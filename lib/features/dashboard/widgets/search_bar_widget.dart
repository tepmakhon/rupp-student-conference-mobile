import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});
  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void search() {
    context.push(
      '/search?q=${Uri.encodeQueryComponent(controller.text.trim())}',
    );
  }

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    textInputAction: TextInputAction.search,
    onSubmitted: (_) => search(),
    decoration: InputDecoration(
      labelText: 'Search events & opportunities',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: IconButton(
        tooltip: 'Search',
        onPressed: search,
        icon: const Icon(Icons.arrow_forward),
      ),
    ),
  );
}
