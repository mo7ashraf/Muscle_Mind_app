import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/services/api_service.dart';
import '../models/measurement_model.dart';
import '../models/progress_photo_model.dart';
import '../providers/progress_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(progressPhotosProvider);
    final measAsync = ref.watch(measurementHistoryProvider);
    final dateFmt = DateFormat('yyyy-MM-dd');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Progress'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Photos'),
              Tab(text: 'Measurements'),
            ],
          ),
        ),
        floatingActionButton: Builder(
          builder: (ctx) {
            final tab = DefaultTabController.of(ctx);
            return FloatingActionButton.extended(
              onPressed: () {
                if (tab.index == 0) {
                  Navigator.of(context).pushNamed(AppRoutes.addProgress);
                } else {
                  Navigator.of(context).pushNamed(AppRoutes.addMeasurement);
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            );
          },
        ),
        body: TabBarView(
          children: [
            photosAsync.when(
              data: (paged) {
                if (paged.data.isEmpty) {
                  return const Center(child: Text('No progress photos yet.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: paged.data.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final item = paged.data[i];
                    return _ProgressPhotoCard(item: item, dateFmt: dateFmt);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(ApiService.messageFromError(e))),
            ),
            measAsync.when(
              data: (paged) {
                if (paged.data.isEmpty) {
                  return const Center(child: Text('No measurements yet.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: paged.data.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final m = paged.data[i];
                    return _MeasurementTile(m: m, dateFmt: dateFmt);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(ApiService.messageFromError(e))),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressPhotoCard extends StatelessWidget {
  const _ProgressPhotoCard({required this.item, required this.dateFmt});

  final ProgressPhotoModel item;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(dateFmt.format(item.takenAt)),
                const Spacer(),
                if (item.weight != null)
                  Text(
                    '${item.weight!.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
              ],
            ),
            if (item.notes != null && item.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(item.notes!.trim()),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _PhotoPreview(url: item.frontUrl, label: 'Front')),
                const SizedBox(width: 8),
                Expanded(child: _PhotoPreview(url: item.sideUrl, label: 'Side')),
                const SizedBox(width: 8),
                Expanded(child: _PhotoPreview(url: item.backUrl, label: 'Back')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.url, required this.label});

  final String? url;
  final String label;

  @override
  Widget build(BuildContext context) {
    final border = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: border.borderRadius,
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: url == null
                ? Container(
                    color: Colors.black12,
                    child: const Center(child: Icon(Icons.image_not_supported_outlined)),
                  )
                : CachedNetworkImage(
                    imageUrl: url!,
                    fit: BoxFit.cover,
                    placeholder: (context, _) => Container(
                      color: Colors.black12,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, _, __) => Container(
                      color: Colors.black12,
                      child: const Center(child: Icon(Icons.broken_image_outlined)),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _MeasurementTile extends StatelessWidget {
  const _MeasurementTile({required this.m, required this.dateFmt});

  final MeasurementModel m;
  final DateFormat dateFmt;

  @override
  Widget build(BuildContext context) {
    String fmt(double? v) => v == null ? '-' : v.toStringAsFixed(1);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      title: Text(dateFmt.format(m.measuredAt)),
      subtitle: Text(
        'Weight: ${fmt(m.weight)} | Chest: ${fmt(m.chest)} | Waist: ${fmt(m.waist)} | Hips: ${fmt(m.hips)}',
      ),
      trailing: Text('Arms ${fmt(m.arms)} / Thighs ${fmt(m.thighs)}'),
    );
  }
}
