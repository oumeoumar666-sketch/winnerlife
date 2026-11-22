import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_data.dart';

class FirebaseApiService implements ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseApiService() {
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  CollectionReference<Map<String, dynamic>> get _companiesRef => _firestore.collection('companies');
  CollectionReference<Map<String, dynamic>> get _missionsRef => _firestore.collection('missions');
  CollectionReference<Map<String, dynamic>> get _tasksRef => _firestore.collection('tasks');
  CollectionReference<Map<String, dynamic>> get _assetsRef => _firestore.collection('assets');
  CollectionReference<Map<String, dynamic>> get _financialAssetsRef => _firestore.collection('financial_assets');

  Future<QuerySnapshot<Map<String, dynamic>>> _fastFetch(CollectionReference<Map<String, dynamic>> ref) async {
    try {
      final cacheSnap = await ref.get(const GetOptions(source: Source.cache));
      if (cacheSnap.docs.isNotEmpty) {
        // Background sync with server
        ref.get(const GetOptions(source: Source.serverAndCache)).catchError((_) => cacheSnap);
        return cacheSnap;
      }
    } catch (_) {}
    return await ref.get(const GetOptions(source: Source.serverAndCache));
  }

  Future<void> seedInitialDataIfEmpty() async {
    try {
      final snapshot = await _financialAssetsRef.limit(1).get(const GetOptions(source: Source.cache));
      if (snapshot.docs.isEmpty) {
        final serverSnap = await _financialAssetsRef.limit(1).get(const GetOptions(source: Source.serverAndCache));
        if (serverSnap.docs.isEmpty) {
          for (final company in MockData.sampleCompanies) {
            await _companiesRef.doc(company.id).set(company.toJson());
          }
          for (final mission in MockData.sampleMissions) {
            await _missionsRef.doc(mission.id).set(mission.toJson());
          }
          for (final task in MockData.sampleTasks) {
            await _tasksRef.doc(task.id).set(task.toJson());
          }
          for (final asset in MockData.sampleAssets) {
            await _assetsRef.doc(asset.id).set(asset.toJson());
          }
          for (final finAsset in MockData.sampleFinancialAssets) {
            await _financialAssetsRef.doc(finAsset.id).set(finAsset.toJson());
          }
        }
      }
    } catch (_) {
      // Offline fallback handling
    }
  }

  @override
  Future<List<Company>> getCompanies() async {
    await seedInitialDataIfEmpty();
    final snapshot = await _fastFetch(_companiesRef);
    return snapshot.docs.map((doc) => Company.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Mission>> getMissions() async {
    await seedInitialDataIfEmpty();
    final snapshot = await _fastFetch(_missionsRef);
    return snapshot.docs.map((doc) => Mission.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Task>> getTasks() async {
    await seedInitialDataIfEmpty();
    final snapshot = await _fastFetch(_tasksRef);
    return snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
  }

  @override
  Future<List<Asset>> getAssets() async {
    await seedInitialDataIfEmpty();
    final snapshot = await _fastFetch(_assetsRef);
    return snapshot.docs.map((doc) => Asset.fromJson(doc.data())).toList();
  }

  @override
  Future<List<FinancialAsset>> getFinancialAssets() async {
    await seedInitialDataIfEmpty();
    final snapshot = await _fastFetch(_financialAssetsRef);
    return snapshot.docs.map((doc) => FinancialAsset.fromJson(doc.data())).toList();
  }

  @override
  Future<Mission> createMission(Mission mission) async {
    await _missionsRef.doc(mission.id).set(mission.toJson());
    return mission;
  }

  @override
  Future<Task> createTask(Task task) async {
    await _tasksRef.doc(task.id).set(task.toJson());
    return task;
  }

  @override
  Future<Asset> createAsset(Asset asset) async {
    await _assetsRef.doc(asset.id).set(asset.toJson());
    return asset;
  }

  @override
  Future<FinancialAsset> createFinancialAsset(FinancialAsset asset) async {
    await _financialAssetsRef.doc(asset.id).set(asset.toJson());
    return asset;
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _tasksRef.doc(taskId).update({'status': status.name});
  }

  @override
  Future<void> updateMissionStatus(String missionId, MissionStatus status) async {
    await _missionsRef.doc(missionId).update({'status': status.name});
  }

  @override
  Future<void> purchaseAsset(String assetId) async {
    final doc = await _assetsRef.doc(assetId).get();
    if (doc.exists) {
      final current = Asset.fromJson(doc.data()!);
      if (current.isPhysical && (current.stockQuantity ?? 0) > 0) {
        final newStock = (current.stockQuantity ?? 1) - 1;
        await _assetsRef.doc(assetId).update({
          'stockQuantity': newStock,
          'isAvailable': newStock > 0,
        });
      }
    }
  }

  @override
  Future<void> buyFinancialShares(String assetId, int sharesCount) async {
    final doc = await _financialAssetsRef.doc(assetId).get();
    if (doc.exists) {
      final current = FinancialAsset.fromJson(doc.data()!);
      final newAvailable = (current.availableShares - sharesCount).clamp(0, current.totalShares);
      await _financialAssetsRef.doc(assetId).update({'availableShares': newAvailable});
    }
  }

  @override
  Future<void> sellFinancialShares(String assetId, int sharesCount) async {
    final doc = await _financialAssetsRef.doc(assetId).get();
    if (doc.exists) {
      final current = FinancialAsset.fromJson(doc.data()!);
      final newAvailable = (current.availableShares + sharesCount).clamp(0, current.totalShares);
      await _financialAssetsRef.doc(assetId).update({'availableShares': newAvailable});
    }
  }
}
