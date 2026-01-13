import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/lost_found_provider.dart';
import '../providers/user_provider.dart';

class LostFoundPage extends StatelessWidget {
  const LostFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lost & Found')),
      body: Consumer<LostFoundProvider>(
        builder: (context, provider, _) {
          if (provider.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text('No items yet', style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.file(
                        File(item.imagePath),
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 70, color: Colors.grey),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.caption, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(item.userName, style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context),
        icon: const Icon(Icons.add_a_photo),
        label: const Text('Add Item'),
      ),
    );
  }

  Future<void> _addItem(BuildContext context) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user == null) return;

    final captionController = TextEditingController();
    final picker = ImagePicker();
    XFile? picked;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: captionController,
                  decoration: const InputDecoration(
                    labelText: 'Caption',
                    prefixIcon: Icon(Icons.edit),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) setState(() => picked = img);
                  },
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: picked == null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text('Tap to select image', style: TextStyle(color: Colors.grey[600])),
                              ],
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(picked!.path),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 70, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    if (picked == null || captionController.text.isEmpty) {
                      Navigator.pop(context);
                      return;
                    }
                    final provider = Provider.of<LostFoundProvider>(context, listen: false);
                    await provider.addItem(
                      LostFoundItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: user.id,
                        userName: user.name,
                        caption: captionController.text,
                        imagePath: picked!.path,
                        createdAt: DateTime.now(),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Post Item'),
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
        );
      },
    );
  }
}


