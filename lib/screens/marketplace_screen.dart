import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/winnerlife_provider.dart';
import '../widgets/asset_card.dart';
import 'asset_detail_screen.dart';
import 'create_asset_screen.dart';
import 'cart_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final filteredAssets = provider.filteredAssets;
    final cartCount = provider.cartItems.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Marketplace Actifs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$cartCount'),
              isLabelVisible: cartCount > 0,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (value) {
                    context.read<WinnerLifeProvider>().setAssetSearchQuery(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher un actif physique ou digital...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip(context, 'Tous'),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Physiques'),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Digitaux'),
                  ],
                ),
              ],
            ),
          ),

          // Assets Grid
          Expanded(
            child: filteredAssets.isEmpty
                ? const Center(
                    child: Text('Aucun actif ne correspond à votre recherche.'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: filteredAssets.length,
                    itemBuilder: (context, index) {
                      final asset = filteredAssets[index];
                      return AssetCard(
                        asset: asset,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssetDetailScreen(asset: asset),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAssetScreen()),
          );
        },
        icon: const Icon(Icons.sell_outlined),
        label: const Text('Mettre en vente'),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String category) {
    final selectedFilter = context.watch<WinnerLifeProvider>().selectedAssetFilter;
    final isSelected = selectedFilter == category;

    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          context.read<WinnerLifeProvider>().setAssetFilter(category);
        }
      },
    );
  }
}
