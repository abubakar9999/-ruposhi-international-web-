import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../services/supabase_service.dart';

class CheckoutView extends StatefulWidget {
  final StoreState state;
  const CheckoutView({super.key, required this.state});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _cityCtrl = TextEditingController(text: 'Dhaka');
  final _couponCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _paymentMethod = 'Cash on Delivery (COD)';
  String? _couponMessage;
  bool _couponSuccess = false;

  @override
  void initState() {
    super.initState();
    if (widget.state.isCustomerLoggedIn) {
      _phoneCtrl.text = widget.state.customerPhone;
    }
  }

  void _handleApplyCoupon(StoreCubit cubit) {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) return;
    final success = cubit.applyCoupon(code);
    setState(() {
      _couponSuccess = success;
      if (success) {
        _couponMessage = 'Coupon $code applied successfully (${cubit.state.discountPercent.toStringAsFixed(0)}% Off)!';
      } else {
        _couponMessage = 'Invalid coupon code. Try RUPOSHI10 or LUXE15.';
      }
    });
  }

  Future<void> _sendWhatsAppReceipt(String orderId, double grandTotal) async {
    final text = 'Order Placed on Ruposhi International!\n'
        'Order ID: $orderId\n'
        'Name: ${_nameCtrl.text.trim()}\n'
        'Phone: ${_phoneCtrl.text.trim()}\n'
        'Address: ${_addrCtrl.text.trim()}, ${_cityCtrl.text.trim()}\n'
        'Payment: $_paymentMethod\n'
        'Total: ৳${grandTotal.toStringAsFixed(0)} BDT';

    final url = Uri.parse('https://wa.me/8801700000000?text=${Uri.encodeComponent(text)}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _confirmOrder(BuildContext context, StoreCubit cubit) {
    if (!_formKey.currentState!.validate()) return;
    if (widget.state.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your bag is empty! Add products first.')),
      );
      return;
    }

    final randId = 'RUP-2026-${1000 + Random().nextInt(9000)}';
    final savedGrandTotal = widget.state.grandTotal;
    final savedSubtotal = widget.state.subtotal;
    final savedDeliveryFee = widget.state.deliveryFee;
    final savedItemsCount = widget.state.totalCartUnits;
    final cartItemsPayload = widget.state.cart.map((item) => {
      'id': item.product.id,
      'name': item.product.name,
      'price': item.unitPrice,
      'quantity': item.quantity,
    }).toList();

    // Persist to Supabase in background
    SupabaseService.createOrder(
      orderId: randId,
      customerName: _nameCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      customerAddress: _addrCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      paymentMethod: _paymentMethod,
      subtotal: savedSubtotal,
      deliveryFee: savedDeliveryFee,
      grandTotal: savedGrandTotal,
      items: cartItemsPayload,
    );

    cubit.clearCart();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 52),
            ),
            const SizedBox(height: 18),
            Text(
              widget.state.isBangla ? 'অর্ডার সফলভাবে সম্পন্ন হয়েছে!' : 'Order Placed Successfully!',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Order Reference ID: $randId',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryRose, fontSize: 13.5),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.softBlush,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  _receiptRow('Customer', _nameCtrl.text.isEmpty ? 'Valued Customer' : _nameCtrl.text),
                  _receiptRow('Contact', _phoneCtrl.text),
                  _receiptRow('Destination', '${_addrCtrl.text}, ${_cityCtrl.text}'),
                  _receiptRow('Payment Mode', _paymentMethod),
                  _receiptRow('Total Units', '$savedItemsCount items'),
                  const Divider(height: 14),
                  _receiptRow('Total Payable', '৳${savedGrandTotal.toStringAsFixed(0)} BDT', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.state.isBangla
                  ? 'আপনার ফোনে ট্র্যাকিং এসএমএস পাঠানো হবে। যেকোনো প্রশ্নে আমাদের কনসিয়ার্জে যোগাযোগ করুন।'
                  : 'An SMS confirmation has been queued for your mobile. Our logistics team will dispatch in cold-chain packaging.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _sendWhatsAppReceipt(randId, savedGrandTotal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Send Order to WhatsApp Concierge'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                cubit.navigateTo(AppView.home);
              },
              child: const Text('Return to Home Store'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String k, String v, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(k, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          Flexible(
            child: Text(
              v,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: 12.5,
                color: isBold ? AppTheme.primaryRose : AppTheme.darkPlum,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    if (widget.state.cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(64),
          child: Column(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppTheme.softBlush,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_bag_outlined, size: 40, color: AppTheme.primaryRose),
              ),
              const SizedBox(height: 20),
              Text(
                widget.state.isBangla ? 'আপনার শপিং ব্যাগটি খালি' : 'Your Beauty Bag is Empty',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please select luxury skincare or cosmetics to proceed with checkout.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => cubit.navigateTo(AppView.shop),
                child: const Text('Return to Catalog'),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Form(
            key: _formKey,
            child: Wrap(
              spacing: 36,
              runSpacing: 32,
              children: [
                // ==========================================
                // LEFT: Delivery Information & Payment
                // ==========================================
                SizedBox(
                  width: isMobile ? double.infinity : 680,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.state.isBangla ? 'ডেলিভারি ও চেকআউট তথ্য' : 'Delivery & Express Checkout',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.state.isBangla
                            ? 'সঠিক তথ্য প্রদান করুন যেন আমরা দ্রুত ডেলিভারি নিশ্চিত করতে পারি'
                            : 'No account required. Fast checkout with cash on delivery or instant MFS.',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                      ),
                      const SizedBox(height: 24),

                      // Delivery Form Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recipient Details',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Full Name *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _phoneCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Mobile Number (+880...) *',
                                prefixIcon: Icon(Icons.phone_iphone),
                              ),
                              validator: (v) =>
                                  v == null || v.trim().length < 10 ? 'Enter valid mobile number' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _addrCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Complete Delivery Address (House, Road, Area) *',
                                prefixIcon: Icon(Icons.home_outlined),
                              ),
                              validator: (v) =>
                                  v == null || v.trim().isEmpty ? 'Please provide detailed address' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _cityCtrl,
                              decoration: const InputDecoration(
                                labelText: 'City / District *',
                                prefixIcon: Icon(Icons.location_city_outlined),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Delivery Zone Selector
                            const Text(
                              'Select Delivery Zone:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _DeliveryZoneCard(
                                    title: 'Inside Dhaka',
                                    time: '24-48 Hours',
                                    cost: widget.state.isFreeDeliveryEligible ? 'FREE' : '৳70',
                                    isSelected: widget.state.insideDhaka,
                                    onTap: () => cubit.toggleDeliveryZone(true),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _DeliveryZoneCard(
                                    title: 'Outside Dhaka',
                                    time: '48-72 Hours',
                                    cost: widget.state.isFreeDeliveryEligible ? 'FREE' : '৳130',
                                    isSelected: !widget.state.insideDhaka,
                                    onTap: () => cubit.toggleDeliveryZone(false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Payment Method Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderSubtle),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Method',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 16),
                            _PaymentOptionTile(
                              title: 'Cash on Delivery (COD)',
                              subtitle: 'Pay after inspecting package at your doorstep',
                              icon: Icons.payments_outlined,
                              color: Colors.green,
                              isSelected: _paymentMethod == 'Cash on Delivery (COD)',
                              onTap: () => setState(() => _paymentMethod = 'Cash on Delivery (COD)'),
                            ),
                            _PaymentOptionTile(
                              title: 'bKash Merchant Pay',
                              subtitle: 'Instant mobile verification via bKash gateway',
                              icon: Icons.account_balance_wallet_outlined,
                              color: const Color(0xFFE2136E),
                              isSelected: _paymentMethod == 'bKash Merchant Pay',
                              onTap: () => setState(() => _paymentMethod = 'bKash Merchant Pay'),
                            ),
                            _PaymentOptionTile(
                              title: 'Nagad Instant Pay',
                              subtitle: 'Fast postal digital wallet payment',
                              icon: Icons.mobile_friendly_outlined,
                              color: const Color(0xFFF7941D),
                              isSelected: _paymentMethod == 'Nagad Instant Pay',
                              onTap: () => setState(() => _paymentMethod = 'Nagad Instant Pay'),
                            ),
                            _PaymentOptionTile(
                              title: 'SSLCommerz (Visa / Mastercard / Amex)',
                              subtitle: 'Secure card checkout with 128-bit encryption',
                              icon: Icons.credit_card_outlined,
                              color: Colors.blue.shade800,
                              isSelected: _paymentMethod == 'SSLCommerz (Cards)',
                              onTap: () => setState(() => _paymentMethod = 'SSLCommerz (Cards)'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ==========================================
                // RIGHT: Order Summary Card
                // ==========================================
                SizedBox(
                  width: isMobile ? double.infinity : 440,
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Summary',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            Text(
                              '${widget.state.totalCartUnits} Items',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                        const Divider(height: 24),

                        // Mini items preview list
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: widget.state.cart.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final it = widget.state.cart[idx];
                              return Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      it.product.imageUrl,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          it.product.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                        ),
                                        Text(
                                          '${it.quantity} x ৳${it.unitPrice.toStringAsFixed(0)}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '৳${it.total.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const Divider(height: 24),

                        // Coupon Code Input
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _couponCtrl,
                                textCapitalization: TextCapitalization.characters,
                                decoration: const InputDecoration(
                                  hintText: 'Promo Code (e.g. RUPOSHI10)',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () => _handleApplyCoupon(cubit),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                              ),
                              child: const Text('Apply'),
                            ),
                          ],
                        ),

                        if (_couponMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _couponMessage!,
                            style: TextStyle(
                              fontSize: 12,
                              color: _couponSuccess ? Colors.green.shade800 : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Pricing Math
                        _summaryRow('Subtotal', '৳${widget.state.subtotal.toStringAsFixed(0)}'),
                        if (widget.state.discountAmount > 0)
                          _summaryRow(
                            'Coupon Discount (${widget.state.discountPercent.toStringAsFixed(0)}%)',
                            '-৳${widget.state.discountAmount.toStringAsFixed(0)}',
                            color: Colors.green.shade800,
                          ),
                        _summaryRow(
                          'Delivery Fee',
                          widget.state.deliveryFee == 0 ? 'FREE' : '৳${widget.state.deliveryFee.toStringAsFixed(0)}',
                          color: widget.state.deliveryFee == 0 ? Colors.green.shade800 : null,
                        ),

                        const Divider(height: 24),

                        // Total Payable
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Payable',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '৳${widget.state.grandTotal.toStringAsFixed(0)} BDT',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                color: AppTheme.primaryRose,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Confirm Button
                        ElevatedButton(
                          onPressed: () => _confirmOrder(context, cubit),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                widget.state.isBangla ? 'অর্ডার কনফার্ম করুন' : 'Confirm Order',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Center(
                          child: Text(
                            '🔒 256-bit SSL encrypted & authentic cosmetics guarantee',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 13.5)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color ?? AppTheme.darkPlum,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryZoneCard extends StatelessWidget {
  final String title;
  final String time;
  final String cost;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryZoneCard({
    required this.title,
    required this.time,
    required this.cost,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryRose.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRose : AppTheme.borderSubtle,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: isSelected ? AppTheme.primaryRose : AppTheme.darkPlum,
                  ),
                ),
                Text(
                  cost,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? color : AppTheme.borderSubtle,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
        trailing: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: isSelected ? color : Colors.grey.shade400,
          size: 20,
        ),
      ),
    );
  }
}
