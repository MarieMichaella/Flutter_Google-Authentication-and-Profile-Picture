import 'package:flutter/material.dart';
import 'package:navigations/buttons.dart';
import 'package:provider/provider.dart'; // Import the Provider package
import 'homescreen.dart';
import 'Aboutscreen.dart';
import 'themeprovider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'api/google_signin_api.dart';
import 'NewScreen.dart';

class CalculatorScreen extends StatefulWidget {
      final GoogleSignInAccount user;
  CalculatorScreen({
    Key? key,
    required this.user,
  }):super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String number1 = "";
  String operand = "";
  String number2 = "";

  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        ThemeData theme = themeProvider.themeData;
        bool isDarkTheme = theme.brightness == Brightness.dark;

        final screenSize = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: isDarkTheme ? Colors.black : Colors.white,
          appBar: AppBar(
            title: Text('Calculator'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    reverse: true,
                    child: Container(
                      alignment: Alignment.bottomRight,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        "$number1$operand$number2".isEmpty
                            ? "0"
                            : "$number1$operand$number2",
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: isDarkTheme ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ),
                ),

                // Buttons
                Wrap(
                  children: Btn.buttonValues
                      .map(
                        (value) => SizedBox(
                          width: value == Btn.n0
                              ? screenSize.width / 4
                              : (screenSize.width / 4),
                          height: screenSize.width / 5,
                          child: buildButton(value, isDarkTheme),
                        ),
                      )
                      .toList(),
                )
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: BottomNavigationBar(
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      child: Icon(Icons.home),
                      backgroundColor: Color(0xFF5271FF),
                    ),
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      child: Icon(Icons.calculate),
                      backgroundColor: Color(0xFF5271FF),
                    ),
                  ),
                  label: 'Calculator',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      child: Icon(Icons.info),
                      backgroundColor: Color(0xFF5271FF),
                    ),
                  ),
                  label: 'About',
                ),
              ],
              selectedItemColor: Color(0xFF5271FF),
              currentIndex: _selectedIndex,
              onTap: (int index) {
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(user :widget.user)),
                  );
                } else if (index == 2) {
                                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUs(user :widget.user)),
                  );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => AboutScreen(user : widget.user)),
              // );
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget buildButton(value, bool isDarkTheme) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => onBtnTap(value),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: (isNumber(value) || [Btn.calculate].contains(value))
                    ? isDarkTheme ? Colors.white : Colors.black 
                    : Colors.green,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  bool isNumber(String value) {
    return RegExp(r'^[0-9.]+$').hasMatch(value);
  }

  void onBtnTap(String value) {
    if (value == Btn.del) {
      delete();
      return;
    }

    if (value == Btn.clr) {
      clearAll();
      return;
    }

    if (value == Btn.per) {
      convertToPercentage();
      return;
    }

    if (value == Btn.calculate) {
      calculate();
      return;
    }

    if (value == Btn.negate) {
      applyNegation();
      return;
    }

    appendValue(value);
  }

  void calculate() {
    if (number1.isEmpty) return;
    if (operand.isEmpty) return;
    if (number2.isEmpty) return;

    final double num1 = double.parse(number1);
    final double num2 = double.parse(number2);

    var result = 0.0;
    switch (operand) {
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        result = num1 / num2;
        break;
      default:
    }

    setState(() {
      number1 = result.toStringAsPrecision(3);

      if (number1.endsWith(".0")) {
        number1 = number1.substring(0, number1.length - 2);
      }

      operand = "";
      number2 = "";
    });
  }

  void convertToPercentage() {
    if (number1.isNotEmpty && operand.isNotEmpty && number2.isNotEmpty) {
      calculate();
    }

    if (operand.isNotEmpty) {
      return;
    }

    final number = double.parse(number1);
    setState(() {
      number1 = "${(number / 100)}";
      operand = "";
      number2 = "";
    });
  }

  void clearAll() {
    setState(() {
      number1 = "";
      operand = "";
      number2 = "";
    });
  }

  void delete() {
    if (number2.isNotEmpty) {
      number2 = number2.substring(0, number2.length - 1);
    } else if (operand.isNotEmpty) {
      operand = "";
    } else if (number1.isNotEmpty) {
      number1 = number1.substring(0, number1.length - 1);
    }

    setState(() {});
  }

  void appendValue(String value) {
    if (value != Btn.dot && int.tryParse(value) == null) {
      if (operand.isNotEmpty && number2.isNotEmpty) {
        calculate();
      }
      operand = value;
    } else if (number1.isEmpty || operand.isEmpty) {
      if (value == Btn.dot && number1.contains(Btn.dot)) return;
      if (value == Btn.dot && (number1.isEmpty || number1 == Btn.n0)) {
        value = "0.";
      }
      number1 += value;
    } else if (number2.isEmpty || operand.isNotEmpty) {
      if (value == Btn.dot && number2.contains(Btn.dot)) return;
      if (value == Btn.dot && (number2.isEmpty || number2 == Btn.n0)) {
        value = "0.";
      }
      number2 += value;
    }

    setState(() {});
  }

  void applyNegation() {
    if (operand.isEmpty) {
      if (number1.startsWith("-")) {
        number1 = number1.substring(1);
      } else {
        number1 = "-$number1";
      }
    } else {
      if (number2.startsWith("-")) {
        number2 = number2.substring(1);
      } else {
        number2 = "-$number2";
      }
    }

    setState(() {});
  }

  Color getBtnColor(value) {
    return [Btn.del, Btn.clr].contains(value)
        ? Colors.blueGrey
        : [
            Btn.per,
            Btn.multiply,
            Btn.add,
            Btn.subtract,
            Btn.divide,
          ].contains(value)
            ? Colors.grey.withOpacity(0.3)
            : [Btn.calculate].contains(value)
                ? Colors.green
                : Colors.grey.withOpacity(0.3);
  }
}
