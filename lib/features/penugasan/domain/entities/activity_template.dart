import 'package:flutter/material.dart';

class ActivityTemplate {
  final String id;
  final String name;
  final String? description;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;

  ActivityTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.displayOrder,
    required this.isActive,
    required this.createdAt,
  });

  factory ActivityTemplate.fromMap(Map<String, dynamic> map) {
    return ActivityTemplate(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      displayOrder: map['display_order'] ?? 0,
      isActive: map['is_active'] ?? true,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  static IconData getIconForActivity(String name) {
    switch (name) {
      case 'Cari Titik Lokasi':
        return Icons.location_searching;
      case 'Cek Usulan Lokasi':
        return Icons.fact_check;
      case 'Survey BKS':
        return Icons.construction;
      case 'MOU dengan Landlord':
        return Icons.handshake;
      case 'Ukur Lokasi':
        return Icons.straighten;
      case 'Negosiasi dengan Landlord':
        return Icons.forum;
      case 'Aanwijzing':
        return Icons.groups;
      case 'Koordinasi Departemen':
        return Icons.corporate_fare;
      case 'Notaris':
        return Icons.gavel;
      case 'Meeting':
        return Icons.meeting_room;
      default:
        return Icons.assignment;
    }
  }
}