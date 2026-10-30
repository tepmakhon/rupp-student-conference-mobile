import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/resource_view.dart';
import '../../catalog/services/student_api.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});
  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool busy = false;
  Future<void> read(String path) async {
    setState(() => busy = true);
    try {
      await ref.read(studentApiProvider).mutate(path, method: 'PATCH');
      ref.invalidate(resourceProvider('/notifications'));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(readableError(e))));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Notifications'),
      actions: [
        TextButton(
          onPressed: busy ? null : () => read('/notifications/read-all'),
          child: const Text('Read all'),
        ),
      ],
    ),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await refreshResources(ref, ['/notifications']);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ResourceView(
              value: ref.watch(resourceProvider('/notifications')),
              retry: () => ref.invalidate(resourceProvider('/notifications')),
              builder: (data) => Column(
                children: [
                  if ((data as List).isEmpty)
                    const EmptyState(
                      'You are all caught up. New notifications will appear here.',
                    ),
                  ...data.map((entry) {
                    final n = entry['notification'];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  entry['isRead'] == true
                                      ? Icons.notifications_none
                                      : Icons.mark_email_unread_outlined,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    textValue(n['title']),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(textValue(n['message'])),
                            const SizedBox(height: 8),
                            Text(localDate(n['createdAt'], time: true)),
                            Wrap(
                              spacing: 12,
                              children: [
                                if (entry['isRead'] != true)
                                  TextButton(
                                    onPressed: busy
                                        ? null
                                        : () => read(
                                            '/notifications/${entry['id']}/read',
                                          ),
                                    child: const Text('Mark as read'),
                                  ),
                                if (n['type'] == 'EVENT' ||
                                    n['type'] == 'OPPORTUNITY')
                                  TextButton(
                                    onPressed: () => context.go(
                                      n['type'] == 'EVENT'
                                          ? '/events'
                                          : '/opportunities',
                                    ),
                                    child: Text(
                                      n['type'] == 'EVENT'
                                          ? 'Browse events'
                                          : 'Browse opportunities',
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
