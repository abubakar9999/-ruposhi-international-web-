import 'dart:developer' as dev;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://eisxuqlnznaixjgkjndc.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_W5jx58z6zjiT-KFZKIDOVw_tPHzLkC4';

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
      _isInitialized = true;
      dev.log('Supabase initialized successfully with $supabaseUrl');
    } catch (e) {
      _isInitialized = false;
      dev.log('Supabase initialization notice (fallback active): $e');
    }
  }

  static SupabaseClient? get client {
    if (!_isInitialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Fetches products from Supabase 'products' table, falling back to sample products if empty or table doesn't exist yet
  static Future<List<Product>> fetchProducts() async {
    if (client == null) return sampleProducts;
    try {
      final response = await client!.from('products').select();
      if (response.isNotEmpty) {
        return (response as List<dynamic>).map((row) {
          final map = row as Map<String, dynamic>;
          return Product(
            id: map['id']?.toString() ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
            name: map['title'] ?? map['name'] ?? '',
            nameBn: map['title_bn'] ?? map['name_bn'] ?? map['title'] ?? '',
            brand: map['brand'] ?? 'Imported Luxury',
            category: map['category'] ?? 'Skincare',
            originCountry: map['origin'] ?? map['origin_country'] ?? 'Global',
            countryFlag: map['flag'] ?? '✨',
            retailPrice: (map['price'] as num?)?.toDouble() ?? 1000.0,
            oldPrice: (map['old_price'] as num?)?.toDouble(),
            wholesalePrice: (map['wholesale_price'] as num?)?.toDouble() ?? 800.0,
            moq: (map['moq'] as num?)?.toInt() ?? 10,
            batchNo: map['batch'] ?? map['batch_no'] ?? 'RUP-2026',
            expiryDate: map['expiry'] ?? map['expiry_date'] ?? '2028',
            skinType: map['skin_type'] ?? 'All Skin Types',
            shadesOrSizes: map['shades'] != null
                ? List<String>.from(map['shades'])
                : ['Standard Size'],
            description: map['short_desc'] ?? map['description'] ?? '',
            descriptionBn: map['description_bn'] ?? '',
            ingredients: map['ingredients'] ?? '',
            usageInstructions: map['usage'] ?? map['usage_instructions'] ?? '',
            imageUrl: map['img'] ?? map['image_url'] ?? '',
            isBestSeller: map['is_best_seller'] ?? (map['badge'] == 'Best Seller'),
            isNewArrival: map['is_new_arrival'] ?? (map['badge'] == 'New Arrival'),
            rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
            reviewsCount: (map['reviews_count'] as num?)?.toInt() ?? 120,
            stock: (map['stock'] as num?)?.toInt() ?? 50,
          );
        }).toList();
      }
    } catch (e) {
      dev.log('Supabase products query fallback: $e');
    }
    return sampleProducts;
  }

  /// Inserts a new order into the Supabase 'orders' table
  static Future<bool> createOrder({
    required String orderId,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String city,
    required String paymentMethod,
    required double subtotal,
    required double deliveryFee,
    required double grandTotal,
    required List<Map<String, dynamic>> items,
  }) async {
    if (client == null) return false;
    try {
      await client!.from('orders').insert({
        'order_id': orderId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'delivery_address': customerAddress,
        'city': city,
        'payment_method': paymentMethod,
        'subtotal': subtotal,
        'delivery_fee': deliveryFee,
        'grand_total': grandTotal,
        'items': items,
        'status': 'Confirmed',
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      dev.log('Supabase createOrder notice: $e');
      return false;
    }
  }

  /// Adds a new product to Supabase 'products' table
  static Future<bool> addProduct(Product product) async {
    if (client == null) return false;
    try {
      await client!.from('products').insert({
        'id': product.id,
        'title': product.name,
        'title_bn': product.nameBn,
        'brand': product.brand,
        'category': product.category,
        'origin': product.originCountry,
        'flag': product.countryFlag,
        'price': product.retailPrice,
        'old_price': product.oldPrice,
        'wholesale_price': product.wholesalePrice,
        'moq': product.moq,
        'batch': product.batchNo,
        'expiry': product.expiryDate,
        'skin_type': product.skinType,
        'shades': product.shadesOrSizes,
        'short_desc': product.description,
        'description_bn': product.descriptionBn,
        'ingredients': product.ingredients,
        'usage': product.usageInstructions,
        'img': product.imageUrl,
        'is_best_seller': product.isBestSeller,
        'is_new_arrival': product.isNewArrival,
        'stock': product.stock,
        'rating': product.rating,
        'reviews_count': product.reviewsCount,
      });
      return true;
    } catch (e) {
      dev.log('Supabase addProduct notice: $e');
      return false;
    }
  }

  /// Updates an existing product in Supabase 'products' table
  static Future<bool> updateProduct(Product product) async {
    if (client == null) return false;
    try {
      await client!.from('products').update({
        'title': product.name,
        'title_bn': product.nameBn,
        'brand': product.brand,
        'category': product.category,
        'origin': product.originCountry,
        'flag': product.countryFlag,
        'price': product.retailPrice,
        'old_price': product.oldPrice,
        'wholesale_price': product.wholesalePrice,
        'moq': product.moq,
        'batch': product.batchNo,
        'expiry': product.expiryDate,
        'skin_type': product.skinType,
        'shades': product.shadesOrSizes,
        'short_desc': product.description,
        'description_bn': product.descriptionBn,
        'ingredients': product.ingredients,
        'usage': product.usageInstructions,
        'img': product.imageUrl,
        'is_best_seller': product.isBestSeller,
        'is_new_arrival': product.isNewArrival,
        'stock': product.stock,
      }).eq('id', product.id);
      return true;
    } catch (e) {
      dev.log('Supabase updateProduct notice: $e');
      return false;
    }
  }

  /// Deletes a product from Supabase 'products' table
  static Future<bool> deleteProduct(String productId) async {
    if (client == null) return false;
    try {
      await client!.from('products').delete().eq('id', productId);
      return true;
    } catch (e) {
      dev.log('Supabase deleteProduct notice: $e');
      return false;
    }
  }

  /// Updates an order status and courier info in Supabase
  static Future<bool> updateOrderStatus(
    String orderId,
    String status, {
    String? courier,
    String? trackingCode,
  }) async {
    if (client == null) return false;
    try {
      final payload = <String, dynamic>{'status': status};
      if (courier != null) payload['courier'] = courier;
      if (trackingCode != null) payload['tracking_code'] = trackingCode;
      await client!.from('orders').update(payload).eq('order_id', orderId);
      return true;
    } catch (e) {
      dev.log('Supabase updateOrderStatus notice: $e');
      return false;
    }
  }
}
