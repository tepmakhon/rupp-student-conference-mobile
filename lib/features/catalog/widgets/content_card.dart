import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../services/student_api.dart';

class ContentImage extends StatelessWidget {
  final String? url;
  final bool event;
  const ContentImage({super.key, this.url, required this.event});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 172,
    width: double.infinity,
    child: (url ?? '').isEmpty
        ? fallback()
        : CachedNetworkImage(
            imageUrl: url!,
            fit: BoxFit.cover,
            placeholder: (_, _) => fallback(),
            errorWidget: (_, _, _) => fallback(),
          ),
  );
  Widget fallback() => ColoredBox(
    color: const Color(0xffe7f0ec),
    child: Center(
      child: Icon(
        event ? Icons.groups_outlined : Icons.school_outlined,
        size: 56,
        color: const Color(0xff0f4c3a),
      ),
    ),
  );
}

class ContentCard extends StatelessWidget {
  final Json item;
  final bool event;
  const ContentCard({super.key, required this.item, required this.event});
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 20),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () =>
          context.push('/${event ? 'events' : 'opportunities'}/${item['id']}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ContentImage(
            url: item[event ? 'bannerImageUrl' : 'coverImageUrl'] as String?,
            event: event,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  textValue(
                    item[event ? 'category' : 'type']?[event
                        ? 'categoryName'
                        : 'typeName'],
                    event ? 'Event' : 'Opportunity',
                  ),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  textValue(item['title']),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  textValue(
                    item['organization']?['organizationName'],
                    'Organizer not specified',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${event ? '' : 'Apply by '}${localDate(item[event ? 'eventDate' : 'deadline'], time: event)}',
                ),
                if (event) ...[
                  const SizedBox(height: 8),
                  Text(textValue(item['location'])),
                ],
                const SizedBox(height: 14),
                Text(
                  event ? 'View event' : 'View opportunity',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
