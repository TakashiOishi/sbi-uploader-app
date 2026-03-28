import 'package:flutter/material.dart';
import '../upload_service.dart';

enum _State { confirm, uploading, done, error }

class UploadScreen extends StatefulWidget {
  final String filePath;
  final CsvType csvType;

  const UploadScreen(
      {super.key, required this.filePath, required this.csvType});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  _State _state = _State.confirm;
  String _message = '';
  late CsvType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.csvType;
  }

  Future<void> _upload() async {
    setState(() => _state = _State.uploading);

    final result = await UploadService.upload(
      filePath: widget.filePath,
      type: _selectedType,
    );

    setState(() {
      _state = result.success ? _State.done : _State.error;
      _message = result.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SBI Uploader')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: switch (_state) {
          _State.confirm => _buildConfirm(),
          _State.uploading => _buildUploading(),
          _State.done => _buildDone(),
          _State.error => _buildError(),
        },
      ),
    );
  }

  Widget _buildConfirm() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.upload_file, size: 64, color: Color(0xFF4f86f7)),
          const SizedBox(height: 24),
          Text(
            'CSVの種別を確認してください',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...CsvType.values.map((type) => RadioListTile<CsvType>(
                title: Text(type.label),
                value: type,
                groupValue: _selectedType,
                onChanged: (v) => setState(() => _selectedType = v!),
              )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _upload,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('VPSへアップロード'),
            style:
                ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ],
      );

  Widget _buildUploading() => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 24),
          Text('アップロード中...'),
        ],
      );

  Widget _buildDone() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Color(0xFF16a34a)),
          const SizedBox(height: 16),
          Text(_message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('閉じる'),
          ),
        ],
      );

  Widget _buildError() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Color(0xFFdc2626)),
          const SizedBox(height: 16),
          Text(
            _message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFdc2626)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _upload, child: const Text('再試行')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      );
}
