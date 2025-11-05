import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/cocktail_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();
  Uint8List? _webImageBytes; // For web platform

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _nameController.text = settings.displayName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Future<void> _pickImage(SettingsProvider settings) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          // For web, read bytes and store them
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
          await settings.setProfilePicture(image.path);
        } else {
          // For mobile, just store the path
          await settings.setProfilePicture(image.path);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _removeImage(SettingsProvider settings) async {
    setState(() {
      _webImageBytes = null;
    });
    await settings.setProfilePicture(null);
  }

  ImageProvider? _getImageProvider(String? path) {
    if (path == null) return null;
    
    if (kIsWeb) {
      // On web, use the cached bytes
      return _webImageBytes != null ? MemoryImage(_webImageBytes!) : null;
    } else {
      // On mobile, use file path
      return FileImage(File(path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer3<SettingsProvider, FavoritesProvider, CocktailProvider>(
        builder: (context, settings, favorites, cocktails, _) {
          final favCount = favorites.favoritesCount;
          final ratedCount = favorites.ratedCount;
          final avgRating = favorites.averageRating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: _getImageProvider(settings.profilePicturePath),
                          child: _getImageProvider(settings.profilePicturePath) == null
                              ? Text(
                                  _initials(settings.displayName),
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: PopupMenuButton<String>(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              iconSize: 18,
                              padding: EdgeInsets.zero,
                              tooltip: 'Change picture',
                              onSelected: (value) {
                                if (value == 'pick') {
                                  _pickImage(settings);
                                } else if (value == 'remove') {
                                  _removeImage(settings);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'pick',
                                  child: Row(
                                    children: [
                                      Icon(Icons.photo_library),
                                      SizedBox(width: 8),
                                      Text('Choose photo'),
                                    ],
                                  ),
                                ),
                                if (settings.profilePicturePath != null)
                                  const PopupMenuItem(
                                    value: 'remove',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(width: 8),
                                        Text('Remove photo'),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Display name',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            onSubmitted: (v) => settings.setDisplayName(v),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.tonal(
                              onPressed: () => settings.setDisplayName(_nameController.text),
                              child: const Text('Save name'),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 24),
                Text('Your stats', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _StatCard(label: 'Favorites', value: favCount.toString(), icon: Icons.favorite),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Rated', value: ratedCount.toString(), icon: Icons.star),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Avg ★', value: avgRating.toStringAsFixed(1), icon: Icons.star_half),
                  ],
                ),

                const SizedBox(height: 24),
                Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Dark mode'),
                  subtitle: const Text('Use dark theme'),
                  value: settings.isDarkMode,
                  onChanged: (value) => settings.setDarkMode(value),
                  secondary: Icon(
                    settings.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Max ingredients'),
                    Expanded(
                      child: Slider(
                        value: settings.maxIngredients.toDouble(),
                        min: 1,
                        max: 15,
                        divisions: 14,
                        label: settings.maxIngredients.toString(),
                        onChanged: (v) => settings.setMaxIngredients(v.toInt()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Units'),
                    const SizedBox(width: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'us', label: Text('US (oz)'), icon: Icon(Icons.straighten)),
                        ButtonSegment(value: 'metric', label: Text('Metric (ml)'), icon: Icon(Icons.straighten)),
                      ],
                      selected: {settings.unitSystem},
                      onSelectionChanged: (sel) => settings.setUnitSystem(sel.first),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text('Data & actions', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: favCount == 0
                          ? null
                          : () async {
                              await favorites.clearFavorites();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Favorites cleared')),
                                );
                              }
                            },
                      icon: const Icon(Icons.favorite_border),
                      label: const Text('Clear favorites'),
                    ),
                    FilledButton.icon(
                      onPressed: ratedCount == 0
                          ? null
                          : () async {
                              await favorites.clearRatings();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ratings cleared')),
                                );
                              }
                            },
                      icon: const Icon(Icons.star_border),
                      label: const Text('Clear ratings'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Sippy • A simple cocktail companion',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container
        (
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
