import 'package:flutter/material.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class TaskCardSkeleton extends StatelessWidget {
  const TaskCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ShimmerLoading(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerBox(width: 55, height: 18, borderRadius: 6),
                  ShimmerBox(width: 60, height: 18, borderRadius: 12),
                ],
              ),
              const SizedBox(height: 12),
              const ShimmerBox(width: 200, height: 16, borderRadius: 4),
              const SizedBox(height: 8),
              const ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  ShimmerBox(width: 90, height: 24, borderRadius: 20),
                  ShimmerBox(width: 80, height: 12, borderRadius: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
