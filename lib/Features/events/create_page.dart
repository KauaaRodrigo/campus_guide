import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/buttons/primary_button.dart';
import '../../components/inputs/app_text_field.dart';
import '../../crudEvent/event_controller.dart';

/*
  create_page.dart
  - Aba "Criar Evento" do HomeShell.
  - Formulário completo integrado com EventController (Provider).
  - Campos: Nome, Dia, Hora, Local, Vagas, Descrição, Curso, Período.
*/

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _nomeCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _horaCtrl = TextEditingController();
  final _localCtrl = TextEditingController();
  final _vagasCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _cursoCtrl = TextEditingController();
  final _periodoCtrl = TextEditingController();

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _diaCtrl.dispose();
    _horaCtrl.dispose();
    _localCtrl.dispose();
    _vagasCtrl.dispose();
    _descricaoCtrl.dispose();
    _cursoCtrl.dispose();
    _periodoCtrl.dispose();
    super.dispose();
  }

  // ─── Seletor de data ──────────────────────────────────────────────────────
  Future<void> _selecionarDia() async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      locale: const Locale('pt', 'BR'),
    );
    if (data != null) {
      _diaCtrl.text =
          '${data.day.toString().padLeft(2, '0')}/'
          '${data.month.toString().padLeft(2, '0')}/'
          '${data.year}';
    }
  }

  // ─── Seletor de hora ──────────────────────────────────────────────────────
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

  // ─── Publicar evento ──────────────────────────────────────────────────────
  Future<void> _publicar() async {
    if (_nomeCtrl.text.trim().isEmpty ||
        _diaCtrl.text.trim().isEmpty ||
        _horaCtrl.text.trim().isEmpty ||
        _localCtrl.text.trim().isEmpty ||
        _vagasCtrl.text.trim().isEmpty) {
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
    final dataInicio = DateTime(
      int.parse(partesDia[2]),
      int.parse(partesDia[1]),
      int.parse(partesDia[0]),
      int.parse(partesHora[0]),
      int.parse(partesHora[1]),
    );

    final controller = context.read<EventController>();
    final ok = await controller.criarEvento(
      titulo: _nomeCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      dataInicio: dataInicio,
      dataFim: dataInicio.add(const Duration(hours: 2)),
      local: _localCtrl.text.trim(),
      vagasTotal: vagas,
      curso: _cursoCtrl.text.trim(),
      periodo: _periodoCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      _nomeCtrl.clear();
      _diaCtrl.clear();
      _horaCtrl.clear();
      _localCtrl.clear();
      _vagasCtrl.clear();
      _descricaoCtrl.clear();
      _cursoCtrl.clear();
      _periodoCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento publicado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(controller.erro ?? 'Erro ao publicar evento.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<EventController>();

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

                AppTextField(hint: 'Nome', controller: _nomeCtrl),
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

                AppTextField(
                  hint: 'Número de vagas totais',
                  controller: _vagasCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _descricaoCtrl,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Descrição',
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
                ),
                const SizedBox(height: 14),

                AppTextField(hint: 'Curso', controller: _cursoCtrl),
                const SizedBox(height: 14),

                AppTextField(hint: 'Período', controller: _periodoCtrl),
                const SizedBox(height: 28),

                PrimaryButton(
                  text: 'Publicar',
                  loading: controller.carregando,
                  onPressed: _publicar,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Campo com ícone clicável ─────────────────────────────────────────────────

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
