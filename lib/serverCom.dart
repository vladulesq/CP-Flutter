import 'dart:convert';

import 'package:http/http.dart' as http;
import 'player.dart';

class ServerCom {
  Future<bool> deletePlayer(int player_id) async {
    try {
      final response = await http.delete(
          "http://192.168.43.166:5000/players/" + player_id.toString());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> updatePlayer(Player player) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> myJson = player.toMapNoId();

    try {
      final response = await http.put(
          "http://192.168.43.166:5000/players/" + player.id.toString(), headers: headers,
          body: json.encode(myJson));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> addPlayer(Player player) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    Map<String, dynamic> myJson = player.toMapNoId();

    try {
      final response = await http.post(
          "http://192.168.43.166:5000/players", headers: headers,
          body: json.encode(myJson));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendData(List<Player> players) async {
    Map<String, String> headers = {"Content-type": "application/json"};
    for(Player player in players) {
      Map<String, dynamic> myJson = player.toMap();
      try {
        final response = await http.post(
            "http://192.168.43.166:5000/players/sync", headers: headers,
            body: json.encode(myJson));
        if (response.statusCode == 200 || response.statusCode == 201) {
          continue;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }
    return true;
  }
}