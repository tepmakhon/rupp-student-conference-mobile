import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';

class ResourceView extends StatelessWidget {
  final AsyncValue<dynamic> value;
  final Widget Function(dynamic) builder;
  final VoidCallback retry;
  const ResourceView({
    super.key,
    required this.value,
    required this.builder,
    required this.retry,
  });
  @override
  Widget build(BuildContext context) => value.when(
    loading: () => const Padding(
      padding: EdgeInsets.all(32),
      child: Center(child: CircularProgressIndicator()),
    ),
    error: (e, _) => Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined),
            const SizedBox(height: 12),
            Text(readableError(e)),
            TextButton(onPressed: retry, child: const Text('Retry')),
          ],
        ),
      ),
    ),
    data: (data) => data == null ? const SizedBox.shrink() : builder(data),
  );
}

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState(this.message, {super.key});
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
