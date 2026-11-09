// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itr_proj/cricd.dart';
import 'package:itr_proj/flag_helper.dart';
import 'package:itr_proj/join.dart';
import 'package:itr_proj/theme.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  final TextEditingController codes = TextEditingController();

  void _getValue([String? customCode]) {
    String matchCode = (customCode ?? codes.text).trim();
    if (matchCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid match code")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CricketMatchAp(matchCode: matchCode),
      ),
    );
  }

  void _showJoinDialog() {
    codes.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: CricketTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.sensors, color: CricketTheme.primaryGreen),
            SizedBox(width: 8),
            Text(
              "Join Match",
              style: TextStyle(fontWeight: FontWeight.w700, color: CricketTheme.primaryText, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter the 6-digit match code to spectate live scores in real time:",
              style: TextStyle(fontSize: 13, color: CricketTheme.secondaryText),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codes,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CricketTheme.primaryText),
              decoration: const InputDecoration(
                labelText: "6-Digit Match Code",
                hintText: "e.g. 748291",
                prefixIcon: Icon(Icons.pin, color: CricketTheme.primaryGreen),
              ),
              onSubmitted: (val) {
                Navigator.pop(context);
                _getValue(val);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CricketTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _getValue();
                },
                child: const Text("Join & Watch", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    codes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketTheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.scoreboard, color: CricketTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Local Match Center',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: CricketTheme.primaryText,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Clean Light Hero Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CricketTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CricketTheme.border, width: 1),
                    boxShadow: const [CricketTheme.cardShadow],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.sports_cricket,
                              size: 32,
                              color: CricketTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Local Match Hub",
                                style: TextStyle(
                                  color: CricketTheme.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                "Live ball-by-ball scoring & spectator streaming",
                                style: TextStyle(color: CricketTheme.secondaryText, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Action Buttons: Create & Join
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CricketTheme.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CricketMatchScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add_circle_outline, size: 20),
                                label: const Text(
                                  "Create Match",
                                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: CricketTheme.primaryGreen,
                                  side: const BorderSide(color: CricketTheme.primaryGreen, width: 1.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _showJoinDialog,
                                icon: const Icon(Icons.sensors, size: 20),
                                label: const Text(
                                  "Join Match",
                                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Active Firebase Matches Section Header
                const Row(
                  children: [
                    Icon(Icons.fiber_manual_record, color: CricketTheme.liveRed, size: 12),
                    SizedBox(width: 6),
                    Text(
                      "Active Firestore Matches",
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: CricketTheme.primaryText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Real-time Firestore Stream
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('cricscore')
                      .limit(15)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(28.0),
                          child: CircularProgressIndicator(
                            color: CricketTheme.primaryGreen,
                            strokeWidth: 2.5,
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: CricketTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: CricketTheme.border, width: 1),
                        ),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.sports_cricket_outlined, size: 36, color: CricketTheme.secondaryText),
                              SizedBox(height: 8),
                              Text(
                                "No active matches in Firebase yet",
                                style: TextStyle(fontWeight: FontWeight.w600, color: CricketTheme.primaryText),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "Tap 'Create Match' above to start scoring your game!",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: CricketTheme.secondaryText, fontSize: 12.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;
                    return Column(
                      children: docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final team1 = data['team1'] as Map<String, dynamic>?;
                        final team2 = data['team2'] as Map<String, dynamic>?;
                        final matchCode = data['matchCode'] ?? doc.id;
                        final status = data['status'] ?? 'ongoing';
                        final t1Name = team1?['name']?.toString() ?? 'Team 1';
                        final t2Name = team2?['name']?.toString() ?? 'Team 2';
                        final bool isCompleted = status == 'completed';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: CricketTheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isCompleted ? CricketTheme.border : CricketTheme.secondaryGreen.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            boxShadow: const [CricketTheme.cardShadow],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => _getValue(matchCode.toString()),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                children: [
                                  // Top bar: Match Code & Status
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
                                          "Code: $matchCode",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: CricketTheme.primaryGreen,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                        decoration: BoxDecoration(
                                          color: isCompleted ? const Color(0xFFF1F6F2) : const Color(0xFFFFEBEE),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: isCompleted ? CricketTheme.border : CricketTheme.liveRed.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isCompleted ? Icons.check_circle_outline : Icons.fiber_manual_record,
                                              size: 10,
                                              color: isCompleted ? CricketTheme.secondaryText : CricketTheme.liveRed,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              status.toString().toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w800,
                                                color: isCompleted ? CricketTheme.secondaryText : CricketTheme.liveRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 18, color: CricketTheme.border),
                                  // Teams row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Team 1
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(FlagHelper.getFlagEmoji(t1Name), style: const TextStyle(fontSize: 22)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    t1Name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14,
                                                      color: CricketTheme.primaryText,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    "${team1?['score'] ?? 0}/${team1?['wickets'] ?? 0} (${team1?['overs'] ?? 0}.${team1?['balls'] ?? 0} ov)",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: CricketTheme.primaryGreen,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          "VS",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: CricketTheme.secondaryText,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                      // Team 2
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    t2Name,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14,
                                                      color: CricketTheme.primaryText,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    team2?['score'] != null && team2?['score'] != 0
                                                        ? "${team2?['score']}/${team2?['wickets']} (${team2?['overs']}.${team2?['balls']} ov)"
                                                        : "Yet to bat",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color: team2?['score'] != null && team2?['score'] != 0
                                                          ? CricketTheme.primaryGreen
                                                          : CricketTheme.secondaryText,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(FlagHelper.getFlagEmoji(t2Name), style: const TextStyle(fontSize: 22)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
