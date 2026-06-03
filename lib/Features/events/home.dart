import 'package:flutter/material.dart';
import 'package:campus_guide/crudEvent/event_controller.dart';
import 'package:campus_guide/crudEvent/event_model.dart';
import 'package:campus_guide/features/events/edit_event_page.dart';

// HOME PAGE
// Conectada ao EventController — carrega eventos reais do Firestore.
// Não depende de Provider: o controller é instanciado localmente e descartado
// no dispose(), igual ao padrão adotado no create_page.dart.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = EventController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
    _controller.carregarEventos();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  // Helpers de data

  /// Retorna "Hoje", "Amanhã" ou "dd/MM" para exibir no card.
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

  // Build

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
                'Olá, Docente!',
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
    // Carregando
    if (_controller.carregando && _controller.eventos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    // Erro
    if (_controller.erro != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 48),
            const SizedBox(height: 12),
            Text(
              _controller.erro!,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _controller.carregarEventos,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Lista vazia
    if (_controller.eventos.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum evento cadastrado.',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
      );
    }

    // Lista de eventos
    return RefreshIndicator(
      onRefresh: _controller.carregarEventos,
      color: const Color(0xFF1535C9),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: _controller.eventos.length,
        itemBuilder: (context, index) {
          final evento = _controller.eventos[index];
          return _EventListCard(
            evento: evento,
            labelData: _labelData(evento.dataInicio),
            labelHora: _labelHora(evento.dataInicio),
            onTap: () => _abrirModal(evento),
          );
        },
      ),
    );
  }

  void _abrirModal(EventModel evento) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventDetailsModal(
        evento: evento,
        controller: _controller,
        onEditar: () => _abrirEdicao(evento),
      ),
    );
  }

  Future<void> _abrirEdicao(EventModel evento) async {
    final atualizado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditEventPage(evento: evento)),
    );
    if (atualizado == true) {
      _controller.carregarEventos();
    }
  }
}

// ---------------------------------------------------------------------------
// EVENT LIST CARD
// ---------------------------------------------------------------------------

class _EventListCard extends StatelessWidget {
  final EventModel evento;
  final String labelData;
  final String labelHora;
  final VoidCallback onTap;

  const _EventListCard({
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Caixa de data/hora ───────────────────────────────────────
              Container(
                width: 82,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                          fontSize: 13, color: Color(0xFF555555)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(
                          height: 1, thickness: 1, color: Color(0xFFAAAAAA)),
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
              // ── Título + descrição ───────────────────────────────────────
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
                          fontSize: 13, color: Color(0xFF555555)),
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

// ---------------------------------------------------------------------------
// EVENT DETAILS MODAL
// ---------------------------------------------------------------------------

class _EventDetailsModal extends StatelessWidget {
  final EventModel evento;
  final EventController controller;
  final VoidCallback onEditar;

  const _EventDetailsModal({
    required this.evento,
    required this.controller,
    required this.onEditar,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.96,
      minChildSize: 0.5,
      builder: (ctx, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────────────────
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
              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        evento.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.red, size: 26),
                      onPressed: () => _showDeleteDialog(context),
                    ),
                  ],
                ),
              ),
              // ── Conteúdo scrollável ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status + vagas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Text('Status: ',
                                style: TextStyle(fontWeight: FontWeight.w500)),
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
                          ]),
                          Row(children: [
                            const Text('Resta(m) '),
                            Text(
                              '${evento.vagasRestantes}',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text(' vaga(s)'),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Descrição
                      Text(evento.descricao,
                          style:
                              const TextStyle(fontSize: 14, height: 1.55)),
                      const SizedBox(height: 14),
                      // Local
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 14),
                          children: [
                            const TextSpan(
                                text: 'Local',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: ': ${evento.local}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Ministrantes
                      if (evento.ministrantes.isNotEmpty) ...[
                        const Center(
                          child: Text(
                            'Ministrantes',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...evento.ministrantes
                            .map((m) => _SpeakerTile(ministrante: m)),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // ── Botões de ação ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: _PrimaryButton(
                        label: 'Editar evento',
                        onPressed: () {
                          Navigator.pop(context);
                          onEditar();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PrimaryButton(
                        label: 'Verificar inscritos',
                        onPressed: () => _showEnrolledList(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Diálogos ─────────────────────────────────────────────────────────────

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Deletar evento',
        message:
            'Tem certeza que deseja deletar esse evento?\nEssa ação não pode ser desfeita.',
        confirmLabel: 'Deletar evento',
        cancelLabel: 'Cancelar',
        extraLinkText: 'Deseja cancelar o evento?',
        onConfirm: () async {
          Navigator.pop(context); // fecha dialog
          Navigator.pop(context); // fecha modal
          await controller.deletarEvento(evento.id);
        },
        onCancel: () => Navigator.pop(context),
        onExtraLink: () {
          Navigator.pop(context);
          _showCancelDialog(context);
        },
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Cancelar evento',
        message:
            'Tem certeza que deseja cancelar esse evento?\nVocê poderá reabri-lo a qualquer hora na aba Meus Eventos',
        confirmLabel: 'Cancelar evento',
        cancelLabel: 'Manter evento',
        onConfirm: () async {
          Navigator.pop(context);
          await controller.cancelarEvento(evento.id);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showEnrolledList(BuildContext context) {
    // TODO: buscar lista de inscritos do Firestore via repository
    // Por enquanto exibe dialog placeholder
    showDialog(
      context: context,
      builder: (_) => const _EnrolledListDialog(students: []),
    );
  }
}

// ---------------------------------------------------------------------------
// SPEAKER TILE
// ---------------------------------------------------------------------------

class _SpeakerTile extends StatelessWidget {
  final Map<String, String> ministrante;

  const _SpeakerTile({required this.ministrante});

  @override
  Widget build(BuildContext context) {
    final imageUrl = ministrante['imagem'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage:
                imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
            child: imageUrl.isEmpty
                ? const Icon(Icons.person, size: 34, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Text(ministrante['nome'] ?? '',
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PRIMARY BUTTON
// ---------------------------------------------------------------------------

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1535C9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(label,
          style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}

// ---------------------------------------------------------------------------
// CONFIRM DIALOG  (deletar / cancelar evento)
// ---------------------------------------------------------------------------

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final String? extraLinkText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final VoidCallback? onExtraLink;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.extraLinkText,
    required this.onConfirm,
    required this.onCancel,
    this.onExtraLink,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.black87),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF555555)),
            ),
            if (extraLinkText != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onExtraLink,
                child: Text(
                  extraLinkText!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1535C9),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: Text(cancelLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ENROLLED LIST DIALOG
// ---------------------------------------------------------------------------

class _EnrolledListDialog extends StatelessWidget {
  final List<Map<String, String>> students;

  const _EnrolledListDialog({required this.students});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Lista de inscritos',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: students.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Nenhum inscrito ainda.',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      itemBuilder: (context, i) {
                        final s = students[i];
                        final parts = <String>[
                          if ((s['name'] ?? '').isNotEmpty) s['name']!,
                          if ((s['registration'] ?? '').isNotEmpty)
                            s['registration']!,
                          if ((s['course'] ?? '').isNotEmpty) s['course']!,
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(parts.join(' | '),
                                    style: const TextStyle(fontSize: 14)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}