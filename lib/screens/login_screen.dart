import 'package:MoneyHelper/MyApp.dart';
import 'package:MoneyHelper/data/DataModel.dart' as model;
import 'package:MoneyHelper/data/Database.dart';
import 'package:MoneyHelper/values/theme.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey loginScreenKey = GlobalKey();
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  SharedPreferences _prefs;

  List<model.User> users = [];

  model.User user;

  String _login, _password;
  bool showPassword = false;

  TextEditingController _loginController;
  TextEditingController _passwordController;

  bool _loginInputIsValid = true;
  bool _passwordInputIsValid = true;

  _getData() async {
    var _users = await DBProvider.db.getUsers();
    users.clear();
    users.addAll(_users);
  }

  Future<bool> _asyncInit() async {
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
    SharedPreferences.getInstance()
      ..then((prefs) {
        setState(() => this._prefs = prefs);
        _loadUserPref();
      });
    _loginController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadUserPref() {
    setState(() {
      MyApp.curUser = this._prefs.getInt(MyApp.userPrefKey) ?? -1;
    });
  }

  Future<Null> _setUserPref(int val) async {
    await this._prefs.setInt(MyApp.userPrefKey, val);
    _loadUserPref();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _asyncInit(),
      builder: (context, snapshot) {
        return Scaffold(
          key: loginScreenKey,
          resizeToAvoidBottomPadding: false,
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: _buildFAB(),
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
        title: Text('Login'),
        centerTitle: true,
        automaticallyImplyLeading: false);
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
                _buildLoginTextField(),
                SizedBox(height: 10),
                _buildPasswordTextField(),
                SizedBox(height: 10),
                Container(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    child: Text(
                      'No account?',
                      style: TextStyle(fontSize: 22),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        MyApp.routeRegistration,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 15, left: 15, right: 15),
    );
  }

  Widget _buildLoginTextField() {
    return TextField(
      controller: this._loginController,
      style: TextStyle(fontSize: 32),
      cursorColor: appTheme.accentColor,
      decoration: InputDecoration(
        counterText: '${this._loginController.text.length} symbols',
        counterStyle: TextStyle(fontSize: 16),
        labelText: 'Enter login:',
        labelStyle: TextStyle(fontSize: 24),
        hintText: 'Login',
        errorText:
            _loginInputIsValid ? null : 'The login must not exceed 15 symbols.',
        errorStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(),
      ),
      onChanged: (String val) {
        if (val.length > 15) {
          setState(() => _loginInputIsValid = false);
        } else {
          setState(() {
            _loginInputIsValid = true;
          });
        }
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextField(
      controller: this._passwordController,
      obscureText: !this.showPassword,
      style: TextStyle(fontSize: 32),
      cursorColor: appTheme.accentColor,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: Icon(
            Icons.remove_red_eye,
            color: this.showPassword ? appTheme.accentColor : Colors.grey,
          ),
          onPressed: () {
            setState(() {
              this.showPassword = !this.showPassword;
            });
          },
        ),
        counterText: '${this._passwordController.text.length} symbols',
        counterStyle: TextStyle(fontSize: 16),
        labelText: 'Enter Password:',
        labelStyle: TextStyle(fontSize: 24),
        errorText: _passwordInputIsValid
            ? null
            : 'The password must not exceed 15 symbols.',
        errorStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(),
      ),
      onChanged: (String val) {
        if (val.length > 15) {
          setState(() => _passwordInputIsValid = false);
        } else {
          setState(() {
            _passwordInputIsValid = true;
          });
        }
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      icon: Icon(
        Icons.check,
        color: Colors.white,
        size: 26,
      ),
      label: Text(
        'Sign In',
        style: TextStyle(
          fontSize: 26,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        if (_isValid()) {
          try {
            this._setUserPref(user.userId);
            Navigator.pushReplacementNamed(
              context,
              MyApp.routeHome,
            );
          } catch (err) {
            debugPrint(err);
          }
        }
      },
    );
  }

  bool _isValid() {
    _login = _loginController.text;
    _password = _passwordController.text;

    if (_login.length == 0 || _password.length == 0) {
      return false;
    }
    var _usersLogin = users.where((u) => u.login == _login);
    if (_usersLogin.length == 0) {
      _showAlertDialog(context, 'Warning', 'There is no user with this login.',
          Icons.info_outline, Colors.orange);
      return false;
    } else {
      var _users =
          users.where((u) => u.login == _login && u.password == _password);
      if (_users.length == 0) {
        _showAlertDialog(context, 'Warning', 'Password is incorrect.',
            Icons.info_outline, Colors.orange);
        return false;
      } else {
        user = _users.first;
        return true;
      }
    }
  }

  _showAlertDialog(BuildContext context, String title, String content,
      [IconData iconData, Color color]) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text(
        "OK",
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
      color: Colors.red,
      onPressed: () {
        Navigator.of(context).pop(); // dismiss dialog
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
