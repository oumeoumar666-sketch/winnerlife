import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/winnerlife_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WinnerLifeProvider>().markNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications WinnerLife'),
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('Aucune notification pour le moment.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: notif['isRead'] == false ? 2 : 0,
                  color: notif['isRead'] == false ? Colors.purple.withAlpha(15) : Colors.grey[50],
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(25),
                      child: Icon(Icons.notifications_active, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      notif['title'] as String,
                      style: TextStyle(
                        fontWeight: notif['isRead'] == false ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(notif['message'] as String),
                        const SizedBox(height: 6),
                        Text(
                          notif['time'] as String,
                          style: TextStyle(color: Colors.grey[600], fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
