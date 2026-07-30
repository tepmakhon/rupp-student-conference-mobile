import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl:
                    event.bannerImageUrl ?? "",
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    const Center(
                  child:
                      CircularProgressIndicator(),
                ),
                errorWidget: (_, __, ___) =>
                    Container(
                  color: Colors.grey.shade200,
                  child: const Icon(
                    Icons.event,
                    size: 60,
                  ),
                ),
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.blue
                              .withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius
                                  .circular(20),
                        ),
                        child: Text(
                          event.categoryName,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      if (event.capacity != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.people,
                              size: 18,
                            ),
                            const SizedBox(
                                width: 4),
                            Text(
                              "${event.capacity}",
                            ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    event.title,
                    style: theme
                        .textTheme.titleLarge
                        ?.copyWith(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.business,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.organizationName,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat(
                          "dd MMM yyyy • HH:mm",
                        ).format(
                          event.eventDate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}