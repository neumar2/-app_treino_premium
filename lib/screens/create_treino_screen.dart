import 'package:flutter/material.dart';
import '../muscle_map_widget.dart';
import '../models/treino.dart';
import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';
import '../widgets/exercise_image.dart';

class CreateTreinoScreen extends StatefulWidget {
  final bool isMale;
  final ExerciseRepository repository;
  final Treino? treinoParaEditar;

  const CreateTreinoScreen({
    Key? key,
    required this.isMale,
    required this.repository,
    this.treinoParaEditar,
  }) : super(key: key);

  @override
  _CreateTreinoScreenState createState() => _CreateTreinoScreenState();
}

class _CreateTreinoScreenState extends State<CreateTreinoScreen> {
  late TextEditingController _nameController;
  List<String> _selectedExerciseIds = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.treinoParaEditar?.nome ?? '');
    if (widget.treinoParaEditar != null) {
      _selectedExerciseIds = List.from(widget.treinoParaEditar!.exerciseIds);
    }
  }

  Map<String, int> get _muscleCounts {
    return widget.repository.getMuscleCountsForExercises(_selectedExerciseIds);
  }

  // Descobre quais mÃºsculos estÃ£o ativos baseado nos exercÃ­cios selecionados
  List<String> get _highlightedMuscles {
    final Set<String> muscles = {};
    for (String id in _selectedExerciseIds) {
      // Procura o exercÃ­cio no repositÃ³rio
      // (Em um app real, _repository poderia ter um getExerciseById)
      final allEx = widget.repository.getExercisesForMuscle('chest'); // Gambiarra? NÃ£o, nÃ£o dÃ¡.
    }
    return muscles.toList();
  }
  
  // Vamos criar um mÃ©todo para pegar todos os exercÃ­cios
  List<String> _calculateActiveMuscles() {
    final Set<String> active = {};
    // Pegar todos os exercÃ­cios (como o repositÃ³rio nÃ£o expoÃµe todos diretamente, 
    // podemos sÃ³ pegar todos de uma lista se ele expor, ou criar um mÃ©todo).
    // Como nÃ£o modifiquei o repositÃ³rio para exportar todos, posso iterar a pesquisa ou
    // simplesmente modificar o repositÃ³rio!
    return active.toList();
  }

  void _openExerciseSelector(String muscleName) {
    String selectedEquipment = 'Todos';
    String selectedLevel = 'Todos';
    final equipmentOptions = ['Todos', 'Halter', 'Barra', 'Peso do Corpo', 'Máquina', 'Polia/Cabo'];
    final levelOptions = ['Todos', 'Iniciante', 'Intermediário', 'Avançado'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder para atualizar os ícones de + e -
          builder: (BuildContext context, StateSetter setModalState) {
            final allExercises = widget.repository.getExercisesForMuscle(muscleName);
            final exercises = allExercises.where((ex) {
              final eqMatch = selectedEquipment == 'Todos' || ExerciseRepository.translateEquipment(ex.equipment) == selectedEquipment;
              final lvlMatch = selectedLevel == 'Todos' || ExerciseRepository.translateLevel(ex.level) == selectedLevel;
              return eqMatch && lvlMatch;
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E212A),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Adicionar Exercícios: ${ExerciseRepository.translateMuscle(muscleName).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: equipmentOptions.map((eq) {
                            final isSelected = selectedEquipment == eq;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(eq),
                                selected: isSelected,
                                selectedColor: const Color(0xFFC74383),
                                backgroundColor: Colors.black45,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (bool selected) {
                                  setModalState(() {
                                    selectedEquipment = eq;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: levelOptions.map((lvl) {
                            final isSelected = selectedLevel == lvl;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(lvl),
                                selected: isSelected,
                                selectedColor: const Color(0xFFC74383),
                                backgroundColor: Colors.black45,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                onSelected: (bool selected) {
                                  setModalState(() {
                                    selectedLevel = lvl;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: exercises.isEmpty
                            ? const Center(child: Text("Nenhum exercÃ­cio encontrado.", style: TextStyle(color: Colors.white54)))
                            : ListView.builder(
                                controller: controller,
                                itemCount: exercises.length,
                                itemBuilder: (context, index) {
                                  final ex = exercises[index];
                                  final isSelected = _selectedExerciseIds.contains(ex.id);
                                  
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: ExerciseImage(
                                        gifUrl: ex.gifUrl,
                                        images: ex.images,
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                    title: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    subtitle: Text('${ExerciseRepository.translateEquipment(ex.equipment)} • ${ExerciseRepository.translateLevel(ex.level)}', style: const TextStyle(color: Colors.white54)),
                                    trailing: IconButton(
                                      icon: Icon(
                                        isSelected ? Icons.check_circle : Icons.add_circle_outline,
                                        color: isSelected ? const Color(0xFFC74383) : Colors.white54,
                                        size: 30,
                                      ),
                                      onPressed: () {
                                        setModalState(() {
                                          if (isSelected) {
                                            _selectedExerciseIds.remove(ex.id);
                                          } else {
                                            _selectedExerciseIds.add(ex.id);
                                          }
                                        });
                                        // Atualiza a tela principal atrÃ¡s do bottom sheet tambÃ©m
                                        setState(() {});
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        );
      },
    );
  }

  void _saveTreino() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, dÃª um nome ao treino.')),
      );
      return;
    }
    if (_selectedExerciseIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um exercÃ­cio tocando no boneco.')),
      );
      return;
    }
    final newTreino = Treino(
      id: widget.treinoParaEditar?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nome: _nameController.text.trim(),
      exerciseIds: _selectedExerciseIds,
    );

    Navigator.of(context).pop(newTreino);
  }

  @override
  Widget build(BuildContext context) {
    // Calcula os músculos a serem acesos baseado nos exercícios adicionados
    final highlightedMuscles = widget.repository.getMusclesForExercises(_selectedExerciseIds);
    
    return Scaffold(
      backgroundColor: const Color(0xFF1E212A),
      body: Stack(
        children: [
          // 1. O Avatar Gigante no Fundo
          Positioned.fill(
            top: 100, // Espaço para o cabeçalho
            bottom: 120, // Espaço para a barra inferior
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              child: Center(
                child: MuscleMapWidget(
                  isMale: widget.isMale,
                  highlightedMuscles: highlightedMuscles,
                  selectionMode: true, // Mantém os músculos acesos
                  muscleCounts: _muscleCounts,
                  onMuscleTapped: _openExerciseSelector,
                ),
              ),
            ),
          ),

          // 2. AppBar Transparente e Campo de Nome
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const BackButton(color: Colors.white),
                        Expanded(
                          child: Text(
                            widget.treinoParaEditar == null ? 'CRIAR TREINO' : 'EDITAR TREINO',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance for BackButton
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'Nome do Treino (Ex: Costas)',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.black45,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // 3. Painel Inferior Deslizante com os Exercícios Selecionados
          DraggableScrollableSheet(
            initialChildSize: 0.15,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3A).withOpacity(0.95),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white30, borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Exercícios Selecionados ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFC74383), borderRadius: BorderRadius.circular(10)),
                          child: Text('${_selectedExerciseIds.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _selectedExerciseIds.isEmpty
                          ? const Center(child: Text('Arraste para cima para ver a lista.\nToque no boneco para adicionar.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)))
                          : Theme(
                              data: Theme.of(context).copyWith(
                                canvasColor: Colors.transparent, // Remove background when dragging
                              ),
                              child: ReorderableListView.builder(
                                scrollController: scrollController,
                                padding: const EdgeInsets.only(bottom: 80), // Espaço pro FAB
                                itemCount: _selectedExerciseIds.length,
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) {
                                      newIndex -= 1;
                                    }
                                    final item = _selectedExerciseIds.removeAt(oldIndex);
                                    _selectedExerciseIds.insert(newIndex, item);
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final id = _selectedExerciseIds[index];
                                  final ex = widget.repository.getExerciseById(id);
                                  if (ex == null) return SizedBox(key: ValueKey(id));
                                  return Container(
                                    key: ValueKey(id),
                                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: Colors.white12),
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: ExerciseImage(gifUrl: ex.gifUrl, images: ex.images, width: 50, height: 50),
                                      ),
                                      title: Text(ex.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                                            onPressed: () {
                                              setState(() {
                                                _selectedExerciseIds.remove(id);
                                              });
                                            },
                                          ),
                                          const Icon(Icons.drag_handle, color: Colors.white54),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTreino,
        backgroundColor: const Color(0xFFC74383),
        label: Text(widget.treinoParaEditar == null ? 'SALVAR TREINO' : 'ATUALIZAR', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }
}
