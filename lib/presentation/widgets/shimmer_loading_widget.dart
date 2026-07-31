import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Componente de carga tipo Shimmer (efecto esqueleto parpadeante)
class ShimmerLoadingWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoadingWidget({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<ShimmerLoadingWidget> createState() => _ShimmerLoadingWidgetState();
}

class _ShimmerLoadingWidgetState extends State<ShimmerLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEBEBF4);
    final highlightColor = isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F5FA);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1.0, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Lista de tarjetas de carga tipo esqueleto para feeds y listas sociales.
class ShimmerListLoading extends StatelessWidget {
  final int itemCount;

  const ShimmerListLoading({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            boxShadow: AppTheme.softShadow,
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerLoadingWidget(width: 44, height: 44, borderRadius: 22),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoadingWidget(width: 130, height: 14, borderRadius: 4),
                      SizedBox(height: 6),
                      ShimmerLoadingWidget(width: 80, height: 10, borderRadius: 4),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              ShimmerLoadingWidget(width: double.infinity, height: 14, borderRadius: 4),
              SizedBox(height: 8),
              ShimmerLoadingWidget(width: double.infinity, height: 14, borderRadius: 4),
              SizedBox(height: 8),
              ShimmerLoadingWidget(width: 180, height: 14, borderRadius: 4),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerLoadingWidget(width: 70, height: 24, borderRadius: 12),
                  ShimmerLoadingWidget(width: 70, height: 24, borderRadius: 12),
                  ShimmerLoadingWidget(width: 70, height: 24, borderRadius: 12),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
