import 'package:MoneyHelper/data/DataModel.dart' as model;
import 'package:MoneyHelper/data/Database.dart';
import 'package:MoneyHelper/values/app_icons.dart';
import 'package:MoneyHelper/values/strings.dart';
import 'package:MoneyHelper/values/theme.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../MyApp.dart';

final GlobalKey<ScaffoldState> _globalKey = new GlobalKey();

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  final _expenseCode = 2;
  final _incomeCode = 1;

  TypeOperation _operation;
  TabController _tabController;

  final _tabs = <Tab>[
    Tab(
        icon: SvgPicture.asset(
          assetIconExpense,
          width: 40,
          height: 40,
        ),
        text: tabExpense),
    Tab(
        icon: SvgPicture.asset(assetIconIncome, width: 40, height: 40),
        text: tabIncome)
  ];

  List<model.Category> _categories = [];

  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: _tabs.length);
    _tabController.addListener(() {
      _activeTabIndex = _tabController.index;
      debugPrint(_activeTabIndex.toString());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initDb() async {
    DBProvider.db.initDB();
  }

  _getData() async {
    final __cats = await DBProvider.db.getCategories(MyApp.curUser);
    _categories.clear();
    _categories.addAll(__cats);
  }

  Future<bool> _asyncInit() async {
    // Avoid this function to be called multiple times,
    // cf. https://medium.com/saugo360/flutter-my-futurebuilder-keeps-firing-6e774830bc2
    await _memoizer.runOnce(() async {
      await _getData();
    });
    return true;
  }

  Future<void> _updateUI() async {
    await _getData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _asyncInit(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == false) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return _buildTabs();
      },
    );
  }

  Widget _buildTabs() {
    return Scaffold(
      key: _globalKey,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 45,
          decoration: BoxDecoration(
              border: Border(top: BorderSide(width: 3, color: Colors.white70))),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        categoriesScreenTitle,
      ),
      centerTitle: true,
      bottom: TabBar(
        controller: _tabController,
        tabs: _tabs,
      ),
    );
  }

  Widget _buildBody() {
    return Container(
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildTabView(_expenseCode),
          _buildTabView(_incomeCode),
        ],
      ),
    );
  }

  _buildTabView(int code) {
    return GridView.count(
      crossAxisCount: 3,
      scrollDirection: Axis.vertical,
      children: _categories
          .where((t) => t.type == (code == _incomeCode ? 1 : 2))
          .map(_itemToListTile)
          .toList(),
    );
  }

  Widget _itemToListTile(model.Category category) {
    return Builder(builder: (BuildContext context) {
      return Container(
          child: OutlineButton(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  app_icon[category.icon],
                  width: 48,
                  height: 48,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    category.name,
                    style: TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            onPressed: () {
              _openAddEditCategoryScreen(context, TypeOperation.Edit, category);
            },
            borderSide: BorderSide(
                style: BorderStyle.solid,
                width: 3,
                color: appTheme.accentColor),
            highlightedBorderColor: appTheme.accentColor,
          ),
          margin: EdgeInsets.all(10));
    });
  }

  _buildFAB() {
    return Builder(
      builder: (context) {
        return FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 32,
            color: Colors.white,
          ),
          onPressed: () {
            _openAddEditCategoryScreen(context, TypeOperation.Add);
          },
        );
      },
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  _openAddEditCategoryScreen(BuildContext context, TypeOperation operation,
      [model.Category cat]) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    Type type;
    if (_activeTabIndex == 0) {
      type = Type.Expense;
    } else if (_activeTabIndex == 1) {
      type = Type.Income;
    }

    debugPrint('category screen ' + type.toString());

    final result = await Navigator.pushNamed(
      context,
      MyApp.routeAddEditCategory,
      arguments:
          ScreensArguments(operation: operation, type: type, category: cat),
    );
    _updateUI();

    if (result != null && result is ScreensArguments) {
      // After the Selection Screen returns a result, hide any previous snackbars
      // and show the new result.
      if (result.operation == TypeOperation.Remove) {
        _globalKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(TypeOperation.Remove, result.category));
      }

      if (result.operation == TypeOperation.Edit) {
        _globalKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(
              TypeOperation.Edit, result.category, result.category_1));
      }

      if (result.operation == TypeOperation.Add) {
        _globalKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(TypeOperation.Add, result.category));
      }
    }
  }

  SnackBar _buildSnackBar(TypeOperation operation, model.Category cat,
      [model.Category cat_1]) {
    String title;
    SnackBarAction action;
    switch (operation) {
      case TypeOperation.Add:
        {
          title = 'Added: ';
          action = SnackBarAction(
            label: 'Edit',
            textColor: Colors.red,
            onPressed: () {
              _openAddEditCategoryScreen(context, TypeOperation.Edit, cat);
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
              DBProvider.db.updateCategory(cat_1);
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
              DBProvider.db.addCategory(cat);
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
          SizedBox(width: 15),
          Image.asset(
            app_icon[cat.icon],
            height: 28,
            width: 28,
          ),
          SizedBox(width: 5),
          Text(cat.name, style: TextStyle(fontSize: 16, color: Colors.white)),
        ],
      ),
      action: action,
      duration: Duration(seconds: 5),
      backgroundColor: appTheme.appBarTheme.color,
    );
  }
}
