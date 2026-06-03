import 'package:flutter/material.dart';

import 'enrollment_repository.dart';

class EnrollmentController extends ChangeNotifier {
  final EnrollmentRepository _repo = EnrollmentRepository();

  List<String> eventosInscritosIds = [];
  bool carregando = false;
  String? erro;

  bool estaInscrito(String eventoID) => eventosInscritosIds.contains(eventoID);

  void _setCarregando(bool valor) {
    carregando = valor;
    notifyListeners();
  }

  void _setErro(String? mensagem) {
    erro = mensagem;
    notifyListeners();
  }

  Future<void> carregarInscricoes(String userID) async {
    _setCarregando(true);
    _setErro(null);

    try {
      eventosInscritosIds = await _repo.buscarEventoIdsPorUsuario(userID);
    } catch (e) {
      _setErro('Erro ao carregar inscrições: $e');
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> inscrever({
    required String userID,
    required String eventoID,
  }) async {
    _setCarregando(true);
    _setErro(null);

    try {
      await _repo.inscrever(userID: userID, eventoID: eventoID);
      await carregarInscricoes(userID);
      return true;
    } catch (e) {
      _setErro('Erro ao realizar inscrição: $e');
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<bool> desinscrever({
    required String userID,
    required String eventoID,
  }) async {
    _setCarregando(true);
    _setErro(null);

    try {
      await _repo.desinscrever(userID: userID, eventoID: eventoID);
      await carregarInscricoes(userID);
      return true;
    } catch (e) {
      _setErro('Erro ao cancelar inscrição: $e');
      return false;
    } finally {
      _setCarregando(false);
    }
  }

  Future<List<Map<String, String>>> buscarInscritosDoEvento(
    String eventoID,
  ) async {
    _setCarregando(true);
    _setErro(null);

    try {
      return await _repo.buscarInscritosDoEvento(eventoID);
    } catch (e) {
      _setErro('Erro ao buscar inscritos: $e');
      return [];
    } finally {
      _setCarregando(false);
    }
  }
}
