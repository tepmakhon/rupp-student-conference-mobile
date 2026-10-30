import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/widgets/resource_view.dart';
import '../../catalog/services/student_api.dart';
import '../../catalog/widgets/content_card.dart';
import '../widgets/greeting_card.dart';
import '../widgets/search_bar_widget.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget section(String title, String path, bool event) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go(event ? '/events' : '/opportunities'),
              child: const Text('See all'),
            ),
          ],
        ),
        ResourceView(
          value: ref.watch(resourceProvider(path)),
          retry: () => ref.invalidate(resourceProvider(path)),
          builder: (data) {
            var items = (data as List).cast<Json>();
            if (event) {
              items =
                  items
                      .where(
                        (e) =>
                            DateTime.tryParse(
                              textValue(e['eventDate']),
                            )?.isAfter(DateTime.now()) ??
                            false,
                      )
                      .toList()
                    ..sort(
                      (a, b) => textValue(
                        a['eventDate'],
                      ).compareTo(textValue(b['eventDate'])),
                    );
            }
            return Column(
              children: [
                if (items.isEmpty)
                  EmptyState(
                    event
                        ? 'No upcoming events yet. Check back soon.'
                        : 'New opportunities will appear here.',
                  ),
                ...items.take(3).map((e) => ContentCard(item: e, event: event)),
              ],
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('RUPP CONNECT'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.go('/notifications'),
            icon: SvgPicture.asset(
              'assets/icons/figma_bell.svg',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await refreshResources(ref, [
              '/profile/me',
              '/events/approved',
              '/opportunities',
            ]);
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ResourceView(
                value: ref.watch(resourceProvider('/profile/me')),
                retry: () => ref.invalidate(resourceProvider('/profile/me')),
                builder: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GreetingCard(
                      fullName: textValue(
                        data['profile']?['fullName'],
                        'Student',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (data['student']?['major']?['majorName'] != null)
                      Text(textValue(data['student']['major']['majorName'])),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Text(
                          '${data['statistics']?['totalRegistrations'] ?? 0} registrations',
                        ),
                        Text(
                          '${data['statistics']?['savedOpportunities'] ?? 0} saved opportunities',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'What will you discover today?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              const SearchBarWidget(),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go('/events'),
                    icon: const Icon(Icons.search),
                    label: const Text('Find events'),
                  ),
                  OutlinedButton(
                    onPressed: () => context.go('/opportunities'),
                    child: const Text('Find opportunities'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              section('Upcoming events', '/events/approved', true),
              section('Opportunities for you', '/opportunities', false),
            ],
          ),
        ),
      ),
    );
  }
}
