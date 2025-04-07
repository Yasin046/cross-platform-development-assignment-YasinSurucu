import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/models/journal_entry.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/screens/add_entry_screen.dart';
import 'package:travel_journal/services/notification_services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = Provider.of<JournalProvider>(context).entries;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Journal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _deleteAllEntries(context),
          ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(child: Text('No entries yet! Start your journey!'))
          : ListView.builder(
              itemCount: entries.length,
              itemBuilder: (ctx, i) => JournalEntryCard(entry: entries[i]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.pushNamed(context, AddEntryScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _deleteAllEntries(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Entries?'),
        content: const Text('This action cannot be undone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<JournalProvider>(context, listen: false);
              final entriesCopy = List<JournalEntry>.from(provider.entries);
              for (var entry in entriesCopy) {
                await provider.deleteEntry(entry.id!);
              }
              Navigator.pop(ctx);

              await NotificationService().showNotification(
                title: 'All Entries Deleted',
                body: 'Your travel journal has been cleared.',
              );
            },
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }
}

class JournalEntryCard extends StatelessWidget {
  final JournalEntry entry;

  const JournalEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.id),
      background: Container(color: Colors.red),
      onDismissed: (_) async {
        await Provider.of<JournalProvider>(context, listen: false)
            .deleteEntry(entry.id!);
        await NotificationService().showNotification(
          title: 'Entry Deleted',
          body: 'A journal entry was removed.',
        );
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        child: ListTile(
          title: Text(entry.note),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lat: ${entry.latitude.toStringAsFixed(5)}'),
              Text('Lon: ${entry.longitude.toStringAsFixed(5)}'),
              Text('Date: ${entry.date.toLocal().toString().substring(0, 16)}'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              await Provider.of<JournalProvider>(context, listen: false)
                  .deleteEntry(entry.id!);
              await NotificationService().showNotification(
                title: 'Entry Deleted',
                body: 'A journal entry was removed.',
              );
            },
          ),
        ),
      ),
    );
  }
}
