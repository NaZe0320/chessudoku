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
}
