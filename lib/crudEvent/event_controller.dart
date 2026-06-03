import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'event_model.dart';
import 'event_repository.dart';

class EventController extends ChangeNotifier {
  final EventRepository _repo = EventRepository();

  List<EventModel> eventos = [];
  bool carregando = false;
  String? erro;

  void _setCarregando(bool valor) {
    carregando = valor;
    notifyListeners();
  }

  void _setErro(String? mensagem) {
    erro = mensagem;
    notifyListeners();
  }

  Future<void> carregarEventos() async {
    _setCarregando(true);
    _setErro(null);

    try {
      eventos = await _repo.buscarTodos();
    } catch (e) {
      _setErro('Erro ao carregar eventos: $e');
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> criarEvento({
    required String titulo,
    required String descricao,
    required DateTime dataInicio,
    required DateTime dataFim,
    required String local,
    required int vagasTotal,
    required String curso,
    String periodo = '',
    List<Map<String, String>> ministrantes = const [],
  }) async {
    _setCarregando(true);
    _setErro(null);

    try {
      final agora = DateTime.now();
      final evento = EventModel(
        id: '',
        titulo: titulo,
        descricao: descricao,
        dataInicio: dataInicio,
        dataFim: dataFim,
        local: local,
        vagasTotal: vagasTotal,
        curso: curso,
        periodo: periodo,
        ministrantes: ministrantes,
        criadoPor: FirebaseAuth.instance.currentUser?.uid ?? '',
        criadoEm: agora,
        atualizadoEm: agora,
      );

      await _repo.criar(evento);
      await carregarEventos();
      return true;
    } catch (e) {
      _setErro('Erro ao criar evento: $e');
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> editarEvento(EventModel eventoAtualizado) async {
    _setCarregando(true);
    _setErro(null);

    try {
      await _repo.atualizar(eventoAtualizado);
      await carregarEventos();
      return true;
    } catch (e) {
      _setErro('Erro ao editar evento: $e');
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> deletarEvento(String id) async {
    _setCarregando(true);
    _setErro(null);

    try {
      await _repo.deletar(id);
      eventos.removeWhere((evento) => evento.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _setErro('Erro ao deletar evento: $e');
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> cancelarEvento(String id) async {
    _setCarregando(true);
    _setErro(null);

    try {
      await _repo.cancelar(id);
      await carregarEventos();
      return true;
    } catch (e) {
      _setErro('Erro ao cancelar evento: $e');
      return false;
    } finally {
      _setCarregando(false);
    }
  }
}
