import 'package:flutter/material.dart';
import 'package:foxcare_lite/utilities/widgets/text/primary_text.dart';

void CustomSnackBar(
    BuildContext context, {
      required String message,
      Color backgroundColor = Colors.grey,
      IconData? icon,
      double iconSize = 24.0,
      double fontSize = 16.0,
      FontWeight fontWeight = FontWeight.bold,
      Duration duration = const Duration(seconds: 3),
    }) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  final screenWidth = MediaQuery.of(context).size.width;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: screenWidth * 0.2,
        right: screenWidth * 0.2,
        child: Material(
          color: Colors.transparent,
          child: SlideDownSnackBar(
            message: message,
            backgroundColor: backgroundColor,
            icon: icon,
            iconSize: iconSize,
            fontSize: fontSize,
            fontWeight: fontWeight,
            onDismiss: () => overlayEntry.remove(),
            duration: duration,
          ),
        ),
      );
    },
  );

  overlay.insert(overlayEntry);
}

class SlideDownSnackBar extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData? icon;
  final double iconSize;
  final double fontSize;
  final FontWeight fontWeight;
  final VoidCallback onDismiss;
  final Duration duration;

  const SlideDownSnackBar({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.onDismiss,
    this.icon,
    this.iconSize = 24.0,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.bold,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<SlideDownSnackBar> createState() => _SlideDownSnackBarState();
}

class _SlideDownSnackBarState extends State<SlideDownSnackBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeAnimation = CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    );

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _progressAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_progressController)
      ..addListener(() {
        setState(() {});
      });

    _slideController.forward();
    _progressController.forward();

    Future.delayed(widget.duration, () {
      _slideController.reverse().then((_) {
        widget.onDismiss();
      });
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 8),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (widget.icon != null)
                      Icon(widget.icon, color: Colors.white, size: widget.iconSize),
                    if (widget.icon != null) const SizedBox(width: 10),
                    Expanded(
                      child: Center(
                        child: CustomText(
                          text: widget.message,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
