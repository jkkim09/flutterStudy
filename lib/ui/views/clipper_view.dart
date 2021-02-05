import 'package:flutter/material.dart';
import 'package:fluttertest/core/models/waveform_data_model.dart';
import 'package:fluttertest/core/services/waveform_data_loader.dart';
import 'package:fluttertest/ui/widgets/app_bar.dart';
import 'package:fluttertest/ui/widgets/bottom_app_bar.dart';

class ClipperView extends StatelessWidget {
  const ClipperView({Key key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: sharedAppBar(context, "Waveform Clipper"),
      bottomNavigationBar: sharedBottomAppBar(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Container(
                color: Colors.grey[900],
                child: FutureBuilder<WaveformData>(
                  future: loadWaveformData("loop.json"),
                  // future: loadWaveformData("test.json"),
                  builder: (context, AsyncSnapshot<WaveformData> snapshot) {
                    if (snapshot.hasData) {
                      return LayoutBuilder(
                          builder: (context, BoxConstraints constraints) {
                        // adjust the shape based on parent's orientation/shape
                        // the waveform should always be wider than taller
                        var height;
                        if (constraints.maxWidth < constraints.maxHeight) {
                          height = constraints.maxWidth;
                        } else {
                          height = constraints.maxHeight;
                        }

                        return ClipPath(
                          clipper: WaveformClipper(snapshot.data),
                          child: Container(
                            height: height,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                stops: [0.1, 0.3, 0.9],
                                colors: [
                                  Color(0xffffffff),
                                  Color(0xffffffff),
                                  Color(0xffffffff),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                    } else if (snapshot.hasError) {
                      return Text("Error ${snapshot.error}",
                          style: TextStyle(color: Colors.red));
                    }
                    return CircularProgressIndicator();
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class WaveformClipper extends CustomClipper<Path> {
  WaveformClipper(this.data);

  final WaveformData data;

  @override
  Path getClip(Size size) {
    return data.path(size);
  }

  @override
  bool shouldReclip(WaveformClipper oldClipper) {
    if (data != oldClipper.data) {
      return true;
    }
    return false;
  }
}
