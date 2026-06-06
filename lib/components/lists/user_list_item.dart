import 'package:flutter/material.dart';

class UserListItem extends StatelessWidget {
  final String name;
  final String image;

  const UserListItem({super.key, required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    final trimmedImage = image.trim();
    final ImageProvider? avatarImage = trimmedImage.isEmpty
        ? null
        : trimmedImage.startsWith('http')
        ? NetworkImage(trimmedImage)
        : AssetImage(trimmedImage);

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),

      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? const Icon(Icons.person, size: 34, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
