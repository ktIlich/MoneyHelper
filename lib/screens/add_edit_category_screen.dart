import 'dart:ui';

import 'package:MoneyHelper/data/DataModel.dart' as model;
import 'package:MoneyHelper/data/Database.dart';
import 'package:MoneyHelper/values/app_icons.dart';
import 'package:MoneyHelper/values/strings.dart';
import 'package:MoneyHelper/values/theme.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';

import '../MyApp.dart';

final GlobalKey _addEditCategoryScreenKey = GlobalKey();

class AddEditCategoryScreen extends StatefulWidget {
  const AddEditCategoryScreen({Key key}) : super(key: key);

  @override
  _AddEditCatScreenState createState() => _AddEditCatScreenState();
}

class _AddEditCatScreenState extends State<AddEditCategoryScreen> {
  TextEditingController _controller;
  ScrollController _scrollController;
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  List<RadioModel> _radioModel = [];

  bool _nameInputIsValid = true;
  String _categoryName;
  Type _typeCategory;
  int _iconIndex = -1;
  model.Category editCategory;
  model.Category oldEditCategory;

  TypeOperation operation;
  bool isInit = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _radioModel.clear();
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extract the arguments from the current ModalRoute settings and cast
    // them as ScreenArguments.
    final ScreensArguments args = ModalRoute.of(context).settings.arguments;

    operation = args.operation;
    _typeCategory = args.type;
    if (operation != TypeOperation.Add && isInit) {
      editCategory = args.category;
      oldEditCategory = args.category;

      _controller.text = editCategory.name;
      _categoryName = args.category.name;
      _iconIndex = args.category.icon;

      switch (args.category.type) {
        case 1:
          {
            _typeCategory = Type.Income;
            break;
          }
        case 2:
          {
            _typeCategory = Type.Expense;
            break;
          }
      }

      _radioModel.add(RadioModel(true, editCategory.icon));
      _radioModel.addAll(List.generate(
        106,
        (id) {
          return RadioModel(false, app_icon.keys.elementAt(id));
        },
      ).where((element) => element.id != editCategory.icon));
      isInit = false;
    } else if (operation == TypeOperation.Add && isInit) {
      _radioModel.addAll(List.generate(
        106,
        (id) {
          return RadioModel(false, app_icon.keys.elementAt(id));
        },
      ));
      isInit = false;
    }

    debugPrint('add edit category screen' + _typeCategory.toString());

    // написать фукнцию для вывода тайтла в аппбар
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
    String title;

    if (operation == TypeOperation.Add) {
      if (_typeCategory == Type.Income) {
        title = addTitleCatIncome;
      } else {
        title = addTitleCatExpense;
      }
    } else {
      if (_typeCategory == Type.Income) {
        title = editTitleCatIncome;
      } else {
        title = editTitleCatExpense;
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
                      'Do you really want to delete this category?\nAll related transactions are also deleted.',
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
            child: _buildNameTextField(),
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
      controller: this._controller,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontSize: 32),
      cursorColor: appTheme.accentColor,
      decoration: InputDecoration(
        counterText: '${this._controller.text.length} symbols',
        counterStyle: TextStyle(fontSize: 16),
        labelText: 'Enter category name:',
        labelStyle: TextStyle(fontSize: 24),
        hintText: 'Name',
        errorText:
            _nameInputIsValid ? null : 'The name must not exceed 16 symbols.',
        errorStyle: TextStyle(fontSize: 16),
        border: OutlineInputBorder(),
      ),
      onSubmitted: (val) {
        _categoryName = val;
      },
      onChanged: (String val) {
        debugPrint('string - $val, string.length - ${val.length}');
        _categoryName = val;
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

  _buildBodyList() {
    /*WidgetsBinding.instance.addPostFrameCallback((_) => _onAfterBuild(context));*/
    return GridView.builder(
        key: _addEditCategoryScreenKey,
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
                    _iconIndex = index;
                  });
                },
                child: RadioItem(_radioModel[index]),
              ),
              margin: EdgeInsets.all(10));
        },
        itemCount: _radioModel.length);
  }

  _buildFAB() {
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
        if (_isValid()) {
          model.Category cat = model.Category(
            name: _categoryName,
            type: _typeCategory == Type.Income ? 1 : 2,
            user: MyApp.curUser,
          );
          debugPrint('add edit screen screen cat ' + cat.toString());
          try {
            if (operation == TypeOperation.Add) {
              cat.icon = _iconIndex + 1;
              DBProvider.db.addCategory(cat);
              Navigator.pop(
                  context,
                  ScreensArguments(
                      operation: TypeOperation.Add, category: cat));
            } else {
              cat.icon = _iconIndex;
              cat.catId = editCategory.catId;
              DBProvider.db.updateCategory(cat);
              Navigator.pop(
                  context,
                  ScreensArguments(
                      operation: TypeOperation.Edit,
                      category: cat,
                      category_1: oldEditCategory));
            }
          } catch (err) {
            debugPrint(err);
          }
        }
      },
    );
  }

  bool _isValid() {
    if (_categoryName == null ||
        _categoryName.isEmpty ||
        _controller.text.isEmpty) {
      _showAlertDialog(context, 'Warning', 'The category name cannot be empty.',
          Icons.info_outline, Colors.orange);
      return false;
    }
    if (_controller.text.length > 16) return false;
    if (_iconIndex == -1) {
      _showAlertDialog(context, 'Warning', 'Select an icon for the category.',
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
        if (operation != TypeOperation.Add) {
          DBProvider.db.removeCategory(editCategory.catId);
          Navigator.pop(
            context,
            ScreensArguments(
                operation: TypeOperation.Remove, category: editCategory),
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
        border: Border.all(
          width: 3,
          color: appTheme.accentColor,
        ),
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
