class Server {
  int? _id;
  late String _name;
  late String _localUrl;
  late String _externalUrl;
//
  // Server(this._name, this._localUrl, this._externalUrl);
  Server(this._name, this._localUrl, this._externalUrl);
  Server.withId(this._id, this._name, this._localUrl, this._externalUrl);

  int? get id => _id;
  String get name => _name;
  String get localUrl => _localUrl;
  String get externalUrl => _externalUrl;

  set name(String newName) {
    if (newName.length <= 255) {
      _name = newName;
    }
  }

  set localUrl(String newLocalUrl) {
    if (newLocalUrl.length <= 255) {
      _localUrl = newLocalUrl;
    }
  }

  set externalUrl(String newExternalUrl) {
    if (newExternalUrl.length <= 255) {
      _externalUrl = newExternalUrl;
    }
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['localUrl'] = _localUrl;
    map['externalUrl'] = _externalUrl;
    return map;
  }

  Server.fromMap(Map<String, dynamic> map) {
    _id = map['id'];
    _name = map['name'];
    _localUrl = map['localUrl'];
    _externalUrl = map['externalUrl'];
  }
}
