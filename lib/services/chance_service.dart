import 'package:chessudoku/models/chance.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 사용자의 기회 정보 가져오기
  Future<Chance> getChance(String userId) async {
    print("TEST : $userId");
    final doc = await _firestore.collection('users').doc(userId).collection('game_data').doc('chance').get();

    if (!doc.exists) {
      // 첫 접속시 초기화
      final initialChance = Chance.initial();
      await _setChance(userId, initialChance);
      return initialChance;
    }

    return Chance.fromMap(doc.data()!);
  }

  // 기회 정보 업데이트
  Future<void> _setChance(String userId, Chance chance) async {
    await _firestore.collection('users').doc(userId).collection('game_data').doc('chance').set(chance.toMap());
  }

  // 기회 사용
  Future<bool> useChance(String userId) async {
    final chanceDoc = _firestore.collection('users').doc(userId).collection('game_data').doc('chance');

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(chanceDoc);
      if (!snapshot.exists) return false;

      final chance = Chance.fromMap(snapshot.data()!);
      if (chance.currentChances <= 0) return false;

      final updatedChance = chance.copyWith(currentChances: chance.currentChances - 1, lastUpdateTime: DateTime.now());

      transaction.set(chanceDoc, updatedChance.toMap());
      return true;
    });
  }

  // 기회 추가 (광고 시청 등의 보상)
  Future<bool> addChance(String userId) async {
    final chanceDoc = _firestore.collection('users').doc(userId).collection('game_data').doc('chance');

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(chanceDoc);
      if (!snapshot.exists) return false;

      final chance = Chance.fromMap(snapshot.data()!);
      if (chance.currentChances >= Chance.maxChances) return false;

      final updatedChance = chance.copyWith(currentChances: chance.currentChances + 1, lastUpdateTime: DateTime.now());

      transaction.set(chanceDoc, updatedChance.toMap());
      return true;
    });
  }

  // 기회 자동 충전 체크 및 실행
  Future<Chance?> checkAndRechargeChances(String userId) async {
    final chanceDoc = _firestore.collection('users').doc(userId).collection('game_data').doc('chance');

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(chanceDoc);
      if (!snapshot.exists) return null;

      final chance = Chance.fromMap(snapshot.data()!);
      final now = DateTime.now();
      final difference = now.difference(chance.lastUpdateTime);

      if (difference >= Chance.rechargeInterval && chance.currentChances < Chance.maxChances) {
        final updatedChance = chance.copyWith(currentChances: chance.currentChances + 1, lastUpdateTime: now);
        transaction.set(chanceDoc, updatedChance.toMap());
        return updatedChance;
      }

      return chance;
    });
  }

  // 실시간 기회 정보 스트림
  Stream<Chance> chanceStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('game_data')
        .doc('chance')
        .snapshots()
        .map((snapshot) => snapshot.exists ? Chance.fromMap(snapshot.data()!) : Chance.initial());
  }
}
