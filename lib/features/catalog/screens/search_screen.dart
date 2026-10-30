import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/resource_view.dart';
import '../services/student_api.dart';
import '../widgets/content_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;
  const SearchScreen({super.key, this.initialQuery = ''});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final controller = TextEditingController(text: widget.initialQuery);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget section(String path, bool event) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          event ? 'Events' : 'Opportunities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ResourceView(
          value: ref.watch(resourceProvider(path)),
          retry: () => ref.invalidate(resourceProvider(path)),
          builder: (data) {
            final items = (data as List)
                .cast<Json>()
                .where(
                  (e) =>
                      '${e['title']} ${e['description']} ${e['organization']?['organizationName']}'
                          .toLowerCase()
                          .contains(controller.text.trim().toLowerCase()),
                )
                .toList();
            return Column(
              children: [
                if (items.isEmpty)
                  const EmptyState('No matches. Try another search.'),
                ...items.map((e) => ContentCard(item: e, event: event)),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Search campus opportunities')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              refreshResources(ref, ['/events/approved', '/opportunities']),
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              TextField(
                controller: controller,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Search title or organization',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 24),
              section('/events/approved', true),
              section('/opportunities', false),
            ],
          ),
        ),
      ),
    );
  }
}
