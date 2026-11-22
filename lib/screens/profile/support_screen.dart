import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support & Assistance WinnerLife'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contact Header
            Card(
              color: Theme.of(context).colorScheme.primary.withAlpha(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(Icons.support_agent, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Besoin d\'assistance ?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Notre équipe support est disponible 7j/7 pour vous accompagner.', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Questions Fréquentes (FAQ)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            const ExpansionTile(
              title: Text('Comment créer une mission pour mon entreprise ?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Accédez à l\'onglet Missions, cliquez sur "Nouvelle Mission", décrivez vos objectifs, définissez un budget et validez. Notre équipe s\'occupe du reste.'),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('Comment sont livrés les actifs digitaux ?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Les actifs digitaux (PDF, logiciels, templates) sont téléchargeables immédiatement après achat via des liens sécurisés temporaires dans votre espace.'),
                ),
              ],
            ),
            const ExpansionTile(
              title: Text('Quels sont les délais d\'expédition des actifs physiques ?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Les produits physiques sont expédiés sous 24h à 48h selon votre localisation (Dakar et régions du Sénégal).'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ouverture du support WhatsApp (+224 610 82 86 49)')),
                );
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Contacter le support WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
