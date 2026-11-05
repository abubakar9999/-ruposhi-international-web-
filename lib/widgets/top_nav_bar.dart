import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final StoreState state;
  const TopNavBar({super.key, required this.state});

  @override
  Size get preferredSize => const Size.fromHeight(116);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 1050;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: const Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ==========================================
          // TOP ANNOUNCEMENT & TRUST BAR (rose-950)
          // ==========================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
            color: AppTheme.rose950,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.workspace_premium, size: 14, color: AppTheme.gold400),
                        const SizedBox(width: 6),
                        Text(
                          state.isBangla
                              ? '১০০% আসল আমদানিকৃত প্রসাধনীর নিশ্চয়তা'
                              : '100% Original Imported Products Guaranteed',
                          style: const TextStyle(
                            color: AppTheme.rose100,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (!isMobile) ...[
                          const SizedBox(width: 12),
                          Text('|', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                          const SizedBox(width: 12),
                          const Icon(Icons.local_shipping_outlined, size: 14, color: AppTheme.rose200),
                          const SizedBox(width: 6),
                          Text(
                            state.isBangla
                                ? 'সারাদেশে দ্রুত হোম ডেলিভারি (ক্যাশ অন ডেলিভারি)'
                                : 'Fast Nationwide Delivery (Cash on Delivery Available)',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // Track Order Link & Language Switcher
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () => cubit.navigateTo(AppView.contact),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.rose200),
                          const SizedBox(width: 4),
                          Text(
                            state.isBangla ? 'অর্ডার ট্র্যাক' : 'Track Order',
                            style: const TextStyle(color: AppTheme.gold300, fontSize: 11.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('|', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                    const SizedBox(width: 14),
                    // Language Switcher
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppTheme.rose900.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.rose800),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: () {
                              if (state.isBangla) cubit.toggleLanguage();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: !state.isBangla ? AppTheme.gold400 : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'EN',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: !state.isBangla ? AppTheme.rose950 : AppTheme.rose200,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              if (!state.isBangla) cubit.toggleLanguage();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: state.isBangla ? AppTheme.gold400 : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'বাংলা',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: state.isBangla ? AppTheme.rose950 : AppTheme.rose200,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ==========================================
          // MAIN HEADER ROW
          // ==========================================
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Mobile Drawer Button
                  if (isMobile)
                    IconButton(
                      icon: const Icon(Icons.menu_rounded, color: AppTheme.textDark, size: 26),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),

                  // Brand Logo
                  InkWell(
                    onTap: () => cubit.navigateTo(AppView.home),
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: AppTheme.logoGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.rose600.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'R',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                fontFamily: 'Playfair Display',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: state.isBangla ? 'রূপসী' : 'RUPOSHI',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          letterSpacing: 1.8,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 21,
                                          color: AppTheme.textDark,
                                        ),
                                  ),
                                  const TextSpan(
                                    text: '.',
                                    style: TextStyle(
                                      color: AppTheme.rose600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              'INTERNATIONAL',
                              style: TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 2.4,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.gold600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Desktop Navigation Links
                  if (!isMobile) ...[
                    const Spacer(),
                    Flexible(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _NavLink(
                              label: state.isBangla ? 'হোম' : 'Home',
                              isActive: state.currentView == AppView.home,
                              onTap: () => cubit.navigateTo(AppView.home),
                            ),
                            const SizedBox(width: 6),
                            _NavLink(
                              label: state.isBangla ? 'সব পণ্য' : 'Shop Catalog',
                              isActive: state.currentView == AppView.shop,
                              onTap: () => cubit.navigateTo(AppView.shop),
                            ),
                            const SizedBox(width: 6),
                            _NavLink(
                              label: state.isBangla ? 'আমাদের সম্পর্কে' : 'About Us',
                              isActive: state.currentView == AppView.aboutUs,
                              onTap: () => cubit.navigateTo(AppView.aboutUs),
                            ),
                            const SizedBox(width: 6),
                            _NavLink(
                              label: state.isBangla ? 'বিউটি ব্লগ' : 'Beauty Blog',
                              isActive: state.currentView == AppView.beautyBlog,
                              onTap: () => cubit.navigateTo(AppView.beautyBlog),
                            ),
                            const SizedBox(width: 8),
                            _B2BGoldPillLink(
                              isBangla: state.isBangla,
                              isActive: state.currentView == AppView.b2bPortal,
                              onTap: () => cubit.navigateTo(AppView.b2bPortal),
                            ),
                            const SizedBox(width: 6),
                            _NavLink(
                              label: state.isBangla ? 'যোগাযোগ' : 'Contact',
                              isActive: state.currentView == AppView.contact,
                              onTap: () => cubit.navigateTo(AppView.contact),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                  ] else ...[
                    const Spacer(),
                  ],

                  // Search Quick Trigger
                  if (!isMobile)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: SizedBox(
                        height: 38,
                        child: TextField(
                          onChanged: cubit.setSearch,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: state.isBangla ? 'খুঁজুন (COSRX, CeraVe...)' : 'Search CeraVe, MAC...',
                            prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.rose600),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(width: 14),

                  // Account Sign In Pill
                  IconButton(
                    tooltip: state.isCustomerLoggedIn
                        ? 'Logged in (${state.customerPhone})'
                        : 'Customer Account',
                    icon: Icon(
                      state.isCustomerLoggedIn ? Icons.verified_user : Icons.person_outline_rounded,
                      color: state.isCustomerLoggedIn ? AppTheme.rose600 : AppTheme.textDark,
                      size: 22,
                    ),
                    onPressed: () => _showOtpAuthDialog(context, cubit, state),
                  ),

                  // Wishlist Icon with Badge
                  Stack(
                    children: [
                      IconButton(
                        tooltip: 'Wishlist',
                        icon: const Icon(Icons.favorite_border_rounded, color: AppTheme.textDark, size: 22),
                        onPressed: () => cubit.navigateTo(AppView.shop),
                      ),
                      if (state.wishlistIds.isNotEmpty)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: AppTheme.rose600,
                            child: Text(
                              '${state.wishlistIds.length}',
                              style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Shopping Bag Button
                  Builder(
                    builder: (ctx) => InkWell(
                      onTap: () => Scaffold.of(ctx).openEndDrawer(),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.rose600,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.rose600.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '৳${state.grandTotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            if (state.totalCartUnits > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${state.totalCartUnits}',
                                  style: const TextStyle(
                                    color: AppTheme.rose600,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOtpAuthDialog(BuildContext context, StoreCubit cubit, StoreState state) {
    final phoneCtrl = TextEditingController(text: '+880 1711-223344');
    final otpCtrl = TextEditingController(text: '1234');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppTheme.rose50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shield_outlined, color: AppTheme.rose600, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              state.isBangla ? 'গ্রাহক ওটিপি লগইন' : 'Customer Fast Sign In',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(labelText: 'Bangladesh Mobile Number (+880)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: otpCtrl,
              decoration: const InputDecoration(labelText: '4-Digit SMS Code (Demo: 1234)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.loginCustomerOtp(phoneCtrl.text);
              Navigator.pop(context);
            },
            child: const Text('Verify & Enter'),
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.rose50 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.rose600 : AppTheme.textDark,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _B2BGoldPillLink extends StatelessWidget {
  final bool isBangla;
  final bool isActive;
  final VoidCallback onTap;

  const _B2BGoldPillLink({
    required this.isBangla,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.gold100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.gold300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.business_center, size: 13, color: AppTheme.gold600),
            const SizedBox(width: 5),
            Text(
              isBangla ? 'পাইকারি পোর্টাল (B2B)' : 'B2B Wholesale',
              style: const TextStyle(
                color: AppTheme.gold600,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
