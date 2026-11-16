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

  /// Returns at least 5 high-resolution imagery angles (matching bioxin.com multi-image standard)
  List<String> get allImages {
    final list = <String>[];
    if (imageUrl.trim().isNotEmpty) {
      list.add(imageUrl.trim());
    }
    for (final item in gallery) {
      final clean = item.trim();
      if (clean.isNotEmpty && !list.contains(clean)) {
        list.add(clean);
      }
    }

    if (list.isEmpty) {
      list.add('https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80');
    }

    // Cohesive, premium dermo-cosmetics visual angles to ensure every product has at least 5 view angles
    final fallbackAngles = [
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80', // Texture / formula swatch
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80', // Bottle profile / angle
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80', // Packaging box & seal
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80', // Skincare application
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80', // Pure ingredients / aesthetic
    ];

    int idx = 0;
    while (list.length < 5 && idx < fallbackAngles.length) {
      final angle = fallbackAngles[idx];
      if (!list.contains(angle)) {
        list.add(angle);
      }
      idx++;
    }

    return list;
  }

  Product copyWith({
    String? id,
    String? name,
    String? nameBn,
    String? brand,
    String? category,
    String? originCountry,
    String? countryFlag,
    double? retailPrice,
    double? oldPrice,
    double? wholesalePrice,
    int? moq,
    String? batchNo,
    String? expiryDate,
    String? skinType,
    List<String>? shadesOrSizes,
    String? description,
    String? descriptionBn,
    String? ingredients,
    String? usageInstructions,
    String? imageUrl,
    List<String>? gallery,
    bool? isNewArrival,
    bool? isBestSeller,
    int? stock,
    double? rating,
    int? reviewsCount,
    List<String>? keyBenefits,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      originCountry: originCountry ?? this.originCountry,
      countryFlag: countryFlag ?? this.countryFlag,
      retailPrice: retailPrice ?? this.retailPrice,
      oldPrice: oldPrice ?? this.oldPrice,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      moq: moq ?? this.moq,
      batchNo: batchNo ?? this.batchNo,
      expiryDate: expiryDate ?? this.expiryDate,
      skinType: skinType ?? this.skinType,
      shadesOrSizes: shadesOrSizes ?? this.shadesOrSizes,
      description: description ?? this.description,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      ingredients: ingredients ?? this.ingredients,
      usageInstructions: usageInstructions ?? this.usageInstructions,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      isNewArrival: isNewArrival ?? this.isNewArrival,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      stock: stock ?? this.stock,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      keyBenefits: keyBenefits ?? this.keyBenefits,
    );
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

/// Official TIA'M South Korea Dermo-Cosmetics Flagship Catalog (tiamglobal.com)
const List<Product> sampleProducts = [
  Product(
    id: 'tiam_p1_vita_b3_source',
    name: 'TIA\'M Vita B3 Source (10% Niacinamide + 2% Arbutin)',
    nameBn: 'টিআই\'এম ভিটা বি৩ সোর্স সিরাম (১০% নিয়াসিনামাইড ও ২% আরবুটিন)',
    brand: 'TIA\'M',
    category: 'Serums',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1650.0,
    oldPrice: 1950.0,
    wholesalePrice: 1180.0,
    moq: 10,
    batchNo: 'TM-VB3-2026-01',
    expiryDate: '2028-06',
    skinType: 'All Skin Types, Dark Spots & Hyperpigmentation',
    shadesOrSizes: ['40ml Dropper'],
    description: 'High-potency dual brightening serum formulated with 10% Niacinamide and 2% Arbutin to fade post-acne marks, melasma, and hyperpigmentation while balancing excess sebum.',
    descriptionBn: '১০% নিয়াসিনামাইড এবং ২% আরবুটিন সমৃদ্ধ শক্তিশালী ব্রাইটনিং সিরাম। এটি মেছতা, ব্রণের জেদি দাগ দূর করতে এবং অতিরিক্ত তেল নিয়ন্ত্রণ করে ত্বককে উজ্জ্বল করে।',
    ingredients: 'Water, Niacinamide (10%), Butylene Glycol, Arbutin (2%), Allantoin, Dipotassium Glycyrrhizate, Sodium Hyaluronate, Hydroxyethylcellulose, 1,2-Hexanediol.',
    usageInstructions: 'Apply 2-3 drops evenly over cleansed and toned skin morning and evening. Follow with daytime sunscreen.',
    imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: true,
    isNewArrival: false,
    stock: 45,
    rating: 4.9,
    reviewsCount: 218,
    keyBenefits: ['Fades dark spots', 'Evens skin tone', 'Regulates sebum', 'Calms redness'],
  ),
  Product(
    id: 'tiam_p2_pore_minimizing_21',
    name: 'TIA\'M Pore Minimizing 21 Serum (20% Niacinamide + 1% Zinc PCA)',
    nameBn: 'টিআই\'এম পোর মিনিমাইজিং ২১ সিরাম (২০% নিয়াসিনামাইড + জিংক পিসিএ)',
    brand: 'TIA\'M',
    category: 'Serums',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1750.0,
    oldPrice: 2100.0,
    wholesalePrice: 1250.0,
    moq: 10,
    batchNo: 'TM-PM21-2026-02',
    expiryDate: '2028-05',
    skinType: 'Oily, Enlarged Pores & Rough Texture',
    shadesOrSizes: ['40ml Dropper'],
    description: 'Engineered with 20% high-concentration Niacinamide, 1% Zinc PCA, and Willow Bark extract to tighten enlarged pores, regulate oil secretion, and smooth rough skin.',
    descriptionBn: 'উচ্চমাত্রার ২০% নিয়াসিনামাইড এবং ১% জিংক পিসিএ সমৃদ্ধ সিরাম যা বড় হয়ে যাওয়া লোমকূপ সঙ্কুচিত করে, অতিরিক্ত সিবাম উৎপাদন রোধ করে এবং খসখসে ভাব দূর করে মসৃণ করে।',
    ingredients: 'Water, Niacinamide (20%), Butylene Glycol, 1,2-Hexanediol, Zinc PCA (1%), Salix Alba (Willow) Bark Water, Sodium Hyaluronate, Allantoin, Xanthan Gum.',
    usageInstructions: 'Dispense 2-3 drops after toner, gently patting into areas with enlarged pores or excess shine. Use SPF during daytime.',
    imageUrl: 'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: true,
    isNewArrival: false,
    stock: 38,
    rating: 4.9,
    reviewsCount: 176,
    keyBenefits: ['Tightens enlarged pores', 'Controls sebum', 'Clears blackheads', 'Smooths skin texture'],
  ),
  Product(
    id: 'tiam_p3_vita_a_bakuchiol',
    name: 'TIA\'M Vita A Bakuchiol Youth Serum (Retinol Alternative)',
    nameBn: 'টিআই\'এম ভিটা এ বাকুচিওল ইউথ সিরাম (অ্যান্টি-এজিং সিরাম)',
    brand: 'TIA\'M',
    category: 'Serums',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1850.0,
    oldPrice: 2250.0,
    wholesalePrice: 1320.0,
    moq: 10,
    batchNo: 'TM-VAB-2026-03',
    expiryDate: '2028-08',
    skinType: 'Aging, Fine Lines & Loss of Elasticity',
    shadesOrSizes: ['40ml Pump Bottle'],
    description: 'Gentle yet powerful anti-aging youth serum formulated with Vitamin A (Retinyl Palmitate), plant-based Bakuchiol, and Hydrolyzed Collagen to firm and plump without irritation.',
    descriptionBn: 'ভিটামিন এ (রেটিনাইল পালমিটেট), প্রাকৃতিক বাকুচিওল এবং কোলাজেন সমৃদ্ধ তারুণ্যোজ্জ্বল সিরাম যা বলিরেখা ও ফাইন লাইনস কমায় এবং ত্বককে টানটান ও উজ্জ্বল রাখে।',
    ingredients: 'Water, Butylene Glycol, Glycerin, Helianthus Annuus (Sunflower) Seed Oil, Bakuchiol, Retinyl Palmitate, Hydrolyzed Collagen, Adenosine, Tocopherol.',
    usageInstructions: 'Apply evenly onto face and neck during evening routine. Always apply sunscreen the following morning.',
    imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: false,
    isNewArrival: true,
    stock: 50,
    rating: 4.8,
    reviewsCount: 94,
    keyBenefits: ['Reduces fine lines', 'Firms sagging skin', 'Gentle retinol alternative', 'Boosts collagen synthesis'],
  ),
  Product(
    id: 'tiam_p4_snail_azulene_essence',
    name: 'TIA\'M Snail & Azulene Water Essence (87% Snail Mucin)',
    nameBn: 'টিআই\'এম স্নেল অ্যান্ড আজুলিন ওয়াটার এসেন্স (স্কিন বেরিয়ার রিপেয়ার)',
    brand: 'TIA\'M',
    category: 'Toner & Essence',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1750.0,
    oldPrice: 2050.0,
    wholesalePrice: 1250.0,
    moq: 10,
    batchNo: 'TM-SAE-2026-04',
    expiryDate: '2028-09',
    skinType: 'Dry, Sensitive & Damaged Barrier Skin',
    shadesOrSizes: ['180ml Jumbo Bottle'],
    description: 'Intensively hydrating restorative water essence packed with 87% Snail Secretion Filtrate and soothing Guaiazulene to heal damaged skin, relieve redness, and calm irritation.',
    descriptionBn: '৮৭% স্নেল মিউসিন এবং ক্যামোমাইল থেকে প্রাপ্ত আজুলিন সমৃদ্ধ ওয়াটার এসেন্স। এটি ক্ষতিগ্রস্ত স্কিন বেরিয়ার নিরাময় করে, লালচে ভাব দূর করে এবং ত্বকে দীর্ঘস্থায়ী আর্দ্রতা জোগায়।',
    ingredients: 'Snail Secretion Filtrate (87%), Butylene Glycol, Glycerin, Sodium Guaiazulene Sulfonate, Betaine, Allantoin, Panthenol, Sodium Hyaluronate.',
    usageInstructions: 'Pour moderate amount into palms or cotton pad and gently pat across entire face after cleansing until completely absorbed.',
    imageUrl: 'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: true,
    isNewArrival: false,
    stock: 52,
    rating: 4.9,
    reviewsCount: 153,
    keyBenefits: ['Repairs skin barrier', 'Calms chronic redness', 'Deep hydrating glow', 'Non-sticky fast absorption'],
  ),
  Product(
    id: 'tiam_p5_snail_azulene_cleanser',
    name: 'TIA\'M Snail & Azulene Low pH Cleanser (pH 5.5 Balanced)',
    nameBn: 'টিআই\'এম স্নেল অ্যান্ড আজুলিন লো পিএইচ ক্লিনজার (মৃদু ফেসিয়াল ওয়াশ)',
    brand: 'TIA\'M',
    category: 'Cleansers',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1550.0,
    oldPrice: 1800.0,
    wholesalePrice: 1100.0,
    moq: 10,
    batchNo: 'TM-SAC-2026-05',
    expiryDate: '2028-07',
    skinType: 'Sensitive, Acne-Prone & Dehydrated Skin',
    shadesOrSizes: ['200ml Family Pump'],
    description: 'Mild gel cleanser formulated at skin-natural pH 5.5 with Snail Mucin and Guaiazulene to wash away daily dirt, sebum, and fine dust without stripping moisture.',
    descriptionBn: 'ত্বকের প্রাকৃতিক পিএইচ ৫.৫ সমতাযুক্ত মৃদু জেল ক্লিনজার। স্নেল মিউসিন এবং আজুলিন থাকায় ত্বক শুষ্ক না করে গভীর থেকে পরিষ্কার করে এবং প্রশান্তি দেয়।',
    ingredients: 'Water, Snail Secretion Filtrate, Cocamidopropyl Betaine, Sodium Lauroyl Methyl Isethionate, Sodium Guaiazulene Sulfonate, Panthenol, Citric Acid.',
    usageInstructions: 'Lather small amount with water, gently massage in circular motions across damp face, and rinse thoroughly with lukewarm water.',
    imageUrl: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: false,
    isNewArrival: false,
    stock: 40,
    rating: 4.8,
    reviewsCount: 112,
    keyBenefits: ['pH 5.5 gentle barrier wash', 'Non-stripping foam', 'Soothes inflamed skin', 'Removes daily pollutants'],
  ),
  Product(
    id: 'tiam_p6_snail_azulene_mask',
    name: 'TIA\'M Snail & Azulene Sleeping Mask (Overnight Recovery)',
    nameBn: 'টিআই\'এম স্নেল অ্যান্ড আজুলিন স্লিপিং মাস্ক (নাইট রিপেয়ার মাস্ক)',
    brand: 'TIA\'M',
    category: 'Creams & Masks',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1750.0,
    oldPrice: 2050.0,
    wholesalePrice: 1250.0,
    moq: 10,
    batchNo: 'TM-SASM-2026-06',
    expiryDate: '2028-10',
    skinType: 'Dry, Fatigued & Stressed Barrier Skin',
    shadesOrSizes: ['80ml Glass Jar'],
    description: 'Soothing overnight treatment packed with 85% Snail Filtrate and Azulene that locks in deep hydration, repairs skin overnight, and reveals radiant glow by morning.',
    descriptionBn: '৮৫% স্নেল ফিল্ট্রেট ও আজুলিন সমৃদ্ধ ওভারনাইট মাস্ক। ঘুমের মধ্যে ত্বকের ক্লান্তি ও ক্ষতি মেরামত করে সকালের মধ্যে ত্বককে কোমল, প্রাণবন্ত ও গ্লোয়িং করে তোলে।',
    ingredients: 'Snail Secretion Filtrate (85%), Glycerin, Butylene Glycol, Sodium Guaiazulene Sulfonate, Betaine, Allantoin, Panthenol, Carbomer.',
    usageInstructions: 'As last step of nighttime routine, apply moderate layer over entire face avoiding eye and lip areas. Wash off with lukewarm water next morning.',
    imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: false,
    isNewArrival: true,
    stock: 30,
    rating: 4.9,
    reviewsCount: 88,
    keyBenefits: ['Overnight skin revival', 'Replenishes lipid barrier', 'Intense morning glow', 'Cooling relief'],
  ),
  Product(
    id: 'tiam_p7_ac_fighting_spot_cream',
    name: 'TIA\'M AC Fighting Spot Rx Cream (10% Niacinamide + Zinc)',
    nameBn: 'টিআই\'এম এসি ফাইটিং স্পট আরএক্স ক্রিম (একনে ও ব্রণের সমাধান)',
    brand: 'TIA\'M',
    category: 'Treatments & Creams',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1550.0,
    oldPrice: 1850.0,
    wholesalePrice: 1100.0,
    moq: 10,
    batchNo: 'TM-ACSP-2026-07',
    expiryDate: '2028-06',
    skinType: 'Acne-Prone, Active Blemishes & Pimple Spots',
    shadesOrSizes: ['30ml Precision Tube'],
    description: 'Fast-acting blemish rescue cream featuring 10% Niacinamide, Zinc Oxide, Centella Asiatica, and natural micro-spicules to target acne bacteria and accelerate recovery.',
    descriptionBn: '১০% নিয়াসিনামাইড, জিঙ্ক এবং সেন্টেলা সমৃদ্ধ দ্রুত কার্যকরী পিম্পল স্পট ক্রিম। এটি ব্রণের প্রদাহ কমায়, ব্যাকটেরিয়া দূর করে এবং দাগ পড়া রোধ করে।',
    ingredients: 'Water, Niacinamide (10%), Zinc Oxide (7%), Glycerin, Centella Asiatica Extract, Melaleuca Alternifolia (Tea Tree) Leaf Oil, Hydrolyzed Sponge, Asiaticoside.',
    usageInstructions: 'Dab a small pea-sized amount directly onto active pimples or breakout areas after moisturizer. Gently press until absorbed.',
    imageUrl: 'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: true,
    isNewArrival: false,
    stock: 55,
    rating: 4.9,
    reviewsCount: 230,
    keyBenefits: ['Quick overnight pimple dry-out', 'Soothes cystic acne swelling', 'Prevents PIH dark marks', 'Gentle micro-spicule delivery'],
  ),
  Product(
    id: 'tiam_p8_ac_fighting_aqua_cream',
    name: 'TIA\'M AC Fighting Oil-Free Aqua Cream (Gel Moisturizer)',
    nameBn: 'টিআই\'এম এসি ফাইটিং অয়েল-ফ্রি অ্যাকোয়া ক্রিম (হালকা ময়েশ্চারাইজার)',
    brand: 'TIA\'M',
    category: 'Creams & Moisturizers',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1650.0,
    oldPrice: 1950.0,
    wholesalePrice: 1180.0,
    moq: 10,
    batchNo: 'TM-ACOF-2026-08',
    expiryDate: '2028-08',
    skinType: 'Oily, Congested & Combination Skin',
    shadesOrSizes: ['50ml Jar'],
    description: '100% oil-free lightweight cooling aqua cream delivering oil-balancing hydration with Panthenol, Betaine, and Niacinamide without clogging pores or greasy shine.',
    descriptionBn: '১০০% তেলমুক্ত ওয়াটার-জেল ময়েশ্চারাইজার যা পোরস বন্ধ না করে ত্বকে প্রশান্তিদায়ক আর্দ্রতা জোগায় এবং অতিরিক্ত তৈলাক্ত ভাব নিয়ন্ত্রণ করে।',
    ingredients: 'Water, Butylene Glycol, Glycerin, 1,2-Hexanediol, Niacinamide, Panthenol, Betaine, Allantoin, Arginine, Carbomer, Melaleuca Alternifolia (Tea Tree) Extract.',
    usageInstructions: 'Smooth an appropriate amount over face as final step of morning and evening skincare routine.',
    imageUrl: 'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: false,
    isNewArrival: false,
    stock: 42,
    rating: 4.8,
    reviewsCount: 104,
    keyBenefits: ['100% oil-free moisture', 'Cooling blemish relief', 'Weightless fast absorption', 'Won\'t clog pores'],
  ),
  Product(
    id: 'tiam_p9_vita_b3_mist_toner',
    name: 'TIA\'M Vita B3 Mist Toner (Brightening & Glow Booster)',
    nameBn: 'টিআই\'এম ভিটা বি৩ মিস্ট টোনার (উজ্জ্বলতাকারী মিস্ট টোনার)',
    brand: 'TIA\'M',
    category: 'Toner & Essence',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1650.0,
    oldPrice: 1900.0,
    wholesalePrice: 1180.0,
    moq: 10,
    batchNo: 'TM-VBM-2026-09',
    expiryDate: '2028-09',
    skinType: 'Dull, Dehydrated & Uneven Tone Skin',
    shadesOrSizes: ['200ml Fine Spray Mist'],
    description: 'Ultra-fine vitamin hydrating mist toner packed with 3% Niacinamide, Tranexamic Acid, and Vitamin C to revitalize tired complexion and boost radiance anytime, anywhere.',
    descriptionBn: '৩% নিয়াসিনামাইড, ট্রানেক্সামিক অ্যাসিড ও ভিটামিন সি সমৃদ্ধ হালকা মিস্ট টোনার। এটি সারাদিন ত্বককে হাইড্রেটেড রাখে এবং তাৎক্ষণিক ব্রাইট গ্লো দেয়।',
    ingredients: 'Water, Niacinamide (3%), 1,2-Hexanediol, Butylene Glycol, Tranexamic Acid, Ascorbyl Glucoside, Panthenol, Allantoin, Sodium Hyaluronate.',
    usageInstructions: 'Close eyes and spray evenly across face from 20cm distance after cleansing or whenever skin feels dry throughout the day.',
    imageUrl: 'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: false,
    isNewArrival: true,
    stock: 35,
    rating: 4.8,
    reviewsCount: 79,
    keyBenefits: ['Instant dewy refresh', '3% Niacinamide glow', 'Tranexamic Acid brightening', 'Fine cloud mist nozzle'],
  ),
  Product(
    id: 'tiam_p10_b3_niacin_sunscreen',
    name: 'TIA\'M B3 Niacin Sunscreen SPF 50+ PA++++ (UV Shield)',
    nameBn: 'টিআই\'এম বি৩ নিয়াসিন সানস্ক্রিন এসপিএফ ৫০+ পিএ++++ (সুরক্ষা ও গ্লো)',
    brand: 'TIA\'M',
    category: 'Sun Care',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 1750.0,
    oldPrice: 2050.0,
    wholesalePrice: 1250.0,
    moq: 10,
    batchNo: 'TM-B3S-2026-10',
    expiryDate: '2028-11',
    skinType: 'All Skin Types, No White Cast, Non-Greasy',
    shadesOrSizes: ['50ml Daily Tube'],
    description: 'Broad-spectrum high protection daily sunscreen infused with Niacinamide and Centella to shield against UVA/UVB rays while brightening dark spots with zero white cast.',
    descriptionBn: 'এসপিএফ ৫০+ এবং পিএ++++ যুক্ত উচ্চমানের ডেইলি সানস্ক্রিন। নিয়াসিনামাইড ও সেন্টেলা সমৃদ্ধ এই সানস্ক্রিন সূর্যের ক্ষতিকর অতিবেগুনি রশ্মি থেকে সুরক্ষা দেয় কোনো সাদা দাগ ছাড়াই।',
    ingredients: 'Water, Dibutyl Adipate, Niacinamide (2%), Ethylhexyl Triazone, Diethylamino Hydroxybenzoyl Hexyl Benzoate, Centella Asiatica Extract, Tocopherol, Adenosine.',
    usageInstructions: 'Apply generously as the final step of morning routine 15 minutes before sun exposure. Reapply every 2-3 hours during outdoor activities.',
    imageUrl: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: true,
    isNewArrival: true,
    stock: 60,
    rating: 4.9,
    reviewsCount: 198,
    keyBenefits: ['SPF 50+ PA++++ maximum protection', 'Zero white cast finish', 'Infused with brightening Niacinamide', 'Lightweight serum texture'],
  ),
  Product(
    id: 'tiam_p11_glow_333_capsule_cream',
    name: 'TIA\'M Glow 333 Capsule Cream (NMN + Vitamin C Radiance)',
    nameBn: 'টিআই\'এম গ্লো ৩৩৩ ক্যাপসুল ক্রিম (ভিটামিন সি ও এনএমএন সমৃদ্ধ)',
    brand: 'TIA\'M',
    category: 'Creams & Moisturizers',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 2150.0,
    oldPrice: 2550.0,
    wholesalePrice: 1520.0,
    moq: 8,
    batchNo: 'TM-G333-2026-11',
    expiryDate: '2028-12',
    skinType: 'Dull, Uneven Skin & Anti-Oxidant Glow',
    shadesOrSizes: ['50ml Luxury Jar'],
    description: 'Luxury radiance booster cream containing dual-capsule technology with NMN (Nicotinamide Mononucleotide), pure Vitamin C, and 3% Niacinamide for glass-skin illumination.',
    descriptionBn: 'এনএমএন এবং খাঁটি ভিটামিন সি ক্যাপসুল প্রযুক্তির বিলাসবহুল ক্রিম যা ত্বককে পুনরুজ্জীবিত করে, ভেতর থেকে প্রাকৃতিক আভা ছড়ায় এবং কোরিয়ান গ্লাস স্কিন লুক এনে দেয়।',
    ingredients: 'Water, Glycerin, Niacinamide (3%), Nicotinamide Mononucleotide (NMN), Ascorbic Acid (Pure Vitamin C Capsules), Butyrospermum Parkii (Shea) Butter, Ceramide NP.',
    usageInstructions: 'Massage a moderate scoop over face until capsules gently burst and absorb into skin. Ideal for morning and night radiance.',
    imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: false,
    isNewArrival: true,
    stock: 25,
    rating: 5.0,
    reviewsCount: 64,
    keyBenefits: ['Pure Vitamin C micro-capsules', 'NMN cellular elasticity', 'Korean glass skin glow', 'Deep ceramide moisture barrier'],
  ),
  Product(
    id: 'tiam_p12_alpha_5_mela_care_cream',
    name: 'TIA\'M Alpha-5 Mela Care Cream (5-Pathway Melasma Defense)',
    nameBn: 'টিআই\'এম আলফা-৫ মেলা কেয়ার ক্রিম (মেছতা ও গাঢ় দাগ দূরীকরণ)',
    brand: 'TIA\'M',
    category: 'Treatments & Creams',
    originCountry: 'South Korea',
    countryFlag: '🇰🇷',
    retailPrice: 2250.0,
    oldPrice: 2650.0,
    wholesalePrice: 1580.0,
    moq: 8,
    batchNo: 'TM-A5M-2026-12',
    expiryDate: '2028-12',
    skinType: 'Melasma, Stubborn Pigmentation & Sun Spots',
    shadesOrSizes: ['50ml Treatment Tube'],
    description: 'Specialized dermo-cosmetic cream formulating 5 clinical brightening actives (Alpha-Arbutin, Tranexamic Acid, Niacinamide, Glutathione, and Vitamin C) to suppress deep melanin.',
    descriptionBn: 'মেছতা এবং দীর্ঘস্থায়ী পিগমেন্টেশন চিকিৎসার জন্য ৫টি শক্তিশালী উপাদানের (আলফা-আরবুটিন, ট্রানেক্সামিক অ্যাসিড, গ্লুটাথিয়ন) বিশেষজ্ঞ ক্রিম।',
    ingredients: 'Water, Alpha-Arbutin, Tranexamic Acid, Niacinamide, Glutathione, Ethyl Ascorbyl Ether, Centella Asiatica Extract, Sodium Hyaluronate, Madecassoside.',
    usageInstructions: 'Apply across face focusing on areas with melasma, sun spots, or stubborn freckles twice daily after serums.',
    imageUrl: 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80',
    gallery: [
      'https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80',
    ],
    isBestSeller: true,
    isNewArrival: true,
    stock: 28,
    rating: 4.9,
    reviewsCount: 142,
    keyBenefits: ['5-way melanin suppression', 'Fades stubborn melasma & sun spots', 'Glutathione brightening', 'Dermatologist tested safe'],
  ),
];
