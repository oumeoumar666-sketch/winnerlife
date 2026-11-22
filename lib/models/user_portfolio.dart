import 'package:flutter/foundation.dart';

@immutable
class PortfolioHolding {
  final String assetId;
  final String symbol;
  final String title;
  final int sharesOwned;
  final double averageBuyPrice;
  final double currentSharePrice;

  const PortfolioHolding({
    required this.assetId,
    required this.symbol,
    required this.title,
    required this.sharesOwned,
    required this.averageBuyPrice,
    required this.currentSharePrice,
  });

  double get totalInvested => sharesOwned * averageBuyPrice;
  double get currentValue => sharesOwned * currentSharePrice;
  double get profitOrLoss => currentValue - totalInvested;
  double get returnPercentage => totalInvested > 0 ? (profitOrLoss / totalInvested) * 100 : 0.0;
}

@immutable
class UserPortfolio {
  final double cashBalance;
  final List<PortfolioHolding> holdings;

  const UserPortfolio({
    required this.cashBalance,
    required this.holdings,
  });

  double get totalHoldingsValue {
    return holdings.fold(0.0, (sum, h) => sum + h.currentValue);
  }

  double get totalPortfolioValue => cashBalance + totalHoldingsValue;

  double get totalUnrealizedProfit {
    return holdings.fold(0.0, (sum, h) => sum + h.profitOrLoss);
  }
}
