import 'dart:core';

import 'package:contextmonitoringapplication/database/symptom_db.dart';
import 'package:contextmonitoringapplication/model/symptom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SymptomLogger extends StatefulWidget {
  final int? heartRate, respiratoryRate;
  final Function(Symptom)? updateSymptoms;
  final Symptom? symptoms;

  const SymptomLogger(
      {super.key,
      this.heartRate,
      this.respiratoryRate,
      this.symptoms,
      this.updateSymptoms});

  @override
  State<SymptomLogger> createState() => _SymptomLoggerState();
}

class _SymptomLoggerState extends State<SymptomLogger> {
  late Map<String, dynamic> sList;

  @override
  void initState() {
    // print(widget.symptoms.toString());
    sList = {
      "nausea": Pair('Nausea', widget.symptoms!.nausea),
      "headache": Pair('Headache', widget.symptoms!.headache),
      "diarrhea": Pair('Diarrhea', widget.symptoms!.diarrhea),
      "sourThroat": Pair('Sour throat', widget.symptoms!.sourThroat),
      "fever": Pair('Fever', widget.symptoms!.fever),
      "muscleAche": Pair('Muscle ache', widget.symptoms!.muscleAche),
      "lossOfSmellOrTaste":
          Pair('Loss of smell or taste', widget.symptoms!.lossOfSmellOrTaste),
      "cough": Pair('Cough', widget.symptoms!.cough),
      "shortnessOfBreath":
          Pair('Shortness of breath', widget.symptoms!.shortnessOfBreath),
      "feelingTired": Pair('Feeling Tired', widget.symptoms!.feelingTired),
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Logger'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            for (var element in sList.keys) ...[
              const SizedBox(height: 10),
              Text(
                sList[element].label,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 5),
              RatingBar.builder(
                initialRating: sList[element].value.toDouble(),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  sList[element].value = rating.toInt();
                },
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ElevatedButton(
                onPressed: () async {
                  Symptom symptoms = Symptom(
                    createdTime: DateTime.now(),
                    heartRate: widget.heartRate ?? 0,
                    respiratoryRate: widget.respiratoryRate ?? 0,
                    nausea: sList['nausea'].value,
                    headache: sList['headache'].value,
                    diarrhea: sList['diarrhea'].value,
                    sourThroat: sList['sourThroat'].value,
                    fever: sList['fever'].value,
                    muscleAche: sList['muscleAche'].value,
                    lossOfSmellOrTaste: sList['lossOfSmellOrTaste'].value,
                    cough: sList['cough'].value,
                    shortnessOfBreath: sList['shortnessOfBreath'].value,
                    feelingTired: sList['feelingTired'].value,
                  );
                  widget.updateSymptoms!(symptoms);
                  await SymptomsDatabase.instance.create(symptoms);
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}