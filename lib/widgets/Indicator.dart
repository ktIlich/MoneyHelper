import 'package:MoneyHelper/data/DataModel.dart';
import 'package:MoneyHelper/values/app_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final Color textColor;
  final Color iconColor;
  final Category category;
  final double value;
  final bool showValue;
  final Function function;

  const Indicator(
      {Key key,
      this.color,
      this.textColor = Colors.white70,
      this.iconColor,
      this.value,
      this.showValue,
      this.category,
      this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          borderRadius: BorderRadius.circular(5),
          color: color,
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              function();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  app_icon[category.icon],
                  width: 48,
                  height: 48,
                  color: iconColor,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 22,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                showValue
                    ? Text(
                        value == 100
                            ? value.toString().substring(0, 3) + '%'
                            : value.toString().substring(0, 4) + '%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
        margin: EdgeInsets.all(10));

    /*Container(
      color: color,
      child: Column(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
              color: color,
              borderRadius: isSquare ? BorderRadius.circular(5) : null,
            ),
            child: Image.asset(
              app_icon[category.Icon],
              fit: BoxFit.cover,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            width: 4,
          ),
          Column(
            children: <Widget>[
              Expanded(
                child: Text(
                  category.Name,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              showValue
                  ? Text(
                      value.toString().substring(0, 3) + '%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    )
                  : Container(),
            ],
          )
        ],
      ),
    );*/
  }
}

/*import 'package:MoneyHelper/data/DataModel.dart';
import 'package:MoneyHelper/values/app_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final Color textColor;
  final Color iconColor;
  final Category category;
  final double value;
  final bool showValue;
  final Function function;

  const Indicator(
      {Key key,
      this.color,
      this.textColor = Colors.white70,
      this.iconColor,
      this.value,
      this.showValue,
      this.category,
      this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Material(
          borderRadius: BorderRadius.circular(5),
          color: color,
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: () {
              function();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  app_icon[category.icon],
                  width: 48,
                  height: 48,
                  color: iconColor,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 22,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                showValue
                    ? Text(
                        value == 100
                            ? value.toString().substring(0, 3) + '%'
                            : value.toString().substring(0, 4) + '%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
        margin: EdgeInsets.all(10));
  }
}
*/
