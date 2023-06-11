import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gamepad_outlined,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 5),
            Text(
              'Bricks',
              style: TextStyle(
                color: Colors.grey.shade300,
                fontSize: 30,
                fontWeight: FontWeight.w200,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/gameboard");
              },
              child: Text(
                "play",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey.shade50,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 2,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
