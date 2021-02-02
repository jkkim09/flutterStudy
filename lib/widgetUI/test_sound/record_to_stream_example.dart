/*
 * Copyright 2018, 2019, 2020 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License version 3 (LGPL-V3), as published by
 * the Free Software Foundation.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Flutter-Sound.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_media_notification/flutter_media_notification.dart';
/*
 * This is an example showing how to record to a Dart Stream.
 * It writes all the recorded data from a Stream to a File, which is completely stupid:
 * if an App wants to record something to a File, it must not use Streams.
 *
 * The real interest of recording to a Stream is for example to feed a
 * Speech-to-Text engine, or for processing the Live data in Dart in real time.
 *
 */

///
const int tSampleRate = 44000;
typedef _Fn = void Function();
String _path = '/';

void setPath(path) {
  _path = path;
}

getPath() {
  return _path;
}

/// Example app.
class RecordToStreamExample extends StatefulWidget {
  @override
  _RecordToStreamExampleState createState() => _RecordToStreamExampleState();
}

class _RecordToStreamExampleState extends State<RecordToStreamExample> {
  FlutterSoundPlayer _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  String _mPath;
  StreamSubscription _mRecordingDataSubscription;
  // test
  bool _pause = false;

  Future<void> _openRecorder() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
    await _mRecorder.openAudioSession(
        focus: AudioFocus.requestFocusAndDuckOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker,
        audioFlags: outputToSpeaker | allowBlueToothA2DP | allowAirPlay);
    setState(() {
      _mRecorderIsInited = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // Be careful : openAudioSession return a Future.
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future
    _mPlayer.openAudioSession().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
    _setPath();
    _openRecorder();
    _setNotifi();
  }

  void _setNotifi() {
    MediaNotification.setListener('pause', () {
      print('pause');
      _mPlayer.pausePlayer();
    });

    MediaNotification.setListener('play', () {
      print('play');
      _mPlayer.resumePlayer();
    });

    MediaNotification.setListener('next', () {
      print('next');
    });

    MediaNotification.setListener('prev', () {
      print('prev');
    });

    MediaNotification.setListener('select', () {
      print('select');
    });
  }

  void _setPath() async {
    var dir = await getApplicationDocumentsDirectory();
    dir
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      print("==========_setPath-list====================>" + entity.path);
    });

    _mPath = '${dir.path}/flutter_sound_example.aac';
    print("===========_setPath=================>>>>" + _mPath);
  }

  @override
  void dispose() {
    stopPlayer();
    _mPlayer.closeAudioSession();
    _mPlayer = null;

    stopRecorder();
    _mRecorder.closeAudioSession();
    _mRecorder = null;
    super.dispose();
  }

  Future<IOSink> createFile() async {
    var dir = await getApplicationDocumentsDirectory();
    _mPath = '${dir.path}/flutter_sound_example.aac';
    var outputFile = File(_mPath);
    if (outputFile.existsSync()) {
      // await outputFile.delete();
    }
    return outputFile.openWrite();
  }

  // ----------------------  Here is the code to record to a Stream ------------

  Future<void> record() async {
    assert(_mRecorderIsInited && _mPlayer.isStopped);
    var sink = await createFile();
    var recordingDataController = StreamController<Food>();
    _mRecordingDataSubscription =
        recordingDataController.stream.listen((buffer) {
      if (buffer is FoodData) {
        sink.add(buffer.data);
      }
    });
    await _mRecorder.startRecorder(
      toStream: recordingDataController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: tSampleRate,
    );
    setState(() {});
  }
  // --------------------- (it was very simple, wasn't it ?) -------------------

  Future<void> stopRecorder() async {
    await _mRecorder.stopRecorder();
    if (_mRecordingDataSubscription != null) {
      await _mRecordingDataSubscription.cancel();
      _mRecordingDataSubscription = null;
    }
    var dir = await getApplicationDocumentsDirectory();
    File(_mPath).copySync('${dir.path}/test.aac');
    _mplaybackReady = true;
  }

  _Fn getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return null;
    }
    return _mRecorder.isStopped
        ? record
        : () {
            stopRecorder().then((value) => setState(() {}));
          };
  }

  void play() async {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder.isStopped &&
        _mPlayer.isStopped);

    await _mPlayer.startPlayer(
        fromURI: _mPath,
        sampleRate: tSampleRate,
        codec: Codec.pcm16,
        numChannels: 1,
        whenFinished: () {
          setState(() {});
        }); // The readability of Dart is very special :-(

    setState(() {});
  }

  void playTest() async {
    await _mPlayer.startPlayer(
        fromURI: _mPath,
        sampleRate: tSampleRate,
        codec: Codec.pcm16,
        numChannels: 1,
        whenFinished: () {
          setState(() {});
        }); // The readability of Dart is very special :-(
    MediaNotification.showNotification(title: 'Title', author: 'Song author');
    setState(() {});
  }

  Future<void> stopPlayer() async {
    await _mPlayer.stopPlayer();
  }

  Future<void> pausePlayer() async {
    if (!_pause) {
      await _mPlayer.pausePlayer();
    } else {
      await _mPlayer.resumePlayer();
    }
    _pause = !_pause;
    setState(() {});
  }

  Future<void> puaseRecord() async {
    if (!_mRecorder.isPaused) {
      await _mRecorder.pauseRecorder();
    } else {
      await _mRecorder.resumeRecorder();
    }
    setState(() {});
  }

  _Fn getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      // return null;
    }
    return _mPlayer.isStopped
        ? play
        : () {
            stopPlayer().then((value) => setState(() {}));
          };
  }

  _Fn getPlaybackFnTest() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder.isStopped) {
      // return null;
    }
    return _mPlayer.isStopped
        ? playTest
        : () {
            stopPlayer().then((value) => setState(() {}));
          };
  }

  // ----------------------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              RaisedButton(
                onPressed: getRecorderFn(),
                color: Colors.white,
                disabledColor: Colors.grey,
                child: Text(_mRecorder.isRecording ? 'Stop' : 'Record'),
              ),
              RaisedButton(
                onPressed: () {
                  puaseRecord();
                },
                color: Colors.white,
                disabledColor: Colors.grey,
                child: Text(_mRecorder.isPaused ? '정지' : '다시시작'),
              ),
              SizedBox(
                width: 20,
              ),
              Text(_mRecorder.isRecording
                  ? 'Recording in progress'
                  : 'Recorder is stopped'),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              RaisedButton(
                onPressed: getPlaybackFn(),
                color: Colors.white,
                disabledColor: Colors.grey,
                child: Text(_mPlayer.isPlaying ? 'Stop' : 'Play'),
              ),
              SizedBox(
                width: 20,
              ),
              Text(_mPlayer.isPlaying
                  ? 'Playback in progress'
                  : 'Player is stopped'),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getPlaybackFnTest(),
                child: Text(_mPlayer.isPlaying ? 'Stop' : 'Play'),
              ),
              ElevatedButton(
                onPressed: () {
                  pausePlayer();
                },
                child: Text(_mPlayer.isPaused ? '정지' : '시작'),
              ),
              SizedBox(
                width: 50,
              ),
              Text(_mPlayer.isPlaying
                  ? 'Playback in progress'
                  : 'Player is stopped'),
            ]),
          ),
          Container(
              child: StreamBuilder<RecordingDisposition>(
                  stream: _mRecorder.dispositionStream(),
                  initialData:
                      RecordingDisposition.zero(), // was START_DECIBELS
                  builder: (_, streamData) {
                    print(streamData);
                    var disposition = streamData.data;
                    // onRecorderProgress(context, this, disposition.duration);
                    return Text(disposition.decibels.toString());
                  })),
          RaisedButton(
            child: Text(
              'Show Pop-up',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: Colors.black,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => TestDialog(),
              );
            },
          )
        ],
      );
    }

    return Scaffold(
      body: makeBody(),
    );
  }
}

// _RecordToStreamExampleState ppState = new _RecordToStreamExampleState();

class TestDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
      title: const Text('Popup example'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            obscureText: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Title',
            ),
            onChanged: (String title) {
              print(title);
              setPath(title);
            },
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          onPressed: () {
            print(getPath());
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('확인'),
        ),
        new FlatButton(
          onPressed: () {
            // ppState.playTest();
            Navigator.of(context).pop();
          },
          textColor: Theme.of(context).primaryColor,
          child: const Text('닫기'),
        )
      ],
    );
  }
}

// Widget _buildPopupDialog(BuildContext context) {
// //  final _RecordToStreamExampleState state = RecordToStreamExample.of(context);

//   return
// }
