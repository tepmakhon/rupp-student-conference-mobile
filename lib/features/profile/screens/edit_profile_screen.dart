import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/resource_view.dart';
import '../../catalog/services/student_api.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      phone = TextEditingController(),
      bio = TextEditingController(),
      year = TextEditingController(),
      dob = TextEditingController(),
      imageUrl = TextEditingController();
  bool initialized = false, busy = false;
  String? error;
  String gender = '';
  @override
  void dispose() {
    for (final c in [name, phone, bio, year, dob, imageUrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(studentApiProvider)
          .mutate(
            '/profile/me',
            method: 'PUT',
            data: {
              'fullName': name.text.trim(),
              'phoneNumber': phone.text.trim(),
              'bio': bio.text.trim(),
              'academicYear': year.text.trim(),
              'gender': gender,
              'dateOfBirth': dob.text.trim().isEmpty ? null : dob.text.trim(),
              'profileImageUrl': imageUrl.text.trim(),
            },
          );
      ref.invalidate(resourceProvider('/profile/me'));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile updated.')));
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      }
    } catch (e) {
      if (mounted) setState(() => error = readableError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit profile')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ResourceView(
            value: ref.watch(resourceProvider('/profile/me')),
            retry: () => ref.invalidate(resourceProvider('/profile/me')),
            builder: (data) {
              if (!initialized) {
                name.text = textValue(data['profile']?['fullName']);
                phone.text = textValue(data['profile']?['phoneNumber']);
                bio.text = textValue(data['profile']?['bio']);
                year.text = textValue(data['student']?['academicYear']);
                gender = textValue(data['profile']?['gender']);
                dob.text = textValue(
                  data['profile']?['dateOfBirth'],
                ).split('T').first;
                imageUrl.text = textValue(data['profile']?['profileImageUrl']);
                initialized = true;
              }
              return Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: name,
                      maxLength: 150,
                      decoration: const InputDecoration(labelText: 'Full name'),
                      validator: (v) => (v?.trim().length ?? 0) < 2
                          ? 'Enter at least 2 characters'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: phone,
                      maxLength: 20,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                      ),
                      validator: (v) =>
                          v != null &&
                              v.isNotEmpty &&
                              !RegExp(r'^[+0-9() .-]+$').hasMatch(v)
                          ? 'Enter a valid phone number'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: gender,
                      decoration: const InputDecoration(
                        labelText: 'Gender (optional)',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '',
                          child: Text('Prefer not to say'),
                        ),
                        DropdownMenuItem(value: 'MALE', child: Text('Male')),
                        DropdownMenuItem(
                          value: 'FEMALE',
                          child: Text('Female'),
                        ),
                        DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                      ],
                      onChanged: busy
                          ? null
                          : (v) => setState(() => gender = v ?? ''),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: dob,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'Date of birth',
                        helperText: 'YYYY-MM-DD (optional)',
                        suffixIcon: IconButton(
                          tooltip: 'Choose date of birth',
                          onPressed: busy
                              ? null
                              : () async {
                                  final now = DateTime.now();
                                  final candidate =
                                      DateTime.tryParse(dob.text) ??
                                      DateTime(2005);
                                  final initial = candidate.isAfter(now)
                                      ? now
                                      : candidate.isBefore(DateTime(1900))
                                      ? DateTime(1900)
                                      : candidate;
                                  final value = await showDatePicker(
                                    context: context,
                                    initialDate: initial,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime.now(),
                                  );
                                  if (value != null) {
                                    dob.text =
                                        '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
                                  }
                                },
                          icon: const Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final d = DateTime.tryParse(v.trim());
                        return d == null ||
                                d.isAfter(DateTime.now()) ||
                                d.isBefore(DateTime(1900)) ||
                                '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}' !=
                                    v.trim()
                            ? 'Enter a valid date of birth'
                            : null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: imageUrl,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Profile image URL (optional)',
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: year,
                      maxLength: 50,
                      decoration: const InputDecoration(
                        labelText: 'Academic year',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: bio,
                      maxLength: 1000,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(labelText: 'About you'),
                    ),
                    const SizedBox(height: 20),
                    if (error != null)
                      Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    FilledButton(
                      onPressed: busy ? null : save,
                      child: Text(busy ? 'Saving…' : 'Save changes'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
