import 'package:cloud_firestore/cloud_firestore.dart';

enum EventStatus { ativo, encerrado, cancelado, ocultado } 

class EventModel {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String local;
  final int vagasTotal;
  final int vagasOcupadas;
  /// Lista de cursos para os quais o evento é destinado.
  final List<String> cursos;

  /// Lista de períodos para os quais o evento é destinado.
  final List<String> periodos;

  final List<Map<String, String>> ministrantes;
  final EventStatus status;
  final String criadoPor;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final DateTime? dataCancelamento;

  const EventModel({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.dataInicio,
    required this.dataFim,
    required this.local,
    required this.vagasTotal,
    this.vagasOcupadas = 0,
    this.cursos = const [],
    this.periodos = const [],
    this.ministrantes = const [],
    this.status = EventStatus.ativo,
    this.criadoPor = '',
    required this.criadoEm,
    required this.atualizadoEm,
    this.dataCancelamento,
  });

  /// Status efetivo calculado em tempo real, sem depender de escrita no Firestore.
  ///
  /// Um evento gravado como [EventStatus.ativo] mas cujo [dataFim] já passou
  /// é tratado automaticamente como [EventStatus.encerrado] para toda lógica
  /// de negócio (exibição, inscrição, visibilidade).  Isso elimina a necessidade
  /// de Cloud Functions ou qualquer job de atualização de status.
  int get vagasRestantes => vagasTotal - vagasOcupadas;

 
  EventStatus get statusEfetivo {
    if (status == EventStatus.cancelado) return status;
    if (status == EventStatus.ocultado) return status;
    if (status != EventStatus.ativo) return status;
    return DateTime.now().isAfter(dataFim)
        ? EventStatus.encerrado
        : EventStatus.ativo;
  }

  bool get estaAberto => statusEfetivo == EventStatus.ativo && vagasRestantes > 0;

 
  bool get isOculto {
    final agora = DateTime.now();
    // Evento ainda dentro do período de realização: sempre visível.
    if (statusEfetivo == EventStatus.ativo) return false;

    // Eventos encerrados já passaram e não devem ser exibidos.
    if (statusEfetivo == EventStatus.encerrado) return true;

    // Cancelado: visível por 4 dias a partir de dataCancelamento.
    if (status == EventStatus.cancelado) {
      if (dataCancelamento == null) return false;
      final limiteVisibilidade = dataCancelamento!.add(const Duration(days: 4));
      return agora.isAfter(limiteVisibilidade);
    }

    // Ocultado: sempre oculto.
    if (statusEfetivo == EventStatus.ocultado) return true;

    return false;
  }

  /// Retorna true se o evento deve aparecer na listagem pública.
  bool get isVisivelNaListagem => !isOculto;

  String get statusTexto {
    if (status == EventStatus.cancelado) return 'Cancelado';
    if (statusEfetivo == EventStatus.ocultado) return 'Ocultado';
    if (statusEfetivo == EventStatus.encerrado) return 'Encerrado';
    if (vagasRestantes <= 0) return 'Fechado';
    return 'Disponível ($vagasRestantes vagas)';
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'local': local,
      'vagasTotal': vagasTotal,
      'vagasOcupadas': vagasOcupadas,
      'cursos': cursos,
      'periodos': periodos,
      'ministrantes': ministrantes,
      'status': status.name,
      'criadoPor': criadoPor,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'atualizadoEm': Timestamp.fromDate(atualizadoEm),
      'dataCancelamento': dataCancelamento != null
          ? Timestamp.fromDate(dataCancelamento!)
          : null,
    };
  }

  factory EventModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final dataCancelamentoTimestamp = data['dataCancelamento'] as Timestamp?;

    return EventModel(
      id: doc.id,
      titulo: data['titulo'] ?? '',
      descricao: data['descricao'] ?? '',
      dataInicio: (data['dataInicio'] as Timestamp).toDate(),
      dataFim: (data['dataFim'] as Timestamp).toDate(),
      local: data['local'] ?? '',
      vagasTotal: data['vagasTotal'] ?? 0,
      vagasOcupadas: data['vagasOcupadas'] ?? 0,
      // Compatibilidade retroativa: aceita List (novo) e String (legado).
      cursos: _parseStringOrList(data['cursos'] ?? data['curso']),
      periodos: _parseStringOrList(data['periodos'] ?? data['periodo']),
      ministrantes: List<Map<String, String>>.from(
        (data['ministrantes'] as List? ?? []).map(
          (ministrante) => Map<String, String>.from(ministrante as Map),
        ),
      ),
      status: EventStatus.values.byName(data['status'] ?? 'ativo'),
      criadoPor: data['criadoPor'] ?? '',
      criadoEm: (data['criadoEm'] as Timestamp).toDate(),
      atualizadoEm: (data['atualizadoEm'] as Timestamp).toDate(),
      dataCancelamento:
          dataCancelamentoTimestamp != null ? dataCancelamentoTimestamp.toDate() : null,
    );
  }

  /// Converte String legada ou List<dynamic> nova em List<String>.
  static List<String> _parseStringOrList(dynamic value) {
    if (value == null) return [];
    if (value is String) return value.isEmpty ? [] : [value];
    if (value is List) return List<String>.from(value.map((e) => e.toString()));
    return [];
  }

  EventModel copyWith({
    String? titulo,
    String? descricao,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? local,
    int? vagasTotal,
    int? vagasOcupadas,
    List<String>? cursos,
    List<String>? periodos,
    List<Map<String, String>>? ministrantes,
    EventStatus? status,
    String? criadoPor,
    DateTime? dataCancelamento,
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
      cursos: cursos ?? this.cursos,
      periodos: periodos ?? this.periodos,
      ministrantes: ministrantes ?? this.ministrantes,
      status: status ?? this.status,
      criadoPor: criadoPor ?? this.criadoPor,
      criadoEm: criadoEm,
      atualizadoEm: DateTime.now(),
      dataCancelamento: dataCancelamento ?? this.dataCancelamento,
    );
  }
}