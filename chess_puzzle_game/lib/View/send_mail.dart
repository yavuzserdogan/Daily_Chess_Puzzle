import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class SendMailPage extends StatefulWidget {
  const SendMailPage({super.key});

  @override
  _SendMailPageState createState() => _SendMailPageState();
}

class _SendMailPageState extends State<SendMailPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  void _sendEmail() async {
    final String recipient = dotenv.env['RECIPIENT']!;
    final String sender  = dotenv.env['SENDER']!;
    final String subject = _subjectController.text;
    final String message = _messageController.text;


    final String apiKey = dotenv.env['API_KEY']!;
    final String domain = dotenv.env['DOMAIN']!;
    final Uri url = Uri.parse('https://api.mailgun.net/v3/$domain/messages');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('api:$apiKey'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        "from": "Excited User <$sender>",
        'to': recipient,
        'subject': subject,
        'text': message,
      },
    );

    if (subject.trim() == "" || message.trim() == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            textAlign: TextAlign.center,
            'Fill in the Message and Subject Sections',
            style: TextStyle(
              letterSpacing: 2.5,
              wordSpacing: 6.0,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          duration: const Duration(milliseconds: 2000),
          width: 290.0,
          // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            textAlign: TextAlign.center,
            'Mail Sent Successfully!',
            style: TextStyle(
              letterSpacing: 2.5,
              wordSpacing: 6.0,
              fontSize: 25.0,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          duration: const Duration(milliseconds: 2000),
          width: 290.0,
          // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13.0),
          ),
          backgroundColor: Colors.green,
        ),
      );
      _subjectController.clear();
      _messageController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Email could not be sent. Status Code: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        title: Container(
          alignment: Alignment.center,
          child: Text(
            'Feedback',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 25, top: 40, right: 23),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.message,
                  size: 110,
                  color: Colors.white,
                  shadows: [
                    BoxShadow(
                      color: Colors.blue,
                      blurRadius: 7,
                      offset: Offset(5, 5),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    labelStyle: TextStyle(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.normal,
                      letterSpacing: 2.0,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 3.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.lightBlue, width: 3.0),
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                labelStyle: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  letterSpacing: 2.0,
                  fontFamily: 'Georgia',
                  color: Colors.white,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white, width: 3.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.lightBlue, width: 3.0),
                ),
              ),
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 70),
            ElevatedButton(
              onPressed: _sendEmail,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 30.0),
                //backgroundColor: isButtonDisabled ? Colors.red : Colors.blue,
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Text(
                'Send',
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
          ],
        ),
      ),
    );
  }
}
