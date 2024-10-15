import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar.dart';
import 'package:rolling_bottom_bar/rolling_bottom_bar_item.dart';
import 'chess_board.dart';
import 'chess_pieces_info.dart';
import 'leaderboard_screen.dart';
import 'send_mail.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        automaticallyImplyLeading: false,
      ),
      body: PageView(
        controller: _controller,
        children: <Widget>[
          Container(
            color: const Color(0xFF040D12),
            child: const ChessBoard(),
          ),
          Container(
            //color: const Color(0xFF6A9C89),
            color: Colors.grey[900],
            child: const ChessPiecesInfoPage(),
          ),
          Container(
            //color: const Color(0xFF821131),
            color: Colors.grey[900],
            child: const LeaderboardScreen(),
          ),
          Container(
            color: Colors.grey[900],
            child: const SendMailPage(),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: RollingBottomBar(
        controller: _controller,
        flat: true,
        useActiveColorByDefault: false,
        items: const [
          RollingBottomBarItem(
            FontAwesomeIcons.puzzlePiece,
            label: 'Puzzles',
            activeColor: Colors.black,
          ),
          RollingBottomBarItem(
            Icons.info,
            label: 'Pieces',
            activeColor: Colors.black,
          ),
          RollingBottomBarItem(
            FontAwesomeIcons.rankingStar,
            label: 'Ranking',
            activeColor: Colors.black,
          ),
          RollingBottomBarItem(
            Icons.email,
            label: 'Contact',
            activeColor: Colors.black,
          ),
        ],
        enableIconRotation: true,
        onTap: (index) {
          _controller.animateToPage(
            index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }
}
