import 'package:flutter/foundation.dart';

class FacebookCampaign {
  final String id;
  final String missionId;
  final String pageName;
  final String targetCountry;
  final double dailyBudgetFcfa;
  final int durationDays;
  final String objective;
  final String status;
  final int estimatedReach;
  final DateTime createdAt;

  const FacebookCampaign({
    required this.id,
    required this.missionId,
    required this.pageName,
    required this.targetCountry,
    required this.dailyBudgetFcfa,
    required this.durationDays,
    required this.objective,
    required this.status,
    required this.estimatedReach,
    required this.createdAt,
  });
}

class FacebookMetaService extends ChangeNotifier {
  bool _isConnected = true;
  String _facebookPageName = 'WinnerLife Official Page';
  String _pageId = '1029384756';
  String _metaPixelId = 'PIXEL-778899';

  final List<FacebookCampaign> _activeCampaigns = [
    FacebookCampaign(
      id: 'fb_camp_1',
      missionId: 'miss_1',
      pageName: 'TechPulse Solutions',
      targetCountry: 'Sénégal & Guinée',
      dailyBudgetFcfa: 50.0,
      durationDays: 7,
      objective: 'Plus de messages WhatsApp & Souscriptions',
      status: 'En cours (Active)',
      estimatedReach: 45000,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  bool get isConnected => _isConnected;
  String get facebookPageName => _facebookPageName;
  String get pageId => _pageId;
  String get metaPixelId => _metaPixelId;
  List<FacebookCampaign> get activeCampaigns => _activeCampaigns;

  void updateFacebookCredentials({required String pageName, required String pageId, required String pixelId}) {
    _facebookPageName = pageName;
    _pageId = pageId;
    _metaPixelId = pixelId;
    _isConnected = true;
    notifyListeners();
  }

  Future<bool> publishProductToFacebook({
    required String title,
    required String description,
    required double price,
    required String imageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    debugPrint('Meta Graph API: Published product "$title" to Facebook page "$_facebookPageName"');
    notifyListeners();
    return true;
  }

  Future<bool> publishMissionToFacebook({
    required String title,
    required String objective,
    required double budget,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    debugPrint('Meta Graph API: Published mission "$title" (Budget: \$$budget) to Facebook page "$_facebookPageName"');
    notifyListeners();
    return true;
  }

  Future<bool> publishTaskToFacebook({
    required String title,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    debugPrint('Meta Graph API: Published task update "$title" to Facebook page "$_facebookPageName"');
    notifyListeners();
    return true;
  }

  Future<bool> publishStockToFacebook({
    required String symbol,
    required String companyName,
    required double sharePrice,
    required double yieldRate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    debugPrint('Meta Graph API: Published stock "$symbol" ($companyName) at \$$sharePrice to Facebook page "$_facebookPageName"');
    notifyListeners();
    return true;
  }

  Future<FacebookCampaign> launchFacebookBoost({
    required String missionId,
    required String pageName,
    required String targetCountry,
    required double dailyBudgetFcfa,
    required int durationDays,
    required String objective,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final totalBudget = dailyBudgetFcfa * durationDays;
    final estimatedReach = (totalBudget * 850).toInt();

    final campaign = FacebookCampaign(
      id: 'fb_camp_${DateTime.now().millisecondsSinceEpoch}',
      missionId: missionId,
      pageName: pageName,
      targetCountry: targetCountry,
      dailyBudgetFcfa: dailyBudgetFcfa,
      durationDays: durationDays,
      objective: objective,
      status: 'En cours (Active)',
      estimatedReach: estimatedReach,
      createdAt: DateTime.now(),
    );

    _activeCampaigns.insert(0, campaign);
    notifyListeners();
    return campaign;
  }
}
