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

// 8 Official Products from Ruposhi International Google Site Embed
const List<Product> sampleProducts = [
  Product(
    id: '1',
    name: 'The Ordinary Niacinamide 10% + Zinc 1% Serum',
    nameBn: 'নায়াসিনামাইড ১০% + জিঙ্ক ১% সিরাম',
    brand: 'The Ordinary',
    category: 'Skincare',
    originCountry: 'Canada',
    countryFlag: '🇨🇦',
    skinType: 'Oily & Acne-Prone',
    retailPrice: 1450,
    oldPrice: 1750,
    wholesalePrice: 980,
    moq: 12,
    batchNo: 'ORD-2609A',
    expiryDate: 'Oct 2028',
    imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=700&q=85',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=700&q=85',
      'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=700&q=80'
    ],
    shadesOrSizes: ['30ml Dropper', '60ml Economy'],
    description: 'High-strength vitamin and mineral blemish formula that visibly regulates sebum and minimizes enlarged pores.',
    descriptionBn: 'অতিরিক্ত তেল নিঃসরণ কমায়, লোমকূপ সঙ্কুচিত করে এবং ত্বকের কালচে দাগ দূর করে মসৃণ উজ্জ্বলতা দেয়।',
    ingredients: 'Aqua (Water), Niacinamide (10%), Pentylene Glycol, Zinc PCA (1%), Dimethyl Isosorbide, Tamarindus Indica Seed Gum.',
    usageInstructions: 'Apply 2-3 drops to the entire face morning and evening before heavier creams.',
    isBestSeller: true,
    rating: 4.9,
    reviewsCount: 312,
    keyBenefits: ['Regulates sebum activity', 'Minimizes enlarged pores', 'Even skin tone'],
  ),
  Product(
    id: '2',
    name: 'COSRX Advanced Snail 96 Mucin Power Essence',
    nameBn: 'অ্যাডভান্সড স্নেইল ৯৬ মিউসিন পাওয়ার এসেন্স',
    brand: 'COSRX',
    category: 'Skincare',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    skinType: 'All Skin Types',
    retailPrice: 1850,
    oldPrice: 2200,
    wholesalePrice: 1290,
    moq: 12,
    batchNo: 'KR-CSX992',
    expiryDate: 'Dec 2028',
    imageUrl: 'https://images.unsplash.com/photo-1608248597359-0e6d526a6828?auto=format&fit=crop&w=700&q=85',
    gallery: [
      'https://images.unsplash.com/photo-1608248597359-0e6d526a6828?auto=format&fit=crop&w=700&q=85',
      'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=700&q=80'
    ],
    shadesOrSizes: ['100ml Standard'],
    description: 'Authentic Korean glass-skin essence formulated with 96.3% Snail Secretion Filtrate to repair and deeply hydrate.',
    descriptionBn: '৯৬.৩% স্নেইল সিক্রেশন ফিল্ট্রেট সমৃদ্ধ যা ত্বকের আর্দ্রতা ধরে রেখে কোলাজেন বুস্ট করে।',
    ingredients: 'Snail Secretion Filtrate, Betaine, Butylene Glycol, 1,2-Hexanediol, Sodium Polyacrylate, Panthenol, Allantoin.',
    usageInstructions: 'After cleansing and toning, apply a small amount on your entire face and gently pat using fingertips.',
    isBestSeller: true,
    rating: 4.95,
    reviewsCount: 420,
    keyBenefits: ['Deep cellular hydration', 'Soothes redness & damaged skin', 'Authentic Korean Glass Skin'],
  ),
  Product(
    id: '3',
    name: 'MAC Retro Matte Lipstick — Ruby Woo',
    nameBn: 'রেট্রো ম্যাট লিপস্টিক — রুবি উ',
    brand: 'MAC Cosmetics',
    category: 'Makeup',
    originCountry: 'USA',
    countryFlag: '🇺🇸',
    skinType: 'All Skin Types',
    retailPrice: 2950,
    oldPrice: 3400,
    wholesalePrice: 2150,
    moq: 10,
    batchNo: 'MAC-US441',
    expiryDate: 'Aug 2028',
    imageUrl: 'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=700&q=85',
    gallery: [
      'https://images.unsplash.com/photo-1586495777744-4413f21062fa?auto=format&fit=crop&w=700&q=85',
      'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=700&q=80'
    ],
    shadesOrSizes: ['Ruby Woo (Vivid Blue-Red)', 'Velvet Teddy', 'Lady Danger'],
    description: 'The iconic vivid blue-red lipstick with full-coverage payoff and a completely zero-shine matte finish.',
    descriptionBn: 'আইকনিক রুবি উ কালার যা ৮ ঘণ্টা পর্যন্ত কোনো স্মাজ ছাড়া ঠোঁটকে দেয় ভেলভেটি ম্যাট ফিনিশ।',
    ingredients: 'Dimethicone, Isoeicosane, Kaolin, Ceresin, Paraffin, Isononyl Isononanoate, Microcrystalline Wax.',
    usageInstructions: 'Apply directly to lips from the bullet or use a lip brush for runway precision.',
    isBestSeller: true,
    rating: 4.9,
    reviewsCount: 188,
    keyBenefits: ['8-hour stay proof', 'Intense vivid pigmentation', 'Non-feathering velvety texture'],
  ),
  Product(
    id: '4',
    name: 'CeraVe Hydrating Facial Cleanser (473ml)',
    nameBn: 'হাইড্রেটিং ফেসিয়াল ক্লিনজার',
    brand: 'CeraVe',
    category: 'Skincare',
    originCountry: 'USA',
    countryFlag: '🇺🇸',
    skinType: 'Dry & Sensitive',
    retailPrice: 2100,
    oldPrice: 2450,
    wholesalePrice: 1520,
    moq: 12,
    batchNo: 'CRV-8812U',
    expiryDate: 'Jan 2029',
    imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=700&q=85',
    gallery: [
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=700&q=85'
    ],
    shadesOrSizes: ['236ml Pump', '473ml Family Size'],
    description: 'Developed with dermatologists, this gentle cleanser contains 3 essential ceramides and hyaluronic acid to restore skin barrier.',
    descriptionBn: 'ত্বকের প্রাকৃতিক আর্দ্রতা স্তর বজায় রেখে ময়লা ও মেকআপ দূর করে মসৃণ রাখে।',
    ingredients: 'Purified Water, Glycerin, Behentrimonium Methosulfate, Ceramide NP, Ceramide AP, Ceramide EOP, Hyaluronic Acid.',
    usageInstructions: 'Wet skin with lukewarm water. Massage cleanser into skin in a gentle, circular motion and rinse.',
    isBestSeller: true,
    rating: 4.85,
    reviewsCount: 390,
    keyBenefits: ['Non-comedogenic & fragrance free', '3 Essential Ceramides', 'Restores protective barrier'],
  ),
  Product(
    id: '5',
    name: 'Laneige Lip Sleeping Mask — Berry (20g)',
    nameBn: 'লিপ স্লিপিং মাস্ক — বেরি',
    brand: 'Laneige',
    category: 'Skincare',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    skinType: 'Dry & Sensitive Lips',
    retailPrice: 1950,
    oldPrice: 2300,
    wholesalePrice: 1380,
    moq: 10,
    batchNo: 'LNG-KR309',
    expiryDate: 'Sep 2028',
    imageUrl: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=700&q=85',
    gallery: [
      'https://images.unsplash.com/photo-1596462502278-27bfdc403348?auto=format&fit=crop&w=700&q=85'
    ],
    shadesOrSizes: ['20g Berry Jar'],
    description: 'Leave-on overnight lip mask powered by Korean Berry Mix Complex™ and Vitamin C for baby-soft lips.',
    descriptionBn: 'রাতের বেলা ঠোঁটে ব্যবহার উপযোগী বিশেষ বেরি মাস্ক যা ফাটা ঠোঁট সারিয়ে নরম গোলাপি করে।',
    ingredients: 'Diisostearyl Malate, Hydrogenated Polyisobutene, Shea Butter, Murumuru Seed Butter, Ascorbic Acid.',
    usageInstructions: 'Apply generously to the lips in the evening before going to bed and wipe gently the next morning.',
    isNewArrival: true,
    rating: 4.9,
    reviewsCount: 210,
    keyBenefits: ['Berry Mix Complex™', 'Deep overnight softening', 'Antioxidant Vitamin C'],
  ),
  Product(
    id: '6',
    name: 'Maybelline Fit Me Matte + Poreless Foundation',
    nameBn: 'ফিট মি ম্যাট + পোরলেস ফাউন্ডেশন',
    brand: 'Maybelline',
    category: 'Makeup',
    originCountry: 'USA',
    countryFlag: '🇺🇸',
    skinType: 'Normal to Oily',
    retailPrice: 1150,
    oldPrice: 1350,
    wholesalePrice: 790,
    moq: 15,
    batchNo: 'MBL-228B',
    expiryDate: 'May 2028',
    imageUrl: 'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=700&q=85',
    gallery: [
      'https://images.unsplash.com/photo-1631214524020-7e18db9a8f92?auto=format&fit=crop&w=700&q=85'
    ],
    shadesOrSizes: ['115 Ivory', '120 Classic Ivory', '128 Warm Nude', '220 Natural Beige'],
    description: 'Ultra-blendable liquid foundation with micro-powders that control shine and blur pores in humid weather.',
    descriptionBn: 'হালকা ওভেন ফিনিশ ফাউন্ডেশন যা বাংলাদেশের আর্দ্র আবহাওয়ায় ১২ ঘণ্টা ম্যাট থাকে।',
    ingredients: 'Aqua, Cyclohexasiloxane, Nylon-12, Isododecane, Alcohol Denat., Tocopherol, Titanium Dioxide.',
    usageInstructions: 'Apply foundation onto skin and blend with fingertips or a damp beauty sponge.',
    isBestSeller: true,
    rating: 4.75,
    reviewsCount: 310,
    keyBenefits: ['Blur pores & oil control', 'Natural seamless matte finish', 'All-day wear in BD climate'],
  ),
  Product(
    id: '7',
    name: "L'Oréal Professionnel Absolut Repair Gold Mask",
    nameBn: 'অ্যাবসলিউট রিপেয়ার গোল্ড মাস্ক',
    brand: "L'Oréal Paris",
    category: 'Haircare',
    originCountry: 'France',
    countryFlag: '🇫🇷',
    skinType: 'Damaged Hair',
    retailPrice: 2450,
    oldPrice: 2800,
    wholesalePrice: 1790,
    moq: 10,
    batchNo: 'LOR-FR710',
    expiryDate: 'Nov 2028',
    imageUrl: 'https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?auto=format&fit=crop&w=700&q=85',
    gallery: [
      'https://images.unsplash.com/photo-1527799820374-dcf8d9d4a388?auto=format&fit=crop&w=700&q=85'
    ],
    shadesOrSizes: ['250ml Luxury Tub', '500ml Salon Size'],
    description: 'French salon-grade resurfacing hair mask infused with Gold Quinoa + Protein for damaged hair.',
    descriptionBn: 'গোল্ড কুইনোয়া সমৃদ্ধ হেয়ার মাস্ক যা ক্ষতিগ্রস্ত চুলকে সিল্কি ও উজ্জ্বল করে তোলে।',
    ingredients: 'Aqua, Cetearyl Alcohol, Behentrimonium Chloride, Chenopodium Quinoa Seed Extract, Hydrolyzed Wheat Protein.',
    usageInstructions: 'After shampooing, apply to towel-dried hair. Leave in for 3 to 5 minutes then rinse thoroughly.',
    isNewArrival: true,
    rating: 4.85,
    reviewsCount: 165,
    keyBenefits: ['Gold Quinoa + Protein', 'Instant salon restoration', '77% less fiber surface damage'],
  ),
  Product(
    id: '8',
    name: 'Miss Dior Blooming Bouquet Eau De Toilette (100ml)',
    nameBn: 'মিস ডিওর ব্লুমিং বুকে পারফিউম',
    brand: 'Dior Beauty',
    category: 'Fragrance',
    originCountry: 'France',
    countryFlag: '🇫🇷',
    skinType: 'All Profiles',
    retailPrice: 12800,
    oldPrice: 14500,
    wholesalePrice: 9800,
    moq: 4,
    batchNo: 'DIR-FR019',
    expiryDate: 'Dec 2029',
    imageUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=700&q=85',
    gallery: [
      'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=700&q=85'
    ],
    shadesOrSizes: ['50ml Spray', '100ml Flacon'],
    description: 'An authentic French floral couture fragrance crafted with Peony, Damascus Rose, and White Musk.',
    descriptionBn: 'ফ্রান্স থেকে আমদানিকৃত মিস ডিওর যা পিওনি ও ডামাস্কাস গোলাপের রাজকীয় সৌরভ দেয়।',
    ingredients: 'Alcohol, Parfum (Fragrance), Aqua, Limonene, Linalool, Citronellol, Rosa Damascena Flower Water.',
    usageInstructions: 'Spritz onto pulse points (wrists, neck, and behind ears).',
    isNewArrival: true,
    rating: 4.95,
    reviewsCount: 94,
    keyBenefits: ['French Haute Couture Floral', 'Damascus Rose & Peony notes', 'Long-lasting luxury sillage'],
  ),
];
