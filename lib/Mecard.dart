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

class Mecard extends StatefulWidget {
  final Color foregroundColor1;
  final Color foregroundColor2;
  final Color backgroundColor;
  final bool isGradient;

  const Mecard({
    super.key,
    required this.foregroundColor1,
    required this.foregroundColor2,
    required this.backgroundColor,
    required this.isGradient,
  });

  @override
  State<Mecard> createState() => _MecardState();
}

class _MecardState extends State<Mecard> {
  final GlobalKey _qrKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String qrData = '';

  final Map<String, TextEditingController> _controllers = {};
  final fields = [
    'Firstname', 'Lastname', 'Nickname',
    'Mobile Number', 'Emergency Number', 'Blood group',
    'Email', 'Website', 'Birthday',
    'Street', 'Zipcode', 'City',
    'State', 'Country', 'Notes'
  ];

  @override
  void initState() {
    super.initState();
    for (var field in fields) {
      _controllers[field] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String generateMecardData() {
    StringBuffer buffer = StringBuffer('MECARD:');

    final first = _controllers['Firstname']?.text.trim() ?? '';
    final last = _controllers['Lastname']?.text.trim() ?? '';
    if (first.isNotEmpty || last.isNotEmpty) buffer.write('N:$last,$first;');

    final nickname = _controllers['Nickname']?.text.trim() ?? '';
    if (nickname.isNotEmpty) buffer.write('NICKNAME:$nickname;');

    final tel = _controllers['Mobile Number']?.text.trim() ?? '';
    if (tel.isNotEmpty) buffer.write('TEL:$tel;');

    final emergency = _controllers['Emergency Number']?.text.trim() ?? '';
    if (emergency.isNotEmpty) buffer.write('TEL-AV:$emergency;');

    final email = _controllers['Email']?.text.trim() ?? '';
    if (email.isNotEmpty) buffer.write('EMAIL:$email;');

    final bday = _controllers['Birthday']?.text.trim() ?? '';
    if (bday.isNotEmpty) buffer.write('BDAY:$bday;');

    final url = _controllers['Website']?.text.trim() ?? '';
    if (url.isNotEmpty) buffer.write('URL:$url;');

    final street = _controllers['Street']?.text.trim() ?? '';
    final city = _controllers['City']?.text.trim() ?? '';
    final state = _controllers['State']?.text.trim() ?? '';
    final zip = _controllers['Zipcode']?.text.trim() ?? '';
    final country = _controllers['Country']?.text.trim() ?? '';
    if ([street, city, state, zip, country].any((e) => e.isNotEmpty)) {
      buffer.write('ADR:$street,$city,$state,$zip,$country;');
    }

    final blood = _controllers['Blood group']?.text.trim() ?? '';
    final note = _controllers['Notes']?.text.trim() ?? '';
    if (note.isNotEmpty || blood.isNotEmpty) {
      buffer.write('NOTE:$note');
      if (blood.isNotEmpty) buffer.write(' (Blood: $blood)');
      buffer.write(';');
    }

    buffer.write(';');
    return buffer.toString();
  }

  Future<void> downloadQrCode() async {
    try {
      RenderRepaintBoundary boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      if (kIsWeb) {
        final blob = html.Blob([pngBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", "mecard_qr.png")
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        var status = await Permission.storage.request();
        if (status.isGranted) {
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/mecard_qr.png');
          await file.writeAsBytes(pngBytes);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR Code downloaded')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving QR: \$e');
    }
  }

  void _createQRCode() {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      Future.delayed(const Duration(milliseconds: 400), () {
        setState(() {
          qrData = generateMecardData();
          isLoading = false;
        });
      });
    }
  }

  Widget buildColumn(List<String> labels) {
    return SizedBox(
      width: 173,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: labels.map((label) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextFormField(
              controller: _controllers[label],
              validator: (value) {
                if ((label == 'Firstname' || label == 'Mobile Number' || label == 'Email') && (value == null || value.isEmpty)) {
                  return 'Required';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.grey),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.orange, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormSection(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 10),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: isMobile
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: buildColumn(fields.sublist(0, 8))),
              const SizedBox(width: 20),
              Expanded(child: buildColumn(fields.sublist(8))),
            ],
          )
              : Wrap(
            spacing: 45,
            runSpacing: 8,
            children: [
              buildColumn(fields.sublist(0, 8)),
              buildColumn(fields.sublist(8)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQrSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        RepaintBoundary(
          key: _qrKey,
          child: Container(
            color: widget.backgroundColor,
            width: isMobile ? 240 : 260,
            height: isMobile ? 240 : 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                isLoading
                    ? const Center(child: SizedBox(width: 200, height: 200, child: CircularProgressIndicator()))
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
                    data: qrData.isNotEmpty ? qrData : 'MECARD:N:,;;',
                    version: QrVersions.auto,
                    size: isMobile ? 220 : 250,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                if (!isLoading)
                  Container(
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
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _createQRCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAC1C),
                foregroundColor: const Color(0xFFEDE3F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 2,
              ),
              child: const Text('Create'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: downloadQrCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFAC1C),
                foregroundColor: const Color(0xFFEDE3F5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                elevation: 2,
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildFormSection(isMobile),
              const SizedBox(height: 30),
              _buildQrSection(isMobile),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: _buildFormSection(isMobile)),
              Expanded(flex: 1, child: _buildQrSection(isMobile)),
            ],
          ),
        ],
      ),
    );
  }
}
