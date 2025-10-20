import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/features/form_kplt/presentation/pages/kplt_form_screen.dart';
import 'package:midi_location/features/lokasi/presentation/providers/ulok_provider.dart'; 

class KpltNotificationHandlerPage extends ConsumerWidget {
  final String ulokId;
  const KpltNotificationHandlerPage({super.key, required this.ulokId});
  static const String route = '/form-kplt';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ulokAsync = ref.watch(ulokByIdProvider(ulokId));

    return Scaffold(
      body: ulokAsync.when(
        data: (ulokData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => KpltFormPage(ulok: ulokData),
              ),
            );
          });
          return const Center(child: CircularProgressIndicator());
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Gagal memuat data ULOK: $err'),
          ),
        ),
      ),
    );
  }
}