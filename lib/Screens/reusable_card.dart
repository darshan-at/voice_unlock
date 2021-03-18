import 'package:flutter/material.dart';

class Reusablecard extends StatelessWidget {
  final Color colour;
  final Widget chidCard;
  final Function onPress;
  Reusablecard({@required this.colour, this.chidCard, this.onPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        child: chidCard,
        margin: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
