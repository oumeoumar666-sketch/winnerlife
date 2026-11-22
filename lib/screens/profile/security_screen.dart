import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _cleanAuthError(dynamic error) {
    final msg = error.toString();
    if (msg.contains('invalid_credentials') || msg.contains('Invalid login')) {
      return 'E-mail ou mot de passe incorrect.';
    } else if (msg.contains('email_already_in_use') || msg.contains('already registered')) {
      return 'Cet e-mail est déjà associé à un compte entreprise.';
    } else if (msg.contains('weak_password')) {
      return 'Le mot de passe doit contenir au moins 6 caractères.';
    }
    return 'Erreur d\'authentification: $msg';
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sécurité & Synchronisation Supabase'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              color: Colors.green.withAlpha(25),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_done,
                      color: Colors.green,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cloud Supabase Actif (Sauvegarde Entreprise)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                          Text(
                            user != null
                                ? 'Connecté (${user.email ?? user.id}) - Données synchronisées.'
                                : 'Connectez-vous pour sauvegarder vos données d\'entreprise.',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            if (user == null) ...[
              Text(
                'Connexion Sécurisée (Email ou Google)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Google Sign In Button
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await authService.signInWithGoogle();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Redirection vers Google Sign-In...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_cleanAuthError(e)),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.blue),
                label: const Text('Se connecter avec Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('OU', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email professionnel',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez entrer un email et un mot de passe.')),
                          );
                          return;
                        }

                        try {
                          await authService.signInWithEmail(_emailController.text.trim(), _passwordController.text.trim());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Connexion réussie ! Données synchronisées.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_cleanAuthError(e)),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Se connecter'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Veuillez entrer un email et un mot de passe.')),
                          );
                          return;
                        }

                        try {
                          await authService.signUpWithEmail(_emailController.text.trim(), _passwordController.text.trim());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Compte créé ! Vérifiez votre boîte mail si nécessaire.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_cleanAuthError(e)),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.person_add),
                      label: const Text('Créer un compte'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await authService.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Déconnexion de Supabase effectuée.')),
                    );
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter de Supabase'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
