import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/models.dart';

class ComplaintProvider extends ChangeNotifier {
  List<Complaint> _complaints = [];
  static const String _complaintsKey = 'complaints';

  List<Complaint> get complaints => _complaints;

  ComplaintProvider() {
    _loadComplaints();
  }

  // Load complaints from local storage
  Future<void> _loadComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final complaintsJson = prefs.getString(_complaintsKey);
    
    if (complaintsJson != null) {
      final List<dynamic> decoded = jsonDecode(complaintsJson);
      _complaints = decoded.map((json) => Complaint.fromJson(json)).toList();
      notifyListeners();
    }
  }

  // Save complaints to local storage
  Future<void> _saveComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final complaintsJson = jsonEncode(
      _complaints.map((c) => c.toJson()).toList(),
    );
    await prefs.setString(_complaintsKey, complaintsJson);
  }

  // Add new complaint
  Future<void> addComplaint(Complaint complaint) async {
    _complaints.insert(0, complaint);
    await _saveComplaints();
    notifyListeners();
  }

  // Update complaint status (for warden)
  Future<void> updateComplaintStatus(
    String complaintId,
    ComplaintStatus status,
    String? wardenComment,
  ) async {
    final index = _complaints.indexWhere((c) => c.id == complaintId);
    if (index != -1) {
      _complaints[index] = _complaints[index].copyWith(
        status: status,
        wardenComment: wardenComment,
      );
      await _saveComplaints();
      notifyListeners();
    }
  }

  // Get complaints by user ID
  List<Complaint> getComplaintsByUser(int userId) {
    return _complaints.where((c) => c.userId == userId).toList();
  }

  // Get all complaints (for warden)
  List<Complaint> getAllComplaints() {
    return _complaints;
  }

  // Get pending complaints count
  int getPendingCount() {
    return _complaints.where((c) => c.status == ComplaintStatus.pending).length;
  }

  // Get resolved complaints count
  int getResolvedCount() {
    return _complaints.where((c) => c.status == ComplaintStatus.resolved).length;
  }
}