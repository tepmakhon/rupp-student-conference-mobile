import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/resource_view.dart';
import '../services/student_api.dart';
import '../widgets/content_card.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final String id;
  final bool event;
  const DetailScreen({super.key, required this.id, required this.event});
  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool busy = false, applied = false;
  String? error, success;
  String get path =>
      '/${widget.event ? 'events' : 'opportunities'}/${widget.id}';
  Future<void> action(
    String suffix, {
    String method = 'POST',
    Json? data,
  }) async {
    setState(() {
      busy = true;
      error = null;
      success = null;
    });
    try {
      await ref
          .read(studentApiProvider)
          .mutate('$path/$suffix', method: method, data: data);
      if (!mounted) return;
      setState(() {
        success = suffix == 'register'
            ? 'Registration confirmed. View your registration in My events.'
            : suffix == 'apply'
            ? 'Application submitted successfully.'
            : method == 'DELETE'
            ? 'Removed from saved opportunities.'
            : 'Opportunity saved.';
        if (suffix == 'apply') applied = true;
      });
      for (final p in [
        path,
        '/events/my-registrations',
        '/opportunities/saved/list',
        '/profile/me',
        '/notifications',
        '/applications/me',
      ]) {
        ref.invalidate(resourceProvider(p));
      }
    } catch (e) {
      if (mounted) setState(() => error = readableError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> register() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm registration'),
        content: const Text(
          'Register with your student account for this event?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            child: const Text('Register'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await action('register');
  }

  Future<void> apply() async {
    final cv = TextEditingController();
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply for opportunity'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Submit your application to the organizer. A CV link is optional.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: cv,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(
                    labelText: 'CV URL (optional)',
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final u = Uri.tryParse(v.trim());
                    return u != null &&
                            u.hasAuthority &&
                            ['http', 'https'].contains(u.scheme)
                        ? null
                        : 'Enter a valid HTTP or HTTPS URL';
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) context.pop(cv.text.trim());
            },
            child: const Text('Submit application'),
          ),
        ],
      ),
    );
    // Controllers remain alive until the dialog's dismissal animation completes.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    cv.dispose();
    if (result != null && mounted) {
      await action('apply', data: {'cvUrl': result});
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = widget.event
        ? '/events/my-registrations'
        : '/opportunities/saved/list';
    final membership = ref.watch(resourceProvider(collection));
    final applications = widget.event
        ? const AsyncData<dynamic>(<dynamic>[])
        : ref.watch(resourceProvider('/applications/me'));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event ? 'Event details' : 'Opportunity details'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(resourceProvider(collection));
            if (!widget.event) {
              ref.invalidate(resourceProvider('/applications/me'));
            }
            await refreshResources(ref, [path]);
          },
          child: ListView(
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ResourceView(
                value: ref.watch(resourceProvider(path)),
                retry: () => ref.invalidate(resourceProvider(path)),
                builder: (data) {
                  final item = Map<String, dynamic>.from(data as Map);
                  final matches = (membership.valueOrNull as List? ?? []).where(
                    (e) =>
                        textValue(
                              e[widget.event ? 'eventId' : 'opportunityId'],
                            ) ==
                            widget.id &&
                        (!widget.event ||
                            e['registrationStatus'] != 'CANCELLED'),
                  );
                  final joined = matches.isNotEmpty;
                  final cancelled =
                      widget.event &&
                      (membership.valueOrNull as List? ?? []).any(
                        (e) =>
                            textValue(e['eventId']) == widget.id &&
                            e['registrationStatus'] == 'CANCELLED',
                      );
                  final alreadyApplied =
                      (applications.valueOrNull as List? ?? []).any(
                        (e) => textValue(e['opportunityId']) == widget.id,
                      );
                  final date = DateTime.tryParse(
                    textValue(item[widget.event ? 'eventDate' : 'deadline']),
                  );
                  final past = date?.isBefore(DateTime.now()) ?? false;
                  final full =
                      widget.event &&
                      item['capacity'] != null &&
                      (item['_count']?['registrations'] ?? 0) >=
                          item['capacity'];
                  final unavailable =
                      item['status'] != 'APPROVED' || past || full;
                  final stateLabel = cancelled
                      ? 'Your registration was cancelled. Contact the organizer to register again.'
                      : joined && widget.event
                      ? 'Already registered'
                      : past
                      ? (widget.event
                            ? 'Event has ended'
                            : 'Deadline has passed')
                      : full
                      ? 'Event is full'
                      : item['status'] != 'APPROVED'
                      ? 'Currently unavailable'
                      : null;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: ContentImage(
                          url:
                              item[widget.event
                                      ? 'bannerImageUrl'
                                      : 'coverImageUrl']
                                  as String?,
                          event: widget.event,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        textValue(item['title']),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        textValue(item['organization']?['organizationName']),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        textValue(
                          item[widget.event ? 'category' : 'type']?[widget.event
                              ? 'categoryName'
                              : 'typeName'],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${widget.event ? 'When' : 'Deadline'}: ${localDate(item[widget.event ? 'eventDate' : 'deadline'], time: true)} (local time)',
                      ),
                      if (widget.event) ...[
                        const SizedBox(height: 12),
                        Text('Where: ${textValue(item['location'])}'),
                        const SizedBox(height: 12),
                        Text('Capacity: ${item['capacity'] ?? 'Not limited'}'),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      SelectableText(textValue(item['description'])),
                      if (!widget.event) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Eligibility & requirements',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        SelectableText(
                          textValue(
                            item['requirements'],
                            'Contact the organizer for requirements.',
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Apply using your student account. Include a public CV link if you wish. The organizer reviews applications on the platform.',
                        ),
                        ...RegExp(r'https?://[^\s<>]+')
                            .allMatches(
                              '${item['description']} ${item['requirements']}',
                            )
                            .map(
                              (m) => TextButton.icon(
                                onPressed: () async {
                                  try {
                                    final opened = await launchUrl(
                                      Uri.parse(m.group(0)!),
                                      mode: LaunchMode.externalApplication,
                                    );
                                    if (!opened && mounted) {
                                      setState(
                                        () =>
                                            error = 'Unable to open this link.',
                                      );
                                    }
                                  } catch (_) {
                                    if (mounted) {
                                      setState(
                                        () =>
                                            error = 'Unable to open this link.',
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.open_in_new),
                                label: Text(
                                  m.group(0)!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                      ],
                      const SizedBox(height: 24),
                      if (stateLabel != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            stateLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            error!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      if (success != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            success!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      if (!widget.event && applications.hasError)
                        ResourceView(
                          value: applications,
                          retry: () => ref.invalidate(
                            resourceProvider('/applications/me'),
                          ),
                          builder: (_) => const SizedBox.shrink(),
                        ),
                      if (membership.hasError)
                        ResourceView(
                          value: membership,
                          retry: () =>
                              ref.invalidate(resourceProvider(collection)),
                          builder: (_) => const SizedBox.shrink(),
                        ),
                      FilledButton(
                        onPressed:
                            busy ||
                                unavailable ||
                                cancelled ||
                                (widget.event && joined) ||
                                applied ||
                                alreadyApplied ||
                                (!widget.event && !applications.hasValue) ||
                                !membership.hasValue
                            ? null
                            : widget.event
                            ? register
                            : apply,
                        child: Text(
                          busy
                              ? 'Please wait…'
                              : widget.event
                              ? (cancelled
                                    ? 'Registration cancelled'
                                    : joined
                                    ? 'Registered'
                                    : 'Register for event')
                              : (applied || alreadyApplied)
                              ? 'Application submitted'
                              : 'Apply now',
                        ),
                      ),
                      if (!widget.event) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed:
                              busy ||
                                  !membership.hasValue ||
                                  (!joined && unavailable)
                              ? null
                              : () => action(
                                  'save',
                                  method: joined ? 'DELETE' : 'POST',
                                ),
                          icon: Icon(
                            joined ? Icons.bookmark : Icons.bookmark_border,
                          ),
                          label: Text(
                            joined
                                ? 'Remove saved opportunity'
                                : 'Save opportunity',
                          ),
                        ),
                      ],
                      if (widget.event && joined) ...[
                        OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/events/${widget.id}/ticket'),
                          icon: const Icon(Icons.qr_code),
                          label: const Text('View ticket'),
                        ),
                        TextButton(
                          onPressed: () => context.push('/my-events'),
                          child: const Text('View My events'),
                        ),
                        const Text(
                          'Your registration is recorded by the platform. Present your ticket at the event.',
                        ),
                      ],
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
