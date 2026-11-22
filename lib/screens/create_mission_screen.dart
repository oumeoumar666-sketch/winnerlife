import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/winnerlife_provider.dart';
import '../services/facebook_meta_service.dart';

class CreateMissionScreen extends StatefulWidget {
  const CreateMissionScreen({super.key});

  @override
  State<CreateMissionScreen> createState() => _CreateMissionScreenState();
}

class _CreateMissionScreenState extends State<CreateMissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _objectiveController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  final DateTime _startDate = DateTime.now();
  final DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void dispose() {
    _titleController.dispose();
    _companyNameController.dispose();
    _objectiveController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final obj = _objectiveController.text.trim();
      final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;

      final newMission = Mission(
        id: 'miss_${DateTime.now().millisecondsSinceEpoch}',
        companyId: 'comp_user',
        companyName: _companyNameController.text.trim(),
        title: title,
        description: _descriptionController.text.trim(),
        objective: obj,
        budget: budget,
        status: MissionStatus.pending,
        startDate: _startDate,
        endDate: _endDate,
        createdAt: DateTime.now(),
      );

      context.read<WinnerLifeProvider>().addMission(newMission);
      context.read<FacebookMetaService>().publishMissionToFacebook(
        title: title,
        objective: obj,
        budget: budget,
      );

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nouvelle mission soumise et auto-publiée sur Facebook !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer une Mission'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de la mission',
                  hintText: 'ex: Boost Ventes Gamme Cosmétique',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise cliente',
                  hintText: 'ex: Africa Business Corp',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _objectiveController,
                decoration: const InputDecoration(
                  labelText: 'Objectif principal',
                  hintText: 'ex: Obtenir 1000 nouveaux clients et \$50,000 de CA',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description détaillée',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _budgetController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Budget Alloué (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Champ obligatoire';
                  if (double.tryParse(val) == null) return 'Entrez un nombre valide';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Soumettre & Publier sur Meta'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
