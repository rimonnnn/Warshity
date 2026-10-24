import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';

Future<void> showSharedAccountsComingSoon(BuildContext context) {
  final isNarrow = MediaQuery.sizeOf(context).width < 600;

  if (isNarrow) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SharedAccountsComingSoon(isSheet: true),
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const SharedAccountsComingSoon(isSheet: false),
  );
}

class SharedAccountsComingSoon extends StatefulWidget {
  const SharedAccountsComingSoon({super.key, this.isSheet = false});

  final bool isSheet;

  @override
  State<SharedAccountsComingSoon> createState() =>
      _SharedAccountsComingSoonState();
}

class _SharedAccountsComingSoonState extends State<SharedAccountsComingSoon>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _entrance,
    curve: Curves.easeOutCubic,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.colors;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
            16,
            widget.isSheet ? 8 : 24,
            16,
            16 + bottomInset,
          ),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 12),
                      color: Colors.black.withValues(alpha: 0.08),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: IconButton(
                        onPressed: _close,
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ),

                    const SizedBox(height: 2),

                    _ComingSoonIllustration(pulse: _pulse),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [colors.primary, colors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                            color: colors.primary.withValues(alpha: 0.30),
                          ),
                        ],
                      ),
                      child: Text(
                        'shared_accounts_coming_soon_badge'.tr(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Text(
                      'shared_accounts_coming_soon_title'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'shared_accounts_coming_soon_description'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.55,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 26),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton(
                        onPressed: _close,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'close'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (widget.isSheet) return content;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.none,
      child: content,
    );
  }
}

class _ComingSoonIllustration extends StatelessWidget {
  const _ComingSoonIllustration({required this.pulse});

  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      width: 148,
      height: 148,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _PulseRing(
                animation: pulse,
                interval: const Interval(0.0, 0.65, curve: Curves.easeOut),
                baseSize: 100,
                color: colors.primary,
              ),
              _PulseRing(
                animation: pulse,
                interval: const Interval(0.30, 0.95, curve: Curves.easeOut),
                baseSize: 100,
                color: colors.secondary,
              ),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [colors.primary, colors.secondary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 28,
                      spreadRadius: 2,
                      offset: const Offset(0, 10),
                      color: colors.primary.withValues(alpha: 0.35),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.diversity_3_rounded,
                  size: 44,
                  color: colors.onPrimary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.animation,
    required this.interval,
    required this.baseSize,
    required this.color,
  });

  final Animation<double> animation;
  final Interval interval;
  final double baseSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(parent: animation, curve: interval);

    return AnimatedBuilder(
      animation: t,
      builder: (context, _) {
        return Transform.scale(
          scale: 1.0 + 0.55 * t.value,
          child: Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.35 * (1.0 - t.value)),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
