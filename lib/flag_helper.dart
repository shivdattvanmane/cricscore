import 'package:flutter/material.dart';

class FlagHelper {
  static const Map<String, String> _countryFlags = {
    'india': '🇮🇳',
    'ind': '🇮🇳',
    'australia': '🇦🇺',
    'aus': '🇦🇺',
    'england': '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    'eng': '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
    'pakistan': '🇵🇰',
    'pak': '🇵🇰',
    'south africa': '🇿🇦',
    'sa': '🇿🇦',
    'rsa': '🇿🇦',
    'new zealand': '🇳🇿',
    'nz': '🇳🇿',
    'west indies': '🌴',
    'wi': '🌴',
    'sri lanka': '🇱🇰',
    'sl': '🇱🇰',
    'bangladesh': '🇧🇩',
    'ban': '🇧🇩',
    'afghanistan': '🇦🇫',
    'afg': '🇦🇫',
    'uganda': '🇺🇬',
    'uga': '🇺🇬',
    'united states': '🇺🇸',
    'usa': '🇺🇸',
    'zimbabwe': '🇿🇼',
    'zim': '🇿🇼',
    'ireland': '🇮🇪',
    'ire': '🇮🇪',
    'scotland': '🏴󠁧󠁢󠁳󠁣󠁴󠁿',
    'scot': '🏴󠁧󠁢󠁳󠁣󠁴󠁿',
    'netherlands': '🇳🇱',
    'ned': '🇳🇱',
    'namibia': '🇳🇦',
    'nam': '🇳🇦',
    'nepal': '🇳🇵',
    'nep': '🇳🇵',
    'uae': '🇦🇪',
    'united arab emirates': '🇦🇪',
    'oman': '🇴🇲',
    'canada': '🇨🇦',
    'can': '🇨🇦',
    'kenya': '🇰🇪',
    'papua new guinea': '🇵🇬',
    'png': '🇵🇬',
    'italy': '🇮🇹',
    'singapore': '🇸🇬',
    'hong kong': '🇭🇰',
    'kuwait': '🇰🇼',
    'qatar': '🇶🇦',
  };

  /// Returns flag emoji for a given team name
  static String getFlagEmoji(String teamName) {
    final lower = teamName.toLowerCase();
    for (final entry in _countryFlags.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return '🏏';
  }

  /// Extracts multiple flags from a series title (e.g. "India tour of Australia")
  static List<String> extractSeriesFlags(String seriesName) {
    final lower = seriesName.toLowerCase();
    final List<String> foundFlags = [];

    if (lower.contains('world cup') || lower.contains('trophy') || lower.contains('icc')) {
      foundFlags.add('🏆');
    }
    if (lower.contains('ipl') || lower.contains('indian premier league')) {
      foundFlags.add('🇮🇳');
    }
    if (lower.contains('bbl') || lower.contains('big bash')) {
      foundFlags.add('🇦🇺');
    }
    if (lower.contains('psl')) {
      foundFlags.add('🇵🇰');
    }
    if (lower.contains('cpl')) {
      foundFlags.add('🌴');
    }

    for (final entry in _countryFlags.entries) {
      if (entry.key.length > 2 && lower.contains(entry.key)) {
        if (!foundFlags.contains(entry.value)) {
          foundFlags.add(entry.value);
        }
      }
    }

    if (foundFlags.isEmpty) {
      foundFlags.add('🏏');
    }
    return foundFlags;
  }

  /// Builds a flag avatar widget with image URL and fallback to flag emoji
  static Widget buildTeamFlag(String? imgUrl, String teamName, {double size = 42}) {
    final emoji = getFlagEmoji(teamName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF7FAF7),
        border: Border.all(color: const Color(0xFFE3EBE4), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: imgUrl != null && imgUrl.isNotEmpty
            ? Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Text(emoji, style: TextStyle(fontSize: size * 0.52)),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: Text(emoji, style: TextStyle(fontSize: size * 0.52)),
                  );
                },
              )
            : Center(
                child: Text(emoji, style: TextStyle(fontSize: size * 0.52)),
              ),
      ),
    );
  }
}

