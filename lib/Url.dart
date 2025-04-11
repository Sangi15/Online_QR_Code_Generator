// UrlScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io' show Platform, File;
import 'dart:html' as html;

class UrlScreen extends StatefulWidget {
  const UrlScreen({super.key});

  @override
  State<UrlScreen> createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> {
  String selectedOption = 'Color Gradient';
  Color startColor = const Color(0xFFC29930);
  Color endColor = const Color(0xFFA4AF30);
  Color singleColor = Colors.black;
  Color backgroundColor = Colors.white;
  final TextEditingController urlController = TextEditingController();
  String urlText = '';
  final GlobalKey qrKey = GlobalKey();
  bool _isLoading = false;

  void _pickColor(Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Done'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBox(Color color, void Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildColorInput(Color color, ValueChanged<Color> onPickColor) {
    final TextEditingController hexController = TextEditingController(
      text: '#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
    );

    return SizedBox(
      width: 300,
      child: Row(
        children: [
          _buildColorBox(color, () {
            _pickColor(color, (newColor) {
              onPickColor(newColor);
              setState(() {
                hexController.text =
                '#${newColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
              });
            });
          }),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              controller: hexController,
              readOnly: true,
              style: const TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD97904)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD97904)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD97904), width: 2),
                ),
                isDense: true,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadQRCode() async {
    try {
      RenderRepaintBoundary boundary =
      qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();
      final time = DateTime.now().millisecondsSinceEpoch;

      if (kIsWeb) {
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "qr_code_$time.png")
          ..click();
        html.Url.revokeObjectUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Downloaded on Web")),
        );
      } else if (Platform.isAndroid || Platform.isIOS) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission is required')),
          );
          return;
        }
        await ImageGallerySaver.saveImage(pngBytes, name: "qr_code_$time");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved to Gallery")),
        );
      } else {
        final directory = await getDownloadsDirectory();
        final file = File('${directory!.path}/qr_code_$time.png');
        await file.writeAsBytes(pngBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Saved to ${file.path}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving QR Code: $e")),
      );
    }
  }

  Widget _buildLeftContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Enter Content',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('Your URL',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 6),
        SizedBox(
          width: 300,
          child: TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: 'Enter your URL here...',
              hintStyle: const TextStyle(color: Colors.grey),
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFD97904)),
                onPressed: () {
                  setState(() {
                    urlController.clear();
                    urlText = '';
                  });
                },
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD97904)),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFD97904), width: 2),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Set Colors',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 10),
        const Text('Foreground Color',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 20,
          runSpacing: 10,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: 'Single Color',
                  groupValue: selectedOption,
                  onChanged: (value) => setState(() => selectedOption = value!),
                ),
                const Text('Single Color', style: TextStyle(color: Colors.grey)),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: 'Color Gradient',
                  groupValue: selectedOption,
                  onChanged: (value) => setState(() => selectedOption = value!),
                ),
                const Text('Color Gradient',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (selectedOption == 'Single Color')
          _buildColorInput(
              singleColor, (color) => setState(() => singleColor = color))
        else ...[
          _buildColorInput(
              startColor, (color) => setState(() => startColor = color)),
          const SizedBox(height: 8),
          _buildColorInput(
              endColor, (color) => setState(() => endColor = color)),
        ],
        const SizedBox(height: 20),
        const Text('Background Color',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
        const SizedBox(height: 6),
        _buildColorInput(backgroundColor,
                (color) => setState(() => backgroundColor = color)),
      ],
    );
  }

  Widget _buildRightContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          key: qrKey,
          child: Container(
            color: backgroundColor,
            padding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _isLoading
                    ? const SizedBox(
                  width: 200,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
                    : selectedOption == 'Single Color'
                    ? QrImageView(
                  data: urlText.isNotEmpty
                      ? urlText
                      : "https://example.com",
                  version: QrVersions.auto,
                  size: 200,
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: singleColor,
                  ),
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                )
                    : ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [startColor, endColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: QrImageView(
                    data: urlText.isNotEmpty
                        ? urlText
                        : "https://example.com",
                    version: QrVersions.auto,
                    size: 200,
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.white,
                    ),
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (!_isLoading)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: backgroundColor,
                      image: const DecorationImage(
                        image: AssetImage('images/m logo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 20,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () async {
                final input = urlController.text.trim();
                if (input.isEmpty) return;

                setState(() => _isLoading = true);
                await Future.delayed(const Duration(milliseconds: 500));

                Uri? parsedUri;
                try {
                  parsedUri = Uri.parse(input);
                } catch (_) {}

                setState(() {
                  urlText = parsedUri != null &&
                      parsedUri.hasScheme &&
                      parsedUri.hasAuthority
                      ? parsedUri.toString()
                      : input;
                  _isLoading = false;
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97904)),
              child: const Text("Create QR Code",
                  style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: _downloadQRCode,
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97904)),
              child: const Text("Download PNG",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 600;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: isMobile
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLeftContent(),
                  const SizedBox(height: 40),
                  Center(child: _buildRightContent()),
                ],
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _buildLeftContent()),
                  const SizedBox(width: 40),
                  Expanded(flex: 3, child: _buildRightContent()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
