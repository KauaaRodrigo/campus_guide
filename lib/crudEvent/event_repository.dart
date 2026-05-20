import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_model.dart';

class EventRepository {
  // Referência à coleção "eventos" no Firestore
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'eventos',
  );

  // Busca todos os eventos, ordenados por data de início
  Future<List<EventModel>> buscarTodos() async {
    final snapshot = await _col.orderBy('dataInicio').get();
    return snapshot.docs.map((doc) => EventModel.fromDoc(doc)).toList();
  }

  // Busca um evento pelo ID
  Future<EventModel?> buscarPorId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return EventModel.fromDoc(doc);
  }

  // Stream em tempo real — usado na tela de listagem para atualizar automaticamente
  Stream<List<EventModel>> stream() {
    return _col
        .orderBy('dataInicio')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => EventModel.fromDoc(doc)).toList(),
        );
  }

  // Cria um novo evento — o Firestore gera o ID automaticamente
  Future<void> criar(EventModel evento) async {
    await _col.add(evento.toMap());
  }

  // Atualiza os dados de um evento existente
  Future<void> atualizar(EventModel evento) async {
    await _col.doc(evento.id).update(evento.toMap());
  }

  // Deleta o documento do evento permanentemente
  Future<void> deletar(String id) async {
    await _col.doc(id).delete();
  }

  // Cancela o evento: muda o status sem deletar o documento
  Future<void> cancelar(String id) async {
    await _col.doc(id).update({
      'status': EventStatus.cancelado.name,
      'atualizadoEm': Timestamp.fromDate(DateTime.now()),
    });
  }
}
