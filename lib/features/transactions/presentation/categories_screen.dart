import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/localization/l10n.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/form_fields.dart';
import '../../../shared/widgets/states.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final categories = ref.watch(categoriesProvider);
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(l.categories),
              bottom: TabBar(
                tabs: [
                  Tab(text: l.expenses),
                  Tab(text: l.income),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                final type = DefaultTabController.of(context).index == 0
                    ? TransactionType.expense
                    : TransactionType.income;
                showAppSheet(context, (_) => CategoryFormSheet(type: type));
              },
              icon: const Icon(Icons.add_rounded),
              label: Text(l.newCategory),
            ),
            body: AsyncView(
              value: categories,
              builder: (all) => TabBarView(
                children: [
                  _CategoryList(
                    items: categoriesOfType(all, TransactionType.expense),
                  ),
                  _CategoryList(
                    items: categoriesOfType(all, TransactionType.income),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryList extends ConsumerWidget {
  const _CategoryList({required this.items});
  final List<CategoryRecord> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.lg, Insets.lg, 96),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: Insets.sm),
      itemBuilder: (context, i) {
        final c = items[i];
        return AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.sm,
          ),
          onTap: c.isDefault
              ? null
              : () => showAppSheet(
                  context,
                  (_) => CategoryFormSheet(type: c.type, existing: c),
                ),
          child: Row(
            children: [
              IconTile(
                icon: AppIcons.of(c.iconKey),
                color: Color(c.color),
                size: 40,
              ),
              const SizedBox(width: Insets.md),
              Expanded(
                child: Text(l.categoryName(c), style: context.text.titleSmall),
              ),
              if (c.isDefault)
                Text(l.builtIn, style: context.text.bodySmall)
              else
                IconButton(
                  tooltip: l.delete,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: context.palette.expense,
                  ),
                  onPressed: () async {
                    final repo = ref.read(categoryRepositoryProvider);
                    final used = await repo.usageCount(c.id);
                    if (!context.mounted) return;
                    final ok = await confirmAction(
                      context,
                      title: l.deleteCategoryTitle,
                      message: used > 0
                          ? l.deleteCategoryInUse(used)
                          : l.deleteCategoryBody,
                      destructive: true,
                    );
                    if (!ok) return;
                    await repo.delete(c.id);
                    if (context.mounted) showSnack(context, l.categoryDeleted);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({super.key, required this.type, this.existing});
  final TransactionType type;
  final CategoryRecord? existing;

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late String _icon = widget.existing?.iconKey ?? 'category';
  late int _color = widget.existing?.color ?? AppColors.pickerColors.first;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final repo = ref.read(categoryRepositoryProvider);
    if (widget.existing == null) {
      await repo.create(
        name: _name.text,
        type: widget.type,
        iconKey: _icon,
        color: _color,
      );
    } else {
      await repo.updateCategory(
        widget.existing!.id,
        name: _name.text,
        iconKey: _icon,
        color: _color,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            0,
            Insets.xl,
            Insets.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? l.newCategory : l.editCategory,
                style: context.text.titleLarge,
              ),
              const SizedBox(height: Insets.lg),
              TextFormField(
                controller: _name,
                maxLength: 40,
                autofocus: widget.existing == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l.name, counterText: ''),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l.validationNameRequired : null,
              ),
              const SizedBox(height: Insets.lg),
              Text(l.icon, style: context.text.labelMedium),
              const SizedBox(height: Insets.sm),
              IconPicker(
                keys: AppIcons.categoryChoices,
                selected: _icon,
                color: Color(_color),
                iconOf: AppIcons.of,
                onSelected: (k) => setState(() => _icon = k),
              ),
              const SizedBox(height: Insets.lg),
              Text(l.color, style: context.text.labelMedium),
              const SizedBox(height: Insets.sm),
              ColorPicker(
                colors: AppColors.pickerColors,
                selected: _color,
                onSelected: (c) => setState(() => _color = c),
              ),
              const SizedBox(height: Insets.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(onPressed: _save, child: Text(l.save)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
