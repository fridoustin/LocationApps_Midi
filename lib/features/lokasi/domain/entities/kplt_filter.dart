class KpltFilter {
  final String? status; 
  final int? month;
  final int? year;

  const KpltFilter({
    this.status,
    this.month,
    this.year,
  });

  static const empty = KpltFilter();

  KpltFilter copyWith({String? status, int? month, int? year}) {
    return KpltFilter(
      status: status ?? this.status,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}