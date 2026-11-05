import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String nameBn;
  final String brand;
  final String category;
  final String originCountry;
  final String countryFlag;
  final double retailPrice;
  final double? oldPrice;
  final double wholesalePrice;
  final int moq;
  final String batchNo;
  final String expiryDate;
  final String skinType;
  final List<String> shadesOrSizes;
  final String description;
  final String descriptionBn;
  final String ingredients;
  final String usageInstructions;
  final String imageUrl;
  final List<String> gallery;
  final bool isNewArrival;
  final bool isBestSeller;
  final int stock;
  final double rating;
  final int reviewsCount;
  final List<String> keyBenefits;

  const Product({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.brand,
    required this.category,
    required this.originCountry,
    this.countryFlag = '✨',
    required this.retailPrice,
    this.oldPrice,
    required this.wholesalePrice,
    this.moq = 10,
    required this.batchNo,
    required this.expiryDate,
    required this.skinType,
    this.shadesOrSizes = const ['Standard Size'],
    required this.description,
    this.descriptionBn = '',
    required this.ingredients,
    required this.usageInstructions,
    required this.imageUrl,
    this.gallery = const [],
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.stock = 50,
    this.rating = 4.9,
    this.reviewsCount = 142,
    this.keyBenefits = const [],
  });

  int get discountPercent {
    if (oldPrice == null || oldPrice! <= retailPrice) return 0;
    return (((oldPrice! - retailPrice) / oldPrice!) * 100).round();
  }

  @override
  List<Object?> get props => [id, name, retailPrice, wholesalePrice, stock, rating];
}

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final String selectedOption;
  final bool isWholesale;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.selectedOption,
    this.isWholesale = false,
  });

  double get unitPrice => isWholesale ? product.wholesalePrice : product.retailPrice;
  double get total => unitPrice * quantity;

  CartItem copyWith({int? quantity, String? selectedOption, bool? isWholesale}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      selectedOption: selectedOption ?? this.selectedOption,
      isWholesale: isWholesale ?? this.isWholesale,
    );
  }

  @override
  List<Object?> get props => [product.id, quantity, selectedOption, isWholesale];
}

/// Catalog is dynamically loaded from Supabase 'products' table.
const List<Product> sampleProducts = [];
