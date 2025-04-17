import 'package:flutter/material.dart';
import '../../models/support_ticket.dart';
import '../../services/data/data_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final DataService _dataService = DataService();
  late List<SupportTicket> _tickets;

  @override
  void initState() {
    super.initState();
    _tickets = _dataService.getSupportTickets();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Destek İletişimi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Destek Taleplerim'),
              Tab(text: 'Yeni Talep'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTicketsList(),
            _buildNewTicketForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsList() {
    if (_tickets.isEmpty) {
      return const Center(
        child: Text('Henüz destek talebiniz bulunmuyor.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(ticket.subject),
            subtitle: Text(
              '${_getStatusText(ticket.status)} · ${_formatDate(ticket.createdAt)}',
            ),
            trailing: _getStatusIcon(ticket.status),
            onTap: () {
              _showTicketDetail(ticket);
            },
          ),
        );
      },
    );
  }

  Widget _buildNewTicketForm() {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yeni Destek Talebi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Konu',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir konu girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Açıklama',
                border: OutlineInputBorder(),
                hintText: 'Sorununuzu detaylı bir şekilde açıklayın',
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen bir açıklama girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Yeni destek talebi oluştur
                    final newTicket = SupportTicket(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      subject: subjectController.text,
                      description: descriptionController.text,
                      status: TicketStatus.open,
                      createdAt: DateTime.now(),
                      messages: [
                        TicketMessage(
                          sender: 'Ahmet Yılmaz',
                          message: descriptionController.text,
                          timestamp: DateTime.now(),
                          isUser: true,
                        ),
                      ],
                    );

                    _dataService.addSupportTicket(newTicket);

                    setState(() {
                      _tickets = _dataService.getSupportTickets();
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Destek talebiniz başarıyla oluşturuldu'),
                        backgroundColor: Color(0xFFFF5A5F),
                      ),
                    );

                    // İlk sekmeye geç
                    DefaultTabController.of(context).animateTo(0);

                    // Form alanlarını temizle
                    subjectController.clear();
                    descriptionController.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Talebi Gönder',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDetail(SupportTicket ticket) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.6,
                minChildSize: 0.3,
                maxChildSize: 0.9,
                expand: false,
                builder: (context, scrollController) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ticket.subject,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _getStatusChip(ticket.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Oluşturulma: ${_formatDate(ticket.createdAt)}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: ticket.messages.length,
                          itemBuilder: (context, index) {
                            final message = ticket.messages[index];
                            return _buildMessageBubble(message);
                          },
                        ),
                      ),
                      if (ticket.status != TicketStatus.closed)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Mesajınızı yazın...',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send),
                                color: const Color(0xFFFF5A5F),
                                onPressed: () {
                                  if (messageController.text.isNotEmpty) {
                                    final newMessage = TicketMessage(
                                      sender: 'Ahmet Yılmaz',
                                      message: messageController.text,
                                      timestamp: DateTime.now(),
                                      isUser: true,
                                    );

                                    _dataService.addTicketMessage(
                                        ticket.id, newMessage);

                                    setState(() {
                                      messageController.clear();
                                    });

                                    this.setState(() {
                                      _tickets =
                                          _dataService.getSupportTickets();
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(TicketMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFFFF5A5F) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.sender,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: message.isUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: TextStyle(
                color: message.isUser ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: message.isUser ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'Açık';
      case TicketStatus.inProgress:
        return 'İşlemde';
      case TicketStatus.closed:
        return 'Kapalı';
    }
  }

  Icon _getStatusIcon(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return const Icon(Icons.fiber_new, color: Colors.green);
      case TicketStatus.inProgress:
        return const Icon(Icons.hourglass_bottom, color: Colors.orange);
      case TicketStatus.closed:
        return const Icon(Icons.check_circle, color: Colors.grey);
    }
  }

  Widget _getStatusChip(TicketStatus status) {
    Color color;
    String text = _getStatusText(status);

    switch (status) {
      case TicketStatus.open:
        color = Colors.green;
        break;
      case TicketStatus.inProgress:
        color = Colors.orange;
        break;
      case TicketStatus.closed:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
