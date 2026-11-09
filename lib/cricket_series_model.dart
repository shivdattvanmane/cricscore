class CricketSeries {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final int odi;
  final int t20;
  final int test;
  final int squads;
  final int matches;

  CricketSeries({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.odi,
    required this.t20,
    required this.test,
    required this.squads,
    required this.matches,
  });

  factory CricketSeries.fromJson(Map<String, dynamic> json) {
    return CricketSeries(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Series',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      odi: (json['odi'] is int) ? json['odi'] : int.tryParse(json['odi']?.toString() ?? '0') ?? 0,
      t20: (json['t20'] is int) ? json['t20'] : int.tryParse(json['t20']?.toString() ?? '0') ?? 0,
      test: (json['test'] is int) ? json['test'] : int.tryParse(json['test']?.toString() ?? '0') ?? 0,
      squads: (json['squads'] is int) ? json['squads'] : int.tryParse(json['squads']?.toString() ?? '0') ?? 0,
      matches: (json['matches'] is int) ? json['matches'] : int.tryParse(json['matches']?.toString() ?? '0') ?? 0,
    );
  }
}

