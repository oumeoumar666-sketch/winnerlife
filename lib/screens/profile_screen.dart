import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/winnerlife_provider.dart';
import 'profile/companies_screen.dart';
import 'profile/asset_inventory_screen.dart';
import 'profile/payments_screen.dart';
import 'profile/security_screen.dart';
import 'profile/support_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil & Paramètres',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Header
            const CircleAvatar(
              radius: 45,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'Oumar Camara',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'WinnerLife - Direction Générale',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),

            // Role Switcher Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => _showRoleSelectionDialog(context),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withAlpha(51),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.business_center, color: Colors.amber),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mode de vue',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              provider.userRole,
                              style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.swap_horiz, color: Colors.deepPurple),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Options List
            _buildOptionTile(
              context,
              icon: Icons.business,
              title: 'Entreprises Partenaires',
              subtitle: 'Gérer les entreprises clientes et les contrats',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompaniesScreen()),
                );
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Gestion des Actifs (Stock & Téléchargements)',
              subtitle: 'Suivre les livraisons et hébergements digitaux',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AssetInventoryScreen()),
                );
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.payment,
              title: 'Paiements & Commissions',
              subtitle: 'Historique des transactions et comptes bancaires',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                );
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.security,
              title: 'Sécurité & Droits d\'accès',
              subtitle: 'Authentification Firebase & autorisations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecurityScreen()),
                );
              },
            ),
            _buildOptionTile(
              context,
              icon: Icons.link,
              title: 'Lien de Téléchargement de l\'App (APK)',
              subtitle: provider.appDownloadLink,
              onTap: () => _showEditDownloadLinkDialog(context, provider),
            ),
            _buildOptionTile(
              context,
              icon: Icons.help_outline,
              title: 'Support & Assistance',
              subtitle: 'Centre d\'aide WinnerLife & FAQ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SupportScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session terminée.')),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Se déconnecter',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDownloadLinkDialog(BuildContext context, WinnerLifeProvider provider) {
    final controller = TextEditingController(text: provider.appDownloadLink);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Lien de Téléchargement APK'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'URL Google Drive / Firebase Storage',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.setAppDownloadLink(controller.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lien de téléchargement mis à jour avec succès !')),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _showRoleSelectionDialog(BuildContext context) {
    final currentRole = context.read<WinnerLifeProvider>().userRole;
    final roles = [
      'Administrateur WinnerLife',
      'Entreprise Cliente B2B',
      'Agent / Exécutant de Mission',
      'Acheteur Marketplace',
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return SimpleDialog(
          title: const Text('Sélectionner le mode de vue'),
          children: roles.map((role) {
            final isSelected = role == currentRole;
            return SimpleDialogOption(
              onPressed: () {
                context.read<WinnerLifeProvider>().setUserRole(role);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Mode de vue changé : $role')),
                );
              },
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.deepPurple : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    role,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.deepPurple : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
