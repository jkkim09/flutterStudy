import 'dart:io';
import 'package:fluttertest/provider/count_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart';

import '../widgetUI/demo_util/temp_file.dart';
import '../widgetUI/demo_util/recorder_state.dart';
import '../widgetUI/demo_util/demo_active_codec.dart';

class First extends StatefulWidget {
  @override
  _FirstState createState() => _FirstState();
}

class _FirstState extends State<First> {
  bool initialized = false;
  Track track;
  String recordingFile;
  CountProvider _countProvider;
  @override
  void initState() {
    super.initState();
    tempFile(suffix: '.aac').then((path) {
      recordingFile = path;
      // trackPath: 오디오 파일 경로
      debugPrint(recordingFile);
      track = Track(trackPath: recordingFile);
      setState(() {});
    });
  }

  Future<bool> init() async {
    if (!initialized) {
      await initializeDateFormatting();
      await UtilRecorder().init();
      ActiveCodec().recorderModule = UtilRecorder().recorderModule;
      ActiveCodec().setCodec(withUI: false, codec: Codec.aacADTS);

      initialized = true;
    }
    return initialized;
  }

  @override
  void dispose() {
    _clean();
    super.dispose();
  }

  void _clean() async {
    if (recordingFile != null) {
      try {
        await File(recordingFile).delete();
      } on Exception {
        // ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final number = Provider.of<int>(context);
    final string = Provider.of<String>(context);

    debugPrint("======================================>");
    print(number);
    print(string);
    debugPrint("<======================================");
    return FutureBuilder(
        initialData: false,
        future: init(),
        builder: (context, snapshot) {
          if (snapshot.data == false) {
            return Container(width: 0, height: 0, color: Colors.white);
          } else {
            return ListView(children: [_buildRecorder(track)]);
          }
        });
  }

  Widget _buildRecorder(Track track) {
    _countProvider = Provider.of<CountProvider>(context);
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: RecorderPlaybackController(
            child: Column(
          children: [
            Left('Recorder'),
            SoundRecorderUI(
              track,
              stoppedTitle: "정지",
            ),
            Left('Recording Playback'),
            SoundPlayerUI.fromTrack(
              track,
              enabled: false,
              showTitle: true,
              audioFocus: AudioFocus.requestFocusAndDuckOthers,
            ),
            InkWell(
              child: Text('test'),
              onTap: () {
                _countProvider.add();
              },
            )
          ],
        )));
  }
}

///
class Left extends StatelessWidget {
  ///
  final String label;

  ///
  Left(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 4, left: 8),
      child: Container(
          alignment: Alignment.centerLeft,
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold))),
    );
  }
}
