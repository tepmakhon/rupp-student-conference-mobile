import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rupp_student_conference_mobile/features/events/providers/event_provider.dart';

import '../../profile/providers/profile_provider.dart';
import '../../profile/providers/profile_state.dart';

import '../widgets/greeting_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/section_title.dart';

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
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Builder(
        builder: (_) {
          switch (state.status) {
            case ProfileStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );

            case ProfileStatus.error:
              return Center(
                child: Text(
                  state.error ?? "Something went wrong",
                ),
              );

            case ProfileStatus.loaded:
              final profile = state.profile!;

              return SingleChildScrollView(
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

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [

                          Text(
                            "No upcoming events yet",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 8),

                          Text(
                            "Events from the backend will appear here.",
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const SectionTitle(
                      title: "Opportunities",
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
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
              );

            default:
              return const SizedBox();
          }
        },
      ),
    );
  }
}