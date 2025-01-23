import 'package:flutter/material.dart';

class TagList extends StatelessWidget {
  final List<String> tags;
  final Function(String) onRemoveTag;

  const TagList({
    Key? key,
    required this.tags,
    required this.onRemoveTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: tags.map((tag) {
        return Chip(
          label: Text(tag),
          deleteIcon: const Icon(Icons.close),
          onDeleted: () => onRemoveTag(tag),
        );
      }).toList(),
    );
  }
}