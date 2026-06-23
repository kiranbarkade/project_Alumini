import 'package:flutter/material.dart';

class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]!
        : Colors.grey[300]!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  // Pre-configured shimmers
  static Widget cardList({int count = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const LoadingShimmer(width: 40, height: 40, borderRadius: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LoadingShimmer(width: 120, height: 16),
                        const SizedBox(height: 6),
                        const LoadingShimmer(width: 80, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const LoadingShimmer(height: 14),
              const SizedBox(height: 8),
              const LoadingShimmer(width: 200, height: 14),
            ],
          ),
        ),
      ),
    );
  }

  static Widget profileShimmer() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const LoadingShimmer(width: 100, height: 100, borderRadius: 50),
          const SizedBox(height: 16),
          const LoadingShimmer(width: 180, height: 22),
          const SizedBox(height: 8),
          const LoadingShimmer(width: 120, height: 14),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: const LoadingShimmer(height: 45, borderRadius: 12)),
              const SizedBox(width: 16),
              Expanded(child: const LoadingShimmer(height: 45, borderRadius: 12)),
            ],
          ),
          const SizedBox(height: 32),
          const Align(
            alignment: Alignment.centerLeft,
            child: LoadingShimmer(width: 100, height: 18),
          ),
          const SizedBox(height: 12),
          const LoadingShimmer(height: 80, borderRadius: 12),
        ],
      ),
    );
  }
}
