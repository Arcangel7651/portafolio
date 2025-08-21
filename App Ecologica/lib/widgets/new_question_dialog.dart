import 'package:flutter/material.dart';

typedef OnSubmitQuestion = Future<void> Function(String questionText);

class NewQuestionDialog extends StatefulWidget {
  final OnSubmitQuestion onSubmit;

  const NewQuestionDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _NewQuestionDialogState createState() => _NewQuestionDialogState();
}

class _NewQuestionDialogState extends State<NewQuestionDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit(text);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Pregunta'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Escribe tu pregunta aquí…',
        ),
        maxLines: 4,
        enabled: !_isSubmitting,
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Publicar'),
        ),
      ],
    );
  }
}
