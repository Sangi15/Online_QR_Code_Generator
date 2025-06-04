import 'package:flutter/material.dart';

class Urltab extends StatefulWidget {
  const Urltab({super.key});

  @override
  State<Urltab> createState() => _UrltabState();
}

class _UrltabState extends State<Urltab> {
  final TextEditingController _controller = TextEditingController();

  void _clearText() {
    setState(() {
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          const Text(
            'Your URL',
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'Roboto',
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // ✅ Set max width here
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter your URL here...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.orange),
                  onPressed: _clearText,
                  tooltip: 'Clear text',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
    );
  }
}
