import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProjectDB {
  int? id;
  String name;
  String? imagePath; // 업로드할 이미지의 경로
  String date;
  double? meanR; // RGB 평균값
  double? meanG;
  double? meanB;
  double? greenPixelCount; // 녹색 픽셀 수
  String? processedImageUrl;

  ProjectDB({
    this.id,
    required this.name,
    this.imagePath,
    required this.date,
    this.meanR,
    this.meanG,
    this.meanB,
    this.greenPixelCount,
    this.processedImageUrl,
  });

  Map<String, dynamic> toMap() {
    return{
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'date': date,
      'meanR': meanR,
      'meanG': meanG,
      'meanB': meanB,
      'greenPixelCount': greenPixelCount,
      'processedImageUrl': processedImageUrl,
    };
  }

  static ProjectDB fromMap(Map<String, dynamic>map) {
    return ProjectDB(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
      date: map['creationDate'],
      meanR: map['meanR'],
      meanG: map['meanG'],
      meanB: map['meanB'],
      greenPixelCount: map['greenPixelCount'],
      processedImageUrl: map['processedImageUrl'],
    );
  }
}

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'projectdb.db');
    return await openDatabase(
      path,
      version: 2, // 버전 변경
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE projectsdb(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            imagePath TEXT,
            date TEXT,
            meanR REAL,
            meanG REAL,
            meanB REAL,
            greenPixelCount REAL,
            processedImageUrl TEXT,
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS projectsdb');
          await initDatabase(); // 테이블 재생성
        }
      },
    );
  }

  Future<int> insertProjectDB(ProjectDB projectdb) async {
    Database db = await database;
    return await db.insert('projectsdb', projectdb.toMap());
  }

  Future<List<ProjectDB>> getProjectsDB() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('projectsdb');
    return maps.map((map) => ProjectDB.fromMap(map)).toList(); // fromMap 사용
  }

  Future<void> updateProjectDB(ProjectDB projectdb) async {
    Database db = await database;
    await db.update(
      'projectsdb',
      projectdb.toMap(),
      where: 'id = ?',
      whereArgs: [projectdb.id],
    );
  }

  Future<void> deleteProjectDB(int id) async {
    Database db = await database;
    await db.delete(
      'projectsdb',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}