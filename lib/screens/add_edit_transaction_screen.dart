import 'package:MoneyHelper/MyApp.dart';
import 'package:MoneyHelper/data/DataModel.dart' as model;
import 'package:MoneyHelper/data/Database.dart';
import 'package:MoneyHelper/values/app_icons.dart';
import 'package:MoneyHelper/values/strings.dart';
import 'package:MoneyHelper/values/theme.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TransactionsType { Income, Expense, Transfer }

class AddEditTransactionScreen extends StatefulWidget {
  const AddEditTransactionScreen({Key key}) : super(key: key);

  @override
  _AddEditTransactionScreenState createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  GlobalKey _addEditTransactionScreenKey = GlobalKey();
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  TextEditingController _valueController;
  TextEditingController _valueController_2;
  TextEditingController _noteController;

  List<model.Account> _accounts = [];
  List<model.Category> _categories = [];
  List<RadioModel> _radioModel = [];

  bool _noteInputIsValid = true;
  bool _valueInputIsValid = true;
  bool _valueInputIsValid_2 = true;

  bool isInit = true;
  TypeOperation operation = TypeOperation.Add;
  Type type;

  DateTime _date;
  model.Account _account;
  model.Category _category;
  double _value;
  StringBuffer _note;
  model.Transaction editTransaction;
  model.Transaction oldEditTransaction;

  _getData() async {
    var _accs = await DBProvider.db.getAccounts(MyApp.curUser);
    List<model.Category> _cats;
    if (type != null) {
      _cats = await DBProvider.db.getCategoriesByType(type, MyApp.curUser);
    } else {
      _cats = await DBProvider.db.getCategories(MyApp.curUser);
    }

    _accounts.clear();
    _categories.clear();

    _accounts.addAll(_accs);
    _categories.addAll(_cats);

    _account = _accounts[0];
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
    _note = new StringBuffer();
    _valueController = TextEditingController();
    _valueController_2 = TextEditingController();
    _noteController = TextEditingController();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _radioModel.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ScreensArguments arguments =
        ModalRoute.of(context).settings.arguments;

    operation = arguments.operation;
    type = arguments.type;
    _category = arguments.category;
    if (operation != TypeOperation.Add && isInit) {
      switch (arguments.transaction.type) {
        case 1:
          {
            type = Type.Income;
            break;
          }
        case 2:
          {
            type = Type.Expense;
            break;
          }
        case 3:
          {
            type = Type.Transfer;
            break;
          }
      }

      editTransaction = arguments.transaction;
      oldEditTransaction = editTransaction;
      _valueController.text = editTransaction.value.toString().length > 20
          ? editTransaction.value.toString().substring(0, 20)
          : editTransaction.value.toString();

      _value = double.parse(_valueController.text);

      _noteController.text = editTransaction.note;
      debugPrint(editTransaction.date);
      _date = DateTime.parse(editTransaction.date);
    }

    return FutureBuilder<bool>(
      future: _asyncInit(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == false) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (operation != TypeOperation.Add && isInit) {
          _category = _categories.firstWhere(
              (element) => element.catId == editTransaction.category);
          _account = _accounts.firstWhere(
              (element) => element.accId == editTransaction.account);

          _radioModel.add(RadioModel(
              isSelected: true, id: _category.catId, category: _category));
          _radioModel.addAll(_categories
              .where((element) => element.catId != _category.catId)
              .map((e) =>
                  RadioModel(isSelected: false, id: e.catId, category: e)));

          isInit = false;
        } else if (operation == TypeOperation.Add && isInit) {
          if (_category != null) {
            _radioModel.add(RadioModel(
                isSelected: true, id: _category.catId, category: _category));
            _radioModel.addAll(_categories
                .where((element) => element.catId != _category.catId)
                .map((e) =>
                    RadioModel(isSelected: false, id: e.catId, category: e)));
          } else {
            _radioModel.addAll(_categories.map((e) =>
                RadioModel(isSelected: false, id: e.catId, category: e)));
          }
          isInit = false;
        }

        return Scaffold(
          key: _addEditTransactionScreenKey,
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
    String title;

    if (operation == TypeOperation.Add) {
      if (type == Type.Expense) {
        title = addTitleExpense;
      } else if (type == Type.Income) {
        title = addTitleIncome;
      } else {
        title = addTitleTransfer;
      }
    } else {
      if (type == Type.Expense) {
        title = editTitleExpense;
      } else if (type == Type.Income) {
        title = editTitleIncome;
      } else {
        title = editTitleTransfer;
      }
    }

    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: operation != TypeOperation.Add
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

  Widget _buildBody() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                _buildDateField(),
                SizedBox(height: 20),
                _buildValueTextField(),
                SizedBox(height: 10),
                _buildNoteTextField(),
                SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 25),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: InkWell(
                    child: RadioItem(_radioModel[index]),
                    onTap: () {
                      setState(() {
                        _radioModel
                            .forEach((element) => element.isSelected = false);
                        _radioModel[index].isSelected = true;

                        var cat = _radioModel[index].category;
                        debugPrint(cat.toString());
                        _category = model.Category(
                            name: cat.name,
                            type: cat.type,
                            icon: cat.icon,
                            user: cat.user);
                        debugPrint(_category.toString());
                        _category = cat;
                        debugPrint(_category.toString());
                      });
                      /*_openAddEditCategoryScreen(context, false, category);*/
                    },
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: appTheme.accentColor, width: 3),
                  ),
                );
              },
              itemCount: _radioModel.length,
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 15, left: 15, right: 15),
    );
  }

  Widget _buildDateField() {
    return Container(
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.event,
              size: 24,
            ),
            SizedBox(
              width: 7,
            ),
            Text(
              DateFormat.yMMMEd().format(_date),
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        onTap: () {
          _datePickerDialog();
        },
      ),
    );
  }

  void _datePickerDialog() {
    DateTime now = DateTime.now();
    showDatePicker(
            context: context,
            initialDate: now,
            firstDate: DateTime(2000),
            lastDate: DateTime(2050))
        .then((onValue) {
      if (onValue != null) {
        setState(() {
          _date = onValue;
        });
      }
      debugPrint(_date.toString());
    });
  }

  Widget _buildNoteTextField() {
    return TextField(
      controller: this._noteController,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontSize: 32),
      cursorColor: appTheme.accentColor,
      decoration: InputDecoration(
        counterText: '${this._noteController.text.length} symbols',
        counterStyle: TextStyle(fontSize: 16),
        labelText: 'Enter note:',
        labelStyle: TextStyle(fontSize: 24),
        hintText: 'Note',
        errorText:
            _noteInputIsValid ? null : 'The name must not exceed 100 symbols.',
        errorStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(),
      ),
      onChanged: (String val) {
        debugPrint('transactions note - $val, length - ${val.length}');
        _note.clear();
        _note.write(val);
        if (val.length > 100) {
          setState(() => _noteInputIsValid = false);
        } else {
          setState(() {
            _noteInputIsValid = true;
          });
        }
      },
    );
  }

  // пофиксить октрытие клавиатуры при нажатии на iconButton
  Widget _buildValueTextField() {
    bool readOnly = false;
    return TextField(
      controller: this._valueController,
      style: TextStyle(fontSize: 32),
      cursorColor: appTheme.accentColor,
      readOnly: readOnly,
      maxLength: 20,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        prefixIcon: IconButton(
          icon: Image.asset(
            app_icon[_account.icon],
          ),
          iconSize: 24,
          onPressed: () {
            _showAccountDialog(context);
          },
        ),
        suffixText: 'BYN',
        counterStyle: TextStyle(fontSize: 16),
        labelText: 'Enter Balance:',
        labelStyle: TextStyle(fontSize: 24),
        hintText: '0.0',
        errorText: _valueInputIsValid
            ? null
            : 'Enter a number (equal to or greater than 0).',
        errorStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(),
      ),
      onChanged: (String val) {
        var v = double.tryParse(val);
        debugPrint('trasactions value parse value - $v');
        _value = v;
        if (v == null || v < 0) {
          setState(() => _valueInputIsValid = false);
        } else {
          setState(() {
            _valueInputIsValid = true;
          });
        }
      },
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      icon: operation == TypeOperation.Add
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
        operation == TypeOperation.Add ? 'Add' : 'Edit',
        style: TextStyle(
          fontSize: 26,
          color: Colors.white,
        ),
      ),
      onPressed: () {
        var cat = _radioModel.where((c) => c.isSelected);
        var _c = cat.first.category;
        _category = _c;

        if (_isValid()) {
          model.Transaction trans = model.Transaction(
            type: type == Type.Income ? 1 : 2,
            date: _date.toLocal().toString(),
            account: _account.accId,
            value: _value,
            note: _note.toString(),
            category: _category.catId,
            user: MyApp.curUser,
          );

          if (type == Type.Income) {
            _account.balance += _value;
          } else {
            _account.balance -= _value;
          }

          try {
            if (operation == TypeOperation.Add) {
              DBProvider.db.addTransaction(trans);
              DBProvider.db.updateAccount(_account);
              Navigator.pop(
                  context,
                  ScreensArguments(
                      operation: TypeOperation.Add, transaction: trans));
            } else {
              trans.transId = editTransaction.transId;
              DBProvider.db.updateTransaction(trans);
              if (trans.value != oldEditTransaction.value) {
                if (type == Type.Income) {
                  _account.balance -= oldEditTransaction.value;
                  _account.balance += trans.value;
                } else {
                  _account.balance += oldEditTransaction.value;
                  _account.balance -= trans.value;
                }
              }
              Navigator.pop(
                  context,
                  ScreensArguments(
                      operation: TypeOperation.Edit,
                      transaction: trans,
                      transaction_1: oldEditTransaction));
            }
          } catch (err) {
            debugPrint(err);
          }
        }
      },
    );
  }

  bool _isValid() {
    if (_noteController.text.length > 100 || _note.length > 100) return false;
    if (_value == null || _valueController.text.isEmpty) {
      _showAlertDialog(context, 'Warning', 'You must enter a value/',
          Icons.info_outline, Colors.orange);
      return false;
    }
    if (_category == null) {
      _showAlertDialog(context, 'Warning', 'Select category.',
          Icons.info_outline, Colors.orange);
      return false;
    }
    return true;
  }

  void _showAccountDialog(BuildContext context) {
    var _dialogWidth = MediaQuery.of(context).size.width - 150;
    var _dialogHeight = MediaQuery.of(context).size.height / 2 - 100;
    Dialog accDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        height: _dialogHeight,
        width: _dialogWidth,
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

    /*showDialog(context: context, builder: (BuildContext context) => accDialog);*/
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
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                child: Text(
                                  account.balance.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white70),
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
                        ),
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
        _account = resValue;
      });
      debugPrint('resValue ${resValue.accId.toString()}\n'
          'selectedAccount ${_account.accId.toString()}');
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
        if (operation != TypeOperation.Add) {
          DBProvider.db.removeTransaction(editTransaction.transId);
          Navigator.pop(
            context,
            ScreensArguments(
                operation: TypeOperation.Remove, transaction: editTransaction),
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

class RadioItem extends StatelessWidget {
  final RadioModel _item;

  RadioItem(this._item);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      color: _item.isSelected ? Color(0xFF616161) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            app_icon[_item.category.icon],
            width: 48,
            height: 48,
          ),
          Container(
            margin: const EdgeInsets.only(top: 8.0),
            child: Text(
              _item.category.name,
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class RadioModel {
  int id;
  model.Category category;
  bool isSelected;

  RadioModel({this.isSelected, this.id, this.category});
}
