import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:multiassistant/helper/model.dart';

class Helper {
  static Helper? _helper;
  static Database? _db;

  String tableName = 'servers';
  String colId = 'id';
  String name = 'name';
  String localUrl = 'localUrl';
  String externalUrl = 'externalUrl';

  Helper._createInstance();

  factory Helper() {
    _helper ??= Helper._createInstance();
    return _helper!;
  }

  Future<Database> get db async {
    _db ??= await initializeDb();
    return _db!;
  }

  Future<Database> initializeDb() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}servers.db';
    var db = await openDatabase(path, version: 1, onCreate: _createDb);
    return db;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $name TEXT, $localUrl TEXT, $externalUrl TEXT)');
  }

  Future<List<Map<String, dynamic>>> getServersMapList() async {
    Database db = await this.db;
    var result = await db.query(tableName);
    return result;
  }

  Future<int> insertServer(Server server) async {
    Database db = await this.db;
    var result = await db.insert(tableName, server.toMap());
    return result;
  }

  Future<int> updateServer(Server server) async {
    Database db = await this.db;
    var result = await db.update(tableName, server.toMap(),
        where: '$colId = ?', whereArgs: [server.id]);
    return result;
  }

  Future<int> deleteServer(int id) async {
    Database db = await this.db;
    int result =
        await db.rawDelete('DELETE FROM $tableName WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.db;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $tableName');
    int result = Sqflite.firstIntValue(x)!;
    return result;
  }

  Future<List<Server>> getServersList() async {
    var serverMapList = await getServersMapList();
    int count = serverMapList.length;
    List<Server> serverList = <Server>[];
    for (int i = 0; i < count; i++) {
      serverList.add(Server.fromMap(serverMapList[i]));
    }
    return serverList;
  }
}
