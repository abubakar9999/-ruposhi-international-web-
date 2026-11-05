import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';

class AboutUsView extends StatelessWidget {
  final StoreState state;
  const AboutUsView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 24 : 48),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.darkPlum, Color(0xFF381F28)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.goldAccent.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.6)),
                      ),
                      child: const Text(
                        'ABOUT RUPOSHI INTERNATIONAL',
                        style: TextStyle(
                          color: AppTheme.goldLight,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.isBangla
                          ? 'আসল প্রসাধনীর নিশ্চয়তায়\nরূপসী ইন্টারন্যাশনাল'
                          : 'Pioneering Authenticity in\nBangladesh Luxury Cosmetics',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        state.isBangla
                            ? 'আমাদের লক্ষ্য একটাই—বাংলাদেশের প্রতিটি নারী ও পুরুষকে নকল প্রসাধনীর ঝুঁকি থেকে রক্ষা করে বিশ্বমানের মূল ব্র্যান্ডের পরীক্ষিত পণ্য সরবরাহ করা।'
                            : 'Established in Dhaka, Ruposhi International was founded to solve the nationwide counterfeit cosmetics crisis by importing 100% genuine skincare, makeup, and fragrances via direct air-freight cold-chain logistics.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Trust Pillars Cards (Adaptive for Mobile, Tablet, Desktop)
              LayoutBuilder(
                builder: (context, constraints) {
                  final available = constraints.maxWidth;
                  final double cardWidth;
                  if (available < 550) {
                    cardWidth = available;
                  } else if (available < 900) {
                    cardWidth = (available - 20) / 2;
                  } else {
                    cardWidth = (available - 3 * 20) / 4;
                  }

                  return Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _AboutCard(
                        icon: Icons.flight_takeoff,
                        title: 'Air-Freighted Direct',
                        desc: 'Never transported via humid, hot sea containers. We fly all inventory via temperature-controlled air cargo directly from Seoul, Paris, London, and New York.',
                        width: cardWidth,
                      ),
                      _AboutCard(
                        icon: Icons.ac_unit,
                        title: '20°C Dhaka Warehousing',
                        desc: 'Our modern central fulfillment warehouse in Dhaka maintains strict 18-22°C climate conditioning to protect sensitive active ingredients like Niacinamide and Peptides.',
                        width: cardWidth,
                      ),
                      _AboutCard(
                        icon: Icons.verified_user,
                        title: 'BSTI & Batch Record',
                        desc: 'Every consignment undergoes customs compliance and BSTI verification. Customers can verify genuine batch numbers directly with manufacturer registries.',
                        width: cardWidth,
                      ),
                      _AboutCard(
                        icon: Icons.storefront,
                        title: '350+ Salon & B2B Partners',
                        desc: 'We are the wholesale backbone supplying top dermatologists, premium beauty salons, and registered pharmacies across all 64 districts in Bangladesh.',
                        width: cardWidth,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 48),

              // Corporate Contact Details Box
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Wrap(
                  spacing: 40,
                  runSpacing: 24,
                  children: [
                    const SizedBox(
                      width: 320,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Headquarters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 8),
                          Text(
                            'Ruposhi International Ltd.\nLevel 7, Lotus Kamal Tower\nBanani Commercial Area, Dhaka-1213\nBangladesh',
                            style: TextStyle(color: Colors.black87, height: 1.5, fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 320,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer & Dealer Concierge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          SizedBox(height: 8),
                          Text('Phone: +880 1700-000000', style: TextStyle(fontSize: 13.5)),
                          SizedBox(height: 4),
                          Text('WhatsApp: +880 1700-000000', style: TextStyle(fontSize: 13.5)),
                          SizedBox(height: 4),
                          Text('Wholesale Email: b2b@ruposhi.com.bd', style: TextStyle(fontSize: 13.5)),
                          SizedBox(height: 4),
                          Text('Hours: Sat - Thu (9:00 AM - 9:00 PM)', style: TextStyle(fontSize: 13.5)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => cubit.navigateTo(AppView.shop),
                      child: const Text('Shop the Catalog'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final double? width;

  const _AboutCard({
    required this.icon,
    required this.title,
    required this.desc,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 270,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.softBlush,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryRose, size: 26),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
