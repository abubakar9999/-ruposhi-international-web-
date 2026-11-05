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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1050;
    final isSmallMobile = screenWidth < 480;
    final isTinyMobile = screenWidth < 360;

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
            color: AppTheme.rose950,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 12 : 24, vertical: 7),
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
                                state.isBangla ? state.announcementBn : state.announcementEn,
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
                          if (!isTinyMobile) ...[
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
                            const SizedBox(width: 10),
                            Text('|', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                            const SizedBox(width: 10),
                          ],
                          if (!isMobile) ...[
                            InkWell(
                              onTap: () => cubit.navigateTo(AppView.admin),
                              child: Row(
                                children: [
                                  const Icon(Icons.admin_panel_settings_outlined, size: 13, color: AppTheme.rose200),
                                  const SizedBox(width: 4),
                                  Text(
                                    state.isBangla ? 'অ্যাডমিন' : 'Admin',
                                    style: const TextStyle(color: AppTheme.rose200, fontSize: 11.5, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('|', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
                            const SizedBox(width: 10),
                          ],
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
              ),
            ),
          ),

          // ==========================================
          // MAIN HEADER ROW (True Geometric Center)
          // ==========================================
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 12 : 24),
                  child: isMobile
                      ? _buildMobileHeader(context, cubit, state, isSmallMobile, isTinyMobile)
                      : _buildDesktopHeader(context, cubit, state, screenWidth),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(
    BuildContext context,
    StoreCubit cubit,
    StoreState state,
    bool isSmallMobile,
    bool isTinyMobile,
  ) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.menu_rounded, color: AppTheme.textDark, size: 24),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: _buildLogo(context, cubit, state, isSmallMobile, isTinyMobile),
        ),
        const Spacer(),
        if (!isTinyMobile)
          IconButton(
            tooltip: state.isCustomerLoggedIn
                ? 'Logged in (${state.customerPhone})'
                : 'Customer Account',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(
              state.isCustomerLoggedIn ? Icons.verified_user : Icons.person_outline_rounded,
              color: state.isCustomerLoggedIn ? AppTheme.rose600 : AppTheme.textDark,
              size: isSmallMobile ? 20 : 22,
            ),
            onPressed: () => _showOtpAuthDialog(context, cubit, state),
          ),
        if (!isSmallMobile) _buildWishlistButton(cubit, state),
        const SizedBox(width: 4),
        _buildCartButton(state, isSmallMobile, isTinyMobile),
      ],
    );
  }

  Widget _buildDesktopHeader(
    BuildContext context,
    StoreCubit cubit,
    StoreState state,
    double screenWidth,
  ) {
    final bool showSearchInput = screenWidth >= 1180;
    final double searchWidth = screenWidth < 1280 ? 120.0 : (screenWidth < 1360 ? 160.0 : 200.0);

    return SizedBox(
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ==========================================
          // LAYER 1: Left Brand Logo & Right Actions
          // ==========================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLogo(context, cubit, state, false, false),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showSearchInput)
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: searchWidth),
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
                    )
                  else
                    IconButton(
                      tooltip: 'Search Products',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      icon: const Icon(Icons.search, color: AppTheme.rose600, size: 22),
                      onPressed: () => cubit.navigateTo(AppView.shop),
                    ),

                  const SizedBox(width: 8),

                  IconButton(
                    tooltip: state.isCustomerLoggedIn
                        ? 'Logged in (${state.customerPhone})'
                        : 'Customer Account',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: Icon(
                      state.isCustomerLoggedIn ? Icons.verified_user : Icons.person_outline_rounded,
                      color: state.isCustomerLoggedIn ? AppTheme.rose600 : AppTheme.textDark,
                      size: 22,
                    ),
                    onPressed: () => _showOtpAuthDialog(context, cubit, state),
                  ),

                  const SizedBox(width: 2),

                  _buildWishlistButton(cubit, state),

                  const SizedBox(width: 6),

                  _buildCartButton(state, false, false),
                ],
              ),
            ],
          ),

          // ==========================================
          // LAYER 2: Nav Links centered geometrically
          // ==========================================
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavLink(
                  label: state.isBangla ? 'হোম' : 'Home',
                  isActive: state.currentView == AppView.home,
                  onTap: () => cubit.navigateTo(AppView.home),
                ),
                const SizedBox(width: 4),
                _NavLink(
                  label: state.isBangla ? 'সব পণ্য' : 'Shop Catalog',
                  isActive: state.currentView == AppView.shop,
                  onTap: () => cubit.navigateTo(AppView.shop),
                ),
                const SizedBox(width: 6),
                _B2BGoldPillLink(
                  isBangla: state.isBangla,
                  isActive: state.currentView == AppView.b2bPortal,
                  isDealerActive: state.isB2BAuthenticated,
                  dealerName: state.activeDealer?.businessName,
                  onTap: () => cubit.navigateTo(AppView.b2bPortal),
                ),
                const SizedBox(width: 6),
                _NavLink(
                  label: state.isBangla ? 'বিউটি ব্লগ' : 'Beauty Blog',
                  isActive: state.currentView == AppView.beautyBlog,
                  onTap: () => cubit.navigateTo(AppView.beautyBlog),
                ),
                const SizedBox(width: 4),
                _NavLink(
                  label: state.isBangla ? 'আমাদের সম্পর্কে' : 'About Us',
                  isActive: state.currentView == AppView.aboutUs,
                  onTap: () => cubit.navigateTo(AppView.aboutUs),
                ),
                const SizedBox(width: 4),
                _NavLink(
                  label: state.isBangla ? 'যোগাযোগ' : 'Contact',
                  isActive: state.currentView == AppView.contact,
                  onTap: () => cubit.navigateTo(AppView.contact),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(
    BuildContext context,
    StoreCubit cubit,
    StoreState state,
    bool isSmallMobile,
    bool isTinyMobile,
  ) {
    return InkWell(
      onTap: () => cubit.navigateTo(AppView.home),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmallMobile ? 30 : 40,
            height: isSmallMobile ? 30 : 40,
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
            child: Center(
              child: Text(
                'R',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallMobile ? 15 : 20,
                  fontFamily: 'Playfair Display',
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: state.isBangla ? 'রূপসী' : 'RUPOSHI',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                letterSpacing: isTinyMobile ? 1.0 : 1.5,
                                fontWeight: FontWeight.bold,
                                fontSize: isTinyMobile ? 15 : (isSmallMobile ? 17 : 21),
                                color: AppTheme.textDark,
                              ),
                        ),
                        const TextSpan(
                          text: '.',
                          style: TextStyle(
                            color: AppTheme.rose600,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  'INTERNATIONAL',
                  style: TextStyle(
                    fontSize: isTinyMobile ? 6.5 : (isSmallMobile ? 7.5 : 9.5),
                    letterSpacing: isTinyMobile ? 1.0 : (isSmallMobile ? 1.4 : 2.4),
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gold600,
                  ),
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

  Widget _buildWishlistButton(StoreCubit cubit, StoreState state) {
    return Stack(
      children: [
        IconButton(
          tooltip: 'Wishlist',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: const Icon(Icons.favorite_border_rounded, color: AppTheme.textDark, size: 22),
          onPressed: () => cubit.navigateTo(AppView.shop),
        ),
        if (state.wishlistIds.isNotEmpty)
          Positioned(
            right: 4,
            top: 4,
            child: CircleAvatar(
              radius: 7,
              backgroundColor: AppTheme.rose600,
              child: Text(
                '${state.wishlistIds.length}',
                style: const TextStyle(fontSize: 8.5, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCartButton(StoreState state, bool isSmallMobile, bool isTinyMobile) {
    return Builder(
      builder: (ctx) => InkWell(
        onTap: () => Scaffold.of(ctx).openEndDrawer(),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTinyMobile ? 8 : (isSmallMobile ? 10 : 14),
            vertical: isSmallMobile ? 7 : 8,
          ),
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
              Icon(Icons.shopping_bag_outlined, color: Colors.white, size: isSmallMobile ? 16 : 18),
              if (!isSmallMobile) ...[
                const SizedBox(width: 6),
                Text(
                  '৳${state.grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
              if (state.totalCartUnits > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${state.totalCartUnits}',
                    style: TextStyle(
                      color: AppTheme.rose600,
                      fontSize: isSmallMobile ? 9 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
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
  final bool isDealerActive;
  final String? dealerName;
  final VoidCallback onTap;

  const _B2BGoldPillLink({
    required this.isBangla,
    required this.isActive,
    this.isDealerActive = false,
    this.dealerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String label = isBangla ? 'বিটুবি পাইকারি' : 'B2B Wholesale';
    if (isDealerActive) {
      final shortName = dealerName != null && dealerName!.isNotEmpty
          ? (dealerName!.length > 14 ? '${dealerName!.substring(0, 12)}…' : dealerName!)
          : 'Dealer';
      label = isBangla ? 'ডিলার: $shortName' : 'Dealer: $shortName';
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: isDealerActive
              ? const Color(0xFFECFDF5)
              : (isActive ? const Color(0xFFFBF1D3) : AppTheme.gold100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDealerActive
                ? const Color(0xFF10B981)
                : (isActive ? AppTheme.goldAccent : AppTheme.gold300),
            width: (isActive || isDealerActive) ? 1.6 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDealerActive
                  ? const Color(0xFF10B981).withValues(alpha: 0.2)
                  : AppTheme.goldAccent.withValues(alpha: 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDealerActive ? Icons.verified : Icons.business_center,
              size: 14,
              color: isDealerActive ? const Color(0xFF047857) : AppTheme.gold600,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isDealerActive ? const Color(0xFF047857) : AppTheme.gold600,
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
