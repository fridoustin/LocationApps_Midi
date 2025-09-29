class UlokFilter {
  final String? status;
  final int? month;
  final int? year;

  UlokFilter({this.status, this.month, this.year});

  UlokFilter copyWith({String? status, int? month, int? year}) {
    return UlokFilter(
      status: status ?? this.status,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}