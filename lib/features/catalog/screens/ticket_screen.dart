import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/widgets/resource_view.dart';
import '../services/student_api.dart';

bool validTicket(dynamic data, String eventId) {
  if (data is! Map ||
      data['registrationId'] == null ||
      data['qrCode'] is! String) {
    return false;
  }
  try {
    final qr = jsonDecode(data['qrCode'] as String);
    return qr is Map &&
        RegExp(r'^[1-9]\d*$').hasMatch(textValue(data['registrationId'])) &&
        textValue(qr['eventId']) == eventId &&
        textValue(qr['registrationId']) == textValue(data['registrationId']) &&
        RegExp(r'^[1-9]\d*$').hasMatch(textValue(qr['studentId']));
  } catch (_) {
    return false;
  }
}

class TicketScreen extends ConsumerWidget {
  final String eventId;
  const TicketScreen({super.key, required this.eventId});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = '/events/$eventId/ticket';
    return Scaffold(
      appBar: AppBar(title: const Text('Your event ticket')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ResourceView(
              value: ref.watch(resourceProvider(path)),
              retry: () => ref.invalidate(resourceProvider(path)),
              builder: (data) {
                if (!validTicket(data, eventId)) {
                  return const EmptyState(
                    'A valid ticket is not available. Please contact the organizer.',
                  );
                }
                return ResourceView(
                  value: ref.watch(
                    resourceProvider('/events/my-registrations'),
                  ),
                  retry: () => ref.invalidate(
                    resourceProvider('/events/my-registrations'),
                  ),
                  builder: (registrations) {
                    final approved = (registrations as List).any(
                      (e) =>
                          textValue(e['id']) ==
                              textValue(data['registrationId']) &&
                          textValue(e['eventId']) == eventId &&
                          e['registrationStatus'] == 'APPROVED' &&
                          e['event']?['status'] == 'APPROVED',
                    );
                    if (!approved) {
                      return const EmptyState(
                        'This registration is not approved or the event is unavailable. A ticket cannot be displayed.',
                      );
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              textValue(data['eventTitle']),
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            Text(textValue(data['studentName'])),
                            Text(textValue(data['organization'])),
                            Text(textValue(data['location'])),
                            Text(localDate(data['eventDate'], time: true)),
                            const SizedBox(height: 24),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 260,
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: QrImageView(
                                    data: data['qrCode'] as String,
                                    backgroundColor: Colors.white,
                                    semanticsLabel: 'Event admission QR code',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Registration #${data['registrationId']}',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Present this ticket to the event organizer. Keep your QR code private.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
