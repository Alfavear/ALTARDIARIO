import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'main_navigation_view.dart';

import '../../data/models/usuario.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInAnonymously() async {
    final nameCtrl = TextEditingController();
    final guestName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_pin, color: AppTheme.primaryBlue),
            SizedBox(width: 8),
            Text('Bienvenido Invitado',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ingresa tu nombre o apodo para identificarte en las reflexiones y oraciones comunitarias:',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: 'Ej. Juan Carlos',
                prefixIcon: const Icon(Icons.badge_outlined,
                    color: AppTheme.primaryBlue),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Cancelar',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final val = nameCtrl.text.trim();
              Navigator.pop(ctx, val.isNotEmpty ? val : 'Invitado');
            },
            child:
                const Text('Ingresar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (guestName == null) return;

    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authServiceProvider).signInAnon();
      final uid = user?.uid ?? (await ref.read(authServiceProvider).getLocalUid());

      if (uid != null) {
        if (user == null) {
          ref.read(localUidProvider.notifier).setUid(uid);
        }
        final formattedName = '$guestName (Invitado)';
        final storage = ref.read(storageProvider);
        await storage.setUserName(formattedName);

        final firestoreService = ref.read(firestoreServiceProvider);
        await firestoreService.crearOActualizarUsuario(
          Usuario(
            id: uid,
            nombre: formattedName,
            email: 'invitado@altardiario.app',
            fotoUrl: '',
            siguiendo: [],
            seguidores: [],
            badges: ['bienvenida'],
          ),
        );
      }
      if (mounted) _navigateToMain();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationView()),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user != null && mounted) {
        _navigateToMain();
      } else if (mounted) {
        // signInWithRedirect iniciado - la navegación ocurre tras recarga
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Redirigiendo a Google... Completa el inicio de sesión.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg;
        switch (e.code) {
          case 'auth/popup-blocked':
            msg = 'Popup bloqueado. Permite popups para este sitio.';
            break;
          case 'auth/cancelled-popup-request':
            msg = 'Inicio de sesión cancelado.';
            break;
          case 'auth/network-request-failed':
            msg = 'Error de red. Verifica tu conexión.';
            break;
          case 'auth/too-many-requests':
            msg = 'Demasiados intentos. Intenta más tarde.';
            break;
          case 'auth/unauthorized-domain':
            msg = 'Dominio no autorizado. Contacta al administrador.';
            break;
          default:
            msg = 'Error de autenticación: ${e.message ?? e.code}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error inesperado: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).signInWithApple();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al conectar con Apple: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
        child: Stack(
          children: [
            ..._buildAmbientGlows(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      _buildLogo(),
                      const SizedBox(height: 24),
                      const Text(
                        'AltarDiario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu hábito diario con Dios,\nahora en comunidad',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: Colors.white70, fontSize: 15),
                      ),
                      const SizedBox(height: 48),
                      if (_isLoading)
                        const CircularProgressIndicator(color: Colors.white)
                      else ...[
                        _buildGoogleButton(),
                        const SizedBox(height: 12),
                        if (defaultTargetPlatform == TargetPlatform.iOS ||
                            defaultTargetPlatform == TargetPlatform.macOS)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildAppleButton(),
                          ),
                        _buildAnonymousButton(),
                      ],
                      const SizedBox(height: 32),
                      const Text(
                        'Al continuar, aceptas nuestros Términos de\nServicio y Política de Privacidad.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white38, fontSize: 11),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAmbientGlows() {
    return [
      Positioned(
        top: -80,
        left: -40,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        bottom: -60,
        right: -40,
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlueLight.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ];
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.local_fire_department,
          size: 64, color: Colors.white),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppTheme.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.g_mobiledata,
                size: 24, color: AppTheme.textPrimary),
            const SizedBox(width: 10),
            const Text('Continuar con Google',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signInWithApple,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, size: 24),
            const SizedBox(width: 10),
            const Text('Continuar con Apple',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildAnonymousButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _signInAnonymously,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white38),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Iniciar sesión como invitado',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }
}
