import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AlertData {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final Color cardColor;
  final Color borderColor;
  final Color timeColor;

  const AlertData({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.cardColor,
    required this.borderColor,
    required this.timeColor,
  });

  factory AlertData.fromJson(Map<String, dynamic> json) {
    final eventName = json['event'] ?? 'Alert';
    final desc = json['description'] ?? json['sender_name'] ?? 'Weather alert issued';

    // Parse start time
    final startDt = DateTime.fromMillisecondsSinceEpoch((json['start'] as int) * 1000);
    final now = DateTime.now();
    final isToday = startDt.year == now.year && startDt.month == now.month && startDt.day == now.day;
    final timeStr = (isToday ? 'Today ' : '${DateFormat('EE').format(startDt)} ') + DateFormat('HH:mm').format(startDt);

    // Default icon/colors (Warning orange)
    IconData icon = LucideIcons.alertTriangle;
    Color iconColor = const Color(0xFFFDBA74);
    Color iconBgColor = const Color(0x66EA580C);
    Color cardColor = const Color(0xFF3C2714);
    Color borderColor = const Color(0x66EA580C);
    Color timeColor = const Color(0xFFFDBA74);

    final lowerEvent = eventName.toLowerCase();
    if (lowerEvent.contains('storm') || lowerEvent.contains('thunder') || lowerEvent.contains('tornado')) {
      icon = LucideIcons.cloudLightning;
      iconColor = const Color(0xFFFCA5A5);
      iconBgColor = const Color(0x667F1D1D);
      cardColor = const Color(0xFF3A1C23);
      borderColor = const Color(0x667F1D1D);
      timeColor = const Color(0xFFFCA5A5);
    } else if (lowerEvent.contains('rain') || lowerEvent.contains('flood') || lowerEvent.contains('water')) {
      icon = LucideIcons.cloudRain;
      iconColor = const Color(0xFF93C5FD);
      iconBgColor = const Color(0x661D4ED8);
      cardColor = const Color(0xFF13263C);
      borderColor = const Color(0x661D4ED8);
      timeColor = const Color(0xFF93C5FD);
    } else if (lowerEvent.contains('heat') || lowerEvent.contains('sun') || lowerEvent.contains('fire')) {
      icon = LucideIcons.sun;
      iconColor = const Color(0xFFFDBA74);
      iconBgColor = const Color(0x66EA580C);
      cardColor = const Color(0xFF3C2714);
      borderColor = const Color(0x66EA580C);
      timeColor = const Color(0xFFFDBA74);
    } else if (lowerEvent.contains('wind') || lowerEvent.contains('cold') || lowerEvent.contains('winter')) {
      icon = LucideIcons.wind;
      iconColor = const Color(0xFFA5B4FC);
      iconBgColor = const Color(0x663730A3);
      cardColor = const Color(0xFF1E1B4B);
      borderColor = const Color(0x663730A3);
      timeColor = const Color(0xFFA5B4FC);
    }

    return AlertData(
      title: eventName,
      description: desc,
      time: timeStr,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      cardColor: cardColor,
      borderColor: borderColor,
      timeColor: timeColor,
    );
  }
}
