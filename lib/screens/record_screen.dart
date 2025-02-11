// record_screen.dart

import 'package:chessudoku/utils/app_localizations.dart';
import 'package:chessudoku/widgets/common/banner_ad.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chessudoku/models/game_record.dart';
import 'package:chessudoku/services/storage_service.dart';
import 'package:chessudoku/utils/helpers.dart';
import 'package:chessudoku/providers/authentication_provider.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late StorageService _storageService;
  final Map<String?, List<GameRecord>> _records = {
    null: [], // All
    'easy': [],
    'medium': [],
    'hard': [],
  };
  final Map<String?, bool> _isLoading = {null: false, 'easy': false, 'medium': false, 'hard': false};
  final Map<String?, bool> _hasMoreData = {null: true, 'easy': true, 'medium': true, 'hard': true};
  String? _userId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_scrollListener);
    _initializeStorage();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreRecords(_getCurrentDifficulty());
    }
  }

  String? _getCurrentDifficulty() {
    switch (_tabController.index) {
      case 0:
        return null;
      case 1:
        return 'easy';
      case 2:
        return 'medium';
      case 3:
        return 'hard';
      default:
        return null;
    }
  }

  Future<void> _initializeStorage() async {
    _storageService = await StorageService.initialize();
    _userId = context.read<AuthProvider>().user?.uid;
    if (_userId != null) {
      await _loadInitialRecords();
    }
  }

  Future<void> _loadInitialRecords() async {
    await Future.wait([
      _loadMoreRecords(null),
      _loadMoreRecords('easy'),
      _loadMoreRecords('medium'),
      _loadMoreRecords('hard'),
    ]);
  }

  Future<void> _loadMoreRecords(String? difficulty) async {
    if (_userId == null || _isLoading[difficulty] == true || _hasMoreData[difficulty] == false) {
      return;
    }

    setState(() => _isLoading[difficulty] = true);

    try {
      final currentRecords = _records[difficulty] ?? [];
      final lastRecord = currentRecords.isEmpty ? null : currentRecords.last;

      final newRecords = await _storageService.getGameRecords(
        userId: _userId!,
        difficulty: difficulty,
        lastRecord: lastRecord,
      );

      if (newRecords.isEmpty) {
        _hasMoreData[difficulty] = false;
      } else {
        setState(() {
          _records[difficulty] = [...currentRecords, ...newRecords];
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.translate('errorLoading')}: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading[difficulty] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_userId == null) {
      return Scaffold(body: Center(child: Text(l10n.translate('loginRequired'))));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('records')),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.translate('all')),
            Tab(text: l10n.translate('easy')),
            Tab(text: l10n.translate('medium')),
            Tab(text: l10n.translate('hard')),
          ],
          onTap: (index) {
            // 탭이 변경될 때마다 해당 난이도의 기록 로드
            String? difficulty;
            switch (index) {
              case 0:
                difficulty = null; // All
                break;
              case 1:
                difficulty = 'easy';
                break;
              case 2:
                difficulty = 'medium';
                break;
              case 3:
                difficulty = 'hard';
                break;
            }
            if (_records[difficulty]?.isEmpty ?? true) {
              _loadMoreRecords(difficulty);
            }
          },
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordList(null), // All
                _buildRecordList('easy'), // Easy
                _buildRecordList('medium'), // Medium
                _buildRecordList('hard'), // Hard
              ],
            ),
          ),
          // Add Banner Ad at the bottom
          // const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildRecordList(String? difficulty) {
    final l10n = AppLocalizations.of(context);
    final records = _records[difficulty] ?? [];

    if (records.isEmpty) {
      if (_isLoading[difficulty] == true) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [const CircularProgressIndicator(), const SizedBox(height: 16), Text(l10n.translate('loading'))],
          ),
        );
      }
      return Center(child: Text(l10n.translate('noRecords'), style: const TextStyle(fontSize: 16, color: Colors.grey)));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: records.length + 1,
      itemBuilder: (context, index) {
        if (index == records.length) {
          if (_isLoading[difficulty] == true) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(l10n.translate('loading')),
                  ],
                ),
              ),
            );
          } else if (_hasMoreData[difficulty] == false) {
            return Center(
              child: Padding(padding: const EdgeInsets.all(16.0), child: Text(l10n.translate('noMoreRecords'))),
            );
          }
          return const SizedBox.shrink();
        }

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
              '${l10n.translate('completed')}: ${_formatDate(record.completedAt)}\n'
              '${l10n.translate('hintsUsed')}: ${record.hintsUsed}',
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
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/'
        '${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
