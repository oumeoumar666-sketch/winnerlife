import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/winnerlife_provider.dart';

class AssetInventoryScreen extends StatelessWidget {
  const AssetInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final physicalAssets = provider.assets.where((a) => a.isPhysical).toList();
    final digitalAssets = provider.assets.where((a) => a.isDigital).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gestion des Actifs & Inventaire'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Stocks Physiques'),
              Tab(text: 'Catalogue Digital'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Physical Stocks
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: physicalAssets.length,
              itemBuilder: (context, index) {
                final asset = physicalAssets[index];
                final stock = asset.stockQuantity ?? 0;
                final isLowStock = stock <= 5;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isLowStock ? Colors.orange.withAlpha(31) : Colors.teal.withAlpha(31),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: isLowStock ? Colors.orange : Colors.teal,
                      ),
                    ),
                    title: Text(asset.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('\$${asset.price.toStringAsFixed(0)} - Poids: ${asset.weightKg ?? 0} kg'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLowStock ? Colors.orange.withAlpha(31) : Colors.green.withAlpha(31),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Stock: $stock',
                        style: TextStyle(
                          color: isLowStock ? Colors.orange : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Tab 2: Digital Catalog
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: digitalAssets.length,
              itemBuilder: (context, index) {
                final asset = digitalAssets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple.withAlpha(31),
                      child: const Icon(Icons.cloud_download_outlined, color: Colors.purple),
                    ),
                    title: Text(asset.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Licence: ${asset.licenseType ?? 'Standard'} - ${(asset.fileSizeBytes ?? 0) ~/ (1024 * 1024)} MB'),
                    trailing: IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lien sécurisé: ${asset.downloadUrl}')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
