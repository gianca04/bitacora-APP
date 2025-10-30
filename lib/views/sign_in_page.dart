import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/auth_controller.dart';
import '../viewmodels/auth_viewmodel.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo PNG adaptado a pantalla
          Image.asset(
            'assets/images/auth_background.png',
            fit: BoxFit.cover,
          ),
          // Capa opcional para oscurecer el fondo y mejorar contraste
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          // Widget del formulario centrado
          Center(
            child: _SignInForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              isPasswordVisible: _isPasswordVisible,
              rememberMe: _rememberMe,
              onPasswordVisibilityChanged: (v) => setState(() => _isPasswordVisible = v),
              onRememberMeChanged: (v) => setState(() => _rememberMe = v),
              ref: ref,
            ),
          ),
        ],
      ),
    );
  }
}

// Widget aparte para el formulario, pero en el mismo archivo
class _SignInForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool rememberMe;
  final ValueChanged<bool> onPasswordVisibilityChanged;
  final ValueChanged<bool> onRememberMeChanged;
  final WidgetRef ref;

  const _SignInForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.rememberMe,
    required this.onPasswordVisibilityChanged,
    required this.onRememberMeChanged,
    required this.ref,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final controller = ref.read(authControllerProvider);

    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(32.0),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FlutterLogo(size: 100),
                const SizedBox(height: 16),
                Text('SAT MONITOR', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Ingrese sus credenciales', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter an email';
                    final emailValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                    if (!emailValid.hasMatch(value)) return 'Please enter a valid email';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter a password';
                    if (value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => onPasswordVisibilityChanged(!isPasswordVisible),
                    ),
                  ),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  value: rememberMe,
                  onChanged: (v) => onRememberMeChanged(v ?? false),
                  title: const Text('Remember me'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              final messenger = ScaffoldMessenger.of(context);

                              final result = await controller.signIn(
                                email: emailController.text.trim(),
                                password: passwordController.text,
                                rememberMe: rememberMe,
                              );

                              if (result.status == AuthStatus.authenticated) {
                                messenger.showSnackBar(const SnackBar(content: Text('Signed in successfully')));
                              } else if (result.status == AuthStatus.error) {
                                messenger.showSnackBar(SnackBar(content: Text(result.errorMessage ?? 'Unknown error')));
                              }
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: authState.status == AuthStatus.loading
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Sign in', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (authState.status == AuthStatus.error)
                  Text(authState.errorMessage ?? 'An error occurred', style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    // Example: navigate to a sign-up page or reset password
                  },
                  child: const Text('Forgot password?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}