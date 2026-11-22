import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/winnerlife_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Future<void> _checkoutViaWhatsApp(BuildContext context, String phone, double total) async {
    final provider = context.read<WinnerLifeProvider>();
    final items = provider.cartItems;

    if (items.isEmpty) return;

    final StringBuffer buffer = StringBuffer();
    buffer.writeln("Bonjour WinnerLife ! 👋");
    buffer.writeln("Je souhaite valider mon panier de commande :\n");

    for (int i = 0; i < items.length; i++) {
      buffer.writeln("${i + 1}. *${items[i].title}* - \$${items[i].price.toStringAsFixed(0)} (${items[i].category.label})");
    }

    buffer.writeln("\n💰 *Montant Total* : \$${total.toStringAsFixed(0)}");
    buffer.writeln("\nMerci de me recontacter pour la livraison et le paiement !");

    final encodedMsg = Uri.encodeComponent(buffer.toString());
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappUrl = Uri.parse("https://wa.me/$cleanPhone?text=$encodedMsg");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
        provider.clearCart();
      } else {
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
        provider.clearCart();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir WhatsApp: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final cartItems = provider.cartItems;
    final total = provider.cartTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier d\'Achat'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              onPressed: () => provider.clearCart(),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Votre panier est vide',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text('Parcourez la marketplace pour ajouter des actifs.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: item.isDigital ? Colors.purple.withAlpha(25) : Colors.teal.withAlpha(25),
                            child: Icon(
                              item.isDigital ? Icons.cloud_download : Icons.inventory_2,
                              color: item.isDigital ? Colors.purple : Colors.teal,
                            ),
                          ),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('\$${item.price.toStringAsFixed(0)} - ${item.category.label}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => provider.removeFromCart(item.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total du Panier :', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _checkoutViaWhatsApp(context, provider.whatsappNumber, total),
                        icon: const Icon(Icons.chat, color: Colors.white),
                        label: const Text('Valider & Commander via WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
