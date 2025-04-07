import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:travel_journal/models/journal_entry.dart';

class JournalProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('entries');
  List<JournalEntry> _entries = [];

  List<JournalEntry> get entries => _entries;

  JournalProvider() {
    _setupDatabaseListener();
  }

  void _setupDatabaseListener() {
    _dbRef.onValue.listen((DatabaseEvent event) {
      _entries = [];
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      
      if (data != null) {
        data.forEach((key, value) {
          _entries.add(JournalEntry(
            id: key.toString(),
            note: value['note'],
            latitude: value['latitude'],
            longitude: value['longitude'],
            date: DateTime.fromMillisecondsSinceEpoch(value['timestamp']),
          ));
        });
        _entries.sort((a, b) => b.date.compareTo(a.date));
        notifyListeners();
      }
    });
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _dbRef.push().set({
      'note': entry.note,
      'latitude': entry.latitude,
      'longitude': entry.longitude,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> deleteEntry(String id) async {
    await _dbRef.child(id).remove();

    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
  }
}