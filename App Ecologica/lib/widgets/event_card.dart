// lib/widgets/event_card.dart

import 'package:flutter/material.dart';
import 'package:iguanosquad/services/actividad_service.dart';
import 'package:path/path.dart' as path; // si lo necesitas más adelante
import '../screens/edit_event_screen.dart';

class EventCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String location;
  final String description;
  final int id;
  final String imageURL;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventCard({
    super.key,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
    required this.id,
    this.onEdit,
    this.onDelete,
    required this.imageURL,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${date.day} de ${_spanishMonth(date.month)}, ${date.year}';
    final isActive = !hasDatePassed();
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior:
          Clip.hardEdge, // Para que el ClipRRect de la imagen funcione bien
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ───── Imagen ─────
          if (imageURL.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                imageURL,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (ctx, child, progress) => progress == null
                    ? child
                    : Container(
                        height: 160,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, size: 40),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ───── Título + botones ─────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditEventScreen(
                              nombre: title,
                              fechaDesde: date,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar'),
                            content: const Text(
                                '¿Seguro que quieres eliminar esta actividad?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Actividad eliminada'),
                              duration: Duration(seconds: 5),
                            ),
                          );
                          final success = await ActivityService()
                              .eliminarActividadPorId(id);

                          if (success) {
                            // Luego verifica si el context aún está montado antes de usarlo
                            if (!context.mounted) {
                              return;
                            }

                            onDelete!(); //Esto reincia la pag
                          }
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // ───── Fecha ─────
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(formattedDate,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                // ───── Ubicación ─────
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(location,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // ───── Descripción ─────
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                // ───── Participantes + estado ─────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<int>(
                      future: _loadParticipants(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Row(
                            children: [
                              Icon(Icons.people,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('Cargando participantes...',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Row(
                            children: [
                              Icon(Icons.people,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('Error',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          );
                        } else {
                          final participants = snapshot.data ?? 0;
                          return Row(
                            children: [
                              Icon(Icons.people,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text('$participants participantes',
                                  style: TextStyle(color: Colors.grey[600])),
                            ],
                          );
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green[100]
                            : const Color.fromARGB(255, 240, 158, 158),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isActive ? 'Activo' : 'Inactivo',
                        style: TextStyle(
                          color: isActive
                              ? Colors.green[800]
                              : const Color.fromARGB(255, 255, 45, 45),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _spanishMonth(int month) {
    const meses = [
      '',
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return meses[month];
  }

  bool hasDatePassed() {
    final now = DateTime.now();
    final eventDate = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    return eventDate.isBefore(today);
  }

  Future<int> _loadParticipants() async {
    // Simula la llamada al servicio asíncrono
    final int count = await ActivityService().countParticipants(id);
    return count;
  }
}
