import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyan),
        ),
        home: const Window(
          title: 'Game of Risk',
        ),
      ),
    );
  }
}

class AppState extends ChangeNotifier {
  int roll = 0;
  int bank = 0;

  bool isPlayer1Turn = true;
  String message = "";
  String winMessage = "";

  int player1Score = 0;
  int player2Score = 0;
}

class Window extends StatelessWidget {
  const Window({super.key, required String title});

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();

    ThemeData theme = Theme.of(context);
    TextStyle appBarStyle = theme.textTheme.displayMedium!.copyWith(
      fontSize: 30,
      color: theme.colorScheme.background,
    );

    TextStyle style = appBarStyle.copyWith(
      color: theme.colorScheme.primary,
    );

    void reset() {
      appState.roll = 0;
      appState.bank = 0;

      appState.isPlayer1Turn = true;
      appState.message = "";
      appState.winMessage = "";

      appState.player1Score = 0;
      appState.player2Score = 0;

      appState.notifyListeners();
    }

    showAlertDialog(BuildContext context) {
      // set up the button
      Widget okButton = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            child: const Text(
              "Play Again",
            ),
            onPressed: () {
              Navigator.of(context).pop();
              reset();
            },
          ),
        ],
      );

      // set up the AlertDialog
      AlertDialog alert = AlertDialog(
        content: Container(
          height: 40,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                appState.winMessage,
                style: style,
              ),
            ],
          ),
        ),
        actions: [
          okButton,
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }

    void roll() {
      appState.message = "";
      int roll = Random().nextInt(6) + 1;
      appState.roll = roll;
      if (roll >= 2 && roll <= 5) {
        appState.bank += roll;
      } else {
        if (roll == 1) {
          appState.message = "Rolled a 1";
        } else {
          appState.message = "Rolled a 6";
        }

        appState.roll = 0;
        appState.bank = 0;
        appState.isPlayer1Turn = !appState.isPlayer1Turn;
      }
      appState.notifyListeners();
    }

    void bank() {
      if (appState.roll != 0) {
        if (appState.isPlayer1Turn) {
          appState.player1Score += appState.bank;
        } else {
          appState.player2Score += appState.bank;
        }

        appState.roll = 0;
        appState.bank = 0;

        if (appState.player1Score >= 20) {
          appState.winMessage = "Player 1 Wins!";
          showAlertDialog(context);
        }

        if (appState.player2Score >= 20) {
          appState.winMessage = "Player 2 Wins!";
          showAlertDialog(context);
        }

        appState.isPlayer1Turn = !appState.isPlayer1Turn;
        appState.notifyListeners();
      }
    }

    int height = 50;
    if (Platform.isIOS) {
      height = 90;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Game of Risk"),
        backgroundColor: theme.colorScheme.primary,
        titleTextStyle: appBarStyle,
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Scores(style: style),
          const Spacer(),
          const Dice(),
          const Spacer(flex: 2),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: reset,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.restart_alt),
      ),
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 6,
          clipBehavior: Clip.antiAlias,
          height: height.toDouble(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: roll,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Text("Roll"),
                ),
              ),
              ElevatedButton(
                onPressed: bank,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: Text("Lock-in"),
                ),
              ),
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class Scores extends StatelessWidget {
  const Scores({
    super.key,
    required this.style,
  });

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();

    Color active = Theme.of(context).colorScheme.primary;
    Color inactive = Theme.of(context).colorScheme.background;

    Color player1Color = inactive;
    Color player2Color = inactive;
    switch (appState.isPlayer1Turn) {
      case true:
        player1Color = active;
        break;

      case false:
        player2Color = active;
        break;
    }
    ThemeData theme = Theme.of(context);
    TextStyle altPlayer1 = theme.textTheme.displaySmall!.copyWith(
      color: player2Color,
      fontSize: 30,
    );

    TextStyle altPlayer2 = theme.textTheme.displaySmall!.copyWith(
      color: player1Color,
      fontSize: 30,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: player1Color,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  "Player 1",
                  style: altPlayer1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(appState.player1Score.toString(), style: style),
            ),
          ],
        ),
        Column(
          children: [
            Icon(
              Icons.monetization_on,
              color: theme.colorScheme.primary,
              size: 45,
            ),
            Text(
              appState.bank.toString(),
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 30,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Card(
              color: player2Color,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text("Player 2", style: altPlayer2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(appState.player2Score.toString(), style: style),
            ),
          ],
        ),
      ],
    );
  }
}

class Dice extends StatelessWidget {
  const Dice({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AppState appState = context.watch<AppState>();

    ThemeData theme = Theme.of(context);
    TextStyle style = theme.textTheme.displayMedium!.copyWith(
      fontSize: 50,
    );

    return Column(
      children: [
        Card(
          child: Container(
            width: 100,
            height: 100,
            alignment: Alignment.center,
            child: Text(
              appState.roll.toString(),
              style: style,
            ),
          ),
        ),
        Text(appState.message.toString()),
      ],
    );
  }
}
