import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../widgets/product_card.dart';

class HomeView extends StatefulWidget {
  final StoreState state;
  const HomeView({super.key, required this.state});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentSlide = 0;
  String _activeTab = 'All';

  // — Auto-rotate hero slider —
  Timer? _autoSlideTimer;
  Timer? _resumeTimer;

  // — Flash deals countdown —
  Timer? _countdownTimer;
  Duration _flashTimeLeft = const Duration(hours: 6, minutes: 30, seconds: 0);

  // — Newsletter —
  final TextEditingController _emailController = TextEditingController();
  bool _subscribed = false;

  final List<Map<String, String>> _slides = [
    {
      'badge': 'Festive Radiance Campaign 2026',
      'title': 'Unveil Your Purest\nLuminous Glow',
      'titleBn': 'আপনার ত্বকের আসল\nউজ্জ্বলতা প্রকাশ করুন',
      'desc':
          'Experience 100% authentic global skincare and luxury makeup imported directly from France, South Korea, USA, and the UK to Bangladesh.',
      'descBn':
          'ফ্রান্স, দক্ষিণ কোরিয়া, আমেরিকা এবং যুক্তরাজ্য থেকে সরাসরি বাংলাদেশে আমদানিকৃত ১০০% আসল স্কিনকেয়ার এবং মেকআপ।',
      'img': 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=1920&q=85',
    },
    {
      'badge': 'New Arrivals • K-Beauty & Luxury Makeup',
      'title': 'Runway-Ready Velvet\n& Glass Skin',
      'titleBn': 'কোরিয়ান গ্লাস স্কিন ও\nবিলাসবহুল মেকআপ কালেকশন',
      'desc':
          'Discover dermatologist-approved serums from The Ordinary, COSRX, and iconic lip colors from MAC & Maybelline New York.',
      'descBn':
          'ডার্মাটোলজিস্ট টেস্টেড সিরাম (The Ordinary, COSRX) এবং ম্যাক ও মেবেলিনের আন্তর্জাতিক শেডসমূহ।',
      'img': 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=1920&q=85',
    },
    {
      'badge': 'Direct Importer • Batch Verified',
      'title': 'Pure Science Meets\nTimeless Beauty',
      'titleBn': 'বিজ্ঞানসম্মত যত্ন ও\nআসল প্রসাধনীর পূর্ণ নিশ্চয়তা',
      'desc':
          'Every bottle comes with verified import batch codes, BSTI compliance, and temperature-controlled warehousing in Dhaka.',
      'descBn':
          'প্রতিটি বোতলে রয়েছে যাচাইকৃত ব্যাচ কোড এবং ঢাকার নিজস্ব ২০°C কোল্ড চেইন সংরক্ষণ ব্যবস্থা।',
      'img': 'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=1920&q=85',
    },
  ];

  // Hardcoded testimonials
  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Farzana Akter',
      'rating': 5,
      'text': 'Finally found a trustworthy source for authentic Korean skincare in Bangladesh! The COSRX snail mucin I ordered was 100% genuine with proper batch codes. Highly recommended!',
      'icon': Icons.person,
    },
    {
      'name': 'Nusrat Jahan',
      'rating': 5,
      'text': 'I was always worried about fake cosmetics. Ruposhi International gave me complete peace of mind — the MAC lipstick had proper hologram stickers and batch verification.',
      'icon': Icons.person_outline,
    },
    {
      'name': 'Tasnim Rahman',
      'rating': 4,
      'text': 'Great prices for imported products! The Ordinary serums are way cheaper than other local sellers and I got cash on delivery too. Will definitely order again.',
      'icon': Icons.face,
    },
    {
      'name': 'Rabeya Khatun',
      'rating': 5,
      'text': 'The delivery was super fast — got my order within 2 days in Dhaka. All products were sealed and temperature-controlled. This is how online shopping should be!',
      'icon': Icons.face_2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
    _startCountdown();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _resumeTimer?.cancel();
    _countdownTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _currentSlide = (_currentSlide + 1) % _slides.length;
        });
      }
    });
  }

  void _pauseAutoSlide() {
    _autoSlideTimer?.cancel();
    _resumeTimer?.cancel();
    _resumeTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) _startAutoSlide();
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          if (_flashTimeLeft.inSeconds > 0) {
            _flashTimeLeft = _flashTimeLeft - const Duration(seconds: 1);
          }
        });
      }
    });
  }

  String _formatCountdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isSmallMobile = screenWidth < 480;
    final slide = _slides[_currentSlide];

    var displayedProducts = widget.state.products.where((p) {
      if (_activeTab == 'Best Sellers') return p.isBestSeller;
      if (_activeTab == 'New Arrivals') return p.isNewArrival;
      return true;
    }).toList();
    if (displayedProducts.isEmpty && widget.state.products.isNotEmpty) {
      displayedProducts = widget.state.products;
    }

    // Flash deal products (those with a discount)
    final flashProducts = widget.state.products
        .where((p) => p.discountPercent > 0)
        .take(4)
        .toList();

    return Column(
      children: [
        // ==========================================
        // 1. HERO SLIDER SECTION (with auto-rotate)
        // ==========================================
        Container(
          width: double.infinity,
          height: isSmallMobile ? 530 : (isMobile ? 520 : 580),
          color: AppTheme.rose950,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image with Zoom
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 700),
                child: Image.network(
                  slide['img']!,
                  key: ValueKey<int>(_currentSlide),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(color: AppTheme.rose950),
                ),
              ),

              // Gradient Overlay (Dark burgundy from left to transparent)
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.heroSlideGradient,
                ),
              ),

              // Content
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 16 : (isMobile ? 24 : 48)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Campaign Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.gold400.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: AppTheme.gold400),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, size: 13, color: AppTheme.gold300),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  slide['badge']!,
                                  style: const TextStyle(
                                    color: AppTheme.gold300,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallMobile ? 12 : 20),

                        // Title
                        Text(
                          widget.state.isBangla ? slide['titleBn']! : slide['title']!,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Colors.white,
                                fontSize: isSmallMobile ? 25 : (isMobile ? 34 : 52),
                                height: 1.18,
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        SizedBox(height: isSmallMobile ? 10 : 16),

                        // Description
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Text(
                            widget.state.isBangla ? slide['descBn']! : slide['desc']!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: isSmallMobile ? 12.5 : (isMobile ? 14 : 16.5),
                              height: 1.45,
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallMobile ? 18 : 28),

                        // Buttons
                        Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => cubit.navigateTo(AppView.shop),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.rose600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                elevation: 8,
                                shadowColor: AppTheme.rose600.withValues(alpha: 0.5),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: Text(
                                widget.state.isBangla ? 'কালেকশন দেখুন' : 'Explore Collection',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                              ),
                            ),
                            OutlinedButton(
                              onPressed: () => cubit.navigateTo(AppView.aboutUs),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                                backgroundColor: Colors.white.withValues(alpha: 0.1),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                              child: Text(
                                widget.state.isBangla ? 'আসল পণ্যের নিশ্চয়তা' : 'Authenticity Guarantee',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Slider Controls (Bottom Right & Left)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Animated Dots
                          Row(
                            children: List.generate(_slides.length, (idx) {
                              final isActive = _currentSlide == idx;
                              return InkWell(
                                onTap: () {
                                  _pauseAutoSlide();
                                  setState(() => _currentSlide = idx);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.only(right: 8),
                                  width: isActive ? 28 : 8,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive ? AppTheme.gold400 : Colors.white54,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              );
                            }),
                          ),
                          // Arrow Buttons
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black38,
                                ),
                                onPressed: () {
                                  _pauseAutoSlide();
                                  setState(() {
                                    _currentSlide = (_currentSlide - 1 + _slides.length) % _slides.length;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: Colors.white),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black38,
                                ),
                                onPressed: () {
                                  _pauseAutoSlide();
                                  setState(() {
                                    _currentSlide = (_currentSlide + 1) % _slides.length;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ==========================================
        // 2. AUTHENTICITY & TRUST RIBBON (4 CARDS)
        // ==========================================
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Wrap(
                spacing: 32,
                runSpacing: 20,
                alignment: WrapAlignment.spaceAround,
                children: [
                  _TrustRibbonCard(
                    icon: Icons.workspace_premium_outlined,
                    title: widget.state.isBangla ? '১০০% আসল ইমপোর্ট' : '100% Authentic Import',
                    subtitle: widget.state.isBangla ? 'ইউএসএ, কোরিয়া ও ইইউ' : 'Direct from USA, Korea & EU',
                  ),
                  _TrustRibbonCard(
                    icon: Icons.qr_code_scanner_outlined,
                    title: widget.state.isBangla ? 'ব্যাচ ও মেয়াদ যাচাইকৃত' : 'Batch & Expiry Verified',
                    subtitle: widget.state.isBangla ? 'প্রতিটি পণ্যের ব্যাচ চেক' : 'Check batch on every product',
                  ),
                  _TrustRibbonCard(
                    icon: Icons.payments_outlined,
                    title: widget.state.isBangla ? 'ক্যাশ অন ডেলিভারি' : 'Cash on Delivery',
                    subtitle: widget.state.isBangla ? 'হোম ডেলিভারি + বিকাশ/নগদ' : 'Pay at doorstep + bKash / Nagad',
                  ),
                  _TrustRibbonCard(
                    icon: Icons.inventory_2_outlined,
                    title: widget.state.isBangla ? 'খুচরা ও পাইকারি ডিলার' : 'Retail & B2B Wholesale',
                    subtitle: widget.state.isBangla ? 'দেশব্যাপী অনুমোদিত ডিলার' : 'Authorized distributor across BD',
                  ),
                ],
              ),
            ),
          ),
        ),

        // ==========================================
        // 3. CATEGORY SHOWCASE (6 CATEGORIES FROM SITE)
        // ==========================================
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Text(
                    widget.state.isBangla ? 'ক্যাটাগরি অনুযায়ী কেনাকাটা করুন' : 'Shop By Beauty Category',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.state.isBangla
                        ? 'ত্বকের ধরন ও চাহিদামাফিক আন্তর্জাতিক মানের প্রসাধনী'
                        : 'Explore clinical skincare, runway makeup, and salon-grade hair treatments',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final available = constraints.maxWidth;
                      final double cardWidth;
                      final double cardHeight;
                      if (available < 480) {
                        cardWidth = (available - 12) / 2;
                        cardHeight = 175;
                      } else if (available < 860) {
                        cardWidth = (available - 2 * 14) / 3;
                        cardHeight = 195;
                      } else {
                        cardWidth = (available - 5 * 16) / 6;
                        cardHeight = 220;
                      }

                      return Wrap(
                        spacing: available < 480 ? 12 : 16,
                        runSpacing: available < 480 ? 12 : 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _CategoryCard(
                            title: 'Skincare',
                            titleBn: 'স্কিনকেয়ার',
                            desc: 'Snail mucin, serums, cleansers',
                            imgUrl: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=600&q=80',
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => cubit.setCategory('Skincare'),
                          ),
                          _CategoryCard(
                            title: 'Makeup',
                            titleBn: 'মেকআপ',
                            desc: 'Matte lips, foundations, cheek tints',
                            imgUrl: 'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?auto=format&fit=crop&w=600&q=80',
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => cubit.setCategory('Makeup'),
                          ),
                          _CategoryCard(
                            title: 'Haircare',
                            titleBn: 'হেয়ার কেয়ার',
                            desc: 'Salon hair repair, keratin masks',
                            imgUrl: 'https://images.unsplash.com/photo-1519699047748-de8e457a634e?auto=format&fit=crop&w=600&q=80',
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => cubit.setCategory('Haircare'),
                          ),
                          _CategoryCard(
                            title: 'Fragrance',
                            titleBn: 'পারফিউম',
                            desc: 'Luxury French perfumes',
                            imgUrl: 'https://images.unsplash.com/photo-1541643600914-78b084683601?auto=format&fit=crop&w=600&q=80',
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => cubit.setCategory('Fragrance'),
                          ),
                          _CategoryCard(
                            title: 'Bath & Body',
                            titleBn: 'বাথ অ্যান্ড বডি',
                            desc: 'Body washes, ceramide lotions',
                            imgUrl: 'https://images.unsplash.com/photo-1515377905703-c4788e51af15?auto=format&fit=crop&w=600&q=80',
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => cubit.setCategory('Bath & Body'),
                          ),
                          _CategoryCard(
                            title: 'Mens Grooming',
                            titleBn: 'মেন্স গ্রুমিং',
                            desc: 'Beard care, face wash, styling',
                            imgUrl: 'https://images.unsplash.com/photo-1621607512214-68297480165e?auto=format&fit=crop&w=600&q=80',
                            width: cardWidth,
                            height: cardHeight,
                            onTap: () => cubit.setCategory('Mens Grooming'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // ==========================================
        // 3B. SHOP BY SKIN CONCERN (6 CONCERN CARDS)
        // ==========================================
        Container(
          width: double.infinity,
          color: AppTheme.surfaceWhite,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Text(
                    widget.state.isBangla ? 'ত্বকের সমস্যা অনুযায়ী কেনাকাটা' : 'Shop By Skin Concern',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.state.isBangla
                        ? 'আপনার ত্বকের নির্দিষ্ট সমস্যা অনুযায়ী সেরা পণ্য খুঁজুন'
                        : 'Find the best products tailored to your specific skin needs',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final available = constraints.maxWidth;
                      final double cardWidth;
                      final double cardHeight;
                      if (available < 480) {
                        cardWidth = (available - 12) / 2;
                        cardHeight = 175;
                      } else if (available < 860) {
                        cardWidth = (available - 2 * 14) / 3;
                        cardHeight = 195;
                      } else {
                        cardWidth = (available - 5 * 16) / 6;
                        cardHeight = 220;
                      }

                      final concerns = <Map<String, dynamic>>[
                        {
                          'title': 'Acne & Breakouts',
                          'titleBn': 'ব্রণ ও দাগ',
                          'icon': Icons.bubble_chart_outlined,
                          'gradient': const [Color(0xFFE11D48), Color(0xFF9F1239)],
                          'search': 'acne',
                        },
                        {
                          'title': 'Anti-Aging & Wrinkles',
                          'titleBn': 'অ্যান্টি-এজিং',
                          'icon': Icons.access_time_filled,
                          'gradient': const [Color(0xFFD4AF37), Color(0xFF8F6F14)],
                          'search': 'anti-aging',
                        },
                        {
                          'title': 'Hyperpigmentation & Dark Spots',
                          'titleBn': 'দাগ ও কালো ছোপ',
                          'icon': Icons.contrast,
                          'gradient': const [Color(0xFFBE123C), Color(0xFF881337)],
                          'search': 'dark spots',
                        },
                        {
                          'title': 'Dryness & Dehydration',
                          'titleBn': 'শুষ্কতা ও আর্দ্রতা',
                          'icon': Icons.water_drop_outlined,
                          'gradient': const [Color(0xFF0EA5E9), Color(0xFF0369A1)],
                          'search': 'dry',
                        },
                        {
                          'title': 'Sensitivity & Redness',
                          'titleBn': 'সংবেদনশীলতা',
                          'icon': Icons.favorite_outline,
                          'gradient': const [Color(0xFFF43F5E), Color(0xFFBE123C)],
                          'search': 'sensitive',
                        },
                        {
                          'title': 'Oily Skin & Pores',
                          'titleBn': 'তৈলাক্ত ত্বক ও ছিদ্র',
                          'icon': Icons.opacity,
                          'gradient': const [Color(0xFF10B981), Color(0xFF047857)],
                          'search': 'oily',
                        },
                      ];

                      return Wrap(
                        spacing: available < 480 ? 12 : 16,
                        runSpacing: available < 480 ? 12 : 16,
                        alignment: WrapAlignment.center,
                        children: concerns.map((concern) {
                          return _SkinConcernCard(
                            title: concern['title'] as String,
                            titleBn: concern['titleBn'] as String,
                            icon: concern['icon'] as IconData,
                            gradientColors: concern['gradient'] as List<Color>,
                            width: cardWidth,
                            height: cardHeight,
                            isBangla: widget.state.isBangla,
                            onTap: () {
                              cubit.setSearch(concern['search'] as String);
                              cubit.navigateTo(AppView.shop);
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // ==========================================
        // 3C. FLASH DEALS / LIMITED TIME OFFERS
        // ==========================================
        if (flashProducts.isNotEmpty)
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.rose950, AppTheme.rose900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  children: [
                    // Flash Deals Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_fire_department, color: AppTheme.gold400, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          widget.state.isBangla ? 'ফ্ল্যাশ ডিল • সীমিত সময়' : 'Flash Deals • Limited Time Offers',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Countdown Timer Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.state.isBangla ? 'শেষ হতে বাকি: ' : 'Ends in: ',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          Text(
                            _formatCountdown(_flashTimeLeft),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 2,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Flash Products Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final available = constraints.maxWidth;
                        final double cardWidth;
                        if (available < 380) {
                          cardWidth = available;
                        } else if (available < 660) {
                          cardWidth = (available - 14) / 2;
                        } else if (available < 1000) {
                          cardWidth = (available - 2 * 18) / 3;
                        } else {
                          cardWidth = (available - 3 * 20) / 4;
                        }

                        return Wrap(
                          spacing: available < 660 ? 14 : 20,
                          runSpacing: 22,
                          alignment: WrapAlignment.center,
                          children: flashProducts.map((p) {
                            return Stack(
                              children: [
                                ProductCard(
                                  product: p,
                                  isBangla: widget.state.isBangla,
                                  isB2BActive: widget.state.isB2BAuthenticated,
                                  width: cardWidth,
                                ),
                                // HURRY Badge
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withValues(alpha: 0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.local_fire_department, color: Colors.white, size: 12),
                                        SizedBox(width: 3),
                                        Text(
                                          'HURRY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ==========================================
        // 4. TRENDING COSMETICS IN BANGLADESH
        // ==========================================
        Container(
          width: double.infinity,
          color: AppTheme.surfaceWhite,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.state.isBangla ? 'বাংলাদেশে জনপ্রিয় প্রসাধনী' : 'Trending Cosmetics in Bangladesh',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.state.isBangla
                                ? '১০০% আসল ও সেরা মূল্যে দ্রুত হোম ডেলিভারির জন্য প্রস্তুত'
                                : 'Authentic global bestsellers ready for express dispatch with verified batch codes',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => cubit.navigateTo(AppView.shop),
                        icon: const Icon(Icons.arrow_forward, size: 16, color: AppTheme.rose600),
                        label: Text(
                          widget.state.isBangla ? 'সব প্রসাধনী দেখুন' : 'View Full Catalog',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.rose600),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Tabs (Horizontally scrollable for small screens)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...['All', 'Best Sellers', 'New Arrivals'].map((tab) {
                          final isSelected = _activeTab == tab;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ChoiceChip(
                              label: Text(tab),
                              selected: isSelected,
                              selectedColor: AppTheme.rose600,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              backgroundColor: AppTheme.rose50,
                              side: BorderSide(
                                color: isSelected ? AppTheme.rose600 : AppTheme.borderSubtle,
                              ),
                              onSelected: (_) => setState(() => _activeTab = tab),
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ActionChip(
                            avatar: const Icon(Icons.business_center, size: 14, color: AppTheme.gold600),
                            label: Text(
                              widget.state.isBangla ? 'বিটুবি ডিলার পোর্টাল' : 'B2B Wholesale Portal',
                              style: const TextStyle(
                                color: AppTheme.gold600,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            backgroundColor: AppTheme.gold100,
                            side: const BorderSide(color: AppTheme.gold300),
                            onPressed: () => cubit.navigateTo(AppView.b2bPortal),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Products Grid (Adaptive for Mobile, Tablet, Desktop)
                  if (widget.state.isLoadingProducts)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(color: AppTheme.rose800),
                      ),
                    )
                  else if (displayedProducts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.blueGrey),
                          const SizedBox(height: 14),
                          Text(
                            widget.state.isBangla ? 'কোন পণ্য পাওয়া যায়নি' : 'No cosmetics found in catalog',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.state.isBangla
                                ? 'লাইভ ডাটাবেজ থেকে পণ্য লোড হচ্ছে অথবা অ্যাডমিন প্যানেল থেকে নতুন পণ্য যুক্ত করুন।'
                                : 'Live products will appear here dynamically once added in the Admin Panel.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final available = constraints.maxWidth;
                        final double cardWidth;
                        if (available < 380) {
                          cardWidth = available;
                        } else if (available < 660) {
                          cardWidth = (available - 14) / 2;
                        } else if (available < 1000) {
                          cardWidth = (available - 2 * 18) / 3;
                        } else {
                          cardWidth = (available - 3 * 20) / 4;
                        }

                        return Wrap(
                          spacing: available < 660 ? 14 : 20,
                          runSpacing: 22,
                          alignment: WrapAlignment.center,
                          children: displayedProducts.map((p) {
                            return ProductCard(
                              product: p,
                              isBangla: widget.state.isBangla,
                              isB2BActive: widget.state.isB2BAuthenticated,
                              width: cardWidth,
                            );
                          }).toList(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ),

        // ==========================================
        // 5. CUSTOMER TESTIMONIALS CAROUSEL
        // ==========================================
        Container(
          width: double.infinity,
          color: AppTheme.rose50,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  Text(
                    widget.state.isBangla ? 'গ্রাহকদের মতামত' : 'What Our Customers Say',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.state.isBangla
                        ? 'বাংলাদেশ জুড়ে হাজারো সন্তুষ্ট গ্রাহকের বিশ্বাস'
                        : 'Trusted by thousands of beauty enthusiasts across Bangladesh',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: isMobile ? 220 : 200,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: _testimonials.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final t = _testimonials[index];
                        return Container(
                          width: isSmallMobile ? 280 : (isMobile ? 320 : 290),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderSubtle),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Star Rating
                              Row(
                                children: List.generate(5, (i) {
                                  return Icon(
                                    i < (t['rating'] as int) ? Icons.star : Icons.star_border,
                                    color: AppTheme.gold400,
                                    size: 16,
                                  );
                                }),
                              ),
                              const SizedBox(height: 10),
                              // Review Text
                              Expanded(
                                child: Text(
                                  t['text'] as String,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12.5,
                                    height: 1.5,
                                  ),
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Customer Avatar + Name
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppTheme.rose100,
                                    child: Icon(t['icon'] as IconData, size: 18, color: AppTheme.rose600),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    t['name'] as String,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ==========================================
        // 6. NEWSLETTER SIGNUP SECTION
        // ==========================================
        Container(
          width: double.infinity,
          color: AppTheme.rose950,
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  const Icon(Icons.mark_email_unread_outlined, color: AppTheme.gold400, size: 36),
                  const SizedBox(height: 16),
                  Text(
                    widget.state.isBangla ? 'নিউজলেটার সাবস্ক্রাইব করুন' : 'Subscribe to Our Newsletter',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.state.isBangla
                        ? 'এক্সক্লুসিভ অফার, নতুন পণ্যের আপডেট ও বিউটি টিপস সবার আগে পান'
                        : 'Get exclusive offers, new arrivals & beauty tips delivered to your inbox',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 13.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_subscribed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.gold400.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppTheme.gold400),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.gold300, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.state.isBangla ? 'সাবস্ক্রিপশন সফল হয়েছে!' : 'Successfully subscribed!',
                            style: const TextStyle(color: AppTheme.gold300, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: widget.state.isBangla ? 'আপনার ইমেইল লিখুন' : 'Enter your email address',
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(color: AppTheme.gold400, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withValues(alpha: 0.6), size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            if (_emailController.text.trim().isNotEmpty) {
                              setState(() => _subscribed = true);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.gold400,
                            foregroundColor: AppTheme.rose950,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                            elevation: 4,
                            shadowColor: AppTheme.gold400.withValues(alpha: 0.4),
                          ),
                          child: Text(
                            widget.state.isBangla ? 'সাবস্ক্রাইব' : 'Subscribe',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrustRibbonCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustRibbonCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 260),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.rose50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderSubtle),
            ),
            child: Icon(icon, color: AppTheme.rose600, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String titleBn;
  final String desc;
  final String imgUrl;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.titleBn,
    required this.desc,
    required this.imgUrl,
    required this.width,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: NetworkImage(imgUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppTheme.rose950.withValues(alpha: 0.45),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xCC4C0519)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.rose100,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkinConcernCard extends StatelessWidget {
  final String title;
  final String titleBn;
  final IconData icon;
  final List<Color> gradientColors;
  final double width;
  final double height;
  final bool isBangla;
  final VoidCallback onTap;

  const _SkinConcernCard({
    required this.title,
    required this.titleBn,
    required this.icon,
    required this.gradientColors,
    required this.width,
    required this.height,
    required this.isBangla,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                isBangla ? titleBn : title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
