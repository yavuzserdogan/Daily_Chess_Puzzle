import 'package:flutter/material.dart';
import 'package:chess_puzzle_game/View/login_screen.dart';
import 'package:page_transition/page_transition.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/welcome.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Positioned(
            top: 100.0,
            left: 0,
            right: 0,
            child: Center(
              child: Text.rich(
                TextSpan(
                  text: 'Daily ',
                  style: TextStyle(
                    fontSize: 35.0,
                    fontWeight: FontWeight.w100,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'Georgia',
                    letterSpacing: 1.5,
                    wordSpacing: 3.0,
                    color: Colors.white,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Chess',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: ' Puzzle',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Positioned(
            bottom: 80.0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Metin
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 42.0),
                  child: Text(
                    'Improve your chess skills with daily puzzles!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w100,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 2.0,
                      wordSpacing: 2.0,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 120.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          opaque: true,
                          duration : const Duration(milliseconds: 400),
                          child: const LoginScreen(),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 12.0),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: const Text('Get Started',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 2.0,
                        fontFamily: 'Georgia',
                        color: Colors.white,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
