import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/models/journal_entry.dart';
import 'package:travel_journal/providers/journal_provider.dart';
import 'package:travel_journal/services/location_services.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});
  static const routeName = '/add-entry';

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  double? _latitude;
  double? _longitude;

  Future<void> _getLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please get location first')),
      );
      return;
    }

    final newEntry = JournalEntry(
      note: _noteController.text,
      latitude: _latitude!,
      longitude: _longitude!,
      date: DateTime.now(),
    );

    Provider.of<JournalProvider>(context, listen: false).addEntry(newEntry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Journal Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Journal Entry',
                    hintText: 'Describe your experience...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) => value!.isEmpty ? 'Please enter a note' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.location_on),
                  label: const Text('Get Current Location'),
                  onPressed: _getLocation,
                ),
                const SizedBox(height: 10),
                if (_latitude != null && _longitude != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            'Coordinates:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          Text(
                            'Lat: ${_latitude!.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Lon: ${_longitude!.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveEntry,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('Save Entry', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}