import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../crudEvent/enrollment_controller.dart';
import '../../crudEvent/event_controller.dart';
import '../../crudEvent/event_model.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  final _eventController = EventController();
  final _enrollmentController = EnrollmentController();

  String? get _userID => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _eventController.addListener(_rebuild);
    _enrollmentController.addListener(_rebuild);
    _carregarDados();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _eventController.removeListener(_rebuild);
    _enrollmentController.removeListener(_rebuild);
    _eventController.dispose();
    _enrollmentController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    final userID = _userID;
    await _eventController.carregarEventos();
    if (userID != null) {
      await _enrollmentController.carregarInscricoes(userID);
    }
  }

  List<EventModel> get _eventosInscritos {
    return _eventController.eventos
        .where((evento) => _enrollmentController.estaInscrito(evento.id))
        .toList();
  }

  String _labelData(DateTime dt) {
    final hoje = DateTime.now();
    if (_mesmoDia(dt, hoje)) return 'Hoje';
    if (_mesmoDia(dt, hoje.add(const Duration(days: 1)))) return 'Amanhã';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}';
  }

  bool _mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _labelHora(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1535C9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Text(
                'Meus Eventos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final userID = _userID;
    if (userID == null) {
      return const Center(
        child: Text(
          'Faça login para ver seus eventos.',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
      );
    }

    if ((_eventController.carregando || _enrollmentController.carregando) &&
        _eventController.eventos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final erro = _eventController.erro ?? _enrollmentController.erro;
    if (erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 48),
            const SizedBox(height: 12),
            Text(
              erro,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final eventos = _eventosInscritos;
    if (eventos.isEmpty) {
      return const Center(
        child: Text(
          'Você ainda não está inscrito em nenhum evento.',
          style: TextStyle(color: Colors.white70, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      color: const Color(0xFF1535C9),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return _MyEventListCard(
            evento: evento,
            labelData: _labelData(evento.dataInicio),
            labelHora: _labelHora(evento.dataInicio),
            onTap: () => _abrirDetalhes(evento),
          );
        },
      ),
    );
  }

  void _abrirDetalhes(EventModel evento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MyEventDetailsModal(
        evento: evento,
        onCancelarInscricao: () => _cancelarInscricao(evento),
      ),
    );
  }

  Future<void> _cancelarInscricao(EventModel evento) async {
    final userID = _userID;
    if (userID == null) return;

    final ok = await _enrollmentController.desinscrever(
      userID: userID,
      eventoID: evento.id,
    );

    if (!mounted) return;
    if (ok) {
      await _carregarDados();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscrição cancelada com sucesso.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _enrollmentController.erro ??
                'Não foi possível cancelar a inscrição.',
          ),
        ),
      );
    }
  }
}

class _MyEventListCard extends StatelessWidget {
  final EventModel evento;
  final String labelData;
  final String labelHora;
  final VoidCallback onTap;

  const _MyEventListCard({
    required this.evento,
    required this.labelData,
    required this.labelHora,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 82,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E4E4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labelData,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                    Text(
                      labelHora,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      evento.titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      evento.descricao,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyEventDetailsModal extends StatelessWidget {
  final EventModel evento;
  final VoidCallback onCancelarInscricao;

  const _MyEventDetailsModal({
    required this.evento,
    required this.onCancelarInscricao,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.45,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        evento.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Status: ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                evento.status == EventStatus.cancelado
                                    ? 'Cancelado'
                                    : 'Aberto',
                                style: TextStyle(
                                  color: evento.status == EventStatus.cancelado
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Resta(m) '),
                              Text(
                                '${evento.vagasRestantes}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(' vaga(s)'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        evento.descricao,
                        style: const TextStyle(fontSize: 14, height: 1.55),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Local: ${evento.local}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: ElevatedButton(
                  onPressed: onCancelarInscricao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1535C9),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Cancelar inscrição',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
