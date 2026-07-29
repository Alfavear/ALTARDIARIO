import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PolicyValidationResult {
  final bool isApproved;
  final String? reason;

  const PolicyValidationResult({required this.isApproved, this.reason});
}

class CommunityPolicyService {
  // Palabras y expresiones prohibidas para cobro/solicitudes de dinero
  static final List<String> _forbiddenFinancialTerms = [
    'pedir dinero',
    'necesito dinero',
    'necesito plata',
    'transferencia bancaria',
    'cuenta bancaria',
    'zelle',
    'paypal',
    'yape',
    'plin',
    'cbu',
    'alias bancario',
    'donación económica',
    'donaciones de dinero',
    'depóstenme',
    'depostenme',
    'prestamo de dinero',
    'préstamo de dinero',
    'envíame dinero',
    'enviame dinero',
    'dame plata',
  ];

  // Palabras obscenas / vulgares comunes en español
  static final List<String> _forbiddenObsceneTerms = [
    'puta',
    'puto',
    'mierda',
    'carajo',
    'pendejo',
    'pendeja',
    'bastardo',
    'malparido',
    'malparida',
    'hijueputa',
    'verga',
    'gonorrea',
    'chupame',
    'coño',
    'hostia',
    'imbecil',
    'imbécil',
    'estupido',
    'estúpida',
    'estúpido',
  ];

  /// Valida si el texto cumple con la política comunitaria de edificación
  static PolicyValidationResult validarContenido(String texto) {
    final lower = texto.toLowerCase();

    for (final term in _forbiddenFinancialTerms) {
      if (lower.contains(term)) {
        return const PolicyValidationResult(
          isApproved: false,
          reason:
              'Está estrictamente prohibido solicitar dinero, préstamos o donaciones económicas dentro de la comunidad.',
        );
      }
    }

    for (final term in _forbiddenObsceneTerms) {
      final words = lower.split(RegExp(r'\s+'));
      if (words.contains(term) || lower.contains(term)) {
        return const PolicyValidationResult(
          isApproved: false,
          reason:
              'El contenido contiene lenguaje no permitido. AltarDiario exige un lenguaje respetuoso y libre de palabras obscenas.',
        );
      }
    }

    return const PolicyValidationResult(isApproved: true);
  }

  /// Muestra el modal con las Normas de la Comunidad
  static void showCommunityRulesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Icon(Icons.gavel_rounded, color: AppTheme.primaryBlue, size: 36),
            SizedBox(height: 8),
            Text(
              'Normas de la Comunidad',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppTheme.primaryBlue,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Edificación Espiritual & Respeto Mutuo',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RuleTile(
                icon: Icons.money_off_rounded,
                title: 'Prohibido pedir dinero',
                description:
                    'Queda estrictamente prohibida la solicitud de dinero, préstamos, donaciones económicas o datos bancarios.',
              ),
              SizedBox(height: 12),
              _RuleTile(
                icon: Icons.record_voice_over_rounded,
                title: 'Lenguaje respetuoso',
                description:
                    'No se permite el uso de palabras obscenas, insultos, lenguaje vulgar o discriminación.',
              ),
              SizedBox(height: 12),
              _RuleTile(
                icon: Icons.auto_awesome,
                title: 'Fin único: Edificar Vidas',
                description:
                    'AltarDiario tiene como único propósito compartir la Palabra de Dios, orar unos por otros y fortalecer la fe.',
              ),
              SizedBox(height: 12),
              _RuleTile(
                icon: Icons.security_rounded,
                title: 'Moderación Activa',
                description:
                    'El contenido que incumpla estas normas será eliminado y la cuenta suspendida.',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Entendido y Acepto'),
          ),
        ],
      ),
    );
  }

  /// Construye un banner discreto e informativo para formularios
  static Widget buildPolicyBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined,
              color: AppTheme.primaryBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                children: [
                  TextSpan(
                    text: 'Norma comunitaria: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue),
                  ),
                  TextSpan(
                    text:
                        'Prohibido pedir dinero o usar lenguaje obsceno. El fin único es edificar vidas. ',
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () => showCommunityRulesDialog(context),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.info_outline,
                  color: AppTheme.primaryBlue, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _RuleTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 2),
              Text(description,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
