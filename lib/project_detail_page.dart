import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import 'project_data.dart';

class ProjectDetailPage extends StatelessWidget {
  final Project project;

  ProjectDetailPage({Key? key, required this.project}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name)),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _projectName(),
            SizedBox(height: 3),
            // 이미지가 있다면 표시
            _buildOriginalImageSection(),
            SizedBox(height: 3),
            // 모니터링 항목 및 측정값 표시
            _buildProcessedImageSection(),
            SizedBox(height: 3),
            // 모니터링 항목 및 측정값 표시
            _buildProcessedDataSection(),
            // 추가로 필요한 정보 또는 기능이 있다면 여기에 추가
          ],
        ),
      ),
    );
  }

  Widget _projectName() {
    // 프로젝트 이름, 프로젝트 생성일 박스
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
            child: Text(
              '${project.name}',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
            child: Text(
                'Creation Date: ${DateFormat.yMMMd().format(
                    project.creationDate)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalImageSection() {
    // 원본 이미지 위젯
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(5.0, 3.0, 0.0, 0.0),
              child: const Text(
                "원본 이미지",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
          Container(
            margin: EdgeInsets.all(5.0),
            child: project.imagePath != null
                ? Image.file(File(project.imagePath!),
                height: 200, fit: BoxFit.cover)
                : Text('이미지 없음'),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessedImageSection() {
    // 처리된 이미지 위젯
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(5.0, 3.0, 0.0, 0.0),
              child: const Text(
                "후처리된 이미지",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              )),
          Container(
            margin: EdgeInsets.all(5.0),
            child: project.processedImageUrl != null
                ? Image.network(project.processedImageUrl!,
                height: 200, fit: BoxFit.cover)
                : Text('이미지 없음'),
          ),
        ],
      ),
    );
  }


  Widget _buildProcessedDataSection() {
    // 모니터링 식물 물리 데이터
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Mean R Values: ${project.meanR?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(fontSize: 20),),
            SizedBox(height: 3),
            Text('Mean G Values: ${project.meanG?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(fontSize: 20),),
            SizedBox(height: 3),
            Text('Mean B Values: ${project.meanB?.toStringAsFixed(2) ?? 'N/A'}',
              style: TextStyle(fontSize: 20),),
            SizedBox(height: 3),
            Text('Green Pixel Count: ${project.greenPixelCount?.toString() ??
                'N/A'}', style: TextStyle(fontSize: 20),),
            // 기타 필요한 모니터링 데이터가 있다면 여기에 추가
          ],
        ),
      ),
    );
  }
}



