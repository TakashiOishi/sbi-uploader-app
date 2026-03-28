import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:path/path.dart' as p;
import 'config.dart';

enum CsvType { portfolio, dividend }

extension CsvTypeExt on CsvType {
  String get endpoint {
    switch (this) {
      case CsvType.portfolio:
        return 'portfolio';
      case CsvType.dividend:
        return 'dividend';
    }
  }

  String get label {
    switch (this) {
      case CsvType.portfolio:
        return '保有証券';
      case CsvType.dividend:
        return '配当金・分配金';
    }
  }
}

/// 自己署名証明書を許可するHTTPクライアントを生成する
/// ⚠️ 個人・開発用途のみ。本番環境では使用しないこと
http.Client _createHttpClient() {
  final ioClient = HttpClient()
    ..badCertificateCallback = (cert, host, port) => true;
  return IOClient(ioClient);
}

class UploadService {
  /// ファイル名からCSV種別を自動判定する
  static CsvType detectType(String filename) {
    final lower = filename.toLowerCase();
    if (lower.contains('配当') || lower.contains('dividend') || lower.contains('分配')) {
      return CsvType.dividend;
    }
    return CsvType.portfolio;
  }

  /// CSVファイルをVPSへアップロードする
  static Future<UploadResult> upload({
    required String filePath,
    required CsvType type,
  }) async {
    final vpsUrl = await Config.getVpsUrl();
    final apiKey = await Config.getApiKey();
    final file = File(filePath);

    if (!await file.exists()) {
      return UploadResult.failure('ファイルが見つかりません: $filePath');
    }

    final uri = Uri.parse('${vpsUrl.replaceAll(RegExp(r'/+$'), '')}/upload/${type.endpoint}');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers['X-Api-Key'] = apiKey
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
          filename: p.basename(filePath),
        ));

      final client = _createHttpClient();
      final response =
          await client.send(request).timeout(const Duration(seconds: 30));
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return UploadResult.success('${type.label}のCSVをアップロードしました');
      } else {
        return UploadResult.failure(
            'サーバーエラー (${response.statusCode}): $body');
      }
    } on SocketException {
      return UploadResult.failure(
          'VPSに接続できません。URLとネットワークを確認してください。');
    } on Exception catch (e) {
      return UploadResult.failure('エラー: $e');
    }
  }
}

class UploadResult {
  final bool success;
  final String message;
  UploadResult.success(this.message) : success = true;
  UploadResult.failure(this.message) : success = false;
}
