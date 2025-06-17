import 'package:flutter/material.dart';
import 'Url.dart'; // Make sure UrlScreen is a responsive widget

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text(
          'Welcome to QR Code Generator!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFAC1C),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final double containerWidth = isMobile
              ? constraints.maxWidth * 0.95 // Almost full width on mobile
              : constraints.maxWidth * 0.85; // Comfortable width on desktop

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Title Section with Gradient Text
                  Container(
                    width: containerWidth,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 16.0),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFFFAC1C), Colors.grey],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                      ),
                      child: Text(
                        'Generate amazing QR codes in seconds!',
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Visible under ShaderMask
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Main Content Container (Holds UrlScreen)
                  Container(
                    width: containerWidth,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(3, 6),
                        ),
                      ],
                    ),
                    child: const UrlScreen(), // Must be responsive inside
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
