import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:html' as html;

class Urltab extends StatefulWidget {
  final Color foregroundColor1;
  final Color foregroundColor2;
  final Color backgroundColor;
  final bool isGradient;

  const Urltab({
    super.key,
    required this.foregroundColor1,
    required this.foregroundColor2,
    required this.backgroundColor,
    required this.isGradient,
  });

  @override
  State<Urltab> createState() => _UrltabState();
}

class _UrltabState extends State<Urltab> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final ScrollController _textScrollController = ScrollController();
  final GlobalKey _qrKey = GlobalKey();
  String _qrData = 'https://example.com';
  bool _isLoading = false;
  String _urlError = '';
  String _textError = '';
  String _lastFocusedField = '';

  void _clearText() {
    _controller.clear();
    setState(() {
      _qrData = _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : 'https://example.com';
    });
  }

  void _generateQRCode() {
    setState(() {
      _urlError = '';
      _textError = '';
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      final urlInput = _controller.text.trim();
      final textInput = _descController.text.trim();

      if (_lastFocusedField == 'url') {
        if (urlInput.isEmpty || !urlInput.contains('.')) {
          setState(() {
            _urlError = '⚠️ Please enter a valid URL';
            _isLoading = false;
          });
          return;
        }
        setState(() {
          _qrData = urlInput;
          _isLoading = false;
        });
      } else if (_lastFocusedField == 'text') {
        if (textInput.isEmpty) {
          setState(() {
            _textError = '⚠️ Please enter some text';
            _isLoading = false;
          });
          return;
        }
        setState(() {
          _qrData = textInput;
          _isLoading = false;
        });
      } else {
        setState(() {
          _qrData = 'https://example.com';
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _downloadQRCode() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 4.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([pngBytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "qr_code.png")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        if (await Permission.storage.request().isGranted) {
          final directory = await getExternalStorageDirectory();
          String path = '${directory!.path}/qr_code.png';
          File imgFile = File(path);
          await imgFile.writeAsBytes(pngBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('QR Code saved to $path')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save QR Code')),
      );
    }
  }

  Widget _buildInputSection() {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
          : const EdgeInsets.only(top: 0, left: 0, bottom: 12, right: 78),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your URL', style: TextStyle(fontSize: 17, color: Colors.grey)),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            onTap: () => _lastFocusedField = 'url',
            decoration: InputDecoration(
              hintText: 'Enter your URL here...',
              suffixIconConstraints: const BoxConstraints(
                minHeight: 32,
                minWidth: 32,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh, color: Colors.orange),
                onPressed: _clearText,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
            keyboardType: TextInputType.url,
          ),
          if (_urlError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_urlError, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          const SizedBox(height: 24),
          const Text('Your Text', style: TextStyle(fontSize: 17, color: Colors.grey)),
          const SizedBox(height: 10),
          Container(
            height: isMobile ? 220 : 180,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Scrollbar(
              controller: _textScrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _textScrollController,
                scrollDirection: Axis.vertical,
                child: TextField(
                  controller: _descController,
                  onTap: () => _lastFocusedField = 'text',
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ),
            ),
          ),
          if (_textError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_textError, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildQrPreviewSection() {
    return Column(
      children: [
        const SizedBox(height: 30),
        RepaintBoundary(
          key: _qrKey,
          child: Container(
            color: widget.backgroundColor,
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _isLoading
                    ? const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator()))
                    : ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: widget.isGradient
                        ? [widget.foregroundColor1, widget.foregroundColor2]
                        : [widget.foregroundColor1, widget.foregroundColor1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                if (!_isLoading)
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.backgroundColor,
                        image: const DecorationImage(
                          image: AssetImage('images/m logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _generateQRCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAC1C),
                foregroundColor: const Color(0xFFEDE3F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Create'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: _downloadQRCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAC1C),
                foregroundColor: const Color(0xFFEDE3F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Download'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputSection(),
                const SizedBox(height: 20),
                _buildQrPreviewSection(),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 32),
                    child: _buildInputSection(),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: _buildQrPreviewSection(),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _descController.dispose();
    _textScrollController.dispose();
    super.dispose();
  }
}
