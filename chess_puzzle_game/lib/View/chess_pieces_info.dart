import 'package:flutter/material.dart';
import 'package:pageviewj/pageviewj.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChessPiecesInfoPage extends StatelessWidget {
  const ChessPiecesInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        title: Container(
          alignment: Alignment.center,
          child: Text(
            'Chess Pieces Info',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 38.0,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              fontFamily: 'Georgia',
              letterSpacing: 3.5,
              wordSpacing: 5.0,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: const Offset(6.0, 6.0),
                  blurRadius: 13.0,
                  color: Colors.lightBlue.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SizedBox(
          width: 370,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 750,
                  child: LayoutBuilder(builder: (context, constraints) {
                    return PageViewJ(
                      modifier: const Modifier(viewportFraction: .73),
                      transform: RotateTransform(),
                      itemBuilder: pageViewItem,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> icons = [
  const FaIcon(FontAwesomeIcons.solidChessKing, size: 200, color: Colors.black),
  const FaIcon(FontAwesomeIcons.solidChessQueen,
      size: 200, color: Colors.black),
  const FaIcon(FontAwesomeIcons.solidChessKnight,
      size: 200, color: Colors.black),
  const FaIcon(FontAwesomeIcons.solidChessRook, size: 200, color: Colors.black),
  const FaIcon(FontAwesomeIcons.solidChessBishop,
      size: 200, color: Colors.black),
  const FaIcon(FontAwesomeIcons.solidChessPawn, size: 200, color: Colors.black),
];

List<String> cardTexts = [
  "The King moves one square in any direction: horizontally, vertically, or diagonally. It has no point value because losing the King means losing the game.",
  "The Queen can move any number of squares in any direction: horizontally, vertically, or diagonally. It is worth 9 points.",
  "The knight moves in an L shape: two squares in one direction and then one square perpendicular or vice versa. It can jump over other pieces. It is worth 3 points.",
  "The Rook moves any number of squares horizontally or vertically. It is worth 5 points.",
  "The Bishop moves any number of squares diagonally. It is worth 5 points.",
  "The Pawn moves one square forward, but can move two squares forward on its first move. It captures diagonally. It is worth 1 point.",
];

Widget pageViewItem(BuildContext context, int index, {double? aniValue}) {
  return Padding(
    padding: const EdgeInsets.all(15.0),
    child: Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)),
          color: const Color(0xFFC0C0C0),
          child: SizedBox(
            height: aniValue != null ? (230 + 50 * aniValue) : 250,
            width: 250,
            child: Center(
              child: icons[index % icons.length],
            ),
          ),
        ),
        Positioned(
          top: aniValue != null ? 245 - 20 * aniValue : 245,
          left: 10,
          right: 10,
          child: Container(
            color: const Color(0xFFC0C0C0),
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Text(
              cardTexts[index % cardTexts.length],
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
                fontFamily: 'Georgia',
                letterSpacing: 2.5,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

