import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/DataModel.dart' as model;
import 'screens/accounts_screen.dart';
import 'screens/add_edit_account_screen.dart';
import 'screens/add_edit_category_screen.dart';
import 'screens/add_edit_transaction_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/settings_screen.dart';
import 'values/theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  final String appName = 'Money Helper';

  static final String routeHome = '/';
  static final String routeCategories = '/category';
  static final String routeAddEditCategory = '/category/add_edit';
  static final String routeAccounts = '/account';
  static final String routAddEditAccount = '/account/add_edit';
  static final String routeAddEditTransaction = '/transaction/add_edit';
  static final String routeSettings = '/settings';
  static final String routeLogin = '/login';
  static final String routeRegistration = '/registration';

  static final String userPrefKey = 'user';

  static int curUser = -1;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences _preferences;

  DateTime start, end;
  bool isInit = true;

  @override
  void initState() {
    super.initState();
    start = DateTime.now();
    end = start.add(Duration(milliseconds: 300));
  }

  init() {
    if (isInit) {
      SharedPreferences.getInstance()
        ..then((prefs) {
          debugPrint('getInstance');
          setState(() {
            this._preferences = prefs;
            _loadUserPref();
            isInit = false;
          });
          debugPrint('then');
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    /*debugPrint('user ' + user.toString());*/

    return FutureBuilder<void>(
      future: init(),
      builder: (context, snapshot) {
        if (DateTime.now().millisecondsSinceEpoch <=
            end.millisecondsSinceEpoch) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: appTheme.accentColor,
            ),
          );
        }
        return MaterialApp(
          initialRoute:
              MyApp.curUser == -1 ? MyApp.routeLogin : MyApp.routeHome,
          routes: {
            MyApp.routeHome: (BuildContext context) => HomeScreen(),
            MyApp.routeCategories: (BuildContext context) => CategoriesScreen(),
            MyApp.routeAddEditCategory: (BuildContext context) =>
                AddEditCategoryScreen(),
            MyApp.routeAccounts: (BuildContext context) => AccountsScreen(),
            MyApp.routAddEditAccount: (BuildContext context) =>
                AddEditAccountScreen(),
            MyApp.routeAddEditTransaction: (BuildContext context) =>
                AddEditTransactionScreen(),
            MyApp.routeSettings: (BuildContext context) => SettingsScreen(),
            MyApp.routeLogin: (BuildContext context) => LoginScreen(),
            MyApp.routeRegistration: (BuildContext context) =>
                RegistrationScreen(),
          },
          debugShowCheckedModeBanner: false,
          theme: appTheme,
        );
      },
    );
  }

  void _loadUserPref() {
    setState(() {
      MyApp.curUser = this._preferences.getInt(MyApp.userPrefKey) ?? -1;
    });
  }
}

// You can pass any object to the arguments parameter. In this example,
// create a class that contains both a customizable title and message.
class ScreensArguments {
  final TypeOperation operation;
  Type type;
  model.Category category;
  model.Category category_1;
  model.Account account;
  model.Account account_1;
  model.Transaction transaction;
  model.Transaction transaction_1;

  ScreensArguments(
      {@required this.operation,
      this.type,
      this.category,
      this.category_1,
      this.account,
      this.account_1,
      this.transaction,
      this.transaction_1});
}

class DateFromDB {}

class DateInfo implements DateFromDB {
  DateTime date;
  int day;
  int week;
  int month;
  int year;

  DateInfo({this.date, this.day, this.week, this.month, this.year});

  DateInfo.fromMap(Map<String, dynamic> map) {
    date = DateTime.parse(map[model.vColDDate]);
    day = int.parse(map[model.vColDDay]);
    week = int.parse(map[model.vColDDay]);
    month = int.parse(map[model.vColDMonth]);
    year = int.parse(map[model.vColDYear]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      model.vColDDate: date,
      model.vColDDay: day,
      model.vColDWeek: week,
      model.vColDMonth: month,
      model.vColDYear: year,
    };
    return map;
  }
}

class DateInfoWithWeek implements DateInfo {
  DateTime date;
  int day;
  int week;
  int month;
  int year;
  DateTime weekStart;
  DateTime weekEnd;

  DateInfoWithWeek({
    this.date,
    this.day,
    this.week,
    this.month,
    this.year,
    this.weekStart,
    this.weekEnd,
  });

  DateInfoWithWeek.fromMap(Map<String, dynamic> map) {
    date = DateTime.parse(map[model.vColWIDate]);
    day = int.parse(map[model.vColDDay]);
    week = int.parse(map[model.vColWIWeek]);
    month = int.parse(map[model.vColDMonth]);
    year = int.parse(map[model.vColDYear]);
    weekStart = DateTime.parse(map[model.vColWIStart]);
    weekEnd = DateTime.parse(map[model.vColWIEnd]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      model.vColWIDate: date,
      model.vColDDay: day,
      model.vColWIWeek: week,
      model.vColDMonth: month,
      model.vColDYear: year,
      model.vColWIStart: weekStart,
      model.vColWIEnd: weekEnd,
    };
    return map;
  }
}

class DateAll implements DateFromDB {
  DateTime timeStart;
  DateTime timeEnd;

  DateAll({this.timeStart, this.timeEnd});

  DateAll.fromMap(Map<String, dynamic> map) {
    timeStart = DateTime.parse(map[model.vColDateAllStart]);
    timeEnd = DateTime.parse(map[model.vColDateAllEnd]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      model.vColDateAllStart: timeStart,
      model.vColDateAllEnd: timeEnd,
    };
    return map;
  }
}

// удалить
class WeekInfo implements DateFromDB {
  int weekNUmber;
  DateTime start;
  DateTime end;
  int count;

  WeekInfo({this.weekNUmber, this.start, this.end, this.count});

  WeekInfo.fromMap(Map<String, dynamic> map) {
    weekNUmber = int.parse(map[model.vColWIWeek]);
    start = DateTime.parse(map[model.vColWIStart]);
    end = DateTime.parse(map[model.vColWIEnd]);
    weekNUmber = int.parse(map[model.vColWIWeek]);
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      model.vColWIWeek: weekNUmber,
      model.vColWIStart: start,
      model.vColWIEnd: end,
      model.vColWICount: count
    };
    return map;
  }
}

enum TypeOperation { Add, Edit, Remove }
enum Type { Income, Expense, Transfer }
enum Period { Day, Week, Month, Year, All, ExactDate }
