class RatingStarsCount {
  final int full;
  final int half;
  final int empty;

  RatingStarsCount(this.full, this.half, this.empty);

  static int _roundAt6(double n) =>
      (n - n.floorToDouble()) > 0.5 ? n.ceil() : n.toInt();

  factory RatingStarsCount.fromRating(double rating, {int max = 5}) {
    final full = _roundAt6(rating);
    final half = rating.ceil() - full;
    final empty = max - full - half;
    return RatingStarsCount(full, half, empty);
  }
}
