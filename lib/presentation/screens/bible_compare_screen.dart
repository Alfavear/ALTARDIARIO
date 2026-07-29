import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/bible_models.dart';
import '../../data/services/bible_service.dart';

/// Screen and Modal for comparing Bible passages across multiple versions side-by-side.
class BibleCompareScreen extends ConsumerStatefulWidget {
  final String pasaje;
  final String? initialVersionA;
  final String? initialVersionB;

  const BibleCompareScreen({
    super.key,
    required this.pasaje,
    this.initialVersionA,
    this.initialVersionB,
  });

  @override
  ConsumerState<BibleCompareScreen> createState() => _BibleCompareScreenState();
}

class _BibleCompareScreenState extends ConsumerState<BibleCompareScreen>
    with SingleTickerProviderStateMixin {
  final BibleService _bibleService = BibleService();
  late TabController _tabController;

  List<BibleVersion> _availableVersions = [];
  late BibleVersion _versionA;
  late BibleVersion _versionB;

  bool _isLoading = true;
  List<BiblePassage> _passagesA = [];
  List<BiblePassage> _passagesB = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initAndLoad();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initAndLoad() async {
    setState(() => _isLoading = true);
    final versions = await _bibleService.getAllAvailableVersions();
    _availableVersions = versions;

    if (versions.isNotEmpty) {
      _versionA = versions.firstWhere(
        (v) => v.id == widget.initialVersionA,
        orElse: () => versions.first,
      );
      _versionB = versions.firstWhere(
        (v) => v.id == widget.initialVersionB,
        orElse: () => versions.length > 1 ? versions[1] : versions.first,
      );
    } else {
      _versionA = const BibleVersion(id: 'rv1960', name: 'Reina-Valera 1960', lang: 'es');
      _versionB = const BibleVersion(id: 'rv1909', name: 'Reina Valera 1909', lang: 'es');
    }

    await _loadBoth();
  }

  Future<void> _loadBoth() async {
    setState(() => _isLoading = true);

    try {
      final pA = await _bibleService.getPassageText(widget.pasaje, version: _versionA.id);
      final pB = await _bibleService.getPassageText(widget.pasaje, version: _versionB.id);

      if (!mounted) return;
      setState(() {
        _passagesA = pA;
        _passagesB = pB;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.primaryBlueLight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparar Versiones',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.pasaje,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.splitscreen_rounded), text: 'Vista Paralela'),
            Tab(icon: Icon(Icons.format_list_bulleted_rounded), text: 'Versículo por Versículo'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildParallelView(),
                _buildVerseByVerseView(),
              ],
            ),
    );
  }

  Widget _buildParallelView() {
    return Column(
      children: [
        _buildVersionHeaderBar(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: AppTheme.pendingGrayDark, width: 0.5)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: _passagesA.map((p) => _buildPassageContent(p, isLeft: true)).toList(),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: _passagesB.map((p) => _buildPassageContent(p, isLeft: false)).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVersionHeaderBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildVersionDropdown(_versionA, (v) {
              if (v != null) {
                setState(() => _versionA = v);
                _loadBoth();
              }
            }),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.compare_arrows, color: AppTheme.primaryBlue, size: 20),
          ),
          Expanded(
            child: _buildVersionDropdown(_versionB, (v) {
              if (v != null) {
                setState(() => _versionB = v);
                _loadBoth();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionDropdown(BibleVersion current, ValueChanged<BibleVersion?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.pendingGray,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.pendingGrayDark.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BibleVersion>(
          isExpanded: true,
          value: _availableVersions.any((v) => v.id == current.id) ? current : null,
          items: _availableVersions.map((v) {
            return DropdownMenuItem<BibleVersion>(
              value: v,
              child: Text(
                v.name,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPassageContent(BiblePassage passage, {required bool isLeft}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            passage.reference,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ),
        ...passage.verses.map((v) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${v.verse} ',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentGold,
                    ),
                  ),
                  TextSpan(
                    text: v.text,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildVerseByVerseView() {
    final Map<int, String> mapA = {};
    final Map<int, String> mapB = {};

    for (final p in _passagesA) {
      for (final v in p.verses) {
        mapA[v.verse] = v.text;
      }
    }
    for (final p in _passagesB) {
      for (final v in p.verses) {
        mapB[v.verse] = v.text;
      }
    }

    final allVerses = {...mapA.keys, ...mapB.keys}.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allVerses.length,
      itemBuilder: (ctx, index) {
        final verseNum = allVerses[index];
        final textA = mapA[verseNum] ?? '—';
        final textB = mapB[verseNum] ?? '—';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Versículo $verseNum',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.pendingGray.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _versionA.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        textA,
                        style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _versionB.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        textB,
                        style: const TextStyle(fontSize: 14, height: 1.4, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
