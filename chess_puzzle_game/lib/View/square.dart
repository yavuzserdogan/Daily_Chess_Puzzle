import 'package:flutter/material.dart';
import 'package:chess_puzzle_game/View/pieces.dart';

var foregroundColor = Colors.grey.shade600;
var backgroundColor = Colors.grey.shade100;

class Square extends StatelessWidget {
  final void Function()? onTap;
  final bool isValidMove;
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;

  const Square(
      {super.key,
      required this.onTap,
      required this.isValidMove,
      required this.isWhite,
      required this.piece,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.green;
    }
    else {
      squareColor = isWhite ? backgroundColor : foregroundColor;
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: squareColor,
          borderRadius: BorderRadius.circular(3),
        ),
        child: piece != null
            ? Image.asset(
                piece!.imagePath,
                color: piece!.isWhite ? null : Colors.black,
              )
            : null,
      ),
    );
  }
}
