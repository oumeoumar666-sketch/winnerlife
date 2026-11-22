import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/winnerlife_provider.dart';
import '../../services/payment_gateway_service.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  void _showWithdrawalDialog(BuildContext context, String currentPhone, double availableBalance) {
    final amountController = TextEditingController();
    final phoneController = TextEditingController(text: currentPhone);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.phone_android, color: Colors.orange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Retrait Orange Money / Mobile Money',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Solde disponible : \$${availableBalance.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Montant à retirer (\$)',
                    prefixIcon: Icon(Icons.attach_money),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro Orange Money / Mobile Money',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                final phone = phoneController.text.trim();

                if (amount > 0 && amount <= availableBalance) {
                  final success = context.read<WinnerLifeProvider>().processWithdrawal(amount, phone);
                  if (success) {
                    Navigator.pop(dialogCtx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Retrait automatique de \$$amount vers Orange Money ($phone) !'),
                        backgroundColor: Colors.orange[800],
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Montant invalide ou solde insuffisant.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[800],
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmer le Retrait'),
            ),
          ],
        );
      },
    );
  }

  void _showFedaPayConfigDialog(BuildContext context, PaymentGatewayService paymentService) {
    final keyController = TextEditingController(text: paymentService.fedapaySecretKey);
    bool isLive = paymentService.isLiveMode;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            return AlertDialog(
              title: const Text('Configuration API FedaPay'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Entrez votre clé secrète FedaPay (depuis dashboard.fedapay.com) pour activer les paiements mobiles automatiques en Guinée.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: keyController,
                      decoration: const InputDecoration(
                        labelText: 'FedaPay Secret Key (sk_live_...)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Mode Live (Production)'),
                      value: isLive,
                      onChanged: (val) => setStateDialog(() => isLive = val),
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
                    if (keyController.text.trim().isNotEmpty) {
                      paymentService.setFedaPayCredentials(keyController.text.trim(), isLive);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Clé API FedaPay configurée avec succès !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final paymentService = context.watch<PaymentGatewayService>();
    final totalRevenue = provider.totalRevenue;
    final missionsRevenue = provider.totalMissionsRevenue;
    final assetSalesRevenue = provider.totalAssetSalesRevenue;
    final transactions = provider.transactions;
    final phone = provider.whatsappNumber;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiements & Commissions FedaPay'),
        actions: [
          IconButton(
            icon: const Icon(Icons.vpn_key_outlined),
            tooltip: 'configurer FedaPay',
            onPressed: () => _showFedaPayConfigDialog(context, paymentService),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Revenue Card
            Card(
              color: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Revenus & Commissions en Direct (FedaPay)',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalRevenue.toStringAsFixed(0)}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Missions (15%): \$${missionsRevenue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        Text('Ventes Actifs: \$${assetSalesRevenue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Exclusive Payment Method Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Passerelle FedaPay (Orange & Mobile Money)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.phone_android, color: Colors.orange, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'FedaPay Mobile Money (Guinée)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Statut: ${paymentService.isLiveMode ? 'Mode Live (Actif)' : 'Mode Sandbox'}',
                                style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.grey),
                          onPressed: () => _showFedaPayConfigDialog(context, paymentService),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showWithdrawalDialog(context, phone, provider.cashBalance),
                      icon: const Icon(Icons.download),
                      label: const Text('Effectuer un Retrait Instantané FedaPay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[800],
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Live Transactions History
            Text(
              'Historique Instantané des Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (transactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Aucune transaction enregistrée pour le moment.'),
              )
            else
              ...transactions.map((tx) {
                final isCredit = tx['isCredit'] as bool;
                final amount = (tx['amount'] as num).toDouble();

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCredit ? Colors.green.withAlpha(31) : Colors.red.withAlpha(31),
                      child: Icon(
                        isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isCredit ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(tx['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${tx['date']} - via ${tx['method']}', style: const TextStyle(fontSize: 12)),
                    trailing: Text(
                      '${isCredit ? '+' : '-'}\$${amount.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isCredit ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
