// lib/widgets/event_card_list.dart

import 'package:flutter/material.dart';
import 'package:iguanosquad/services/actividad_service.dart';
import 'package:iguanosquad/widgets/event_card.dart';
import '../screens/edit_event_screen.dart';

// Importa tu observer:
import '../main.dart'; // <-- asegúrate de la ruta correcta

class EventCardList extends StatefulWidget {
  final String userId;
  const EventCardList({super.key, required this.userId});

  @override
  State<EventCardList> createState() => _EventCardListState();
}

class _EventCardListState extends State<EventCardList> with RouteAware {
  // <-- agregamos RouteAware
  late Future<List<Map<String, dynamic>>> _futureEventos;

  @override
  void initState() {
    super.initState();
    _futureEventos =
        ActivityService().obtenerActividadesPorUsuario(widget.userId);
  }

  void _reload() {
    setState(() {
      _futureEventos =
          ActivityService().obtenerActividadesPorUsuario(widget.userId);
    });
  }

  // 1) Suscríbete cuando el widget entra en el árbol
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  // 2) Cancela la suscripción al destruir el widget
  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // 3) ¡Aquí está la magia! Se llama cuando vuelves de otra pantalla
  @override
  void didPopNext() {
    // print('🔄 didPopNext: recargando eventos');
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureEventos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final eventos = snapshot.data!;
        if (eventos.isEmpty) {
          return const Center(child: Text('No hay actividades aún.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: eventos.length,
          itemBuilder: (context, index) {
            final evento = eventos[index];
            final nombre = evento['nombre'] as String;
            final fechaHora = DateTime.parse(evento['fecha_hora'] as String);
            return EventCard(
              title: nombre,
              date: fechaHora,
              location: evento['ubicacion'] ?? 'Ubicación no especificada',
              description: evento['descripcion'] ?? '',
              id: evento['id'] ?? 0,
              imageURL: evento['url_image'] ?? '',
              onEdit: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditEventScreen(
                      nombre: nombre,
                      fechaDesde: fechaHora,
                    ),
                  ),
                );
                // No hace falta setState aquí: didPopNext lo hace por ti.
              },
            );
          },
        );
      },
    );
  }
}
