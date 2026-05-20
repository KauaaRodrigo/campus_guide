import 'package:flutter/material.dart';

import '../../components/buttons/primary_button.dart';
import '../../components/inputs/app_text_field.dart';
import '../../components/navigation/bottom_nav_bar.dart';
import '../../crudEvent/event_controller.dart';
import 'package:provider/provider.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  int _currentIndex = 1; // aba "Criar evento" ativa

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

  // ─── Abre o seletor de data e preenche o campo Dia ───────────────────────
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

  // ─── Abre o seletor de hora e preenche o campo Hora ─────────────────────
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

  // ─── Valida e publica o evento ────────────────────────────────────────────
  Future<void> _publicar() async {
    // Validação básica dos campos obrigatórios
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

    // Converte dia + hora para DateTime
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
      dataFim: dataInicio.add(const Duration(hours: 2)), // padrão 2h
      local: _localCtrl.text.trim(),
      vagasTotal: vagas,
      curso: _cursoCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      // Limpa os campos após publicar
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

      // ─── Bottom Nav Bar ─────────────────────────────────────────────────
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),

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
                // ─── Título ───────────────────────────────────────────────
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

                // ─── Campos do formulário ─────────────────────────────────
                AppTextField(hint: 'Nome', controller: _nomeCtrl),
                const SizedBox(height: 14),

                // Campo Dia — abre DatePicker ao tocar
                _CampoComIcone(
                  hint: 'Dia',
                  controller: _diaCtrl,
                  icon: Icons.calendar_today_outlined,
                  onIconTap: _selecionarDia,
                ),
                const SizedBox(height: 14),

                // Campo Hora — abre TimePicker ao tocar
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

                // Descrição — campo maior
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

                // ─── Botão Publicar ───────────────────────────────────────
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

// ─── Campo com ícone clicável à direita ───────────────────────────────────────

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
