import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/resource_view.dart';
import '../../catalog/services/student_api.dart';
import '../../auth/providers/session_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Your profile')),
    body: SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await refreshResources(ref, ['/profile/me']);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ResourceView(
              value: ref.watch(resourceProvider('/profile/me')),
              retry: () => ref.invalidate(resourceProvider('/profile/me')),
              builder: (data) {
                final profile = data['profile'] as Map? ?? {};
                final student = data['student'] as Map? ?? {};
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ClipOval(
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: textValue(profile['profileImageUrl']).isEmpty
                              ? const ColoredBox(
                                  color: Color(0xffe7f0ec),
                                  child: Icon(Icons.school_outlined, size: 40),
                                )
                              : Image.network(
                                  textValue(profile['profileImageUrl']),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.person_outline,
                                    size: 40,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      textValue(profile['fullName'], 'Student'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(textValue(data['email']), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    for (final detail in [
                      student['university']?['universityName'],
                      student['faculty']?['facultyName'],
                      student['major']?['majorName'],
                    ])
                      if (textValue(detail).isNotEmpty) Text(textValue(detail)),
                    Text(
                      'Academic year: ${textValue(student['academicYear'], 'Not specified')}',
                    ),
                    const SizedBox(height: 16),
                    if (textValue(profile['bio']).isNotEmpty)
                      Text(textValue(profile['bio'])),
                    const SizedBox(height: 12),
                    Text(
                      'Phone: ${textValue(profile['phoneNumber'], 'Not specified')}',
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => context.push('/edit-profile'),
                      child: const Text('Edit profile'),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Text(
                          '${data['statistics']?['totalRegistrations'] ?? 0} registrations',
                        ),
                        Text(
                          '${data['statistics']?['totalApplications'] ?? 0} applications',
                        ),
                        Text(
                          '${data['statistics']?['savedOpportunities'] ?? 0} saved',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.event_available),
                    title: const Text('My events'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/my-events'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline),
                    title: const Text('Saved opportunities'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/saved'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About RUPP Connect'),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'RUPP Connect',
                      applicationVersion: '1.0.0',
                      children: const [
                        Text(
                          'Student Conference & Opportunity Platform\nEvent times follow your device timezone. Account recovery is managed by your platform administrator.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Log out?'),
                    content: const Text(
                      'Your saved opportunities and registrations remain in your account.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => context.pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => context.pop(true),
                        child: const Text('Log out'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(sessionProvider.notifier).logout();
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    ),
  );
}
