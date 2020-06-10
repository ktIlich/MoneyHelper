import 'package:MoneyHelper/data/DataModel.dart' as model;
import 'package:MoneyHelper/data/Database.dart';
import 'package:MoneyHelper/values/app_icons.dart';
import 'package:MoneyHelper/values/app_icons_color.dart';
import 'package:MoneyHelper/values/strings.dart';
import 'package:MoneyHelper/values/theme.dart';
import 'package:MoneyHelper/widgets/Indicator.dart';
import 'package:async/async.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../MyApp.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  TabController _tabController;
  ScrollController _gridScrollController;

  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final isSelected = <bool>[true, false, false, false, false];
  List<model.Account> _accounts = [];
  List<model.Category> _categories = [];
  List<model.Category> _allCategories = [];
  Map<DateTime, List<model.Transaction>> _transactions = {};
  List<model.Transaction> _transByCurPeriod = [];
  List<DateFromDB> _transactionDates = [];
  Map<DateTime, Balance> _balanceMap = {};

  int touchedPieIndex;
  int curTabIndex;

  double incomeBalance, expenseBalance, balance;

  Period selectedPeriod;

  model.Account allAccount;
  model.Account selectedAccount;
  DateInfo allDate;

  DateTime selectedDate;

  Type type = Type.Expense;
  bool isOpen = false;
  bool isInit = true;
  double padding = 43;

  var _dialogWidth = 0.0;
  var _dialogHeight = 0.0;
  var _drawerWidth = 0.0;

  double get dialogWidth => this._dialogWidth;

  double get dialogHeight => this._dialogHeight;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    allAccount = model.Account(accId: -1, name: 'All accounts', icon: 130);
    selectedAccount = allAccount;
    selectedPeriod = Period.Day;
    allDate = DateInfo(
        date: DateTime.parse('10101010'), day: 1, week: 1, month: 1, year: 1);
    _asyncInit();
    _gridScrollController = new ScrollController(
      initialScrollOffset: 0.0,
      keepScrollOffset: true,
    );
    isInit = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gridScrollController.dispose();
    super.dispose();
  }

  void _toElement(int pos) {
    double cursor;

    switch (pos) {
      case 0:
      case 1:
      case 2:
        {
          cursor = 0.0;
          break;
        }
      case 3:
      case 4:
      case 5:
        {
          cursor = 1.0 * 100;
          break;
        }
      case 6:
      case 7:
      case 8:
        {
          cursor = 2.0 * 100;
          break;
        }
      case 9:
      case 10:
      case 11:
        {
          cursor = 3.0 * 100;
          break;
        }
      case 12:
      case 13:
      case 14:
        {
          cursor = 4.0 * 100;
          break;
        }
      case 15:
      case 16:
      case 17:
        {
          cursor = 5.0 * 100;
          break;
        }
    }

    _gridScrollController.animateTo(
      cursor,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  _getDataAccount() async {
    var _accs = await DBProvider.db.getAccounts(MyApp.curUser);
    _accounts.clear();
    _accounts.add(allAccount);
    _accounts.addAll(_accs);
  }

  _getDataCategories() async {
    var _cats =
        await DBProvider.db.getCategoriesByType(Type.Expense, MyApp.curUser);
    _categories.clear();
    _categories.addAll(_cats);

    var cats = await DBProvider.db.getCategories(MyApp.curUser);
    _allCategories.clear();
    _allCategories.addAll(cats);
  }

  _getDataTransactions() async {
    _transactionDates.clear();
    _transactions.clear();
    _balanceMap.clear();
    bool isAll = false;
    switch (selectedPeriod) {
      case Period.Day:
        {
          var _dates =
              await DBProvider.db.getUniqueTransactionDays(MyApp.curUser);
          _transactionDates.addAll(_dates);
          break;
        }
      case Period.Week:
        {
          var _weeks =
              await DBProvider.db.getUniqueTransactionWeeks(MyApp.curUser);
          _transactionDates.addAll(_weeks);
          break;
        }
      case Period.Month:
        {
          var _months =
              await DBProvider.db.getUniqueTransactionMonths(MyApp.curUser);
          _transactionDates.addAll(_months);
          break;
        }
      case Period.Year:
        {
          var _years =
              await DBProvider.db.getUniqueTransactionYears(MyApp.curUser);
          _transactionDates.addAll(_years);
          break;
        }
      case Period.All:
        {
          var _all = await DBProvider.db.getAllTransactions(MyApp.curUser);
          _transactionDates.addAll(_all);
          isAll = true;
          break;
        }
    }

    if (!isAll) {
      for (var _d in _transactionDates) {
        DateInfo _td = _d as DateInfo;
        _transactions[_td.date] = await DBProvider.db.getTransactionByParam(
            period: selectedPeriod,
            account: selectedAccount,
            date: _td.date,
            user: MyApp.curUser);
        _balanceMap[_td.date] = await DBProvider.db.getBalance(
            period: selectedPeriod,
            account: selectedAccount,
            date: _td.date,
            user: MyApp.curUser);
      }
    } else {
      for (var _d in _transactionDates) {
        DateAll _td = _d as DateAll;
        _transactions[_td.timeStart] = await DBProvider.db
            .getTransactionByParam(
                period: selectedPeriod,
                account: selectedAccount,
                date: _td.timeStart,
                user: MyApp.curUser);
        _balanceMap[_td.timeStart] = await DBProvider.db.getBalance(
            period: selectedPeriod,
            account: selectedAccount,
            date: _td.timeEnd,
            user: MyApp.curUser);
      }
    }
  }

  Future<bool> _asyncInit() async {
    // Avoid this function to be called multiple times,
    // cf. https://medium.com/saugo360/flutter-my-futurebuilder-keeps-firing-6e774830bc2
    await _memoizer.runOnce(() async {
      await _getDataCategories();
      await _getDataAccount();
      await _getDataTransactions();
    });
    return true;
  }

  Future<void> _updateUI() async {
    await _getDataAccount();
    await _getDataTransactions();
    await _getDataCategories();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build");
    return FutureBuilder<bool>(
      future: _asyncInit(),
      builder: (context, snapshot) {
        if (!snapshot.hasData && snapshot.data == false) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        _tabController =
            TabController(length: _transactionDates.length, vsync: this);
        _tabController.addListener(() {
          try {
            if (selectedPeriod != Period.All) {
              DateInfo info =
                  _transactionDates[_tabController.index] as DateInfo;
              selectedDate = info.date;
            } else {
              DateAll info = _transactionDates[_tabController.index] as DateAll;
              selectedDate = info.timeEnd;
            }
          } catch (exp) {
            print(exp.toString());
          }
        });

        if (isInit) {
          isInit = false;
          List<DateInfo> dateInfoList = [];
          for (var _d in _transactionDates) {
            dateInfoList.add(_d as DateInfo);
          }
          debugPrint(dateInfoList.length.toString());

          var date = dateInfoList.firstWhere((el) => el.date == selectedDate,
              orElse: () => null);
          if (date != null) {
            selectedDate = date.date;
          }
        }

        return Scaffold(
          key: _scaffoldKey,
          appBar: _buildAppBar(),
          body: _buildBody(),
          drawer: _buildDrawer(),
          endDrawer: _buildEndDrawer(),
          bottomNavigationBar: _buildBottomBar(),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(appName),
      centerTitle: true,
      actions: [
        Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxHeight: 60.0),
          child: Material(
            color: appTheme.scaffoldBackgroundColor,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorWeight: 1,
              indicatorColor: Colors.transparent,
              tabs: _transactionDates.map(_buildTab).toList(),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _transactionDates.map(_buildTabViews).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTab(DateFromDB dateFromDB) {
    String tabTitle = '';
    try {
      switch (selectedPeriod) {
        case Period.Day:
          {
            DateInfo info = dateFromDB as DateInfo;
            tabTitle = DateFormat.yMMMEd().format(info.date);
            break;
          }
        case Period.Week:
          {
            DateInfoWithWeek diw = dateFromDB as DateInfoWithWeek;
            StringBuffer buf = StringBuffer();
            buf.write(diw.weekStart.add(Duration(days: 1)).day.toString());
            if (diw.weekStart.month == diw.weekEnd.month) {
              buf.write('-');
              buf.write(diw.weekEnd.add(Duration(days: 1)).day.toString());
              buf.write(' ');
              buf.write(DateFormat.MMM().format(diw.date));
            } else {
              buf.write(' ');
              buf.write(DateFormat.MMM().format(diw.weekStart));
              buf.write(' - ');
              buf.write(diw.weekEnd.add(Duration(days: 1)).day.toString());
              buf.write(' ');
              buf.write(DateFormat.MMM().format(diw.weekEnd));
            }
            buf.write(', ');
            buf.write(diw.year.toString());

            tabTitle = buf.toString();
            break;
          }
        case Period.Month:
          {
            DateInfo info = dateFromDB as DateInfo;
            tabTitle = DateFormat.yMMM().format(info.date);
            break;
          }
        case Period.Year:
          {
            DateInfo info = dateFromDB as DateInfo;
            tabTitle = info.year.toString();
            break;
          }
        case Period.All:
          {
            DateAll info = dateFromDB as DateAll;
            tabTitle =
                '${DateFormat.yMMMd().format(info.timeStart)} - ${DateFormat.yMMMd().format(info.timeEnd)}';
            break;
          }
      }
    } catch (exp) {
      debugPrint(exp.toString());
    }

    return Container(
      child: Tab(
        text: tabTitle,
      ),
    );
  }

  Widget _buildTabViews(DateFromDB info) {
    DateFromDB _info = info;
    DateAll dAll;
    DateInfo dInfo;
    int count = 0;
    List<model.Transaction> _children = [];
    List<int> _catsId = [];
    List<model.Category> _cats = [];

    try {
      if (selectedPeriod == Period.All) {
        dAll = info as DateAll;

        if (_transactions[dAll.timeStart] != null) {
          _catsId = _transactions[dAll.timeStart]
              .where((t) => t.type == 2)
              .map((t) => t.category)
              .toSet()
              .toList();

          _children =
              _transactions[dAll.timeStart].where((t) => t.type == 2).toList();
        }
      } else {
        dInfo = info as DateInfo;

        if (_transactions[dInfo.date] != null) {
          /*count = _transactions[dInfo.date].length;*/
          _catsId = _transactions[dInfo.date]
              .where((t) => t.type == 2)
              .map((t) => t.category)
              .toSet()
              .toList();

          _children =
              _transactions[dInfo.date].where((t) => t.type == 2).toList();
        }
      }
    } catch (exp) {
      debugPrint(exp.toString());
    }

    if (_catsId.length != 0) {
      for (var _c in _catsId) {
        _cats.add(_categories.firstWhere((c) => c.catId == _c));
      }
      _cats.addAll(_categories.toSet().difference(_cats.toSet()).toList());
    } else {
      _cats = _categories;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(7, 7, 7, 0),
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width - 20,
                height: (MediaQuery.of(context).size.height / 3),
                margin: EdgeInsets.only(bottom: 10),
                child: Transform.scale(
                  scale: 1.2,
                  child: PieChart(
                    PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            touchedPieIndex = -1;
                            _tabController.index = curTabIndex;
                          } else {
                            touchedPieIndex =
                                pieTouchResponse.touchedSectionIndex;

                            _toElement(touchedPieIndex);
                            curTabIndex = _tabController.index;
                          }
                        });

                        debugPrint(touchedPieIndex.toString());
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                      sections: showingSections(_catsId, _children),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                    childAspectRatio: 1,
                  ),
                  controller: _gridScrollController,
                  itemBuilder: (BuildContext context, int i) {
                    if (_catsId.length > i) {
                      model.Category _cat = _cats.firstWhere(
                          (c) => c.catId == _catsId[i],
                          orElse: () => null);
                      var _curTrans = _children
                          .where((t) => t.category == _catsId[i])
                          .toList();

                      double value = _curTrans.length == 0
                          ? 0
                          : (100 * _curTrans.length) / _children.length;

                      if (_cat != null) {
                        return Indicator(
                          color: touchedPieIndex == i
                              ? Color(app_icons_color[_cat.icon])
                              : null,
                          textColor: touchedPieIndex == i
                              ? Colors.white
                              : Colors.white70,
                          iconColor: touchedPieIndex == i ? Colors.white : null,
                          category: _cat,
                          showValue: true,
                          value: value,
                          function: () {
                            _openAddEditTransactionScreen(
                                operation: TypeOperation.Add,
                                context: context,
                                type: Type.Expense,
                                cat: _cat);
                          },
                        );
                      }
                    } else {
                      return Indicator(
                        textColor: Colors.white70,
                        category: _cats[i],
                        showValue: false,
                        value: 0,
                        function: () {
                          _openAddEditTransactionScreen(
                              operation: TypeOperation.Add,
                              context: context,
                              type: Type.Expense,
                              cat: _cats[i]);
                        },
                      );
                    }
                    return null;
                  },
                  itemCount: _cats.length,
                ),
              ),
              SizedBox(
                height: 70,
              )
            ],
          ),
          _buildTransactionsList(_info),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections(
      List<int> catsId, List<model.Transaction> children) {
    if (catsId.length == 0 || children.length == 0) {
      return List.generate(1, (index) {
        return PieChartSectionData(
          color: appTheme.appBarTheme.color,
          value: 100,
          showTitle: false,
          radius: 60,
        );
      });
    }

    return List.generate(catsId.length, (i) {
      final isTouched = i == touchedPieIndex;
      final double fontSize = isTouched ? 25 : 16;
      final double radius = isTouched ? 70 : 60;

      model.Category _cat = _categories.firstWhere((c) => c.catId == catsId[i],
          orElse: () => null);
      var _curTrans = children.where((t) => t.category == catsId[i]).toList();

      double value = _curTrans.length == 0
          ? 0
          : (100 * _curTrans.length) / children.length;
      debugPrint(value.toString());

      if (_cat != null) {
        String name = _cat.name;

        if (name.length >= 8 && name.length <= 16) {
          name = name.substring(0, 8) + '...';
        }

        return PieChartSectionData(
          color: Color(app_icons_color[_cat.icon]),
          value: value,
          title: name,
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),
          ),
        );
      } else {
        return null;
      }
    });
  }

  Widget _buildTransactionsList(DateFromDB info) {
    DateAll dAll;
    DateInfo dInfo;
    Balance _balance = Balance(balance: 0, expenseBalance: 0, incomeBalance: 0);
    Color balanceTextColor;
    List<model.Transaction> _trans;
    try {
      if (selectedPeriod == Period.All) {
        dAll = info as DateAll;
        if (_balanceMap[dAll.timeStart] != null) {
          _balance = _balanceMap[dAll.timeStart];
        }

        if (_transactions[dAll.timeStart] != null) {
          _trans = _transactions[dAll.timeStart];
        }
      } else {
        dInfo = info as DateInfo;
        if (_balanceMap[dInfo.date] != null) {
          _balance = _balanceMap[dInfo.date];
        }

        if (_transactions[dInfo.date] != null) {
          _trans = _transactions[dInfo.date];
        }
      }

      if (_balance.balance >= 0) {
        balanceTextColor = Color(0xFF81C784);
      } else {
        balanceTextColor = Color(0xFFFF8A80);
      }
    } catch (exp) {
      debugPrint(exp.toString());
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.1,
      minChildSize: 0.1,
      maxChildSize: 1,
      expand: true,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: appTheme.scaffoldBackgroundColor,
          ),
          child: Stack(
            children: <Widget>[
              Container(
                height: 65,
                padding: EdgeInsets.symmetric(horizontal: 20),
                margin: EdgeInsets.only(bottom: 5),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 3),
                  decoration: BoxDecoration(
                    border: Border.all(
                        style: BorderStyle.solid,
                        width: 3,
                        color: appTheme.accentColor),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          app_icon[selectedAccount.icon],
                          width: 36,
                          height: 36,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(
                          _balance.balance.toString() + ' BYN',
                          style:
                              TextStyle(fontSize: 24, color: balanceTextColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListView.builder(
                padding: EdgeInsets.only(top: 70),
                controller: scrollController,
                itemCount: _trans != null ? _trans.length : 20,
                itemBuilder: (BuildContext context, int index) {
                  if (_trans != null) {
                    var cat = _allCategories.firstWhere(
                        (c) => c.catId == _trans[index].category,
                        orElse: () => null);

                    return cat != null
                        ? Material(
                            child: InkWell(
                              onTap: () {
                                _openAddEditTransactionScreen(
                                    operation: TypeOperation.Edit,
                                    context: context,
                                    trans: _trans[index]);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 7),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      app_icon[cat.icon],
                                      height: 52,
                                      width: 52,
                                    ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    Container(
                                      constraints: BoxConstraints(
                                          minWidth: 60, maxWidth: 100),
                                      child: Text(
                                        cat.name,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Colors.white70),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    Container(
                                      child: Text(
                                        DateFormat.yMMMEd().format(
                                            DateTime.parse(_trans[index].date)),
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    Expanded(
                                      child: Container(
                                        child: Text(
                                          num.parse(_trans[index]
                                                  .value
                                                  .toStringAsFixed(2))
                                              .toString(),
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: _trans[index].type == 1
                                                ? Color(0xFF81C784)
                                                : Color(0xFFFF8A80),
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        'BYN',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.white70),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Container();
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    _drawerWidth = MediaQuery.of(context).size.width / 2;
    return Container(
      width: _drawerWidth,
      height: MediaQuery.of(context).size.height,
      color: appTheme.primaryColor,
      child: Column(
        children: <Widget>[
          Container(
            child: Center(
              child: Text(
                drawerHeaderText.toUpperCase(),
                style: TextStyle(
                    fontSize: 22.0,
                    color: appTheme.accentColor,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.0),
              ),
            ),
            color: appTheme.appBarTheme.color,
            height: AppBar().preferredSize.height,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          ),
          Expanded(
            flex: 1,
            child: _buildContentDrawer(),
          )
        ],
      ),
    );
  }

  Widget _buildContentDrawer() {
    return Container(
      child: ListView(
        children: <Widget>[
          _buildContentItemDrawer(
              title: selectedAccount.name,
              function: () {
                _showAccountDialog(context);
              },
              isBtn: false,
              icon: selectedAccount.icon),
          _buildContentItemDrawer(
              title: btnDay,
              function: () async {
                setState(() {
                  selectedPeriod = Period.Day;
                  selectItem(0);
                });
                _updateUI();
              },
              btnId: 0),
          _buildContentItemDrawer(
              title: btnWeek,
              function: () async {
                setState(() {
                  selectedPeriod = Period.Week;
                  selectItem(1);
                });
                _updateUI();
              },
              btnId: 1),
          _buildContentItemDrawer(
              title: btnMonth,
              function: () {
                setState(() {
                  selectedPeriod = Period.Month;
                  selectItem(2);
                });
                _updateUI();
              },
              btnId: 2),
          _buildContentItemDrawer(
              title: btnYear,
              function: () {
                setState(() {
                  selectedPeriod = Period.Year;
                  selectItem(3);
                });
                _updateUI();
              },
              btnId: 3),
          _buildContentItemDrawer(
              title: btnAll,
              function: () {
                setState(() {
                  selectedPeriod = Period.All;
                  selectItem(4);
                });
                _updateUI();
              },
              btnId: 4),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 15),
    );
  }

  Widget _buildContentItemDrawer(
      {String title,
      Function function,
      bool isBtn = true,
      int btnId,
      int icon}) {
    Widget child;

    if (icon == null) {
      child = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            function();
          },
          child: Container(
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isBtn
                  ? isSelected[btnId] ? appTheme.accentColor : null
                  : null,
              border: Border.all(
                  style: BorderStyle.solid,
                  width: 3,
                  color: appTheme.accentColor),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      );
    } else {
      child = OutlineButton.icon(
        icon: Image.asset(
          app_icon[icon],
          color: Colors.white,
          height: 26,
          width: 26,
        ),
        label: Container(
          constraints: BoxConstraints(maxWidth: 120),
          child: Text(
            title,
            style: TextStyle(fontSize: 18),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onPressed: () {
          function();
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        borderSide: BorderSide(
            style: BorderStyle.solid, width: 3, color: appTheme.accentColor),
        padding: EdgeInsets.only(top: 15, bottom: 15),
        highlightedBorderColor: appTheme.accentColor,
      );
    }

    return Container(
      child: child,
      constraints: BoxConstraints(minHeight: 55),
      margin: EdgeInsets.symmetric(vertical: 15),
    );
  }

  void selectItem(int index) {
    for (int i = 0; i < isSelected.length; i++) {
      isSelected[i] = i == index ? true : false;
    }
  }

  void _showAccountDialog(BuildContext context) {
    _dialogWidth = MediaQuery.of(context).size.width - 150;
    _dialogHeight = MediaQuery.of(context).size.height / 2 - 100;
    Dialog accDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        height: dialogHeight,
        width: dialogWidth,
        child: Column(
          children: <Widget>[
            Container(
              child: Center(
                child: Text(
                  'Select account',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
              padding: EdgeInsets.only(top: 10, bottom: 5),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white70,
                    width: 2,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                  child: ListView(
                    children: _accounts.map(_itemAccountDialog).toList(),
                  ),
                  padding:
                      EdgeInsets.only(top: 7, bottom: 10, right: 5, left: 5)),
            )
          ],
        ),
      ),
    );

    _showDialog<model.Account>(context: context, child: accDialog);
  }

  Widget _itemAccountDialog(model.Account account) {
    debugPrint(account.toString());
    return Container(
      child: InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop(account);
          },
          child: Tooltip(
            message: account.balance.toString(),
            textStyle: TextStyle(fontSize: 16, color: Colors.white70),
            decoration: BoxDecoration(
                color: appTheme.appBarTheme.color,
                borderRadius: BorderRadius.circular(5)),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Image.asset(
                    app_icon[account.icon],
                    width: 42,
                    height: 42,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          child: Text(
                            account.name,
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.start,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        account.accId != allAccount.accId
                            ? Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      child: Text(
                                        account.balance.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white70),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    account.currency,
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white70),
                                  ),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.end,
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
      decoration: BoxDecoration(
        border: Border.all(color: appTheme.accentColor, width: 2),
        borderRadius: BorderRadius.circular(5),
      ),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 7),
    );
  }

  Future<void> _showDialog<T>({BuildContext context, Widget child}) async {
    final resValue = await showDialog<T>(
      context: context,
      builder: (context) => child,
    );

    if (resValue != null && resValue is model.Account) {
      setState(() {
        selectedAccount = resValue;
      });
      _updateUI();
    }
  }

  Widget _buildEndDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width / 2,
      height: MediaQuery.of(context).size.height,
      color: appTheme.primaryColor,
      child: Column(
        children: <Widget>[
          Container(
            color: appTheme.appBarTheme.color,
            height: AppBar().preferredSize.height,
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          ),
          Expanded(
            flex: 1,
            child: _buildListViewEndDrawer(),
          )
        ],
      ),
    );
  }

  Widget _buildListViewEndDrawer() {
    return Container(
      child: ListView(
        children: <Widget>[
          _itemEndDrawer(btnCategory, Icons.widgets, MyApp.routeCategories),
          _itemEndDrawer(
              btnAccounts, Icons.account_balance_wallet, MyApp.routeAccounts),
          _itemEndDrawer(btnSetting, Icons.settings, MyApp.routeSettings),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 15),
    );
  }

  Widget _itemEndDrawer(String text, IconData icon, String route) {
    return Container(
      child: OutlineButton(
        child: Column(
          children: <Widget>[
            Icon(icon, size: 56, color: appTheme.accentColor),
            Center(
              child: Text(
                text,
                style: TextStyle(fontSize: 22),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
          _updateUI();
          setState(() {});
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        borderSide: BorderSide(
            style: BorderStyle.solid, width: 3, color: appTheme.accentColor),
        padding: EdgeInsets.only(top: 15, bottom: 15),
        highlightedBorderColor: appTheme.accentColor,
      ),
      margin: EdgeInsets.symmetric(vertical: 15),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      child: Container(
          child: Row(
            children: <Widget>[
              _buildBottomBarButton('-'),
              _buildBottomBarButton('+'),
            ],
          ),
          decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(width: 3, color: Colors.white70)))),
    );
  }

  Widget _buildBottomBarButton(String str) {
    bool isExpense = str == '-';
    Color color;
    String text;
    IconData icon;
    if (isExpense) {
      icon = Icons.remove;
      color = Color(0xFFFF8A80);
      text = 'Add expense';
    } else {
      icon = Icons.add;
      color = Color(0xFF81C784);
      text = 'Add income';
    }

    return Expanded(
      child: Container(
        child: FlatButton.icon(
          padding: EdgeInsets.symmetric(
            vertical: 7,
          ),
          icon: Icon(
            icon,
            size: 46,
            color: color,
          ),
          label: Text(
            text,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          onPressed: () {
            curTabIndex = _tabController.index;
            _openAddEditTransactionScreen(
                operation: TypeOperation.Add,
                context: context,
                type: isExpense ? Type.Expense : Type.Income);
          },
        ),
      ),
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  _openAddEditTransactionScreen(
      {@required BuildContext context,
      @required TypeOperation operation,
      Type type,
      model.Transaction trans,
      model.Category cat}) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.pushNamed(
      context,
      MyApp.routeAddEditTransaction,
      arguments: ScreensArguments(
          transaction: trans, type: type, operation: operation, category: cat),
    );
    _updateUI();

    if (result != null && result is ScreensArguments) {
      _tabController.index = curTabIndex;
      if (result.operation == TypeOperation.Remove) {
        _scaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(
              _buildSnackBar(TypeOperation.Remove, result.transaction));
      }
      if (result.operation == TypeOperation.Edit) {
        _scaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(
              TypeOperation.Edit, result.transaction, result.transaction_1));
      }

      if (result.operation == TypeOperation.Add) {
        _scaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(TypeOperation.Add, result.transaction));
      }
    }
  }

  SnackBar _buildSnackBar(TypeOperation operation, model.Transaction trans,
      [model.Transaction trans_1]) {
    String title;
    SnackBarAction action;
    var _cat = _allCategories.firstWhere((c) => c.catId == trans.category,
        orElse: () => null);
    switch (operation) {
      case TypeOperation.Add:
        {
          title = 'Added: ';
          action = SnackBarAction(
            label: 'Edit',
            textColor: Colors.red,
            onPressed: () {
              _openAddEditTransactionScreen(
                  context: context,
                  operation: TypeOperation.Edit,
                  type: trans.type == 1 ? Type.Income : Type.Expense,
                  trans: trans);
            },
          );
          break;
        }
      case TypeOperation.Edit:
        {
          title = 'Changed: ';
          action = SnackBarAction(
            label: 'Cancel',
            textColor: Colors.red,
            onPressed: () {
              DBProvider.db.updateTransaction(trans_1);
              _updateUI();
            },
          );
          break;
        }
      case TypeOperation.Remove:
        {
          title = 'Removed: ';
          action = SnackBarAction(
            label: 'Cancel',
            textColor: Colors.red,
            onPressed: () {
              DBProvider.db.addTransaction(trans);
              _updateUI();
            },
          );
          break;
        }
      default:
        {
          action = null;
          break;
        }
    }

    return SnackBar(
      content: Row(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          Image.asset(
            app_icon[_cat.icon],
            height: 22,
            width: 22,
          ),
          SizedBox(
            width: 5,
          ),
          Container(
            child: Text(
              DateFormat.yMMMEd().format(DateTime.parse(trans.date)),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          SizedBox(
            width: 3,
          ),
          Container(
            child: Text(
              num.parse(trans.value.toStringAsFixed(2)).toString(),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                color: trans.type == 1 ? Color(0xFF81C784) : Color(0xFFFF8A80),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Container(
            child: Text(
              'BYN',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
      action: action,
      duration: Duration(seconds: 5),
      backgroundColor: appTheme.appBarTheme.color,
    );
  }
}

class Balance {
  double incomeBalance;
  double expenseBalance;
  double balance;

  Balance({this.balance, this.incomeBalance, this.expenseBalance});

  @override
  String toString() {
    return 'Balance(balance: $balance, income: $incomeBalance, expense: $expenseBalance)';
  }
}

class Entry {
  final model.Category category;
  final List<model.Transaction> transactions;

  Entry({this.category, this.transactions});
}
