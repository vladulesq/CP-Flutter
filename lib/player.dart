class Player {
  int id;
  String name;

  Player({ this.id, this.name });

  factory Player.fromMap(Map<String, dynamic> json) => new Player(
      id: json["id"],
      name: json["name"]
  );

  Map<String, dynamic> toMap() => {
    "id": id,
    "name": name
  };

  Map<String, dynamic> toMapNoId() => {
    "name": name
  };
}