import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_model.dart';

class EventRepository {
  final CollectionReference _col = FirebaseFirestore.instance.collection(
    'eventos',
  );

  Future<List<EventModel>> buscarTodos() async {
    final snapshot = await _col.orderBy('dataInicio').get();
    final eventosVisiveis = <EventModel>[];
    
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      // Filtra eventos ocultados automaticamente após a janela de 4 dias
      if (data['isOcultoSistema'] == true) continue;
      
      final evento = EventModel.fromDoc(doc);
      if (evento.isVisivelNaListagem) {
        eventosVisiveis.add(evento);
      }
    }
    return _ordenarEventos(eventosVisiveis);
  }

  Future<EventModel?> buscarPorId(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return EventModel.fromDoc(doc);
  }

  Stream<List<EventModel>> stream() {
    return _col
        .orderBy('dataInicio')
        .snapshots()
        .map(
          (snapshot) {
            final eventosVisiveis = <EventModel>[];
            
            for (final doc in snapshot.docs) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['isOcultoSistema'] == true) continue;
              
              final evento = EventModel.fromDoc(doc);
              if (evento.isVisivelNaListagem) {
                eventosVisiveis.add(evento);
              }
            }
            return _ordenarEventos(eventosVisiveis);
          },
        );
  }

  Future<void> criar(EventModel evento) async {
    await _col.add(evento.toMap());
  }

  Future<void> atualizar(EventModel evento) async {
    await _col.doc(evento.id).update(evento.toMap());
  }

  Future<void> cancelar(String id) async {
    await _col.doc(id).update({
      'status': EventStatus.cancelado.name,
      'dataCancelamento': Timestamp.fromDate(DateTime.now()),
      'atualizadoEm': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// REGRA: Eventos cancelados devem permanecer visíveis por 4 dias e depois receber uma flag oculta.
  /// O status "Cancelado" não é modificado.
  Future<void> atualizarEventosOcultados() async {
    final snapshot = await _col.where('status', isEqualTo: EventStatus.cancelado.name).get();
    final agora = DateTime.now();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['isOcultoSistema'] == true) continue;

      final dataCancelamentoTimestamp = data['dataCancelamento'] as Timestamp?;

      if (dataCancelamentoTimestamp != null) {
        final dataCancelamento = dataCancelamentoTimestamp.toDate();
        final limiteVisibilidade = dataCancelamento.add(const Duration(days: 4));

        if (agora.isAfter(limiteVisibilidade)) {
          await _col.doc(doc.id).update({
            'isOcultoSistema': true,
            'atualizadoEm': Timestamp.fromDate(agora),
          });
        }
      }
    }
  }

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