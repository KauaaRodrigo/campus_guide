import 'package:cloud_firestore/cloud_firestore.dart';

import 'event_model.dart';

class EventRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'eventos',
  );

  Future<List<EventModel>> buscarTodos() async {
    final snapshot = await _col.orderBy('dataInicio').get();
    final eventos = snapshot.docs
        .map((doc) => EventModel.fromDoc(doc))
        .toList();
    final eventosVisiveis = eventos
        .where((evento) => evento.isVisivelNaListagem)
        .toList();
    return _ordenarEventos(eventosVisiveis);
  }

  Future<EventModel?> buscarPorId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return EventModel.fromDoc(doc);
  }

  Stream<List<EventModel>> stream() {
    return _col.orderBy('dataInicio').snapshots().map((snapshot) {
      final eventos = snapshot.docs
          .map((doc) => EventModel.fromDoc(doc))
          .toList();
      final eventosVisiveis = eventos
          .where((evento) => evento.isVisivelNaListagem)
          .toList();
      return _ordenarEventos(
        eventosVisiveis,
      ); // eventos ordenados pela data e hora
    });
  }

  Future<void> criar(EventModel evento) async {
    await _col.add(evento.toMap());
  }

  Future<void> atualizar(EventModel evento) async {
    await _col.doc(evento.id).update(evento.toMap());
  }

  Future<void> cancelar(String id) async {
    await _col.doc(id).update({
      'status': EventStatus.ocultado.name, // Mata o evento imediatamente
      'isOcultoSistema': true, // Garante a remoção imediata das listas
      'dataCancelamento': Timestamp.fromDate(DateTime.now()),
      'atualizadoEm': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<List<EventModel>> buscarHistoricoDocente(String userId) async {
    // Busca no banco SOMENTE os eventos que este usuário específico criou.
    final snapshot = await _col.where('criadoPor', isEqualTo: userId).get();

    final eventosHistorico = <EventModel>[];

    for (final doc in snapshot.docs) {
      // AQUI ESTÁ A LÓGICA: Nós NÃO usamos o "if (isOcultoSistema) continue;".
      // O docente tem o direito de ver o próprio histórico completo,
      // incluindo o que ele cancelou ou o que já foi encerrado.
      eventosHistorico.add(EventModel.fromDoc(doc));
    }

    // Ordenar do mais recente para o mais antigo faz mais sentido em um histórico.
    eventosHistorico.sort((a, b) => b.dataInicio.compareTo(a.dataInicio));

    return eventosHistorico;
  }

  Stream<List<EventModel>> streamHistoricoDocente(String userId) {
    return _col.where('criadoPor', isEqualTo: userId).snapshots().map((
      snapshot,
    ) {
      final eventosHistorico = snapshot.docs
          .map((doc) => EventModel.fromDoc(doc))
          .toList();

      eventosHistorico.sort((a, b) => b.dataInicio.compareTo(a.dataInicio));
      return eventosHistorico;
    });
  }

  //ordenados pela data e hora do evento
  List<EventModel> _ordenarEventos(List<EventModel> eventos) {
    final hoje = DateTime.now();
    final amanha = hoje.add(const Duration(days: 1));

    final eventosHoje = <EventModel>[];
    final eventosAmanha = <EventModel>[];
    final eventosOutrasDatas = <EventModel>[];
    final eventosCancelados = <EventModel>[];

    for (final evento in eventos) {
      if (evento.status == EventStatus.cancelado) {
        eventosCancelados.add(evento);
      } else {
        final data = evento.dataInicio;
        final mesmoAno = data.year == hoje.year;
        final mesmoMes = data.month == hoje.month;
        final mesmoDay = data.day == hoje.day;

        if (mesmoAno && mesmoMes && mesmoDay) {
          eventosHoje.add(evento);
        } else if (data.year == amanha.year &&
            data.month == amanha.month &&
            data.day == amanha.day) {
          eventosAmanha.add(evento);
        } else {
          eventosOutrasDatas.add(evento);
        }
      }
    }

    eventosHoje.sort((a, b) => a.dataInicio.compareTo(b.dataInicio));
    eventosAmanha.sort((a, b) => a.dataInicio.compareTo(b.dataInicio));
    eventosOutrasDatas.sort((a, b) => a.dataInicio.compareTo(b.dataInicio));
    eventosCancelados.sort((a, b) => a.dataInicio.compareTo(b.dataInicio));

    return [
      ...eventosHoje,
      ...eventosAmanha,
      ...eventosOutrasDatas,
      ...eventosCancelados,
    ];
  }
}
