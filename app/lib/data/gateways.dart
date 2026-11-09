/// Vendor interfaces are deliberately disconnected in the offline build.
abstract interface class AdGateway {
  Future<bool> earnHint();
}

abstract interface class PurchaseGateway {
  Future<bool> restorePurchases();
}

abstract interface class AnalyticsGateway {
  void record(String event, Map<String, Object> properties);
}

class OfflineAdGateway implements AdGateway {
  @override
  Future<bool> earnHint() async => false;
}

class OfflinePurchaseGateway implements PurchaseGateway {
  @override
  Future<bool> restorePurchases() async => false;
}

class PrivateAnalyticsGateway implements AnalyticsGateway {
  @override
  void record(String event, Map<String, Object> properties) {}
}
