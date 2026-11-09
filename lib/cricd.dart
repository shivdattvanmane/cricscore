import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:itr_proj/flag_helper.dart';
import 'package:itr_proj/matchcode.dart';
import 'package:itr_proj/theme.dart';
import 'package:itr_proj/umpire.dart';

// ignore: non_constant_identifier_names
String Code = generateMatchCode();

class CricketMatchApp extends StatelessWidget {
  const CricketMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cricket Match',
      debugShowCheckedModeBanner: false,
      theme: CricketTheme.themeData,
      home: const CricketMatchScreen(),
    );
  }
}

class CricketMatchScreen extends StatefulWidget {
  const CricketMatchScreen({super.key});

  @override
  State<CricketMatchScreen> createState() => _CricketMatchScreenState();
}

class _CricketMatchScreenState extends State<CricketMatchScreen> {
  final TextEditingController _team1Controller = TextEditingController();
  final TextEditingController _team2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Code = generateMatchCode();
  }

  @override
  void dispose() {
    _team1Controller.dispose();
    _team2Controller.dispose();
    super.dispose();
  }

  void _setUpTeams() {
    final team1Name = _team1Controller.text.trim();
    final team2Name = _team2Controller.text.trim();

    if (team1Name.isNotEmpty && team2Name.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamsSetupScreen(
            team1Name: team1Name,
            team2Name: team2Name,
            matchCode: Code,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter names for both teams')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CricketTheme.background,
      appBar: AppBar(
        title: const Text('Match Setup'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: CricketTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CricketTheme.border, width: 1),
              boxShadow: const [CricketTheme.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Match Code Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      border: Border.all(
                        color: CricketTheme.secondaryGreen.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pin, color: CricketTheme.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Match Code: $Code',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: CricketTheme.primaryGreen,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Team 1
                const Text(
                  'Team 1 Name',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: CricketTheme.primaryText),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _team1Controller,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: CricketTheme.primaryText),
                  decoration: const InputDecoration(
                    hintText: 'e.g. India, Mumbai Indians',
                    prefixIcon: Icon(Icons.shield_outlined, color: CricketTheme.primaryGreen, size: 20),
                  ),
                ),
                const SizedBox(height: 20),

                // Team 2
                const Text(
                  'Team 2 Name',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: CricketTheme.primaryText),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _team2Controller,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: CricketTheme.primaryText),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Australia, Chennai Super Kings',
                    prefixIcon: Icon(Icons.shield_outlined, color: CricketTheme.primaryGreen, size: 20),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _setUpTeams,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CricketTheme.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Proceed to Squad & Overs', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TeamsSetupScreen extends StatefulWidget {
  final String team1Name;
  final String team2Name;
  final String matchCode;

  const TeamsSetupScreen({
    super.key,
    required this.team1Name,
    required this.team2Name,
    required this.matchCode,
  });

  @override
  State<TeamsSetupScreen> createState() => _TeamsSetupScreenState();
}

class _TeamsSetupScreenState extends State<TeamsSetupScreen> {
  final TextEditingController _playerController = TextEditingController();
  late String _currentTeam;
  late List<Team> _teams;
  int? _selectedOvers = 20;

  @override
  void initState() {
    super.initState();
    _teams = [
      Team(name: widget.team1Name, players: []),
      Team(name: widget.team2Name, players: []),
    ];
    _currentTeam = widget.team1Name;
  }

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  void _switchTeam() {
    setState(() {
      _currentTeam = _currentTeam == widget.team1Name
          ? widget.team2Name
          : widget.team1Name;
    });
  }

  void _addPlayer() {
    final playerName = _playerController.text.trim();
    if (playerName.isNotEmpty) {
      final team = _teams.firstWhere((team) => team.name == _currentTeam);
      if (team.players.length < 11) {
        setState(() {
          team.players.add(playerName);
        });
        _playerController.clear();
      } else {
        _showMaxPlayersDialog();
      }
    }
  }

  void _showMaxPlayersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: CricketTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: const Text('Maximum Players', style: TextStyle(fontWeight: FontWeight.bold, color: CricketTheme.primaryText)),
          content: const Text('A cricket team can have up to 11 players.', style: TextStyle(color: CricketTheme.secondaryText)),
          actions: <Widget>[
            TextButton(
              child: const Text('OK', style: TextStyle(color: CricketTheme.primaryGreen, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void createMatch() {
    if (_selectedOvers == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select overs')),
      );
      return;
    }

    final t1Players = _teams.firstWhere((team) => team.name == widget.team1Name).players;
    final t2Players = _teams.firstWhere((team) => team.name == widget.team2Name).players;

    // Comprehensive & robust Firebase database document
    FirebaseFirestore.instance.collection('cricscore').doc(widget.matchCode).set({
      'matchCode': widget.matchCode,
      'title': '${widget.team1Name} vs ${widget.team2Name}',
      'maxOvers': _selectedOvers,
      'currentInning': 1,
      'status': 'ongoing',
      'target': 0,
      'result': '',
      'team1': {
        'name': widget.team1Name,
        'flag': FlagHelper.getFlagEmoji(widget.team1Name),
        'players': t1Players,
        'score': 0,
        'wickets': 0,
        'overs': 0,
        'balls': 0,
        'extras': {'wides': 0, 'noBalls': 0},
        'recentBalls': <String>[],
      },
      'team2': {
        'name': widget.team2Name,
        'flag': FlagHelper.getFlagEmoji(widget.team2Name),
        'players': t2Players,
        'score': 0,
        'wickets': 0,
        'overs': 0,
        'balls': 0,
        'extras': {'wides': 0, 'noBalls': 0},
        'recentBalls': <String>[],
      },
      'ballByBall': <String>['Match started: ${widget.team1Name} batting first.'],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).then((_) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Umpire(
            team1Name: widget.team1Name,
            team2Name: widget.team2Name,
            maxOvers: _selectedOvers!,
            matchCode: widget.matchCode,
          ),
        ),
      );
    }).catchError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create match: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTeam = _teams.firstWhere((team) => team.name == _currentTeam);

    return Scaffold(
      backgroundColor: CricketTheme.background,
      appBar: AppBar(
        title: const Text('Players & Overs'),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              // Current Team Header Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        Text(FlagHelper.getFlagEmoji(_currentTeam), style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 10),
                        Text(
                          _currentTeam,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: CricketTheme.primaryText,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _switchTeam,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        side: const BorderSide(color: CricketTheme.primaryGreen, width: 1),
                      ),
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Switch Team', style: TextStyle(fontSize: 12.5)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Player Input Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CricketTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CricketTheme.border, width: 1),
                  boxShadow: const [CricketTheme.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Squad for $_currentTeam (${currentTeam.players.length}/11)',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: CricketTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _playerController,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Enter Player Name',
                              prefixIcon: Icon(Icons.person_outline, color: CricketTheme.primaryGreen, size: 20),
                            ),
                            onSubmitted: (_) => _addPlayer(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addPlayer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CricketTheme.primaryGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          ),
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (currentTeam.players.isEmpty)
                      const Text(
                        'No players added yet (optional).',
                        style: TextStyle(color: CricketTheme.secondaryText, fontSize: 13),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: currentTeam.players
                            .map((p) => Chip(
                                  backgroundColor: const Color(0xFFE8F5E9),
                                  side: BorderSide.none,
                                  label: Text(
                                    p,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: CricketTheme.primaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                  deleteIconColor: CricketTheme.secondaryText,
                                  onDeleted: () {
                                    setState(() {
                                      currentTeam.players.remove(p);
                                    });
                                  },
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Overs Selector Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CricketTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: CricketTheme.border, width: 1),
                  boxShadow: const [CricketTheme.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Match Format / Overs',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: CricketTheme.primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [2, 5, 10, 20, 50].map((int overs) {
                        final bool isSelected = _selectedOvers == overs;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3.0),
                            child: InkWell(
                              onTap: () => setState(() => _selectedOvers = overs),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? CricketTheme.primaryGreen : const Color(0xFFF1F6F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isSelected ? CricketTheme.primaryGreen : CricketTheme.border,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "$overs",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: isSelected ? Colors.white : CricketTheme.primaryText,
                                      ),
                                    ),
                                    Text(
                                      "ov",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isSelected ? Colors.white70 : CricketTheme.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Start Match Button
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: createMatch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CricketTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.sports_cricket, size: 20),
                  label: const Text('Start & Score Match', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Team {
  final String name;
  final List<String> players;

  Team({
    required this.name,
    required this.players,
  });
}
