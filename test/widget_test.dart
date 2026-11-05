import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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
    testWidgets('RuposhiCustomerApp renders luxury brand title and navigation',
        (WidgetTester tester) async {
      // Set desktop window size
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const RuposhiCustomerApp());
      await tester.pump();

      // Brand title should be present
      expect(find.text('INTERNATIONAL'), findsWidgets);
      expect(find.text('Shop Catalog'), findsWidgets);
      expect(find.text('B2B Wholesale'), findsWidgets);
    });
  });
}
