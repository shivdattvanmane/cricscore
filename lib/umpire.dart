// ignore_for_file: non_constant_identifier_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itr_proj/cricd.dart';
import 'package:itr_proj/flag_helper.dart';
import 'package:itr_proj/join.dart';
import 'package:itr_proj/theme.dart';

class Umpire extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  final int maxOvers;
  final String? matchCode;

  const Umpire({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.maxOvers,
    this.matchCode,
  });

  @override
  State<Umpire> createState() => _UmpireState();
}

class _UmpireState extends State<Umpire> {
  int score = 0;
  int wic = 0;
  int overs = 0;
  int balls = 0;
  int currentInning = 1;
  int team1FinalScore = 0;
  int widesCount = 0;
  int noBallsCount = 0;
  List<String> recentBallsList = [];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final String activeMatchCode;

  @override
  void initState() {
    super.initState();
    activeMatchCode = widget.matchCode ?? Code;

    // Listen to real-time Firestore updates
    _firestore.collection('cricscore').doc(activeMatchCode).snapshots().listen((snapshot) {
      if (!mounted) return;
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        String inningField = currentInning == 1 ? 'team1' : 'team2';
        if (data[inningField] != null) {
          final tData = data[inningField] as Map<String, dynamic>;
          setState(() {
            score = tData['score'] ?? score;
            wic = tData['wickets'] ?? wic;
            overs = tData['overs'] ?? overs;
            balls = tData['balls'] ?? balls;
            if (tData['recentBalls'] != null) {
              recentBallsList = List<String>.from(tData['recentBalls']);
            }
          });
        }
        if (data['team1'] != null && currentInning == 2) {
          team1FinalScore = (data['team1'] as Map<String, dynamic>)['score'] ?? team1FinalScore;
        }
      }
    });
  }

  Future<void> updateFirestoreScore({String? ballLabel, String? matchStatus, String? resultText}) async {
    String inningField = currentInning == 1 ? 'team1' : 'team2';
    final battingTeam = currentInning == 1 ? widget.team1Name : widget.team2Name;

    if (ballLabel != null) {
      recentBallsList.add(ballLabel);
      if (recentBallsList.length > 18) {
        recentBallsList.removeAt(0);
      }
    }

    final Map<String, dynamic> updateData = {
      '$inningField.score': score,
      '$inningField.wickets': wic,
      '$inningField.overs': overs,
      '$inningField.balls': balls,
      '$inningField.recentBalls': recentBallsList,
      '$inningField.extras': {
        'wides': widesCount,
        'noBalls': noBallsCount,
      },
      'currentInning': currentInning,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (ballLabel != null) {
      final log = "Ov $overs.$balls: $ballLabel ($battingTeam: $score/$wic)";
      updateData['ballByBall'] = FieldValue.arrayUnion([log]);
    }

    if (matchStatus != null) {
      updateData['status'] = matchStatus;
    }
    if (resultText != null) {
      updateData['result'] = resultText;
    }
    if (currentInning == 1 && (overs >= widget.maxOvers || wic >= 10)) {
      updateData['target'] = score + 1;
    }

    await _firestore.collection('cricscore').doc(activeMatchCode).update(updateData);
  }

  void updateScore(int runs) {
    if (overs >= widget.maxOvers || wic >= 10) return;

    setState(() {
      score += runs;
      balls++;

      if (balls == 6) {
        balls = 0;
        overs++;
      }

      _checkInningsStatus();
      updateFirestoreScore(ballLabel: runs == 0 ? "•" : "$runs");
    });
  }

  void _checkInningsStatus() {
    if (currentInning == 1) {
      if (overs >= widget.maxOvers || wic >= 10) {
        team1FinalScore = score;
        updateFirestoreScore(matchStatus: 'innings_break');

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: CricketTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Innings Complete', style: TextStyle(fontWeight: FontWeight.w700, color: CricketTheme.primaryText)),
            content: Text(
              '${widget.team1Name} scored $score/$wic in $overs.$balls overs.\n\nTarget for ${widget.team2Name}: ${score + 1} runs.',
              style: const TextStyle(fontSize: 14.5, color: CricketTheme.secondaryText),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: CricketTheme.primaryGreen),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    currentInning = 2;
                    score = 0;
                    wic = 0;
                    overs = 0;
                    balls = 0;
                    widesCount = 0;
                    noBallsCount = 0;
                    recentBallsList = [];
                  });
                  updateFirestoreScore(matchStatus: 'ongoing');
                },
                child: const Text('Start 2nd Innings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } else if (currentInning == 2) {
      final target = team1FinalScore + 1;
      if (score >= target) {
        _finishMatch('${widget.team2Name} won by ${10 - wic} wickets!');
      } else if (overs >= widget.maxOvers || wic >= 10) {
        if (score == team1FinalScore) {
          _finishMatch('Match Tied!');
        } else {
          _finishMatch('${widget.team1Name} won by ${team1FinalScore - score} runs!');
        }
      }
    }
  }

  void _finishMatch(String result) {
    updateFirestoreScore(matchStatus: 'completed', resultText: result);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: CricketTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: CricketTheme.accentGold, size: 24),
            SizedBox(width: 8),
            Text('Match Finished', style: TextStyle(fontWeight: FontWeight.bold, color: CricketTheme.primaryText)),
          ],
        ),
        content: Text(
          result,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CricketTheme.primaryGreen),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CricketTheme.primaryGreen),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit Scoring', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void nb() {
    setState(() {
      score++;
      noBallsCount++;
      updateFirestoreScore(ballLabel: 'NB');
    });
  }

  void wide() {
    setState(() {
      score++;
      widesCount++;
      updateFirestoreScore(ballLabel: 'WD');
    });
  }

  void wick() {
    if (wic < 10) {
      setState(() {
        wic++;
        balls++;
        if (balls == 6) {
          balls = 0;
          overs++;
        }
        _checkInningsStatus();
        updateFirestoreScore(ballLabel: 'W');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All Out!')),
      );
    }
  }

  void unwicket() {
    if (wic > 0) {
      setState(() {
        wic--;
        if (recentBallsList.isNotEmpty && recentBallsList.last == 'W') {
          recentBallsList.removeLast();
        }
        updateFirestoreScore();
      });
    }
  }

  void unrun() {
    if (score > 0) {
      setState(() {
        score--;
        if (recentBallsList.isNotEmpty) {
          recentBallsList.removeLast();
        }
        updateFirestoreScore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final battingTeam = currentInning == 1 ? widget.team1Name : widget.team2Name;
    final bowlingTeam = currentInning == 1 ? widget.team2Name : widget.team1Name;

    return Scaffold(
      backgroundColor: CricketTheme.background,
      appBar: AppBar(
        title: Text(
          "$battingTeam vs $bowlingTeam",
          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye_outlined, color: CricketTheme.primaryGreen),
            tooltip: 'Live Spectator View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JoinScreen(matchCode: activeMatchCode),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Scorecard Card
              Container(
                decoration: BoxDecoration(
                  color: CricketTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CricketTheme.border, width: 1),
                  boxShadow: const [CricketTheme.cardShadow],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Innings $currentInning",
                            style: const TextStyle(fontWeight: FontWeight.w700, color: CricketTheme.primaryGreen, fontSize: 12),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F6F2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: CricketTheme.border),
                          ),
                          child: Text(
                            "Code: $activeMatchCode",
                            style: const TextStyle(fontWeight: FontWeight.w700, color: CricketTheme.primaryText, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(FlagHelper.getFlagEmoji(battingTeam), style: const TextStyle(fontSize: 26)),
                        const SizedBox(width: 8),
                        Text(
                          "$battingTeam Batting",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: CricketTheme.primaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Large readable score numbers
                    Text(
                      '$score / $wic',
                      style: const TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: CricketTheme.primaryGreen,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      'Overs: $overs.$balls / ${widget.maxOvers}',
                      style: const TextStyle(fontSize: 18, color: CricketTheme.secondaryText, fontWeight: FontWeight.w600),
                    ),
                    if (currentInning == 2) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Target: ${team1FinalScore + 1} | Need ${team1FinalScore + 1 - score} in ${(widget.maxOvers * 6) - (overs * 6 + balls)} balls',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CricketTheme.primaryGreen),
                        ),
                      ),
                    ],
                    if (recentBallsList.isNotEmpty) ...[
                      const Divider(height: 24, color: CricketTheme.border),
                      const Text(
                        "Recent Deliveries",
                        style: TextStyle(fontSize: 11.5, color: CricketTheme.secondaryText, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: recentBallsList.reversed.take(12).map((b) {
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
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                b,
                                style: TextStyle(fontWeight: FontWeight.w800, color: badgeColor, fontSize: 13),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Run Buttons Header
              const Text(
                "Score Runs",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: CricketTheme.primaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // 0, 1, 2, 3, 4, 6 Run Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _runButton(0, "0 •"),
                  _runButton(1, "1"),
                  _runButton(2, "2"),
                  _runButton(3, "3"),
                  _runButton(4, "4"),
                  _runButton(6, "6"),
                ],
              ),

              const SizedBox(height: 20),

              // Extras & Wickets Header
              const Text(
                "Extras & Wicket",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: CricketTheme.primaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: nb,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF3E0),
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFFFCC80)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: const Text("No Ball", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: wide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF3E0),
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFFFCC80)),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    child: const Text("Wide", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: wick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CricketTheme.liveRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("WICKET", style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Undo buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: unrun,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CricketTheme.secondaryText,
                      side: const BorderSide(color: CricketTheme.border),
                    ),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text("-1 Run"),
                  ),
                  const SizedBox(width: 14),
                  OutlinedButton.icon(
                    onPressed: unwicket,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CricketTheme.liveRed,
                      side: BorderSide(color: CricketTheme.liveRed.withValues(alpha: 0.5)),
                    ),
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text("-1 Wicket"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _runButton(int run, String label) {
    final bool isFour = run == 4;
    final bool isSix = run == 6;

    Color bg = CricketTheme.surface;
    Color fg = CricketTheme.primaryText;
    Color borderC = CricketTheme.border;

    if (isFour) {
      bg = const Color(0xFFE8F5E9);
      fg = CricketTheme.primaryGreen;
      borderC = CricketTheme.secondaryGreen;
    } else if (isSix) {
      bg = const Color(0xFFFFF8E1);
      fg = const Color(0xFFB78103);
      borderC = CricketTheme.accentGold;
    }

    return InkWell(
      onTap: () => updateScore(run),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: borderC, width: 1.2),
          boxShadow: const [CricketTheme.cardShadow],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: run == 0 ? 11 : 16,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
