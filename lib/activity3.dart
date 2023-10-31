import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Activity3 extends StatefulWidget {
  const Activity3({super.key});

  @override
  State<Activity3> createState() => _SymptomLoggerState();
}

class _SymptomLoggerState extends State<Activity3> {
  double avgSpeed = 0.0;
  double idealSpeed = 0.0;
  late TextEditingController _destLongitudeController;
  late TextEditingController _destLatitudeController;
  late TextEditingController _srcLongitudeController;
  late TextEditingController _srcLatitudeController;

  @override
  void initState() {
    super.initState();
    _destLongitudeController = TextEditingController();
    _destLatitudeController = TextEditingController();
    _srcLongitudeController = TextEditingController();
    _srcLatitudeController = TextEditingController();
  }

  @override
  void dispose() {
    _destLongitudeController.dispose();
    _destLatitudeController.dispose();
    _srcLongitudeController.dispose();
    _srcLatitudeController.dispose();
    super.dispose();
  }

  void displayDialog(title, description) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 3'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _srcLongitudeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter source longitude',
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _srcLatitudeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter source latitude',
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _destLongitudeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter destination longitude',
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _destLatitudeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter destination latitude',
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: ElevatedButton(
                  child: const Text("Get data"),
                  onPressed: () async {
                    if (_destLongitudeController.text == "" ||
                        _destLatitudeController.text == "" ||
                        _srcLatitudeController.text == "" ||
                        _srcLongitudeController.text == "") {
                      displayDialog(
                          "Fill in missing fields", "Fill in missing fields");
                    } else {
                      final response = await http.get(Uri.parse(
                          'https://maps.googleapis.com/maps/api/distancematrix/json?departure_time=now&destinations=${_destLongitudeController.text}%2C${_destLatitudeController.text}8&origins=${_srcLongitudeController.text}%2C${_srcLatitudeController.text}&key=AIzaSyBzi30ZbW41zmnaKnW6FNCJUFMyHUaqs1E'));
                      if (response.statusCode == 200) {
                        final data =
                            jsonDecode(response.body) as Map<String, dynamic>;
                        if (data["rows"][0]["elements"][0]["status"] ==
                            "ZERO_RESULTS") {
                          displayDialog("No data found", "No data found");
                        } else {
                          final values = data["rows"][0]["elements"][0];
                          setState(() {
                            avgSpeed = values["distance"]["value"] *
                                3.6 /
                                values["duration_in_traffic"]["value"];
                            idealSpeed = values["distance"]["value"] *
                                3.6 /
                                values["duration"]["value"];
                          });
                        }
                      } else {
                        displayDialog("Error occurred while fetching API",
                            "Error occurred while fetching API");
                      }
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
                            "Average speed: ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Text('${avgSpeed.toString()} km/h'),
                        ],
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
                            "Ideal speed: ",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                          Text('${idealSpeed.toString()} km/h'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}