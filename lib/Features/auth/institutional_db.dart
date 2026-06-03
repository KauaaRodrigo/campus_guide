/// Base institucional em memória usada apenas para validação local/testes.
///
/// Fornece um lookup simples por `matricula` e um método `validate` que
/// checa se a matrícula existe e se o email informado corresponde ao
/// registro institucional. Lança `InstitutionalException` em caso de erro.
class InstitutionalDB {
  InstitutionalDB._();

  static const _records = <String, _InstitutionalRecord>{
    '20210001': _InstitutionalRecord(
      matricula: '20210001',
      email: 'joao.silva@instituicao.edu.br',
      name: 'João Silva',
      role: 'aluno',
    ),
    '20210002': _InstitutionalRecord(
      matricula: '20210002',
      email: 'maria.souza@instituicao.edu.br',
      name: 'Maria Souza',
      role: 'aluno',
    ),
    '1231112899': _InstitutionalRecord(
      matricula: '1231112899',
      email: 'jodantasjunior@gmail.com',
      name: 'José Alves',
      role: 'aluno',
    ),
    '1234827891': _InstitutionalRecord(
      matricula: '1234827891',
      email: 'josealvesdantasjunior@gmail.com',
      name: 'José Júnior',
      role: 'aluno',
    ),
    '1222190106': _InstitutionalRecord(
      matricula: '1222190106',
      email: 'kauarodrigo1@gmail.com',
      name: 'Kauã Rodrigo',
      role: 'docente',
    ),
    '1234827211': _InstitutionalRecord(
      matricula: '1234827211',
      email: 'davireis909@gmail.com',
      name: 'Davi Reis',
      role: 'aluno',
    ),
    'DOC001': _InstitutionalRecord(
      matricula: 'DOC001',
      email: 'ana.lima@instituicao.edu.br',
      name: 'Ana Lima',
      role: 'docente',
    ),
    'DOC002': _InstitutionalRecord(
      matricula: 'DOC002',
      email: 'pedro.costa@instituicao.edu.br',
      name: 'Pedro Costa',
      role: 'docente',
    ),
    '1231110624': _InstitutionalRecord(
      matricula: '1231110624',
      email: 'luiz.armando@unit.com.br',
      name: 'Luiz Armando',
      role: 'docente',
    ),
  };

  /// Retorna o registro institucional correspondente à `matricula`, ou `null`
  /// se não encontrado.
  ///
  /// Observação: este método expõe um tipo privado (`_InstitutionalRecord`)
  /// porque a base é interna ao pacote; para uso público preferir retornar
  /// dados serializáveis ou converter para `AppUser`.
  static _InstitutionalRecord? lookup(String matricula) {
    return _records[matricula.trim().toUpperCase()] ??
        _records[matricula.trim()];
  }

  /// Valida que a `matricula` existe e que o `email` corresponde ao registro
  /// institucional. Retorna o registro encontrado em caso de sucesso ou lança
  /// `InstitutionalException` em caso de erro.
  static _InstitutionalRecord validate({
    required String matricula,
    required String email,
  }) {
    final record = lookup(matricula);

    if (record == null) {
      throw InstitutionalException.unknownMatricula();
    }

    if (record.email.toLowerCase() != email.trim().toLowerCase()) {
      throw InstitutionalException.emailMismatch();
    }

    return record;
  }
}

/// Representação interna de um registro institucional.
class _InstitutionalRecord {
  final String matricula;
  final String email;
  final String name;

  final String role;

  const _InstitutionalRecord({
    required this.matricula,
    required this.email,
    required this.name,
    required this.role,
  });
}

class InstitutionalException implements Exception {
  final String message;
  const InstitutionalException(this.message);

  factory InstitutionalException.unknownMatricula() =>
      const InstitutionalException(
        'Matrícula não encontrada na base institucional.',
      );

  factory InstitutionalException.emailMismatch() =>
      const InstitutionalException(
        'O email não corresponde à matrícula informada.',
      );

  @override
  String toString() => message;
}
