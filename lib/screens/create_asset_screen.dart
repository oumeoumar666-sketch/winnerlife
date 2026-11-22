import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/winnerlife_provider.dart';
import '../services/facebook_meta_service.dart';

class CreateAssetScreen extends StatefulWidget {
  const CreateAssetScreen({super.key});

  @override
  State<CreateAssetScreen> createState() => _CreateAssetScreenState();
}

class _CreateAssetScreenState extends State<CreateAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '10');
  final _weightController = TextEditingController(text: '0.5');
  final _downloadUrlController = TextEditingController(text: 'https://winnerlife.com/downloads/file.pdf');
  final _licenseController = TextEditingController(text: 'Licence Commerciale');
  final _imageUrlController = TextEditingController();

  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();
  bool _autoPublishToFacebook = true;

  AssetCategory _category = AssetCategory.physical;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _weightController.dispose();
    _downloadUrlController.dispose();
    _licenseController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _imageUrlController.text = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de charger l\'image: $e')),
        );
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final isDigital = _category == AssetCategory.digital;
      final finalImageUrl = _selectedImageFile != null
          ? _selectedImageFile!.path
          : _imageUrlController.text.trim();
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      final title = _titleController.text.trim();
      final desc = _descriptionController.text.trim();

      final newAsset = Asset(
        id: 'asset_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: desc,
        price: price,
        category: _category,
        imageUrl: finalImageUrl.isNotEmpty ? finalImageUrl : null,
        stockQuantity: isDigital ? null : int.tryParse(_stockController.text.trim()),
        weightKg: isDigital ? null : double.tryParse(_weightController.text.trim()),
        downloadUrl: isDigital ? _downloadUrlController.text.trim() : null,
        licenseType: isDigital ? _licenseController.text.trim() : null,
        fileSizeBytes: isDigital ? 8500000 : null,
        createdAt: DateTime.now(),
      );

      context.read<WinnerLifeProvider>().addAsset(newAsset);

      if (_autoPublishToFacebook) {
        await context.read<FacebookMetaService>().publishProductToFacebook(
          title: title,
          description: desc,
          price: price,
          imageUrl: finalImageUrl.isNotEmpty ? finalImageUrl : 'https://winnerlife.com/logo.png',
        );

        if (mounted) {
          context.read<WinnerLifeProvider>().addNotification(
            'Publication Facebook & Instagram 🚀',
            'Le produit "$title" a été publié automatiquement avec le bouton CTA "Télécharger l\'application".',
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Actif ${_category.label.toLowerCase()} publié et synchronisé avec Facebook !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publier un Actif'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Segmented Selector
              SegmentedButton<AssetCategory>(
                segments: const [
                  ButtonSegment(
                    value: AssetCategory.physical,
                    label: Text('Actif Physique'),
                    icon: Icon(Icons.inventory_2_outlined),
                  ),
                  ButtonSegment(
                    value: AssetCategory.digital,
                    label: Text('Actif Digital'),
                    icon: Icon(Icons.cloud_download_outlined),
                  ),
                ],
                selected: {_category},
                onSelectionChanged: (set) {
                  setState(() {
                    _category = set.first;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Image Picker Box & Preview
              Text(
                'Photo / Illustration du produit',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _selectedImageFile != null
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              _selectedImageFile!,
                              width: double.infinity,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedImageFile = null;
                                  _imageUrlController.clear();
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : (_imageUrlController.text.startsWith('http')
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  _imageUrlController.text,
                                  width: double.infinity,
                                  height: 160,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(child: Text('URL Image invalide')),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _imageUrlController.clear();
                                    });
                                  },
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              const Text('Sélectionner ou ajouter une photo', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library, size: 18),
                                    label: const Text('Galerie'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt, size: 18),
                                    label: const Text('Appareil'),
                                  ),
                                ],
                              ),
                            ],
                          )),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _imageUrlController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Ou coller l\'URL d\'une image web (optionnel)',
                  prefixIcon: Icon(Icons.image_outlined),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre de l\'actif',
                  hintText: 'ex: Pack Template Marketing ou Coffret Produit',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description complète',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Prix de vente (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.price_change_outlined),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Champ obligatoire';
                  if (double.tryParse(val) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category specific fields
              if (_category == AssetCategory.physical) ...[
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Quantité en Stock',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.warehouse),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Poids estimé (en kg)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.scale),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
                ),
              ] else ...[
                TextFormField(
                  controller: _downloadUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Lien de téléchargement sécurisé',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _licenseController,
                  decoration: const InputDecoration(
                    labelText: 'Type de Licence',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.verified),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Champ obligatoire' : null,
                ),
              ],
              const SizedBox(height: 16),

              // Facebook Auto-Publish Switch
              SwitchListTile(
                title: const Text(
                  'Auto-publier sur Facebook & Instagram 🚀',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: const Text(
                  'Ajoute un bouton CTA "Télécharger l\'application" sur la publication Meta.',
                  style: TextStyle(fontSize: 11),
                ),
                value: _autoPublishToFacebook,
                activeThumbColor: const Color(0xFF1877F2),
                onChanged: (val) {
                  setState(() {
                    _autoPublishToFacebook = val;
                  });
                },
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.storefront),
                label: const Text('Publier l\'Actif & Synchroniser Meta'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
