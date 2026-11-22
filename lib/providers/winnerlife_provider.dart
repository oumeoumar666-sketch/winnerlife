import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class WinnerLifeProvider extends ChangeNotifier {
  final ApiService _repository;

  List<Company> _companies = [];
  List<Mission> _missions = [];
  List<Task> _tasks = [];
  List<Asset> _assets = [];
  List<FinancialAsset> _financialAssets = [];

  // Cart State
  final List<Asset> _cartItems = [];

  // Notifications State
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'notif_1',
      'title': 'Bienvenue sur WinnerLife 👑',
      'message': 'Votre plateforme d\'actifs et de bourse d\'entreprise est prête.',
      'time': 'Il y a 10 min',
      'isRead': false,
    },
    {
      'id': 'notif_2',
      'title': 'Nouvelle Mission Active',
      'message': 'TechPulse Solutions a lancé la mission "Boost Acquisition SaaS".',
      'time': 'Il y a 1 heure',
      'isRead': false,
    },
    {
      'id': 'notif_3',
      'title': 'Opportunité en Bourse',
      'message': 'Le titre TPS a progressé de +5.2% cette semaine !',
      'time': 'Il y a 3 heures',
      'isRead': false,
    },
  ];

  // Transactions State
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'tx_1',
      'title': 'Acompte Mission TechPulse Solutions',
      'date': 'Aujourd\'hui',
      'amount': 2250.0,
      'isCredit': true,
      'method': 'Orange Money',
    },
    {
      'id': 'tx_2',
      'title': 'Commission Vente E-book ERP',
      'date': 'Hier',
      'amount': 150.0,
      'isCredit': true,
      'method': 'Mobile Money',
    },
  ];

  // User Investment Portfolio State
  double _cashBalance = 0.0;
  final Map<String, int> _userHoldingsCount = {};
  final Map<String, double> _userBuyPrices = {};

  bool _isLoading = false;
  String? _errorMessage;
  String _assetSearchQuery = '';
  String _selectedAssetFilter = 'Tous';
  String _userRole = 'Administrateur WinnerLife';
  String _whatsappNumber = '';
  String _appDownloadLink = 'https://drive.google.com/drive/folders/winnerlife-apk';

  WinnerLifeProvider({ApiService? repository})
      : _repository = repository ?? WinnerLifeRepository() {
    fetchInitialData();
  }

  String get userRole => _userRole;
  String get whatsappNumber => _whatsappNumber;
  String get appDownloadLink => _appDownloadLink;

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  void setWhatsappNumber(String phone) {
    _whatsappNumber = phone.replaceAll(RegExp(r'[^\d]'), '');
    notifyListeners();
  }

  void setAppDownloadLink(String link) {
    _appDownloadLink = link;
    notifyListeners();
  }

  List<Company> get companies => _companies;
  List<Mission> get missions => _missions;
  List<Task> get tasks => _tasks;
  List<Asset> get assets => _assets;
  List<FinancialAsset> get financialAssets => _financialAssets;
  double get cashBalance => _cashBalance;

  // Transactions & Revenue Getters
  List<Map<String, dynamic>> get transactions => _transactions;

  double get totalMissionsRevenue => _missions.fold(0.0, (sum, m) => sum + (m.budget * 0.15));
  double get totalAssetSalesRevenue => _assets.fold(0.0, (sum, a) => sum + a.price);
  double get totalRevenue => totalMissionsRevenue + totalAssetSalesRevenue + userPortfolio.totalUnrealizedProfit;

  bool processWithdrawal(double amount, String phoneNumber) {
    if (_cashBalance < amount || amount <= 0) return false;
    _cashBalance -= amount;

    _transactions.insert(0, {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Retrait Orange Money / Mobile Money ($phoneNumber)',
      'date': 'À l\'instant',
      'amount': amount,
      'isCredit': false,
      'method': 'Orange Money / Mobile Money',
    });

    addNotification('Retrait Effectué 📲', 'Retrait de \$$amount envoyé vers Orange Money / Mobile Money ($phoneNumber).');
    notifyListeners();
    return true;
  }

  bool depositToWallet(double amount, String phoneNumber) {
    if (amount < 3.0) return false;

    _cashBalance += amount;

    _transactions.insert(0, {
      'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Dépôt Bourse Orange Money / Mobile Money ($phoneNumber)',
      'date': 'À l\'instant',
      'amount': amount,
      'isCredit': true,
      'method': 'Orange Money / Mobile Money',
    });

    addNotification('Dépôt Bourse Reçu 💵', 'Dépôt de \$$amount crédité sur votre portefeuille Bourse via Orange Money / Mobile Money.');
    notifyListeners();
    return true;
  }

  // Cart Getters & Methods
  List<Asset> get cartItems => _cartItems;
  double get cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.price);

  void addToCart(Asset asset) {
    if (!_cartItems.any((item) => item.id == asset.id)) {
      _cartItems.add(asset);
      addNotification('Panier mis à jour 🛒', 'Actif "${asset.title}" ajouté à votre panier.');
      notifyListeners();
    }
  }

  void removeFromCart(String assetId) {
    _cartItems.removeWhere((item) => item.id == assetId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  // Notifications Getters & Methods
  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadNotificationsCount => _notifications.where((n) => n['isRead'] == false).length;

  void markNotificationsAsRead() {
    for (var n in _notifications) {
      n['isRead'] = true;
    }
    notifyListeners();
  }

  void addNotification(String title, String message) {
    _notifications.insert(0, {
      'id': 'notif_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'message': message,
      'time': 'À l\'instant',
      'isRead': false,
    });
    notifyListeners();
  }

  UserPortfolio get userPortfolio {
    final List<PortfolioHolding> holdingsList = [];
    _userHoldingsCount.forEach((assetId, count) {
      if (count > 0) {
        final asset = _financialAssets.firstWhere(
          (a) => a.id == assetId,
          orElse: () => FinancialAsset(
            id: assetId,
            symbol: '???',
            companyId: '',
            companyName: '',
            title: 'Actif',
            description: '',
            sharePrice: 0.0,
            previousPrice: 0.0,
            totalShares: 0,
            availableShares: 0,
            expectedAnnualYield: 0.0,
            category: FinancialAssetCategory.pmeEquity,
            priceHistory: [],
            createdAt: DateTime.now(),
          ),
        );

        holdingsList.add(PortfolioHolding(
          assetId: assetId,
          symbol: asset.symbol,
          title: asset.title,
          sharesOwned: count,
          averageBuyPrice: _userBuyPrices[assetId] ?? asset.sharePrice,
          currentSharePrice: asset.sharePrice,
        ));
      }
    });

    return UserPortfolio(
      cashBalance: _cashBalance,
      holdings: holdingsList,
    );
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get assetSearchQuery => _assetSearchQuery;
  String get selectedAssetFilter => _selectedAssetFilter;

  List<Asset> get filteredAssets {
    return _assets.where((asset) {
      final matchesSearch = asset.title.toLowerCase().contains(_assetSearchQuery.toLowerCase()) ||
          asset.description.toLowerCase().contains(_assetSearchQuery.toLowerCase());

      if (_selectedAssetFilter == 'Physiques') {
        return matchesSearch && asset.isPhysical;
      } else if (_selectedAssetFilter == 'Digitaux') {
        return matchesSearch && asset.isDigital;
      }
      return matchesSearch;
    }).toList();
  }

  double get totalBudgetManaged {
    return _missions.fold(0.0, (sum, mission) => sum + mission.budget);
  }

  Future<void> fetchInitialData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _companies = await _repository.getCompanies();
      _missions = await _repository.getMissions();
      _tasks = await _repository.getTasks();
      _assets = await _repository.getAssets();
      _financialAssets = await _repository.getFinancialAssets();
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des données: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setAssetSearchQuery(String query) {
    _assetSearchQuery = query;
    notifyListeners();
  }

  void setAssetFilter(String filter) {
    _selectedAssetFilter = filter;
    notifyListeners();
  }

  Future<void> addMission(Mission mission) async {
    // Optimistic UI update (0 ms response)
    _missions.insert(0, mission);
    addNotification('Nouvelle Mission Soumise 🚀', 'La mission "${mission.title}" a été ajoutée.');
    notifyListeners();

    // Background sync
    _repository.createMission(mission).then((_) {}, onError: (e) {
      debugPrint('Background sync error (mission): $e');
    });
  }

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    addNotification('Nouvelle Tâche Assignée 📋', 'Tâche "${task.title}" ajoutée à la mission.');
    notifyListeners();

    _repository.createTask(task).then((_) {}, onError: (e) {
      debugPrint('Background sync error (task): $e');
    });
  }

  Future<void> addAsset(Asset asset) async {
    _assets.insert(0, asset);
    addNotification('Nouveau Produit en Vente 🛍️', 'L\'actif "${asset.title}" est maintenant disponible.');
    notifyListeners();

    _repository.createAsset(asset).then((_) {}, onError: (e) {
      debugPrint('Background sync error (asset): $e');
    });
  }

  Future<void> addFinancialAsset(FinancialAsset asset) async {
    _financialAssets.insert(0, asset);
    addNotification('Nouveau Titre en Bourse 📈', 'Le titre "${asset.symbol}" a été émis sur la bourse.');
    notifyListeners();

    _repository.createFinancialAsset(asset).then((_) {}, onError: (e) {
      debugPrint('Background sync error (financial asset): $e');
    });
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _repository.updateTaskStatus(taskId, status);
      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = _tasks[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de la tâche';
      notifyListeners();
    }
  }

  Future<void> updateMissionStatus(String missionId, MissionStatus status) async {
    try {
      await _repository.updateMissionStatus(missionId, status);
      final index = _missions.indexWhere((m) => m.id == missionId);
      if (index != -1) {
        _missions[index] = _missions[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de la mission';
      notifyListeners();
    }
  }

  Future<bool> purchasePhysicalAsset(String assetId) async {
    try {
      await _repository.purchaseAsset(assetId);
      final index = _assets.indexWhere((a) => a.id == assetId);
      if (index != -1) {
        final current = _assets[index];
        if (current.isPhysical && (current.stockQuantity ?? 0) > 0) {
          final newStock = (current.stockQuantity ?? 1) - 1;
          _assets[index] = current.copyWith(
            stockQuantity: newStock,
            isAvailable: newStock > 0,
          );
          _transactions.insert(0, {
            'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
            'title': 'Vente Produit Physique (${current.title})',
            'date': 'À l\'instant',
            'amount': current.price,
            'isCredit': true,
            'method': 'Orange Money / Mobile Money',
          });
          addNotification('Commande d\'Actif 🛍️', 'Une unité de "${current.title}" a été commandée.');
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors de la commande';
      notifyListeners();
      return false;
    }
  }

  Future<bool> buyShares(String assetId, int quantity) async {
    final index = _financialAssets.indexWhere((a) => a.id == assetId);
    if (index == -1) return false;

    final asset = _financialAssets[index];
    final totalCost = asset.sharePrice * quantity;

    if (_cashBalance < totalCost || asset.availableShares < quantity) {
      return false;
    }

    try {
      await _repository.buyFinancialShares(assetId, quantity);

      _cashBalance -= totalCost;
      final currentOwned = _userHoldingsCount[assetId] ?? 0;
      _userHoldingsCount[assetId] = currentOwned + quantity;
      _userBuyPrices[assetId] = asset.sharePrice;

      _financialAssets[index] = asset.copyWith(
        availableShares: asset.availableShares - quantity,
      );

      _transactions.insert(0, {
        'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Achat Bourse (${asset.symbol}) - $quantity parts',
        'date': 'À l\'instant',
        'amount': totalCost,
        'isCredit': false,
        'method': 'Portefeuille Bourse',
      });

      addNotification('Ordre en Bourse Exécuté 📈', 'Achat de $quantity parts de ${asset.symbol} pour \$${totalCost.toStringAsFixed(0)}.');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'achat d\'actions';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sellShares(String assetId, int quantity) async {
    final currentOwned = _userHoldingsCount[assetId] ?? 0;
    if (currentOwned < quantity) return false;

    final index = _financialAssets.indexWhere((a) => a.id == assetId);
    if (index == -1) return false;

    final asset = _financialAssets[index];
    final totalRevenue = asset.sharePrice * quantity;

    try {
      await _repository.sellFinancialShares(assetId, quantity);

      _cashBalance += totalRevenue;
      _userHoldingsCount[assetId] = currentOwned - quantity;

      _financialAssets[index] = asset.copyWith(
        availableShares: asset.availableShares + quantity,
      );

      _transactions.insert(0, {
        'id': 'tx_${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Vente Bourse (${asset.symbol}) - $quantity parts',
        'date': 'À l\'instant',
        'amount': totalRevenue,
        'isCredit': true,
        'method': 'Portefeuille Bourse',
      });

      addNotification('Vente Bourse Confirmée 📉', 'Revente de $quantity parts de ${asset.symbol} pour \$${totalRevenue.toStringAsFixed(0)}.');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la revente d\'actions';
      notifyListeners();
      return false;
    }
  }
}
