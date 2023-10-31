import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:contextmonitoringapplication/activity3.dart';
import 'package:contextmonitoringapplication/database/symptom_db.dart';
import 'package:contextmonitoringapplication/model/symptom.dart';
import 'package:contextmonitoringapplication/symptom_logger.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wakelock/wakelock.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AccelerometerEvent> accelerometerEventsList = [];
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;
  bool _toggled = false, _rrToggle = false;
  final List<SensorValue> _data = [];
  CameraController? _controller;
  final double _alpha = 0.3;
  int _bpm = 0; // beats per minute
  int _rr = 0;
  final int _fs = 30;
  final int _windowLen = 30 * 6;
  CameraImage? _image;
  double _avg = 0.0;
  DateTime _now = DateTime.timestamp();
  Timer? _timer;
  Symptom symptoms = Symptom(
    createdTime: DateTime.now(),
    heartRate: 0,
    respiratoryRate: 0,
    nausea: 0,
    headache: 0,
    diarrhea: 0,
    sourThroat: 0,
    fever: 0,
    muscleAche: 0,
    lossOfSmellOrTaste: 0,
    cough: 0,
    shortnessOfBreath: 0,
    feelingTired: 0,
  );

  @override
  void dispose() {
    _timer?.cancel();
    _toggled = false;
    _disposeController();
    Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(18),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: <Widget>[
                            _controller != null && _toggled
                                ? AspectRatio(
                                    aspectRatio: _controller!.value.aspectRatio,
                                    child: CameraPreview(_controller!),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(12),
                                    alignment: Alignment.center,
                                    color: Colors.grey,
                                  ),
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                _toggled
                                    ? "Cover both the camera and the flash with your finger"
                                    : "Camera feed will display here",
                                style: TextStyle(
                                  backgroundColor: _toggled
                                      ? Colors.white
                                      : Colors.transparent,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Estimated BPM",
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          Text(
                            (_bpm > 30 && _bpm < 200 ? _bpm.toString() : "--"),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: ElevatedButton(
                  child: Text(_toggled
                      ? 'Measuring heart rate...'
                      : 'Measure heart rate'),
                  onPressed: () {
                    if (!_toggled) {
                      _toggle();
                      _timer = Timer(
                        const Duration(seconds: 45),
                        () {
                          _unToggle();
                        },
                      );
                    }
                  },
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "Estimated respiratory rate",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            (_rr > 5 && _rr < 500 ? _rr.toString() : "--"),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: ElevatedButton(
                        child: Text(
                          _rrToggle
                              ? 'Measuring respiratory rate..'
                              : 'Measure respiratory rate',
                        ),
                        onPressed: () {
                          if (!_rrToggle) {
                            setState(() {
                              _rrToggle = true;
                            });
                            accelerometerSubscription =
                                accelerometerEvents.listen(
                              (event) {
                                setState(
                                  () {
                                    accelerometerEventsList.add(event);
                                  },
                                );
                              },
                            );
                            // Set a timer to stop the accelerometer events after 45 seconds
                            _timer = Timer(
                              const Duration(seconds: 45),
                              () {
                                accelerometerSubscription!.cancel();
                                callRespiratoryCalculator(
                                  accelerometerEventsList,
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: ElevatedButton(
                        child: const Text('Symptom'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => SymptomLogger(
                                heartRate: _bpm,
                                respiratoryRate: _rr,
                                symptoms: symptoms,
                                updateSymptoms: updateSymptoms,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: ElevatedButton(
                        child: const Text('Upload Signs'),
                        onPressed: () async {
                          Symptom tmp = Symptom(
                            createdTime: DateTime.now(),
                            heartRate: _bpm,
                            respiratoryRate: _rr,
                            nausea: symptoms.nausea,
                            headache: symptoms.headache,
                            diarrhea: symptoms.diarrhea,
                            sourThroat: symptoms.sourThroat,
                            fever: symptoms.fever,
                            muscleAche: symptoms.muscleAche,
                            lossOfSmellOrTaste: symptoms.lossOfSmellOrTaste,
                            cough: symptoms.cough,
                            shortnessOfBreath: symptoms.shortnessOfBreath,
                            feelingTired: symptoms.feelingTired,
                          );
                          await SymptomsDatabase.instance.create(tmp);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: ElevatedButton(
                  child: const Text('Show activity 3'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (builder) => const Activity3(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateSymptoms(Symptom updatedSymptom) {
    setState(() {
      symptoms = updatedSymptom;
    });
  }

  int callRespiratoryCalculator(
      List<AccelerometerEvent> accelerometerEventsList) {
    double previousValue = 0.0;
    double currentValue = 0.0;
    previousValue = 10.0;
    int k = 0;
    for (int i = 0; i < accelerometerEventsList.length; i++) {
      currentValue = sqrt(
        pow(accelerometerEventsList[i].x, 2.0) +
            pow(accelerometerEventsList[i].y, 2.0) +
            pow(accelerometerEventsList[i].z, 2.0),
      ).toDouble();
      if ((previousValue - currentValue).abs() > 0.15) {
        k++;
      }
      previousValue = currentValue;
    }
    final ret = k / 45.0;
    setState(() {
      _rr = (ret * 30).toInt();
      _rrToggle = false;
      accelerometerEventsList.clear();
    });
    return (ret * 30).toInt();
  }

  void _clearData() {
    // create array of 128 ~= 255/2
    _data.clear();
    int now = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < _windowLen; i++) {
      _data.insert(
        0,
        SensorValue(
            DateTime.fromMillisecondsSinceEpoch(now - i * 1000 ~/ _fs), 128),
      );
    }
  }

  void _toggle() {
    _clearData();
    _initController().then((onValue) {
      Wakelock.enable();
      setState(() {
        _toggled = true;
      });
      // after is toggled
      _initTimer();
      _updateBPM();
    });
  }

  void _unToggle() {
    _disposeController();
    Wakelock.disable();
    setState(() {
      _toggled = false;
    });
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  Future<void> _initController() async {
    try {
      List cameras = await availableCameras();
      _controller = CameraController(cameras.first, ResolutionPreset.max);
      await _controller!.initialize();
      // Future.delayed(const Duration(milliseconds: 100)).then((onValue) {
      //
      // });
      _controller!.setFlashMode(FlashMode.torch);
      _controller!.startImageStream((CameraImage image) {
        _image = image;
      });
      // ignore: empty_catches
    } on Exception {}
  }

  void _initTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 1000 ~/ _fs), (timer) {
      if (_toggled) {
        if (_image != null) _scanImage(_image!);
      } else {
        timer.cancel();
      }
    });
  }

  void _scanImage(CameraImage image) {
    _now = DateTime.now();
    _avg =
        image.planes.first.bytes.reduce((value, element) => value + element) /
            image.planes.first.bytes.length;
    if (_data.length >= _windowLen) {
      _data.removeAt(0);
    }
    setState(() {
      _data.add(SensorValue(_now, 255 - _avg));
    });
  }

  void _updateBPM() async {
    List<SensorValue> values;
    double avg;
    int n;
    double m;
    double threshold;
    double bpm;
    int counter;
    int previous;
    while (_toggled) {
      values = List.from(_data); // create a copy of the current data array
      avg = 0;
      n = values.length;
      m = 0;
      for (var value in values) {
        avg += value.value / n;
        if (value.value > m) m = value.value;
      }
      threshold = (m + avg) / 2;
      bpm = 0;
      counter = 0;
      previous = 0;
      for (int i = 1; i < n; i++) {
        if (values[i - 1].value < threshold && values[i].value > threshold) {
          if (previous != 0) {
            counter++;
            bpm +=
                60 * 1000 / (values[i].time.millisecondsSinceEpoch - previous);
          }
          previous = values[i].time.millisecondsSinceEpoch;
        }
      }
      if (counter > 0) {
        bpm = bpm / counter;
        // print(_bpm);
        setState(() {
          _bpm = ((1 - _alpha) * _bpm + _alpha * bpm).toInt();
        });
      }
      await Future.delayed(Duration(
          milliseconds:
              1000 * _windowLen ~/ _fs)); // wait for a new set of _data values
    }
  }
}