import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'Urltab.dart';
import 'Vcard.dart';
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

  final List<String> tabLabels = ['URL', 'VCARD', 'MECARD'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabLabels.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          color: const Color.fromARGB(80, 255, 192, 203),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Tabs
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
                const SizedBox(height: 30),

                /// Content Section
                const Text(
                  'Enter content',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (_) {
                    switch (selectedIndex) {
                      case 0:
                        return Urltab(
                          foregroundColor1: foregroundColor1,
                          foregroundColor2: foregroundColor2,
                          backgroundColor: backgroundColor,
                          isGradient: isGradientSelected,
                        );
                      case 1:
                        return Vcard(
                          foregroundColor1: foregroundColor1,
                          foregroundColor2: foregroundColor2,
                          backgroundColor: backgroundColor,
                          isGradient: isGradientSelected,
                        );
                      case 2:
                        return Mecard(
                          foregroundColor1: foregroundColor1,
                          foregroundColor2: foregroundColor2,
                          backgroundColor: backgroundColor,
                          isGradient: isGradientSelected,
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),

                const SizedBox(height: 24),

                /// Set Colors
                const Text(
                  'Set Colors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Foreground Color',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF757575)),
                ),
                Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: isGradientSelected,
                      onChanged: (val) => setState(() => isGradientSelected = false),
                    ),
                    const Text("Single Color"),
                    const SizedBox(width: 10),
                    Radio<bool>(
                      value: true,
                      groupValue: isGradientSelected,
                      onChanged: (val) => setState(() => isGradientSelected = true),
                    ),
                    const Text("Color Gradient"),
                  ],
                ),
                colorPickerRow(foregroundColor1, (color) => setState(() => foregroundColor1 = color)),
                const SizedBox(height: 15),
                if (isGradientSelected)
                  colorPickerRow(foregroundColor2, (color) => setState(() => foregroundColor2 = color)),
                const SizedBox(height: 20),
                const Text(
                  'Background Color',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF757575)),
                ),
                const SizedBox(height: 8),
                colorPickerRow(backgroundColor, (color) => setState(() => backgroundColor = color)),
              ],
            ),
          ),
        );
      },
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
              child: Text(
                hexValue,
                style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
