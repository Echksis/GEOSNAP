import 'dart:typed_data';
import 'dart:ui_web' as ui;

import 'package:flutter/material.dart';

import 'web_camera_service.dart';

class WebCameraView extends StatefulWidget {
  const WebCameraView({super.key, required this.onPhotoTaken});

  final ValueChanged<Uint8List> onPhotoTaken;

  @override
  State<WebCameraView> createState() => _WebCameraViewState();
}

class _WebCameraViewState extends State<WebCameraView> {
  static int _nextViewId = 0;

  final WebCameraService _camera = WebCameraService();
  late final String _viewType;
  bool _ready = false;
  bool _capturing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _viewType = 'geosnap-web-camera-${_nextViewId++}';
    _start();
  }

  Future<void> _start() async {
    try {
      final video = await _camera.startCamera();
      ui.platformViewRegistry.registerViewFactory(
        _viewType,
        (int viewId) => video,
      );
      if (!mounted) {
        await _camera.stopCamera();
        return;
      }
      setState(() => _ready = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _capture() async {
    if (!_ready || _capturing) return;
    setState(() => _capturing = true);
    try {
      final bytes = await _camera.takePhoto();
      if (mounted) widget.onPhotoTaken(bytes);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  @override
  void dispose() {
    _camera.stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: _error != null
                ? SingleChildScrollView(
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center),
                  )
                : !_ready
                    ? const CircularProgressIndicator()
                    : HtmlElementView(viewType: _viewType),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _ready && !_capturing ? _capture : null,
          icon: const Icon(Icons.camera_alt),
          label: Text(_capturing ? 'Mengambil foto...' : 'Ambil Foto'),
        ),
      ],
    );
  }
}
