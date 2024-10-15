import 'package:chess_puzzle_game/View/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sign_up_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:chess_puzzle_game/ViewModel/login_view_model.dart';
import 'package:chess_puzzle_game/Model/data_model.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late LoginViewModel _loginViewModel;

  @override
  void initState() {
    super.initState();
    _loginViewModel = LoginViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Daily Chess Puzzle',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'Georgia',
                  letterSpacing: 1.5,
                  wordSpacing: 3.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 50),
              Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('images/background.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      spreadRadius: 15,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                      blurStyle: BlurStyle.normal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _usernameController,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Username',
                  hintStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 2.0,
                    fontFamily: 'Georgia',
                    color: Colors.black,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.account_circle,
                      color: Colors.black, size: 32.0),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
                controller: _passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 2.0,
                    fontFamily: 'Georgia',
                    color: Colors.black,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon:
                      const Icon(Icons.lock, color: Colors.black, size: 32.0),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Not have an account?',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 1.0,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.leftToRight,
                            duration : const Duration(milliseconds: 300),
                            opaque: true,
                            child: const SignUpScreen(),
                          ));
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.normal,
                        letterSpacing: 1.0,
                        fontFamily: 'Georgia',
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Log in Button
              SizedBox(
                width: 160,
                child: ElevatedButton(
                  onPressed: () async {
                    final username = _usernameController.text.trim();
                    final password = _passwordController.text.trim();

                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            textAlign: TextAlign.center,
                            'Username and Password are Required!',
                            style: TextStyle(
                              fontSize: 19.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          duration: const Duration(milliseconds: 2000),
                          width: 290.0,
                          // Width of the SnackBar.
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    //Loading animation
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          backgroundColor: Colors.transparent,
                          child: LoadingAnimationWidget.inkDrop(
                            color: Colors.white,
                            size: 70,
                          ),
                        );
                      },
                    );

                    String? result = await _loginViewModel.logIn(username, password);

                    await Future.delayed(const Duration(milliseconds: 2000));
                    Navigator.pop(context);

                    if (result == null) {
                      Provider.of<DataModel>(context, listen: false)
                          .setUsername(username);
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.fade,
                          opaque: true,
                          duration : const Duration(milliseconds: 400),
                          //child: MenuPage(),
                          child: const MenuPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            textAlign: TextAlign.center,
                            result,
                            style: const TextStyle(
                              fontSize: 19.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          duration: const Duration(milliseconds: 2000),
                          width: 290.0,
                          // Width of the SnackBar.
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13.0),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 10.0),
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 2.0,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
