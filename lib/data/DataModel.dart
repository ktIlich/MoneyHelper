final String url = 'http://ca5c5507f1da.ngrok.io';

final String tableTypes = 'Types';
final String colTypesId = 'Type_id';
final String colTypesName = 'Name';

final String tableIcons = 'Icons';
final String colIconsId = 'Icon_id';
final String colIconsName = 'Name';
final String colIconsType = 'Type';

final String tableAccounts = 'Accounts';
final String colAccId = 'Acc_id';
final String colAccName = 'Name';
final String colAccCurrency = 'Currency';
final String colAccBalance = 'Balance';
final String colAccIcon = 'Icon';

final String tableCategories = 'Categories';
final String colCatId = 'Cat_id';
final String colCatName = 'Name';
final String colCatType = 'Type';
final String colCatIcon = 'Icon';

final String tableTransactions = 'Transactions';
final String colTransId = 'Trans_id';
final String colTransType = 'Type';
final String colTransDate = 'Date';
final String colTransAccount = 'Account';
final String colTransValue = 'Value';
final String colTransNote = 'Note';
final String colTransCategory = 'Category';

final String viewWeekInfo = 'WeekInfo';
final String vColWIDate = 'date';
final String vColWIWeek = 'week';
final String vColWIStart = 'weekStart';
final String vColWIEnd = 'weekEnd';
final String vColWICount = 'countVal';

final String viewDateInfo = 'DateInfo';
final String vColDDate = 'date';
final String vColDDay = 'day';
final String vColDWeek = 'week';
final String vColDMonth = 'month';
final String vColDYear = 'year';

final String viewDateInfoWithWeek = 'DateInfoWithWeek';

final String viewDateAll = 'DateAll';
final String vColDateAllStart = 'timeStart';
final String vColDateAllEnd = 'timeEnd';

final String tableUsers = 'Users';
final String colUsersID = 'UserID';
final String colUsersLogin = 'Login';
final String colUsersPassword = 'Password';

class Type {
  int typeId;
  String name;

  Type({this.typeId, this.name});

  Type.fromMap(Map<String, dynamic> map) {
    typeId = map[colTypesId];
    name = map[colTypesName];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTypesName: name,
    };
    if (colTypesId != null) {
      map[colTypesId] = typeId;
    }
    return map;
  }

  @override
  String toString() {
    return 'Type(typeId: $typeId, name: $name}';
  }
}

class Icon {
  int iconId;
  int type;
  String name;

  Icon({this.iconId, this.type, this.name});

  Icon.fromMap(Map<String, dynamic> map) {
    iconId = map[colIconsId];
    name = map[colIconsName];
    type = map[colIconsType];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colIconsType: type,
      colIconsName: name,
    };
    if (colIconsId != null) {
      map[colIconsId] = iconId;
    }
    return map;
  }

  @override
  String toString() {
    return 'Icon(iconId: $iconId, type: $type, name: $name}';
  }
}

class Account {
  int accId;
  String name;
  String currency;
  double balance;
  int icon;
  int user;

  Account(
      {this.accId,
      this.name,
      this.currency,
      this.balance,
      this.icon,
      this.user});

  Account.fromMap(Map<String, dynamic> map) {
    accId = map[colAccId];
    name = map[colAccName];
    currency = map[colAccCurrency];
    balance = map[colAccBalance];
    icon = map[colAccIcon];
    user = map[colUsersID];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colAccName: name,
      colAccCurrency: currency,
      colAccBalance: balance,
      colAccIcon: icon,
      colUsersID: user
    };
    if (colAccId != null) {
      map[colAccId] = accId;
    }
    return map;
  }

  Map toJson() => {
        colAccName: name,
        colAccCurrency: currency,
        colAccBalance: balance,
        colAccIcon: icon,
        colUsersID: user
      };

  @override
  String toString() {
    return 'Account(accId: $accId, name: $name, currency: $currency, balance: $balance, icon: $icon}';
  }
}

class Category {
  int catId;
  String name;
  int type;
  int icon;
  int user;

  Category({this.catId, this.name, this.type, this.icon, this.user});

  Category.fromMap(Map<String, dynamic> map) {
    catId = map[colCatId];
    name = map[colCatName];
    type = map[colCatType];
    icon = map[colCatIcon];
    user = map[colUsersID];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colCatName: name,
      colCatType: type,
      colCatIcon: icon,
      colUsersID: user,
    };
    if (colCatId != null) {
      map[colCatId] = catId;
    }
    return map;
  }

  Map toJson() => {
        colCatName: name,
        colCatType: type,
        colCatIcon: icon,
        colUsersID: user,
      };

  @override
  String toString() {
    return this.toMap().toString();
  }
}

class Transaction {
  int transId;
  int type;
  String date;
  int account;
  double value;
  String note;
  int category;
  int user;

  Transaction({
    this.transId,
    this.type,
    this.date,
    this.account,
    this.value,
    this.note,
    this.category,
    this.user,
  });

  Transaction.fromMap(Map<String, dynamic> map) {
    transId = map[colTransId];
    type = map[colTransType];
    date = map[colTransDate];
    account = map[colTransAccount];
    value = map[colTransValue];
    note = map[colTransNote];
    category = map[colTransCategory];
    user = map[colUsersID];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTransType: type,
      colTransDate: date,
      colTransAccount: account,
      colTransValue: value,
      colTransNote: note,
      colTransCategory: category,
      colUsersID: user,
    };
    if (colTransId != null) {
      map[colTransId] = transId;
    }
    return map;
  }

  Map toJson() => {
        colTransType: type,
        colTransDate: date,
        colTransAccount: account,
        colTransValue: value,
        colTransNote: note,
        colTransCategory: category,
        colUsersID: user,
      };

  @override
  String toString() {
    return toMap().toString();
  }
}

class User {
  int userId;
  String login;
  String password;

  User({this.userId, this.login, this.password});

  User.fromMap(Map<String, dynamic> map) {
    userId = map[colUsersID];
    login = map[colUsersLogin];
    password = map[colUsersPassword];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colUsersID: userId,
      colUsersLogin: login,
      colUsersPassword: password
    };
    if (colUsersID != null) {
      map[colUsersID] = userId;
    }
    return map;
  }

  Map toJson() =>
      {colUsersID: userId, colUsersLogin: login, colUsersPassword: password};

  @override
  String toString() {
    return 'user(userid: $userId, login: $login, password: $password}';
  }
}
