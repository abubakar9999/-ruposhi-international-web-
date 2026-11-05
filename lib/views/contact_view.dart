import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';

class ContactView extends StatefulWidget {
  final StoreState state;
  const ContactView({super.key, required this.state});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final _trackCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  Future<void> _launchWhatsApp(String msg) async {
    final url = Uri.parse('https://wa.me/8801700000000?text=${Uri.encodeComponent(msg)}');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Tracking Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 24 : 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppTheme.rose50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_shipping_outlined, color: AppTheme.rose600, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.state.isBangla ? 'লাইভ অর্ডার ট্র্যাকিং' : 'Track Your Order',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                widget.state.isBangla
                                    ? 'আপনার অর্ডারের রেফারেন্স আইডি দিন'
                                    : 'Enter your Ruposhi order ID (e.g. RUP-2026-9812)',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _trackCtrl,
                            decoration: const InputDecoration(
                              hintText: 'e.g. RUP-2026-9812',
                              prefixIcon: Icon(Icons.confirmation_number_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => cubit.trackOrder(_trackCtrl.text),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                          ),
                          child: const Text('Track'),
                        ),
                      ],
                    ),
                    if (widget.state.trackOrderStatus != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Colors.green),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Order #${widget.state.trackedOrderId}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.state.trackOrderStatus!,
                                    style: TextStyle(color: Colors.green.shade900, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Contact & Corporate Info Wrap (Adaptive for Mobile, Tablet, Desktop)
              LayoutBuilder(
                builder: (context, constraints) {
                  final available = constraints.maxWidth;
                  final isStacked = available < 1000;
                  final double leftWidth = isStacked ? double.infinity : (available - 32) * 0.46;
                  final double rightWidth = isStacked ? double.infinity : (available - 32) * 0.54;

                  return Wrap(
                    spacing: 32,
                    runSpacing: 24,
                    children: [
                      // Office Address & Channels
                      SizedBox(
                        width: leftWidth,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Corporate Headquarters & Central Hub',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                Icons.location_on_outlined,
                                'Ruposhi International Ltd.\nLevel 7, Lotus Kamal Tower\nBanani Commercial Area, Dhaka-1213\nBangladesh',
                              ),
                              const SizedBox(height: 14),
                              _infoRow(
                                Icons.phone_outlined,
                                'Concierge Hotline: +880 1700-000000\nCustomer Service: +880 1711-223344',
                              ),
                              const SizedBox(height: 14),
                              _infoRow(
                                Icons.email_outlined,
                                'General: concierge@ruposhi.com.bd\nWholesale B2B: b2b@ruposhi.com.bd',
                              ),
                              const SizedBox(height: 14),
                              _infoRow(
                                Icons.schedule,
                                'Support Hours: Saturday to Thursday (9:00 AM - 9:00 PM)',
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Message Form
                      SizedBox(
                        width: rightWidth,
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Send a Direct Inquiry to Concierge',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _nameCtrl,
                                decoration: const InputDecoration(labelText: 'Your Full Name'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _phoneCtrl,
                                decoration: const InputDecoration(labelText: 'Mobile Number (+880)'),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _msgCtrl,
                                maxLines: 3,
                                decoration: const InputDecoration(labelText: 'Your Question or Product Request'),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final text = 'Inquiry from ${_nameCtrl.text} (${_phoneCtrl.text}): ${_msgCtrl.text}';
                                    _launchWhatsApp(text);
                                  },
                                  icon: const Icon(Icons.send_rounded, size: 16),
                                  label: const Text('Send Message via WhatsApp'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.rose600, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppTheme.textDark),
          ),
        ),
      ],
    );
  }
}
