import 'package:supabase_flutter/supabase_flutter.dart';

class PixCharge {
  final String mercadoPagoOrderId;
  final String status;
  final String qrCode;
  final String qrCodeBase64;
  final String ticketUrl;

  const PixCharge({
    required this.mercadoPagoOrderId,
    required this.status,
    required this.qrCode,
    required this.qrCodeBase64,
    required this.ticketUrl,
  });

  factory PixCharge.fromMap(Map<String, dynamic> map) {
    return PixCharge(
      mercadoPagoOrderId: '${map['order_id'] ?? ''}',
      status: '${map['status'] ?? ''}',
      qrCode: '${map['qr_code'] ?? ''}',
      qrCodeBase64: '${map['qr_code_base64'] ?? ''}',
      ticketUrl: '${map['ticket_url'] ?? ''}',
    );
  }
}

class PixService {
  final SupabaseClient client;
  PixService([SupabaseClient? client]) : client = client ?? Supabase.instance.client;

  Future<PixCharge> createCharge({
    required String orderId,
    required double amount,
    required String payerEmail,
  }) async {
    final response = await client.functions.invoke(
      'create-pix',
      body: {
        'order_id': orderId,
        'amount': amount,
        'payer_email': payerEmail.trim(),
      },
    );

    if (response.status < 200 || response.status >= 300) {
      throw Exception('Falha ao gerar Pix (${response.status}).');
    }

    final data = response.data;
    if (data is! Map) {
      throw Exception('Resposta inválida ao gerar Pix.');
    }

    final charge = PixCharge.fromMap(Map<String, dynamic>.from(data));
    if (charge.qrCode.isEmpty && charge.qrCodeBase64.isEmpty && charge.ticketUrl.isEmpty) {
      throw Exception('Mercado Pago não devolveu dados do Pix.');
    }
    return charge;
  }
}
