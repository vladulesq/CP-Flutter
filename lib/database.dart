import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_app/player.dart';

class DatabaseProvider {
  Future<Database> getDatabase() async {
    return openDatabase(
        join(await getDatabasesPath(), "players.db"),
        onCreate: (db, version) async {
          await db.execute(
              "CREATE TABLE players(id INTEGER PRIMARY KEY, name TEXT)"
          );
        },
        version: 1
    );
  }

  Future<List<Player>> getPlayers() async {
    final Database db = await getDatabase();
    final List<Map<String, dynamic>> maps = await db.query("players");
    return List.generate(maps.length, (i) {
      return Player(
          id: maps[i]["id"],
          name: maps[i]["name"]
      );
    });
  }

  Future<void> insertPlayer(Player player) async {
    final Database db = await getDatabase();
    await db.insert(
        "players",
        player.toMapNoId(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> updatePlayer(Player player) async {
    final Database db = await getDatabase();
    await db.update(
        "players",
        player.toMap(),
        where: "id = ?",
        whereArgs: [player.id]
    );
  }

  Future<void> deletePlayer(int id) async {
    final Database db = await getDatabase();
    await db.delete(
        "players",
        where: "id = ?",
        whereArgs: [id]
    );
  }
}