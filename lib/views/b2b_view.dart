import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../admin/admin_models.dart';

class B2BWholesaleView extends StatefulWidget {
  final StoreState state;
  const B2BWholesaleView({super.key, required this.state});

  @override
  State<B2BWholesaleView> createState() => _B2BWholesaleViewState();
}

class _B2BWholesaleViewState extends State<B2BWholesaleView> {
  // Tab index: 0 = Dealer Login, 1 = Apply for Dealership
  int _activeTabIndex = 0;

  // Login controllers
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Registration controllers
  final _regBusinessNameCtrl = TextEditingController();
  final _regContactPersonCtrl = TextEditingController();
  final _regPhoneCtrl = TextEditingController(text: '+880 1');
  final _regEmailCtrl = TextEditingController();
  final _regDistrictCtrl = TextEditingController(text: 'Dhaka');
  final _regTradeLicenseCtrl = TextEditingController(text: 'TRAD/DNCC/');
  String _regBusinessType = 'Wholesaler';
  String _regOrderVolume = '৳50,000 - ৳2,00,000 / month';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _regBusinessNameCtrl.dispose();
    _regContactPersonCtrl.dispose();
    _regPhoneCtrl.dispose();
    _regEmailCtrl.dispose();
    _regDistrictCtrl.dispose();
    _regTradeLicenseCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchB2BSupport() async {
    final url = Uri.parse(
      'https://wa.me/8801700000000?text=${Uri.encodeComponent("Hello Ruposhi B2B Wholesale Dept, I would like to inquire about dealer/wholesaler accounts.")}',
    );
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _submitDealershipApplication(StoreCubit cubit) {
    final businessName = _regBusinessNameCtrl.text.trim();
    final contactPerson = _regContactPersonCtrl.text.trim();
    final phone = _regPhoneCtrl.text.trim();

    if (businessName.isEmpty || contactPerson.isEmpty || phone.isEmpty || phone == '+880 1') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in Business Name, Contact Person, and Mobile Phone number.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newApplication = B2BPartner(
      id: 'b2b_${DateTime.now().millisecondsSinceEpoch}',
      businessName: businessName,
      contactPerson: contactPerson,
      phone: phone,
      email: _regEmailCtrl.text.trim(),
      tradeLicense: _regTradeLicenseCtrl.text.trim(),
      district: _regDistrictCtrl.text.trim(),
      tier: 'Wholesaler (20% off)',
      status: 'Pending Review',
      businessType: _regBusinessType,
      totalOrders: 0,
      totalSpend: 0.0,
    );

    cubit.applyForDealership(newApplication);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 48),
            ),
            const SizedBox(height: 18),
            const Text(
              'Application Submitted!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Thank you, $contactPerson. Your application for "$businessName" has been registered and is pending executive review by our Wholesale Accounts Director.\n\nWe will verify your trade license and activate your portal login ($phone) within 2 hours.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _activeTabIndex = 0);
                _usernameController.text = phone;
                _passwordController.text = '1234';
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.darkPlum,
                foregroundColor: AppTheme.goldLight,
              ),
              child: const Text('Back to Dealer Login Gate'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 800;
    final isSmallMobile = MediaQuery.of(context).size.width < 480;

    if (!widget.state.isB2BAuthenticated) {
      return Center(
        child: Container(
          width: 540,
          margin: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 12 : (isMobile ? 16 : 24),
            vertical: isMobile ? 24 : 48,
          ),
          padding: EdgeInsets.all(isSmallMobile ? 20 : (isMobile ? 24 : 32)),
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
              // Top Icon & Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56,
                    height: 56,
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
                    child: const Icon(Icons.business_center, color: AppTheme.goldLight, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                widget.state.isBangla ? 'বিটুবি ডিলার পোর্টাল গেট' : 'B2B Wholesale Dealer Gate',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallMobile ? 20 : 22,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.state.isBangla
                    ? 'অনুমোদিত ডিলার, হোলসেলার, ফার্মেসি ও পার্লারের জন্য সংরক্ষিত পাইকারি মূল্য তালিকা।'
                    : 'Exclusive bulk wholesale trade prices & dealer profit margins for verified cosmetics retailers, salons, and pharmacies across Bangladesh.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.4),
              ),
              const SizedBox(height: 20),

              // Segmented Tab Switcher: Login vs Apply
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTabIndex = 0),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTabIndex == 0 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _activeTabIndex == 0
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_open,
                                  size: 16,
                                  color: _activeTabIndex == 0 ? AppTheme.midnightPlum : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.state.isBangla ? 'ডিলার লগইন' : 'Dealer Login',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _activeTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                                    color: _activeTabIndex == 0 ? AppTheme.midnightPlum : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _activeTabIndex = 1),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _activeTabIndex == 1 ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _activeTabIndex == 1
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.app_registration,
                                  size: 16,
                                  color: _activeTabIndex == 1 ? AppTheme.rose800 : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  widget.state.isBangla ? 'নতুন ডিলার আবেদন' : 'Apply Dealership',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: _activeTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                                    color: _activeTabIndex == 1 ? AppTheme.rose800 : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ==========================================
              // TAB 0: DEALER / WHOLESALER LOGIN FORM
              // ==========================================
              if (_activeTabIndex == 0) ...[
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Dealer Mobile Phone / Trade License / ID',
                    hintText: 'e.g. 01711223344 or Trade License',
                    prefixIcon: const Icon(Icons.phone_iphone_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Wholesale Password / Security PIN',
                    hintText: 'Enter your dealer password or PIN',
                    prefixIcon: const Icon(Icons.key_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                if (widget.state.b2bError != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.state.b2bError!,
                            style: TextStyle(color: Colors.red.shade900, fontSize: 12, height: 1.3),
                          ),
                        ),
                      ],
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_open, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.state.isBangla ? 'ডিলার হিসেবে আনলক করুন' : 'Unlock Wholesale Pricing',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 20, color: AppTheme.rose800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.state.isBangla
                              ? 'অনুমোদিত ডিলার ও পাইকারি ক্রেতারা তাদের নিবন্ধিত ফোন নম্বর দিয়ে সরাসরি লগইন করতে পারেন।'
                              : 'Authorized dealers can sign in directly using their registered mobile phone number. New salons, spas, and wholesalers can apply above.',
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ==========================================
              // TAB 1: APPLY FOR DEALERSHIP FORM
              // ==========================================
              if (_activeTabIndex == 1) ...[
                TextField(
                  controller: _regBusinessNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Business / Salon / Shop Name *',
                    hintText: 'e.g. Royal Glow Beauty Salon & Spa',
                    prefixIcon: const Icon(Icons.storefront_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regContactPersonCtrl,
                  decoration: InputDecoration(
                    labelText: 'Proprietor / Contact Person Name *',
                    hintText: 'e.g. Mrs. Sharmin Sultana',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regPhoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Mobile Phone Number *',
                    hintText: '+880 1700-000000',
                    prefixIcon: const Icon(Icons.phone_android_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _regBusinessType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Business Type',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['Wholesaler', 'Salon & Spa', 'Pharmacy', 'Distributor']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _regBusinessType = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _regDistrictCtrl,
                        decoration: InputDecoration(
                          labelText: 'District / Region',
                          hintText: 'e.g. Dhaka',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regTradeLicenseCtrl,
                  decoration: InputDecoration(
                    labelText: 'Bangladesh Trade License Number',
                    hintText: 'TRAD/DNCC/...',
                    prefixIcon: const Icon(Icons.verified_user_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _regOrderVolume,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Estimated Monthly Volume',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [
                    '৳50,000 - ৳2,00,000 / month',
                    '৳2,00,000 - ৳5,00,000 / month',
                    '৳5,00,000+ / month (Master Distributor)'
                  ].map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _regOrderVolume = val);
                  },
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: () => _submitDealershipApplication(cubit),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.rose800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send_rounded, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.state.isBangla ? 'আবেদন জমা দিন' : 'Submit Dealership Application',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),
              const Divider(),
              TextButton.icon(
                onPressed: _launchB2BSupport,
                icon: const Icon(Icons.chat, size: 16, color: Color(0xFF25D366)),
                label: const Text(
                  'Talk to Wholesale Director on WhatsApp',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ==========================================
    // AUTHENTICATED B2B DEALER VIEW
    // ==========================================
    final activeDealer = widget.state.activeDealer;

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
                padding: EdgeInsets.all(isMobile ? 18 : 24),
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
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified, color: Colors.greenAccent, size: 20),
                              SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'OFFICIAL WHOLESALE DEALER ACTIVE',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            activeDealer?.businessName ??
                                (widget.state.isBangla
                                    ? 'অনুমোদিত ডিলার প্রাইস শিট ও বাল্ক অর্ডার পোর্টাল'
                                    : 'Approved B2B Dealer Price Sheet & Consignment Portal'),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  activeDealer?.tier ?? 'Platinum Tier (30% off)',
                                  style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 11.5),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  activeDealer?.businessType ?? 'Wholesaler',
                                  style: const TextStyle(color: Colors.white, fontSize: 11.5),
                                ),
                              ),
                              if (activeDealer != null && activeDealer.phone.isNotEmpty)
                                Text(
                                  'Phone: ${activeDealer.phone}',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
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
                      )
                    : Row(
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
                                  activeDealer != null
                                      ? '${activeDealer.businessName} • Wholesale Portal'
                                      : (widget.state.isBangla
                                          ? 'অনুমোদিত ডিলার প্রাইস শিট ও বাল্ক অর্ডার পোর্টাল'
                                          : 'Approved B2B Dealer Price Sheet & Consignment Portal'),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        activeDealer?.tier ?? 'Platinum Tier (30% off)',
                                        style: const TextStyle(color: AppTheme.goldLight, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        activeDealer?.businessType ?? 'Wholesaler',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                    if (activeDealer != null) ...[
                                      Text(
                                        'Proprietor: ${activeDealer.contactPerson} • Phone: ${activeDealer.phone}',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12.5),
                                      ),
                                      Text(
                                        'License: ${activeDealer.tradeLicense}',
                                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                                      ),
                                    ],
                                  ],
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  child: isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    p.imageUrl,
                                    width: 72,
                                    height: 75,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 72,
                                      height: 75,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.spa_outlined),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            p.brand.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryRose,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '• ${p.originCountry}',
                                            style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        p.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'MRP: ৳${p.retailPrice.toStringAsFixed(0)} • Batch: ${p.batchNo}',
                                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Text(
                                    '${marginPercent.toStringAsFixed(0)}% Margin',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                                Text(
                                  '৳${p.wholesalePrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'MOQ: ${p.moq} units (Total: ৳${(p.wholesalePrice * p.moq).toStringAsFixed(0)})',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
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
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                icon: const Icon(Icons.add_shopping_cart, size: 15),
                                label: Text('Add MOQ (${p.moq} Units)'),
                              ),
                            ),
                          ],
                        )
                      : Row(
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
