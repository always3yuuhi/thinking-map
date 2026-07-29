import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/place_alias.dart';
import '../providers/repository_providers.dart';
import '../providers/service_providers.dart';
import '../providers/timeline_providers.dart';

class PlaceAliasScreen extends ConsumerWidget {
  const PlaceAliasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aliasesAsync = ref.watch(placeAliasesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('場所エイリアス設定')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAliasSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: aliasesAsync.when(
        data: (aliases) {
          if (aliases.isEmpty) {
            return const Center(
              child: Text('よく訪れる場所に名前を登録できます。右下の + から追加してください。'),
            );
          }
          return ListView.separated(
            itemCount: aliases.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final alias = aliases[index];
              return ListTile(
                title: Text(alias.displayName),
                subtitle: Text(
                  '${alias.latitude.toStringAsFixed(5)}, '
                  '${alias.longitude.toStringAsFixed(5)} '
                  '(半径${alias.radiusMeters.round()}m)',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    await ref
                        .read(placeAliasRepositoryProvider)
                        .delete(alias.id!);
                    ref.invalidate(placeAliasesProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('読み込みエラー: $e')),
      ),
    );
  }

  Future<void> _showAddAliasSheet(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final radiusController = TextEditingController(text: '100');
    double? latitude;
    double? longitude;
    var locating = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '新しい場所を登録',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '表示名 (例: 自宅、会社)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: radiusController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '半径 (m)'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: locating
                        ? null
                        : () async {
                            setSheetState(() => locating = true);
                            try {
                              final position = await ref
                                  .read(locationServiceProvider)
                                  .currentPosition();
                              latitude = position.latitude;
                              longitude = position.longitude;
                            } finally {
                              setSheetState(() => locating = false);
                            }
                          },
                    icon: const Icon(Icons.my_location),
                    label: Text(
                      latitude == null
                          ? '現在地を取得'
                          : '現在地取得済み ($latitude, $longitude)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: locating
                        ? null
                        : () async {
                            if (nameController.text.trim().isEmpty ||
                                latitude == null ||
                                longitude == null) {
                              return;
                            }
                            final radius =
                                double.tryParse(radiusController.text) ?? 100;
                            await ref
                                .read(placeAliasRepositoryProvider)
                                .insert(
                                  PlaceAlias(
                                    latitude: latitude!,
                                    longitude: longitude!,
                                    radiusMeters: radius,
                                    displayName: nameController.text.trim(),
                                  ),
                                );
                            ref.invalidate(placeAliasesProvider);
                            if (context.mounted) Navigator.of(context).pop();
                          },
                    child: const Text('保存'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
