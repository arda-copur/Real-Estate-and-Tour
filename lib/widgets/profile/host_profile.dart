import 'package:flutter/material.dart';

class HostProfile extends StatelessWidget {
  final String name;
  final String image;

  const HostProfile({
    Key? key,
    required this.name,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          backgroundColor: Colors.grey[300],
          child: image.isEmpty
              ? const Icon(
                  Icons.person,
                  color: Colors.grey,
                )
              : null,
          onBackgroundImageError: (_, __) => {},
        ),
        const SizedBox(width: 6),
        Text(
          'Ev sahibi: $name',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
