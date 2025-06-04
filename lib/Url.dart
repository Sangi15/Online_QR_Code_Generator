import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform, File;
import 'dart:html' as html;

import 'Urltab.dart';
import 'Vcard.dart';
import 'Texttab.dart';
import 'Mecard.dart';

class UrlScreen extends StatefulWidget {
  const UrlScreen({super.key});

  @override
  State<UrlScreen> createState() => _UrlScreenState();
}

class _UrlScreenState extends State<UrlScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedIndex = 0;
  bool isGradientSelected = true;

  Color foregroundColor1 = const Color(0xFF021945);
  Color foregroundColor2 = const Color(0xFFFFAC1C);
  Color backgroundColor = const Color(0xFFFFFFFF);

  final List<String> tabLabels = ['URL', 'VCARD', 'TEXT', 'MECARD'];
  final GlobalKey qrKey = GlobalKey();
  String urlText = '';
  final TextEditingController urlController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedIndex = _tabController.index;
        });
      }
    });
  }

  void pickColor(Color currentColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a color'),
        content: ColorPicker(
          pickerColor: currentColor,
          onColorChanged: onColorChanged,
          showLabel: true,
          pickerAreaHeightPercent: 0.8,
        ),
        actions: [
          TextButton(
            child: const Text('SELECT'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary = qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (await Permission.storage.request().isGranted) {
        final directory = await getExternalStorageDirectory();
        final path = '${directory!.path}/qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File(path);
        await file.writeAsBytes(pngBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("QR code saved at $path")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission denied")),
        );
      }
    } catch (e) {
      print("Error saving QR code: $e");
    }
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


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(80, 255, 192, 203),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// LEFT PANEL
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(tabLabels.length, (i) {
                      return Row(
                        children: [
                          GradientTabButton(
                            isSelected: selectedIndex == i,
                            onTap: () {
                              _tabController.animateTo(i);
                              setState(() => selectedIndex = i);
                            },
                            label: tabLabels[i],
                          ),
                          if (i < tabLabels.length - 1) const SizedBox(width: 10),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Enter content', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF757575))),
                const SizedBox(height: 8),
                Builder(
                  builder: (_) {
                    switch (selectedIndex) {
                      case 0: return const Urltab();
                      case 1: return const Vcard();
                      case 2: return const Texttab();
                      case 3: return const Mecard();
                      default: return const SizedBox.shrink();
                    }
                  },
                ),
                const SizedBox(height: 24),
                const Text('Set Colors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF757575))),
                const SizedBox(height: 8),
                const Text('Foreground Color', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF757575))),
                Row(
                  children: [
                    Radio<bool>(value: false, groupValue: isGradientSelected, onChanged: (val) => setState(() => isGradientSelected = false)),
                    const Text("Single Color"),
                    const SizedBox(width: 10),
                    Radio<bool>(value: true, groupValue: isGradientSelected, onChanged: (val) => setState(() => isGradientSelected = true)),
                    const Text("Color Gradient"),
                  ],
                ),
                colorPickerRow(foregroundColor1, (color) => setState(() => foregroundColor1 = color)),
                const SizedBox(height: 15),
                if (isGradientSelected)
                  colorPickerRow(foregroundColor2, (color) => setState(() => foregroundColor2 = color)),
                const SizedBox(height: 20),
                const Text('Background Color', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF757575))),
                colorPickerRow(backgroundColor, (color) => setState(() => backgroundColor = color)),
              ],
            ),
          ),

          const SizedBox(width: 10),

          /// RIGHT PANEL
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, right: 70),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: qrKey,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.transparent,
                      child: Container(
                        width: 320,
                        height: 250,
                        color: backgroundColor,
                        alignment: Alignment.center,
                        child: buildQrWithLogo(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFAC1C),
                          foregroundColor: Colors.white,
                        ),
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
                        child: const Text("Create"),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFAC1C),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _downloadQRCode,
                        child: const Text("Download"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ QR CODE WITH CENTER CIRCULAR LOGO
  Widget buildQrWithLogo() {
    final qrData = urlText.isEmpty ? 'https://example.com' : urlText;

    final qrCode = QrImageView(
      data: qrData,
      size: 300,
      backgroundColor: Colors.transparent,
      eyeStyle: QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: isGradientSelected ? Colors.white : foregroundColor1,
      ),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: isGradientSelected ? Colors.white : foregroundColor1,
      ),
      embeddedImage: AssetImage('images/m logo.png'), // Optional: your logo asset
      embeddedImageStyle: QrEmbeddedImageStyle(
        size: const Size(60, 60),
      ),
    );

    if (!isGradientSelected) {
      return qrCode;
    }

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [foregroundColor1, foregroundColor2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      blendMode: BlendMode.srcIn,
      child: qrCode,
    );
  }



  Widget colorPickerRow(Color color, Function(Color) onColorChanged) {
    final hexValue = "#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}";
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => pickColor(color, onColorChanged),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 40,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(hexValue, style: const TextStyle(fontFamily: 'Roboto', fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class GradientTabButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String label;

  const GradientTabButton({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 90,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF021945), Color(0xFFFFAC1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF021945),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
    );
  }
}