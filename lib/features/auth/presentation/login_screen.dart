import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/home_screen.dart';
import '../../../core/constants.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.supabaseReady = true});
  final bool supabaseReady;
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _goHome({required bool isDemo, String? email}) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          supabaseReady: widget.supabaseReady && Constants.hasSupabaseCredentials,
          isDemo: isDemo,
          displayName: email?.split('@').first ?? 'Usuario',
        ),
      ),
      (_) => false,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!Constants.hasSupabaseCredentials) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configura Supabase en constants.dart o usa modo demo')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    try {
      final client = Supabase.instance.client;
      if (_isRegistering) {
        final res = await client.auth.signUp(
          email: email,
          password: _passwordController.text,
          data: {
            'username': _usernameController.text.trim().isEmpty ? email.split('@').first : _usernameController.text.trim(),
            'display_name': _usernameController.text.trim().isEmpty ? email.split('@').first : _usernameController.text.trim(),
          },
        );
        if (res.session != null && mounted) {
          _goHome(isDemo: false, email: email);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Revisa tu correo para confirmar la cuenta')),
          );
        }
      } else {
        await client.auth.signInWithPassword(email: email, password: _passwordController.text);
        if (mounted) _goHome(isDemo: false, email: email);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.hub_rounded, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text('Nexora', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tu espacio. Tus reglas.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
                  const SizedBox(height: 12),
                  Text('Los administradores se asignan por Gmail en Supabase (role = admin).', textAlign: TextAlign.center, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 32),
                  if (_isRegistering) ...[
                    TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Nombre de usuario', prefixIcon: Icon(Icons.person_outline))),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo (Gmail u otro)', prefixIcon: Icon(Icons.email_outlined)),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu correo';
                      if (!v.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_isRegistering ? 'Crear cuenta' : 'Iniciar sesión'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(onPressed: () => setState(() => _isRegistering = !_isRegistering), child: Text(_isRegistering ? '¿Ya tienes cuenta? Inicia sesión' : '¿No tienes cuenta? Regístrate')),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: () => _goHome(isDemo: true, email: 'demo'), child: const Text('Continuar en modo demo')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
