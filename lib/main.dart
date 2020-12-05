import 'dart:async';

import 'package:flutter/material.dart';
import 'music.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jordy Music',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Jordy Music'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Music> maListeDeMusic = [
    Music('Theme Swift', 'Jodan', 'assets/2.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/un.mp3'),
    Music('Theme Flutter', 'Jodan', 'assets/future.jpg',
        'https://codabee.com/wp-content/uploads/2018/06/deux.mp3'),
  ];
  AudioPlayer audioPlayer;
  StreamSubscription positionSub;
  StreamSubscription stateSubscription;
  Music maMusicActuelle;
  Duration position = Duration(seconds: 0);
  Duration duree = Duration(seconds: 10);
  PlayerState statut = PlayerState.stopped;
  int index = 0;

  @override
  void initState() {
    super.initState();
    maMusicActuelle = maListeDeMusic[index];
    configurationAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Card(
              elevation: 9.0,
              child: Container(
                width: MediaQuery.of(context).size.width / 2.5,
                child: Image.asset(maMusicActuelle.imagePath),
              ),
            ),
            texteAvecStyle(maMusicActuelle.titre, 1.5),
            texteAvecStyle(maMusicActuelle.artiste, 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                button(Icons.fast_rewind, 30.0, ActionMusic.rewind),
                button(
                    (statut == PlayerState.playing)
                        ? Icons.pause
                        : Icons.play_arrow,
                    45.0,
                    (statut == PlayerState.playing)
                        ? ActionMusic.pause
                        : ActionMusic.play),
                button(Icons.fast_forward, 30.0, ActionMusic.forward),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                texteAvecStyle(fromDuration(position), 0.8),
                texteAvecStyle(fromDuration(duree), 0.8),
              ],
            ),
            Slider(
                value: position.inSeconds.toDouble(),
                min: 0.0,
                max: 22.0,
                inactiveColor: Colors.white,
                activeColor: Colors.red,
                onChanged: (double d) {
                  setState(() {
                    Duration nouvelleDuration = Duration(seconds: d.toInt());
                    position = nouvelleDuration;
                    audioPlayer.seek;
                  });
                })
          ],
        ),
      ),
    );
  }

  IconButton button(IconData icone, double taille, ActionMusic action) {
    return IconButton(
        iconSize: taille,
        color: Colors.white,
        icon: Icon(icone),
        onPressed: () {
          switch (action) {
            case ActionMusic.play:
              play();
              break;

            case ActionMusic.pause:
              pause();
              break;

            case ActionMusic.forward:
              forward();
              break;

            case ActionMusic.rewind:
              rewind();
              break;
          }
        });
  }

  Text texteAvecStyle(String data, double scale) {
    return Text(data,
        textScaleFactor: scale,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontStyle: FontStyle.italic,
        ));
  }

  void configurationAudioPlayer() {
    audioPlayer = AudioPlayer();
    positionSub = audioPlayer.onAudioPositionChanged
        .listen((pos) => setState(() => position = pos));
    stateSubscription = audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == AudioPlayerState.PLAYING) {
        setState(() {});
      } else if (state == AudioPlayerState.STOPPED) {
        setState(() {
          statut = PlayerState.stopped;
        });
      }
    }, onError: (message) {
      print('erreur : $message');
      setState(() {
        statut = PlayerState.stopped;
        duree = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(maMusicActuelle.urlSong);
    setState(() {
      statut = PlayerState.playing;
    });
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() {
      statut = PlayerState.paused;
    });
  }

  void forward() {
    if (index == maListeDeMusic.length - 1) {
      index = 0;
    } else {
      index++;
    }
    maMusicActuelle = maListeDeMusic[index];
    audioPlayer.stop();
    configurationAudioPlayer();
  }

  void rewind() {
    if (position > Duration(seconds: 3)) {
      audioPlayer.seek;
    } else {
      if (index == 0) {
        index = maListeDeMusic.length - 1;
        audioPlayer.stop();
        configurationAudioPlayer();
        play();
      }
    }
  }

  String fromDuration(Duration duree) {
    print('duree');
    return duree.toString().split('.').first;
  }
}

enum ActionMusic {
  play,
  pause,
  rewind,
  forward,
}

enum PlayerState {
  playing,
  stopped,
  paused,
}
