import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';

class B2BWholesaleView extends StatefulWidget {
  final StoreState state;
  const B2BWholesaleView({super.key, required this.state});

  @override
  State<B2BWholesaleView> createState() => _B2BWholesaleViewState();
}

class _B2BWholesaleViewState extends State<B2BWholesaleView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _launchB2BSupport() async {
    final url = Uri.parse(
      'https://wa.me/8801700000000?text=${Uri.encodeComponent("Hello Ruposhi B2B Wholesale Dept, I would like to inquire about bulk dealership.")}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 800;

    if (!widget.state.isB2BAuthenticated) {
      return Center(
        child: Container(
          width: 480,
          margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 48),
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.midnightPlum,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.midnightPlum.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.lock_person_outlined, color: AppTheme.goldLight, size: 30),
              ),
              const SizedBox(height: 18),
              Text(
                widget.state.isBangla ? 'বিটুবি ডিলার পোর্টাল গেট' : 'B2B Wholesale Dealer Gate',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.state.isBangla
                    ? 'অনুমোদিত ডিলার, ফার্মেসি ও পার্লারের জন্য সংরক্ষিত পাইকারি মূল্য তালিকা ও এমওকিউ শিট।'
                    : 'Exclusive bulk wholesale pricing & dealer margins for registered beauty retailers and certified salons across Bangladesh.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Dealer ID / Registered Mobile',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Wholesale Password',
                  prefixIcon: Icon(Icons.key_outlined),
                ),
              ),
              if (widget.state.b2bError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    widget.state.b2bError!,
                    style: TextStyle(color: Colors.red.shade900, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => cubit.loginB2B(_usernameController.text, _passwordController.text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.darkPlum,
                  foregroundColor: AppTheme.goldLight,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_open, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.state.isBangla ? 'ডিলার হিসেবে আনলক করুন' : 'Unlock Wholesale Pricing',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  _usernameController.text = 'aaaa';
                  _passwordController.text = 'aaaa';
                  cubit.loginB2B('aaaa', 'aaaa');
                },
                child: const Text('1-Click Demo Login (aaaa / aaaa)'),
              ),
              const SizedBox(height: 16),
              const Divider(),
              TextButton.icon(
                onPressed: _launchB2BSupport,
                icon: const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                label: const Text('Apply for New Dealership on WhatsApp'),
              ),
            ],
          ),
        ),
      );
    }

    // Authenticated B2B View
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // B2B Status Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B3B2B), Color(0xFF2E6347)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified, color: Colors.greenAccent, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'OFFICIAL WHOLESALE DEALER ACTIVE',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.state.isBangla
                                ? 'অনুমোদিত ডিলার প্রাইস শিট ও বাল্ক অর্ডার পোর্টাল'
                                : 'Approved B2B Dealer Price Sheet & Consignment Portal',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'All prices are shown excluding local courier freight. 100% genuine BSTI and Customs cleared batches with VAT Challan 6.3.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: cubit.logoutB2B,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white60),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                      icon: const Icon(Icons.lock_outline, size: 16),
                      label: const Text('Lock Portal'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Wholesale Product Table / List
              ...widget.state.products.map((p) {
                final marginPercent = ((p.retailPrice - p.wholesalePrice) / p.retailPrice) * 100;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          p.imageUrl,
                          width: 80,
                          height: 85,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80,
                            height: 85,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.spa_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  p.brand.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryRose,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•  ${p.originCountry}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'Retail MRP: ৳${p.retailPrice.toStringAsFixed(0)}',
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                                ),
                                Text(
                                  'Batch: ${p.batchNo}',
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                                ),
                                Text(
                                  'Expiry: ${p.expiryDate}',
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Price & MOQ Action
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: Text(
                                  '${marginPercent.toStringAsFixed(0)}% Margin',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '৳${p.wholesalePrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'MOQ: ${p.moq} units (Total: ৳${(p.wholesalePrice * p.moq).toStringAsFixed(0)})',
                            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              cubit.addToCart(p, qty: p.moq, isWholesale: true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.midnightPlum,
                                  content: Text('Added MOQ bundle (${p.moq} units) of ${p.name} at wholesale rate!'),
                                  action: SnackBarAction(
                                    label: 'View Bag',
                                    textColor: AppTheme.goldLight,
                                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: Text('Add MOQ (${p.moq} Units)'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
