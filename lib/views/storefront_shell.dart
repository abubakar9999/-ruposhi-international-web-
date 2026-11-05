import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../widgets/cart_drawer.dart';
import '../widgets/footer_section.dart';
import '../widgets/top_nav_bar.dart';
import 'about_view.dart';
import 'b2b_view.dart';
import 'blog_view.dart';
import 'checkout_view.dart';
import 'contact_view.dart';
import 'home_view.dart';
import 'product_details_view.dart';
import 'shop_view.dart';

class StorefrontShell extends StatelessWidget {
  const StorefrontShell({super.key});

  Future<void> _launchWhatsApp(BuildContext context, bool isBangla) async {
    final message = Uri.encodeComponent(
      'Hello Ruposhi International Concierge! I would like to inquire about authentic imported cosmetics and delivery in Bangladesh.',
    );
    final url = Uri.parse('https://wa.me/8801700000000?text=$message');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('WhatsApp Concierge: +880 1700-000000')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp Concierge: +880 1700-000000')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreCubit, StoreState>(
      builder: (context, state) {
        final cubit = context.read<StoreCubit>();

        return Scaffold(
          appBar: TopNavBar(state: state),
          // Mobile Drawer for responsive navigation
          drawer: Drawer(
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    color: AppTheme.darkPlum,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryRose,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'RUPOSHI INTERNATIONAL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '100% Authentic Imported Cosmetics',
                          style: TextStyle(color: AppTheme.goldLight, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: Text(state.isBangla ? 'হোম' : 'Home'),
                    selected: state.currentView == AppView.home,
                    onTap: () {
                      Navigator.pop(context);
                      cubit.navigateTo(AppView.home);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.storefront_outlined),
                    title: Text(state.isBangla ? 'শপ ক্যাটালগ' : 'Cosmetics Catalog'),
                    selected: state.currentView == AppView.shop,
                    onTap: () {
                      Navigator.pop(context);
                      cubit.navigateTo(AppView.shop);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(state.isBangla ? 'আমাদের সম্পর্কে' : 'Our Story & Warehousing'),
                    selected: state.currentView == AppView.aboutUs,
                    onTap: () {
                      Navigator.pop(context);
                      cubit.navigateTo(AppView.aboutUs);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.article_outlined),
                    title: Text(state.isBangla ? 'বিউটি ব্লগ ও গাইড' : 'Beauty Blog & Guides'),
                    selected: state.currentView == AppView.beautyBlog,
                    onTap: () {
                      Navigator.pop(context);
                      cubit.navigateTo(AppView.beautyBlog);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.headset_mic_outlined),
                    title: Text(state.isBangla ? 'যোগাযোগ ও ট্র্যাকিং' : 'Contact & Live Tracking'),
                    selected: state.currentView == AppView.contact,
                    onTap: () {
                      Navigator.pop(context);
                      cubit.navigateTo(AppView.contact);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.business_center_outlined, color: Colors.green),
                    title: Text(
                      state.isBangla ? 'বিটুবি পাইকারি পোর্টাল' : 'B2B Wholesale Portal',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    selected: state.currentView == AppView.b2bPortal,
                    onTap: () {
                      Navigator.pop(context);
                      cubit.navigateTo(AppView.b2bPortal);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(state.isBangla ? 'শপিং ব্যাগ' : 'Shopping Bag'),
                    trailing: Text(
                      '${state.totalCartUnits}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(state.isBangla ? 'Switch to English' : 'বাংলা ভাষায় দেখুন'),
                    onTap: () {
                      cubit.toggleLanguage();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
          endDrawer: CartDrawer(state: state),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _launchWhatsApp(context, state.isBangla),
            backgroundColor: const Color(0xFF25D366),
            elevation: 4,
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
            label: Text(
              state.isBangla ? 'হোয়াটসঅ্যাপ সহায়তা' : 'WhatsApp Concierge',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildActiveBody(context, state),
                FooterSection(state: state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveBody(BuildContext context, StoreState state) {
    switch (state.currentView) {
      case AppView.home:
        return HomeView(state: state);
      case AppView.shop:
        return ShopCatalogView(state: state);
      case AppView.productDetails:
        return ProductDetailsView(
          product: state.activeProduct ?? state.products.first,
          state: state,
        );
      case AppView.aboutUs:
        return AboutUsView(state: state);
      case AppView.beautyBlog:
        return BeautyBlogView(state: state);
      case AppView.contact:
        return ContactView(state: state);
      case AppView.b2bPortal:
        return B2BWholesaleView(state: state);
      case AppView.checkout:
        return CheckoutView(state: state);
    }
  }
}
