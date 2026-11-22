import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/winnerlife_provider.dart';
import '../widgets/mission_card.dart';
import '../widgets/task_card.dart';
import 'mission_detail_screen.dart';
import 'create_mission_screen.dart';

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();
    final missions = provider.missions;
    final tasks = provider.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Missions & Tâches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Missions Entreprises'),
            Tab(text: 'Tâches d\'exécution'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Missions
          missions.isEmpty
              ? const Center(child: Text('Aucune mission en cours.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: missions.length,
                  itemBuilder: (context, index) {
                    final mission = missions[index];
                    return MissionCard(
                      mission: mission,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MissionDetailScreen(mission: mission),
                          ),
                        );
                      },
                    );
                  },
                ),

          // Tab 2: Tasks
          tasks.isEmpty
              ? const Center(child: Text('Aucune tâche créée.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskCard(task: tasks[index]);
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateMissionScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Mission'),
      ),
    );
  }
}
