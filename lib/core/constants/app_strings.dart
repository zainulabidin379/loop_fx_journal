abstract final class AppStrings {
  static const String appName = 'LOOP';
  static const String appTagline = 'Trading Journal';

  // Splash
  static const String splashLoading = 'Loading your journal...';

  // Auth
  static const String authTitle = 'Unlock LOOP';
  static const String authSubtitle = 'Authenticate to access your trading journal';
  static const String authButton = 'Unlock with Biometrics';
  static const String authFailed = 'Authentication failed. Please try again.';
  static const String authUnavailable = 'Biometrics unavailable on this device';

  // Navigation
  static const String navDashboard = 'Dashboard';
  static const String navTrades = 'Trades';
  static const String navSettings = 'Settings';

  // Dashboard
  static const String dashboardTitle = 'Dashboard';
  static const String totalPnl = 'Total P&L';
  static const String winRate = 'Win Rate';
  static const String totalTrades = 'Total Trades';
  static const String avgRiskReward = 'Avg R:R';
  static const String profitFactor = 'Profit Factor';
  static const String equityCurve = 'Equity Curve';
  static const String winLossBreakdown = 'Win / Loss';
  static const String performanceByInstrument = 'By Instrument';
  static const String performanceByStrategy = 'By Strategy';
  static const String performanceByEmotion = 'By Emotion';
  static const String bestTrade = 'Best Trade';
  static const String worstTrade = 'Worst Trade';
  static const String openTrades = 'Open Trades';
  static const String streakTracker = 'Streak';
  static const String currentStreak = 'Current Streak';
  static const String filterAll = 'All';
  static const String filter7d = '7D';
  static const String filter30d = '30D';
  static const String filter90d = '90D';
  static const String filterCustom = 'Custom';
  static const String noTradesYet = 'No trades yet';
  static const String noTradesSubtitle = 'Log your first trade to start tracking performance';
  static const String viewRecap = 'View Recap';

  // Trades
  static const String tradesTitle = 'Trades';
  static const String addTrade = 'Add Trade';
  static const String editTrade = 'Edit Trade';
  static const String tradeDetail = 'Trade Detail';
  static const String saveTrade = 'Save Trade';
  static const String saveAsOpen = 'Save as Open';
  static const String closeTrade = 'Close Trade';
  static const String deleteTrade = 'Delete Trade';
  static const String deleteTradeConfirm = 'Are you sure you want to delete this trade?';
  static const String instrument = 'Instrument';
  static const String direction = 'Direction';
  static const String long = 'Long';
  static const String short = 'Short';
  static const String entryPrice = 'Entry Price';
  static const String exitPrice = 'Exit Price';
  static const String stopLoss = 'Stop Loss';
  static const String takeProfit = 'Take Profit';
  static const String lotSize = 'Lot Size';
  static const String entryDate = 'Entry Date';
  static const String exitDate = 'Exit Date';
  static const String plannedRR = 'Planned R:R';
  static const String actualRR = 'Actual R:R';
  static const String pnl = 'P&L';
  static const String pnlPips = 'P&L (Pips)';
  static const String strategy = 'Strategy';
  static const String noStrategy = 'None';
  static const String notes = 'Notes';
  static const String tags = 'Tags';
  static const String addTag = 'Add tag';
  static const String emotionBefore = 'Emotion Before';
  static const String emotionAfter = 'Emotion After';
  static const String screenshots = 'Screenshots';
  static const String addScreenshot = 'Add Screenshot';
  static const String customInstrument = 'Custom Instrument';
  static const String lotCalculator = 'Position Calculator';
  static const String suggestedLotSize = 'Suggested Lot Size';
  static const String accountBalance = 'Account Balance';
  static const String riskPercent = 'Risk %';

  // Strategies
  static const String strategiesTitle = 'Strategies';
  static const String addStrategy = 'Add Strategy';
  static const String editStrategy = 'Edit Strategy';
  static const String strategyName = 'Strategy Name';
  static const String strategyDescription = 'Description';
  static const String archiveStrategy = 'Archive Strategy';
  static const String archiveStrategyConfirm = 'Archive this strategy? Past trades will keep their reference.';
  static const String noStrategies = 'No strategies yet';
  static const String strategyPerformance = 'Strategy Performance';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String biometricLock = 'Biometric Lock';
  static const String biometricLockSubtitle = 'Require fingerprint or Face ID to open LOOP';
  static const String baseCurrency = 'Base Currency';
  static const String startingBalance = 'Starting Balance';
  static const String defaultRiskPercent = 'Default Risk %';
  static const String exportData = 'Export Data';
  static const String importData = 'Import Data';
  static const String exportJson = 'Export JSON';
  static const String exportCsv = 'Export CSV';
  static const String clearAllData = 'Clear All Data';
  static const String clearAllDataConfirm = 'This will permanently delete all trades, strategies, and settings. This cannot be undone.';
  static const String about = 'About';
  static const String version = 'Version';
  static const String reminderNotification = 'Trade Log Reminder';
  static const String reminderNotificationSubtitle = 'Notify if no trade logged in 24 hours';
  static const String manageStrategies = 'Manage Strategies';

  // Recap
  static const String recapTitle = 'Performance Recap';
  static const String weeklyRecap = 'This Week';
  static const String monthlyRecap = 'This Month';
  static const String recapTrades = 'trades';
  static const String recapBestPair = 'Best pair';

  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String error = 'Something went wrong';
  static const String wins = 'Wins';
  static const String losses = 'Losses';
  static const String breakeven = 'Breakeven';
  static const String open = 'Open';
  static const String archived = 'Archived';
}
