import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itr_proj/flag_helper.dart';
import 'package:itr_proj/theme.dart';

class CricketMatchAp extends StatelessWidget {
  final String matchCode;

  const CricketMatchAp({super.key, required this.matchCode});

  @override
  Widget build(BuildContext context) {
    return JoinScreen(matchCode: matchCode);
  }
}

class JoinScreen extends StatefulWidget {
  final String matchCode;

  const JoinScreen({super.key, required this.matchCode});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? documentData;
  bool _isLoading = true;
  bool _matchFound = true;

  @override
  void initState() {
    super.initState();
    _listenToLiveUpdates();
  }

  void _listenToLiveUpdates() {
    _firestore.collection('cricscore').doc(widget.matchCode).snapshots().listen(
      (snapshot) {
        if (!mounted) return;
        if (snapshot.exists && snapshot.data() != null) {
          setState(() {
            documentData = snapshot.data();
            _isLoading = false;
            _matchFound = true;
          });
        } else {
          setState(() {
            _isLoading = false;
            _matchFound = false;
          });
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _matchFound = false;
        });
      },
    );
  }

  int _getInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  double _calcRunRate(int runs, int overs, int balls) {
    final totalOvers = overs + (balls / 6.0);
    if (totalOvers <= 0) return 0.0;
    return runs / totalOvers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketTheme.background,
      appBar: AppBar(
        title: const Text(
          'Live Match Spectator',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: CricketTheme.primaryGreen,
                strokeWidth: 2.5,
              ),
            )
          : !_matchFound || documentData == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE8F5E9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sports_cricket, size: 40, color: CricketTheme.primaryGreen),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No match found with code: ${widget.matchCode}',
                          style: const TextStyle(fontSize: 16, color: CricketTheme.primaryText, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(backgroundColor: CricketTheme.primaryGreen),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Match Code & Live Badge Bar
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: CricketTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: CricketTheme.border, width: 1),
                              boxShadow: const [CricketTheme.cardShadow],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEBEE),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: CricketTheme.liveRed.withValues(alpha: 0.3)),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.fiber_manual_record, color: CricketTheme.liveRed, size: 9),
                                          SizedBox(width: 4),
                                          Text(
                                            "LIVE",
                                            style: TextStyle(
                                              color: CricketTheme.liveRed,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      documentData?['status']?.toString().toUpperCase() ?? 'ONGOING',
                                      style: const TextStyle(
                                        color: CricketTheme.secondaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Code: ${widget.matchCode}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: CricketTheme.primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Scorecard Card with FLAGS
                          _buildScorecard(),

                          const SizedBox(height: 14),

                          // Ball-by-ball commentary
                          _buildCommentary(),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildScorecard() {
    final team1 = documentData?['team1'] as Map<String, dynamic>?;
    final team2 = documentData?['team2'] as Map<String, dynamic>?;

    final t1Name = team1?['name']?.toString() ?? 'Team 1';
    final t2Name = team2?['name']?.toString() ?? 'Team 2';

    final t1Score = _getInt(team1?['score']);
    final t1Wic = _getInt(team1?['wickets']);
    final t1Overs = _getInt(team1?['overs']);
    final t1Balls = _getInt(team1?['balls']);

    final t2Score = _getInt(team2?['score']);
    final t2Wic = _getInt(team2?['wickets']);
    final t2Overs = _getInt(team2?['overs']);
    final t2Balls = _getInt(team2?['balls']);

    final currentInning = _getInt(documentData?['currentInning']) == 0 ? 1 : _getInt(documentData?['currentInning']);
    final maxOvers = _getInt(documentData?['maxOvers']) == 0 ? 20 : _getInt(documentData?['maxOvers']);
    final target = _getInt(documentData?['target']);
    final result = documentData?['result']?.toString() ?? '';

    final t1Cr = _calcRunRate(t1Score, t1Overs, t1Balls);
    final t2Cr = _calcRunRate(t2Score, t2Overs, t2Balls);

    // Recent deliveries
    final activeTeam = currentInning == 1 ? team1 : team2;
    final recentBalls = (activeTeam?['recentBalls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return Container(
      decoration: BoxDecoration(
        color: CricketTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CricketTheme.border, width: 1),
        boxShadow: const [CricketTheme.cardShadow],
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Team 1 with Flag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(FlagHelper.getFlagEmoji(t1Name), style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 6),
                    Text(
                      t1Name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: CricketTheme.primaryText),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "$t1Score / $t1Wic",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: CricketTheme.primaryGreen),
                    ),
                    Text(
                      "($t1Overs.$t1Balls / $maxOvers ov)",
                      style: const TextStyle(fontSize: 12.5, color: CricketTheme.secondaryText),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "CRR: ${t1Cr.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 11, color: CricketTheme.secondaryText, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Container(
                height: 100,
                width: 1,
                color: CricketTheme.border,
              ),

              // Team 2 with Flag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(FlagHelper.getFlagEmoji(t2Name), style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 6),
                    Text(
                      t2Name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: CricketTheme.primaryText),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentInning == 1 && t2Score == 0 && t2Wic == 0
                          ? "Yet to bat"
                          : "$t2Score / $t2Wic",
                      style: TextStyle(
                        fontSize: currentInning == 1 && t2Score == 0 ? 16 : 24,
                        fontWeight: FontWeight.w900,
                        color: currentInning == 1 && t2Score == 0 ? CricketTheme.secondaryText : CricketTheme.primaryGreen,
                      ),
                    ),
                    Text(
                      currentInning == 1 && t2Score == 0 && t2Wic == 0
                          ? ""
                          : "($t2Overs.$t2Balls / $maxOvers ov)",
                      style: const TextStyle(fontSize: 12.5, color: CricketTheme.secondaryText),
                    ),
                    if (currentInning == 2)
                      Text(
                        "CRR: ${t2Cr.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 11, color: CricketTheme.secondaryText, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (target > 0 || result.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                result.isNotEmpty
                    ? result
                    : "Target: $target | $t2Name need ${target - t2Score} runs to win",
                style: const TextStyle(fontWeight: FontWeight.w700, color: CricketTheme.primaryGreen, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          if (recentBalls.isNotEmpty) ...[
            const Divider(height: 22, color: CricketTheme.border),
            Row(
              children: [
                const Text("Recent: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: CricketTheme.secondaryText)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: recentBalls.reversed.take(12).map((b) {
                        Color badgeColor = CricketTheme.primaryText;
                        Color bgColor = const Color(0xFFF1F6F2);

                        if (b == 'W') {
                          badgeColor = CricketTheme.liveRed;
                          bgColor = const Color(0xFFFFEBEE);
                        } else if (b == '4') {
                          badgeColor = CricketTheme.primaryGreen;
                          bgColor = const Color(0xFFE8F5E9);
                        } else if (b == '6') {
                          badgeColor = const Color(0xFFB78103);
                          bgColor = const Color(0xFFFFF8E1);
                        } else if (b == 'NB' || b == 'WD') {
                          badgeColor = const Color(0xFFE65100);
                          bgColor = const Color(0xFFFFF3E0);
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 0.8),
                          ),
                          child: Text(
                            b,
                            style: TextStyle(fontWeight: FontWeight.bold, color: badgeColor, fontSize: 11),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentary() {
    final List<dynamic> logs = documentData?['ballByBall'] as List<dynamic>? ?? [];
    if (logs.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: CricketTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CricketTheme.border, width: 1),
        boxShadow: const [CricketTheme.cardShadow],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.comment_outlined, size: 18, color: CricketTheme.primaryGreen),
              SizedBox(width: 8),
              Text(
                "Live Commentary Feed",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: CricketTheme.primaryText),
              ),
            ],
          ),
          const Divider(height: 18, color: CricketTheme.border),
          ...logs.reversed.take(10).map((log) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sports_cricket, size: 14, color: CricketTheme.secondaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.toString(),
                        style: const TextStyle(fontSize: 13, color: CricketTheme.primaryText),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
