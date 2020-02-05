import 'package:flutter/material.dart';
import 'package:flutter_app/database.dart';
import 'package:flutter_app/player.dart';
import 'serverCom.dart';
import 'package:connectivity/connectivity.dart';

void main() => runApp(PlayersApp());

class PlayersApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Players List',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.blue,
        ),
        home: new PlayerList()
    );
  }
}

class PlayerList extends StatefulWidget {
  @override
  createState() => new PlayerListState();
}

class PlayerListState extends State<PlayerList> {
  ServerCom serverCom =  new ServerCom();
  DatabaseProvider dbProvider = new DatabaseProvider();
  var subscription;

  @override
  initState() {
    super.initState();

    subscription = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      sendData();
    });
  }

  void sendData() async {
    List<Player> players = await getItems();
    serverCom.sendData(players);
  }

  Future<bool> checkConnection() async {
    var conres = await Connectivity().checkConnectivity();
    if(conres == ConnectivityResult.wifi){
      return true;
    }
    return false;
  }

  Future<List<Player>> getItems() async {
    return await dbProvider.getPlayers();
  }

  void addItem(Player player) async {
    if (player.name.length > 0) {
      await dbProvider.insertPlayer(player);
      await serverCom.addPlayer(player);
      setState(() {});
    }
  }

  void removeItem(int id) async {
    await dbProvider.deletePlayer(id);
    await serverCom.deletePlayer(id);
    setState(() {});
  }

  void updateItem(Player player) async {
    if (player.name.length > 0) {
      await dbProvider.updatePlayer(player);
      await serverCom.updatePlayer(player);
      setState(() {});
    }
  }

  void promptRemoveItem(Player player) async{
    if(await checkConnection()) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
                title: new Text("Delete player"),
                actions: <Widget>[
                  new FlatButton(
                      child: new Text("CANCEL"),
                      onPressed: () => Navigator.of(context).pop()
                  ),
                  new FlatButton(
                      child: new Text("OK"),
                      onPressed: () {
                        removeItem(player.id);
                        Navigator.of(context).pop();
                      }
                  )
                ]
            );
          }
      );
    }
    else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
                title: new Text("No network"),
                actions: <Widget>[
                  new FlatButton(
                      child: new Text("OK"),
                      onPressed: () => Navigator.of(context).pop()
                  )
                ]
            );
          }
      );
    }
  }

  Widget buildList() {
    return FutureBuilder(
        builder: (builder, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          List<Player> items = snapshot.data;
          return new ListView.builder(
              itemBuilder: (context, index) {
                if (index < items.length) {
                  return buildItem(items[index]);
                } else {
                  return null;
                }
              }
          );
        },
        future: getItems()
    );
  }

  Widget buildItem(Player player) {
    return new ListTile(
      title: new Text(player.name),
      onTap: () => promptRemoveItem(player),
      onLongPress: () => pushUpdateScreen(player),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("My players")
        ),
        body: buildList(),
        floatingActionButton: new FloatingActionButton(
            onPressed: pushAddScreen,
            tooltip: "Add new player",
            child: new Icon(Icons.add)
        )
    );
  }

  void pushAddScreen() {
    Navigator.of(context).push(
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  appBar: new AppBar(
                      title: new Text("Add new player")
                  ),
                  body: new TextField(
                    autofocus: true,
                    onSubmitted: (val) {
                      addItem(new Player(id: -1, name: val));
                      Navigator.pop(context);
                    },
                    decoration: new InputDecoration(
                        hintText: "Enter the new player here",
                        contentPadding: const EdgeInsets.all(16.0)
                    ),
                  )
              );
            }
        )
    );
  }

  void pushUpdateScreen(Player player) async {
    if(await checkConnection()) {
      Navigator.of(context).push(
          new MaterialPageRoute(
              builder: (context) {
                return new Scaffold(
                    appBar: new AppBar(
                        title: new Text("Update player")
                    ),
                    body: new TextField(
                        controller: TextEditingController()
                          ..text = player.name,
                        autofocus: true,
                        onSubmitted: (val) {
                          updateItem(new Player(id: player.id, name: val));
                          Navigator.pop(context);
                        },
                        decoration: new InputDecoration(
                            hintText: "Enter player here",
                            contentPadding: const EdgeInsets.all(16.0)
                        )
                    )
                );
              }
          )
      );
    }
    else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return new AlertDialog(
                title: new Text("No network"),
                actions: <Widget>[
                  new FlatButton(
                      child: new Text("OK"),
                      onPressed: () => Navigator.of(context).pop()
                  )
                ]
            );
          }
      );
    }
  }

  @override
  dispose() {
    super.dispose();

    subscription.cancel();
  }
}
