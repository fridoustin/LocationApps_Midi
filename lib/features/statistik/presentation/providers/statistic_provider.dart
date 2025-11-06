import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/statistic_data.dart';

enum ChartType { ulok, kplt }

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final statisticDateProvider = StateProvider.autoDispose<DateTime>((ref) {
  return DateTime.now();
});

final chartTypeProvider = StateProvider.autoDispose<ChartType>((ref) {
  return ChartType.ulok;
});

final statisticProvider = FutureProvider.autoDispose<StatisticData>((
  ref,
) async {
  final supabase = ref.watch(supabaseClientProvider);
  final DateTime selectedDate = ref.watch(statisticDateProvider);
  final int currentYear = selectedDate.year;
  final int currentMonth = selectedDate.month;
  try {
    final response = await supabase.rpc(
      'get_user_statistics',
      params: {'p_year': currentYear, 'p_month': currentMonth},
    );
    if (response == null) {
      throw Exception('Data statistik tidak ditemukan.');
    }
    return StatisticData.fromJson(response);
  } on PostgrestException catch (e) {
    print('Supabase Error: ${e.message}');
    throw Exception('Gagal memuat data: ${e.message}');
  } catch (e) {
    print('Error fetching statistics: $e');
    throw Exception('Gagal memuat data statistik: $e');
  }
});
