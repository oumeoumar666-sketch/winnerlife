import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/winnerlife_provider.dart';
import '../widgets/task_card.dart';
import '../services/facebook_meta_service.dart';
import 'facebook_boost_dialog.dart';

class MissionDetailScreen extends StatelessWidget {
  final Mission mission;

  const MissionDetailScreen({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();

    final currentMission = provider.missions.firstWhere(
      (m) => m.id == mission.id,
      orElse: () => mission,
    );

    final missionTasks = provider.tasks.where((t) => t.missionId == currentMission.id).toList();
    final linkedAssets = provider.assets.where((a) => currentMission.assetIds.contains(a.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMission.companyName),
        actions: [
          PopupMenuButton<MissionStatus>(
            onSelected: (status) {
              context.read<WinnerLifeProvider>().updateMissionStatus(currentMission.id, status);
            },
            itemBuilder: (context) {
              return MissionStatus.values.map((status) {
                return PopupMenuItem(
                  value: status,
                  child: Text('Changer statut: ${status.label}'),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge & Title
            Row(
              children: [
                Expanded(
                  child: Text(
                    currentMission.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  label: Text(
                    currentMission.status.label,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(currentMission.status),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Objectif de la mission',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(currentMission.objective),
                    const Divider(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(currentMission.description),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Budget Alloué', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              '\$${currentMission.budget.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Période d\'exécution', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            Text(
                              '${currentMission.startDate.day}/${currentMission.startDate.month} - ${currentMission.endDate.day}/${currentMission.endDate.month}/${currentMission.endDate.year}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => FacebookBoostDialog(
                            missionOrAssetName: currentMission.title,
                            missionId: currentMission.id,
                          ),
                        );
                      },
                      icon: const Icon(Icons.campaign, color: Colors.white),
                      label: const Text('Booster sur Facebook & Instagram 🚀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tasks Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tâches associées (${missionTasks.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_task),
                  onPressed: () => _showAddTaskDialog(context, currentMission.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (missionTasks.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Aucune tâche n\'est encore créée pour cette mission.'),
              )
            else
              ...missionTasks.map((t) => TaskCard(task: t)),

            const SizedBox(height: 20),

            // Linked Assets Section
            if (linkedAssets.isNotEmpty) ...[
              Text(
                'Actifs promus / vendus (${linkedAssets.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...linkedAssets.map((asset) => Card(
                    child: ListTile(
                      leading: Icon(
                        asset.isDigital ? Icons.download_done : Icons.inventory_2,
                        color: asset.isDigital ? Colors.purple : Colors.teal,
                      ),
                      title: Text(asset.title),
                      subtitle: Text('\$${asset.price.toStringAsFixed(0)} - ${asset.category.label}'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(MissionStatus status) {
    switch (status) {
      case MissionStatus.draft:
        return Colors.grey;
      case MissionStatus.pending:
        return Colors.orange;
      case MissionStatus.inProgress:
        return Colors.blue;
      case MissionStatus.completed:
        return Colors.green;
      case MissionStatus.cancelled:
        return Colors.red;
    }
  }

  void _showAddTaskDialog(BuildContext context, String missionId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setStateState) {
            return AlertDialog(
              title: const Text('Ajouter une tâche d\'exécution'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Titre de la tâche'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TaskPriority>(
                      initialValue: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priorité'),
                      items: TaskPriority.values.map((p) {
                        return DropdownMenuItem(value: p, child: Text(p.label));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setStateState(() => selectedPriority = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final taskTitle = titleController.text.trim();
                    final taskDesc = descController.text.trim();
                    if (taskTitle.isNotEmpty) {
                      final newTask = Task(
                        id: 'task_${DateTime.now().millisecondsSinceEpoch}',
                        missionId: missionId,
                        title: taskTitle,
                        description: taskDesc,
                        assignedToUserName: 'Équipe WinnerLife',
                        priority: selectedPriority,
                        status: TaskStatus.todo,
                        dueDate: DateTime.now().add(const Duration(days: 7)),
                        createdAt: DateTime.now(),
                      );
                      context.read<WinnerLifeProvider>().addTask(newTask);
                      context.read<FacebookMetaService>().publishTaskToFacebook(
                        title: taskTitle,
                        description: taskDesc,
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Créer & Publier'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
