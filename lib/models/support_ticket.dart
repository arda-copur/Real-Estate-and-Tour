enum TicketStatus {
  open,
  inProgress,
  closed,
}

class TicketMessage {
  final String sender;
  final String message;
  final DateTime timestamp;
  final bool isUser;

  TicketMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isUser,
  });
}

class SupportTicket {
  final String id;
  final String subject;
  final String description;
  TicketStatus status;
  final DateTime createdAt;
  final List<TicketMessage> messages;

  SupportTicket({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.messages,
  });
}
