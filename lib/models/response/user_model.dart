class UserModel {
  String? id;
  String? fullName;
  String? username;
  String? password;
  String? supportpin;
  String? ip;
  String? date;
  String? createdDate;
  String? createdTime;
  String? web3BscAddress;
  String? web3BscAddressKey;
  String? status;
  String? locked;
  String? loginTries;
  String? lastLoginTry;
  dynamic admin;
  dynamic secret;
  dynamic authused;

  UserModel({
    this.id,
    this.fullName,
    this.username,
    this.password,
    this.supportpin,
    this.ip,
    this.date,
    this.createdDate,
    this.createdTime,
    this.web3BscAddress,
    this.web3BscAddressKey,
    this.status,
    this.locked,
    this.loginTries,
    this.lastLoginTry,
    this.admin,
    this.secret,
    this.authused,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['full_name'];
    username = json['username'];
    password = json['password'];
    supportpin = json['supportpin'];
    ip = json['ip'];
    date = json['date'];
    createdDate = json['created_date'];
    createdTime = json['created_time'];
    web3BscAddress = json['web3_bsc_address'];
    web3BscAddressKey = json['web3_bsc_address_key'];
    status = json['status'];
    locked = json['locked'];
    loginTries = json['login_tries'];
    lastLoginTry = json['last_login_try'];
    admin = json['admin'];
    secret = json['secret'];
    authused = json['authused'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['full_name'] = fullName;
    data['username'] = username;
    data['password'] = password;
    data['supportpin'] = supportpin;
    data['ip'] = ip;
    data['date'] = date;
    data['created_date'] = createdDate;
    data['created_time'] = createdTime;
    data['web3_bsc_address'] = web3BscAddress;
    data['web3_bsc_address_key'] = web3BscAddressKey;
    data['status'] = status;
    data['locked'] = locked;
    data['login_tries'] = loginTries;
    data['last_login_try'] = lastLoginTry;
    data['admin'] = admin;
    data['secret'] = secret;
    data['authused'] = authused;
    return data;
  }
}
