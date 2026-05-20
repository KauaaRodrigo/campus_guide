import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus { ativo, cancelado }

class EventModel {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String local;
  final int vagasTotal;
  final int vagasOcupadas;
  final String curso;
  final String periodo; // ex: "2º período", "Noturno", etc.
  final List<Map<String, String>> ministrantes; // [{name, image}]
  final EventStatus status;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const EventModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataInicio,
    required this.dataFim,
    required this.local,
    required this.vagasTotal,
    this.vagasOcupadas = 0,
    required this.curso,
    this.periodo = '',
    this.ministrantes = const [],
    this.status = EventStatus.ativo,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  // Campos derivados — calculados, sem precisar salvar no banco
  int get vagasRestantes => vagasTotal - vagasOcupadas;
  bool get estaAberto => status == EventStatus.ativo && vagasRestantes > 0;

  String get statusTexto {
    if (status == EventStatus.cancelado) return 'Cancelado';
    if (vagasRestantes <= 0) return 'Esgotado';
    return 'Disponível ($vagasRestantes vagas)';
  }

  // Converte para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'local': local,
      'vagasTotal': vagasTotal,
      'vagasOcupadas': vagasOcupadas,
      'curso': curso,
      'periodo': periodo,
      'ministrantes': ministrantes,
      'status': status.name,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm': Timestamp.fromDate(atualizadoEm),
    };
  }

  // Constrói um EventModel a partir de um documento do Firestore
  factory EventModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      dataInicio: (data['dataInicio'] as Timestamp).toDate(),
      dataFim: (data['dataFim'] as Timestamp).toDate(),
      local: data['local'] ?? '',
      vagasTotal: data['vagasTotal'] ?? 0,
      vagasOcupadas: data['vagasOcupadas'] ?? 0,
      curso: data['curso'] ?? '',
      periodo: data['periodo'] ?? '',
      ministrantes: List<Map<String, String>>.from(
        (data['ministrantes'] as List? ?? []).map(
          (m) => Map<String, String>.from(m as Map),
        ),
      ),
      status: EventStatus.values.byName(data['status'] ?? 'ativo'),
      criadoEm: (data['criadoEm'] as Timestamp).toDate(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp).toDate(),
    );
  }

  // Cria uma cópia com campos alterados — usado na edição
  EventModel copyWith({
    String? titulo,
    String? descricao,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? local,
    int? vagasTotal,
    int? vagasOcupadas,
    String? curso,
    String? periodo,
    List<Map<String, String>>? ministrantes,
    EventStatus? status,
  }) {
    return EventModel(
      id: id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      local: local ?? this.local,
      vagasTotal: vagasTotal ?? this.vagasTotal,
      vagasOcupadas: vagasOcupadas ?? this.vagasOcupadas,
      curso: curso ?? this.curso,
      periodo: periodo ?? this.periodo,
      ministrantes: ministrantes ?? this.ministrantes,
      status: status ?? this.status,
      criadoEm: criadoEm,
      atualizadoEm: DateTime.now(),
    );
  }
}
