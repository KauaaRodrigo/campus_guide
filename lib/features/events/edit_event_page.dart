import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/buttons/primary_button.dart';
import '../../crudEvent/event_controller.dart';
import '../../crudEvent/event_model.dart';
import 'event_form_data.dart';

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
  late final TextEditingController _horaFimCtrl;
  late final TextEditingController _localCtrl;
  late final TextEditingController _vagasCtrl;
  late final TextEditingController _descricaoCtrl;
  final TextEditingController _ministranteCtrl = TextEditingController();

  late List<String> _cursosSelecionados;
  late List<String> _periodosSelecionados;
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
    _horaFimCtrl = TextEditingController(
      text:
          '${e.dataFim.hour.toString().padLeft(2, "0")}:'
          '${e.dataFim.minute.toString().padLeft(2, "0")}',
    );
    _localCtrl = TextEditingController(text: e.local);
    _vagasCtrl = TextEditingController(text: e.vagasTotal.toString());
    _descricaoCtrl = TextEditingController(text: e.descricao);

    _cursosSelecionados = List<String>.from(e.cursos);
    _periodosSelecionados = List<String>.from(e.periodos);
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
    _horaFimCtrl.dispose();
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

  Future<void> _selecionarHoraFim() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(widget.evento.dataFim),
    );
    if (hora != null) {
      _horaFimCtrl.text =
          '${hora.hour.toString().padLeft(2, "0")}:'
          '${hora.minute.toString().padLeft(2, "0")}';
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

  void _onCursosChanged(List<String> novos) {
    setState(() {
      _cursosSelecionados = novos;
      final validos = periodosParaCursos(novos);
      _periodosSelecionados.retainWhere(validos.contains);
    });
  }

  Future<void> _salvar() async {
    if (_tituloCtrl.text.trim().isEmpty ||
        _diaCtrl.text.trim().isEmpty ||
        _horaCtrl.text.trim().isEmpty ||
        _horaFimCtrl.text.trim().isEmpty ||
        _localCtrl.text.trim().isEmpty ||
        _vagasCtrl.text.trim().isEmpty ||
        _cursosSelecionados.isEmpty ||
        _periodosSelecionados.isEmpty) {
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

    // REGRA: Não deve ser permitido reduzir o número de vagas abaixo do número de inscritos
    if (vagas < widget.evento.vagasOcupadas) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossível reduzir vagas para $vagas. O evento já possui ${widget.evento.vagasOcupadas} inscritos.',
          ),
        ),
      );
      return;
    }

    final partesDia = _diaCtrl.text.trim().split('/');
    final partesHora = _horaCtrl.text.trim().split(':');
    final partesHoraFim = _horaFimCtrl.text.trim().split(':');

    if (partesDia.length != 3 ||
        partesHora.length != 2 ||
        partesHoraFim.length != 2) {
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

    final dataFim = DateTime(
      int.parse(partesDia[2]),
      int.parse(partesDia[1]),
      int.parse(partesDia[0]),
      int.parse(partesHoraFim[0]),
      int.parse(partesHoraFim[1]),
    );

    if (!dataFim.isAfter(dataInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('O horário de término deve ser após o de início.'),
        ),
      );
      return;
    }

    final eventoAtualizado = widget.evento.copyWith(
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      dataInicio: dataInicio,
      dataFim: dataFim,
      local: _localCtrl.text.trim(),
      vagasTotal: vagas,
      cursos: _cursosSelecionados,
      periodos: _periodosSelecionados,
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
                  hint: 'Hora de início',
                  controller: _horaCtrl,
                  icon: Icons.schedule_outlined,
                  onIconTap: _selecionarHora,
                ),
                const SizedBox(height: 14),
                _CampoComIcone(
                  hint: 'Hora de término',
                  controller: _horaFimCtrl,
                  icon: Icons.schedule_outlined,
                  onIconTap: _selecionarHoraFim,
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
                MultiSelectField(
                  hint: 'Curso',
                  options: kCursos,
                  selected: _cursosSelecionados,
                  onChanged: _onCursosChanged,
                ),
                const SizedBox(height: 14),
                MultiSelectField(
                  hint: 'Período',
                  options: periodosParaCursos(_cursosSelecionados),
                  selected: _periodosSelecionados,
                  enabled: _cursosSelecionados.isNotEmpty,
                  onChanged: (v) => setState(() => _periodosSelecionados = v),
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