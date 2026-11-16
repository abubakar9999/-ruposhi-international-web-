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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 32,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, color: AppTheme.rose900, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'RUPOSHI INTERNATIONAL',
                                  style: TextStyle(color: AppTheme.rose900, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
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
                        Text(
                          state.isBangla ? 'গুরুত্বপূর্ণ লিংক' : 'QUICK NAVIGATION',
                          style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 14),
                        _footerLink(state.isBangla ? 'হোম পেইজ' : 'Home Storefront', () => cubit.navigateTo(AppView.home)),
                        _footerLink(state.isBangla ? 'প্রসাধনী ক্যাটালগ' : 'Cosmetics Catalog', () => cubit.navigateTo(AppView.shop)),
                        _footerLink(state.isBangla ? 'আমাদের সম্পর্কে' : 'Company Overview', () => cubit.navigateTo(AppView.aboutUs)),
                        _footerLink(state.isBangla ? 'বিউটি ব্লগ ও টিপস' : 'Beauty Blog & Guides', () => cubit.navigateTo(AppView.beautyBlog)),
                        _footerLink(state.isBangla ? 'অর্ডার ট্র্যাকিং ও যোগাযোগ' : 'Contact & Live Tracking', () => cubit.navigateTo(AppView.contact)),
                        _footerLink(state.isBangla ? 'বিটুবি ডিলার পোর্টাল' : 'B2B Wholesale Portal', () => cubit.navigateTo(AppView.b2bPortal)),
                        _footerLink(state.isBangla ? 'শপিং ব্যাগ ও চেকআউট' : 'Shopping Bag & Checkout', () => cubit.navigateTo(AppView.checkout)),
                        _footerLink(state.isBangla ? 'অ্যাডমিন কনসোল' : 'Executive Admin Console', () => cubit.navigateTo(AppView.admin)),
                      ],
                    ),
                  ),

                  // Cosmetics Categories
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isBangla ? 'প্রসাধনী ক্যাটাগরি' : 'PRODUCT CATEGORIES',
                          style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 14),
                        _footerLink(state.isBangla ? 'কোরিয়ান স্কিনকেয়ার' : 'Korean Skincare', () => cubit.setCategory('Skincare')),
                        _footerLink(state.isBangla ? 'লাক্সারি মেকআপ' : 'Luxury Makeup', () => cubit.setCategory('Makeup')),
                        _footerLink(state.isBangla ? 'সেলুন হেয়ারকেয়ার' : 'Salon Haircare Masks', () => cubit.setCategory('Haircare')),
                        _footerLink(state.isBangla ? 'ফ্রেঞ্চ পারফিউম' : 'French Fragrances', () => cubit.setCategory('Fragrance')),
                        _footerLink(state.isBangla ? 'নতুন কালেকশন' : 'New Arrivals', () => cubit.navigateTo(AppView.shop)),
                      ],
                    ),
                  ),

                  // Customer Concierge
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isBangla ? 'সহায়তা ও কাস্টমার কেয়ার' : 'SUPPORT & CONCIERGE',
                          style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          state.isBangla
                              ? 'হটলাইন: +৮৮০ ১৭০০-০০০০০০\nহোয়াটসঅ্যাপ: +৮৮০ ১৭০০-০০০০০০\nইমেইল: concierge@ruposhi.com.bd\nওয়্যারহাউস: বনানী, ঢাকা-১২১৩'
                              : 'Hotline: +880 1700-000000\nWhatsApp: +880 1700-000000\nEmail: concierge@ruposhi.com.bd\nWarehouse: Banani, Dhaka-1213',
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
