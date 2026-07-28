class GameResultModel {
  final int stars;
  final int moves;
  final Duration time;

  const GameResultModel({
    required this.stars,
    required this.moves,
    required this.time,
  });

  int get seconds => time.inSeconds;

  bool get isPerfect => stars >= 3;

  String get rating {
    if (stars >= 3) return "ممتاز";
    if (stars == 2) return "جيد جداً";
    if (stars == 1) return "جيد";
    return "حاول مرة أخرى";
  }

  Map<String, dynamic> toJson() {
    return {
      "stars": stars,
      "moves": moves,
      "seconds": seconds,
    };
  }

  factory GameResultModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return GameResultModel(
      stars: json["stars"] ?? 0,
      moves: json["moves"] ?? 0,
      time: Duration(
        seconds: json["seconds"] ?? 0,
      ),
    );
  }

  GameResultModel copyWith({
    int? stars,
    int? moves,
    Duration? time,
  }) {
    return GameResultModel(
      stars: stars ?? this.stars,
      moves: moves ?? this.moves,
      time: time ?? this.time,
    );
  }

  bool isBetterThan(GameResultModel other) {
    if (stars != other.stars) {
      return stars > other.stars;
    }

    if (moves != other.moves) {
      return moves < other.moves;
    }

    return seconds < other.seconds;
  }

  @override
  String toString() {
    return "GameResultModel(stars: $stars, moves: $moves, seconds: $seconds)";
  }
}