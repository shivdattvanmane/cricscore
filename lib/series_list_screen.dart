import 'package:flutter/material.dart';
import 'package:itr_proj/cricket_series_model.dart';
import 'package:itr_proj/fetch_series.dart';
import 'package:itr_proj/flag_helper.dart';
import 'package:itr_proj/theme.dart';

class SeriesListScreen extends StatefulWidget {
  const SeriesListScreen({super.key});

  @override
  State<SeriesListScreen> createState() => _SeriesListScreenState();
}

class _SeriesListScreenState extends State<SeriesListScreen> {
  List<CricketSeries> allSeries = [];
  List<CricketSeries> filteredSeries = [];
  String searchQuery = "";
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    loadSeries();
  }

  Future<void> loadSeries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final series = await fetchSeries();
      if (mounted) {
        setState(() {
          allSeries = series;
          filteredSeries = series;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load series: $e';
          _isLoading = false;
        });
      }
    }
  }

  void searchSeries(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredSeries = allSeries;
      } else {
        filteredSeries = allSeries.where((s) {
          return s.name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
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
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.emoji_events, color: CricketTheme.accentGold, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Cricket Series & Tours',
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
            onPressed: loadSeries,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: CricketTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              onChanged: searchSeries,
              style: const TextStyle(fontSize: 14, color: CricketTheme.primaryText),
              decoration: InputDecoration(
                hintText: 'Search series (e.g. World Cup, IPL, Ashes)...',
                prefixIcon: const Icon(Icons.search, color: CricketTheme.primaryGreen, size: 20),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: CricketTheme.secondaryText),
                        onPressed: () => searchSeries(''),
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
          ),

          const Divider(height: 1, thickness: 1, color: CricketTheme.border),

          // Series List
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
                                child: const Icon(Icons.error_outline, size: 36, color: CricketTheme.primaryGreen),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: CricketTheme.secondaryText, fontSize: 14),
                              ),
                              const SizedBox(height: 18),
                              ElevatedButton.icon(
                                onPressed: loadSeries,
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredSeries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.emoji_events_outlined, size: 48, color: CricketTheme.secondaryText),
                                const SizedBox(height: 12),
                                Text(
                                  searchQuery.isNotEmpty
                                      ? 'No series matching "$searchQuery"'
                                      : 'No cricket series available',
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
                            onRefresh: loadSeries,
                            color: CricketTheme.primaryGreen,
                            backgroundColor: CricketTheme.surface,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              itemCount: filteredSeries.length,
                              itemBuilder: (context, index) {
                                final s = filteredSeries[index];
                                final flags = FlagHelper.extractSeriesFlags(s.name);

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: CricketTheme.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: CricketTheme.border, width: 1),
                                    boxShadow: const [CricketTheme.cardShadow],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            // Country / Tournament Flag Badge
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF1F6F2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: CricketTheme.border),
                                              ),
                                              child: Text(
                                                flags.join(' '),
                                                style: const TextStyle(fontSize: 22),
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    s.name,
                                                    style: const TextStyle(
                                                      fontSize: 15.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: CricketTheme.primaryText,
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.calendar_today_outlined, size: 13, color: CricketTheme.secondaryText),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "${s.startDate}  →  ${s.endDate}",
                                                        style: const TextStyle(fontSize: 12, color: CricketTheme.secondaryText),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        const Divider(height: 16, color: CricketTheme.border),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Total Matches Pill
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE8F5E9),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.sports_cricket, size: 13, color: CricketTheme.primaryGreen),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    "${s.matches} Matches",
                                                    style: const TextStyle(
                                                      color: CricketTheme.primaryGreen,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 11.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Format badges
                                            Wrap(
                                              spacing: 6,
                                              children: [
                                                if (s.t20 > 0)
                                                  _formatBadge("T20 (${s.t20})", const Color(0xFF2E7D32), const Color(0xFFE8F5E9)),
                                                if (s.odi > 0)
                                                  _formatBadge("ODI (${s.odi})", const Color(0xFF1B5E20), const Color(0xFFF1F8E9)),
                                                if (s.test > 0)
                                                  _formatBadge("Test (${s.test})", const Color(0xFF827717), const Color(0xFFF9FBE7)),
                                                if (s.squads > 0)
                                                  _formatBadge("Squads (${s.squads})", CricketTheme.primaryText, const Color(0xFFF1F6F2)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _formatBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}
