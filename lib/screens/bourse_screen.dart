import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/winnerlife_provider.dart';
import '../services/facebook_meta_service.dart';
import 'stock_detail_screen.dart';
import 'wallet_dialog.dart';

class BourseScreen extends StatefulWidget {
  const BourseScreen({super.key});

  @override
  State<BourseScreen> createState() => _BourseScreenState();
}

class _BourseScreenState extends State<BourseScreen> {
  String _selectedCategoryFilter = 'Tous';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final portfolio = provider.userPortfolio;
    final financialAssets = provider.financialAssets;

    final filteredAssets = financialAssets.where((asset) {
      if (_selectedCategoryFilter == 'Actions PME') {
        return asset.category == FinancialAssetCategory.pmeEquity;
      } else if (_selectedCategoryFilter == 'Actifs Physiques') {
        return asset.category == FinancialAssetCategory.physicalAssetToken;
      } else if (_selectedCategoryFilter == 'Projets Digitaux') {
        return asset.category == FinancialAssetCategory.digitalAssetToken;
      } else if (_selectedCategoryFilter == 'Obligations') {
        return asset.category == FinancialAssetCategory.bonds;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.candlestick_chart, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'WinnerLife Bourse',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const WalletDialog(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Portfolio Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF4A148C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Valeur Totale du Portefeuille',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${portfolio.totalPortfolioValue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Solde Disponible', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          Text(
                            '\$${portfolio.cashBalance.toStringAsFixed(0)}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Gains / Pertes', style: TextStyle(color: Colors.white60, fontSize: 11)),
                          Text(
                            '${portfolio.totalUnrealizedProfit >= 0 ? '+' : ''}\$${portfolio.totalUnrealizedProfit.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: portfolio.totalUnrealizedProfit >= 0 ? Colors.lightGreenAccent : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Colors.white24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const WalletDialog(),
                            );
                          },
                          icon: const Icon(Icons.add_card, size: 18),
                          label: const Text('Dépôt (min 3\$)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => const WalletDialog(),
                            );
                          },
                          icon: const Icon(Icons.outbox, size: 18, color: Colors.white),
                          label: const Text('Retrait', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white54),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Stock Ticker Bar
            Text(
              'Bandeau des Cours en Direct',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: financialAssets.length,
                itemBuilder: (context, index) {
                  final item = financialAssets[index];
                  final isUp = item.isUp;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Text(
                          item.symbol,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '\$${item.sharePrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: isUp ? Colors.green : Colors.red,
                          size: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Category Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Tous'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Actions PME'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Actifs Physiques'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Projets Digitaux'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Obligations'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Financial Assets List
            Text(
              'Opportunités d\'Investissement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            ...filteredAssets.map((asset) {
              final isUp = asset.isUp;
              final changeColor = isUp ? Colors.green : Colors.red;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StockDetailScreen(asset: asset),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withAlpha(25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                asset.symbol,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '+${asset.expectedAnnualYield}% / an',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          asset.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          asset.companyName,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Prix de la part', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                Text(
                                  '\$${asset.sharePrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                  color: changeColor,
                                ),
                                Text(
                                  '${asset.priceChangePercent.toStringAsFixed(2)}%',
                                  style: TextStyle(color: changeColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StockDetailScreen(asset: asset),
                                  ),
                                );
                              },
                              child: const Text('Investir'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIssueStockDialog(context),
        icon: const Icon(Icons.add_chart),
        label: const Text('Émettre des Actions'),
      ),
    );
  }

  Widget _buildFilterChip(String category) {
    final isSelected = _selectedCategoryFilter == category;
    return ChoiceChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedCategoryFilter = category;
          });
        }
      },
    );
  }

  void _showIssueStockDialog(BuildContext context) {
    final symbolController = TextEditingController();
    final titleController = TextEditingController();
    final companyController = TextEditingController();
    final priceController = TextEditingController();
    final sharesController = TextEditingController(text: '1000');
    final yieldController = TextEditingController(text: '15.0');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Émettre un Titre en Bourse'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: symbolController,
                  decoration: const InputDecoration(labelText: 'Symbole Ticker (ex: WNL)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Titre du Projet/Capital'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: companyController,
                  decoration: const InputDecoration(labelText: 'Nom de l\'entreprise'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix de la part (\$)'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: sharesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Nombre total de parts'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: yieldController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Rendement annuel estimé (%)'),
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
                final symbol = symbolController.text.trim().toUpperCase();
                final company = companyController.text.trim();
                final title = titleController.text.trim();
                if (title.isNotEmpty && priceController.text.trim().isNotEmpty) {
                  final price = double.tryParse(priceController.text.trim()) ?? 10.0;
                  final shares = int.tryParse(sharesController.text.trim()) ?? 1000;
                  final yieldVal = double.tryParse(yieldController.text.trim()) ?? 10.0;

                  final newStock = FinancialAsset(
                    id: 'fin_${DateTime.now().millisecondsSinceEpoch}',
                    symbol: symbol,
                    companyId: 'comp_user',
                    companyName: company,
                    title: title,
                    description: 'Titre financier rédigé et émis sur WinnerLife Bourse.',
                    sharePrice: price,
                    previousPrice: price,
                    totalShares: shares,
                    availableShares: shares,
                    expectedAnnualYield: yieldVal,
                    category: FinancialAssetCategory.pmeEquity,
                    priceHistory: [price, price],
                    createdAt: DateTime.now(),
                  );

                  context.read<WinnerLifeProvider>().addFinancialAsset(newStock);
                  context.read<FacebookMetaService>().publishStockToFacebook(
                    symbol: symbol,
                    companyName: company,
                    sharePrice: price,
                    yieldRate: yieldVal,
                  );

                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nouveau titre financier coté sur la Bourse & publié sur Meta !')),
                  );
                }
              },
              child: const Text('Émettre & Publier'),
            ),
          ],
        );
      },
    );
  }
}
