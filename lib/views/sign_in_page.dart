import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../viewmodels/auth_viewmodel.dart'; // For AuthStatus enum
import '../providers/app_providers.dart';

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
  bool _rememberMe = true; // Default to true for better UX

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
            'assets/images/png/auth_background.png',
            fit: BoxFit.fitHeight,
          ),
          // Capa opcional para oscurecer el fondo y mejorar contraste
          Container(color: Colors.black.withOpacity(0.3)),
          // Widget del formulario centrado
          Center(
            child: _SignInForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              isPasswordVisible: _isPasswordVisible,
              rememberMe: _rememberMe,
              onPasswordVisibilityChanged: (v) =>
                  setState(() => _isPasswordVisible = v),
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
  });

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final controller = ref.read(authControllerProvider);

    return Card(
      elevation: 8,
      // Give the card a visible border and rounded corners. We also set
      // clipBehavior so the child is clipped to the rounded shape.
      color: const Color(0xFF18181B),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Color.fromARGB(0, 255, 255, 255)),
      ),
      child: Container(
        // Do NOT set the same background color here — let the Card paint it
        // and keep this container transparent so the Card's rounded border
        // and side are visible.
        padding: const EdgeInsets.all(32.0),
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset('assets/images/svg/logo.svg', height: 100),
                const SizedBox(height: 6),
                Text(
                  'Ingrese sus credenciales',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un correo electrónico';
                    }
                    final emailValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
                    if (!emailValid.hasMatch(value)) {
                      return 'Por favor ingrese un correo electrónico valido';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Correo Electrónico',
                    labelStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(color: Colors.white),
                    prefixIcon: const Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white,
                      ),
                      onPressed: () =>
                          onPasswordVisibilityChanged(!isPasswordVisible),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Colors.white,
                    checkboxTheme: CheckboxThemeData(
                      fillColor: MaterialStateProperty.all(Colors.white),
                      checkColor: MaterialStateProperty.all(Color(0xFF18181B)),
                    ),
                    textTheme: Theme.of(
                      context,
                    ).textTheme.apply(bodyColor: Colors.white),
                  ),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: rememberMe,
                    onChanged: (v) => onRememberMeChanged(v ?? false),
                    title: const Text(
                      'Recordarme',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A8D8D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: authState.status == AuthStatus.loading
                        ? null
                        : () async {
                            if (formKey.currentState?.validate() ?? false) {
                              print('🔵 SignInPage: Iniciando sign in');
                              
                              final success = await controller.signIn(
                                context: context,
                                email: emailController.text.trim(),
                                password: passwordController.text,
                                rememberMe: rememberMe,
                              );

                              print('🔵 SignInPage: Sign in completado, success: $success');
                              
                              // Router will handle navigation automatically
                              // No manual navigation needed
                            }
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: authState.status == AuthStatus.loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Ingresar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Show error message inline if auth fails
                if (authState.status == AuthStatus.error)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.errorMessage ?? 'Error desconocido',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
