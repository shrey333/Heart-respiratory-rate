const String tableSymptoms = 'symptoms';

class Pair {
  String label;
  int value;

  Pair(this.label, this.value);
}

class SensorValue {
  DateTime time;
  double value;

  SensorValue(this.time, this.value);
}

class SymptomFields {
  static final List<String> values = [
    /// Add all fields
    id,
    createdTime,
    heartRate,
    respiratoryRate,
    nausea,
    headache,
    diarrhea,
    sourThroat,
    fever,
    muscleAche,
    lossOfSmellOrTaste,
    cough,
    shortnessOfBreath,
    feelingTired,
  ];

  static const String id = '_id';
  static const String createdTime = 'createdTime';
  static const String heartRate = 'heartRate';
  static const String respiratoryRate = 'respiratoryRate';
  static const String nausea = 'nausea';
  static const String headache = 'headache';
  static const String diarrhea = 'diarrhea';
  static const String sourThroat = 'sourThroat';
  static const String fever = 'fever';
  static const String muscleAche = 'muscleAche';
  static const String lossOfSmellOrTaste = 'lossOfSmellOrTaste';
  static const String cough = 'cough';
  static const String shortnessOfBreath = 'shortnessOfBreath';
  static const String feelingTired = 'feelingTired';
}

class Symptom {
  final int? id;
  final DateTime createdTime;
  final int heartRate;
  final int respiratoryRate;
  final int nausea;
  final int headache;
  final int diarrhea;
  final int sourThroat;
  final int fever;
  final int muscleAche;
  final int lossOfSmellOrTaste;
  final int cough;
  final int shortnessOfBreath;
  final int feelingTired;

  const Symptom({
    this.id,
    required this.createdTime,
    required this.heartRate,
    required this.respiratoryRate,
    required this.nausea,
    required this.headache,
    required this.diarrhea,
    required this.sourThroat,
    required this.fever,
    required this.muscleAche,
    required this.lossOfSmellOrTaste,
    required this.cough,
    required this.shortnessOfBreath,
    required this.feelingTired,
  });

  Symptom copy({
    int? id,
    DateTime? createdTime,
    int? heartRate,
    int? respiratoryRate,
    int? nausea,
    int? headache,
    int? diarrhea,
    int? sourThroat,
    int? fever,
    int? muscleAche,
    int? lossOfSmellOrTaste,
    int? cough,
    int? shortnessOfBreath,
    int? feelingTired,
  }) =>
      Symptom(
        id: id ?? this.id,
        createdTime: createdTime ?? this.createdTime,
        heartRate: heartRate ?? this.heartRate,
        respiratoryRate: respiratoryRate ?? this.respiratoryRate,
        nausea: nausea ?? this.nausea,
        headache: headache ?? this.headache,
        diarrhea: diarrhea ?? this.diarrhea,
        sourThroat: sourThroat ?? this.sourThroat,
        fever: fever ?? this.fever,
        muscleAche: muscleAche ?? this.muscleAche,
        lossOfSmellOrTaste: lossOfSmellOrTaste ?? this.lossOfSmellOrTaste,
        cough: cough ?? this.cough,
        shortnessOfBreath: shortnessOfBreath ?? this.shortnessOfBreath,
        feelingTired: feelingTired ?? this.feelingTired,
      );

  static Symptom fromJson(Map<String, Object?> json) => Symptom(
        id: json[SymptomFields.id] as int?,
        createdTime: DateTime.parse(json[SymptomFields.createdTime] as String),
        heartRate: json[SymptomFields.heartRate] as int,
        respiratoryRate: json[SymptomFields.respiratoryRate] as int,
        nausea: json[SymptomFields.nausea] as int,
        headache: json[SymptomFields.headache] as int,
        diarrhea: json[SymptomFields.diarrhea] as int,
        sourThroat: json[SymptomFields.sourThroat] as int,
        fever: json[SymptomFields.fever] as int,
        muscleAche: json[SymptomFields.muscleAche] as int,
        lossOfSmellOrTaste: json[SymptomFields.lossOfSmellOrTaste] as int,
        cough: json[SymptomFields.cough] as int,
        shortnessOfBreath: json[SymptomFields.shortnessOfBreath] as int,
        feelingTired: json[SymptomFields.feelingTired] as int,
      );

  Map<String, Object?> toJson() => {
        SymptomFields.id: id,
        SymptomFields.createdTime: createdTime.toIso8601String(),
        SymptomFields.heartRate: heartRate,
        SymptomFields.respiratoryRate: respiratoryRate,
        SymptomFields.nausea: nausea,
        SymptomFields.headache: headache,
        SymptomFields.diarrhea: diarrhea,
        SymptomFields.sourThroat: sourThroat,
        SymptomFields.fever: fever,
        SymptomFields.muscleAche: muscleAche,
        SymptomFields.lossOfSmellOrTaste: lossOfSmellOrTaste,
        SymptomFields.cough: cough,
        SymptomFields.shortnessOfBreath: shortnessOfBreath,
        SymptomFields.feelingTired: feelingTired,
      };

  @override
  String toString() {
    return 'Symptom{id: $id, createdTime: $createdTime, heartRate: $heartRate, respiratoryRate: $respiratoryRate, nausea: $nausea, headache: $headache, diarrhea: $diarrhea, sourThroat: $sourThroat, fever: $fever, muscleAche: $muscleAche, lossOfSmellOrTaste: $lossOfSmellOrTaste, cough: $cough, shortnessOfBreath: $shortnessOfBreath, feelingTired: $feelingTired}';
  }
}