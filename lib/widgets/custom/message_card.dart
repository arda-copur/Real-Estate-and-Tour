import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final String hostName;
  final String hostImage;
  final String propertyName;
  final String lastMessage;
  final String time;
  final bool unread;
  final VoidCallback onTap;

  const MessageCard({
    Key? key,
    required this.hostName,
    required this.hostImage,
    required this.propertyName,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: unread ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: hostImage.startsWith('assets/')
                  ? AssetImage(hostImage)
                  : NetworkImage(hostImage) as ImageProvider,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hostName,
                        style: TextStyle(
                          fontWeight: unread ? FontWeight.bold : FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    propertyName,
                    style: TextStyle(
                      fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                      color: Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(
                      color: unread ? Colors.black87 : Colors.grey.shade600,
                      fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (unread)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
