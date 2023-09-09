import 'package:contextmonitoringapplication/model/symptom.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SymptomsDatabase {
  static final SymptomsDatabase instance = SymptomsDatabase._init();

  static Database? _database;

  SymptomsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    print("CREATED DATABASE");
    _database = await _initDB('symptoms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $tableSymptoms ( 
        ${SymptomFields.id} $idType, 
        ${SymptomFields.createdTime} $textType,
        ${SymptomFields.heartRate} $integerType,
        ${SymptomFields.respiratoryRate} $integerType,
        ${SymptomFields.nausea} $integerType,
        ${SymptomFields.headache} $integerType,
        ${SymptomFields.diarrhea} $integerType,
        ${SymptomFields.sourThroat} $integerType,
        ${SymptomFields.fever} $integerType,
        ${SymptomFields.muscleAche} $integerType,
        ${SymptomFields.lossOfSmellOrTaste} $integerType,
        ${SymptomFields.cough} $integerType,
        ${SymptomFields.shortnessOfBreath} $integerType,
        ${SymptomFields.feelingTired} $integerType
        )
      ''');
  }

  Future<Symptom> create(Symptom symptom) async {
    final db = await instance.database;

    final id = await db.insert(tableSymptoms, symptom.toJson());
    print(id);
    return symptom.copy(id: id);
  }

  Future<Symptom> readSymptom(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableSymptoms,
      columns: SymptomFields.values,
      where: '${SymptomFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Symptom.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Symptom>> readAllSymptoms() async {
    final db = await instance.database;

    const orderBy = '${SymptomFields.createdTime} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableSymptoms ORDER BY $orderBy');

    final result = await db.query(tableSymptoms, orderBy: orderBy);

    return result.map((json) => Symptom.fromJson(json)).toList();
  }

  Future<int> update(Symptom symptom) async {
    final db = await instance.database;

    return db.update(
      tableSymptoms,
      symptom.toJson(),
      where: '${SymptomFields.id} = ?',
      whereArgs: [symptom.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableSymptoms,
      where: '${SymptomFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}