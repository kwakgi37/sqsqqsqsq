import 'package:flutter/material.dart';
import 'package:gvi/DatabaseHelper.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import 'my_page.dart';
import 'project_data.dart';


class ProjectCreationStep4 extends StatefulWidget {
  final Project project;
  final String? imagePath; // 이미지 경로를 전달받을 변수 추가
  final Function onComplete;

  const ProjectCreationStep4({
    Key? key,
    required this.project,
    this.imagePath,
    required this.onComplete,
  }) : super(key: key);

  @override
  _ProjectCreationStep4State createState() => _ProjectCreationStep4State();
}

class _ProjectCreationStep4State extends State<ProjectCreationStep4> {
  final databaseHelper = DatabaseHelper();
  double? meanR, meanG, meanB;
  double? greenPixelCount;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // imagePath가 null이 아닐 때만 이미지 처리 요청을 시작합니다.
    if (widget.imagePath != null) {
      uploadImage(widget.imagePath!);
    }
  }

  Future<void> uploadImage(String imagePath) async {
    setState(() {
      _isLoading = true;
    });

    Uri uri = Uri.parse('http://192.168.19.254:8080/upload');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imagePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await http.Response.fromStream(response);
      var data = jsonDecode(responseBody.body);
      setState(() {
        _isLoading = false;
        // _imageUrl = data['processed_image_url']; // 이전에 사용
        widget.project.processedImageUrl = data['processed_image_url'];
        widget.project.meanR = double.tryParse(data['mean_R'].toString());
        widget.project.meanG = double.tryParse(data['mean_G'].toString());
        widget.project.meanB = double.tryParse(data['mean_B'].toString());
        widget.project.greenPixelCount =
            double.tryParse(data['green_pixel_count'].toString());
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Server error: ${response.statusCode}');
    }
  }

  void saveProjectAndGoToMyPage() {
    // 프로젝트 정보를 ProjectData에 추가하는 로직
    Provider.of<ProjectData>(context, listen: false).addProject(widget.project);

    // 모든 루틴을 종료하고 MyPage로 바로 넘어갑니다.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyPage()), // MyPage로 이동
          (Route<dynamic> route) => false, // 현재 스택에 있는 모든 페이지를 제거
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Processing'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check), // 버튼 아이콘을 '체크'로 변경
            onPressed: _isLoading
                ? null
                : saveProjectAndGoToMyPage, // 로딩 중이 아닐 때 saveProjectAndGoToMyPage 호출
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이미지 URL이 null이 아닐 경우 이미지를 표시하고, 그렇지 않으면 '이미지 없음' 메시지를 표시
            widget.project.processedImageUrl != null
                ? Image.network(
                widget.project.processedImageUrl!, height: 500,
                fit: BoxFit.cover)
                : Text('Processed image is not available'),
            SizedBox(height: 10), // 수치들 사이에 간격 추가
            Text('Mean R: ${widget.project.meanR?.toStringAsFixed(2) ??
                'N/A'}'),
            Text('Mean G: ${widget.project.meanG?.toStringAsFixed(2) ??
                'N/A'}'),
            Text('Mean B: ${widget.project.meanB?.toStringAsFixed(2) ??
                'N/A'}'),
            Text('Green Pixel Count: ${widget.project.greenPixelCount
                ?.toString() ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
