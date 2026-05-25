import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final double progress;
  final String? label;

  const AppLoader({
    super.key,
    required this.progress,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              color: Color(0xFF2D4B37),       // cor da barra
              backgroundColor: Colors.grey[300], // fundo
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (label != null)
          Text(
            label!,
            style: const TextStyle(fontSize: 12),
          ),
      ],
    );
  }
}