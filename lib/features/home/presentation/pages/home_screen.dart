import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/services/notification_service.dart';
import 'package:midi_location/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:midi_location/features/home/presentation/provider/dashboard_provider.dart';
import 'package:midi_location/features/home/presentation/widgets/greeting_section.dart';
import 'package:midi_location/features/home/presentation/widgets/summary_grid_section.dart';
import 'package:midi_location/features/home/presentation/widgets/task_list_section.dart';
import 'package:midi_location/features/home/presentation/widgets/quick_actions_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  static const String route = '/home';

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour < 11) {
      return 'Selamat Pagi,';
    } else if (hour < 15) {
      return 'Selamat Siang,';
    } else if (hour < 18) {
      return 'Selamat Sore,';
    } else {
      return 'Selamat Malam,';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NotificationService().requestPermissionAndGetToken();
      }
    });
  }

  Future<void> _refreshData() async {
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(userProfileProvider);
  }

  @override
  Widget build(BuildContext context) {
    final String greeting = _getGreeting();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: null,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryColor,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GreetingSection(greeting: greeting),
                const SizedBox(height: 24),
                const SummaryGridSection(),
                const SizedBox(height: 24),
                const TaskListSection(),
                const SizedBox(height: 24),
                const QuickActionsSection(),
                const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
