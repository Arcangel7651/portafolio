import 'package:flutter/material.dart';
import '../services/actividad_service.dart';
import '../widgets/activity_detail_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActivityDetailScreen extends StatefulWidget {
  final int activityId;
  const ActivityDetailScreen({Key? key, required this.activityId})
      : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  final ActivityService _service = ActivityService();
  bool _isLoading = true;
  var _activity;
  bool _isParticipating = false;
  bool _checkingParticipation = true;
  int _participantsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    try {
      final act = await _service.fetchActivity(widget.activityId);
      final count = await _service.countParticipants(widget.activityId);
      final participando = userId != null
          ? await _service.userParticipating(widget.activityId, userId)
          : false;

      setState(() {
        _activity = act;
        _participantsCount = count;
        _isParticipating = participando;
        _checkingParticipation = false;
      });
    } catch (e) {
      print("El error es: ${e}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar detalles')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onToggle() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _service.toggleParticipation(
        widget.activityId,
        userId,
        _isParticipating,
        (_activity?.disponibilidadCupos ?? 0) - _participantsCount,
      );

      // Aquí recargas los datos Y fuerzas reconstrucción visual
      await _loadDetails();
      setState(() {});
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_activity == null)
      return Scaffold(body: Center(child: Text('Actividad no encontrada')));

    return Scaffold(
      body: ActivityDetailWidget(
        activity: _activity,
        isParticipating: _isParticipating,
        checkingParticipation: _checkingParticipation,
        participantsCount: _participantsCount,
        onToggle: _onToggle,
      ),
    );
  }
}
