import 'dart:ui';

import 'package:MoneyHelper/data/DataModel.dart' as model;
import 'package:MoneyHelper/data/Database.dart';
import 'package:MoneyHelper/values/app_icons.dart';
import 'package:MoneyHelper/values/strings.dart';
import 'package:MoneyHelper/values/theme.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

import '../MyApp.dart';

final GlobalKey _addEditAccountScreenKey = GlobalKey();

class AddEditAccountScreen extends StatefulWidget {
  const AddEditAccountScreen({Key key}) : super(key: key);

  @override
  _AddEditAccScreenState createState() => _AddEditAccScreenState();
}

class _AddEditAccScreenState extends State<AddEditAccountScreen> {
  TextEditingController _nameInputController;
  TextEditingController _balanceInputController;
  ScrollController _scrollController;
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  List<RadioModel> _radioModel = [];

  bool _nameInputIsValid = true;
  bool _balanceInputIsValid = true;

  model.Account _editAccount;
  model.Account _oldEditAccount;

  String _accountName;
  double _accountBalance;
  int _accountIcon = -1;

  TypeOperation _operation;
  bool isInit = true;

  @override
  void initState() {
    super.initState();
    _balanceInputController = TextEditingController();
    _nameInputController = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _radioModel.clear();
    _scrollController.dispose();
    _balanceInputController.dispose();
    _nameInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final ScreensArguments args = ModalRoute.of(context).settings.arguments;

    _operation = args.operation;

    if (_operation != TypeOperation.Add && isInit) {
      _editAccount = args.account;
      _oldEditAccount = _editAccount;
      _accountName = args.account.name;
      _accountIcon = args.account.icon;
      _nameInputController.text = _accountName;
      _balanceInputController.text = _accountBalance.toString();

      _balanceInputController.text = _editAccount.balance.toString().length > 20
          ? _editAccount.balance.toString().substring(0, 20)
          : _editAccount.balance.toString();

      _accountBalance = double.parse(_balanceInputController.text);

      _radioModel.add(RadioModel(true, _accountIcon));
      int _index = 107;
      _radioModel.addAll(List.generate(
        24,
        (id) {
          return RadioModel(false, _index++);
        },
      ).where((element) => element.id != _accountIcon));
      isInit = false;
    } else if (_operation == TypeOperation.Add && isInit) {
      int _index = 107;
      _radioModel.addAll(List.generate(
        24,
        (id) {
          return RadioModel(false, _index++);
        },
      ));
      isInit = false;
    }

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: _buildAppBar(),
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

  _buildAppBar() {
    return AppBar(
      title: Text(
        _operation == TypeOperation.Add ? addTitleAcc : editTitleAcc,
      ),
      centerTitle: true,
      actions: _operation != TypeOperation.Add
          ? <Widget>[
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                iconSize: 32,
                onPressed: () {
                  _showAlertDialog(
                      context,
                      'Attention',
                      'Do you really want to delete this account?\nAll related transactions are also deleted.',
                      Icons.info_outline,
                      Colors.orange);
                },
              ),
            ]
          : null,
    );
  }

  _buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                _buildNameTextField(),
                SizedBox(height: 10),
                _buildBalanceTextField()
              ],
            ),
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 15, right: 15),
          ),
          Expanded(
            flex: 1,
            child: _buildBodyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNameTextField() {
    return TextField(
      controller: this._nameInputController,
      textCapitalization: TextCapitalization.none,
      style: TextStyle(fontSize: 32),
      cursorColor: appTheme.accentColor,
      decoration: InputDecoration(
        counterText: '${this._nameInputController.text.length} symbols',
        counterStyle: TextStyle(fontSize: 16),
        labelText: 'Enter account name:',
        labelStyle: TextStyle(fontSize: 24),
        hintText: 'Name',
        errorText:
            _nameInputIsValid ? null : 'The name must not exceed 16 symbols.',
        errorStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(),
      ),
      onSubmitted: (val) {
        _accountName = val;
      },
      onChanged: (String val) {
        debugPrint('string - $val, string.length - ${val.length}');
        _accountName = val;
        if (val.length > 16) {
          setState(() => _nameInputIsValid = false);
        } else {
          setState(() {
            _nameInputIsValid = true;
          });
        }
      },
    );
  }

  Widget _buildBalanceTextField() {
    return TextField(
      controller: this._balanceInputController,
      style: TextStyle(fontSize: 32),
      cursorColor: appTheme.accentColor,
      maxLength: 20,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'BYN',
                style: TextStyle(fontSize: 22),
              ),
            ],
          ),
        ),
        counterStyle: TextStyle(fontSize: 16),
        labelText: 'Enter Balance:',
        labelStyle: TextStyle(fontSize: 24),
        hintText: '0.0',
        errorText: _balanceInputIsValid
            ? null
            : 'Enter a number (equal to or greater than 0).',
        errorStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(),
      ),
      onChanged: (String val) {
        var v = double.tryParse(val);
        debugPrint('parse value - $v');
        _accountBalance = v;
        if (v == null || v < 0) {
          setState(() => _balanceInputIsValid = false);
        } else {
          setState(() {
            _balanceInputIsValid = true;
          });
        }
      },
    );
  }

  _buildBodyList() {
    return GridView.builder(
        key: _addEditAccountScreenKey,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _radioModel
                        .forEach((element) => element.isSelected = false);
                    _radioModel[index].isSelected = true;
                    _accountIcon = _radioModel[index].id;
                    debugPrint(_accountIcon.toString());
                  });
                },
                child: new RadioItem(_radioModel[index]),
              ),
              margin: EdgeInsets.all(10));
        },
        itemCount: _radioModel.length);
  }

  _buildFAB() {
    return FloatingActionButton.extended(
      icon: _operation == TypeOperation.Add
          ? Icon(
              Icons.check,
              color: Colors.white,
              size: 26,
            )
          : Icon(
              Icons.edit,
              color: Colors.white,
              size: 26,
            ),
      label: Text(
        _operation == TypeOperation.Add ? 'Add' : 'Edit',
        style: TextStyle(
          fontSize: 26,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        if (_isValid()) {
          model.Account acc = model.Account(
              name: _accountName,
              balance: _accountBalance,
              currency: 'BYN',
              icon: _accountIcon,
              user: MyApp.curUser);
          try {
            if (_operation == TypeOperation.Add) {
              DBProvider.db.addAccount(acc);
              Navigator.pop(context,
                  ScreensArguments(operation: TypeOperation.Add, account: acc));
            } else {
              acc.accId = _editAccount.accId;
              DBProvider.db.updateAccount(acc);
              Navigator.pop(
                  context,
                  ScreensArguments(
                      operation: TypeOperation.Edit,
                      account: acc,
                      account_1: _oldEditAccount));
            }
          } catch (err) {
            debugPrint(err);
          }
        }
      },
    );
  }

  bool _isValid() {
    if (_accountName == null ||
        _accountName.isEmpty ||
        _nameInputController.text.isEmpty) {
      _showAlertDialog(context, 'Warning', 'The account name cannot be empty',
          Icons.info_outline, Colors.orange);
      return false;
    }
    if (_nameInputController.text.length > 16) return false;
    if (_accountBalance == null || _balanceInputController.text.isEmpty) {
      _showAlertDialog(
          context,
          'Warning',
          'The account balance cannot be empty',
          Icons.info_outline,
          Colors.orange);
      return false;
    }
    if (_accountIcon == -1) {
      _showAlertDialog(context, 'Warning', 'Select an icon for the account',
          Icons.info_outline, Colors.orange);
      return false;
    }
    return true;
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
        if (_operation != TypeOperation.Add) {
          DBProvider.db.removeAccount(_editAccount.accId);
          Navigator.pop(
            context,
            ScreensArguments(
                operation: TypeOperation.Remove, account: _editAccount),
          );
        }
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
        textAlign: TextAlign.justify,
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

class RadioItem extends StatelessWidget {
  final RadioModel _item;

  RadioItem(this._item);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(app_icon[_item.id]),
      decoration: BoxDecoration(
        color: _item.isSelected ? Color(0xFF616161) : null,
        border: BorderDirectional(
            top: BorderSide(width: 3, color: appTheme.accentColor),
            end: BorderSide(width: 3, color: appTheme.accentColor),
            start: BorderSide(width: 3, color: appTheme.accentColor),
            bottom: BorderSide(width: 3, color: appTheme.accentColor)),
      ),
      padding: EdgeInsets.all(10),
    );
  }
}

class RadioModel {
  int id;
  bool isSelected;

  RadioModel(this.isSelected, this.id);
}
