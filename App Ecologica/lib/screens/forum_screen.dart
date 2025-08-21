import 'package:flutter/material.dart';
import 'package:iguanosquad/screens/answer_screen.dart';
import 'package:iguanosquad/widgets/question_card.dart';
import 'package:iguanosquad/widgets/new_question_dialog.dart';
import 'package:iguanosquad/models/Preguntas.dart';
import 'package:iguanosquad/services/preguntas_service.dart';
import 'dart:async'; // Importar para usar Timer

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final _service = PreguntasService();
  List<Pregunta> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer; // Agregar el Timer

  @override
  void initState() {
    super.initState();
    _loadAllQuestions();
    _startAutoRefresh(); // Llamar a la función que configura el Timer
  }

  // Función que carga las preguntas
  Future<void> _loadAllQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final preguntas = await _service.obtenerResumenPreguntas();
      setState(() => _questions = preguntas);
    } catch (e) {
      setState(() => _errorMessage = 'Error cargando preguntas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Función que inicia el Timer para recargar los datos automáticamente
  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      await _loadAllQuestions(); // Actualizar las preguntas cada 30 segundos
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancelar el Timer cuando se destruya el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadAllQuestions,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: false,
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Foro de Preguntas'),
                background: Container(
                  color: Theme.of(context).primaryColor,
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.all(5),
                  child: const Text(
                    'Resuelve tus dudas sobre temas ecológicos',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            if (_isLoading)
              SliverFillRemaining(
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (_questions.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('No hay preguntas disponibles')),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final pregunta = _questions[i];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AnswerScreen(
                              question: _questions[i],
                            ),
                          ),
                        ).then((_) async {
                          // Después de que el usuario regrese de la pantalla de respuestas, recargamos las preguntas.
                          await _loadAllQuestions();
                        });
                      },
                      child: QuestionCard(question: pregunta),
                    );
                  },
                  childCount: _questions.length,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => NewQuestionDialog(
              onSubmit: (texto) async {
                await _service.crearPregunta(texto);
                await _loadAllQuestions();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
