import 'package:flutter_test/flutter_test.dart';
import 'package:altar_diario/core/services/community_policy_service.dart';

void main() {
  group('CommunityPolicyService', () {
    test('Acepta textos edificantes y normales', () {
      final res1 = CommunityPolicyService.validarContenido(
          'Dios es bueno y fiel en todo tiempo.');
      expect(res1.isApproved, isTrue);

      final res2 = CommunityPolicyService.validarContenido(
          'Oremos por la sanidad de la familia Pérez.');
      expect(res2.isApproved, isTrue);
    });

    test('Rechaza solicitudes de dinero o donaciones financieras', () {
      final res1 = CommunityPolicyService.validarContenido(
          'Por favor necesito dinero para pagar mis deudas');
      expect(res1.isApproved, isFalse);
      expect(res1.reason, contains('solicitar dinero'));

      final res2 = CommunityPolicyService.validarContenido(
          'Envíenme una transferencia bancaria a mi cuenta');
      expect(res2.isApproved, isFalse);
      expect(res2.reason, contains('solicitar dinero'));
    });

    test('Rechaza palabras obscenas o vulgares', () {
      final res1 = CommunityPolicyService.validarContenido(
          'Esta persona es un pendejo');
      expect(res1.isApproved, isFalse);
      expect(res1.reason, contains('lenguaje no permitido'));
    });
  });
}
