import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/buttons/primary_button.dart';
import '../../components/inputs/app_text_field.dart';
import '../../crudEvent/event_controller.dart';

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

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _controller = EventController();

  final _tituloCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _vagasCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _ministranteCtrl = TextEditingController();

  String? _cursoSelecionado;
  String? _periodoSelecionado;
  final List<String> _ministrantes = [];

  @override
  void initState() {
    super.initState();
    _controller.addListener(_atualizarTela);
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
      initialTime: TimeOfDay.now(),
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

  Future<void> _publicar() async {
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

    final ok = await _controller.criarEvento(
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

    if (!mounted) return;

    if (ok) {
      _tituloCtrl.clear();
      _diaCtrl.clear();
      _horaCtrl.clear();
      _localCtrl.clear();
      _vagasCtrl.clear();
      _descricaoCtrl.clear();
      _ministranteCtrl.clear();
      setState(() {
        _cursoSelecionado = null;
        _periodoSelecionado = null;
        _ministrantes.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento publicado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.erro ?? 'Erro ao publicar evento.')),
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
                const Center(
                  child: Text(
                    'Criar evento',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(hint: 'Título', controller: _tituloCtrl),
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
                AppTextField(hint: 'Local', controller: _localCtrl),
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
                  text: 'Publicar',
                  loading: _controller.carregando,
                  onPressed: _publicar,
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
  final IconData icon;
  final VoidCallback onIconTap;

  const _CampoComIcone({
    required this.hint,
    required this.controller,
    required this.icon,
    required this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
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
        suffixIcon: IconButton(
          icon: Icon(icon, color: Colors.black45),
          onPressed: onIconTap,
        ),
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
