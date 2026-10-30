import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/resource_view.dart';
import '../services/student_api.dart';
import '../widgets/content_card.dart';

class CollectionScreen extends ConsumerWidget {
  final bool events;
  const CollectionScreen({super.key, required this.events});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = events
        ? '/events/my-registrations'
        : '/opportunities/saved/list';
    return Scaffold(
      appBar: AppBar(title: Text(events ? 'My events' : 'Saved opportunities')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await refreshResources(ref, [path]);
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ResourceView(
                value: ref.watch(resourceProvider(path)),
                retry: () => ref.invalidate(resourceProvider(path)),
                builder: (data) => Column(
                  children: [
                    if ((data as List).isEmpty)
                      EmptyState(
                        events
                            ? 'Your event registrations will appear here.'
                            : 'Save opportunities to find them here.',
                      ),
                    ...data.map(
                      (e) => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (events)
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'Registration: ${e['registrationStatus']}',
                              ),
                            ),
                          ContentCard(
                            item: Map<String, dynamic>.from(
                              e[events ? 'event' : 'opportunity'] as Map,
                            ),
                            event: events,
                          ),
                        ],
                      ),
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
