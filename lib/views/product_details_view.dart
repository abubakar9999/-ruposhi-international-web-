import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../models/product_model.dart';

class ProductDetailsView extends StatefulWidget {
  final Product product;
  final StoreState state;

  const ProductDetailsView({
    super.key,
    required this.product,
    required this.state,
  });

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  late String _selectedOption;
  int _quantity = 1;
  int _activeInfoTab = 0; // 0: Description & Benefits, 1: Ingredients, 2: How to Use, 3: Authenticity

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.product.shadesOrSizes.first;
  }

  Future<void> _launchWhatsAppConcierge(Product p) async {
    final message = Uri.encodeComponent(
      'Hello Ruposhi International! I want to order/inquire about: ${p.name} (Batch: ${p.batchNo}, Price: ৳${p.retailPrice.toStringAsFixed(0)} BDT).',
    );
    final url = Uri.parse('https://wa.me/8801700000000?text=$message');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch WhatsApp. WhatsApp Concierge: +880 1700-000000')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('WhatsApp Concierge: +880 1700-000000')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 900;
    final isSmallMobile = MediaQuery.of(context).size.width < 420;
    final p = widget.product;
    final isWishlisted = widget.state.isWishlisted(p.id);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Breadcrumb Navigation
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  InkWell(
                    onTap: () => cubit.navigateTo(AppView.home),
                    child: Text(
                      widget.state.isBangla ? 'হোম' : 'Home',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ),
                  InkWell(
                    onTap: () => cubit.navigateTo(AppView.shop),
                    child: Text(
                      widget.state.isBangla ? 'ক্যাটালগ' : 'Catalog',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ),
                  InkWell(
                    onTap: () => cubit.setCategory(p.category),
                    child: Text(
                      p.category,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ),
                  Text(
                    p.brand,
                    style: const TextStyle(
                      color: AppTheme.primaryRose,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Main Product Showcase Layout
              Wrap(
                spacing: 48,
                runSpacing: 32,
                children: [
                  // Left: Product Image & Highlights
                  SizedBox(
                    width: isMobile ? double.infinity : 480,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Card
                        Container(
                          height: isMobile ? 360 : 480,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.borderSubtle),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  p.imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.spa_outlined, size: 64, color: Colors.grey),
                                  ),
                                ),
                              ),
                              // Badges
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: isSmallMobile ? 180 : 300),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.94),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(p.countryFlag, style: const TextStyle(fontSize: 13)),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          'Imported from ${p.originCountry}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                            color: AppTheme.darkPlum,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Wishlist Button
                              Positioned(
                                top: 12,
                                right: 12,
                                child: InkWell(
                                  onTap: () => cubit.toggleWishlist(p.id),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.92),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isWishlisted ? Icons.favorite : Icons.favorite_border_rounded,
                                      color: isWishlisted ? Colors.redAccent : AppTheme.darkPlum,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Trust Badges Under Image
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: const Wrap(
                            alignment: WrapAlignment.spaceAround,
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              _MiniTrust(icon: Icons.shield_outlined, label: '100% Authentic'),
                              _MiniTrust(icon: Icons.ac_unit, label: '20°C Stored'),
                              _MiniTrust(icon: Icons.verified_outlined, label: 'Batch Verified'),
                              _MiniTrust(icon: Icons.local_shipping_outlined, label: 'Fast Dispatch'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Product Details & Purchase Form
                  SizedBox(
                    width: isMobile ? double.infinity : 600,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand & Category
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            Text(
                              p.brand.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.primaryRose,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.softBlush,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.category,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Title
                        Text(
                          widget.state.isBangla ? p.nameBn : p.name,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.25,
                              ),
                        ),

                        const SizedBox(height: 12),

                        // Ratings & Reviews Count
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (i) => const Icon(Icons.star_rounded, size: 18, color: AppTheme.goldAccent),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${p.rating} / 5.0',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            Text(
                              ' (${p.reviewsCount} customer reviews in BD)',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Pricing Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.softBlush,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 10,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        '৳${p.retailPrice.toStringAsFixed(0)} BDT',
                                        style: TextStyle(
                                          fontSize: isSmallMobile ? 22 : 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.darkPlum,
                                        ),
                                      ),
                                      if (p.oldPrice != null)
                                        Text(
                                          '৳${p.oldPrice!.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey.shade400,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      if (p.discountPercent > 0)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.rose600,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '-${p.discountPercent}% OFF',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Inclusive of all import taxes & VAT',
                                    style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              if (widget.state.isB2BAuthenticated)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.green.shade300),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Wholesale: ৳${p.wholesalePrice.toStringAsFixed(0)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                      Text(
                                        'MOQ: ${p.moq} units',
                                        style: TextStyle(fontSize: 11, color: Colors.green.shade800),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Transparency Grid (Batch, Expiry, Skin Type)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Column(
                            children: [
                              _TransparencyRow(
                                title: 'Batch Number',
                                value: p.batchNo,
                                isBold: true,
                              ),
                              const Divider(height: 16),
                              _TransparencyRow(
                                title: 'Expiration Date',
                                value: p.expiryDate,
                                valueColor: Colors.green.shade800,
                              ),
                              const Divider(height: 16),
                              _TransparencyRow(
                                title: 'Skin Compatibility',
                                value: p.skinType,
                              ),
                              const Divider(height: 16),
                              _TransparencyRow(
                                title: 'Dhaka Fulfilment Hub',
                                value: '${p.stock} units in stock',
                                valueColor: Colors.blue.shade800,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Options / Size / Shade Selector
                        if (p.shadesOrSizes.isNotEmpty) ...[
                          Text(
                            widget.state.isBangla ? 'সাইজ / শেড নির্বাচন করুন' : 'Select Volume / Shade',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: p.shadesOrSizes.map((opt) {
                              final isSelected = _selectedOption == opt;
                              return ChoiceChip(
                                label: Text(opt),
                                selected: isSelected,
                                selectedColor: AppTheme.primaryRose,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppTheme.darkPlum,
                                  fontWeight: FontWeight.w600,
                                ),
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected ? AppTheme.primaryRose : AppTheme.borderSubtle,
                                ),
                                onSelected: (_) => setState(() => _selectedOption = opt),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 22),
                        ],

                        // Quantity Selector & Action Buttons
                        Builder(
                          builder: (context) {
                            final quantityBox = Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppTheme.borderSubtle),
                                borderRadius: BorderRadius.circular(25),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    onPressed: () {
                                      if (_quantity > 1) setState(() => _quantity--);
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      '$_quantity',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    onPressed: () {
                                      if (_quantity < p.stock) setState(() => _quantity++);
                                    },
                                  ),
                                ],
                              ),
                            );

                            final addToBagButton = ElevatedButton.icon(
                              onPressed: () {
                                cubit.addToCart(p, qty: _quantity, option: _selectedOption);
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppTheme.midnightPlum,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text('Added $_quantity x ${p.name} to your Beauty Bag!'),
                                    action: SnackBarAction(
                                      label: 'Open Bag',
                                      textColor: AppTheme.goldLight,
                                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                              label: Text(
                                widget.state.isBangla ? 'ব্যাগে যোগ করুন' : 'Add to Beauty Bag',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            );

                            if (isSmallMobile) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Quantity: ',
                                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                                      ),
                                      const SizedBox(width: 8),
                                      quantityBox,
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  addToBagButton,
                                ],
                              );
                            }

                            return Row(
                              children: [
                                quantityBox,
                                const SizedBox(width: 16),
                                Expanded(child: addToBagButton),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // WhatsApp Instant Concierge Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _launchWhatsAppConcierge(p),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E8E3E),
                              side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFFF0FDF4),
                            ),
                            icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
                            label: Text(
                              widget.state.isBangla
                                  ? 'হোয়াটসঅ্যাপে অর্ডার ও কনসাল্টেশন'
                                  : 'Order or Ask via WhatsApp Concierge',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Detailed Tabs: Description, Ingredients, How to Use, Authenticity
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  children: [
                    // Tab Bar (Horizontally scrollable for mobile)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.softBlush,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _TabPill(
                              label: widget.state.isBangla ? 'বিবরণ ও ফলাফল' : 'Description & Benefits',
                              isActive: _activeInfoTab == 0,
                              onTap: () => setState(() => _activeInfoTab = 0),
                            ),
                            _TabPill(
                              label: widget.state.isBangla ? 'উপাদান তালিকা' : 'Ingredients',
                              isActive: _activeInfoTab == 1,
                              onTap: () => setState(() => _activeInfoTab = 1),
                            ),
                            _TabPill(
                              label: widget.state.isBangla ? 'ব্যবহার বিধি' : 'How to Use',
                              isActive: _activeInfoTab == 2,
                              onTap: () => setState(() => _activeInfoTab = 2),
                            ),
                            _TabPill(
                              label: widget.state.isBangla ? 'আমদানি সত্যতা' : 'Batch Authenticity',
                              isActive: _activeInfoTab == 3,
                              onTap: () => setState(() => _activeInfoTab = 3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tab Content
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: _buildActiveTabContent(p),
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

  Widget _buildActiveTabContent(Product p) {
    switch (_activeInfoTab) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.state.isBangla && p.descriptionBn.isNotEmpty ? p.descriptionBn : p.description,
              style: const TextStyle(fontSize: 15, height: 1.6, color: AppTheme.darkPlum),
            ),
            if (p.keyBenefits.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Key Clinical Benefits:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),
              ...p.keyBenefits.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: AppTheme.primaryRose),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(b, style: const TextStyle(fontSize: 13.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Full Declared Formula & Ingredients:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Text(
              p.ingredients,
              style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey.shade800),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.softBlush,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'All formulations comply with BSTI and EU/KFDA cosmetic standards. Free of parabens, harmful artificial dyes, and adulterants.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Application Instructions & Routine Placement:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Text(
              p.usageInstructions,
              style: const TextStyle(fontSize: 14.5, height: 1.6, color: AppTheme.darkPlum),
            ),
          ],
        );
      case 3:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Official Batch Code Transparency & Cold Chain Guarantee:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Text(
              'Every batch of ${p.name} (Batch: ${p.batchNo}, Expiry: ${p.expiryDate}) was imported via direct air cargo at an ambient cabin temperature of 18-22°C to prevent thermal degradation of active extracts. Authenticity guaranteed with full manufacturer batch records.',
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        );
    }
  }
}

class _MiniTrust extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniTrust({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryRose),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.darkPlum),
        ),
      ],
    );
  }
}

class _TransparencyRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _TransparencyRow({
    required this.title,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              fontSize: 13.5,
              color: valueColor ?? AppTheme.darkPlum,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              fontSize: 13,
              color: isActive ? AppTheme.primaryRose : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
