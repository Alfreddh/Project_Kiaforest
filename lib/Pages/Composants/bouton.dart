import 'package:flutter/material.dart';
import 'package:projectkiaforest/constants.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function press;
  final Color color, textcolor;

  const RoundedButton({
    Key? key,
    required this.text, required this.press, this.color = KprimaryColor, this.textcolor = Colors
        .white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
      width: size.width * 0.8,
      height: size.height * 0.08,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color(0xCC458535)),

          ),
          onPressed: () {
            press();
          },
          child: Text(text, style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Poppins'),),

        ),
      ),
    );
  }
}