import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'muscle_map_widget.dart';
import 'models/treino.dart';
import 'models/exercise.dart';
import 'repositories/exercise_repository.dart';
import 'screens/create_treino_screen.dart';
import 'screens/workout_execution_screen.dart';
import 'widgets/exercise_image.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color appAccentColor = Color(0xFFC74383); // Magenta brilhante baseado na logo
const Color appDarkColor = Color(0xFF471A33); // Fundo vinho/magenta escuro da logo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TreinoApp());
}

class TreinoApp extends StatelessWidget {
  const TreinoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Treino Premium',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E212A),
        fontFamily: 'Montserrat',
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isMale = true;
  String? _selectedMuscle;
  
  List<Treino> _treinos = [];
  Treino? _selectedTreino;
  
  final ExerciseRepository _exerciseRepo = ExerciseRepository();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _exerciseRepo.loadExercises();
    
    // Login Seguro Anônimo do Firebase
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      debugPrint("Erro no login anônimo: \$e");
    }

    await _loadTreinos();
  }

  Future<void> _loadTreinos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('treinos')
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _treinos = snapshot.docs.map((doc) => Treino.fromMap(doc.data())).toList();
          _selectedTreino = _treinos.first;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar do Firestore: \$e");
    }
  }

  Future<void> _addTreinoToDb(Treino t) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('treinos')
        .doc(t.id)
        .set(t.toMap());
  }

  Future<void> _deleteTreinoFromDb(Treino t) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('treinos')
        .doc(t.id)
        .delete();
  }

  void _onMuscleTapped(String muscle) {
    setState(() {
      _selectedMuscle = muscle;
    });
    _showExerciciosParaMusculo(muscle);
  }

  Future<void> _navigateToCreateTreino() async {
    final Treino? novoTreino = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTreinoScreen(
          isMale: _isMale,
          repository: _exerciseRepo,
        ),
      ),
    );

    if (novoTreino != null) {
      setState(() {
        _treinos.add(novoTreino);
        _selectedTreino = novoTreino;
      });
      _addTreinoToDb(novoTreino);
    }
  }

  Future<void> _navigateToEditTreino(Treino treinoParaEditar) async {
    final Treino? treinoAtualizado = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTreinoScreen(
          isMale: _isMale,
          repository: _exerciseRepo,
          treinoParaEditar: treinoParaEditar,
        ),
      ),
    );

    if (treinoAtualizado != null) {
      setState(() {
        final index = _treinos.indexWhere((t) => t.id == treinoAtualizado.id);
        if (index != -1) {
          _treinos[index] = treinoAtualizado;
          if (_selectedTreino?.id == treinoAtualizado.id) {
            _selectedTreino = treinoAtualizado;
          }
        }
      });
      _addTreinoToDb(treinoAtualizado);
    }
  }

  void _deleteTreino(Treino treino) {
      setState(() {
        _treinos.remove(treino);
        if (_selectedTreino == treino) {
          _selectedTreino = _treinos.isNotEmpty ? _treinos.first : null;
        }
      });
      _deleteTreinoFromDb(treino);
  }

  void _showExerciciosParaMusculo(String muscle) {
    final exercises = _exerciseRepo.getExercisesForMuscle(muscle);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.bottomCenter,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white24,
              Colors.white12,
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white54,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Exercícios: ${ExerciseRepository.translateMuscle(muscle).toUpperCase()}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: exercises.isEmpty 
                  ? const Center(child: Text("Nenhum exercício encontrado.", style: TextStyle(color: Colors.white70)))
                  : ListView.builder(
                      controller: controller,
                      itemCount: exercises.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, index) {
                        final ex = exercises[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 100 * index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ExerciseImage(
                                  gifUrl: ex.gifUrl,
                                  images: ex.images,
                                  width: 60,
                                  height: 60,
                                ),
                              ),
                              title: Text(
                                ex.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              subtitle: Text(
                                '${ex.equipment} • ${ex.level}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.play_circle_fill, color: appAccentColor, size: 30),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: ExerciseImage(
                                          gifUrl: ex.gifUrl,
                                          images: ex.images,
                                          height: 200,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho e Switch de Gênero
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SEU CORPO',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: appAccentColor,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Mapa Muscular',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _isMale = true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isMale ? appAccentColor.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isMale ? appAccentColor : Colors.transparent,
                              ),
                            ),
                            child: const Text('Masculino', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _isMale = false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: !_isMale ? appAccentColor.withOpacity(0.2) : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: !_isMale ? appAccentColor : Colors.transparent,
                              ),
                            ),
                            child: const Text('Feminino', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // LISTA HORIZONTAL DE TREINOS (A, B, C...)
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  ..._treinos.map((treino) {
                    final isSelected = _selectedTreino?.id == treino.id;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTreino = isSelected ? null : treino;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? appAccentColor.withOpacity(0.2) : Colors.black45,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: isSelected ? appAccentColor : Colors.white12,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected ? [
                            BoxShadow(color: appAccentColor.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
                          ] : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              treino.nome,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _navigateToEditTreino(treino),
                                child: const Icon(Icons.edit, color: Colors.white70, size: 18),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _deleteTreino(treino),
                                child: const Icon(Icons.delete, color: Colors.redAccent, size: 18),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  GestureDetector(
                    onTap: _navigateToCreateTreino,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC74383), Color(0xFFF06292)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFC74383).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 18),
                          SizedBox(width: 5),
                          Text('Criar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // O AVATAR MUSCULAR INTERATIVO E VETORIAL
            Expanded(
              child: FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Center(
                  child: MuscleMapWidget(
                    isMale: _isMale,
                    highlightedMuscles: _selectedTreino != null 
                        ? _exerciseRepo.getMusclesForExercises(_selectedTreino!.exerciseIds)
                        : [],
                    onMuscleTapped: (muscle) {
                      _onMuscleTapped(muscle);
                    },
                  ),
                ),
              ),
            ),
            
            // Call to Action Inferior
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: _selectedTreino == null 
                ? const Text(
                    'Selecione ou crie um Treino para começar.',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  )
                : FadeInUp(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: appAccentColor,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 8,
                        shadowColor: appAccentColor.withOpacity(0.5),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => WorkoutExecutionScreen(
                              treino: _selectedTreino!,
                              repository: _exerciseRepo,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                      label: const Text(
                        'INICIAR TREINO',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.5),
                      ),
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
