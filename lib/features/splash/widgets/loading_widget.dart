import 'package:flutter/material.dart';
import 'package:warshity/core/extensions/context_extension.dart';
import 'package:warshity/core/styling/app_assets.dart';

class LoadingWidget extends StatefulWidget {
  const LoadingWidget({
    super.key,
    this.progress,
    required this.messageKey,
    this.animateIntro = true,
  });

  final double? progress;

  // Retained to maintain compatibility with existing callers.
  // The subtitle is no longer displayed.
  final String messageKey;

  final bool animateIntro;

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with TickerProviderStateMixin {
  // حجم اللوجو (الصورة كاملة من غير قص)
  static const double _logoSize = 160;

  // المسافة بين اللوجو والاسم
  static const double _titleGap = 28;

  // توقيت الكتابة (الـ delay جزء من نفس الـ controller)
  static const Duration _typingDelay = Duration(milliseconds: 350);
  static const Duration _typingDuration = Duration(milliseconds: 1100);
  static final Duration _titleTotal = _typingDelay + _typingDuration;

  // مدة النبضة
  static const Duration _pulseDuration = Duration(milliseconds: 1100);

  // نفس ألوان flutter_native_splash بالظبط
  static const Color _nativeBgLight = Color(0xFFF8FAFC);
  static const Color _nativeBgDark = Color(0xFF0F172A);

  static const String _appName = 'Masiter';

  late final AnimationController _logoController;
  late final AnimationController _titleController;

  late final Animation<double> _logoScale;
  late final Animation<double> _titleTyping;

  @override
  void initState() {
    super.initState();

    // نبضة هادية تبدأ من 1.0 فمفيش قفزة وقت التحويل.
    _logoController = AnimationController(vsync: this, duration: _pulseDuration)
      ..repeat();

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOutSine)),
        weight: 50,
      ),
    ]).animate(_logoController);

    // الـ controller واحد: أول جزء منه انتظار (delay) والباقي كتابة.
    _titleController = AnimationController(
      vsync: this,
      duration: _titleTotal,
      value: widget.animateIntro ? 0 : 1,
    );

    _titleTyping = CurvedAnimation(
      parent: _titleController,
      curve: Interval(
        _typingDelay.inMilliseconds / _titleTotal.inMilliseconds,
        1.0,
        curve: Curves.linear,
      ),
    );

    if (widget.animateIntro) _startTyping();
  }

  void _startTyping() {
    if (!mounted) return;
    _titleController.forward(from: 0);
  }

  // بيشتغل مع Hot Reload في الـ debug، فالأنيميشن بتتعاد وتبان.
  @override
  void reassemble() {
    super.reassemble();

    _logoController
      ..duration = _pulseDuration
      ..repeat();

    _titleController.duration = _titleTotal;

    if (widget.animateIntro) {
      _startTyping();
    } else {
      _titleController.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant LoadingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animateIntro == widget.animateIntro) return;

    if (widget.animateIntro) {
      _titleController.value = 0;
      _startTyping();
    } else {
      _titleController.value = 1;
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// كتابة الاسم حرف حرف من الشمال لليمين.
  /// الحروف اللي لسه ماظهرتش شفافة لكن واخدة مكانها،
  /// فالنص ما بيتحركش من مكانه أثناء الكتابة.
  Widget _buildTypingTitle(ColorScheme scheme) {
    const text = _appName;

    final style = TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: scheme.primary,
    );

    return AnimatedBuilder(
      animation: _titleTyping,
      builder: (context, _) {
        // round() بدل ceil() عشان الحرف الأول ما يظهرش فوراً
        // وكل حرف ياخد نفس الزمن تقريباً.
        final count = (_titleTyping.value * text.length)
            .round()
            .clamp(0, text.length)
            .toInt();

        return Directionality(
          textDirection: TextDirection.ltr,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: text.substring(0, count), style: style),
                TextSpan(
                  text: text.substring(count),
                  style: style.copyWith(color: Colors.transparent),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nativeBg = isDark ? _nativeBgDark : _nativeBgLight;

    return Scaffold(
      // لازم يطابق background color بتاع الـ native splash.
      backgroundColor: nativeBg,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final centerY = constraints.maxHeight / 2;

          return Stack(
            children: [
              // اللوجو في نص الشاشة بالظبط، والصورة ظاهرة كاملة.
              Center(
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(
                    AppAssets.logo,
                    width: _logoSize,
                    height: _logoSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // الاسم والـ progress تحت اللوجو من غير ما يحركوه.
              Positioned(
                top: centerY + (_logoSize / 2) + _titleGap,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypingTitle(scheme),

                    // Optional progress indicator for existing loading use cases.
                    if (widget.progress != null) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 150,
                        child: LinearProgressIndicator(
                          value: widget.progress!.clamp(0.0, 1.0).toDouble(),
                          backgroundColor: scheme.surfaceContainerHighest,
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
