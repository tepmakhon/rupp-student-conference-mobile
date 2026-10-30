import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/resource_view.dart';
import '../services/student_api.dart';
import '../widgets/content_card.dart';

class BrowseScreen extends ConsumerStatefulWidget {
  final bool event;
  const BrowseScreen({super.key, required this.event});
  @override
  ConsumerState<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends ConsumerState<BrowseScreen> {
  String query = '', category = 'All', date = 'All dates';
  @override
  Widget build(BuildContext context) {
    final path = widget.event ? '/events/approved' : '/opportunities';
    final resource = ref.watch(resourceProvider(path));
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.event ? 'Discover events' : 'Discover opportunities',
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await refreshResources(ref, [path]);
          },
          child: ListView(
            key: PageStorageKey(path),
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Text(
                widget.event
                    ? 'Learn beyond the classroom.'
                    : 'Your next chapter starts here.',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Search title or organization',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) =>
                    setState(() => query = v.toLowerCase().trim()),
              ),
              const SizedBox(height: 16),
              ResourceView(
                value: resource,
                retry: () => ref.invalidate(resourceProvider(path)),
                builder: (data) {
                  final all = (data as List).cast<Json>();
                  String type(Json e) => textValue(
                    e[widget.event ? 'category' : 'type']?[widget.event
                        ? 'categoryName'
                        : 'typeName'],
                  );
                  final types = {
                    'All',
                    ...all.map(type).where((s) => s.isNotEmpty),
                  };
                  final filtered = all.where((e) {
                    final matches =
                        '${e['title']} ${e['description']} ${e['organization']?['organizationName']}'
                            .toLowerCase()
                            .contains(query) &&
                        (category == 'All' || type(e) == category);
                    final d = DateTime.tryParse(
                      textValue(e['eventDate']),
                    )?.toLocal();
                    final now = DateTime.now();
                    return matches &&
                        (!widget.event ||
                            date == 'All dates' ||
                            (d != null &&
                                (date == 'Past'
                                    ? d.isBefore(now)
                                    : d.isAfter(now) &&
                                          (date != 'Next 7 days' ||
                                              d.isBefore(
                                                now.add(
                                                  const Duration(days: 7),
                                                ),
                                              )))));
                  }).toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: types
                            .map(
                              (t) => ChoiceChip(
                                label: Text(t),
                                selected: category == t,
                                onSelected: (_) => setState(() => category = t),
                              ),
                            )
                            .toList(),
                      ),
                      if (widget.event) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children:
                              ['All dates', 'Upcoming', 'Next 7 days', 'Past']
                                  .map(
                                    (t) => ChoiceChip(
                                      label: Text(t),
                                      selected: date == t,
                                      onSelected: (_) =>
                                          setState(() => date = t),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text('${filtered.length} results'),
                      const SizedBox(height: 12),
                      if (filtered.isEmpty)
                        const EmptyState(
                          'No matches. Try another search or filter.',
                        ),
                      ...filtered.map(
                        (e) => ContentCard(item: e, event: widget.event),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
