import 'package:chessudoku/utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  final FirebaseFirestore _firestore;

  ApiService({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  // 난이도에 따른 퍼즐 가져오기
  Future<Map<String, dynamic>> fetchPuzzle(String difficulty) async {
    try {
      // 해당 난이도의 퍼즐 중 랜덤으로 선택
      final puzzleQuery = await _firestore.collection('puzzles').doc(difficulty).collection('puzzle_documents').get();

      if (puzzleQuery.docs.isEmpty) {
        throw Exception('No puzzles found for difficulty: $difficulty');
      }

      // 랜덤으로 퍼즐 선택
      final randomPuzzle = puzzleQuery.docs[getRandomInt(0, puzzleQuery.docs.length)];
      final puzzleData = randomPuzzle.data();
      puzzleData['puzzleId'] = randomPuzzle.id;

      return puzzleData;
    } catch (e) {
      throw Exception('Failed to fetch puzzle: $e');
    }
  }

  // // 게임 완료 데이터 저장
  // Future<void> submitCompletion(String difficulty, Map<String, dynamic> completionData) async {
  //   try {
  //     await _firestore.collection('collections').doc(difficulty).collection('records').add({
  //       ...completionData,
  //       'timestamp': FieldValue.serverTimestamp(),
  //     });
  //
  //     // 통계 업데이트
  //     await _firestore.runTransaction((transaction) async {
  //       final statsRef = _firestore.collection('completions').doc(difficulty).collection('statistics').doc('overall');
  //
  //       final stats = await transaction.get(statsRef);
  //       if (stats.exists) {
  //         final currentStats = stats.data()!;
  //         transaction.update(statsRef, {
  //           'total_completions': currentStats['total_completions'] + 1,
  //           'average_time': _updateAverage(
  //             currentStats['average_time'],
  //             completionData['completion_time'],
  //             currentStats['total_completions'],
  //           ),
  //         });
  //       } else {
  //         transaction.set(statsRef, {
  //           'total_completions': 1,
  //           'average_time': completionData['completion_time'],
  //           'average_mistakes': completionData['mistakes'],
  //         });
  //       }
  //     });
  //   } catch (e) {
  //     print('Failed to submit completion data: $e');
  //   }
  // }
  //
  // double _updateAverage(double currentAvg, double newValue, int currentCount) {
  //   return (currentAvg * currentCount + newValue) / (currentCount + 1);
  // }

  // // 오프라인 플레이를 위한 퍼즐 캐시 가져오기
  // Future<List<Map<String, dynamic>>> fetchPuzzleCache(String difficulty, int count) async {
  //   try {
  //     final puzzleQuery = await _firestore
  //         .collection('puzzles')
  //         .doc(difficulty)
  //         .collection('puzzle_documents')
  //         .limit(count)
  //         .get();
  //
  //     return puzzleQuery.docs
  //         .map((doc) => {...doc.data(), 'puzzleId': doc.id})
  //         .toList();
  //   } catch (e) {
  //     throw Exception('Failed to fetch puzzle cache: $e');
  //   }
  // }
}
