import 'package:flutter/material.dart';

class Mecard extends StatelessWidget {
  const Mecard({super.key});

  @override
  Widget build(BuildContext context) {
    final fields = [
      'Firstname', 'Lastname', 'Nickname',
      'Mobile Number', 'Emergency Number', 'Blood group',
      'Email', 'Website', 'Birthday',
      'Street','Zipcode', 'City',
      'State','Country','Notes',
    ];

    final fieldWidthMap = {
      'Firstname': 120.0,
      'Lastname': 120.0,
      'Nickname': 120.0,
      'Mobile Number': 120.0,
      'Emergency Number': 120.0,
      'Blood group': 120.0,
      'Email': 120.0,
      'Website': 120.0,
      'Birthday': 120.0,
      'Street': 120.0,
      'Zipcode': 120.0,
      'City': 120.0,
      'State': 120.0,
      'Country': 120.0,
      'Notes': 120.0,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: List.generate((fields.length / 3).ceil(), (rowIndex) {
          final rowFields = fields.skip(rowIndex * 3).take(3).toList();

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowFields.map((label) {
                return Container(
                  width: fieldWidthMap[label] ?? 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Roboto',
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 36,
                        child: TextField(
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
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
        }),
      ),
    );
  }
}
