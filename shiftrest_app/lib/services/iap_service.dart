import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IAP service for ShiftRest Pro one-time purchase.
class IapService extends ChangeNotifier {
  static const String productId = 'shiftrest_pro';
  static const String _prefKey = 'shiftrest_is_pro';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  bool _isPro = false;
  bool _isAvailable = false;
  bool _isPending = false;
  ProductDetails? _product;
  String? _error;

  bool get isPro => _isPro;
  bool get isAvailable => _isAvailable;
  bool get isPending => _isPending;
  ProductDetails? get product => _product;
  String? get error => _error;

  /// Initialize the service: load persisted state and listen to purchase stream.
  Future<void> initialize() async {
    // Load persisted pro status
    final prefs = await SharedPreferences.getInstance();
    _isPro = prefs.getBool(_prefKey) ?? false;
    notifyListeners();

    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      notifyListeners();
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (Object e) {
        _error = e.toString();
        notifyListeners();
      },
    );

    // Load product details
    final response = await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('IapService: product $productId not found in store');
    }
    if (response.productDetails.isNotEmpty) {
      _product = response.productDetails.first;
    }
    notifyListeners();
  }

  /// Initiate the Pro purchase flow.
  Future<void> purchasePro() async {
    if (_product == null) {
      _error = 'Product not available';
      notifyListeners();
      return;
    }
    _error = null;
    _isPending = true;
    notifyListeners();

    final param = PurchaseParam(productDetails: _product!);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  /// Restore previous purchases.
  Future<void> restorePurchases() async {
    _error = null;
    _isPending = true;
    notifyListeners();
    await _iap.restorePurchases();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == productId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await _setProUnlocked(true);
        } else if (purchase.status == PurchaseStatus.error) {
          _error = purchase.error?.message ?? 'Purchase failed';
          _isPending = false;
          notifyListeners();
        } else if (purchase.status == PurchaseStatus.canceled) {
          _isPending = false;
          notifyListeners();
        }

        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<void> _setProUnlocked(bool value) async {
    _isPro = value;
    _isPending = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
