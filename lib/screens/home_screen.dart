import 'package:flutter/material.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _urlCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _urlCtrl.text = await Config.getVpsUrl();
    _apiKeyCtrl.text = await Config.getApiKey();
    setState(() {});
  }

  Future<void> _save() async {
    await Config.save(
        vpsUrl: _urlCtrl.text.trim(), apiKey: _apiKeyCtrl.text.trim());
    setState(() => _saved = true);
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SBI Uploader - 設定')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SBI証券アプリで保有株CSVをダウンロードし、「共有」からこのアプリを選ぶとVPSへ自動アップロードされます。',
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(
                labelText: 'VPS URL',
                hintText: 'https://123.456.789.0',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apiKeyCtrl,
              decoration: const InputDecoration(
                labelText: 'API キー',
                hintText: '.envのUPLOAD_API_KEYの値',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('保存'),
            ),
            if (_saved)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  '保存しました',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF16a34a)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
