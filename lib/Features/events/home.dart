import 'package:flutter/material.dart';

class EventData {
  final String title;
  final String description;
  final String location;
  final String date; // ex: "03/04", "Hoje", "Amanhã"
  final String time; // ex: "15:30"
  final List<Map<String, String>> speakers; // {'name': '', 'image': ''}
  final int remainingVacancies;
  final bool isOpen;
  final List<Map<String, String>> enrolledStudents; // {'name','registration','course'}

  const EventData({
    required this.title,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.speakers,
    this.remainingVacancies = 0,
    this.isOpen = true,
    this.enrolledStudents = const [],
  });
}

// Placeholder events (substitua por chamada real)
final List<EventData> _placeholderEvents = [
  EventData(
    title: 'TechConnect 2026: Do Código ao Mercado',
    description:
        'Uma palestra focada em quem quer sair da teoria e entrar no jogo de '
        'verdade. O TechConnect reúne estudantes, desenvolvedores e profissionais '
        'da área para discutir o que realmente importa: habilidades exigidas pelo '
        'mercado, projetos que fazem diferença no currículo e caminhos reais para '
        'conseguir a primeira oportunidade em tecnologia.',
    location: 'Auditório Padre Arnobio',
    date: '03/04',
    time: '15:30',
    remainingVacancies: 30,
    isOpen: true,
    speakers: [
      {'name': 'Satoro Gojo', 'image': ''},
      {'name': 'Sofia', 'image': ''},
      {'name': 'Franklin', 'image': ''},
      {'name': 'Mega cavaleiro', 'image': ''},
    ],
    enrolledStudents: [
      {'name': 'a', 'registration': '123456789', 'course': 'Medicina'},
      {'name': 'b', 'registration': '', 'course': ''},
      {'name': 'c', 'registration': '', 'course': ''},
    ],
  ),
  EventData(
    title: 'CodeRush 2026: Construa, Teste, Conquiste',
    description:
        'Um evento intenso pra quem quer evoluir de verdade. No CodeRush, você '
        'vai ver na prática como construir projetos reais do zero até a entrega.',
    location: 'Laboratório 2',
    date: 'Amanhã',
    time: '9:40',
    remainingVacancies: 15,
    isOpen: true,
    speakers: [
      {'name': 'Pedro', 'image': ''},
    ],
    enrolledStudents: [],
  ),
  EventData(
    title: 'Saúde em Foco: Da Prevenção ao Cuidado Real',
    description:
        'Uma reunião voltado para quem quer entender como a saúde funciona na '
        'prática, com foco em prevenção e acompanhamento contínuo.',
    location: 'Sala 305',
    date: '12/04',
    time: '18:45',
    remainingVacancies: 5,
    isOpen: true,
    speakers: [
      {'name': 'Dra. Ana', 'image': ''},
    ],
    enrolledStudents: [],
  ),
];

// ---------------------------------------------------------------------------
// CONSTANTS
// ---------------------------------------------------------------------------

const Color kPrimaryBlue = Color(0xFF1535C9);

// ---------------------------------------------------------------------------
// HOME PAGE
// ---------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBlue,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Text(
                'Olá, Docente!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ) ??
                    const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                itemCount: _placeholderEvents.length,
                itemBuilder: (context, index) {
                  final event = _placeholderEvents[index];
                  return _EventListCard(
                    event: event,
                    onTap: () => _openEventModal(context, event),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: _BottomNavBar( selectedIndex: _selectedNavIndex, onTap: (i) => setState(() => _selectedNavIndex = i)),
    );
  }

  void _openEventModal(BuildContext context, EventData event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EventDetailsModal(event: event),
    );
  }
}

// ---------------------------------------------------------------------------
// EVENT LIST CARD
// ---------------------------------------------------------------------------

class _EventListCard extends StatelessWidget {
  final EventData event;
  final VoidCallback onTap;

  const _EventListCard({required this.event, required this.onTap});

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
              // ── Date / Time box ──────────────────────────────────────────
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
                      event.date,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF555555)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(
                          height: 1, thickness: 1, color: Color(0xFFAAAAAA)),
                    ),
                    Text(
                      event.time,
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
              // ── Title + Description ──────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.description,
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
// BOTTOM NAV BAR
// ---------------------------------------------------------------------------

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPrimaryBlue,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.add_circle_outline_rounded,
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.calendar_month_outlined,
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String? label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selected,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: selected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(24),
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            if (label != null && selected) ...[
              const SizedBox(width: 6),
              Text(label!,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EVENT DETAILS MODAL (bottom sheet)
// ---------------------------------------------------------------------------

class _EventDetailsModal extends StatelessWidget {
  final EventData event;

  const _EventDetailsModal({required this.event});

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
              // ── Header row ───────────────────────────────────────────────
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
                        event.title,
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
              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status + vacancies
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(children: [
                            const Text('Status: ',
                                style:
                                    TextStyle(fontWeight: FontWeight.w500)),
                            Text(
                              event.isOpen ? 'Aberto' : 'Fechado',
                              style: TextStyle(
                                color: event.isOpen
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ]),
                          Row(children: [
                            const Text('Resta(m) '),
                            Text(
                              '${event.remainingVacancies}',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                            const Text(' vaga(s)'),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Description
                      Text(event.description,
                          style: const TextStyle(fontSize: 14, height: 1.55)),
                      const SizedBox(height: 14),
                      // Location
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.black87, fontSize: 14),
                          children: [
                            const TextSpan(
                                text: 'Local',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
                            TextSpan(text: ': ${event.location}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Ministrantes title
                      const Center(
                        child: Text(
                          'Ministrantes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Speaker list
                      ...event.speakers.map(
                        (s) => _SpeakerTile(speaker: s),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // ── Action buttons ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: _PrimaryButton(
                        label: 'Editar evento',
                        onPressed: () {
                          // TODO: navegar para tela de edição
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

  // ── Dialogs ──────────────────────────────────────────────────────────────

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
        onConfirm: () {
          Navigator.pop(context); // fecha dialog
          Navigator.pop(context); // fecha modal
          // TODO: chamar repositório para deletar
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
        onConfirm: () {
          Navigator.pop(context);
          // TODO: chamar repositório para cancelar
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showEnrolledList(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) =>
          _EnrolledListDialog(students: event.enrolledStudents),
    );
  }
}

// ---------------------------------------------------------------------------
// SPEAKER TILE
// ---------------------------------------------------------------------------

class _SpeakerTile extends StatelessWidget {
  final Map<String, String> speaker;

  const _SpeakerTile({required this.speaker});

  @override
  Widget build(BuildContext context) {
    final imageUrl = speaker['image'] ?? '';
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
          Text(speaker['name'] ?? '',
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
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      child: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              style:
                  const TextStyle(fontSize: 14, color: Color(0xFF555555)),
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
                      backgroundColor: kPrimaryBlue,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
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
            // Body
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
                                    style:
                                        const TextStyle(fontSize: 14)),
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