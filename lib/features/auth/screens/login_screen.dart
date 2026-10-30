import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/widgets/resource_view.dart';
import '../providers/session_provider.dart';
import '../../catalog/services/student_api.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool register;
  const LoginScreen({super.key, this.register = false});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final year = TextEditingController();
  String? university, faculty, major, error;
  bool busy = false, obscure = true;
  @override
  void dispose() {
    for (final c in [email, password, name, year]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    if (widget.register &&
        (university == null || faculty == null || major == null)) {
      setState(
        () => error =
            'Choose your university, faculty, and major before registering.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).authenticate({
        'email': email.text.trim(),
        'password': password.text,
        if (widget.register) ...{
          'roleName': 'STUDENT',
          'fullName': name.text.trim(),
          'universityId': university,
          'facultyId': faculty,
          'majorId': major,
          'academicYear': year.text.trim(),
        },
      }, register: widget.register);
    } catch (e) {
      if (mounted) setState(() => error = readableError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget education(
    String path,
    String label,
    String nameKey,
    String? value,
    bool Function(Json) filter,
    void Function(String?) changed,
  ) {
    final resource = ref.watch(resourceProvider(path));
    return ResourceView(
      value: resource,
      retry: () => ref.invalidate(resourceProvider(path)),
      builder: (data) {
        final items = (data as List).cast<Json>().where(filter).toList();
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: DropdownButtonFormField<String>(
            key: ValueKey('$path-$university-$faculty'),
            initialValue: value,
            isExpanded: true,
            decoration: InputDecoration(labelText: label),
            items: items
                .map(
                  (e) => DropdownMenuItem(
                    value: textValue(e['id']),
                    child: Text(
                      textValue(e[nameKey]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: busy ? null : changed,
            validator: (v) => v == null ? 'Select $label' : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: AutofillGroup(
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      widget.register ? 'JOIN THE COMMUNITY' : 'WELCOME BACK',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.register
                          ? 'Create your student account'
                          : 'Good to see you again.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.register
                          ? 'Your academic details help you find relevant opportunities.'
                          : 'Sign in to continue your student journey.',
                    ),
                    const SizedBox(height: 28),
                    if (widget.register) ...[
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                        validator: (v) =>
                            (v?.trim().length ?? 0) < 2 || v!.length > 150
                            ? 'Enter a name of 2–150 characters'
                            : null,
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextFormField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'University email',
                      ),
                      validator: (v) =>
                          !RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch(v?.trim() ?? '')
                          ? 'Enter a valid email address'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: password,
                      obscureText: obscure,
                      autofillHints: [
                        widget.register
                            ? AutofillHints.newPassword
                            : AutofillHints.password,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          tooltip: obscure ? 'Show password' : 'Hide password',
                          onPressed: () => setState(() => obscure = !obscure),
                          icon: Icon(
                            obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          (v?.length ?? 0) < (widget.register ? 8 : 1)
                          ? (widget.register
                                ? 'Use at least 8 characters'
                                : 'Enter your password')
                          : utf8.encode(v!).length > 72
                          ? 'Use at most 72 UTF-8 bytes'
                          : null,
                      onFieldSubmitted: (_) {
                        if (!busy) submit();
                      },
                    ),
                    const SizedBox(height: 20),
                    if (widget.register) ...[
                      education(
                        '/universities',
                        'University',
                        'universityName',
                        university,
                        (_) => true,
                        (v) => setState(() {
                          university = v;
                          faculty = null;
                          major = null;
                        }),
                      ),
                      if (university != null)
                        education(
                          '/faculties',
                          'Faculty',
                          'facultyName',
                          faculty,
                          (e) => textValue(e['universityId']) == university,
                          (v) => setState(() {
                            faculty = v;
                            major = null;
                          }),
                        ),
                      if (faculty != null)
                        education(
                          '/majors',
                          'Major',
                          'majorName',
                          major,
                          (e) => textValue(e['facultyId']) == faculty,
                          (v) => setState(() => major = v),
                        ),
                      TextFormField(
                        controller: year,
                        maxLength: 50,
                        decoration: const InputDecoration(
                          labelText: 'Academic year (optional)',
                        ),
                      ),
                    ],
                    if (error != null ||
                        ref.read(sessionProvider.notifier).message != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          error ?? ref.read(sessionProvider.notifier).message!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          semanticsLabel: error,
                        ),
                      ),
                    FilledButton(
                      onPressed: busy ? null : submit,
                      child: busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.register
                                  ? 'Create student account'
                                  : 'Sign in',
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => context.go(
                              widget.register ? '/login' : '/register',
                            ),
                      child: Text(
                        widget.register
                            ? 'Already registered? Sign in'
                            : 'Create a student account',
                      ),
                    ),
                    if (!widget.register)
                      TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Password recovery'),
                            content: const Text(
                              'Password recovery is not available through the current API. Contact your platform administrator for account assistance.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => context.pop(),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        ),
                        child: const Text('Forgot password?'),
                      ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/figma_cap.svg',
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'One campus. More possibilities.\nYour registrations and applications stay together.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
