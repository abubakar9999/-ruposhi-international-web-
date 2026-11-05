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

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 900;
    final isSmallMobile = screenWidth < 480;
    final slide = _slides[_currentSlide];

    final displayedProducts = widget.state.products.where((p) {
      if (_activeTab == 'Best Sellers') return p.isBestSeller;
      if (_activeTab == 'New Arrivals') return p.isNewArrival;
      return true;
    }).toList();

    return Column(
      children: [
        // ==========================================
        // 1. HERO SLIDER SECTION
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
                          // Dots
                          Row(
                            children: List.generate(_slides.length, (idx) {
                              final isActive = _currentSlide == idx;
                              return InkWell(
                                onTap: () => setState(() => _currentSlide = idx),
                                child: Container(
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
                    subtitle: widget.state.isBangla ? 'ইউএসএ, কোরিয়া ও ইইউ' : 'Direct from USA, Korea & EU',
                  ),
                  _TrustRibbonCard(
                    icon: Icons.qr_code_scanner_outlined,
                    title: widget.state.isBangla ? 'ব্যাচ ও মেয়াদ যাচাইকৃত' : 'Batch & Expiry Verified',
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
                            titleBn: 'স্কিনকেয়ার',
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
                      children: ['All', 'Best Sellers', 'New Arrivals'].map((tab) {
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
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Products Grid (Adaptive for Mobile, Tablet, Desktop)
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
