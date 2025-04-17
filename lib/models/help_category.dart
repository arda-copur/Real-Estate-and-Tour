import 'package:flutter/material.dart';

class HelpCategory {
  final String id;
  final String title;
  final IconData icon;
  final List<String> articles;

  HelpCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.articles,
  });
}
