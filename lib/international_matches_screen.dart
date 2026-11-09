import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itr_proj/app_config.dart';
import 'package:itr_proj/flag_helper.dart';
import 'package:itr_proj/theme.dart';

class InternationalMatchesScreen extends StatefulWidget {
  const InternationalMatchesScreen({super.key});

  @override
  State<InternationalMatchesScreen> createState() => _InternationalMatchesScreenState();
}

class _InternationalMatchesScreenState extends State<InternationalMatchesScreen> {
  List<dynamic> allMatches = [];
  String searchQuery = "";
  int selectedCategoryIndex = 0; // 0: All, 1: Live, 2: Upcoming, 3: Results
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> categories = ['All Matches', '🔴 Live', '⏳ Upcoming', '🏆 Results'];

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://api.cricapi.com/v1/currentMatches?apikey=${AppConfig.cricApiMatchKey}&offset=0'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'] as List<dynamic>? ?? [];
        if (mounted) {
          setState(() {
            allMatches = data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load matches (Status: ${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading matches: $e';
          _isLoading = false;
        });
      }
    }
  }

  bool _isMatchLive(dynamic match) {
    final bool matchStarted = match['matchStarted'] == true;
    final bool matchEnded = match['matchEnded'] == true;
    return matchStarted && !matchEnded;
  }

  bool _isMatchUpcoming(dynamic match) {
    final bool matchStarted = match['matchStarted'] == true;
    final bool matchEnded = match['matchEnded'] == true;
    final status = match['status']?.toString().toLowerCase() ?? '';
    return !matchStarted && !matchEnded || status.contains('yet to') || status.contains('starts');
  }

  bool _isMatchFinished(dynamic match) {
    return match['matchEnded'] == true;
  }

  List<dynamic> get filteredMatches {
    List<dynamic> list = allMatches;

    // Filter by Category
    if (selectedCategoryIndex == 1) {
      list = list.where(_isMatchLive).toList();
    } else if (selectedCategoryIndex == 2) {
      list = list.where(_isMatchUpcoming).toList();
    } else if (selectedCategoryIndex == 3) {
      list = list.where(_isMatchFinished).toList();
    }

    // Filter by Search Query
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((match) {
        final name = match['name']?.toString().toLowerCase() ?? '';
        final status = match['status']?.toString().toLowerCase() ?? '';
        final venue = match['venue']?.toString().toLowerCase() ?? '';
        return name.contains(q) || status.contains(q) || venue.contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final displayList = filteredMatches;

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
              child: const Icon(Icons.sports_cricket, color: CricketTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'CricScore Dashboard',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: CricketTheme.primaryText,
                fontSize: 18,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: CricketTheme.primaryGreen),
            tooltip: 'Refresh',
            onPressed: fetchMatches,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: CricketTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                // Clean search bar
                TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  style: const TextStyle(fontSize: 14, color: CricketTheme.primaryText),
                  decoration: InputDecoration(
                    hintText: 'Search teams, tournaments, or venues...',
                    prefixIcon: const Icon(Icons.search, color: CricketTheme.primaryGreen, size: 20),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18, color: CricketTheme.secondaryText),
                            onPressed: () => setState(() => searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: CricketTheme.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CricketTheme.border, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CricketTheme.border, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CricketTheme.primaryGreen, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Category selector chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(categories.length, (index) {
                      final bool isSelected = selectedCategoryIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => selectedCategoryIndex = index),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? CricketTheme.primaryGreen : CricketTheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? CricketTheme.primaryGreen : CricketTheme.border,
                                width: 1,
                              ),
                              boxShadow: isSelected ? [CricketTheme.cardShadow] : null,
                            ),
                            child: Text(
                              categories[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : CricketTheme.primaryText,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: CricketTheme.border),

          // Matches list or status view
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: CricketTheme.primaryGreen,
                      strokeWidth: 2.5,
                    ),
                  )
                : _errorMessage != null
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
                                child: const Icon(Icons.wifi_off, size: 36, color: CricketTheme.primaryGreen),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: CricketTheme.secondaryText, fontSize: 14),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: fetchMatches,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : displayList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.sports_cricket_outlined, size: 48, color: CricketTheme.secondaryText),
                                const SizedBox(height: 12),
                                Text(
                                  searchQuery.isNotEmpty
                                      ? 'No matches matching "$searchQuery"'
                                      : 'No matches in this category',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: CricketTheme.secondaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: fetchMatches,
                            color: CricketTheme.primaryGreen,
                            backgroundColor: CricketTheme.surface,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                return _buildMatchCard(displayList[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(dynamic match) {
    final bool isLive = _isMatchLive(match);
    final bool isEnded = _isMatchFinished(match);
    final String matchType = match['matchType']?.toString().toUpperCase() ?? 'CRICKET';
    final String statusText = match['status']?.toString() ?? 'In Progress';
    final String venue = match['venue']?.toString() ?? '';
    final String dateTimeGMT = match['dateTimeGMT']?.toString() ?? '';

    // Team info
    final List<dynamic> teamInfo = match['teamInfo'] as List<dynamic>? ?? [];
    final dynamic t1 = teamInfo.isNotEmpty ? teamInfo[0] : null;
    final dynamic t2 = teamInfo.length > 1 ? teamInfo[1] : null;

    final List<dynamic> rawTeams = match['teams'] as List<dynamic>? ?? [];
    final String team1Name = t1?['name'] ?? (rawTeams.isNotEmpty ? rawTeams[0].toString() : 'Team 1');
    final String team2Name = t2?['name'] ?? (rawTeams.length > 1 ? rawTeams[1].toString() : 'Team 2');
    final String team1Short = t1?['shortname'] ?? (team1Name.length > 4 ? team1Name.substring(0, 4) : team1Name);
    final String team2Short = t2?['shortname'] ?? (team2Name.length > 4 ? team2Name.substring(0, 4) : team2Name);
    final String? team1Img = t1?['img']?.toString();
    final String? team2Img = t2?['img']?.toString();

    // Inning scores
    final List<dynamic> scores = match['score'] as List<dynamic>? ?? [];

    String? t1ScoreString;
    String? t2ScoreString;

    for (var s in scores) {
      final inningName = s['inning']?.toString().toLowerCase() ?? '';
      final runs = s['r'] ?? 0;
      final wickets = s['w'] ?? 0;
      final overs = s['o'] ?? 0;

      if (inningName.contains(team1Name.toLowerCase()) || inningName.contains(team1Short.toLowerCase())) {
        t1ScoreString = "$runs/$wickets ($overs ov)";
      } else if (inningName.contains(team2Name.toLowerCase()) || inningName.contains(team2Short.toLowerCase())) {
        t2ScoreString = "$runs/$wickets ($overs ov)";
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: CricketTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLive ? CricketTheme.secondaryGreen.withValues(alpha: 0.5) : CricketTheme.border,
          width: isLive ? 1.4 : 1.0,
        ),
        boxShadow: const [CricketTheme.cardShadow],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Format Badge & Match Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Format Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    matchType,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CricketTheme.primaryGreen,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // Status Badge
                _buildStatusBadge(isLive: isLive, isEnded: isEnded),
              ],
            ),

            const SizedBox(height: 14),

            // Teams Row with Visible Flags & Scores
            Row(
              children: [
                // Team 1
                Expanded(
                  child: Column(
                    children: [
                      FlagHelper.buildTeamFlag(team1Img, team1Name, size: 44),
                      const SizedBox(height: 8),
                      Text(
                        team1Short,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: CricketTheme.primaryText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        team1Name,
                        style: const TextStyle(fontSize: 11, color: CricketTheme.secondaryText),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t1ScoreString ?? (scores.isNotEmpty && scores.length == 1 ? "${scores[0]['r']}/${scores[0]['w']} (${scores[0]['o']} ov)" : "-"),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: CricketTheme.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // VS separator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F6F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: CricketTheme.border),
                    ),
                    child: const Text(
                      "VS",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: CricketTheme.secondaryText,
                      ),
                    ),
                  ),
                ),

                // Team 2
                Expanded(
                  child: Column(
                    children: [
                      FlagHelper.buildTeamFlag(team2Img, team2Name, size: 44),
                      const SizedBox(height: 8),
                      Text(
                        team2Short,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: CricketTheme.primaryText,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        team2Name,
                        style: const TextStyle(fontSize: 11, color: CricketTheme.secondaryText),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t2ScoreString ?? (scores.length > 1 ? "${scores[1]['r']}/${scores[1]['w']} (${scores[1]['o']} ov)" : "-"),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: CricketTheme.primaryGreen,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 16, color: CricketTheme.border),

            // Match Status / Result Note
            Row(
              children: [
                Icon(
                  isLive
                      ? Icons.radio_button_checked
                      : isEnded
                          ? Icons.check_circle_outline
                          : Icons.schedule,
                  size: 15,
                  color: isLive ? CricketTheme.liveRed : CricketTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: isLive ? CricketTheme.liveRed : CricketTheme.primaryText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Venue / Date if available
            if (venue.isNotEmpty || dateTimeGMT.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: CricketTheme.secondaryText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      venue.isNotEmpty ? venue : dateTimeGMT,
                      style: const TextStyle(fontSize: 11.5, color: CricketTheme.secondaryText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge({required bool isLive, required bool isEnded}) {
    if (isLive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CricketTheme.liveRed.withValues(alpha: 0.4), width: 1),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fiber_manual_record, size: 10, color: CricketTheme.liveRed),
            SizedBox(width: 4),
            Text(
              'LIVE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: CricketTheme.liveRed,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      );
    } else if (isEnded) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F6F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CricketTheme.border, width: 1),
        ),
        child: const Text(
          'RESULT',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: CricketTheme.secondaryText,
            letterSpacing: 0.4,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CricketTheme.accentGold.withValues(alpha: 0.5), width: 1),
        ),
        child: const Text(
          'UPCOMING',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFFB78103),
            letterSpacing: 0.4,
          ),
        ),
      );
    }
  }
}
