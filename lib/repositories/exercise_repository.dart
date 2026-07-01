import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  List<Exercise> _exercises = [];

  Future<void> loadExercises() async {
    final String response = await rootBundle.loadString('assets/premium_exercises.json');
    final List<dynamic> data = json.decode(response);
    _exercises = data.map((json) => Exercise.fromJson(json)).toList();
  }

  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Exercise> getAllExercises() {
    return _exercises;
  }

  List<Exercise> getExercisesForMuscle(String muscleName) {
    // Mapeamento entre o nome do MuscleMap e os nomes no JSON
    final Map<String, String> muscleMapTarget = {
      'chest': 'chest',
      'upperChest': 'chest',
      'lowerChest': 'chest',
      'frontDeltoid': 'shoulders',
      'deltoids': 'shoulders',
      'biceps': 'biceps',
      'triceps': 'triceps',
      'forearm': 'forearms',
      'abs': 'abdominals',
      'upperAbs': 'abdominals',
      'lowerAbs': 'abdominals',
      'obliques': 'abdominals',
      'quadriceps': 'quadriceps',
      'innerQuad': 'quadriceps',
      'outerQuad': 'quadriceps',
      'calves': 'calves',
      'hamstrings': 'hamstrings',
      'hamstring': 'hamstrings',
      'glutes': 'glutes',
      'gluteal': 'glutes',
      'trapezius': 'traps',
      'lats': 'lats',
      'upperBack': 'lats',
      'lowerBack': 'lower back',
      'middleBack': 'middle back'
    };

    final target = muscleMapTarget[muscleName] ?? muscleName;

    return _exercises.where((ex) {
      return ex.primaryMuscles.contains(target) || ex.secondaryMuscles.contains(target);
    }).toList();
  }

  static final Map<String, List<String>> _jsonToSvgMuscles = {
    'shoulders': ['deltoids', 'frontDeltoid'],
    'abdominals': ['abs', 'upperAbs', 'lowerAbs', 'obliques'],
    'lats': ['upperBack'],
    'middle back': ['upperBack'],
    'lower back': ['lowerBack'],
    'glutes': ['gluteal'],
    'hamstrings': ['hamstring'],
    'quadriceps': ['quadriceps', 'innerQuad', 'outerQuad'],
    'chest': ['chest', 'upperChest', 'lowerChest'],
    'biceps': ['biceps'],
    'triceps': ['triceps'],
    'calves': ['calves'],
    'trapezius': ['trapezius'],
    'forearms': ['forearm'],
  };

  List<String> getMusclesForExercises(List<String> exerciseIds) {
    final Set<String> muscles = {};
    for (var id in exerciseIds) {
      try {
        final ex = _exercises.firstWhere((e) => e.id == id);
        for (var m in ex.primaryMuscles) {
          muscles.addAll(_jsonToSvgMuscles[m] ?? [m]);
        }
        for (var m in ex.secondaryMuscles) {
          muscles.addAll(_jsonToSvgMuscles[m] ?? [m]);
        }
      } catch (_) {}
    }
    return muscles.toList();
  }

  Map<String, int> getMuscleCountsForExercises(List<String> exerciseIds) {
    final Map<String, int> counts = {};
    for (var id in exerciseIds) {
      try {
        final ex = _exercises.firstWhere((e) => e.id == id);
        for (var m in ex.primaryMuscles) {
          final svgKeys = _jsonToSvgMuscles[m] ?? [m];
          for (var svgKey in svgKeys) {
            counts[svgKey] = (counts[svgKey] ?? 0) + 1;
          }
        }
      } catch (_) {}
    }
    return counts;
  }

  static String translateMuscle(String englishName) {
    final Map<String, String> ptBr = {
      'chest': 'Peito',
      'upperChest': 'Peito Superior',
      'lowerChest': 'Peito Inferior',
      'frontDeltoid': 'Ombro Frontal',
      'deltoids': 'Ombros',
      'biceps': 'Bíceps',
      'triceps': 'Tríceps',
      'forearm': 'Antebraço',
      'abs': 'Abdômen',
      'upperAbs': 'Abdômen Superior',
      'lowerAbs': 'Abdômen Inferior',
      'obliques': 'Oblíquos',
      'quadriceps': 'Quadríceps',
      'innerQuad': 'Vasto Medial (Perna)',
      'outerQuad': 'Vasto Lateral (Perna)',
      'calves': 'Panturrilhas',
      'hamstrings': 'Posterior de Coxa',
      'glutes': 'Glúteos',
      'trapezius': 'Trapézio',
      'lats': 'Costas (Dorsal)',
      'lowerBack': 'Lombar',
      'middleBack': 'Meio das Costas',
      'shoulders': 'Ombros',
      'abdominals': 'Abdômen'
    };
    return ptBr[englishName] ?? englishName;
  }

  static String translateEquipment(String englishName) {
    final Map<String, String> ptBr = {
      'body only': 'Peso do Corpo',
      'body weight': 'Peso do Corpo',
      'bodyweight': 'Peso do Corpo',
      'machine': 'Máquina',
      'other': 'Outro',
      'foam roll': 'Rolo de Espuma',
      'kettlebells': 'Kettlebell',
      'dumbbell': 'Halter',
      'cable': 'Polia/Cabo',
      'barbell': 'Barra',
      'bands': 'Elástico',
      'medicine ball': 'Bola Medicinal',
      'exercise ball': 'Bola Suíça',
      'e-z curl bar': 'Barra W'
    };
    return ptBr[englishName.toLowerCase()] ?? englishName;
  }

  static String translateLevel(String englishName) {
    final Map<String, String> ptBr = {
      'beginner': 'Iniciante',
      'intermediate': 'Intermediário',
      'expert': 'Avançado'
    };
    return ptBr[englishName.toLowerCase()] ?? englishName;
  }
}
