import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;


import 'project_data.dart';
import 'project_creation_step1.dart';
import 'project_creation_step2.dart';
import 'project_creation_step4.dart';
import 'project_detail_page.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  Future<void> createProjectOnServer(String projectName) async {
    final url = Uri.parse('http://192.168.19.254:8080/upload');
    final response = await http.post(url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({'name': projectName}));

    if (response.statusCode == 200) {
      // 성공적으로 서버에 프로젝트를 생성했을 때의 로직
      print('Project created successfully');
    } else {
      // 에러 처리
      print('Failed to create project on server');
    }
  }

  void _startProjectCreationProcess() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) =>
          ProjectCreationStep1(
            onNext: (Project project) {
              _navigateToStep2(project);
              // 서버와의 통신을 트리거하는 부분, 예시로 projectName을 보냄
              createProjectOnServer(project.name);
            },
          ),
    ));
  }


  void _navigateToStep2(Project project) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProjectCreationStep2(
        project: project,
        onNext: (Project updatedProject) {
          _navigateToStep4(updatedProject);
        },
      ),
    ));
  }

  void _navigateToStep4(Project project) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProjectCreationStep4(
        project: project,
        imagePath: project.imagePath, // 수정: Project 객체에서 imagePath를 직접 사용
        onComplete: () {
          Provider.of<ProjectData>(context, listen: false).addProject(project);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    ));
  }


  void _openProjectDetails(Project project) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ProjectDetailPage(project: project),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'G-VISION',
          textAlign: TextAlign.left,
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.add, size: 40.0, color: Colors.black87),
              onPressed: _startProjectCreationProcess,
            ),
          )
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Consumer<ProjectData>(
        builder: (context, projectData, child) {
          return ListView.builder(
            itemCount: projectData.projects.length,
            itemBuilder: (context, index) {
              final project = projectData.projects[index];
              return _buildProjectCard(context, project, index);
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: '프로젝트 목록',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.unarchive),
            label: '공유함',
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project, int index) {
    return InkWell(
      onTap: () => _openProjectDetails(project),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          width: double.infinity,
          height: 120.0,
          alignment: Alignment.center,
          child: Row(
            children: [
              _buildImageContainer(project),
              _buildProjectInfo(project),
              _buildPopupMenuButton(context, index),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer(Project project) {
    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.all(10.0),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: Colors.grey[200],
      ),
      child: project.imagePath != null
          ? AspectRatio(
              aspectRatio: 1.0,
              child: Image.file(File(project.imagePath!), fit: BoxFit.cover),
            )
          : const SizedBox(),
    );
  }

  Widget _buildProjectInfo(Project project) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              project.name,
              style:
                  const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Creation Date: ${DateFormat.yMMMd().format(project.creationDate)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupMenuButton(BuildContext context, int index) {
    return PopupMenuButton<String>(
      onSelected: (String value) {
        if (value == 'edit') {
          _editProjectName(context, index);
        } else if (value == 'delete') {
          _deleteProject(context, index);
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('이름 편집'),
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('프로젝트 삭제'),
            ),
          ),
        ];
      },
    );
  }

  Future<void> _editProjectName(BuildContext context, int index) async {
    final projectData = Provider.of<ProjectData>(context, listen: false);
    final project = projectData.projects[index];
    TextEditingController _nameEditController =
        TextEditingController(text: project.name);

    String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('프로젝트 이름 편집'),
          content: TextField(
            controller: _nameEditController,
            decoration: const InputDecoration(hintText: '새 이름 입력'),
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('저장'),
              onPressed: () {
                Navigator.of(context).pop(_nameEditController.text);
              },
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      project.name = newName;
      projectData.editProject(index, project);
    }
  }

  void _deleteProject(BuildContext context, int index) {
    Provider.of<ProjectData>(context, listen: false).deleteProject(index);
  }
}
