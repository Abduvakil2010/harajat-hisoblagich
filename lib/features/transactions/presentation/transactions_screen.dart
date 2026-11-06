import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/localization/l10n.dart';
import '../../../core/utils/date_range.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/states.dart';
import '../widgets/transaction_tile.dart';

final _queryResultsProvider = StreamProvider.autoDispose
    .family<List<TransactionRecord>, (TransactionQuery, int)>(
      (ref, args) => ref
          .watch(transactionRepositoryProvider)
          .watchQuery(args.$1, limit: args.$2),
    );

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  static const _pageSize = 50;
  final _search = TextEditingController();
  final _scroll = ScrollController();
  Timer? _debounce;
  TransactionQuery _query = const TransactionQuery();
  int _limit = _pageSize;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 600) {
        final current = ref.read(_queryResultsProvider((_query, _limit))).value;
        if (current != null && current.length >= _limit) {
          setState(() => _limit += _pageSize);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _setQuery(TransactionQuery q) => setState(() {
    _query = q;
    _limit = _pageSize;
  });

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _query.range == null
          ? null
          : DateTimeRange(
              start: _query.range!.start,
              end: _query.range!.lastDay,
            ),
    );
    if (r != null) {
      _setQuery(_query.copyWith(range: () => DateRange.days(r.start, r.end)));
    }
  }

  Future<void> _pickCategories() async {
    final all = ref.read(categoriesProvider).value ?? const [];
    final result = await showAppSheet<Set<int>>(
      context,
      (_) => _CategoryFilterSheet(all: all, selected: _query.categoryIds),
    );
    if (result != null) _setQuery(_query.copyWith(categoryIds: result));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final results = ref.watch(_queryResultsProvider((_query, _limit)));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.allTransactions),
        actions: [
          PopupMenuButton<TransactionSort>(
            tooltip: l.sort,
            icon: const Icon(Icons.swap_vert_rounded),
            initialValue: _query.sort,
            onSelected: (s) => _setQuery(_query.copyWith(sort: s)),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: TransactionSort.dateDesc,
                child: Text(l.sortNewest),
              ),
              PopupMenuItem(
                value: TransactionSort.dateAsc,
                child: Text(l.sortOldest),
              ),
              PopupMenuItem(
                value: TransactionSort.amountDesc,
                child: Text(l.sortAmountHigh),
              ),
              PopupMenuItem(
                value: TransactionSort.amountAsc,
                child: Text(l.sortAmountLow),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l.addTransaction,
        onPressed: () => context.push(Routes.newTransaction),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Insets.lg,
              0,
              Insets.lg,
              Insets.sm,
            ),
            child: TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l.searchTransactions,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l.clear,
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _search.clear();
                          _setQuery(_query.copyWith(search: ''));
                        },
                      ),
              ),
              onChanged: (v) {
                setState(() {});
                _debounce?.cancel();
                _debounce = Timer(
                  const Duration(milliseconds: 300),
                  () => _setQuery(_query.copyWith(search: v)),
                );
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
              children: [
                _chip(
                  l.all,
                  _query.type == null,
                  () => _setQuery(_query.copyWith(type: () => null)),
                ),
                _chip(
                  l.income,
                  _query.type == TransactionType.income,
                  () => _setQuery(
                    _query.copyWith(type: () => TransactionType.income),
                  ),
                ),
                _chip(
                  l.expenses,
                  _query.type == TransactionType.expense,
                  () => _setQuery(
                    _query.copyWith(type: () => TransactionType.expense),
                  ),
                ),
                const SizedBox(width: Insets.sm),
                _chip(
                  _query.range == null
                      ? l.anyDate
                      : '${context.dates.dayShort(_query.range!.start)} – ${context.dates.dayShort(_query.range!.lastDay)}',
                  _query.range != null,
                  _pickRange,
                  icon: Icons.date_range_rounded,
                  onClear: _query.range == null
                      ? null
                      : () => _setQuery(_query.copyWith(range: () => null)),
                ),
                _chip(
                  _query.categoryIds.isEmpty
                      ? l.categories
                      : l.categoriesSelected(_query.categoryIds.length),
                  _query.categoryIds.isNotEmpty,
                  _pickCategories,
                  icon: Icons.category_rounded,
                  onClear: _query.categoryIds.isEmpty
                      ? null
                      : () => _setQuery(_query.copyWith(categoryIds: {})),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.sm),
          Expanded(
            child: AsyncView(
              value: results,
              builder: (list) {
                if (list.isEmpty) {
                  return _query.isFiltered
                      ? EmptyState(
                          icon: Icons.search_off_rounded,
                          title: l.noResultsTitle,
                          message: l.noResultsBody,
                        )
                      : EmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: l.emptyTransactionsTitle,
                          message: l.emptyTransactionsBody,
                          actionLabel: l.addTransaction,
                          onAction: () => context.push(Routes.newTransaction),
                        );
                }
                final byDate =
                    _query.sort == TransactionSort.dateDesc ||
                    _query.sort == TransactionSort.dateAsc;
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                    Insets.md,
                    0,
                    Insets.md,
                    96,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final t = list[i];
                    final header =
                        byDate &&
                        (i == 0 || !list[i - 1].date.isSameDay(t.date));
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (header)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Insets.sm,
                              Insets.lg,
                              Insets.sm,
                              Insets.xs,
                            ),
                            child: Text(
                              context.dates.relative(t.date, l, DateTime.now()),
                              style: context.text.labelMedium,
                            ),
                          ),
                        TransactionTile(t, showDate: !byDate),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    String label,
    bool selected,
    VoidCallback onTap, {
    IconData? icon,
    VoidCallback? onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: Insets.sm),
      child: InputChip(
        label: Text(label),
        selected: selected,
        onPressed: onTap,
        avatar: icon == null ? null : Icon(icon, size: 16),
        onDeleted: onClear,
        deleteIcon: const Icon(Icons.close_rounded, size: 16),
      ),
    );
  }
}

class _CategoryFilterSheet extends StatefulWidget {
  const _CategoryFilterSheet({required this.all, required this.selected});
  final List<CategoryRecord> all;
  final Set<int> selected;

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet> {
  late final Set<int> _sel = {...widget.selected};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget group(String title, TransactionType type) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: Insets.sm),
          child: Text(title, style: context.text.labelMedium),
        ),
        Wrap(
          spacing: Insets.sm,
          runSpacing: Insets.sm,
          children: [
            for (final c in widget.all.where((c) => c.type == type))
              FilterChip(
                avatar: Icon(
                  AppIcons.of(c.iconKey),
                  size: 16,
                  color: Color(c.color),
                ),
                label: Text(l.categoryName(c)),
                selected: _sel.contains(c.id),
                onSelected: (v) =>
                    setState(() => v ? _sel.add(c.id) : _sel.remove(c.id)),
              ),
          ],
        ),
      ],
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Insets.xl, 0, Insets.xl, Insets.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.filterByCategory, style: context.text.titleLarge),
            group(l.expenses, TransactionType.expense),
            group(l.income, TransactionType.income),
            const SizedBox(height: Insets.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, <int>{}),
                    child: Text(l.clear),
                  ),
                ),
                const SizedBox(width: Insets.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _sel),
                    child: Text(l.apply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
