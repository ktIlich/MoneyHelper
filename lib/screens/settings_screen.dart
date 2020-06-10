import 'dart:io';

import 'package:MoneyHelper/data/DataModel.dart' as m;
import 'package:MoneyHelper/data/Database.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../MyApp.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingsScreen> {
  GlobalKey _scaffoldKey = GlobalKey();
  SharedPreferences _prefs;

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  m.User user;

  String _login;

  _getData() async {
    user = await DBProvider.db.getUser(MyApp.curUser);
  }

  Future<bool> _asyncInit() async {
    await _memoizer.runOnce(() async {
      await _getData();
    });
    return true;
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
      ..then((prefs) {
        setState(() => this._prefs = prefs);
      });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Null> _setUserPref(int val) async {
    await this._prefs.setInt(MyApp.userPrefKey, val);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _asyncInit(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          resizeToAvoidBottomPadding: false,
          appBar: _buildAppBar(),
          body: _buildBody(),
          /*floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildFAB(),*/
          bottomNavigationBar: BottomAppBar(
              child: Container(
            height: 45,
            decoration: BoxDecoration(
                border:
                    Border(top: BorderSide(width: 3, color: Colors.white70))),
          )),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text('Settings'),
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      Text(
                        'The current user is ',
                        style: TextStyle(fontSize: 28, color: Colors.white70),
                      ),
                      Text(
                        user.login,
                        style: TextStyle(fontSize: 28, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                      child: Text(
                        'Exit account',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    onTap: () {
                      _showAlertDialog(
                        context,
                        'Warning',
                        'Are you sure?',
                        () {
                          MyApp.curUser = -1;
                          _setUserPref(-1);
                          Navigator.pushNamed(
                            context,
                            MyApp.routeLogin,
                          );
                        },
                        Icons.info_outline,
                        Colors.orange,
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                        child: Text(
                          'Upload to server',
                          style: TextStyle(fontSize: 22),
                        ),
                        onPressed: () {
                          internet().then((result) {
                            if (result) {
                              _showAlertDialog(
                                context,
                                'Warning',
                                'Are you sure?\nData on the server will be overwritten.',
                                () async {
                                  await saveLocalToServer();
                                  Navigator.of(context).pop();
                                },
                                Icons.info_outline,
                                Colors.orange,
                              );
                            } else {
                              _showAlertDialog(
                                context,
                                'Error',
                                'There is no Internet connection.',
                                () {
                                  Navigator.of(context).pop();
                                },
                                Icons.info_outline,
                                Colors.red,
                              );
                            }
                          });
                        }),
                    RaisedButton(
                        child: Text(
                          'Download by server',
                          style: TextStyle(fontSize: 22),
                        ),
                        onPressed: () {
                          internet().then((result) {
                            if (result) {
                              _showAlertDialog(
                                context,
                                'Warning',
                                'are you sure?\nData on the device will be overwritten.',
                                () async {
                                  await saveServerToLocal();
                                  Navigator.of(context).pop();
                                },
                                Icons.info_outline,
                                Colors.orange,
                              );
                            } else {
                              _showAlertDialog(
                                context,
                                'Error',
                                'There is no Internet connection.',
                                () {
                                  Navigator.of(context).pop();
                                },
                                Icons.info_outline,
                                Colors.red,
                              );
                            }
                          });
                        }),
                  ],
                ),*/
              ],
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 15, left: 15, right: 15),
    );
  }

  Future<bool> internet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  saveServerToLocal() async {
    var users = await DBProvider.db.downloadUserByServer();
    var cats = await DBProvider.db.downloadCategoryByServer();
    var accs = await DBProvider.db.downloadAccountByServer();
    var trans = await DBProvider.db.downloadTransactionByServer();

    if (users.length > 0 &&
        cats.length > 0 &&
        accs.length > 0 &&
        trans.length > 0) {
      int res = await DBProvider.db.removeAllUsers();
      if (res == -1) {
        _showAlertDialog(
          context,
          'Error',
          'Error loading the database.\nWill try again later.',
          () {
            Navigator.of(context).pop();
          },
          Icons.info_outline,
          Colors.red,
        );
      } else {
        for (var u in users) {
          DBProvider.db.addUser(u);
        }

        for (var c in cats) {
          DBProvider.db.addCategory(c);
        }

        for (var a in accs) {
          DBProvider.db.addAccount(a);
        }

        for (var t in trans) {
          DBProvider.db.addTransaction(t);
        }

        _showAlertDialog(context, '', 'Data was added successfully.', () {
          Navigator.of(context).pop();
        });
      }
    }
  }

  saveLocalToServer() async {
    var users = await DBProvider.db.getUsers();
    var cats = await DBProvider.db.getCategoriesAll();
    var accs = await DBProvider.db.getAccountsAll();
    var trans = await DBProvider.db.getTransactionsAll();

    if (users.length > 0 &&
        cats.length > 0 &&
        accs.length > 0 &&
        trans.length > 0) {
      int res = await DBProvider.db.removeAllUsers();
      if (res == -1) {
        _showAlertDialog(
          context,
          'Error',
          'Error loading the database.\nWill try again later.',
          () {
            Navigator.of(context).pop();
          },
          Icons.info_outline,
          Colors.red,
        );
      } else {
        int res_1 = await DBProvider.db.uploadUsersToServer(users);
        int res_2 = await DBProvider.db.uploadAccountToServer(accs);
        int res_3 = await DBProvider.db.uploadCategoryToServer(cats);
        int res_4 = await DBProvider.db.uploadTransactionToServer(trans);
        if (res_1 == -1 || res_2 == -1 || res_3 == -1 || res_4 == -1) {
          _showAlertDialog(
            context,
            'Error',
            'Error loading data',
            () {
              Navigator.of(context).pop();
            },
            Icons.info_outline,
            Colors.red,
          );
        } else {
          _showAlertDialog(context, '', 'Data was added successfully.', () {
            Navigator.of(context).pop();
          });
        }
      }
    }
  }

  _showAlertDialog(
      BuildContext context, String title, String content, Function function,
      [IconData iconData, Color color]) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text(
        "OK",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      color: Colors.red,
      onPressed: () {
        function();
      },
    );
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: TextStyle(fontSize: 18),
      ),
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
      },
    ); // set up th// set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Row(
        children: <Widget>[
          Icon(iconData, size: 32, color: color),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          )
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
      content: Text(
        content,
        style: TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
      actions: [okButton, cancelButton],
    ); // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
