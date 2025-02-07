class Chance {
  static const int maxChances = 5;
  static const Duration rechargeInterval = Duration(hours: 2);

  final int currentChances;
  final DateTime lastUpdateTime;

  Chance({required this.currentChances, required this.lastUpdateTime});

  Duration? get timeUntilNextRecharge {
    final nextRecharge = lastUpdateTime.add(rechargeInterval);
    final now = DateTime.now();

    if (now.isAfter(nextRecharge)) return null;
    return nextRecharge.difference(now);
  }

  Map<String, dynamic> toMap() {
    return {'currentChances': currentChances, 'lastUpdateTime': lastUpdateTime.toIso8601String()};
  }

  factory Chance.fromMap(Map<String, dynamic> map) {
    return Chance(
      currentChances: map['currentChances'] as int,
      lastUpdateTime: DateTime.parse(map['lastUpdateTime'] as String),
    );
  }

  factory Chance.initial() {
    return Chance(currentChances: maxChances, lastUpdateTime: DateTime.now());
  }

  Chance copyWith({int? currentChances, DateTime? lastUpdateTime}) {
    return Chance(
      currentChances: currentChances ?? this.currentChances,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
    );
  }
}
