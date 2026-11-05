import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruposhi_international/cubits/store_cubit.dart';
import 'package:ruposhi_international/models/product_model.dart';
import 'package:ruposhi_international/main.dart';

// 1x1 transparent PNG data for network image mocking in widget tests
final _transparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getUrl) {
      return Future.value(_MockHttpClientRequest());
    }
    return null;
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #close) {
      return Future.value(_MockHttpClientResponse());
    }
    return super.noSuchMethod(invocation);
  }
}

class _MockHttpClientResponse implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => _transparentPng.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream.value(_transparentPng).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
  });

  group('StoreCubit Unit Tests', () {
    late StoreCubit cubit;

    setUp(() {
      cubit = StoreCubit();
    });

    test('Initial state has default view, sample products, and empty cart', () {
      expect(cubit.state.currentView, AppView.home);
      expect(cubit.state.products.isNotEmpty, true);
      expect(cubit.state.cart, isEmpty);
      expect(cubit.state.isBangla, false);
      expect(cubit.state.isB2BAuthenticated, false);
    });

    test('Language toggle updates isBangla', () {
      cubit.toggleLanguage();
      expect(cubit.state.isBangla, true);
      cubit.toggleLanguage();
      expect(cubit.state.isBangla, false);
    });

    test('Add to cart increases total units and subtotal', () {
      final product = sampleProducts.first;
      cubit.addToCart(product, qty: 2);
      expect(cubit.state.cart.length, 1);
      expect(cubit.state.totalCartUnits, 2);
      expect(cubit.state.subtotal, product.retailPrice * 2);
    });

    test('Coupon RUPOSHI10 gives 10% discount', () {
      final product = sampleProducts.first;
      cubit.addToCart(product, qty: 1);
      final applied = cubit.applyCoupon('RUPOSHI10');
      expect(applied, true);
      expect(cubit.state.discountPercent, 10);
      expect(cubit.state.discountAmount, product.retailPrice * 0.1);
    });

    test('B2B login works with demo credentials', () {
      cubit.loginB2B('aaaa', 'aaaa');
      expect(cubit.state.isB2BAuthenticated, true);
      expect(cubit.state.b2bError, isNull);

      cubit.logoutB2B();
      expect(cubit.state.isB2BAuthenticated, false);
    });

    test('Wishlist toggle adds and removes product id', () {
      cubit.toggleWishlist('p1');
      expect(cubit.state.isWishlisted('p1'), true);
      cubit.toggleWishlist('p1');
      expect(cubit.state.isWishlisted('p1'), false);
    });
  });

  group('Widget Tests', () {
    testWidgets('RuposhiCustomerApp renders luxury brand title and navigation on desktop (1400x900)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      expect(find.text('INTERNATIONAL'), findsWidgets);
      expect(find.text('Shop Catalog'), findsWidgets);
      expect(find.text('B2B Wholesale'), findsWidgets);
    });

    testWidgets('RuposhiCustomerApp renders adaptively on tablet (768x1024)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(768, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      expect(find.text('INTERNATIONAL'), findsWidgets);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    });

    testWidgets('RuposhiCustomerApp renders adaptively on mobile (375x812) with 0 overflows',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      expect(find.text('INTERNATIONAL'), findsWidgets);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);
    });

    testWidgets('RuposhiCustomerApp renders on compact mobile (320x568) with 0 overflows',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      expect(find.text('INTERNATIONAL'), findsWidgets);
      expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    });

    testWidgets('Mobile drawer navigation opens all views with 0 layout overflows',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      // Open drawer
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      expect(find.text('RUPOSHI INTERNATIONAL'), findsWidgets);
      final drawerShopItem = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Cosmetics Catalog'),
      );
      expect(drawerShopItem, findsOneWidget);

      // Navigate to Shop
      await tester.tap(drawerShopItem);
      await tester.pumpAndSettle();
      expect(find.text('Imported Cosmetics Catalog'), findsOneWidget);

      // Open drawer again and navigate to Beauty Blog
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      final drawerBlogItem = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Beauty Blog & Guides'),
      );
      await tester.tap(drawerBlogItem);
      await tester.pumpAndSettle();
      expect(find.text('RUPOSHI BEAUTY & AUTHENTICITY BLOG'), findsOneWidget);

      // Open drawer again and navigate to Contact & Tracking
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      final drawerContactItem = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Contact & Live Tracking'),
      );
      await tester.tap(drawerContactItem);
      await tester.pumpAndSettle();
      expect(find.text('Track Your Order'), findsOneWidget);

      // Open drawer again and navigate to B2B Wholesale Portal
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      final drawerB2BItem = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('B2B Wholesale Portal'),
      );
      await tester.tap(drawerB2BItem);
      await tester.pumpAndSettle();
      expect(find.text('B2B Wholesale Dealer Gate'), findsOneWidget);

      // Open drawer again and navigate to Our Story & Warehousing
      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();
      final drawerAboutItem = find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Our Story & Warehousing'),
      );
      await tester.tap(drawerAboutItem);
      await tester.pumpAndSettle();
      expect(find.text('ABOUT RUPOSHI INTERNATIONAL'), findsWidgets);
    });

    testWidgets('Checkout and Cart Drawer render without overflow on compact mobile (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      // Open shopping bag drawer when empty
      final bagButton = find.byIcon(Icons.shopping_bag_outlined).first;
      await tester.tap(bagButton);
      await tester.pumpAndSettle();

      expect(find.text('Your Beauty Bag'), findsOneWidget);
      expect(find.text('Your bag is empty'), findsOneWidget);

      // Close drawer
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Add product via cubit and open cart drawer
      final cubit = tester.element(find.byType(Scaffold).first).read<StoreCubit>();
      cubit.addToCart(cubit.state.products.first);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.shopping_bag_outlined).first);
      await tester.pumpAndSettle();

      final checkoutBtn = find.text('Proceed to Checkout');
      expect(checkoutBtn, findsOneWidget);
      await tester.tap(checkoutBtn);
      await tester.pumpAndSettle();

      expect(find.text('Delivery & Express Checkout'), findsOneWidget);
      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('Product Details view renders without overflow on compact mobile (320x568)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      final cubit = tester.element(find.byType(Scaffold).first).read<StoreCubit>();
      cubit.navigateTo(AppView.productDetails, product: cubit.state.products.first);
      await tester.pumpAndSettle();

      // Check product details view renders cleanly
      expect(find.text('Imported from ${cubit.state.products.first.originCountry}'), findsWidgets);
      expect(find.text('Add to Beauty Bag'), findsOneWidget);
    });

    testWidgets('B2B authenticated portal renders without overflow on 320x568 and 768x1024',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      final cubit = tester.element(find.byType(Scaffold).first).read<StoreCubit>();
      cubit.navigateTo(AppView.b2bPortal);
      cubit.loginB2B('aaaa', 'aaaa');
      await tester.pumpAndSettle();

      expect(find.text('OFFICIAL WHOLESALE DEALER ACTIVE'), findsOneWidget);
      expect(find.text('Lock Portal'), findsWidgets);

      // Lock portal back
      cubit.logoutB2B();
      await tester.pumpAndSettle();
      expect(find.text('B2B Wholesale Dealer Gate'), findsOneWidget);
    });

    testWidgets('TopNavBar has centered nav items including B2B tab across multiple desktop breakpoints',
        (WidgetTester tester) async {
      final desktopResolutions = [
        const Size(1100, 800),
        const Size(1280, 800),
        const Size(1366, 768),
        const Size(1920, 1080),
      ];

      for (final res in desktopResolutions) {
        tester.view.physicalSize = res;
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(const RuposhiCustomerApp());
        await tester.pump();

        // Verify key desktop navigation items are present
        expect(find.text('Home'), findsWidgets);
        expect(find.text('Shop Catalog'), findsWidgets);
        expect(find.text('B2B Wholesale'), findsWidgets);
        expect(find.text('Beauty Blog'), findsWidgets);
        expect(find.text('About Us'), findsWidgets);
        expect(find.text('Contact'), findsWidgets);
      }

      // Test tapping B2B Wholesale pill navigates to B2B portal
      final b2bTab = find.text('B2B Wholesale').first;
      await tester.tap(b2bTab);
      await tester.pumpAndSettle();

      expect(find.text('B2B Wholesale Dealer Gate'), findsOneWidget);
    });

    testWidgets('Admin Management Console authentication and section switching works cleanly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      final cubit = tester.element(find.byType(Scaffold).first).read<StoreCubit>();

      // Navigate to Admin Gate
      cubit.navigateTo(AppView.admin);
      await tester.pumpAndSettle();

      expect(find.text('Executive Business Management Console'), findsOneWidget);
      expect(find.text('Enter Executive Console'), findsOneWidget);

      // Perform Admin Login
      cubit.loginAdmin('admin', 'admin123');
      await tester.pumpAndSettle();

      // Check Admin Console is active
      expect(find.text('RUPOSHI ADMIN'), findsOneWidget);
      expect(find.text('Welcome to Ruposhi International Executive Suite'), findsOneWidget);
      expect(find.text('Executive Overview'), findsWidgets);
      expect(find.text('Products & Inventory'), findsWidgets);

      // Test section switching
      final productsTile = find.text('Products & Inventory').first;
      await tester.tap(productsTile);
      await tester.pumpAndSettle();

      expect(find.text('Cosmetics Catalog & Warehouse Inventory'), findsOneWidget);
      expect(find.text('+ Add New SKU'), findsOneWidget);

      // Switch to Orders section
      final ordersTile = find.text('Orders & Shipping').first;
      await tester.tap(ordersTile);
      await tester.pumpAndSettle();

      expect(find.text('Customer Orders & Express Fulfillment'), findsOneWidget);

      // Logout Admin
      cubit.logoutAdmin();
      await tester.pumpAndSettle();

      expect(find.text('INTERNATIONAL'), findsWidgets);
    });
  });
}
