import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/winnerlife_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/mission_card.dart';
import '../widgets/asset_card.dart';
import 'mission_detail_screen.dart';
import 'asset_detail_screen.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WinnerLifeProvider>();

    final missions = provider.missions;
    final tasks = provider.tasks;
    final assets = provider.assets;
    final totalBudget = provider.totalBudgetManaged;
    final unreadCount = provider.unreadNotificationsCount;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber),
            SizedBox(width: 8),
            Text(
              'WinnerLife Dashboard',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              label: Text('$unreadCount'),
              isLabelVisible: unreadCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bienvenue sur WinnerLife 👋',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Accélérez la croissance des entreprises avec nos missions & notre marketplace.',
                          style: TextStyle(
                            color: Colors.white.withAlpha(230),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Key Statistics Grid
                  Text(
                    'Vue d\'ensemble',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      StatCard(
                        title: 'Missions actives',
                        value: '${missions.length}',
                        icon: Icons.assignment_outlined,
                        color: Colors.blue,
                      ),
                      StatCard(
                        title: 'Tâches en cours',
                        value: '${tasks.length}',
                        icon: Icons.task_alt,
                        color: Colors.orange,
                      ),
                      StatCard(
                        title: 'Actifs en vente',
                        value: '${assets.length}',
                        icon: Icons.storefront,
                        color: Colors.purple,
                      ),
                      StatCard(
                        title: 'Budget géré',
                        value: '\$${(totalBudget / 1000).toStringAsFixed(0)}k',
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Missions Récentes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Missions récentes',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...missions.map((m) => MissionCard(
                        mission: m,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MissionDetailScreen(mission: m),
                            ),
                          );
                        },
                      )),

                  const SizedBox(height: 16),

                  // Top Actifs Marketplace
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Actifs en vedette',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: assets.length,
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return AssetCard(
                        asset: asset,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssetDetailScreen(asset: asset),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
