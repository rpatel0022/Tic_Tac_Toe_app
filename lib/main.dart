import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GameScreen(),
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Colors.white,
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  bool isOTurn = true; // The first player is O
  List<String> boardState = ['', '', '', '', '', '', '', '', ''];
  List<int> winCombo = [];
  int oPlayerScore = 0;
  int xPlayerScore = 0;
  int movesMade = 0;
  late AnimationController animController;
  late Animation<double> scaleAnimation;
  bool firstGame = true;

  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: animController,
      curve: Curves.easeInOut,
    ));

    // Show fun fact when the game starts for the first time
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (firstGame) {
        _displayFunFact();
        firstGame = false;
      }
    });
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Custom Tic Tac Toe', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Player 1 (O)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.blue,
                                offset: Offset(5.0, 5.0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          oPlayerScore.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.blue,
                                offset: Offset(5.0, 5.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Player 2 (X)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.red,
                                offset: Offset(5.0, 5.0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          xPlayerScore.toString(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.red,
                                offset: Offset(5.0, 5.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            isOTurn ? "Player O's Turn" : "Player X's Turn",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
                itemCount: 9,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3), // Specifies a fixed number of cells (3) per row.
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      _handleTap(index);
                    },
                    child: AnimatedBuilder(
                      animation: animController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: winCombo.contains(index) ? scaleAnimation.value : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: winCombo.contains(index) ? Colors.green : Colors.transparent,
                              border: Border.all(
                                color: _getGradientColor(index),
                                width: 4.0,
                              ),
                            ),
                            child: Center(
                              child: boardState[index] == 'O'
                                  ? Image.asset('assets/o_image.png')
                                  : boardState[index] == 'X'
                                      ? Image.asset('assets/x_image.png')
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      _resetScoreBoard();
                      _displayFunFact();
                    },
                    child: Text("Restart Game"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getGradientColor(int index) {
    List<Color> colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];
    return colors[index % colors.length];
  }

  void _handleTap(int index) {
    setState(() {
      if (isOTurn && boardState[index] == '') {
        boardState[index] = 'O';
        movesMade++;
      } else if (!isOTurn && boardState[index] == '') {
        boardState[index] = 'X';
        movesMade++;
      }

      isOTurn = !isOTurn;
      _evaluateWinner();
    });
  }

  void _evaluateWinner() {
    // Checking rows
    if (boardState[0] == boardState[1] &&
        boardState[0] == boardState[2] &&
        boardState[0] != '') {
      winCombo = [0, 1, 2];
      _showWinDialog(boardState[0]);
    }
    if (boardState[3] == boardState[4] &&
        boardState[3] == boardState[5] &&
        boardState[3] != '') {
      winCombo = [3, 4, 5];
      _showWinDialog(boardState[3]);
    }
    if (boardState[6] == boardState[7] &&
        boardState[6] == boardState[8] &&
        boardState[6] != '') {
      winCombo = [6, 7, 8];
      _showWinDialog(boardState[6]);
    }

    // Checking columns
    if (boardState[0] == boardState[3] &&
        boardState[0] == boardState[6] &&
        boardState[0] != '') {
      winCombo = [0, 3, 6];
      _showWinDialog(boardState[0]);
    }
    if (boardState[1] == boardState[4] &&
        boardState[1] == boardState[7] &&
        boardState[1] != '') {
      winCombo = [1, 4, 7];
      _showWinDialog(boardState[1]);
    }
    if (boardState[2] == boardState[5] &&
        boardState[2] == boardState[8] &&
        boardState[2] != '') {
      winCombo = [2, 5, 8];
      _showWinDialog(boardState[2]);
    }

    // Checking diagonals
    if (boardState[0] == boardState[4] &&
        boardState[0] == boardState[8] &&
        boardState[0] != '') {
      winCombo = [0, 4, 8];
      _showWinDialog(boardState[0]);
    }
    if (boardState[2] == boardState[4] &&
        boardState[2] == boardState[6] &&
        boardState[2] != '') {
      winCombo = [2, 4, 6];
      _showWinDialog(boardState[2]);
    } else if (movesMade == 9) {
      _showDrawDialog();
    }
  }

  void _showWinDialog(String winner) {
    animController.forward(from: 0.0);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("\" " + winner + " \" is Winner"),
          actions: [
            TextButton(
              child: Text("Play Again"),
              onPressed: () {
                _resetBoard();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );

    if (winner == 'O') {
      oPlayerScore++;
    } else if (winner == 'X') {
      xPlayerScore++;
    }
  }

  void _showDrawDialog() {
    animController.forward(from: 0.0);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Draw"),
          actions: [
            TextButton(
              child: Text("Play Again"),
              onPressed: () {
                _resetBoard();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void _resetBoard() {
    setState(() {
      for (int i = 0; i < 9; i++) {
        boardState[i] = '';
      }
      winCombo.clear();
    });

    movesMade = 0;
  }

  void _resetScoreBoard() {
    setState(() {
      xPlayerScore = 0;
      oPlayerScore = 0;
      for (int i = 0; i < 9; i++) {
        boardState[i] = '';
      }
      winCombo.clear();
    });
    movesMade = 0;
  }

  void _displayFunFact() {
    List<String> funFacts = [
      "Tic Tac Toe is also known as Noughts and Crosses.",
      "The game is one of the oldest known games, dating back to ancient Egypt.",
      "There are 255,168 possible unique games in Tic Tac Toe.",
      "The first player can force a win or a draw if they play perfectly.",
      "Tic Tac Toe is classified as a 'solved' game.",
      "The center square is the most strategically important square in Tic Tac Toe.",
      "Tic Tac Toe has inspired numerous variations and adaptations.",
      "It's commonly used as a metaphor for evenly matched situations.",
      "The game has been played by people of all ages and cultures around the world.",
      "It's a common pastime in schoolyards, cafes, and homes.",
      "Tic Tac Toe is often used as a warm-up or icebreaker activity.",
      "The game can be played with pen and paper, chalk, or digitally.",
      "Tic Tac Toe has been featured in movies, TV shows, and literature.",
      "Some cultures have their own variations of Tic Tac Toe.",
      "In some countries, the game is known by different names.",
      "Tic Tac Toe has been used in psychological studies.",
      "The game's simplicity belies its strategic depth.",
      "Tic Tac Toe can be played competitively or casually.",
      "The rules of Tic Tac Toe are easy to learn.",
      "The game's origins can be traced back to ancient Roman and Greek civilizations.",
      "Tic Tac Toe is often used in AI and computer science research.",
      "The game's popularity has endured for centuries.",
      "Tic Tac Toe has been played on various surfaces, from sand to chalkboards.",
      "It's commonly played as a time-filler or boredom buster.",
      "Tic Tac Toe has been featured in art and music.",
      "The game has simple rules but complex strategies.",
      "Tic Tac Toe tournaments have been held around the world.",
      "Some players have developed their own unique strategies and tactics.",
      "Tic Tac Toe can be played in different modes, including online and offline.",
      "The game's strategic possibilities make it intriguing for mathematicians.",
      "Tic Tac Toe has been included in educational curriculums.",
      "Some mathematicians have calculated the number of possible games.",
      "Tic Tac Toe has been used to teach probability and decision-making.",
      "The game's popularity has led to its inclusion in various pop culture references.",
      "Tic Tac Toe has been adapted into electronic games and apps.",
      "The game's simplicity makes it accessible to players of all ages and skill levels.",
      "Tic Tac Toe is often used as a tool for brain teasers and puzzles.",
      "Some versions of Tic Tac Toe include additional rules or variations.",
      "Tic Tac Toe has been analyzed by game theorists and strategists.",
      "The game's enduring appeal lies in its blend of simplicity and strategy.",
      "Tic Tac Toe has been used in therapy and rehabilitation settings.",
      "The game's design allows for quick and engaging gameplay.",
      "Tic Tac Toe has been featured in academic research on cognition and decision-making.",
      "The game's grid layout makes it visually appealing and easy to understand.",
      "Tic Tac Toe has been included in museums and exhibitions on games and puzzles.",
      "The game has been adapted into physical toys and board games.",
      "Tic Tac Toe has been played competitively in organized tournaments.",
      "Some players have achieved celebrity status for their skill in Tic Tac Toe."
    ];

    final randomFact = funFacts[Random().nextInt(funFacts.length)];

    animController.forward(from: 0.0);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ScaleTransition(
          scale: scaleAnimation,
          child: AlertDialog(
            title: Text("Fun Fact"),
            content: Text(randomFact),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Got it!"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
