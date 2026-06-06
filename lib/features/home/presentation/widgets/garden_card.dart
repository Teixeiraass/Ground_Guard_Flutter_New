import 'package:flutter/material.dart';

class GardenCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String humidity;
  final Color humidityColor;
  final bool enabled;
  final Color iconBg;

  const GardenCard({
    super.key,
    required this.icon,
    required this.title,
    required this.humidity,
    required this.humidityColor,
    required this.enabled,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5EF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF214225),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: humidityColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  humidity,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Switch(
                value: enabled,
                onChanged: (_) {},
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF123E15),
              ),
              const Spacer(),
              Icon(
                Icons.settings_outlined,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
