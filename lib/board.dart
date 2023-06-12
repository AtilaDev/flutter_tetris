import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tetris/piece.dart';
import 'package:tetris/pixel.dart';
import 'package:tetris/values.dart';
import 'package:audioplayers/audioplayers.dart';

// create game board
List<List<Tetromino?>> gameBoard = List.generate(
  colLength,
  (i) => List.generate(
    rowLength,
    (j) => null,
  ),
);

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  // current tetris piece
  Piece currentPiece = Piece(type: Tetromino.L);

  // current score
  int currentScore = 0;

  // game over
  bool gameOver = false;

  AudioPlayer audioPlayer = AudioPlayer();

  Future<void> playBackgroundMusic() async {
    audioPlayer.play(AssetSource("tetris.m4a"));
  }

  @override
  void initState() {
    super.initState();

    // start game when ap starts
    startGame();
  }

  void startGame() {
    currentPiece.initializePiece();
    playBackgroundMusic();

    // frame refreh rate
    Duration frameRate = const Duration(milliseconds: 300);
    gameLoop(frameRate);
  }

  void gameLoop(Duration frameRate) {
    Timer.periodic(
      frameRate,
      (timer) {
        setState(() {
          // clear lines
          clearLines();

          // check landing
          checkLanding();

          if (gameOver == true) {
            timer.cancel();
            audioPlayer.stop();
            showGameOverDialog();
          }

          // move current piece down
          currentPiece.movePiece(Direction.down);
        });
      },
    );
  }

  // game over dialog
  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text("Your score is: $currentScore"),
        actions: [
          TextButton(
            onPressed: () {
              resetGame();

              // Navigator.pop(context);
              Navigator.pushNamed(context, "/");
            },
            child: const Text("Ok"),
          )
        ],
      ),
    );
  }

  // reset game
  void resetGame() {
    gameBoard = List.generate(
      colLength,
      (i) => List.generate(
        rowLength,
        (j) => null,
      ),
    );

    // new game
    gameOver = false;
    currentScore = 0;

    // createNewPiece();
    // startGame();
  }

  // check for collision in a future position
  bool checkCollision(Direction direction) {
    // loop throught each position of the current piece
    for (int i = 0; i < currentPiece.position.length; i++) {
      // calculate the row and col of the current position
      int row = (currentPiece.position[i] / rowLength).floor();
      int col = currentPiece.position[i] % rowLength;

      // adjust the row and col based on the direction
      if (direction == Direction.left) {
        col -= 1;
      } else if (direction == Direction.right) {
        col += 1;
      } else if (direction == Direction.down) {
        row += 1;
      }

      // check if the piece is out of bounds
      if (row >= colLength || col < 0 || col >= rowLength) {
        return true;
      }

      if (row >= 0 && gameBoard[row][col] != null) {
        return true;
      }
    }

    // if not collision detected
    return false;
  }

  void checkLanding() {
    if (checkCollision(Direction.down)) {
      // mark position as occupied on the gameboard
      for (int i = 0; i < currentPiece.position.length; i++) {
        int row = (currentPiece.position[i] / rowLength).floor();
        int col = currentPiece.position[i] % rowLength;
        if (row >= 0 && col >= 0) {
          gameBoard[row][col] = currentPiece.type;
        }
      }

      // once landed, create next piece
      createNewPiece();
    }
  }

  void createNewPiece() {
    // create a random object to generate random tetrominotypes
    Random rand = Random();

    // create a new piece with random type
    Tetromino randomType =
        Tetromino.values[rand.nextInt(Tetromino.values.length)];
    currentPiece = Piece(type: randomType);
    currentPiece.initializePiece();

    if (isGameOver()) {
      gameOver = true;
    }
  }

  void moveLeft() {
    if (!checkCollision(Direction.left)) {
      setState(() {
        currentPiece.movePiece(Direction.left);
      });
    }
  }

  void moveRight() {
    if (!checkCollision(Direction.right)) {
      setState(() {
        currentPiece.movePiece(Direction.right);
      });
    }
  }

  void rotatePiece() {
    setState(() {
      currentPiece.rotatePiece();
    });
  }

  // clear lines
  void clearLines() {
    for (int row = colLength - 1; row >= 0; row--) {
      bool rowIsFull = true;

      for (int col = 0; col < rowLength; col++) {
        if (gameBoard[row][col] == null) {
          rowIsFull = false;
          break;
        }
      }

      if (rowIsFull) {
        for (int r = row; r > 0; r--) {
          gameBoard[r] = List.from(gameBoard[r - 1]);
        }

        gameBoard[0] = List.generate(row, (index) => null);

        currentScore++;
      }
    }
  }

  // game over
  bool isGameOver() {
    for (int col = 0; col < rowLength; col++) {
      if (gameBoard[0][col] != null) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // game board
          Expanded(
            child: GridView.builder(
                itemCount: rowLength * colLength,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: rowLength,
                ),
                itemBuilder: (context, index) {
                  // get row and colof each index
                  int row = (index / rowLength).floor();
                  int col = index % rowLength;

                  // current piece
                  if (currentPiece.position.contains(index)) {
                    return Pixel(
                      color: currentPiece.color,
                    );
                  }
                  // landed pieces
                  else if (gameBoard[row][col] != null) {
                    final Tetromino? tetrominoType = gameBoard[row][col];
                    return Pixel(color: tetrominoColors[tetrominoType]!);
                  }
                  // blank pixel
                  else {
                    return Pixel(
                      color: Colors.grey.shade900,
                    );
                  }
                }),
          ),

          // score
          Text(
            "Score: $currentScore",
            style: const TextStyle(color: Colors.white),
          ),

          // game controls
          Padding(
            padding: const EdgeInsets.only(bottom: 50, top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // left
                IconButton(
                  onPressed: moveLeft,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: Colors.white,
                ),

                // rotate
                IconButton(
                    onPressed: rotatePiece,
                    icon: const Icon(Icons.rotate_right),
                    color: Colors.white),

                // right
                IconButton(
                    onPressed: moveRight,
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: Colors.white),
              ],
            ),
          )
        ],
      ),
    );
  }
}
