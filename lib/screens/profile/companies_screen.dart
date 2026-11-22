import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/company.dart';
import '../../providers/winnerlife_provider.dart';

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final companies = provider.companies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises Partenaires'),
      ),
      body: companies.isEmpty
          ? const Center(child: Text('Aucune entreprise enregistrée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                final activeMissionsCount = provider.missions.where((m) => m.companyId == company.id).length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(31),
                              child: Icon(Icons.business, color: Theme.of(context).colorScheme.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    company.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    company.sector ?? 'Secteur d\'activité non renseigné',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          company.description ?? '',
                          style: TextStyle(color: Colors.grey[800], fontSize: 13),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(company.email, style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(31),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$activeMissionsCount mission(s)',
                                style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCompanyDialog(context),
        icon: const Icon(Icons.add_business),
        label: const Text('Ajouter une Entreprise'),
      ),
    );
  }

  void _showAddCompanyDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final sectorController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ajouter une Entreprise Cliente'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nom de l\'entreprise'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email professionnel'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sectorController,
                  decoration: const InputDecoration(labelText: 'Secteur d\'activité'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final newComp = Company(
                    id: 'comp_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text.trim(),
                    email: emailController.text.trim(),
                    sector: sectorController.text.trim(),
                    description: descController.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  // Add company locally to mock/state list
                  context.read<WinnerLifeProvider>().companies.add(newComp);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Entreprise partenaire enregistrée !')),
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
}
