import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/Preguntas.dart';
import '../models/respuesta.dart';
import '../widgets/respuesta_service.dart';

class AnswerScreen extends StatefulWidget {
  final Pregunta question;

  const AnswerScreen({Key? key, required this.question}) : super(key: key);

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final _answerController = TextEditingController();
  final _service = RespuestasService();

  List<Respuesta> _answers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final lista =
          await _service.obtenerRespuestas(widget.question.idPregunta);
      setState(() => _answers = lista);
    } catch (e) {
      setState(() => _error = 'Error cargando respuestas: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitAnswer() async {
    final text = _answerController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _service.crearRespuesta(widget.question.idPregunta, text);
      _answerController.clear();
      await _loadAnswers();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fecha =
        DateFormat('dd/MM/yyyy – HH:mm').format(widget.question.fecha);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar
          SliverAppBar(
            floating: true,
            snap: true,
            pinned: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Destalles pregunta'),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(color: Theme.of(context).primaryColor),
            ),
          ),
          // Detalle de la pregunta
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.question.pregunta,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.question.nombreUsuario ?? 'Anónimo'} · $fecha',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Divider(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de respuestas
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _buildAnswerItem(_answers[i]),
              childCount: _answers.length,
            ),
          ),
        ],
      ),

      // Entrada de nueva respuesta
      bottomSheet: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _answerController,
                decoration: const InputDecoration(
                  hintText: 'Escribe tu respuesta...',
                  border: OutlineInputBorder(),
                ),
                minLines: 1,
                maxLines: 3,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _submitAnswer,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerItem(Respuesta resp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  resp.nombreUsuario ?? 'Anónimo',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(resp.respuesta),
        ],
      ),
    );
  }
}
