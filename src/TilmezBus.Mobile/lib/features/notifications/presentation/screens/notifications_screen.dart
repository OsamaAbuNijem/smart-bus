import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:tilmez_bus/core/theme/app_theme.dart';
import 'package:tilmez_bus/features/notifications/domain/entities/notification_item.dart';
import 'package:tilmez_bus/features/notifications/presentation/providers/notifications_controller.dart';
import 'package:tilmez_bus/l10n/generated/app_localizations.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(notificationsControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (items) => _Body(items: items, l: l),
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.items, required this.l});
  final List<NotificationItem> items;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = items.where((n) => !n.isRead).length;

    return Column(
      children: [
        _Hero(
          newCount: unread,
          total: items.length,
          l: l,
          onMarkAllRead: () => ref
              .read(notificationsControllerProvider.notifier)
              .markAllRead(),
        ),
        Expanded(
          child: items.isEmpty
              ? _EmptyState(l: l)
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(notificationsControllerProvider.notifier)
                      .refresh(),
                  child: _Groups(items: items, l: l),
                ),
        ),
      ],
    );
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({
    required this.newCount,
    required this.total,
    required this.l,
    required this.onMarkAllRead,
  });
  final int newCount;
  final int total;
  final AppLocalizations l;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate100)),
      ),
      child: Row(
        children: [
          _IconChip(
            icon: isRtl ? Icons.arrow_forward : Icons.arrow_back,
            onTap: () => context.canPop() ? context.pop() : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.notificationsTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 1),
                _Sub(newCount: newCount, total: total, l: l),
              ],
            ),
          ),
          if (newCount > 0)
            _MarkAllPill(
              label: l.notificationsMarkAllRead,
              onTap: onMarkAllRead,
            ),
        ],
      ),
    );
  }
}

class _Sub extends StatelessWidget {
  const _Sub({required this.newCount, required this.total, required this.l});
  final int newCount;
  final int total;
  final AppLocalizations l;
  @override
  Widget build(BuildContext context) {
    // The localised string uses "·" as the divider — split on it so the
    // "new" half can highlight the count in yellow without needing two ICU
    // strings.
    final parts = l.notificationsCountSummary(newCount, total).split('·');
    final left = parts.isNotEmpty ? parts.first.trim() : '$newCount';
    final right = parts.length > 1 ? parts[1].trim() : '$total';
    final leftSuffix = left.replaceFirst('$newCount', '').trim();

    return Text.rich(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      TextSpan(
        style: const TextStyle(
          color: AppColors.slate500,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: '$newCount',
            style: const TextStyle(
              color: AppColors.yellowDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: leftSuffix.isEmpty ? '' : ' $leftSuffix'),
          const TextSpan(text: ' · '),
          TextSpan(text: right),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.slate50,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.slate100),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppColors.slate700,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}

class _MarkAllPill extends StatelessWidget {
  const _MarkAllPill({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.yellowTint,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: const Color(0x66F5C518)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, size: 11, color: AppColors.yellowDeep),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.yellowDeep,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Groups ───────────────────────────────────────────────────────────

class _Groups extends ConsumerWidget {
  const _Groups({required this.items, required this.l});
  final List<NotificationItem> items;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group by day-bucket relative to "now". Items within a bucket keep their
    // server-sent newest-first order.
    final today = DateTime.now();
    int dayKey(DateTime d) => DateTime(d.year, d.month, d.day)
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    final buckets = <int, List<NotificationItem>>{};
    for (final n in items) {
      buckets.putIfAbsent(dayKey(n.createdAt.toLocal()), () => []).add(n);
    }
    final orderedKeys = buckets.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      itemCount: orderedKeys.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final key = orderedKeys[index];
        final group = buckets[key]!;
        return _DayGroup(
          label: _bucketLabel(key, l),
          countLabel: _countLabel(group, l),
          items: group,
        );
      },
    );
  }

  String _bucketLabel(int dayKey, AppLocalizations l) {
    if (dayKey == 0) return l.notificationsToday;
    if (dayKey == -1) return l.notificationsYesterday;
    return l.notificationsDaysAgo(-dayKey);
  }

  String _countLabel(List<NotificationItem> items, AppLocalizations l) {
    final newCount = items.where((n) => !n.isRead).length;
    return newCount > 0
        ? l.notificationsCountNew(newCount)
        : l.notificationsCountItems(items.length);
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.label,
    required this.countLabel,
    required this.items,
  });
  final String label;
  final String countLabel;
  final List<NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate500,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              Text(
                countLabel,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x0A0F172A), offset: Offset(0, 1), blurRadius: 3),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _NotifRow(item: items[i]),
                  if (i < items.length - 1)
                    const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NotifRow extends ConsumerWidget {
  const _NotifRow({required this.item});
  final NotificationItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = !item.isRead;
    final iconStyle = _iconStyleFor(item.type);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return DecoratedBox(
      decoration: unread
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                colors: const [Color(0xFFFFFBEB), Colors.white],
                stops: const [0, 0.8],
              ),
            )
          : const BoxDecoration(color: Colors.white),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (unread) {
              ref
                  .read(notificationsControllerProvider.notifier)
                  .markRead(item.id);
            }
          },
          child: Stack(
            children: [
              if (unread)
                Positioned(
                  top: 14,
                  bottom: 14,
                  left: isRtl ? null : 0,
                  right: isRtl ? 0 : null,
                  child: Container(
                    width: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF5C518), Color(0xFFE0AE08)],
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: iconStyle.bg,
                        border: Border.all(color: iconStyle.border),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child:
                          Icon(iconStyle.icon, size: 17, color: iconStyle.fg),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight:
                                  unread ? FontWeight.w800 : FontWeight.w700,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.2,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat.jm().format(item.createdAt.toLocal()),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(height: 6),
                          const _UnreadPulse(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 8px yellow dot with the soft pulsing ring from the template's
/// `@keyframes unreadPulse` (2s loop, ring expands 0→6px and fades out).
class _UnreadPulse extends StatefulWidget {
  const _UnreadPulse();
  @override
  State<_UnreadPulse> createState() => _UnreadPulseState();
}

class _UnreadPulseState extends State<_UnreadPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        // Map t∈[0,1] to phase∈[0,1] over the first 70% of the cycle, so the
        // ring grows + fades and then sits invisible for the last 30% — the
        // same shape as the CSS keyframes.
        final phase = (_c.value / 0.7).clamp(0.0, 1.0);
        final spread = phase * 6.0;
        final alpha = (1 - phase) * 0.6;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF5C518), Color(0xFFE0AE08)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(245, 197, 24, alpha),
                blurRadius: 0,
                spreadRadius: spread,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconStyle {
  const _IconStyle(this.icon, this.bg, this.border, this.fg);
  final IconData icon;
  final Color bg;
  final Color border;
  final Color fg;
}

_IconStyle _iconStyleFor(NotificationKind k) => switch (k) {
      NotificationKind.busArriving =>
        const _IconStyle(Icons.access_time, Color(0xFFFEF3C7), Color(0xFFFDE68A), Color(0xFFD97706)),
      NotificationKind.studentBoarded =>
        const _IconStyle(Icons.check, Color(0xFFD1FAE5), Color(0xFFA7F3D0), Color(0xFF059669)),
      NotificationKind.studentArrived =>
        const _IconStyle(Icons.school, Color(0xFFDBEAFE), Color(0xFFBFDBFE), Color(0xFF2563EB)),
      NotificationKind.busArrived =>
        const _IconStyle(Icons.check, Color(0xFFD1FAE5), Color(0xFFA7F3D0), Color(0xFF059669)),
      NotificationKind.driverMessage =>
        const _IconStyle(Icons.message_outlined, Color(0xFFEDE9FE), Color(0xFFDDD6FE), Color(0xFF7C3AED)),
      NotificationKind.absenceConfirmed =>
        const _IconStyle(Icons.task_alt, Color(0xFFFFFBEB), Color(0xFFFDE68A), Color(0xFFE0AE08)),
      NotificationKind.schoolNotice =>
        const _IconStyle(Icons.info_outline, Color(0xFFDBEAFE), Color(0xFFBFDBFE), Color(0xFF2563EB)),
      NotificationKind.tripStarted ||
      NotificationKind.tripCompleted =>
        const _IconStyle(Icons.directions_bus_outlined, Color(0xFFDBEAFE), Color(0xFFBFDBFE), Color(0xFF2563EB)),
      NotificationKind.systemAlert =>
        const _IconStyle(Icons.warning_amber_outlined, Color(0xFFFFE4E6), Color(0xFFFECDD3), Color(0xFFE11D48)),
    };

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications_none, size: 36, color: Color(0xFFE0AE08)),
            ),
            const SizedBox(height: 18),
            Text(
              l.notificationsEmptyTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 6),
            Text(
              l.notificationsEmptySub,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
