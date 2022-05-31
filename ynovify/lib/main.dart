import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:ynovify/models/duration.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ynovify/Utils/playlist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF000000),
          primaryColor: const Color(0xFF000000)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _pause = false;
  Duration? duration = new Duration(seconds: 1);
  Duration buffered = new Duration(seconds: 1);
  Duration progress = new Duration(seconds: 1);
  late Stream<DurationState> _durationState;
  double _volume = 1;

  bool _showSlider = false;
  final _player = AudioPlayer();

  void _setMusic() async {
    _player.pause();
    await _player.setAsset(myMusicList[_counter].urlSong).then((value) => {
          setState(() {
            duration = value;
            buffered = _player.bufferedPosition;
            progress = _player.position;
          })
        });

    if (!_pause) {
      _player.play();
    }
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      if (_counter >= myMusicList.length) {
        _counter = 0;
      }
    });
    _setMusic();
  }

  format(Duration? d) => d.toString().substring(2, 7);

  void _decreaseCounter() {
    setState(() {
      _counter--;
      if (_counter < 0) {
        _counter = myMusicList.length - 1;
      }
    });
    _setMusic();
  }

  void _setPause() {
    setState(() {
      _pause = !_pause;
      if (_pause) {
        _player.pause();
      } else {
        _player.play();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
        _player.positionStream,
        _player.playbackEventStream,
        (position, playbackEvent) => DurationState(
              progress: position,
              buffered: playbackEvent.bufferedPosition,
              total: playbackEvent.duration,
            ));
    _setMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Ynovify"),
          centerTitle: true,
          backgroundColor: const Color(0xFF000000)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showSlider = !_showSlider;
                    });
                  },
                  icon: new Icon(Icons.volume_up),
                  color: Colors.white,
                ),
                _showSlider
                    ? Slider(
                        min: 0.0,
                        max: 1.0,
                        value: _volume,
                        onChanged: (value) {
                          _player.setVolume(value);
                          setState(() {
                            _volume = _player.volume;
                          });
                        },
                        activeColor: Colors.white,
                        inactiveColor: Colors.white,
                      )
                    : Container(),
              ],
            ),
            Image.asset(
              myMusicList[_counter].imagePath,
            ),
            myCustomText(myMusicList[_counter].title, 50),
            myCustomText(myMusicList[_counter].singer, 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  onPressed: _decreaseCounter,
                  icon: const Icon(Icons.skip_previous),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: _setPause,
                  icon: (_pause)
                      ? Icon(Icons.play_circle_filled)
                      : Icon(Icons.pause_circle_filled),
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: _incrementCounter,
                  icon: const Icon(Icons.skip_next),
                  color: Colors.white,
                )
              ],
            ),
            StreamBuilder<DurationState>(
              stream: _durationState,
              builder: (context, snapshot) {
                final durationState = snapshot.data;
                final progress = durationState?.progress ?? Duration.zero;
                final buffered = durationState?.buffered ?? Duration.zero;
                final total = durationState?.total ?? Duration.zero;
                return Column(
                  children: [
                    Container(
                      padding:  EdgeInsets.fromLTRB(20,0,20,0),
                      child: ProgressBar(
                        progress: progress,
                        buffered: buffered,
                        total: total,
                        onSeek: (value) {
                          _player.seek(value);
                        },
                      ),
                    ),
                    Container(
                        padding: EdgeInsets.fromLTRB(20,0,20,0),
                        child: Row(
                          children: [
                            myCustomText(format(progress), 15),
                            Spacer(),
                            myCustomText(format(duration), 15)
                          ],
                        ))
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget myCustomText(String text, double size) {
  return Text(text,
      style: TextStyle(
        color: Colors.white,
        fontSize: size,
      ));
}
