import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:campus_guide/crudEvent/event_model.dart';
import 'package:campus_guide/features/auth/user.dart';

class EmailService {
  static const String _serviceId = 'campus_guide';
  static const String _templateId = 'template_lqsep6t';
  static const String _templateCancelamentoId = 'template_cancelamento';
  static const String _publicKey = 'OcdXVe1cna0TpVXcf';

  static const String _endpoint =
      'https://api.emailjs.com/api/v1.0/email/send';

  /// Envia e-mail de confirmação de inscrição para [usuario] no [evento].
  ///
  /// Retorna `true` se o e-mail foi aceito pelo EmailJS (HTTP 200).
  /// Falhas de rede ou credenciais inválidas retornam `false` silenciosamente
  /// — a inscrição já foi salva no Firestore e não deve ser afetada.
  static Future<bool> enviarConfirmacaoInscricao({
    required AppUser usuario,
    required EventModel evento,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'service_id':  _serviceId,
              'template_id': _templateId,
              'user_id':     _publicKey,
              'template_params': {
                'to_name':          usuario.name,
                'to_email':         usuario.email,
                'event_name':       evento.titulo,
                'event_date':       _formatarData(evento.dataInicio),
                'event_time_start': _formatarHora(evento.dataInicio),
                'event_time_end':   _formatarHora(evento.dataFim),
                'event_location':   evento.local,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (_) {
      // Falha de rede não impede a inscrição — apenas loga silencamente.
      return false;
    }
  }

  static Future<bool> enviarAvisoCancelamentoEvento({
    required AppUser usuario,
    required EventModel evento,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'service_id': _serviceId,
              'template_id': _templateCancelamentoId,
              'user_id': _publicKey,
              'template_params': {
                'to_name': usuario.name,
                'to_email': usuario.email,
                'event_name': evento.titulo,
                'event_date': _formatarData(evento.dataInicio),
                'event_time_start': _formatarHora(evento.dataInicio),
                'event_time_end': _formatarHora(evento.dataFim),
                'event_location': evento.local,
              },
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static String _formatarData(DateTime dt) =>
      '${_pad(dt.day)}/${_pad(dt.month)}/${dt.year}';

  static String _formatarHora(DateTime dt) =>
      '${_pad(dt.hour)}:${_pad(dt.minute)}';

  static String _pad(int n) => n.toString().padLeft(2, '0');
}