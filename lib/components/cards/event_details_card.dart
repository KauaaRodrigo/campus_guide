import 'package:flutter/material.dart';
import '../lists/user_list_item.dart';

class EventDetailsCard extends StatelessWidget {
  final String title;
  final String description;
  final String location;

  final int remainingVacancies;
  final bool isOpen;

  final List<Map<String, String>> speakers;

  final bool showVacancies;

  const EventDetailsCard({
    super.key,
    required this.title,
    required this.description,
    required this.location,
    required this.remainingVacancies,
    required this.isOpen,
    required this.speakers,

    this.showVacancies = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 24),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            children: [
              const Text(
                "Status: ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              Text(
                isOpen ? "Aberto" : "Fechado",
                style: TextStyle(
                  color: isOpen ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              if (showVacancies)
                Text(
                  "Restam $remainingVacancies vaga(s)",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
            ],
          ),

          const SizedBox(height: 20),

          Text(description, style: const TextStyle(height: 1.5, fontSize: 15)),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Local: ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              Expanded(child: Text(location)),
            ],
          ),

          const SizedBox(height: 30),

          const Center(
            child: Text(
              "Ministrantes",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          Column(
            children: speakers.map((speaker) {
              final name = speaker["name"] ?? speaker["nome"] ?? "";
              final image = speaker["image"] ?? speaker["imagem"] ?? "";

              return UserListItem(name: name, image: image);
            }).toList(),
          ),
        ],
      ),
    );
  }
}
