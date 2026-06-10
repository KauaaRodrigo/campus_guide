import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:campus_guide/features/auth/user.dart';

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

    // O runTransaction garante a consistência e resolve os acessos simultâneos
    await _db.runTransaction((transaction) async {
      final inscricaoDoc = await transaction.get(inscricaoRef);
      
      // REGRA: Usuário não pode se inscrever mais de uma vez no mesmo evento
      if (inscricaoDoc.exists) {
        throw Exception('Você já está inscrito neste evento.');
      }

      final eventoDoc = await transaction.get(eventoRef);
      if (!eventoDoc.exists) {
        throw Exception('Evento não encontrado.');
      }

      final data = eventoDoc.data() as Map<String, dynamic>;
      final status = data['status'] ?? EventStatus.ativo.name;
      final vagasTotal = data['vagasTotal'] ?? 0;
      final vagasOcupadas = data['vagasOcupadas'] ?? 0;
      final Timestamp? dataInicioTimestamp = data['dataInicio'];

      if (status == EventStatus.cancelado.name) {
        throw Exception('Este evento está cancelado.');
      }

      // REGRA: Devem existir vagas remanescentes
      if (vagasOcupadas >= vagasTotal) {
        throw Exception('Não há vagas disponíveis para este evento.');
      }

      // REGRA: Inscrições podem ocorrer até 10 min antes do começo do evento
      if (dataInicioTimestamp != null) {
        final dataInicio = dataInicioTimestamp.toDate();
        final dataLimiteInscricao = dataInicio.subtract(const Duration(minutes: 10));
        
        if (DateTime.now().isAfter(dataLimiteInscricao)) {
          throw Exception(
            'Inscrições encerradas. O prazo finalizou 10 minutos antes do início do evento.'
          );
        }
      }

      // Se passou em todas as regras, consolida a inscrição
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

  Future<List<AppUser>> buscarUsuariosInscritosDoEvento( //avisa os inscritos no email
    String eventoID,
  ) async {
    final snapshot = await _col.where('eventoID', isEqualTo: eventoID).get();
    final usuarios = <AppUser>[];

    for (final doc in snapshot.docs) {
      final userID = doc.data()['userID'] as String?;
      if (userID == null || userID.isEmpty) continue;

      final userDoc = await _db.collection('usuarios').doc(userID).get();
      if (!userDoc.exists) continue;

      final userData = userDoc.data();
      if (userData == null) continue;

      usuarios.add(AppUser.fromMap(userDoc.id, userData));
    }

    return usuarios;
  }

  /// Stream em tempo real dos IDs de eventos em que [userID] está inscrito.
  /// Usado por [MyEventsPage] para atualização automática sem reload.
  Stream<List<String>> streamEventoIdsPorUsuario(String userID) {
    return _col
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => doc.data()['eventoID'] as String?)
              .whereType<String>()
              .toList(),
        );
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