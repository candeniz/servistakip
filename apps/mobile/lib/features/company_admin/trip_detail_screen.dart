import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/demo_data.dart';
import '../../providers/data_providers.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/passenger_row.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stop_timeline.dart';
import '../../widgets/trip_status_card.dart';

/// Servis detayı (yolcular + durak zaman çizelgesi).
class TripDetailScreen extends ConsumerWidget {
  const TripDetailScreen({super.key, required this.tripId});
  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider(tripId));
    final passengers = ref.watch(tripPassengersProvider(tripId));

    return AppScaffold(
      title: 'Servis Detayı',
      children: [
        trip.when(
          loading: () => const Padding(padding: EdgeInsets.all(40), child: LoadingState()),
          error: (e, _) => ErrorStateView(onRetry: () => ref.refresh(tripProvider(tripId))),
          data: (t) => Column(children: [
            TripStatusCard(trip: t),
            const SizedBox(height: AppSpacing.md),
            Align(alignment: Alignment.centerLeft, child: Text('DURAKLAR', style: AppText.label)),
            const SizedBox(height: AppSpacing.sm),
            AppCard(child: StopTimeline(stops: demoStops, nextStopIndex: 1)),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: passengers.maybeWhen(
                data: (list) => Text('YOLCULAR (${list.length})', style: AppText.label),
                orElse: () => Text('YOLCULAR', style: AppText.label),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            passengers.when(
              loading: () => const LoadingState(),
              error: (e, _) => const SizedBox.shrink(),
              data: (list) => Column(children: [
                for (final p in list)
                  Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: PassengerRow(passenger: p)),
              ]),
            ),
          ]),
        ),
      ],
    );
  }
}
