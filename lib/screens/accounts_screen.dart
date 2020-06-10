import 'package:MoneyHelper/data/DataModel.dart' as model;
import 'package:MoneyHelper/data/Database.dart';
import 'package:MoneyHelper/values/app_icons.dart';
import 'package:MoneyHelper/values/strings.dart';
import 'package:MoneyHelper/values/theme.dart';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../MyApp.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key key}) : super(key: key);

  @override
  _AccountsScreenState createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final AsyncMemoizer _memoizer = AsyncMemoizer();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  List<model.Account> _accounts = [];

  _getData() async {
    final __acc = await DBProvider.db.getAccounts(MyApp.curUser);
    _accounts.clear();
    _accounts.addAll(__acc);
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
  void initState() {
    super.initState();
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
        return _buildContent();
      },
    );
  }

  Widget _buildContent() {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          accountsScreenTitle,
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          child: Container(
        height: 45,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(width: 3, color: Colors.white70))),
      )),
    );
  }

  Widget _buildBody() {
    return Builder(
      builder: (context) {
        return Container(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.7,
            scrollDirection: Axis.vertical,
            children: _accounts.map(_itemGridView).toList(),
          ),
        );
      },
    );
  }

  Widget _itemGridView(model.Account account) {
    return Container(
        child: OutlineButton(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: <Widget>[
              Image.asset(
                app_icon[account.icon],
                width: 56,
                height: 56,
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        account.name,
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 60,
                          child: Text(
                            account.balance.toString(),
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          margin: EdgeInsets.only(right: 7),
                        ),
                        Text(
                          account.currency,
                          style: TextStyle(fontSize: 20, color: Colors.white70),
                        ),
                      ],
                      crossAxisAlignment: CrossAxisAlignment.end,
                    ),
                  ],
                ),
              ),
            ],
          ),
          onPressed: () {
            _openAddEditAccountScreen(
                operation: TypeOperation.Edit, context: context, acc: account);
          },
          borderSide: BorderSide(
              style: BorderStyle.solid, width: 3, color: appTheme.accentColor),
          highlightedBorderColor: appTheme.accentColor,
        ),
        margin: EdgeInsets.all(10));
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
            _openAddEditAccountScreen(
                context: context, operation: TypeOperation.Add);
          },
        );
      },
    );
  }

  Widget _buildSnackBar(TypeOperation operation, model.Account acc,
      [model.Account acc_1]) {
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
              _openAddEditAccountScreen(
                  context: context, operation: TypeOperation.Edit, acc: acc);
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
              DBProvider.db.updateAccount(acc_1);
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
              DBProvider.db.addAccount(acc);
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
          Expanded(
            child: Row(
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(width: 7),
                Image.asset(
                  app_icon[acc.icon],
                  height: 28,
                  width: 28,
                ),
                SizedBox(width: 5),
                Container(
                  width: 100,
                  child: Text(
                    acc.name,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  width: 50,
                  child: Text(acc.balance.toString(),
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      overflow: TextOverflow.ellipsis),
                ),
                Text(acc.currency,
                    style: TextStyle(fontSize: 16, color: Colors.white70))
              ],
            ),
          )
        ],
      ),
      action: action,
      duration: Duration(seconds: 5),
      backgroundColor: appTheme.appBarTheme.color,
    );
  }

  // A method that launches the SelectionScreen and awaits the result from
  // Navigator.pop.
  _openAddEditAccountScreen(
      {@required BuildContext context,
      @required TypeOperation operation,
      model.Account acc}) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.pushNamed(
      context,
      MyApp.routAddEditAccount,
      arguments: ScreensArguments(operation: operation, account: acc),
    );
    _updateUI();

    if (result != null && result is ScreensArguments) {
      if (result.operation == TypeOperation.Remove) {
        _scaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(TypeOperation.Remove, result.account));
      }
      if (result.operation == TypeOperation.Edit) {
        _scaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(
              TypeOperation.Edit, result.account, result.account_1));
      }

      if (result.operation == TypeOperation.Add) {
        _scaffoldKey.currentState
          ..removeCurrentSnackBar()
          ..showSnackBar(_buildSnackBar(TypeOperation.Add, result.account));
      }
    }
  }
}
