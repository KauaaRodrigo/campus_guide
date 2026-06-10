import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'event_model.dart';
import 'event_repository.dart';
import '../services/email_service.dart';
import '../features/auth/user.dart';

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
    List<String> cursos = const [],
    List<String> periodos = const [],
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
        cursos: cursos,
        periodos: periodos,
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
      if (eventoAtualizado.statusEfetivo == EventStatus.encerrado) {
        throw Exception('Eventos encerrados não podem ser editados.');
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (eventoAtualizado.criadoPor != currentUser?.uid) {
        throw Exception('Apenas o criador deste evento pode editá-lo.');
      }

      await _repo.atualizar(eventoAtualizado);

      // NOTA: Disparo de e-mail de edição removido devido ao limite do plano gratuito do EmailJS

      await carregarEventos();
      return true;
    } catch (e) {
      _setErro('Erro ao editar evento: $e');
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> cancelarEvento(String id) async {
    _setCarregando(true);
    _setErro(null);

    try {
      final evento = await _repo.buscarPorId(id);
      if (evento == null) throw Exception('Evento não encontrado.');

      final currentUser = FirebaseAuth.instance.currentUser;
      if (evento.criadoPor != currentUser?.uid) {
        throw Exception('Apenas o criador do evento pode cancelá-lo.');
      }

      await _repo.cancelar(id);

      _notificarInscritos(
        id,
        (usuario) => EmailService.enviarAvisoCancelamentoEvento(
          usuario: usuario,
          evento: evento,
        ),
      );

      await carregarEventos();
      return true;
    } catch (e) {
      _setErro('Erro ao cancelar evento: $e');
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<void> _notificarInscritos(
    String eventoID,
    Future<void> Function(AppUser) acaoEmail,
  ) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('inscrições')
          .where('eventoID', isEqualTo: eventoID)
          .get();

      for (final doc in snapshot.docs) {
        final userID = doc.data()['userID'];
        if (userID != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(userID)
              .get();

          if (userDoc.exists && userDoc.data() != null) {
            final usuario = AppUser.fromMap(userDoc.id, userDoc.data()!);
            acaoEmail(usuario); 
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao notificar inscritos: $e');
    }
  }
}