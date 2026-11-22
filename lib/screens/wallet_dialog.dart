import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/winnerlife_provider.dart';
import '../services/payment_gateway_service.dart';

class WalletDialog extends StatefulWidget {
  const WalletDialog({super.key});

  @override
  State<WalletDialog> createState() => _WalletDialogState();
}

class _WalletDialogState extends State<WalletDialog> {
  bool _isDeposit = true; // true = Dépôt, false = Retrait
  bool _isLoading = false;
  final _amountController = TextEditingController();
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<WinnerLifeProvider>();
    _phoneController = TextEditingController(text: provider.whatsappNumber);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final paymentService = context.watch<PaymentGatewayService>();
    final balance = provider.cashBalance;

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.account_balance_wallet, color: Colors.amber),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Portefeuille Bourse WinnerLife',
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
            // Balance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Solde Disponible', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '\$${balance.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Icon(Icons.monetization_on_outlined, color: Colors.amber, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Segmented Selector Dépôt vs Retrait
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Dépôt (+)', style: TextStyle(fontWeight: FontWeight.bold)),
                  icon: Icon(Icons.add_card, color: Colors.green),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Retrait (-)', style: TextStyle(fontWeight: FontWeight.bold)),
                  icon: Icon(Icons.outbox, color: Colors.orange),
                ),
              ],
              selected: {_isDeposit},
              onSelectionChanged: (set) {
                setState(() {
                  _isDeposit = set.first;
                });
              },
            ),
            const SizedBox(height: 16),

            // Minimum Deposit Alert Banner
            if (_isDeposit)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withAlpha(80)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dépôt minimum obligatoire : 3 \$ (Automatique Orange/Mobile Money)',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: _isDeposit ? 'Montant du Dépôt (\$)' : 'Montant du Retrait (\$)',
                hintText: _isDeposit ? 'Ex: 3 ou 50' : 'Ex: 20',
                prefixIcon: const Icon(Icons.attach_money),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Numéro Orange Money / Mobile Money',
                prefixIcon: Icon(Icons.phone_android, color: Colors.orange),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading
              ? null
              : () async {
                  final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
                  final phone = _phoneController.text.trim();

                  if (_isDeposit) {
                    if (amount < 3.0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Le dépôt minimum est de 3 \$ !'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    final gatewaySuccess = await paymentService.initiateAutomatedDeposit(
                      amount: amount,
                      phoneNumber: phone,
                      providerName: 'Orange Money / Mobile Money',
                    );

                    if (gatewaySuccess) {
                      provider.depositToWallet(amount, phone);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Dépôt automatique de \$$amount validé via Orange Money ($phone) !'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      setState(() => _isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Échec du paiement automatique. Veuillez réessayer.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } else {
                    if (amount <= 0 || amount > balance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Montant invalide ou solde insuffisant.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    setState(() => _isLoading = true);
                    final gatewaySuccess = await paymentService.initiateAutomatedPayout(
                      amount: amount,
                      phoneNumber: phone,
                      providerName: 'Orange Money / Mobile Money',
                    );

                    if (gatewaySuccess) {
                      provider.processWithdrawal(amount, phone);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Retrait automatique de \$$amount vers Orange Money ($phone) effectué !'),
                            backgroundColor: Colors.orange[800],
                          ),
                        );
                      }
                    } else {
                      setState(() => _isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Échec du retrait automatique. Veuillez réessayer.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
          icon: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Icon(_isDeposit ? Icons.add_circle_outline : Icons.file_upload_outlined),
          label: Text(_isLoading ? 'Traitement auto...' : (_isDeposit ? 'Confirmer le Dépôt' : 'Confirmer le Retrait')),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isDeposit ? Colors.green : Colors.orange[800],
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
