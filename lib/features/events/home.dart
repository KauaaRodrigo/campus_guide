import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../crudEvent/enrollment_controller.dart';
import '../../crudEvent/event_controller.dart';
import '../../crudEvent/event_model.dart';
import '../../services/email_service.dart';
import '../auth/user.dart';
import 'edit_event_page.dart';

class HomePage extends StatefulWidget {
  /// Incrementado pelo `HomeShell` toda vez que esta aba fica visível.
  /// Quando muda, a página recarrega os eventos automaticamente.
  final int reloadToken;

  const HomePage({super.key, this.reloadToken = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = EventController();
  final _enrollmentController = EnrollmentController();

  AppUser? _usuarioAtual;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_rebuild);
    _enrollmentController.addListener(_rebuild);
    _carregarDados();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reloadToken != oldWidget.reloadToken) {
      _carregarDados();
    }
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _enrollmentController.removeListener(_rebuild);
    _controller.dispose();
    _enrollmentController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    await _carregarUsuarioAtual();
    await _controller.carregarEventos();

    final usuario = _usuarioAtual;
    if (usuario != null) {
      await _enrollmentController.carregarInscricoes(usuario.id);
    }
  }

  Future<void> _carregarUsuarioAtual() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(firebaseUser.uid)
        .get();
    final data = doc.data();
    if (data == null) return;

    _usuarioAtual = AppUser.fromMap(doc.id, data);
  }

  Future<void> _recarregarAposInscricao() async {
    await _controller.carregarEventos();

    final usuario = _usuarioAtual;
    if (usuario != null) {
      await _enrollmentController.carregarInscricoes(usuario.id);
    }
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Text(
                _usuarioAtual == null
                    ? 'Olá!'
                    : 'Olá, ${_usuarioAtual!.name.split(' ').first}!',
                style: const TextStyle(
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
    if (_controller.carregando && _controller.eventos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

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
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    // Regras de negócio de visibilidade:
    //  - Eventos ativos: sempre visíveis.
    //  - Eventos encerrados/cancelados: visíveis por até 4 dias após dataFim.
    //  - Demais: ocultos da listagem pública (preservados no Firestore).
    final eventosVisiveis = _controller.eventos
        .where((e) => e.isVisivelNaListagem)
        .toList();

    if (eventosVisiveis.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum evento disponível no momento.',
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDados,
      color: const Color(0xFF1535C9),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        itemCount: eventosVisiveis.length,
        itemBuilder: (context, index) {
          final evento = eventosVisiveis[index];
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
        enrollmentController: _enrollmentController,
        usuarioAtual: _usuarioAtual,
        onEditar: () => _abrirEdicao(evento),
        onInscricaoAlterada: _recarregarAposInscricao,
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

class _EventDetailsModal extends StatelessWidget {
  final EventModel evento;
  final EventController controller;
  final EnrollmentController enrollmentController;
  final AppUser? usuarioAtual;
  final VoidCallback onEditar;
  final Future<void> Function() onInscricaoAlterada;

  const _EventDetailsModal({
    required this.evento,
    required this.controller,
    required this.enrollmentController,
    required this.usuarioAtual,
    required this.onEditar,
    required this.onInscricaoAlterada,
  });

  @override
  Widget build(BuildContext context) {
    final usuario = usuarioAtual;
    final isDonoDocente =
        usuario?.role == 'docente' && evento.criadoPor == usuario?.id;
    final isInscrito = enrollmentController.estaInscrito(evento.id);

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
                    if (isDonoDocente)
                      IconButton(
                        icon: const Icon(
                          Icons.cancel_outlined,
                          color: Colors.red,
                          size: 26,
                        ),
                        // Eventos não são deletados — apenas cancelados,
                        // para preservar o histórico de participação.
                        onPressed: () => _showCancelDialog(context),
                      )
                    else
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
                                evento.statusEfetivo == EventStatus.cancelado
                                    ? 'Cancelado'
                                    : 'Aberto',
                                style: TextStyle(
                                  color:
                                      evento.statusEfetivo ==
                                          EventStatus.cancelado
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
                      if (evento.statusEfetivo == EventStatus.cancelado) ...[
                        const SizedBox(height: 14), //aviso de evento cancelado
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.red),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Este evento foi cancelado. Inscrições não são permitidas.',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text(
                        evento.descricao,
                        style: const TextStyle(fontSize: 14, height: 1.55),
                      ),
                      const SizedBox(height: 14),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Local',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: ': ${evento.local}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (evento.ministrantes.isNotEmpty) ...[
                        const Center(
                          child: Text(
                            'Ministrantes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...evento.ministrantes.map(
                          (m) => _SpeakerTile(ministrante: m),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: isDonoDocente
                    ? Row(
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
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _PrimaryButton(
                              label: evento.statusEfetivo == EventStatus.cancelado
                                  ? 'Evento cancelado'
                                  : isInscrito
                                      ? 'Cancelar inscrição'
                                      : 'Inscrever-se',
                              onPressed: evento.statusEfetivo == EventStatus.cancelado &&
                                      !isInscrito
                                  ? null
                                  : () =>
                                      _alterarInscricao(context, isInscrito),
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

  Future<void> _showEnrolledList(BuildContext context) async {
    final students = await enrollmentController.buscarInscritosDoEvento(
      evento.id,
    );

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => _EnrolledListDialog(students: students),
    );
  }

  Future<void> _alterarInscricao(BuildContext context, bool isInscrito) async {
    final usuario = usuarioAtual;
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login para se inscrever.')),
      );
      return;
    }

    final ok = isInscrito
        ? await enrollmentController.desinscrever(
            userID: usuario.id,
            eventoID: evento.id,
          )
        : await enrollmentController.inscrever(
            userID: usuario.id,
            eventoID: evento.id,
          );

    if (!context.mounted) return;

    if (ok) {
      await onInscricaoAlterada();
      if (!context.mounted) return;
      Navigator.pop(context); // fecha o modal do evento

      if (isInscrito) {
        // Desincrição: SnackBar simples é suficiente
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inscrição cancelada com sucesso.')),
        );
      } else {
        // Inscrição: exibe diálogo de confirmação e dispara e-mail
        EmailService.enviarConfirmacaoInscricao(
          usuario: usuario,
          evento: evento,
        ); // sem await — não bloqueia a UI

        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _InscricaoConfirmadaDialog(),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            enrollmentController.erro ??
                'Não foi possível atualizar inscrição.',
          ),
        ),
      );
    }
  }
}

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
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl.isEmpty
                ? const Icon(Icons.person, size: 34, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 16),
          Text(ministrante['nome'] ?? '', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1535C9),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Colors.black87,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
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
                        borderRadius: BorderRadius.circular(30),
                      ),
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

class _EnrolledListDialog extends StatelessWidget {
  final List<Map<String, String>> students;

  const _EnrolledListDialog({required this.students});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Lista de inscritos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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
                      child: Text(
                        'Nenhum inscrito ainda.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      itemBuilder: (context, i) {
                        final student = students[i];
                        final parts = <String>[
                          if ((student['name'] ?? '').isNotEmpty)
                            student['name']!,
                          if ((student['registration'] ?? '').isNotEmpty)
                            student['registration']!,
                          if ((student['course'] ?? '').isNotEmpty)
                            student['course']!,
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('- ', style: TextStyle(fontSize: 14)),
                              Expanded(
                                child: Text(
                                  parts.join(' | '),
                                  style: const TextStyle(fontSize: 14),
                                ),
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

/// Diálogo exibido após uma inscrição bem-sucedida.
///
/// Mostra os dados do evento confirmado e informa que um e-mail foi enviado.
/// Popup de confirmação exibido após inscrição bem-sucedida.
class _InscricaoConfirmadaDialog extends StatelessWidget {
  const _InscricaoConfirmadaDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: SizedBox(
        width: 350,
        height: 290,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Checkmark simples, sem círculo colorido
              const Icon(Icons.check, size: 48, color: Colors.black87),
              const SizedBox(height: 16),

              // Título
              const Text(
                'Você está inscrito!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subtítulo
              const Text(
                'Enviamos uma confirmação de inscrição para seu email.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Botão Continuar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1535C9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
