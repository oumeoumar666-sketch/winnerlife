import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/asset.dart';
import '../providers/winnerlife_provider.dart';

class AssetDetailScreen extends StatelessWidget {
  final Asset asset;

  const AssetDetailScreen({super.key, required this.asset});

  Future<void> _openWhatsAppOrder(BuildContext context, Asset asset, String phone) async {
    final message = "Bonjour WinnerLife ! 👋\n\nJe souhaite commander l'actif physique suivant :\n"
        "- *Produit* : ${asset.title}\n"
        "- *Prix* : \$${asset.price.toStringAsFixed(0)}\n"
        "- *Description* : ${asset.description}\n\n"
        "Merci de me recontacter pour la confirmation et la livraison !";

    final encodedMsg = Uri.encodeComponent(message);
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappUrl = Uri.parse("https://wa.me/$cleanPhone?text=$encodedMsg");

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(whatsappUrl, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir WhatsApp: $e')),
        );
      }
    }
  }

  Future<void> _downloadDigitalFile(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ouverture du lien de téléchargement: $e')),
        );
      }
    }
  }

  Widget _buildHeroImage(String url, Color fallbackColor, bool isDigital) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: fallbackColor.withAlpha(20),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => _buildFallbackHeroIcon(fallbackColor, isDigital),
      );
    } else if (File(url).existsSync()) {
      return Image.file(
        File(url),
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackHeroIcon(fallbackColor, isDigital),
      );
    }
    return _buildFallbackHeroIcon(fallbackColor, isDigital);
  }

  Widget _buildFallbackHeroIcon(Color categoryColor, bool isDigital) {
    return Center(
      child: Icon(
        isDigital ? Icons.cloud_download_rounded : Icons.inventory_2_rounded,
        size: 90,
        color: categoryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();

    // Retrieve up to date asset object from provider
    final currentAsset = provider.assets.firstWhere(
      (a) => a.id == asset.id,
      orElse: () => asset,
    );

    final isDigital = currentAsset.isDigital;
    final categoryColor = isDigital ? Colors.purple : Colors.teal;
    final hasImage = currentAsset.imageUrl != null && currentAsset.imageUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentAsset.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              Share.share(
                "Découvrez '${currentAsset.title}' sur WinnerLife pour \$${currentAsset.price.toStringAsFixed(0)} !\n\n${currentAsset.description}",
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Hero Banner
            Container(
              height: 220,
              width: double.infinity,
              color: categoryColor.withAlpha(31),
              child: Stack(
                children: [
                  if (hasImage)
                    Positioned.fill(
                      child: _buildHeroImage(currentAsset.imageUrl!, categoryColor, isDigital),
                    )
                  else
                    _buildFallbackHeroIcon(categoryColor, isDigital),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Actif ${currentAsset.category.label}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          currentAsset.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${currentAsset.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description de l\'actif',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentAsset.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Specific Properties Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDigital ? 'Spécifications Numériques' : 'Spécifications Logistiques',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Divider(height: 20),
                          if (isDigital) ...[
                            _buildSpecRow(
                              context,
                              icon: Icons.article_outlined,
                              label: 'Licence',
                              value: currentAsset.licenseType ?? 'Standard',
                            ),
                            const SizedBox(height: 10),
                            _buildSpecRow(
                              context,
                              icon: Icons.data_usage_outlined,
                              label: 'Taille du fichier',
                              value: currentAsset.fileSizeBytes != null
                                  ? '${(currentAsset.fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB'
                                  : 'Variable',
                            ),
                          ] else ...[
                            _buildSpecRow(
                              context,
                              icon: Icons.inventory_2_outlined,
                              label: 'Quantité en stock',
                              value: '${currentAsset.stockQuantity ?? 0} unités',
                            ),
                            const SizedBox(height: 10),
                            _buildSpecRow(
                              context,
                              icon: Icons.scale_outlined,
                              label: 'Poids estimé',
                              value: '${currentAsset.weightKg ?? 0.0} kg',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Action Buttons (Add to Cart + Order / Download)
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          provider.addToCart(currentAsset);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Actif ajouté au panier !')),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Panier'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(120, 54),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: isDigital
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  _downloadDigitalFile(context, currentAsset.downloadUrl ?? "https://winnerlife.com");
                                },
                                icon: const Icon(Icons.cloud_download, color: Colors.white),
                                label: const Text('Télécharger l\'Actif', style: TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: (currentAsset.stockQuantity ?? 0) > 0
                                    ? () async {
                                        final success = await context.read<WinnerLifeProvider>().purchasePhysicalAsset(currentAsset.id);
                                        if (success && context.mounted) {
                                          final phone = context.read<WinnerLifeProvider>().whatsappNumber;
                                          await _openWhatsAppOrder(context, currentAsset, phone);
                                        }
                                      }
                                    : null,
                                icon: const Icon(Icons.chat, color: Colors.white),
                                label: Text(
                                  (currentAsset.stockQuantity ?? 0) > 0 ? 'Commander via WhatsApp' : 'Rupture de Stock',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  minimumSize: const Size.fromHeight(54),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey[700])),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
