import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:async';
import '../models/treino.dart';
import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';
import '../widgets/exercise_image.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final Treino treino;
  final ExerciseRepository repository;

  const WorkoutExecutionScreen({
    Key? key,
    required this.treino,
    required this.repository,
  }) : super(key: key);

  @override
  _WorkoutExecutionScreenState createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  final Set<String> _completedExercises = {};
  List<Exercise> _exercises = [];
  
  // Timer State
  Timer? _restTimer;
  int _restSeconds = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    // The repository should have a way to fetch exercises by ID, 
    // but right now it only has getExercisesForMuscle.
    // Let's implement a quick workaround or assume we added getExerciseById.
    // Actually, I will add getExerciseById to the repository later.
    _exercises = widget.treino.exerciseIds.map((id) {
      return widget.repository.getExerciseById(id);
    }).whereType<Exercise>().toList();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRestTimer(int seconds) {
    setState(() {
      _isResting = true;
      _restSeconds = seconds;
    });

    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_restSeconds > 0) {
        setState(() {
          _restSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isResting = false;
        });
      }
    });
  }

  String get _formattedTime {
    final m = (_restSeconds / 60).floor();
    final s = _restSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _exercises.isEmpty ? 0 : _completedExercises.length / _exercises.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.treino.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Progresso', style: TextStyle(color: Colors.white70)),
                    Text('${(_completedExercises.length)} / ${_exercises.length}', 
                      style: const TextStyle(color: Color(0xFFC74383), fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC74383)),
                  ),
                ),
              ],
            ),
          ),

          // Rest Timer Banner
          if (_isResting)
            FadeInDown(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF471A33).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFC74383).withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Color(0xFFC74383)),
                        const SizedBox(width: 10),
                        Text('Descanso...', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text(_formattedTime, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () {
                        setState(() {
                          _isResting = false;
                          _restTimer?.cancel();
                        });
                      },
                    )
                  ],
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final ex = _exercises[index];
                final isDone = _completedExercises.contains(ex.id);

                return FadeInUp(
                  delay: Duration(milliseconds: 50 * index),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isDone) {
                          _completedExercises.remove(ex.id);
                        } else {
                          _completedExercises.add(ex.id);
                          // Auto start rest timer when an exercise is marked as done
                          _startRestTimer(60); 
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDone ? Colors.green.withOpacity(0.1) : const Color(0xFF2A2D3A),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isDone ? Colors.green.withOpacity(0.5) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                            child: Opacity(
                              opacity: isDone ? 0.5 : 1.0,
                              child: ExerciseImage(
                                gifUrl: ex.gifUrl,
                                images: ex.images,
                                width: 90,
                                height: 90,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ex.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDone ? Colors.white54 : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  '3 Séries x 10 a 15 Reps',
                                  style: TextStyle(color: Colors.white54, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Icon(
                              isDone ? Icons.check_circle : Icons.circle_outlined,
                              color: isDone ? Colors.green : Colors.white24,
                              size: 30,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: progress == 1.0
          ? FadeInUp(
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.pop(context); // Finaliza treino
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🎉 Treino concluído com sucesso!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                backgroundColor: const Color(0xFFC74383),
                icon: const Icon(Icons.celebration, color: Colors.white),
                label: const Text('FINALIZAR TREINO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
