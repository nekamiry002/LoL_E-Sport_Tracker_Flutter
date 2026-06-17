import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../features/matches/data/datasources/league_schedule_datasource.dart';
import '../features/matches/presentation/providers/history_provider.dart';
import '../features/matches/presentation/providers/match_provider.dart';
import '../widgets/hex_logo.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'ALL';
  DateTimeRange? _dateRange;
  String _search = '';
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<HistoryProvider>();
      if (provider.status == HistoryStatus.initial) {
        provider.fetchHistory();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final provider = context.read<HistoryProvider>();
    final matches = provider.matches;
    final earliest = matches.isNotEmpty ? matches.last.startTime : DateTime(2024);
    final latest = matches.isNotEmpty ? matches.first.startTime : DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(earliest.year, earliest.month, earliest.day),
      lastDate: DateTime(latest.year, latest.month, latest.day),
      initialDateRange: _dateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.black,
            surface: Color(0xFF1A1A2E),
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  List<HistoryMatch> _filtered(List<HistoryMatch> all) {
    var list = all;
    if (_filter != 'ALL') {
      list = list.where((m) => m.leagueName == _filter).toList();
    }
    if (_dateRange != null) {
      final start = _dateRange!.start;
      final end = _dateRange!.end;
      list = list.where((m) {
        final d = m.startTime;
        return !d.isBefore(DateTime(start.year, start.month, start.day)) &&
            !d.isAfter(DateTime(end.year, end.month, end.day, 23, 59, 59));
      }).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((m) =>
        m.team1Name.toLowerCase().contains(q) ||
        m.team2Name.toLowerCase().contains(q) ||
        m.team1Code.toLowerCase().contains(q) ||
        m.team2Code.toLowerCase().contains(q)
      ).toList();
    }
    return list;
  }

  List<String> _dateGroups(List<HistoryMatch> matches) {
    final seen = <String>{};
    return matches.map((m) => m.dateLabel).where(seen.add).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HistoryProvider>();
    final filtered = _filtered(provider.matches);
    final leagues = ['ALL', ...provider.availableLeagues];

    return Column(
      children: [
        _Header(
          count: filtered.length,
          hasDateFilter: _dateRange != null,
          showSearch: _showSearch,
          onCalendarTap: _pickDateRange,
          onClearDate: () => setState(() => _dateRange = null),
          onSearchToggle: () => setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) {
              _search = '';
              _searchController.clear();
            }
          }),
        ),
        if (_showSearch)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: AppTheme.rajdhani(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search teams...',
                hintStyle: AppTheme.rajdhani(color: AppColors.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 18),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                ),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        _LeagueFilter(
          leagues: leagues,
          selected: _filter,
          onSelect: (l) => setState(() => _filter = l),
        ),
        Expanded(
          child: switch (provider.status) {
            HistoryStatus.initial || HistoryStatus.loading =>
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            HistoryStatus.failure =>
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.textMuted, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load history',
                      style: AppTheme.rajdhani(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => provider.fetchHistory(),
                      child: Text('Retry', style: AppTheme.rajdhani(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            HistoryStatus.success when filtered.isEmpty =>
              const _EmptyState(),
            HistoryStatus.success =>
              RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: const Color(0xFF1A1A2E),
                onRefresh: () => provider.fetchHistory(),
                child: _MatchList(groups: _dateGroups(filtered), matches: filtered),
              ),
          },
        ),
      ],
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.count,
    required this.hasDateFilter,
    required this.showSearch,
    required this.onCalendarTap,
    required this.onClearDate,
    required this.onSearchToggle,
  });
  final int count;
  final bool hasDateFilter;
  final bool showSearch;
  final VoidCallback onCalendarTap;
  final VoidCallback onClearDate;
  final VoidCallback onSearchToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
      child: Row(
        children: [
          _HamburgerBtn(),
          Expanded(
            child: Column(
              children: [
                Text(
                  'HISTORY',
                  style: AppTheme.rajdhani(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count RESULTS',
                  style: AppTheme.rajdhani(
                    fontSize: 9,
                    letterSpacing: 2.5,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onSearchToggle,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: showSearch
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    border: Border.all(
                      color: showSearch
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.07),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    showSearch ? Icons.close : Icons.search,
                    color: showSearch ? AppColors.primary : AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: hasDateFilter ? onClearDate : onCalendarTap,
                child: Stack(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: hasDateFilter
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        border: Border.all(
                          color: hasDateFilter
                              ? AppColors.primary.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.07),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        hasDateFilter ? Icons.close : Icons.calendar_today_outlined,
                        color: hasDateFilter ? AppColors.primary : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                    if (hasDateFilter)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HamburgerBtn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Scaffold.of(context).openDrawer(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _Bar(color: AppColors.primary),
            SizedBox(height: 4),
            _Bar(color: AppColors.textPrimary),
            SizedBox(height: 4),
            _Bar(color: AppColors.textPrimary, width: 12),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.color, this.width = 18});
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// ── League filter chips ───────────────────────────────────────────────────────

class _LeagueFilter extends StatelessWidget {
  const _LeagueFilter({
    required this.leagues,
    required this.selected,
    required this.onSelect,
  });
  final List<String> leagues;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    if (leagues.length <= 1) return const SizedBox(height: 40);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: leagues.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final l = leagues[i];
          final active = l == selected;
          final color =
              l == 'ALL' ? AppColors.primary : AppColors.leagueColor(l);
          return GestureDetector(
            onTap: () => onSelect(l),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: active
                    ? color.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.04),
                border: Border.all(
                  color: active
                      ? color.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.07),
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                l,
                style: AppTheme.rajdhani(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 1.5,
                  color: active ? color : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Match list (grouped by date) ──────────────────────────────────────────────

class _MatchList extends StatelessWidget {
  const _MatchList({required this.groups, required this.matches});
  final List<String> groups;
  final List<HistoryMatch> matches;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 26),
      itemCount: groups.length,
      itemBuilder: (_, i) {
        final group = groups[i];
        final groupMatches = matches.where((m) => m.dateLabel == group).toList();
        return _DateSection(dateLabel: group, matches: groupMatches);
      },
    );
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection({required this.dateLabel, required this.matches});
  final String dateLabel;
  final List<HistoryMatch> matches;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 10),
          child: Row(
            children: [
              Text(
                dateLabel,
                style: AppTheme.rajdhani(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Divider(
                  color: Colors.white.withValues(alpha: 0.06),
                  thickness: 1,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
        ...matches.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ResultCard(match: m),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.match});
  final HistoryMatch match;

  @override
  Widget build(BuildContext context) {
    final leagueColor = AppColors.leagueColor(match.leagueName);
    final matchProvider = context.read<MatchProvider>();
    final team1 = matchProvider.teamFor(match.team1Code);
    final team2 = matchProvider.teamFor(match.team2Code);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/team', arguments: match.team1Code),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0, height: 2,
              child: ColoredBox(color: leagueColor.withValues(alpha: 0.7)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: leagueColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          match.leagueName,
                          style: AppTheme.rajdhani(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: leagueColor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'BO${match.bestOf}',
                        style: AppTheme.barlow(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            HexLogo(size: 40, gradient: team1.gradient, mono: team1.mono),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                match.team1Name.isNotEmpty ? match.team1Name : team1.name,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.rajdhani(
                                  fontSize: 15,
                                  fontWeight: match.team1Won
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: match.team1Won
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            match.scoreText,
                            style: AppTheme.rajdhani(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                match.team2Name.isNotEmpty ? match.team2Name : team2.name,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: AppTheme.rajdhani(
                                  fontSize: 15,
                                  fontWeight: !match.team1Won
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: !match.team1Won
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            HexLogo(size: 40, gradient: team2.gradient, mono: team2.mono),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 56, color: AppColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'NO RESULTS',
            style: AppTheme.rajdhani(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No matches found for this filter.',
            style: AppTheme.barlow(fontSize: 14, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
