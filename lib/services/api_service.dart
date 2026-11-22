import '../models/models.dart';
import 'mock_data.dart';

abstract class ApiService {
  Future<List<Company>> getCompanies();
  Future<List<Mission>> getMissions();
  Future<List<Task>> getTasks();
  Future<List<Asset>> getAssets();
  Future<List<FinancialAsset>> getFinancialAssets();
  Future<Mission> createMission(Mission mission);
  Future<Task> createTask(Task task);
  Future<Asset> createAsset(Asset asset);
  Future<FinancialAsset> createFinancialAsset(FinancialAsset asset);
  Future<void> updateTaskStatus(String taskId, TaskStatus status);
  Future<void> updateMissionStatus(String missionId, MissionStatus status);
  Future<void> purchaseAsset(String assetId);
  Future<void> buyFinancialShares(String assetId, int sharesCount);
  Future<void> sellFinancialShares(String assetId, int sharesCount);
}

class WinnerLifeRepository implements ApiService {
  final List<Company> _companies = List.from(MockData.sampleCompanies);
  final List<Mission> _missions = List.from(MockData.sampleMissions);
  final List<Task> _tasks = List.from(MockData.sampleTasks);
  final List<Asset> _assets = List.from(MockData.sampleAssets);
  final List<FinancialAsset> _financialAssets = List.from(MockData.sampleFinancialAssets);

  @override
  Future<List<Company>> getCompanies() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_companies);
  }

  @override
  Future<List<Mission>> getMissions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_missions);
  }

  @override
  Future<List<Task>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_tasks);
  }

  @override
  Future<List<Asset>> getAssets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_assets);
  }

  @override
  Future<List<FinancialAsset>> getFinancialAssets() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_financialAssets);
  }

  @override
  Future<Mission> createMission(Mission mission) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _missions.insert(0, mission);
    return mission;
  }

  @override
  Future<Task> createTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.insert(0, task);
    return task;
  }

  @override
  Future<Asset> createAsset(Asset asset) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _assets.insert(0, asset);
    return asset;
  }

  @override
  Future<FinancialAsset> createFinancialAsset(FinancialAsset asset) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _financialAssets.insert(0, asset);
    return asset;
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(status: status);
    }
  }

  @override
  Future<void> updateMissionStatus(String missionId, MissionStatus status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _missions.indexWhere((m) => m.id == missionId);
    if (index != -1) {
      _missions[index] = _missions[index].copyWith(status: status);
    }
  }

  @override
  Future<void> purchaseAsset(String assetId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _assets.indexWhere((a) => a.id == assetId);
    if (index != -1) {
      final current = _assets[index];
      if (current.isPhysical && (current.stockQuantity ?? 0) > 0) {
        final newStock = (current.stockQuantity ?? 1) - 1;
        _assets[index] = current.copyWith(
          stockQuantity: newStock,
          isAvailable: newStock > 0,
        );
      }
    }
  }

  @override
  Future<void> buyFinancialShares(String assetId, int sharesCount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _financialAssets.indexWhere((a) => a.id == assetId);
    if (index != -1) {
      final current = _financialAssets[index];
      final newAvailable = (current.availableShares - sharesCount).clamp(0, current.totalShares);
      _financialAssets[index] = current.copyWith(availableShares: newAvailable);
    }
  }

  @override
  Future<void> sellFinancialShares(String assetId, int sharesCount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _financialAssets.indexWhere((a) => a.id == assetId);
    if (index != -1) {
      final current = _financialAssets[index];
      final newAvailable = (current.availableShares + sharesCount).clamp(0, current.totalShares);
      _financialAssets[index] = current.copyWith(availableShares: newAvailable);
    }
  }
}
