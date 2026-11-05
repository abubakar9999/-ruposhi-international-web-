import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';

enum AppView { home, shop, productDetails, aboutUs, beautyBlog, b2bPortal, contact, checkout }

class StoreState extends Equatable {
  final AppView currentView;
  final bool isBangla;
  final List<Product> products;
  final bool isLoadingProducts;
  final String selectedCategory;
  final String selectedBrand;
  final String searchQuery;
  final String sortBy;
  final Product? activeProduct;
  final List<CartItem> cart;
  final Set<String> wishlistIds;
  final String couponCode;
  final double discountPercent;
  final bool insideDhaka;
  final bool isB2BAuthenticated;
  final String? b2bError;
  final bool isCustomerLoggedIn;
  final String customerPhone;
  final String? trackedOrderId;
  final String? trackOrderStatus;

  const StoreState({
    this.currentView = AppView.home,
    this.isBangla = false,
    this.products = sampleProducts,
    this.isLoadingProducts = false,
    this.selectedCategory = 'All',
    this.selectedBrand = 'All',
    this.searchQuery = '',
    this.sortBy = 'Featured',
    this.activeProduct,
    this.cart = const [],
    this.wishlistIds = const {'1', '3'},
    this.couponCode = '',
    this.discountPercent = 0,
    this.insideDhaka = true,
    this.isB2BAuthenticated = false,
    this.b2bError,
    this.isCustomerLoggedIn = false,
    this.customerPhone = '',
    this.trackedOrderId,
    this.trackOrderStatus,
  });

  List<Product> get filteredProducts {
    var list = products.where((p) {
      final matchCat = selectedCategory == 'All' || p.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchBrand = selectedBrand == 'All' || p.brand.toLowerCase() == selectedBrand.toLowerCase();
      final q = searchQuery.trim().toLowerCase();
      final matchSearch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.nameBn.contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.originCountry.toLowerCase().contains(q);
      return matchCat && matchBrand && matchSearch;
    }).toList();

    switch (sortBy) {
      case 'Price: Low to High':
        list.sort((a, b) => a.retailPrice.compareTo(b.retailPrice));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.retailPrice.compareTo(a.retailPrice));
        break;
      case 'Top Rated':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Newest':
        list.sort((a, b) => (b.isNewArrival ? 1 : 0).compareTo(a.isNewArrival ? 1 : 0));
        break;
      case 'Featured':
      default:
        list.sort((a, b) => (b.isBestSeller ? 1 : 0).compareTo(a.isBestSeller ? 1 : 0));
        break;
    }

    return list;
  }

  int get totalCartUnits => cart.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);
  double get discountAmount => subtotal * (discountPercent / 100);
  
  // Free delivery above 3,500 BDT
  static const double freeDeliveryThreshold = 3500;
  bool get isFreeDeliveryEligible => subtotal >= freeDeliveryThreshold;
  double get amountNeededForFreeDelivery =>
      subtotal < freeDeliveryThreshold ? (freeDeliveryThreshold - subtotal) : 0;

  double get deliveryFee {
    if (cart.isEmpty) return 0;
    if (isFreeDeliveryEligible) return 0;
    return insideDhaka ? 70 : 130;
  }

  double get grandTotal => (subtotal - discountAmount) + deliveryFee;

  bool isWishlisted(String productId) => wishlistIds.contains(productId);

  StoreState copyWith({
    AppView? currentView,
    bool? isBangla,
    List<Product>? products,
    bool? isLoadingProducts,
    String? selectedCategory,
    String? selectedBrand,
    String? searchQuery,
    String? sortBy,
    Product? activeProduct,
    List<CartItem>? cart,
    Set<String>? wishlistIds,
    String? couponCode,
    double? discountPercent,
    bool? insideDhaka,
    bool? isB2BAuthenticated,
    String? b2bError,
    bool? isCustomerLoggedIn,
    String? customerPhone,
    String? trackedOrderId,
    String? trackOrderStatus,
  }) {
    return StoreState(
      currentView: currentView ?? this.currentView,
      isBangla: isBangla ?? this.isBangla,
      products: products ?? this.products,
      isLoadingProducts: isLoadingProducts ?? this.isLoadingProducts,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      activeProduct: activeProduct ?? this.activeProduct,
      cart: cart ?? this.cart,
      wishlistIds: wishlistIds ?? this.wishlistIds,
      couponCode: couponCode ?? this.couponCode,
      discountPercent: discountPercent ?? this.discountPercent,
      insideDhaka: insideDhaka ?? this.insideDhaka,
      isB2BAuthenticated: isB2BAuthenticated ?? this.isB2BAuthenticated,
      b2bError: b2bError,
      isCustomerLoggedIn: isCustomerLoggedIn ?? this.isCustomerLoggedIn,
      customerPhone: customerPhone ?? this.customerPhone,
      trackedOrderId: trackedOrderId ?? this.trackedOrderId,
      trackOrderStatus: trackOrderStatus ?? this.trackOrderStatus,
    );
  }

  @override
  List<Object?> get props => [
        currentView,
        isBangla,
        products,
        isLoadingProducts,
        selectedCategory,
        selectedBrand,
        searchQuery,
        sortBy,
        activeProduct,
        cart,
        wishlistIds,
        couponCode,
        discountPercent,
        insideDhaka,
        isB2BAuthenticated,
        b2bError,
        isCustomerLoggedIn,
        customerPhone,
        trackedOrderId,
        trackOrderStatus,
      ];
}

class StoreCubit extends Cubit<StoreState> {
  StoreCubit() : super(const StoreState());

  Future<void> loadProducts() async {
    emit(state.copyWith(isLoadingProducts: true));
    try {
      final fetched = await SupabaseService.fetchProducts();
      emit(state.copyWith(products: fetched, isLoadingProducts: false));
    } catch (_) {
      emit(state.copyWith(products: sampleProducts, isLoadingProducts: false));
    }
  }

  void navigateTo(AppView view, {Product? product, String? category}) {
    emit(state.copyWith(
      currentView: view,
      activeProduct: product ?? state.activeProduct,
      selectedCategory: category ?? state.selectedCategory,
      b2bError: null,
    ));
  }

  void toggleLanguage() {
    emit(state.copyWith(isBangla: !state.isBangla));
  }

  void setCategory(String category) {
    emit(state.copyWith(selectedCategory: category, currentView: AppView.shop));
  }

  void setBrand(String brand) {
    emit(state.copyWith(selectedBrand: brand));
  }

  void setSearch(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void setSortBy(String sortBy) {
    emit(state.copyWith(sortBy: sortBy));
  }

  void toggleWishlist(String productId) {
    final updated = Set<String>.from(state.wishlistIds);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    emit(state.copyWith(wishlistIds: updated));
  }

  void addToCart(Product product, {int qty = 1, String? option, bool isWholesale = false}) {
    final chosenOption = option ?? product.shadesOrSizes.first;
    final existingIndex = state.cart.indexWhere(
      (i) => i.product.id == product.id && i.selectedOption == chosenOption && i.isWholesale == isWholesale,
    );

    final updated = List<CartItem>.from(state.cart);
    if (existingIndex >= 0) {
      final current = updated[existingIndex];
      updated[existingIndex] = current.copyWith(quantity: current.quantity + qty);
    } else {
      updated.add(CartItem(
        product: product,
        quantity: qty,
        selectedOption: chosenOption,
        isWholesale: isWholesale,
      ));
    }
    emit(state.copyWith(cart: updated));
  }

  void updateCartQty(int index, int delta) {
    if (index < 0 || index >= state.cart.length) return;
    final updated = List<CartItem>.from(state.cart);
    final item = updated[index];
    final minQty = item.isWholesale ? item.product.moq : 1;
    final nextQty = item.quantity + delta;
    if (nextQty < minQty) {
      updated.removeAt(index);
    } else {
      updated[index] = item.copyWith(quantity: nextQty);
    }
    emit(state.copyWith(cart: updated));
  }

  void removeFromCart(int index) {
    if (index < 0 || index >= state.cart.length) return;
    final updated = List<CartItem>.from(state.cart);
    updated.removeAt(index);
    emit(state.copyWith(cart: updated));
  }

  bool applyCoupon(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'RUPOSHI10') {
      emit(state.copyWith(couponCode: 'RUPOSHI10', discountPercent: 10));
      return true;
    } else if (cleanCode == 'LUXE15') {
      emit(state.copyWith(couponCode: 'LUXE15', discountPercent: 15));
      return true;
    } else {
      emit(state.copyWith(couponCode: cleanCode, discountPercent: 0));
      return false;
    }
  }

  void toggleDeliveryZone(bool insideDhaka) {
    emit(state.copyWith(insideDhaka: insideDhaka));
  }

  void loginB2B(String username, String password) {
    if (username.trim() == 'aaaa' && password.trim() == 'aaaa') {
      emit(state.copyWith(isB2BAuthenticated: true, b2bError: null));
    } else {
      emit(state.copyWith(
        isB2BAuthenticated: false,
        b2bError: 'Invalid credentials! Use demo login -> Username: aaaa & Password: aaaa',
      ));
    }
  }

  void logoutB2B() {
    emit(state.copyWith(isB2BAuthenticated: false, b2bError: null));
  }

  void loginCustomerOtp(String phone) {
    emit(state.copyWith(isCustomerLoggedIn: true, customerPhone: phone));
  }

  void logoutCustomer() {
    emit(state.copyWith(isCustomerLoggedIn: false, customerPhone: ''));
  }

  void trackOrder(String orderId) {
    final id = orderId.trim();
    if (id.isEmpty) {
      emit(state.copyWith(trackedOrderId: null, trackOrderStatus: null));
      return;
    }
    // Simulate lookup / check Supabase
    emit(state.copyWith(
      trackedOrderId: id,
      trackOrderStatus: 'Dispatched from Dhaka Central Cold Hub • In Transit via Express Courier (Cash on Delivery).',
    ));
  }

  void clearCart() {
    emit(state.copyWith(cart: [], discountPercent: 0, couponCode: ''));
  }
}
