import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'skeletons/greeting_skeleton.dart';

class GreetingSection extends ConsumerWidget {
  final String greeting;
  const GreetingSection({super.key, required this.greeting});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data:
          (profile) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                profile?.name ?? 'User',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
            ],
          ),
      loading: () => const GreetingSkeleton(),
      error:
          (err, stack) => Text(
            '$greeting\nGagal memuat nama',
            style: const TextStyle(color: Colors.red),
          ),
    );
  }
}
