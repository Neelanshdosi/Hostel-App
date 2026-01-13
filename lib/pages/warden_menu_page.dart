import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/menu_provider.dart';

class WardenMenuPage extends StatefulWidget {
  const WardenMenuPage({super.key});

  @override
  State<WardenMenuPage> createState() => _WardenMenuPageState();
}

class _WardenMenuPageState extends State<WardenMenuPage> {
  late TextEditingController _breakfast;
  late TextEditingController _lunch;
  late TextEditingController _snacks;
  late TextEditingController _dinner;
  late TextEditingController _update;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final today = context.read<MenuProvider>().getTodayMenu();
    _breakfast = TextEditingController(text: today.breakfast);
    _lunch = TextEditingController(text: today.lunch);
    _snacks = TextEditingController(text: today.snacks);
    _dinner = TextEditingController(text: today.dinner);
    _update = TextEditingController(text: today.todaysUpdate);
    if (today.imagePath != null) {
      _imageFile = File(today.imagePath!);
    }
  }

  @override
  void dispose() {
    _breakfast.dispose();
    _lunch.dispose();
    _snacks.dispose();
    _dinner.dispose();
    _update.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Today\'s Menu')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Image picker and preview
          Card(
            child: InkWell(
              onTap: () async {
                final picker = ImagePicker();
                final x = await picker.pickImage(source: ImageSource.gallery);
                if (x != null) setState(() => _imageFile = File(x.path));
              },
              child: Container(
                height: 200,
                alignment: Alignment.center,
                child: _imageFile == null
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('Tap to upload today\'s menu image', style: TextStyle(color: Colors.grey[600])),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _field('Breakfast', _breakfast, Icons.free_breakfast),
          const SizedBox(height: 12),
          _field('Lunch', _lunch, Icons.lunch_dining),
          const SizedBox(height: 12),
          _field('Snacks', _snacks, Icons.cookie),
          const SizedBox(height: 12),
          _field('Dinner', _dinner, Icons.dinner_dining),
          const SizedBox(height: 12),
          TextField(
            controller: _update,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Today\'s Update/Comment',
              prefixIcon: Icon(Icons.campaign),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: () async {
                final provider = context.read<MenuProvider>();
                final current = provider.getTodayMenu();
                final updated = current.copyWith(
                  breakfast: _breakfast.text,
                  lunch: _lunch.text,
                  snacks: _snacks.text,
                  dinner: _dinner.text,
                  todaysUpdate: _update.text,
                  imagePath: _imageFile?.path,
                );
                await provider.updateToday(updated);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Menu saved for today')),
                );
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}


