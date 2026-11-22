import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'api_service.dart';
import 'mock_data.dart';

class SupabaseApiService implements ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> seedInitialDataIfEmpty() async {
    try {
      final response = await _supabase.from('financial_assets').select().limit(1);
      if (response.isEmpty) {
        for (final company in MockData.sampleCompanies) {
          await _supabase.from('companies').upsert(company.toJson());
        }
        for (final mission in MockData.sampleMissions) {
          await _supabase.from('missions').upsert(mission.toJson());
        }
        for (final task in MockData.sampleTasks) {
          await _supabase.from('tasks').upsert(task.toJson());
        }
        for (final asset in MockData.sampleAssets) {
          await _supabase.from('assets').upsert(asset.toJson());
        }
        for (final finAsset in MockData.sampleFinancialAssets) {
          await _supabase.from('financial_assets').upsert(finAsset.toJson());
        }
      }
    } catch (e) {
      debugPrint('Supabase seeding error (using offline fallback): $e');
    }
  }

  @override
  Future<List<Company>> getCompanies() async {
    try {
      await seedInitialDataIfEmpty();
      final data = await _supabase.from('companies').select();
      return (data as List).map((json) => Company.fromJson(json)).toList();
    } catch (_) {
      return MockData.sampleCompanies;
    }
  }

  @override
  Future<List<Mission>> getMissions() async {
    try {
      await seedInitialDataIfEmpty();
      final data = await _supabase.from('missions').select();
      return (data as List).map((json) => Mission.fromJson(json)).toList();
    } catch (_) {
      return MockData.sampleMissions;
    }
  }

  @override
  Future<List<Task>> getTasks() async {
    try {
      await seedInitialDataIfEmpty();
      final data = await _supabase.from('tasks').select();
      return (data as List).map((json) => Task.fromJson(json)).toList();
    } catch (_) {
      return MockData.sampleTasks;
    }
  }

  @override
  Future<List<Asset>> getAssets() async {
    try {
      await seedInitialDataIfEmpty();
      final data = await _supabase.from('assets').select();
      return (data as List).map((json) => Asset.fromJson(json)).toList();
    } catch (_) {
      return MockData.sampleAssets;
    }
  }

  @override
  Future<List<FinancialAsset>> getFinancialAssets() async {
    try {
      await seedInitialDataIfEmpty();
      final data = await _supabase.from('financial_assets').select();
      return (data as List).map((json) => FinancialAsset.fromJson(json)).toList();
    } catch (_) {
      return MockData.sampleFinancialAssets;
    }
  }

  @override
  Future<Mission> createMission(Mission mission) async {
    try {
      await _supabase.from('missions').upsert(mission.toJson());
    } catch (_) {}
    return mission;
  }

  @override
  Future<Task> createTask(Task task) async {
    try {
      await _supabase.from('tasks').upsert(task.toJson());
    } catch (_) {}
    return task;
  }

  @override
  Future<Asset> createAsset(Asset asset) async {
    try {
      await _supabase.from('assets').upsert(asset.toJson());
    } catch (_) {}
    return asset;
  }

  @override
  Future<FinancialAsset> createFinancialAsset(FinancialAsset asset) async {
    try {
      await _supabase.from('financial_assets').upsert(asset.toJson());
    } catch (_) {}
    return asset;
  }

  @override
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _supabase.from('tasks').update({'status': status.name}).eq('id', taskId);
    } catch (_) {}
  }

  @override
  Future<void> updateMissionStatus(String missionId, MissionStatus status) async {
    try {
      await _supabase.from('missions').update({'status': status.name}).eq('id', missionId);
    } catch (_) {}
  }

  @override
  Future<void> purchaseAsset(String assetId) async {
    try {
      final response = await _supabase.from('assets').select().eq('id', assetId).single();
      final current = Asset.fromJson(response);
      if (current.isPhysical && (current.stockQuantity ?? 0) > 0) {
        final newStock = (current.stockQuantity ?? 1) - 1;
        await _supabase.from('assets').update({
          'stockQuantity': newStock,
          'isAvailable': newStock > 0,
        }).eq('id', assetId);
      }
    } catch (_) {}
  }

  @override
  Future<void> buyFinancialShares(String assetId, int sharesCount) async {
    try {
      final response = await _supabase.from('financial_assets').select().eq('id', assetId).single();
      final current = FinancialAsset.fromJson(response);
      final newAvailable = (current.availableShares - sharesCount).clamp(0, current.totalShares);
      await _supabase.from('financial_assets').update({'availableShares': newAvailable}).eq('id', assetId);
    } catch (_) {}
  }

  @override
  Future<void> sellFinancialShares(String assetId, int sharesCount) async {
    try {
      final response = await _supabase.from('financial_assets').select().eq('id', assetId).single();
      final current = FinancialAsset.fromJson(response);
      final newAvailable = (current.availableShares + sharesCount).clamp(0, current.totalShares);
      await _supabase.from('financial_assets').update({'availableShares': newAvailable}).eq('id', assetId);
    } catch (_) {}
  }
}
