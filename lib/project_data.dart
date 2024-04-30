import 'package:flutter/foundation.dart';
import 'DatabaseHelper.dart';

class Project {
  int? id;
  String name;
  String? imagePath; // 업로드할 이미지의 경로
  DateTime creationDate;
  double? meanR; // RGB 평균값
  double? meanG;
  double? meanB;
  double? greenPixelCount; // 녹색 픽셀 수
  String? processedImageUrl; // 처리된 이미지의 URL

  Project({
    this.id,
    required this.name,
    required this.creationDate,
    this.imagePath,
    this.meanR,
    this.meanG,
    this.meanB,
    this.greenPixelCount,
    this.processedImageUrl,
  });

  // Project to Proj (데이터베이스 모델로 변환)
  ProjectDB toProjectDB() {
    return ProjectDB(
      id: id,
      name: name,
      imagePath: imagePath,
      date: creationDate.toIso8601String(),
      meanR: meanR,
      meanG: meanG,
      meanB: meanB,
      greenPixelCount: greenPixelCount,
      processedImageUrl: processedImageUrl,
    );
  }

  // Proj to Project (프로바이더 모델로 변환)
  static Project fromProjectDB(ProjectDB projectdb) {
    return Project(
      id: projectdb.id,
      name: projectdb.name,
      imagePath: projectdb.imagePath,
      creationDate: DateTime.parse(projectdb.date), // 문자열에서 DateTime으로 변환
      meanR: projectdb.meanR,
      meanG: projectdb.meanG,
      meanB: projectdb.meanB,
      greenPixelCount: projectdb.greenPixelCount,
      processedImageUrl: projectdb.processedImageUrl,
    );
  }
}

class ProjectData with ChangeNotifier {
  final DatabaseHelper databaseHelper;

  List<Project> _projects = [];

  ProjectData({required this.databaseHelper}) {
    _loadProjects();
  }

  List<Project> get projects => _projects;

  Future<void> _loadProjects() async {
    var projectsdb = await databaseHelper.getProjectsDB(); // 데이터베이스에서 가져오기
    _projects = projectsdb.map((projectdb) => Project.fromProjectDB(projectdb)).toList(); // Project로 변환
    notifyListeners();
  }

  Future<void> addProject(Project project) async {
    var projectdb = project.toProjectDB(); // ProjectDB로 변환
    int id = await databaseHelper.insertProjectDB(projectdb); // 데이터베이스에 추가
    project.id = id; // 생성된 ID 설정
    _projects.add(project); // 프로바이더 상태 업데이트
    notifyListeners(); // 데이터 변경 알림
  }

  Future<void> editProject(int index, Project updatedProject) async {
    if (index >= 0 && index < _projects.length) {
      // ProjectDB 객체를 생성하고 이름을 변경
      var updatedProj = updatedProject.toProjectDB(); // ProjectDB 객체로 변환
      updatedProj.name = updatedProject.name; // 새로운 이름으로 업데이트
      updatedProj.id = _projects[index].id; // 기존 ID 유지

      await databaseHelper.updateProjectDB(updatedProj); // 데이터베이스 업데이트

      // 프로바이더의 내부 상태 업데이트
      _projects[index] = updatedProject; // 프로바이더의 프로젝트 리스트 업데이트
      notifyListeners(); // UI에 변경 사항 알림
    }
  }

  Future<void> deleteProject(int index) async {
    if (index >= 0 && index < _projects.length) {
      int id = _projects[index].id!;
      await databaseHelper.deleteProjectDB(id); // 데이터베이스에서 삭제
      _projects.removeAt(index); // 프로바이더 상태 업데이트
      notifyListeners(); // 데이터 변경 알림
    }
  }

  void updateProjectWithProcessingResults(String projectId, {double? meanR, double? meanG, double? meanB, double? greenPixelCount, String? processedImageUrl}) {
    var project = _projects.firstWhere((project) => project.id == projectId);
    project.meanR = meanR;
    project.meanG = meanG;
    project.meanB = meanB;
    project.greenPixelCount = greenPixelCount;
    project.processedImageUrl = processedImageUrl;
    notifyListeners();
  }
}
