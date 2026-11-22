import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/facebook_meta_service.dart';
import '../providers/winnerlife_provider.dart';

class FacebookBoostDialog extends StatefulWidget {
  final String missionOrAssetName;
  final String missionId;

  const FacebookBoostDialog({
    super.key,
    required this.missionOrAssetName,
    required this.missionId,
  });

  @override
  State<FacebookBoostDialog> createState() => _FacebookBoostDialogState();
}

class _FacebookBoostDialogState extends State<FacebookBoostDialog> {
  final _countryController = TextEditingController(text: 'Sénégal & Guinée & Côte d\'Ivoire');
  final _budgetController = TextEditingController(text: '5000');
  int _durationDays = 7;
  String _selectedObjective = 'Messages WhatsApp Directs';

  final List<String> _objectives = [
    'Messages WhatsApp Directs',
    'Ventes Directes Marketplace',
    'Vues & Trafic de Marque',
    'Acquisition de Prospects Qualifiés',
  ];

  @override
  void dispose() {
    _countryController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metaService = context.watch<FacebookMetaService>();
    final dailyBudget = double.tryParse(_budgetController.text) ?? 5000.0;
    final totalBudget = dailyBudget * _durationDays;
    final estimatedReach = (totalBudget * 8.5).toInt();

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1877F2), // Facebook Blue
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.campaign, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Booster sur Meta (Facebook & Instagram)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1877F2).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: Color(0xFF1877F2), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Page associée: ${metaService.facebookPageName}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Campagne pour : "${widget.missionOrAssetName}"',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _countryController,
              decoration: const InputDecoration(
                labelText: 'Ciblage Géographique',
                prefixIcon: Icon(Icons.public),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: _selectedObjective,
              decoration: const InputDecoration(
                labelText: 'Objectif de la Campagne',
                border: OutlineInputBorder(),
              ),
              items: _objectives.map((obj) {
                return DropdownMenuItem(value: obj, child: Text(obj, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedObjective = val);
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Budget / jour (\$)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: _durationDays,
                    decoration: const InputDecoration(
                      labelText: 'Durée',
                      border: OutlineInputBorder(),
                    ),
                    items: [3, 7, 14, 30].map((days) {
                      return DropdownMenuItem(value: days, child: Text('$days jours'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _durationDays = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Estimation summary
            Card(
              color: Colors.blue[50],
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Budget Total :', style: TextStyle(fontSize: 12)),
                        Text('\$${totalBudget.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Portée Estimée :', style: TextStyle(fontSize: 12)),
                        Text('~$estimatedReach personnes', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            final campaign = await metaService.launchFacebookBoost(
              missionId: widget.missionId,
              pageName: metaService.facebookPageName,
              targetCountry: _countryController.text.trim(),
              dailyBudgetFcfa: dailyBudget,
              durationDays: _durationDays,
              objective: _selectedObjective,
            );

            if (context.mounted) {
              context.read<WinnerLifeProvider>().addNotification(
                'Booster Facebook Lancé 🚀',
                'Campagne Meta activée pour "${widget.missionOrAssetName}". Portée estimée: ~${campaign.estimatedReach} personnes.',
              );

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Campagne Facebook & Instagram lancée ! ID: ${campaign.id}'),
                  backgroundColor: const Color(0xFF1877F2),
                ),
              );
            }
          },
          icon: const Icon(Icons.rocket_launch),
          label: const Text('Lancer le Boost Meta'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
