import 'package:chess_puzzle_game/View/menu.dart';
import "package:chess_puzzle_game/View/square.dart";
import 'package:chess_puzzle_game/View/pieces.dart';
import 'package:flutter/material.dart';
import 'package:chess_puzzle_game/Model/puzzle_repository.dart';
import 'package:collection/collection.dart';
import 'package:chess_puzzle_game/Model/user.dart';
import 'package:chess_puzzle_game/Model/data_model.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ChessBoard extends StatefulWidget {
  const ChessBoard({super.key});

  @override
  State<ChessBoard> createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  final User _userTime = User();
  late Timer timer;
  late String playerName;
  late String _date;
  late String _fen;
  late String _pgn;
  late PuzzleRepository _puzzleRepository;
  bool isTimerRunning = true;
  int secondsElapsed = 0;
  int userScore = 0;
  String isTurnUI = "";
  List<List<ChessPiece?>> newBoard =
      List.generate(8, (index) => List.generate(8, (index) => null));

  @override
  void initState() {
    super.initState();
    _puzzleRepository = PuzzleRepository();
    _fenPgnDate();
    playerName = Provider.of<DataModel>(context, listen: false).username;
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (isTimerRunning) {
        setState(() {
          secondsElapsed++;
        });
      } else {
        t.cancel();
        userScore = secondsElapsed;
        checkAndUpdateUserTime();
      }
    });
  }

  Future<void> checkAndUpdateUserTime() async {
    String storedDate = await _userTime.getUserDate(playerName);
    String currentDate = extractDateFromUrl(_date);

    if (storedDate != currentDate) {
      _userTime.updateUserTime(playerName, userScore);
      _userTime.updateUserDate(playerName, currentDate);
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  bool isWhite(int index) {
    int x = index ~/ 8;
    int y = index % 8;
    bool isWhite = (x + y) % 2 == 0;
    return isWhite;
  }

  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  late List<List<ChessPiece?>> board =
      List.generate(8, (index) => List.generate(8, (index) => null));
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];
  bool isWhiteTurn = true;
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  List<List<dynamic>> piecePositions = [];

  void _fenPgnDate() {
    _puzzleRepository.getFenAndPgn().then((data) {
      if (mounted) {
        setState(() {
          _fen = data['fen']!;
          _pgn = data['pgn']!;
          _date = data['url']!;
          isWhiteTurn = _fen.split(' ')[1] == 'w' ? true : false;
          isTurnUI = isWhiteTurn == true ? 'White to Move' : 'Black to Move';
        });
      }
    });
  }

  String extractDateFromUrl(String url) {
    RegExp dateRegex = RegExp(r'(\d{4})-(\d{2})-(\d{2})$');
    Match? match = dateRegex.firstMatch(url);
    if (match != null) {
      String year = match.group(1)!;
      String month = match.group(2)!;
      String day = match.group(3)!;
      return "$day-$month-$year";
    } else {
      return "Invalid date";
    }
  }

  List<String> parseMoves(String pgn) {
    String movesSection = pgn.split("\r\n\r\n")[1];
    List<String> moves = movesSection.split(" ");
    List<String> filteredMoves = moves
        .where((move) => !RegExp(r'^\d+\.|^1-0|^0-1|^1/2-1/2').hasMatch(move))
        .map((move) => move.replaceAll('#', ''))
        .toList();
    return filteredMoves;
  }

  List<List<dynamic>> convertMovesToCoordinates(List<String> moves) {
    List<List<dynamic>> parsedMoves = [];

    for (var move in moves) {
      List<dynamic> moveDetails = [];
      String piece = '';
      if (move.startsWith('Q')) {
        piece = 'queen';
      } else if (move.startsWith('N')) {
        piece = 'knight';
      } else if (move.startsWith('R')) {
        piece = 'rook';
      } else if (move.startsWith('B')) {
        piece = 'bishop';
      } else if (move.startsWith('K')) {
        piece = 'king';
      } else {
        piece = 'pawn';
      }
      String position = move.replaceAll(RegExp(r'[^a-h1-8]'), '');

      if (position.length == 2) {
        try {
          int col = position.codeUnitAt(0) - 'a'.codeUnitAt(0);
          int row = int.parse(position[1]) - 1;
          row = 7 - row;
          moveDetails = [piece, row, col];
        } catch (e) {
          print('Error parsing position: $position');
        }
      } else {
        print('Invalid position format: $position');
      }

      if (moveDetails.isEmpty && move.contains('x')) {
        String otherPosition =
            move.split('x')[1].replaceAll(RegExp(r'[^a-h1-8]'), '');
        if (otherPosition.length == 2) {
          try {
            int col = otherPosition.codeUnitAt(0) - 'a'.codeUnitAt(0);
            int row = int.parse(otherPosition[1]) - 1;
            row = 7 - row;
            moveDetails = [piece, row, col];
          } catch (e) {
            print('Error parsing other position: $otherPosition');
          }
        }
      }
      if (moveDetails.isNotEmpty) {
        parsedMoves.add(moveDetails);
      }
    }
    return parsedMoves;
  }

  void _initializeBoard(String fen) {
    List<String> rows = fen.split(' ')[0].split('/');
    piecePositions = [];
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (_) => List.filled(8, null));

    Map<String, int> whitePieceCounter = {
      'pawn': 1,
      'rook': 1,
      'knight': 1,
      'bishop': 1,
    };
    Map<String, int> blackPieceCounter = {
      'pawn': 1,
      'rook': 1,
      'knight': 1,
      'bishop': 1,
    };

    for (int row = 0; row < 8; row++) {
      int col = 0;
      for (int i = 0; i < rows[row].length; i++) {
        String symbol = rows[row][i];
        if (RegExp(r'\d').hasMatch(symbol)) {
          col += int.parse(symbol);
        } else {
          bool isWhite = symbol == symbol.toUpperCase();
          ChessPiecesType type;
          switch (symbol.toLowerCase()) {
            case 'p':
              type = ChessPiecesType.pawn;
              break;
            case 'r':
              type = ChessPiecesType.rook;
              break;
            case 'n':
              type = ChessPiecesType.knight;
              break;
            case 'b':
              type = ChessPiecesType.bishop;
              break;
            case 'q':
              type = ChessPiecesType.queen;
              break;
            case 'k':
              type = ChessPiecesType.king;
              break;
            default:
              throw Exception("Invalid FEN symbol: $symbol");
          }

          if (isWhite) {
            String pieceName;
            if (type == ChessPiecesType.king || type == ChessPiecesType.queen) {
              pieceName = type.name;
            } else {
              pieceName = '${type.name}${whitePieceCounter[type.name]}';
              whitePieceCounter[type.name] = whitePieceCounter[type.name]! + 1;
            }
            piecePositions.add(['w', pieceName, row, col]);
          } else {
            String pieceName;
            if (type == ChessPiecesType.king || type == ChessPiecesType.queen) {
              pieceName = type.name;
            } else {
              pieceName = '${type.name}${blackPieceCounter[type.name]}';
              blackPieceCounter[type.name] = blackPieceCounter[type.name]! + 1;
            }
            piecePositions.add(['b', pieceName, row, col]);
          }
          newBoard[row][col] = ChessPiece(
            type: type,
            isWhite: isWhite,
            imagePath: 'images/${type.name}.png',
          );
          col++;
        }
      }
    }
    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }
      validMoves = calculateRealValidMoves(
          selectedRow, selectedCol, selectedPiece, true);
    });
  }

  bool otoComputerMoves(String pieceName, int currentRow, int currentCol,
      int nextRow, int nextCol) {
    bool otoMove = false;
    int rowDiff = nextRow - currentRow;
    int colDiff = nextCol - currentCol;

    switch (pieceName.toLowerCase()) {
      case 'pawn':
        if (nextRow == 7) {
          board[currentRow][currentCol] = newBoard[7][6] = ChessPiece(
              type: ChessPiecesType.queen,
              isWhite: false,
              imagePath: 'images/queen.png');
          pieceName = 'queen';
          otoMove = true;
        } else if (rowDiff.abs() == 1 && colDiff == 0 && board[nextRow][nextCol] ==null ) {
          otoMove = true;
        } else if (rowDiff.abs() == 2 && colDiff == 0 && board[nextRow][nextCol] ==null) {
          otoMove = true;
        } else if ((rowDiff.abs() == 1 && colDiff.abs() == 1)) {
          otoMove = true;
        }
        break;
      case 'rook':
        if (currentRow == nextRow && currentCol != nextCol) {
          otoMove = true;
        } else if (currentCol == nextCol && currentRow != nextRow) {
          otoMove = true;
        }
        break;
      case 'knight':
        if ((rowDiff.abs() == 2 && colDiff.abs() == 1) ||
            (rowDiff.abs() == 1 && colDiff.abs() == 2)) {
          otoMove = true;
        }
        break;
      case 'bishop':
        if (rowDiff.abs() == colDiff.abs()) {
          otoMove = true;
        }
        break;
      case 'king':
        otoMove = true;
        break;
      case 'queen':
        otoMove = true;
        break;
      default:
        otoMove = false;
        break;
    }
    return otoMove;
  }

  void otoMovePiece(int currentRow, int currentCol, int newRow, int newCol) {
    ChessPiece? selectedPiece = board[currentRow][currentCol];
    board[newRow][newCol] = selectedPiece;
    board[currentRow][currentCol] = null;
  }

  List<List<int>> calculateRowValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPiecesType.pawn:
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case ChessPiecesType.rook:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], //left
          [0, 1], //right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPiecesType.knight:
        // all eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1], // up 2 left 1
          [-2, 1], // up 2 right 1
          [-1, -2], // up 1 left 2
          [-1, 2], // up 1 right 2
          [1, -2], // down 1 left 2
          [1, 2], // down 1 right 2
          [2, -1], // down 2 left 1
          [2, 1], // down 2 right 1
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] == null ||
              board[newRow][newCol]!.isWhite != piece.isWhite) {
            candidateMoves.add([newRow, newCol]);
          }
        }
        break;

      case ChessPiecesType.bishop:
        var directions = [
          [-1, -1], // up-left
          [-1, 1], // up-right
          [1, -1], // down-left
          [1, 1], // down-right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPiecesType.queen:
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
          [-1, -1], // up-left
          [-1, 1], // up-right
          [1, -1], // down-left
          [1, 1] // down-right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];

            if (!isInBoard(newRow, newCol)) {
              break;
            }

            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPiecesType.king:
        var kingMoves = [
          [-1, -1], // Up-left
          [-1, 0], // Up
          [-1, 1], // Up-right
          [0, -1], // Left
          [0, 1], // Right
          [1, -1], // Down-left
          [1, 0], // Down
          [1, 1] // Down-right
        ];

        for (var move in kingMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];

          if (!isInBoard(newRow, newCol)) {
            continue;
          }

          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      default:
    }
    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRowValidMoves(row, col, piece);
    if (checkSimulation) {
      for (var move in candidateMoves) {
        realValidMoves.add(move);
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  List<List<dynamic>> moveHistory = [];
  int currentMoveIndex = 0;
  List<List<dynamic>> selectedGroup = [];
  List<List<dynamic>> matchedPieces = [];

  void initSelectedGroup() {
    if (selectedGroup.isEmpty) {
      String turnOtoMove = isWhiteTurn ? "w" : "b";
      selectedGroup = piecePositions.where((p) => p[0] != turnOtoMove).toList();
    }
  }

  void movePiece(int newRow, int newCol) {
    initSelectedGroup();
    String pieceType = selectedPiece?.type.name ?? "Unknown Piece";

    if (selectedPiece?.type == ChessPiecesType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    if(board[newRow][newCol]!=null){
      for(int i= 0;i<selectedGroup.length;i++){
        if(selectedGroup[i][2]==newRow && selectedGroup[i][3]==newCol){
          selectedGroup.removeAt(i);
        }
      }
    }
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;
    

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    isWhiteTurn = !isWhiteTurn;
    List<dynamic> moveInfo = [pieceType, newRow, newCol];
    moveHistory.add(moveInfo);

    var correctMoves = parseMoves(_pgn);
    List<List<dynamic>> correctMovesCoordinates =
        convertMovesToCoordinates(correctMoves);

    ListEquality equality = const ListEquality();

    if (currentMoveIndex < correctMovesCoordinates.length &&
        equality.equals(moveHistory[moveHistory.length - 1],
            correctMovesCoordinates[currentMoveIndex])) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            textAlign: TextAlign.center,
            'Correct Move',
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

      currentMoveIndex++;
      isTimerRunning =
          currentMoveIndex == correctMovesCoordinates.length ? false : true;

      if (isTimerRunning == false) {
        Future.delayed(Duration.zero, () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.black,
              title: const Text(
                'Congratulations, you solved the puzzle.',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'Georgia',
                  color: Colors.white,
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    startTimer();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MenuPage()),
                    );
                  },
                ),
              ],
            ),
          );
        });
      }

      String correctPieceType = correctMovesCoordinates[currentMoveIndex][0];
      for (var pos in selectedGroup) {
        String positionPieceType = pos[1];
        if (correctPieceType.substring(0, 3) ==
            positionPieceType.substring(0, 3)) {
          matchedPieces.add(pos);
        }
      }
      for (var piece in matchedPieces) {
        if (piece[1] is String && piece[1].toString().startsWith('pawn')) {
          piece[1] = piece[1].substring(0, piece[1].length - 1);
        }
      }
      for (int i = 0; i < matchedPieces.length; i++) {
        var correct = otoComputerMoves(
            matchedPieces[i][1],
            matchedPieces[i][2],
            matchedPieces[i][3],
            correctMovesCoordinates[currentMoveIndex][1],
            correctMovesCoordinates[currentMoveIndex][2]);
        if (correct) {
          otoMovePiece(
              matchedPieces[i][2],
              matchedPieces[i][3],
              correctMovesCoordinates[currentMoveIndex][1],
              correctMovesCoordinates[currentMoveIndex][2]);

          for (var piece in selectedGroup) {
            if (piece[1].substring(0, 3) == correctPieceType.substring(0, 3) &&
                piece[2] == matchedPieces[i][2] &&
                piece[3] == matchedPieces[i][3]) {
              piece[2] = correctMovesCoordinates[currentMoveIndex][1];
              piece[3] = correctMovesCoordinates[currentMoveIndex][2];
            }
          }
          currentMoveIndex++;
          isWhiteTurn = !isWhiteTurn;
          matchedPieces.clear();
          break;
        }
      }
    } else {
      handleWrongMove();
      moveHistory = [];
      currentMoveIndex = 0;
      selectedGroup.clear();
      matchedPieces.clear();
    }
  }

  void handleWrongMove() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          textAlign: TextAlign.center,
          'Wrong Move!',
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
        backgroundColor: Colors.redAccent,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      _initializeBoard(_fen);
      isWhiteTurn = !isWhiteTurn;
    });
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
            'Chess Puzzle',
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'Georgia',
                    letterSpacing: 3.5,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$secondsElapsed second',
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'Georgia',
                    letterSpacing: 3.5,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // Expanded - Chessboard
          Expanded(
            flex: 3,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8 * 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = selectedCol == col && selectedRow == row;
                bool isValidMove = false;
                for (var position in validMoves) {
                  // compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }
                return Square(
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                  isSelected: isSelected,
                  isWhite: isWhite(index),
                  piece: board[row][col],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                isTurnUI,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'Georgia',
                  letterSpacing: 3.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 97, horizontal: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 30.0),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.black,
                      title: const Text(
                        'Information',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Georgia',
                          color: Colors.white,
                        ),
                      ),
                      content: const Text(
                        'The leaderboard contains only the score of the first puzzle you solved.',
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Georgia',
                          color: Colors.white,
                        ),
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 9),
                          ),
                          onPressed: () {
                            startTimer();
                            _initializeBoard(_fen);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Georgia',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                'PLAY',
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
        ],
      ),
    );
  }
}
