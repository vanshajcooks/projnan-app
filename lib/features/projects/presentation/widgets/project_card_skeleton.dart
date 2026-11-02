import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class ProjectCardSkeleton extends StatelessWidget {
  const ProjectCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: ShimmerLoading(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerBox(width: 160, height: 18, borderRadius: 6),
                  ShimmerBox(width: 60, height: 20, borderRadius: 12),
                ],
              ),
              const SizedBox(height: 12),
              const ShimmerBox(width: double.infinity, height: 13, borderRadius: 4),
              const SizedBox(height: 6),
              const ShimmerBox(width: 220, height: 13, borderRadius: 4),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerBox(width: 50, height: 11, borderRadius: 4),
                  ShimmerBox(width: 30, height: 11, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 8),
              const ShimmerBox(width: double.infinity, height: 6, borderRadius: 4),
              const SizedBox(height: 16),
              Row(
                children: const [
                  ShimmerBox(width: 80, height: 12, borderRadius: 4),
                  SizedBox(width: 16),
                  ShimmerBox(width: 90, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
