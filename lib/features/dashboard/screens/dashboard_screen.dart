import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../events/providers/event_provider.dart';
import '../../events/providers/event_state.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/providers/profile_state.dart';

import '../widgets/greeting_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/section_title.dart';
import '../../events/widgets/event_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
      ref.read(eventProvider.notifier).loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final eventState = ref.watch(eventProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Builder(
        builder: (_) {
          switch (profileState.status) {
            case ProfileStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case ProfileStatus.error:
              return Center(
                child: Text(
                  profileState.error ??
                      "Something went wrong",
                ),
              );

            case ProfileStatus.loaded:
              final profile = profileState.profile!;

              return RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(profileProvider.notifier)
                      .loadProfile();

                  await ref
                      .read(eventProvider.notifier)
                      .loadEvents();
                },
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      GreetingCard(
                        fullName: profile.fullName,
                      ),

                      const SizedBox(height: 24),

                      const SearchBarWidget(),

                      const SizedBox(height: 32),

                      const SectionTitle(
                        title: "Upcoming Events",
                      ),

                      const SizedBox(height: 16),

                      if (eventState.status ==
                          EventStatus.loading)
                        const Center(
                          child:
                              CircularProgressIndicator(),
                        )
                      else if (eventState.status ==
                          EventStatus.error)
                        Center(
                          child: Text(
                            eventState.error ??
                                "Failed to load events",
                          ),
                        )
                      else if (eventState.events.isEmpty)
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(
                                    16),
                            border: Border.all(
                              color:
                                  Colors.grey.shade300,
                            ),
                          ),
                          child: const Text(
                            "No upcoming events.",
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          itemCount:
                              eventState.events.length,
                          itemBuilder:
                              (context, index) {
                            final event =
                                eventState.events[index];

                            return EventCard(
                              event: event,
                                onTap: () {
                                  // TODO:
                                  // Navigate to Event Detail
                                },
                            );
                          },
                        ),

                      const SizedBox(height: 32),

                      const SectionTitle(
                        title: "Opportunities",
                      ),

                      const SizedBox(height: 16),

                      Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(
                                  16),
                          border: Border.all(
                            color:
                                Colors.grey.shade300,
                          ),
                        ),
                        child: const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "No opportunities yet",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Scholarships, internships and competitions will appear here.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}