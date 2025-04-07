class JournalEntry {
  final String? id;
  final String note;
  final double latitude;
  final double longitude;
  final DateTime date;

  JournalEntry({
    this.id,
    required this.note,
    required this.latitude,
    required this.longitude,
    required this.date,
  });
}