import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../providers/winnerlife_provider.dart';
import '../widgets/stock_chart.dart';

class StockDetailScreen extends StatefulWidget {
  final FinancialAsset asset;

  const StockDetailScreen({super.key, required this.asset});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  int _sharesToTrade = 1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();

    final currentAsset = provider.financialAssets.firstWhere(
      (a) => a.id == widget.asset.id,
      orElse: () => widget.asset,
    );

    final portfolio = provider.userPortfolio;
    final userHolding = portfolio.holdings.firstWhere(
      (h) => h.assetId == currentAsset.id,
      orElse: () => PortfolioHolding(
        assetId: currentAsset.id,
        symbol: currentAsset.symbol,
        title: currentAsset.title,
        sharesOwned: 0,
        averageBuyPrice: 0.0,
        currentSharePrice: currentAsset.sharePrice,
      ),
    );

    final isUp = currentAsset.isUp;
    final changeColor = isUp ? Colors.green : Colors.red;
    final totalTradeCost = currentAsset.sharePrice * _sharesToTrade;

    return Scaffold(
      appBar: AppBar(
        title: Text('${currentAsset.symbol} - ${currentAsset.companyName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share(
                "Découvrez le titre financier '${currentAsset.symbol}' (${currentAsset.companyName}) sur WinnerLife Bourse pour \$${currentAsset.sharePrice.toStringAsFixed(0)} la part !\n\nRendement estimé: +${currentAsset.expectedAnnualYield}% / an.",
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
            // Header Price & Ticker
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withAlpha(31),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentAsset.symbol,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentAsset.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${currentAsset.sharePrice.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: changeColor,
                        ),
                        Text(
                          '${currentAsset.priceChangePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Price Chart Card (Courbe Boursière de l'Action)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Courbe du Cours en Bourse',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(31),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rendement : +${currentAsset.expectedAnnualYield}% / an',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Line Chart Curve Component
                    StockChart(
                      priceHistory: currentAsset.priceHistory,
                      isUp: isUp,
                      height: 160,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // User Holding Summary (If user owns shares)
            if (userHolding.sharesOwned > 0) ...[
              Card(
                color: Colors.deepPurple.withAlpha(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Votre Position Actuelle',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildUserStat('Parts possédées', '${userHolding.sharesOwned} parts'),
                          _buildUserStat('Valeur totale', '\$${userHolding.currentValue.toStringAsFixed(0)}'),
                          _buildUserStat(
                            'Gain / Perte',
                            '${userHolding.profitOrLoss >= 0 ? '+' : ''}\$${userHolding.profitOrLoss.toStringAsFixed(0)}',
                            color: userHolding.profitOrLoss >= 0 ? Colors.green : Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Investment Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Présentation & Thèse d\'Investissement',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentAsset.description,
                      style: TextStyle(color: Colors.grey[800], height: 1.4),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Parts disponibles:', style: TextStyle(color: Colors.grey[600])),
                        Text(
                          '${currentAsset.availableShares} / ${currentAsset.totalShares}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Trade Execution Card (Buy / Sell Shares)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Passer une Ordre en Bourse',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Solde: \$${provider.cashBalance.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Nombre de parts : ', style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: _sharesToTrade > 1
                              ? () => setState(() => _sharesToTrade--)
                              : null,
                        ),
                        Text(
                          '$_sharesToTrade',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => setState(() => _sharesToTrade++),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Montant Total estimé :'),
                        Text(
                          '\$${totalTradeCost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final success = await provider.buyShares(currentAsset.id, _sharesToTrade);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success
                                        ? 'Achat de $_sharesToTrade parts de ${currentAsset.symbol} confirmé !'
                                        : 'Solde insuffisant ou parts indisponibles.'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.trending_up),
                            label: const Text('Acheter des Parts'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ),
                        if (userHolding.sharesOwned > 0) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final success = await provider.sellShares(currentAsset.id, _sharesToTrade);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(success
                                          ? 'Revente de $_sharesToTrade parts effectuée avec succès !'
                                          : 'Vous ne possédez pas autant de parts.'),
                                      backgroundColor: success ? Colors.blue : Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.trending_down),
                              label: const Text('Revendre'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStat(String title, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black87),
        ),
      ],
    );
  }
}
