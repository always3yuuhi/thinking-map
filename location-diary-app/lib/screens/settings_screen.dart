import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/service_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiKeyController = TextEditingController();
  int _intervalMinutes = 5;
  TimeOfDay _triggerTime = const TimeOfDay(hour: 23, minute: 0);
  bool _obscureKey = true;
  bool _savingKey = false;
  bool _apiKeyFieldTouched = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKeyAsync = ref.watch(claudeApiKeyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('位置情報取得頻度', style: Theme.of(context).textTheme.titleMedium),
          DropdownButton<int>(
            value: _intervalMinutes,
            items: const [3, 5, 10]
                .map((m) => DropdownMenuItem(value: m, child: Text('$m分ごと')))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _intervalMinutes = value);
            },
          ),
          const SizedBox(height: 24),
          Text('日記生成トリガー時刻', style: Theme.of(context).textTheme.titleMedium),
          OutlinedButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _triggerTime,
              );
              if (picked != null) setState(() => _triggerTime = picked);
            },
            child: Text(_triggerTime.format(context)),
          ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '取得頻度・トリガー時刻は現時点では保存されません(フェーズ2で永続化予定)。',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const Divider(height: 40),
          Text('Claude APIキー', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          const Text(
            '日記生成にはAnthropicのClaude APIキーが必要です。未設定の場合は仮の日記が表示されます。',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          apiKeyAsync.when(
            data: (storedKey) {
              if (!_apiKeyFieldTouched && storedKey != null) {
                _apiKeyController.text = storedKey;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _apiKeyController,
                    obscureText: _obscureKey,
                    onChanged: (_) => _apiKeyFieldTouched = true,
                    decoration: InputDecoration(
                      labelText: 'APIキー',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureKey
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscureKey = !_obscureKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _savingKey ? null : _saveApiKey,
                          child: _savingKey
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('保存'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (storedKey != null)
                        OutlinedButton(
                          onPressed: _savingKey ? null : _clearApiKey,
                          child: const Text('削除'),
                        ),
                    ],
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Text('読み込みエラー: $e'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveApiKey() async {
    setState(() => _savingKey = true);
    try {
      await ref
          .read(apiKeyStorageProvider)
          .writeClaudeApiKey(_apiKeyController.text.trim());
      ref.invalidate(claudeApiKeyProvider);
      _apiKeyFieldTouched = false;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('APIキーを保存しました')));
      }
    } finally {
      if (mounted) setState(() => _savingKey = false);
    }
  }

  Future<void> _clearApiKey() async {
    setState(() => _savingKey = true);
    try {
      await ref.read(apiKeyStorageProvider).deleteClaudeApiKey();
      ref.invalidate(claudeApiKeyProvider);
      _apiKeyController.clear();
      _apiKeyFieldTouched = false;
    } finally {
      if (mounted) setState(() => _savingKey = false);
    }
  }
}
