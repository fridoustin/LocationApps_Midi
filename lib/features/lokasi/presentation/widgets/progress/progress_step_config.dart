import 'package:flutter/material.dart';

class ProgressStepConfig {
  final String key;
  final String label;
  final String title;
  final String description;
  final IconData icon;

  const ProgressStepConfig({
    required this.key,
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
  });

  static const List<ProgressStepConfig> steps = [
    ProgressStepConfig(
      key: 'mou',
      label: 'MOU',
      title: 'MOU',
      description: 'Tahap pembuatan dan penandatanganan kesepakatan awal',
      icon: Icons.handshake,
    ),
    ProgressStepConfig(
      key: 'izin_tetangga',
      label: 'Izin\nTetangga',
      title: 'Izin Tetangga',
      description: 'Proses mendapatkan persetujuan dari tetangga sekitar',
      icon: Icons.people,
    ),
    ProgressStepConfig(
      key: 'perizinan',
      label: 'Perizinan',
      title: 'Perizinan',
      description: 'Pengurusan dokumen dan izin resmi dari instansi terkait',
      icon: Icons.description,
    ),
    ProgressStepConfig(
      key: 'notaris',
      label: 'Notaris',
      title: 'Notaris',
      description: 'Proses legalisasi dokumen melalui notaris',
      icon: Icons.account_balance,
    ),
    ProgressStepConfig(
      key: 'renovasi',
      label: 'Renovasi',
      title: 'Renovasi',
      description: 'Tahap perbaikan dan penataan lokasi',
      icon: Icons.construction,
    ),
    ProgressStepConfig(
      key: 'grand_opening',
      label: 'Grand\nOpening',
      title: 'Grand Opening',
      description: 'Peresmian dan pembukaan lokasi',
      icon: Icons.celebration_rounded,
    ),
  ];

  static ProgressStepConfig getStep(String key) {
    return steps.firstWhere(
      (step) => step.key == key,
      orElse: () => const ProgressStepConfig(
        key: 'unknown',
        label: 'Unknown',
        title: 'Progress',
        description: 'Detail tahapan progress',
        icon: Icons.info,
      ),
    );
  }
}