import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'dart:async';
import 'screens/home_screen.dart';
import 'screens/upload_screen.dart';
import 'upload_service.dart';

void main() {
  runApp(const SbiUploaderApp());
}

final navigatorKey = GlobalKey<NavigatorState>();

class SbiUploaderApp extends StatefulWidget {
  const SbiUploaderApp({super.key});

  @override
  State<SbiUploaderApp> createState() => _SbiUploaderAppState();
}

class _SbiUploaderAppState extends State<SbiUploaderApp> {
  StreamSubscription? _intentSub;

  @override
  void initState() {
    super.initState();

    // アプリが起動中に共有を受けた場合
    _intentSub =
        ReceiveSharingIntent.instance.getMediaStream().listen((files) {
      if (files.isNotEmpty) {
        _handleSharedFile(files.first.path);
      }
    });

    // アプリが終了中に共有を受けて起動した場合
    ReceiveSharingIntent.instance.getInitialMedia().then((files) {
      if (files.isNotEmpty) {
        _handleSharedFile(files.first.path);
        ReceiveSharingIntent.instance.reset();
      }
    });
  }

  void _handleSharedFile(String filePath) {
    final csvType = UploadService.detectType(filePath);

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => UploadScreen(filePath: filePath, csvType: csvType),
      ),
    );
  }

  @override
  void dispose() {
    _intentSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'SBI Uploader',
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(primary: Color(0xFF4f86f7)),
      ),
      home: const HomeScreen(),
    );
  }
}
