import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:MoneyHelper/MyApp.dart';
import 'package:MoneyHelper/data/DataModel.dart' as model;
import 'package:MoneyHelper/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDB();
    return _database;
  }

  initDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "MH_DB.db");

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "MH_DB.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }
    // open the database
    var db = await openDatabase(path, readOnly: false);
    db.execute('PRAGMA foreign_keys=ON');

    return db;
  }

  /* Types */

  Future<model.Type> addType(model.Type type) async {
    final Database db = await database;
    try {
      type.typeId = await db.insert(model.tableTypes, type.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (err) {
      print(err);
    }
    return type;
  }

  Future<int> removeType(int id) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.delete(model.tableTypes,
          where: '${model.colTypesId} = ?', whereArgs: [id]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<int> updateType(model.Type type) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.update(model.tableTypes, type.toMap(),
          where: '${model.colTypesId} = ?', whereArgs: [type.typeId]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Type>> getTypes() async {
    final Database db = await database;

    List<model.Type> res = [];
    try {
      final List<Map<String, dynamic>> maps = await db.query(model.tableTypes);
      res = List.generate(maps.length, (i) => model.Type.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<model.Type> getType(int id) async {
    final Database db = await database;

    try {
      List<Map> maps = await db.query(model.tableTypes,
          columns: [model.colTypesId, model.colTypesName],
          where: '${model.colTypesId} = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return model.Type.fromMap(maps.first);
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  /* Icons */

  Future<model.Icon> addIcon(model.Icon icon) async {
    final Database db = await database;
    try {
      icon.iconId = await db.insert(model.tableIcons, icon.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (err) {
      print(err);
    }
    return icon;
  }

  Future<int> removeIcon(int id) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.delete(model.tableIcons,
          where: '${model.colIconsId} = ?', whereArgs: [id]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<int> updateIcon(model.Icon icon) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.update(model.tableIcons, icon.toMap(),
          where: '${model.colIconsId} = ?', whereArgs: [icon.iconId]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Icon>> getIcons() async {
    final Database db = await database;

    List<model.Icon> res = [];
    try {
      final List<Map<String, dynamic>> maps = await db.query(model.tableIcons);
      res = List.generate(maps.length, (i) => model.Icon.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<model.Icon> getIcon(int id) async {
    final Database db = await database;

    try {
      List<Map> maps = await db.query(model.tableIcons,
          columns: [model.colIconsId, model.colIconsName, model.colIconsType],
          where: '${model.colIconsId} = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return model.Icon.fromMap(maps.first);
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  /* Accounts */

  Future<model.Account> addAccount(model.Account acc) async {
    final Database db = await database;
    try {
      acc.accId = await db.insert(model.tableAccounts, acc.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (err) {
      print(err);
    }
    return acc;
  }

  Future<int> removeAccount(int id) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.delete(model.tableAccounts,
          where: '${model.colAccId} = ?', whereArgs: [id]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<int> updateAccount(model.Account acc) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.update(model.tableAccounts, acc.toMap(),
          where: '${model.colAccId} = ?', whereArgs: [acc.accId]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Account>> getAccounts(int user) async {
    final Database db = await database;

    List<model.Account> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.tableAccounts} where ${model.colUsersID} = $user');
      res = List.generate(maps.length, (i) => model.Account.fromMap(maps[i]));
      debugPrint('accounts ' + res.length.toString());
      debugPrint(
          'SELECT * FROM ${model.tableAccounts} where ${model.colUsersID} = $user');
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Account>> getAccountsAll() async {
    final Database db = await database;

    List<model.Account> res = [];
    try {
      List<Map> maps =
          await db.rawQuery('SELECT * FROM ${model.tableAccounts}');
      res = List.generate(maps.length, (i) => model.Account.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<model.Account> getAccount(int id) async {
    final Database db = await database;

    try {
      List<Map> maps = await db.query(model.tableAccounts,
          columns: [
            model.colAccId,
            model.colAccIcon,
            model.colAccBalance,
            model.colAccCurrency,
            model.colAccName,
            model.colUsersID
          ],
          where: '${model.colAccId} = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return model.Account.fromMap(maps.first);
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  /* Category */

  Future<model.Category> addCategory(model.Category cat) async {
    final Database db = await database;
    try {
      cat.catId = await db.insert(model.tableCategories, cat.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (err) {
      print(err);
    }
    return cat;
  }

  Future<int> removeCategory(int id) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.delete(model.tableCategories,
          where: '${model.colCatId} = ?', whereArgs: [id]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<int> updateCategory(model.Category cat) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.update(model.tableCategories, cat.toMap(),
          where: '${model.colCatId} = ?', whereArgs: [cat.catId]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Category>> getCategories(int user) async {
    final Database db = await database;

    List<model.Category> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.tableCategories} where ${model.colUsersID} = $user');
      debugPrint(
          'SELECT * FROM ${model.tableCategories} where ${model.colUsersID} = $user');
      res = List.generate(maps.length, (i) => model.Category.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Category>> getCategoriesAll() async {
    final Database db = await database;

    List<model.Category> res = [];
    try {
      List<Map> maps =
          await db.rawQuery('SELECT * FROM ${model.tableCategories}');
      debugPrint('SELECT * FROM ${model.tableCategories}');
      res = List.generate(maps.length, (i) => model.Category.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Category>> getCategoriesByType(Type type, int user) async {
    final Database db = await database;

    List<model.Category> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.tableCategories} where ${model.colUsersID} = $user and ${model.colCatType} = ${type == Type.Income ? 1 : 2}');
      debugPrint(
          'SELECT * FROM ${model.tableCategories} where ${model.colUsersID} = $user and ${model.colCatType} = ${type == Type.Income ? 1 : 2}');
      res = List.generate(maps.length, (i) => model.Category.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<model.Category> getCategory(int id) async {
    final Database db = await database;

    try {
      List<Map> maps = await db.query(model.tableCategories,
          columns: [
            model.colCatId,
            model.colCatName,
            model.colCatType,
            model.colCatIcon,
            model.colUsersID
          ],
          where: '${model.colCatId} = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return model.Category.fromMap(maps.first);
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  /* Transactions */

  Future<model.Transaction> addTransaction(model.Transaction trans) async {
    final Database db = await database;
    try {
      trans.transId = await db.insert(model.tableTransactions, trans.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (err) {
      print(err);
    }
    return trans;
  }

  Future<int> removeTransaction(int id) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.delete(model.tableTransactions,
          where: '${model.colTransId} = ?', whereArgs: [id]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<int> updateTransaction(model.Transaction trans) async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.update(model.tableTransactions, trans.toMap(),
          where: '${model.colTransId} = ?', whereArgs: [trans.transId]);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Transaction>> getTransactions(int user) async {
    final Database db = await database;

    List<model.Transaction> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.tableTransactions} where ${model.colUsersID} = $user');
      debugPrint(
          'SELECT * FROM ${model.tableTransactions} where ${model.colUsersID} = $user');
      res =
          List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<model.Transaction>> getTransactionsAll() async {
    final Database db = await database;

    List<model.Transaction> res = [];
    try {
      List<Map> maps =
          await db.rawQuery('SELECT * FROM ${model.tableTransactions}');
      res =
          List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<model.Transaction> getTransaction(int id) async {
    final Database db = await database;

    try {
      List<Map> maps = await db.query(model.tableTransactions,
          columns: [
            model.colTransId,
            model.colTransAccount,
            model.colTransCategory,
            model.colTransDate,
            model.colTransNote,
            model.colTransType,
            model.colTransValue,
            model.colUsersID
          ],
          where: '${model.colTransId} = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return model.Transaction.fromMap(maps.first);
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  /*SELECT * FROM Transactions t WHERE strftime('%j', t.Date ) = STRFTIME('%j', datetime('now','localtime')) and t.Account = 2*/
  Future<List<model.Transaction>> getTransactionByParam(
      {@required Period period,
      @required model.Account account,
      @required DateTime date,
      @required int user,
      DateTime date_2}) async {
    final Database db = await database;

    List<model.Transaction> res = [];

    try {
      String _where;
      bool withPeriod = true;
      String _date = date.toLocal().toString();

      switch (period) {
        case Period.Day:
          {
            _where = "where Date(t.${model.colTransDate}) =  DATE('$_date') ";
            withPeriod = true;
            break;
          }
        case Period.Week:
          {
            _where =
                "where strftime('%W', t.${model.colTransDate}) = strftime('%W', DATE('$_date')) and strftime('%Y', t.${model.colTransDate}) = strftime('%Y', DATE('$_date')) ";
            withPeriod = true;
            break;
          }
        case Period.Month:
          {
            _where =
                "where strftime('%m', t.${model.colTransDate}) = strftime('%m', DATE('$_date')) and strftime('%Y', t.${model.colTransDate}) = strftime('%Y', DATE('$_date')) ";
            withPeriod = true;
            break;
          }
        case Period.Year:
          {
            _where =
                "where strftime('%Y', t.${model.colTransDate}) = strftime('%Y', DATE('$_date')) ";
            withPeriod = true;
            break;
          }
        case Period.All:
          {
            _where = '';
            withPeriod = false;
            break;
          }
        default:
          {
            _where = '';
            withPeriod = false;
            break;
          }
      }

      if (account.accId != -1) {
        if (withPeriod) {
          _where += 'and ';
        }
        if (_where.length == 0) {
          _where += 'where ';
        }
        _where += '${model.colTransAccount} = ${account.accId}';
      }

      if (withPeriod) {
        _where += ' and ';
      }
      if (_where.length == 0) {
        _where += 'where ';
      }
      _where += '${model.colUsersID} = $user';

      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.tableTransactions} t $_where order by t.${model.colTransDate}');

      debugPrint(
          'SELECT * FROM ${model.tableTransactions} t $_where order by t.${model.colTransDate}');
      res =
          List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<DateInfo>> getUniqueTransactionDays(int user) async {
    final Database db = await database;
    List<DateInfo> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.viewDateInfo} where ${model.colUsersID} = $user');
      res = List.generate(maps.length, (i) => DateInfo.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<DateInfoWithWeek>> getUniqueTransactionWeeks(int user) async {
    final Database db = await database;
    List<DateInfoWithWeek> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.viewDateInfoWithWeek} where ${model.colUsersID} = $user');
      res =
          List.generate(maps.length, (i) => DateInfoWithWeek.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<DateInfo>> getUniqueTransactionMonths(int user) async {
    final Database db = await database;
    List<DateInfo> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.viewDateInfo} where ${model.colUsersID} = $user group by ${model.vColDYear}, ${model.vColDMonth}');
      res = List.generate(maps.length, (i) => DateInfo.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<DateInfo>> getUniqueTransactionYears(int user) async {
    final Database db = await database;
    List<DateInfo> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.viewDateInfo} where ${model.colUsersID} = $user group by ${model.vColDYear}');
      res = List.generate(maps.length, (i) => DateInfo.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<List<DateAll>> getAllTransactions(int user) async {
    final Database db = await database;
    List<DateAll> res = [];
    try {
      List<Map> maps = await db.rawQuery(
          'SELECT * FROM ${model.viewDateAll} where ${model.colUsersID} = $user');
      res = List.generate(maps.length, (i) => DateAll.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<Balance> getBalance(
      {@required Period period,
      @required model.Account account,
      @required DateTime date,
      @required int user}) async {
    final Database db = await database;

    Balance res;

    try {
      double income, expense, balance;
      String _date = date.toLocal().toString();
      String _where;
      bool withPeriod = true;

      switch (period) {
        case Period.Day:
          {
            _where = "where Date(t.${model.colTransDate}) <=  DATE('$_date') ";
            withPeriod = true;
            break;
          }
        case Period.Week:
          {
            _where =
                "where strftime('%W', t.${model.colTransDate}) <= strftime('%W', DATE('$_date')) and strftime('%Y', t.${model.colTransDate}) = strftime('%Y', DATE('$_date')) ";
            withPeriod = true;
            break;
          }
        case Period.Month:
          {
            _where =
                "where strftime('%m', t.${model.colTransDate}) <= strftime('%m', DATE('$_date')) and strftime('%Y', t.${model.colTransDate}) = strftime('%Y', DATE('$_date')) ";
            withPeriod = true;
            break;
          }
        case Period.Year:
          {
            _where =
                "where strftime('%Y', t.${model.colTransDate}) <= strftime('%Y', DATE('$_date')) ";

            withPeriod = true;
            break;
          }
        case Period.All:
          {
            _where = '';
            withPeriod = false;
            break;
          }
        default:
          {
            _where = '';
            withPeriod = false;
            break;
          }
      }

      if (account.accId != -1) {
        if (withPeriod) {
          _where += 'and ';
        }
        if (_where.length == 0) {
          _where += 'where ';
        }
        _where += '${model.colTransAccount} = ${account.accId}';
      }

      if (withPeriod) {
        _where += ' and ';
      }
      if (_where.length == 0) {
        _where += 'where ';
      }
      _where += ' t.${model.colTransType} = ';

      List<Map> maps = await db.rawQuery(
          'SELECT SUM(t.${model.colTransValue}) as summ FROM ${model.tableTransactions} t $_where 1 and ${model.colUsersID} = $user');
      if (maps.first['summ'] != null) {
        income = maps.first['summ'];
      } else {
        income = 0;
      }

      maps = await db.rawQuery(
          'SELECT SUM(t.${model.colTransValue}) as summ FROM ${model.tableTransactions} t $_where 2 and ${model.colUsersID} = $user');

      if (maps.first['summ'] != null) {
        expense = maps.first['summ'];
      } else {
        expense = 0;
      }

      balance = income - expense;
      balance = num.parse(balance.toStringAsFixed(2));

      res = Balance(
          balance: balance, incomeBalance: income, expenseBalance: expense);

      debugPrint(
          'SELECT SUM(t.${model.colTransValue}) as summ FROM ${model.tableTransactions} t $_where and t.${model.colTransType} = 1 and ${model.colUsersID} = $user');
      debugPrint(res.toString());
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<model.User> addUser(model.User user) async {
    final Database db = await database;
    try {
      user.userId = await db.insert(model.tableUsers, user.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (err) {
      print(err);
    }
    return user;
  }

  Future<List<model.User>> getUsers() async {
    final Database db = await database;

    List<model.User> res = [];
    try {
      final List<Map<String, dynamic>> maps = await db.query(model.tableUsers);
      res = List.generate(maps.length, (i) => model.User.fromMap(maps[i]));
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<model.User> getUser(int id) async {
    final Database db = await database;

    try {
      List<Map> maps = await db.query(model.tableUsers,
          columns: [
            model.colUsersID,
            model.colUsersLogin,
            model.colUsersPassword
          ],
          where: '${model.colUsersID} = ?',
          whereArgs: [id]);
      if (maps.length > 0) {
        return model.User.fromMap(maps.first);
      }
    } catch (err) {
      print(err);
    }
    return null;
  }

  Future<int> removeAllUsers() async {
    final Database db = await database;
    int res = -1;
    try {
      res = await db.delete(model.tableUsers);
    } catch (err) {
      print(err);
    }
    return res;
  }

  Future<int> uploadUsersToServer(List<model.User> users) async {
    String json = jsonEncode(users);
    debugPrint(json);

    var response = await http.post('${model.url}/User/addAll',
        body: json, headers: {'Content-type': 'application/json'});

    if (response.statusCode == 200) {
      return 1;
    } else {
      return -1;
    }
  }

  Future<int> uploadCategoryToServer(List<model.Category> categories) async {
    String json = jsonEncode(categories);
    debugPrint(json);
    var response = await http.post('${model.url}/Category/addAll',
        body: json, headers: {'Content-type': 'application/json'});

    if (response.statusCode == 200) {
      return 1;
    } else {
      return -1;
    }
  }

  Future<int> uploadAccountToServer(List<model.Account> accounts) async {
    String json = jsonEncode(accounts);
    debugPrint(json);
    var response = await http.post('${model.url}/Account/addAll',
        body: json, headers: {'Content-type': 'application/json'});

    if (response.statusCode == 200) {
      return 1;
    } else {
      return -1;
    }
  }

  Future<int> uploadTransactionToServer(
      List<model.Transaction> transactions) async {
    String json = jsonEncode(transactions);
    debugPrint(json);
    var response = await http.post('${model.url}/Transaction/addAll',
        body: json, headers: {'Content-type': 'application/json'});

    if (response.statusCode == 200) {
      return 1;
    } else {
      return -1;
    }
  }

  Future<List<model.User>> downloadUserByServer() async {
    var data = await http.get('${model.url}/User/getAll');
    var dataStr = jsonDecode(data.body);

    List<model.User> _users = [];

    debugPrint(dataStr.toString());

    for (var d in dataStr) {
      _users.add(model.User(
          userId: d[model.colUsersID],
          login: d[model.colUsersLogin],
          password: d[model.colUsersPassword]));
    }

    return _users;
  }

  Future<List<model.Account>> downloadAccountByServer() async {
    var data = await http.get('${model.url}/Account/getAll');
    var dataStr = jsonDecode(data.body);

    List<model.Account> _accs = [];

    debugPrint(dataStr.toString());

    for (var d in dataStr) {
      _accs.add(model.Account(
          accId: d[model.colAccId],
          name: d[model.colAccName],
          currency: d[model.colAccCurrency],
          balance: d[model.colAccBalance],
          icon: d[model.colAccIcon],
          user: d[model.colUsersID]));
    }

    return _accs;
  }

  Future<List<model.Category>> downloadCategoryByServer() async {
    var data = await http.get('${model.url}/Category/getAll');
    var dataStr = jsonDecode(data.body);

    List<model.Category> _cats = [];

    debugPrint(dataStr.toString());

    for (var d in dataStr) {
      _cats.add(model.Category(
        catId: d[model.colCatId],
        name: d[model.colCatName],
        type: d[model.colCatType],
        icon: d[model.colCatIcon],
        user: d[model.colUsersID],
      ));
    }

    return _cats;
  }

  Future<List<model.Transaction>> downloadTransactionByServer() async {
    var data = await http.get('${model.url}/Transaction/getAll');
    var dataStr = jsonDecode(data.body);

    List<model.Transaction> _trans = [];

    debugPrint(dataStr.toString());

    for (var d in dataStr) {
      _trans.add(model.Transaction(
        transId: d[model.colTransId],
        type: d[model.colTransType],
        date: d[model.colTransDate],
        account: d[model.colTransAccount],
        value: d[model.colTransValue],
        note: d[model.colTransNote],
        category: d[model.colTransCategory],
        user: d[model.colUsersID],
      ));
    }

    return _trans;
  }
}
