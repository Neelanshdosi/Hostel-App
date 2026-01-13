import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/students_provider.dart';
import '../models/models.dart';

class WardenStudentsPage extends StatelessWidget {
  const WardenStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: Consumer<StudentsProvider>(
        builder: (context, provider, _) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final s = provider.students[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(s.name.isNotEmpty ? s.name[0].toUpperCase() : 'S')),
                  title: Text(s.name),
                  subtitle: Text('@${s.username}${s.roomNumber.isNotEmpty ? ' · Room ${s.roomNumber}' : ''}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => context.read<StudentsProvider>().removeStudent(s.id),
                  ),
                  onTap: () => _showStudent(context, s),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Student'),
      ),
    );
  }

  void _showStudent(BuildContext context, User s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Username: @${s.username}'),
            if (s.roomNumber.isNotEmpty) Text('Room: ${s.roomNumber}'),
            if (s.phoneNumber.isNotEmpty) Text('Phone: ${s.phoneNumber}'),
            if (s.emergencyContact.isNotEmpty) Text('Emergency: ${s.emergencyContact}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final name = TextEditingController();
    final username = TextEditingController();
    final room = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: username, decoration: const InputDecoration(labelText: 'Username')),
            TextField(controller: room, decoration: const InputDecoration(labelText: 'Room Number')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final s = User(
                id: DateTime.now().millisecondsSinceEpoch,
                username: username.text,
                name: name.text,
                role: 'student',
                roomNumber: room.text,
                phoneNumber: '',
                emergencyContact: '',
              );
              await context.read<StudentsProvider>().addStudent(s);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}


