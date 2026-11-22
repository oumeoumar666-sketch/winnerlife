import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/asset.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.asset,
    this.onTap,
  });

  Widget _buildImageWidget(String url, Color fallbackColor, bool isDigital) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 110,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: fallbackColor.withAlpha(20),
          child: const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
        ),
        errorWidget: (context, url, error) => _buildFallbackIcon(fallbackColor, isDigital),
      );
    } else if (File(url).existsSync()) {
      return Image.file(
        File(url),
        width: double.infinity,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(fallbackColor, isDigital),
      );
    }
    return _buildFallbackIcon(fallbackColor, isDigital);
  }

  Widget _buildFallbackIcon(Color categoryColor, bool isDigital) {
    return Center(
      child: Icon(
        isDigital ? Icons.download_done_rounded : Icons.inventory_2_outlined,
        size: 48,
        color: categoryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = asset.isDigital;
    final categoryColor = isDigital ? Colors.purple : Colors.teal;
    final hasImage = asset.imageUrl != null && asset.imageUrl!.isNotEmpty;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header image / placeholder
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(25),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    if (hasImage)
                      Positioned.fill(
                        child: _buildImageWidget(asset.imageUrl!, categoryColor, isDigital),
                      )
                    else
                      _buildFallbackIcon(categoryColor, isDigital),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDigital ? Icons.cloud_download : Icons.local_shipping,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              asset.category.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    asset.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    asset.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${asset.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[500],
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
}
