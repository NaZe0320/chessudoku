// records_screen.dart

import 'package:flutter/material.dart';
import 'package:chessudoku/models/game_record.dart';
import 'package:chessudoku/services/storage_service.dart';
import 'package:chessudoku/utils/helpers.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StorageService _storageService;
  List<GameRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.initialize();
    await _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      _records = await _storageService.getAllGameRecords();
    } catch (e) {
      print('Error loading records: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<GameRecord> _getFilteredRecords(String? difficulty) {
    if (difficulty == null) return _records;
    return _records.where((record) => record.difficulty == difficulty.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Records'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'All'), Tab(text: 'Easy'), Tab(text: 'Medium'), Tab(text: 'Hard')],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildRecordList(null),
                  _buildRecordList('Easy'),
                  _buildRecordList('Medium'),
                  _buildRecordList('Hard'),
                ],
              ),
    );
  }

  Widget _buildRecordList(String? difficulty) {
    final records = _getFilteredRecords(difficulty);
    if (records.isEmpty) {
      return const Center(child: Text('No records yet', style: TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getDifficultyColor(record.difficulty),
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            title: Text(
              formatDuration(Duration(seconds: record.elapsedSeconds)),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Completed: ${_formatDate(record.completedAt)}\n'
              'Hints used: ${record.hintsUsed}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
