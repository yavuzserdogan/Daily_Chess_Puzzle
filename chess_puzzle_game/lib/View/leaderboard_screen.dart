import 'package:flutter/material.dart';
import 'package:chess_puzzle_game/Model/user.dart';
import 'package:chess_puzzle_game/Model/puzzle_repository.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardState();
}

class _LeaderboardState extends State<LeaderboardScreen> {
  final User _usersInfo = User();
  List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;
  String currentDate = "";
  late PuzzleRepository _puzzleRepository;
  late String date;


  @override
  void initState() {
    super.initState();
    _puzzleRepository = PuzzleRepository();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      date = await _puzzleRepository.getFenAndPgn().then((data) => data['url']!);
      currentDate = _extractDateFromUrl(date);
      leaderboardData = await _usersInfo.getUsersByDate(currentDate);
      leaderboardData.sort((a, b) => (a['time'] as int).compareTo(b['time'] as int));
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _extractDateFromUrl(String url) {
    RegExp dateRegex = RegExp(r'(\d{4})-(\d{2})-(\d{2})$');
    Match? match = dateRegex.firstMatch(url);
    return match != null
        ? "${match.group(3)}-${match.group(2)}-${match.group(1)}"
        : "Invalid URL";
  }

  Future<void> fetchAndSetUsers() async {
    List<Map<String, dynamic>> users =
        await _usersInfo.getUsersByDate(currentDate);
    if (mounted) {
      setState(() {
        leaderboardData = users;
        users.sort((a, b) => (a['time'] as int).compareTo(b['time'] as int));
        isLoading = false;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey[900],
        title: Container(
          alignment: Alignment.center,
          child: Text(
            'Leaderboard',
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      const Center(
                        child: FaIcon(
                          FontAwesomeIcons.medal,
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
                      ),
                      const SizedBox(height: 120),
                      Table(
                        border: TableBorder.all(color: Colors.black, width: 3),
                        columnWidths: const {
                          0: FixedColumnWidth(90),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(90),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(color: Colors.teal),
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Rank',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    letterSpacing: 2.0,
                                    fontFamily: 'Georgia',
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Username',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    letterSpacing: 2.0,
                                    fontFamily: 'Georgia',
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Score',
                                  style: TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FontStyle.normal,
                                    letterSpacing: 2.0,
                                    fontFamily: 'Georgia',
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          for (int i = 0; i < leaderboardData.length; i++)
                            TableRow(
                              decoration: BoxDecoration(
                                color: i % 2 == 0
                                    ? Colors.lightBlueAccent.shade700
                                    : Colors.blue.shade300,
                                border:
                                    Border.all(color: Colors.blue, width: 2),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 2.0,
                                      fontFamily: 'Georgia',
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    leaderboardData[i]['username'],
                                    style: const TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 2.0,
                                      fontFamily: 'Georgia',
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    leaderboardData[i]['time'].toString(),
                                    style: const TextStyle(
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FontStyle.normal,
                                      letterSpacing: 2.0,
                                      fontFamily: 'Georgia',
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 220,
                    left: 50,
                    child: Text('Date  $currentDate',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w800,
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
                        )),
                  ),
                ],
              ),
            ),
    );
  }
}
