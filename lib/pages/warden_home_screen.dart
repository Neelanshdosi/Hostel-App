import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../providers/complaint_provider.dart';
import '../models/models.dart';
import '../pages/profile_screen.dart';
import 'lost_found_page.dart';
import 'warden_menu_page.dart';
import 'warden_students_page.dart';

class WardenHomeScreen extends StatefulWidget {
  const WardenHomeScreen({super.key});

  @override
  State<WardenHomeScreen> createState() => _WardenHomeScreenState();
}

class _WardenHomeScreenState extends State<WardenHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warden Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Lost & Found',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LostFoundPage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Manage Menu',
            icon: const Icon(Icons.restaurant),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WardenMenuPage()),
              );
            },
          ),
          IconButton(
            tooltip: 'Students',
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WardenStudentsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<ComplaintProvider>(
        builder: (context, complaintProvider, child) {
          final complaints = complaintProvider.getAllComplaints();

          return Column(
            children: [
              _buildStatsCard(complaintProvider),
              Expanded(
                child: complaints.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: complaints.length,
                        itemBuilder: (context, index) {
                          return _ComplaintCard(
                            complaint: complaints[index],
                            onStatusChanged: (status, comment) {
                              complaintProvider.updateComplaintStatus(
                                complaints[index].id,
                                status,
                                comment,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(ComplaintProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', provider.complaints.length, Icons.list),
          _buildStatItem('Pending', provider.getPendingCount(), Icons.pending),
          _buildStatItem('Resolved', provider.getResolvedCount(), Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No complaints yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _ComplaintCard extends StatefulWidget {
  final Complaint complaint;
  final Function(ComplaintStatus, String?) onStatusChanged;

  const _ComplaintCard({
    required this.complaint,
    required this.onStatusChanged,
  });

  @override
  State<_ComplaintCard> createState() => _ComplaintCardState();
}

class _ComplaintCardState extends State<_ComplaintCard> {
  late bool _isResolved;

  @override
  void initState() {
    super.initState();
    _isResolved = widget.complaint.status == ComplaintStatus.resolved;
  }

  void _toggleStatus() async {
    if (!_isResolved) {
      final comment = await _showCommentDialog();
      if (comment != null) {
        setState(() => _isResolved = true);
        widget.onStatusChanged(ComplaintStatus.resolved, comment);
      }
    } else {
      setState(() => _isResolved = false);
      widget.onStatusChanged(ComplaintStatus.pending, null);
    }
  }

  Future<String?> _showCommentDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Resolution Comment'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Enter resolution comment (optional)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.complaint.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Switch(
                  value: _isResolved,
                  onChanged: (_) => _toggleStatus(),
                  activeThumbColor: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(widget.complaint.userName, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(width: 16),
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(widget.complaint.category.displayName, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 12),
            Text(widget.complaint.description),
            if (widget.complaint.imagePath != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(widget.complaint.imagePath!),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              DateFormat('MMM dd, yyyy - hh:mm a').format(widget.complaint.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}