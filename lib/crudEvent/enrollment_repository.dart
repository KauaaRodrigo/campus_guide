import 'package:cloud_firestore/cloud_firestore.dart';

import 'event_model.dart';

class EnrollmentRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _col = _db.collection(
    'inscrições',
  );

  String _docId(String userID, String eventoID) => '${userID}_$eventoID';

  Future<void> inscrever({
    required String userID,
    required String eventoID,
  }) async {
    final inscricaoRef = _col.doc(_docId(userID, eventoID));
    final eventoRef = _db.collection('eventos').doc(eventoID);

    await _db.runTransaction((transaction) async {
      final inscricaoDoc = await transaction.get(inscricaoRef);
      if (inscricaoDoc.exists) return;

      final eventoDoc = await transaction.get(eventoRef);
      if (!eventoDoc.exists) {
        throw Exception('Evento não encontrado.');
      }

      final data = eventoDoc.data() as Map<String, dynamic>;
      final status = data['status'] ?? EventStatus.ativo.name;
      final vagasTotal = data['vagasTotal'] ?? 0;
      final vagasOcupadas = data['vagasOcupadas'] ?? 0;

      if (status == EventStatus.cancelado.name) {
        throw Exception('Este evento está cancelado.');
      }

      if (vagasOcupadas >= vagasTotal) {
        throw Exception('Não há vagas disponíveis para este evento.');
      }

      transaction.set(inscricaoRef, {
        'userID': userID,
        'eventoID': eventoID,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      transaction.update(eventoRef, {
        'vagasOcupadas': vagasOcupadas + 1,
        'atualizadoEm': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  Future<void> desinscrever({
    required String userID,
    required String eventoID,
  }) async {
    final inscricaoRef = _col.doc(_docId(userID, eventoID));
    final eventoRef = _db.collection('eventos').doc(eventoID);

    await _db.runTransaction((transaction) async {
      final inscricaoDoc = await transaction.get(inscricaoRef);
      if (!inscricaoDoc.exists) return;

      final eventoDoc = await transaction.get(eventoRef);
      final vagasOcupadas = eventoDoc.exists
          ? ((eventoDoc.data() as Map<String, dynamic>)['vagasOcupadas'] ?? 0)
          : 0;

      transaction.delete(inscricaoRef);
      if (eventoDoc.exists) {
        transaction.update(eventoRef, {
          'vagasOcupadas': vagasOcupadas > 0 ? vagasOcupadas - 1 : 0,
          'atualizadoEm': Timestamp.fromDate(DateTime.now()),
        });
      }
    });
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> buscarPorUsuario(
    String userID,
  ) async {
    final snapshot = await _col.where('userID', isEqualTo: userID).get();
    return snapshot.docs;
  }

  Future<List<String>> buscarEventoIdsPorUsuario(String userID) async {
    final docs = await buscarPorUsuario(userID);
    return docs
        .map((doc) => doc.data()['eventoID'] as String?)
        .whereType<String>()
        .toList();
  }

  Future<List<Map<String, String>>> buscarInscritosDoEvento(
    String eventoID,
  ) async {
    final snapshot = await _col.where('eventoID', isEqualTo: eventoID).get();

    final inscritos = <Map<String, String>>[];
    for (final doc in snapshot.docs) {
      final userID = doc.data()['userID'] as String?;
      if (userID == null || userID.isEmpty) continue;

      final userDoc = await _db.collection('usuarios').doc(userID).get();
      final userData = userDoc.data();
      if (userData == null) continue;

      inscritos.add({
        'name': userData['name'] ?? '',
        'registration': userData['matricula'] ?? '',
        'course': userData['curso'] ?? '',
      });
    }

    return inscritos;
  }
}
