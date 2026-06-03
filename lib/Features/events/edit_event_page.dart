import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/buttons/primary_button.dart';
import '../../crudEvent/event_controller.dart';
import '../../crudEvent/event_model.dart';

const _cursos = [
  'Ciência da Computação',
  'Engenharia de Software',
  'Sistemas de Informação',
  'Análise e Desenvolvimento de Sistemas',
  'Engenharia Civil',
  'Engenharia Elétrica',
  'Administração',
  'Direito',
  'Medicina',
  'Todos os cursos',
];

const _periodos = [
  '1º Período',
  '2º Período',
  '3º Período',
  '4º Período',
  '5º Período',
  '6º Período',
  '7º Período',
  '8º Período',
  '9º Período',
  '10º Período',
  'Todos os períodos',
];

class EditEventPage extends StatefulWidget {
  final EventModel evento;

  const EditEventPage({super.key, required this.evento});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _controller = EventController();

  late final TextEditingController _tituloCtrl;
  late final TextEditingController _diaCtrl;
  late final TextEditingController _horaCtrl;
  late final TextEditingController _localCtrl;
  late final TextEditingController _vagasCtrl;
  late final TextEditingController _descricaoCtrl;
  final TextEditingController _ministranteCtrl = TextEditingController();

  String? _cursoSelecionado;
  String? _periodoSelecionado;
  late List<String> _ministrantes;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_atualizarTela);

    final e = widget.evento;
    _tituloCtrl = TextEditingController(text: e.titulo);
    _diaCtrl = TextEditingController(
      text:
          '${e.dataInicio.day.toString().padLeft(2, '0')}/'
          '${e.dataInicio.month.toString().padLeft(2, '0')}/'
          '${e.dataInicio.year}',
    );
    _horaCtrl = TextEditingController(
      text:
          '${e.dataInicio.hour.toString().padLeft(2, '0')}:'
          '${e.dataInicio.minute.toString().padLeft(2, '0')}',
    );
    _localCtrl = TextEditingController(text: e.local);
    _vagasCtrl = TextEditingController(text: e.vagasTotal.toString());
    _descricaoCtrl = TextEditingController(text: e.descricao);

    _cursoSelecionado = _cursos.contains(e.curso) ? e.curso : null;
    _periodoSelecionado = _periodos.contains(e.periodo) ? e.periodo : null;
    _ministrantes = e.ministrantes
        .map((m) => m['nome'] ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
  }

  void _atualizarTela() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_atualizarTela);
    _controller.dispose();
    _tituloCtrl.dispose();
    _diaCtrl.dispose();
    _horaCtrl.dispose();
    _localCtrl.dispose();
    _vagasCtrl.dispose();
    _descricaoCtrl.dispose();
    _ministranteCtrl.dispose();
    super.dispose();
  }

  Future<void> _selecionarDia() async {
    final data = await showDatePicker(
      context: context,
      initialDate: widget.evento.dataInicio,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (data != null) {
      _diaCtrl.text =
          '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year}';
    }
  }

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.evento.dataInicio),
    );
    if (hora != null) {
      _horaCtrl.text =
          '${hora.hour.toString().padLeft(2, '0')}:'
          '${hora.minute.toString().padLeft(2, '0')}';
    }
  }

  void _adicionarMinistrante() {
    final nome = _ministranteCtrl.text.trim();
    if (nome.isEmpty) return;
    setState(() {
      _ministrantes.add(nome);
      _ministranteCtrl.clear();
    });
  }

  void _removerMinistrante(int index) {
    setState(() => _ministrantes.removeAt(index));
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty ||
        _diaCtrl.text.trim().isEmpty ||
        _horaCtrl.text.trim().isEmpty ||
        _localCtrl.text.trim().isEmpty ||
        _vagasCtrl.text.trim().isEmpty ||
        _cursoSelecionado == null ||
        _periodoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
      return;
    }

    final vagas = int.tryParse(_vagasCtrl.text.trim());
    if (vagas == null || vagas <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um número de vagas válido.')),
      );
      return;
    }

    final partesDia = _diaCtrl.text.trim().split('/');
    final partesHora = _horaCtrl.text.trim().split(':');

    if (partesDia.length != 3 || partesHora.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe uma data e hora válidas.')),
      );
      return;
    }

    final dataInicio = DateTime(
      int.parse(partesDia[2]),
      int.parse(partesDia[1]),
      int.parse(partesDia[0]),
      int.parse(partesHora[0]),
      int.parse(partesHora[1]),
    );

    final eventoAtualizado = widget.evento.copyWith(
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      dataInicio: dataInicio,
      dataFim: dataInicio.add(const Duration(hours: 2)),
      local: _localCtrl.text.trim(),
      vagasTotal: vagas,
      curso: _cursoSelecionado!,
      periodo: _periodoSelecionado!,
      ministrantes: _ministrantes.map((n) => {'nome': n}).toList(),
    );

    final ok = await _controller.editarEvento(eventoAtualizado);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.erro ?? 'Erro ao salvar evento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F49D1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Editar evento',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
                const SizedBox(height: 24),
                _CampoComIcone(
                  hint: 'Título',
                  controller: _tituloCtrl,
                  readOnly: false,
                ),
                const SizedBox(height: 14),
                _CampoComIcone(
                  hint: 'Dia',
                  controller: _diaCtrl,
                  icon: Icons.calendar_today_outlined,
                  onIconTap: _selecionarDia,
                ),
                const SizedBox(height: 14),
                _CampoComIcone(
                  hint: 'Hora',
                  controller: _horaCtrl,
                  icon: Icons.schedule_outlined,
                  onIconTap: _selecionarHora,
                ),
                const SizedBox(height: 14),
                _CampoComIcone(
                  hint: 'Local',
                  controller: _localCtrl,
                  readOnly: false,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _vagasCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: _inputDecoration('Número de vagas totais'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _descricaoCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _inputDecoration('Descrição'),
                ),
                const SizedBox(height: 14),
                _DropdownField<String>(
                  hint: 'Curso',
                  value: _cursoSelecionado,
                  items: _cursos,
                  onChanged: (v) => setState(() => _cursoSelecionado = v),
                ),
                const SizedBox(height: 14),
                _DropdownField<String>(
                  hint: 'Período',
                  value: _periodoSelecionado,
                  items: _periodos,
                  onChanged: (v) => setState(() => _periodoSelecionado = v),
                ),
                const SizedBox(height: 14),
                _MinistrantesField(
                  controller: _ministranteCtrl,
                  ministrantes: _ministrantes,
                  onAdicionar: _adicionarMinistrante,
                  onRemover: _removerMinistrante,
                ),
                const SizedBox(height: 28),
                PrimaryButton(
                  text: 'Próximo →',
                  loading: _controller.carregando,
                  onPressed: _salvar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B5EDF)),
      ),
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _CampoComIcone extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final IconData? icon;
  final VoidCallback? onIconTap;
  final bool readOnly;

  const _CampoComIcone({
    required this.hint,
    required this.controller,
    this.icon,
    this.onIconTap,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onIconTap,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B5EDF)),
        ),
        suffixIcon: icon != null
            ? IconButton(
                icon: Icon(icon, color: Colors.black45),
                onPressed: onIconTap,
              )
            : null,
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      hint: Text(hint, style: const TextStyle(color: Colors.black45)),
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B5EDF)),
        ),
      ),
      items: items
          .map(
            (item) =>
                DropdownMenuItem<T>(value: item, child: Text(item.toString())),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _MinistrantesField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> ministrantes;
  final VoidCallback onAdicionar;
  final ValueChanged<int> onRemover;

  const _MinistrantesField({
    required this.controller,
    required this.ministrantes,
    required this.onAdicionar,
    required this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ministrante',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3B5EDF)),
                  ),
                ),
                onSubmitted: (_) => onAdicionar(),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: onAdicionar,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B5EDF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
        if (ministrantes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ministrantes
                .asMap()
                .entries
                .map(
                  (e) => Chip(
                    label: Text(e.value),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => onRemover(e.key),
                    backgroundColor: const Color(0xFFE8EDFF),
                    labelStyle: const TextStyle(color: Color(0xFF2F49D1)),
                    deleteIconColor: const Color(0xFF2F49D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
