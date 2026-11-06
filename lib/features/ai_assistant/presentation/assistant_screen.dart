import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/finance_providers.dart';
import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/localization/l10n.dart';
import '../../../data/local/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/dialogs.dart';
import '../../../shared/widgets/states.dart';
import '../engine/assistant_engine.dart';
import '../engine/financial_snapshot.dart';

/// The engine in use. Swap this provider to plug in a remote LLM later.
final assistantEngineProvider = Provider<AssistantEngine>(
  (ref) => const LocalAssistantEngine(),
);

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _thinking = false;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final message = text.trim();
    if (message.isEmpty || _thinking) return;
    final l = context.l10n;
    _input.clear();
    final chat = ref.read(chatRepositoryProvider);
    await chat.add(ChatRole.user, message);
    setState(() => _thinking = true);
    _scrollToEnd();
    try {
      // Wait for the data snapshot if it is still loading.
      final snapshot = await _snapshot();
      final started = DateTime.now();
      final reply = await ref
          .read(assistantEngineProvider)
          .reply(message, snapshot, l);
      // Short pause so the typing indicator is perceivable (UX only).
      final elapsed = DateTime.now().difference(started);
      const minDelay = Duration(milliseconds: 550);
      if (elapsed < minDelay) await Future<void>.delayed(minDelay - elapsed);
      await chat.add(
        ChatRole.assistant,
        reply.text,
        insufficientData: reply.insufficientData,
      );
    } catch (_) {
      await chat.add(ChatRole.assistant, l.aiError);
    } finally {
      if (mounted) setState(() => _thinking = false);
      _scrollToEnd();
    }
  }

  Future<FinancialSnapshot> _snapshot() async {
    for (var i = 0; i < 50; i++) {
      final s = ref.read(financialSnapshotProvider);
      if (s.hasValue) return s.value!;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    throw TimeoutException('snapshot');
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final messages = ref.watch(chatMessagesProvider);
    // Keep the snapshot warm so answers are instant.
    ref.watch(financialSnapshotProvider);

    final suggestions = [
      l.aiSuggest1,
      l.aiSuggest2,
      l.aiSuggest3,
      l.aiSuggest4,
      l.aiSuggest5,
      l.aiSuggest6,
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: Insets.lg,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [context.colors.primary, context.palette.accent],
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: Insets.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.assistantTitle, style: context.text.titleMedium),
                  Text(l.assistantSubtitle, style: context.text.bodySmall),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.clearConversation,
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: l.clearConversation,
                message: l.clearConversationBody,
                destructive: true,
                confirmLabel: l.clear,
              );
              if (ok) await ref.read(chatRepositoryProvider).clear();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AsyncView(
              value: messages,
              builder: (list) {
                if (list.isEmpty && !_thinking) {
                  return _EmptyChat(suggestions: suggestions, onAsk: _send);
                }
                final reversed = list.reversed.toList();
                return ListView.builder(
                  controller: _scroll,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(
                    Insets.lg,
                    Insets.lg,
                    Insets.lg,
                    Insets.sm,
                  ),
                  itemCount: reversed.length + (_thinking ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_thinking && i == 0) return const _TypingBubble();
                    return _Bubble(reversed[_thinking ? i - 1 : i]);
                  },
                );
              },
            ),
          ),
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: Insets.sm),
              itemBuilder: (context, i) => ActionChip(
                label: Text(suggestions[i]),
                onPressed: _thinking ? null : () => _send(suggestions[i]),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.lg,
                Insets.sm,
                Insets.sm,
                Insets.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: InputDecoration(
                        hintText: l.askHint,
                        counterText: '',
                      ),
                    ),
                  ),
                  const SizedBox(width: Insets.xs),
                  IconButton.filled(
                    tooltip: l.send,
                    onPressed: _thinking ? null : () => _send(_input.text),
                    icon: const Icon(Icons.arrow_upward_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.suggestions, required this.onAsk});
  final List<String> suggestions;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(Insets.lg),
      children: [
        EmptyState(
          icon: Icons.auto_awesome,
          title: l.assistantEmptyTitle,
          message: l.assistantEmptyBody,
        ),
        Container(
          padding: const EdgeInsets.all(Insets.md),
          decoration: BoxDecoration(
            color: context.palette.surface2,
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: context.palette.textSecondary,
              ),
              const SizedBox(width: Insets.sm),
              Expanded(
                child: Text(
                  l.assistantLocalNote,
                  style: context.text.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.m);
  final ChatMessageRecord m;

  @override
  Widget build(BuildContext context) {
    final mine = m.role == ChatRole.user;
    final bg = mine ? context.colors.primary : context.colors.surface;
    final fg = mine ? Colors.white : context.colors.onSurface;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            border: mine ? null : Border.all(color: context.palette.outline),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (m.insufficientData)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: context.palette.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.insufficientDataBadge,
                        style: context.text.labelSmall?.copyWith(
                          color: context.palette.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              SelectableText(
                m.body,
                style: context.text.bodyMedium?.copyWith(color: fg),
              ),
              const SizedBox(height: 4),
              Text(
                context.dates.time(m.createdAt),
                style: context.text.labelSmall?.copyWith(
                  color: fg.withValues(alpha: 0.6),
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.l10n.assistantTyping,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border.all(color: context.palette.outline),
            borderRadius: BorderRadius.circular(18),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.primary.withValues(
                        alpha:
                            0.3 +
                            0.7 *
                                (((_c.value * 3 - i) % 3) < 1
                                    ? 1 - ((_c.value * 3 - i) % 1)
                                    : 0.0),
                      ),
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
