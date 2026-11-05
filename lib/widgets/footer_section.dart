import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';

class FooterSection extends StatelessWidget {
  final StoreState state;
  const FooterSection({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
      width: double.infinity,
      color: AppTheme.midnightPlum,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 64, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Wrap(
                spacing: 48,
                runSpacing: 32,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  // Brand Column
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryRose,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Flexible(
                              child: Text(
                                'RUPOSHI INTERNATIONAL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.isBangla
                              ? 'বাংলাদেশে বিশ্বমানের আসল প্রসাধনী আমদানিকারক ও পাইকারি পরিবেশক। প্রতিটি প্রোডাক্ট ১০০% আসল ও ব্যাচ কোড ভেরিফাইড।'
                              : 'Premier importer and B2B wholesale distributor of 100% authentic Korean, French, Canadian, and American cosmetics in Bangladesh.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            _SocialPill(icon: Icons.facebook, label: 'Facebook'),
                            SizedBox(width: 8),
                            _SocialPill(icon: Icons.camera_alt_outlined, label: 'Instagram'),
                            SizedBox(width: 8),
                            _SocialPill(icon: Icons.video_library_outlined, label: 'YouTube'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick Links
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'QUICK NAVIGATION',
                          style: TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 14),
                        _footerLink('Home Storefront', () => cubit.navigateTo(AppView.home)),
                        _footerLink('Cosmetics Catalog', () => cubit.navigateTo(AppView.shop)),
                        _footerLink('Company Overview', () => cubit.navigateTo(AppView.aboutUs)),
                        _footerLink('Beauty Blog & Guides', () => cubit.navigateTo(AppView.beautyBlog)),
                        _footerLink('Contact & Live Tracking', () => cubit.navigateTo(AppView.contact)),
                        _footerLink('B2B Wholesale Portal', () => cubit.navigateTo(AppView.b2bPortal)),
                        _footerLink('Shopping Bag & Checkout', () => cubit.navigateTo(AppView.checkout)),
                      ],
                    ),
                  ),

                  // Cosmetics Categories
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PRODUCT CATEGORIES',
                          style: TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 14),
                        _footerLink('Korean Skincare', () => cubit.setCategory('Skincare')),
                        _footerLink('Luxury Makeup', () => cubit.setCategory('Makeup')),
                        _footerLink('Salon Haircare Masks', () => cubit.setCategory('Haircare')),
                        _footerLink('French Fragrances', () => cubit.setCategory('Fragrance')),
                        _footerLink('New Arrivals', () => cubit.navigateTo(AppView.shop)),
                      ],
                    ),
                  ),

                  // Customer Concierge
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SUPPORT & CONCIERGE',
                          style: TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Hotline: +880 1700-000000\nWhatsApp: +880 1700-000000\nEmail: concierge@ruposhi.com.bd\nWarehouse: Banani, Dhaka-1213',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(color: Colors.white24, height: 48),

              // Bottom payment logos and copyright
              Wrap(
                spacing: 20,
                runSpacing: 12,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '© ${DateTime.now().year} Ruposhi International Ltd. All rights reserved.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                  ),
                  const Wrap(
                    spacing: 12,
                    children: [
                      _PaymentPill('Cash on Delivery'),
                      _PaymentPill('bKash'),
                      _PaymentPill('Nagad'),
                      _PaymentPill('Rocket'),
                      _PaymentPill('Visa / Mastercard'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13),
        ),
      ),
    );
  }
}

class _SocialPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SocialPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white70, size: 16),
    );
  }
}

class _PaymentPill extends StatelessWidget {
  final String label;
  const _PaymentPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11),
      ),
    );
  }
}
