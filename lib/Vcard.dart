import 'package:flutter/material.dart';

class Vcard extends StatelessWidget {
  const Vcard({super.key});

  @override
  Widget build(BuildContext context) {
    final fields = [
      'Firstname', 'Lastname', 'Organization',
      'Position', 'Mobile Number', 'Private Number',
      'Emergency Contact ', 'Email', 'Website',
      'Street','Zipcode', 'City',
      'State','Country',
    ];

    // Split fields into 3 columns: every 3rd element
    List<String> col1 = [];
    List<String> col2 = [];
    List<String> col3 = [];

    for (int i = 0; i < fields.length; i++) {
      if (i % 3 == 0) {
        col1.add(fields[i]);
      } else if (i % 3 == 1) {
        col2.add(fields[i]);
      } else {
        col3.add(fields[i]);
      }
    }

    const double inputWidth = 140.0;
    const double spacing = 16.0;

    Widget buildColumn(List<String> labels) {
      return SizedBox(
        width: inputWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: labels.map((label) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 34,
                    child: TextField(
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 15,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildColumn(col1),
          const SizedBox(width: spacing),
          buildColumn(col2),
          const SizedBox(width: spacing),
          buildColumn(col3),
        ],
      ),
    );
  }
}
