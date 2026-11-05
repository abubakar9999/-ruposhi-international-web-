import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../models/product_model.dart';
import 'admin_models.dart';
import 'bulk_product_dialog.dart';
import 'image_upload_service.dart';

enum AdminSection {
  overview,
  products,
  orders,
  b2b,
  coupons,
  customers,
  compliance,
}

class AdminView extends StatefulWidget {
  final StoreState state;
  const AdminView({super.key, required this.state});

  @override
  State<AdminView> createState() => _AdminViewState();
}

class _AdminViewState extends State<AdminView> {
  AdminSection _currentSection = AdminSection.overview;
  final TextEditingController _usernameCtrl = TextEditingController(text: 'admin');
  final TextEditingController _passwordCtrl = TextEditingController(text: 'admin123');
  final TextEditingController _productSearchCtrl = TextEditingController();
  final TextEditingController _orderSearchCtrl = TextEditingController();
  final TextEditingController _customerSearchCtrl = TextEditingController();

  String _productCategoryFilter = 'All';
  bool _onlyLowStock = false;
  String _orderStatusFilter = 'All';
  String _b2bFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StoreCubit>().loadAdminData();
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _productSearchCtrl.dispose();
    _orderSearchCtrl.dispose();
    _customerSearchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.isAdminLoggedIn) {
      return _buildAdminLoginGate(context);
    }
    return _buildAdminConsole(context);
  }

  // ==========================================
  // 1. ADMIN AUTHENTICATION / LOGIN GATE
  // ==========================================
  Widget _buildAdminLoginGate(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFF1E020A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 24 : 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Icon & Badge
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.logoGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.rose600.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RUPOSHI INTERNATIONAL',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.2,
                      color: AppTheme.rose950,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Executive Business Management Console',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gold600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (widget.state.adminLoginError != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.state.adminLoginError!,
                              style: TextStyle(fontSize: 12, color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Username
                  TextField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Admin Username / Email',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Admin Password',
                      prefixIcon: Icon(Icons.lock_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Login Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        cubit.loginAdmin(_usernameCtrl.text, _passwordCtrl.text);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.rose900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_open, size: 18),
                          SizedBox(width: 8),
                          Text('Enter Executive Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Return to Storefront
                  TextButton.icon(
                    onPressed: () => cubit.navigateTo(AppView.home),
                    icon: const Icon(Icons.storefront, size: 16),
                    label: const Text('Back to Public Storefront', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. MAIN EXECUTIVE CONSOLE
  // ==========================================
  Widget _buildAdminConsole(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideDesktop = screenWidth >= 1050;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.rose950,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            child: Row(
              children: [
                // Brand Title
                InkWell(
                  onTap: () => setState(() => _currentSection = AdminSection.overview),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.logoGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.state.isBangla ? 'রূপসী অ্যাডমিন' : 'RUPOSHI ADMIN',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 1.1),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: AppTheme.gold500.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.gold400),
                                ),
                                child: const Text('EXECUTIVE', style: TextStyle(color: AppTheme.gold300, fontSize: 9.5, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const Text('Central Business Hub • Dhaka', style: TextStyle(color: AppTheme.rose200, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Live Warehouse Temperature Status Pill
                if (screenWidth >= 1200) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit, color: Colors.lightBlueAccent, size: 14),
                        SizedBox(width: 6),
                        Text('Cold Hub: 19.4°C (Normal)', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Live Supabase Status Pill
                if (screenWidth >= 1350) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.shade400),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_done, color: Colors.lightGreenAccent, size: 14),
                        SizedBox(width: 6),
                        Text('Supabase Live Storage', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Sync Live Supabase Data Button
                IconButton(
                  tooltip: 'Sync Live Orders & Customers',
                  onPressed: widget.state.isLoadingAdminData ? null : () => cubit.loadAdminData(),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(8),
                  ),
                  icon: widget.state.isLoadingAdminData
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.sync_rounded, size: 18),
                ),

                const SizedBox(width: 10),

                // Return to Customer Storefront
                ElevatedButton.icon(
                  onPressed: () => cubit.navigateTo(AppView.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.rose800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.storefront, size: 16),
                  label: Text(
                    widget.state.isBangla ? 'পাবলিক স্টোর' : 'View Store',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(width: 8),

                // Logout Button
                IconButton(
                  tooltip: 'Admin Logout',
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.rose200, size: 20),
                  onPressed: cubit.logoutAdmin,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Desktop Luxury Sidebar
          if (isWideDesktop)
            Container(
              width: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF23030C),
                border: Border(right: BorderSide(color: Color(0xFF380716))),
              ),
              child: _buildSidebarItems(cubit),
            ),

          // Main Section Content
          Expanded(
            child: Column(
              children: [
                // Mobile Horizontal Navigation Bar
                if (!isWideDesktop)
                  Container(
                    color: const Color(0xFF23030C),
                    height: 52,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          _buildMobileNavItem(AdminSection.overview, Icons.dashboard_outlined, 'Overview'),
                          _buildMobileNavItem(AdminSection.products, Icons.inventory_2_outlined, 'Products (${widget.state.products.length})'),
                          _buildMobileNavItem(AdminSection.orders, Icons.local_shipping_outlined, 'Orders (${widget.state.orders.length})'),
                          _buildMobileNavItem(AdminSection.b2b, Icons.business_center_outlined, 'B2B Dealers'),
                          _buildMobileNavItem(AdminSection.coupons, Icons.discount_outlined, 'Coupons'),
                          _buildMobileNavItem(AdminSection.customers, Icons.people_outline, 'Customers'),
                          _buildMobileNavItem(AdminSection.compliance, Icons.ac_unit, 'Compliance'),
                        ],
                      ),
                    ),
                  ),

                // Section Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildSelectedSectionContent(context, cubit),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItems(StoreCubit cubit) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'BUSINESS MANAGEMENT',
            style: TextStyle(color: Color(0xFF9F707E), fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        _buildSidebarTile(
          section: AdminSection.overview,
          icon: Icons.dashboard_outlined,
          title: 'Executive Overview',
          subtitle: 'KPIs & Revenue Analytics',
        ),
        _buildSidebarTile(
          section: AdminSection.products,
          icon: Icons.inventory_2_outlined,
          title: 'Products & Inventory',
          subtitle: '${widget.state.products.length} Active Cosmetics SKUs',
          badgeText: widget.state.products.where((p) => p.stock <= 20).length.toString(),
          badgeColor: Colors.amber.shade700,
        ),
        _buildSidebarTile(
          section: AdminSection.orders,
          icon: Icons.local_shipping_outlined,
          title: 'Orders & Shipping',
          subtitle: '${widget.state.orders.length} Total Customer Orders',
          badgeText: widget.state.orders.where((o) => o.status == 'Pending').length.toString(),
          badgeColor: AppTheme.rose600,
        ),
        _buildSidebarTile(
          section: AdminSection.b2b,
          icon: Icons.business_center_outlined,
          title: 'B2B Wholesale Dealers',
          subtitle: '${widget.state.b2bPartners.length} Salons & Pharmacies',
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            'MARKETING & CRM',
            style: TextStyle(color: Color(0xFF9F707E), fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
        _buildSidebarTile(
          section: AdminSection.coupons,
          icon: Icons.discount_outlined,
          title: 'Coupons & Campaigns',
          subtitle: '${widget.state.coupons.length} Active Vouchers',
        ),
        _buildSidebarTile(
          section: AdminSection.customers,
          icon: Icons.people_outline,
          title: 'Customer Directory',
          subtitle: 'CRM & WhatsApp Alerts',
        ),
        _buildSidebarTile(
          section: AdminSection.compliance,
          icon: Icons.ac_unit,
          title: 'Cold-Chain & BSTI',
          subtitle: '20°C Audit & Cargo AWB',
        ),
      ],
    );
  }

  Widget _buildSidebarTile({
    required AdminSection section,
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
  }) {
    final isSelected = _currentSection == section;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: isSelected ? AppTheme.rose900 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => setState(() => _currentSection = section),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? AppTheme.gold300 : AppTheme.rose200, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.85),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isSelected ? AppTheme.rose200 : Colors.white.withValues(alpha: 0.45),
                          fontSize: 10.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (badgeText != null && badgeText != '0')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? AppTheme.rose600,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileNavItem(AdminSection section, IconData icon, String label) {
    final isSelected = _currentSection == section;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: () => setState(() => _currentSection = section),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.rose800 : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.gold400 : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? AppTheme.gold300 : Colors.white70, size: 14),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedSectionContent(BuildContext context, StoreCubit cubit) {
    switch (_currentSection) {
      case AdminSection.overview:
        return _buildOverviewSection(context, cubit);
      case AdminSection.products:
        return _buildProductsSection(context, cubit);
      case AdminSection.orders:
        return _buildOrdersSection(context, cubit);
      case AdminSection.b2b:
        return _buildB2BSection(context, cubit);
      case AdminSection.coupons:
        return _buildCouponsSection(context, cubit);
      case AdminSection.customers:
        return _buildCustomersSection(context, cubit);
      case AdminSection.compliance:
        return _buildComplianceSection(context, cubit);
    }
  }

  // ==========================================
  // SECTION 1: OVERVIEW & KPIS
  // ==========================================
  Widget _buildOverviewSection(BuildContext context, StoreCubit cubit) {
    final products = widget.state.products;
    final orders = widget.state.orders;
    final b2bCount = widget.state.b2bPartners.length;

    final double totalRevenue = orders.fold(0.0, (sum, o) => sum + o.grandTotal);
    final int pendingOrdersCount = orders.where((o) => o.status == 'Pending').length;
    final int lowStockCount = products.where((p) => p.stock <= 20).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4C0519), Color(0xFF881337)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.rose900.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome to Ruposhi International Executive Suite',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Direct cosmetics importer from Seoul, Paris, London & NY. All 64 Bangladesh delivery corridors active.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => setState(() => _currentSection = AdminSection.products),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.gold400,
                  foregroundColor: AppTheme.rose950,
                  elevation: 2,
                ),
                icon: const Icon(Icons.add_box, size: 18),
                label: const Text('Add New SKU', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 4 KPI Cards
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final double cardWidth = w < 600 ? w : (w < 1000 ? (w - 16) / 2 : (w - 3 * 16) / 4);

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildKPICard(
                  title: 'Total Sales Revenue',
                  value: '৳${totalRevenue.toStringAsFixed(0)}',
                  trend: '+24.5% vs last month',
                  icon: Icons.payments_outlined,
                  accentColor: const Color(0xFF10B981),
                  width: cardWidth,
                ),
                _buildKPICard(
                  title: 'Customer Orders',
                  value: '${orders.length}',
                  trend: '$pendingOrdersCount pending dispatch',
                  icon: Icons.shopping_cart_outlined,
                  accentColor: AppTheme.rose600,
                  width: cardWidth,
                ),
                _buildKPICard(
                  title: 'Active Beauty SKUs',
                  value: '${products.length}',
                  trend: '$lowStockCount low stock alerts',
                  icon: Icons.inventory_2_outlined,
                  accentColor: AppTheme.gold600,
                  width: cardWidth,
                ),
                _buildKPICard(
                  title: 'Verified B2B Salons',
                  value: '$b2bCount Partners',
                  trend: 'All 64 districts active',
                  icon: Icons.business_center_outlined,
                  accentColor: Colors.indigo,
                  width: cardWidth,
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        // Charts & Import Distribution
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country of Origin Breakdown
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Direct Import Inventory by Country of Origin',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('BSTI Verified', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildCountryShareBar('South Korea (K-Beauty)', 'COSRX, Beauty of Joseon, Anua, Laneige', 0.42, Colors.purple),
                    const SizedBox(height: 12),
                    _buildCountryShareBar('United States (USA)', 'CeraVe, Paula\'s Choice, Neutrogena', 0.28, Colors.blue),
                    const SizedBox(height: 12),
                    _buildCountryShareBar('France (French Pharmacy)', 'La Roche-Posay, Bioderma, Avene', 0.18, Colors.indigo),
                    const SizedBox(height: 12),
                    _buildCountryShareBar('United Kingdom (UK) & Canada', 'The Ordinary, MAC Cosmetics, Inkey List', 0.12, Colors.teal),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Low Stock Warning Box
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Low Stock Warnings',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$lowStockCount Alert(s)',
                            style: TextStyle(color: Colors.amber.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (products.where((p) => p.stock <= 20).isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text('All products healthy in central warehouse (>20 units).', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ),
                      )
                    else
                      ...products.where((p) => p.stock <= 20).take(4).map((p) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    p.imageUrl,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(width: 36, height: 36, color: Colors.grey.shade200),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      Text('Stock: ${p.stock} units left', style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => cubit.adjustProductStock(p.id, 25),
                                  child: const Text('+25 Restock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          )),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Recent Orders Feed
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Live Customer Orders Feed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(
                    onPressed: () => setState(() => _currentSection = AdminSection.orders),
                    child: const Text('View All Orders →'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...orders.take(5).map((order) => _buildRecentOrderRow(order, cubit)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color accentColor,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          ),
          const SizedBox(height: 6),
          Text(trend, style: TextStyle(fontSize: 11, color: accentColor, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildCountryShareBar(String country, String brands, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(country, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${(percentage * 100).toInt()}% Share', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        Text(brands, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentOrderRow(AdminOrder order, StoreCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.rose50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.receipt_long, color: AppTheme.rose600, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text('• ${order.customerName}', style: const TextStyle(fontSize: 12.5, color: Colors.grey)),
                  ],
                ),
                Text('${order.city} • ${order.paymentMethod}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text('৳${order.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 12),
          _buildOrderStatusPill(order.status),
        ],
      ),
    );
  }

  Widget _buildOrderStatusPill(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'Pending':
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        break;
      case 'Confirmed':
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      case 'Processing':
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade900;
        break;
      case 'Shipped':
        bg = Colors.indigo.shade100;
        fg = Colors.indigo.shade900;
        break;
      case 'Delivered':
        bg = Colors.green.shade100;
        fg = Colors.green.shade900;
        break;
      case 'Cancelled':
      default:
        bg = Colors.red.shade100;
        fg = Colors.red.shade900;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ==========================================
  // SECTION 2: PRODUCTS & INVENTORY CRUD
  // ==========================================
  Widget _buildProductsSection(BuildContext context, StoreCubit cubit) {
    var list = widget.state.products.where((p) {
      final q = _productSearchCtrl.text.trim().toLowerCase();
      final matchQ = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q);
      final matchCat = _productCategoryFilter == 'All' || p.category.toLowerCase() == _productCategoryFilter.toLowerCase();
      final matchStock = !_onlyLowStock || p.stock <= 20;
      return matchQ && matchCat && matchStock;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar with Bulk Import Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Cosmetics Catalog & Warehouse Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('Manage retail prices, wholesale minimum orders, batch codes & stock counts.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BulkProductDialog(cubit: cubit),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.rose900,
                    side: const BorderSide(color: AppTheme.rose900),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  icon: const Icon(Icons.playlist_add, size: 18),
                  label: const Text('Bulk Item Entries', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openAddEditProductDialog(context, cubit, null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.rose800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('+ Add New SKU', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Filter Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search input
              SizedBox(
                width: 240,
                height: 38,
                child: TextField(
                  controller: _productSearchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search SKU or Brand...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Category dropdown
              DropdownButton<String>(
                value: _productCategoryFilter,
                underline: const SizedBox(),
                items: ['All', 'Skincare', 'Makeup', 'Sunscreen', 'Haircare']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _productCategoryFilter = val);
                },
              ),

              // Low stock toggle
              FilterChip(
                label: const Text('Low Stock Only (<= 20)', style: TextStyle(fontSize: 12)),
                selected: _onlyLowStock,
                selectedColor: Colors.amber.shade100,
                checkmarkColor: Colors.amber.shade900,
                onSelected: (val) => setState(() => _onlyLowStock = val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Product Cards List
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: const Text('No products match your search/filter criteria.', style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = list[index];
              return _buildProductInventoryCard(context, cubit, product);
            },
          ),
      ],
    );
  }

  Widget _buildProductInventoryCard(BuildContext context, StoreCubit cubit, Product product) {
    final bool isLowStock = product.stock <= 20;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLowStock ? Colors.amber.shade300 : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              product.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title & Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('${product.countryFlag} ${product.originCountry}', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text('• ${product.brand}', style: const TextStyle(fontSize: 11, color: AppTheme.rose600, fontWeight: FontWeight.bold)),
                    if (product.isBestSeller) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(color: AppTheme.rose50, borderRadius: BorderRadius.circular(6)),
                        child: const Text('Best Seller', style: TextStyle(color: AppTheme.rose600, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  children: [
                    Text('Retail: ৳${product.retailPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    Text('Wholesale: ৳${product.wholesalePrice.toStringAsFixed(0)} (MOQ: ${product.moq})', style: const TextStyle(fontSize: 12, color: AppTheme.gold600, fontWeight: FontWeight.w600)),
                    Text('Batch: ${product.batchNo}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // Stock count & adjustments
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isLowStock ? Colors.red.shade200 : Colors.green.shade200),
                ),
                child: Text(
                  '${product.stock} in Stock',
                  style: TextStyle(
                    color: isLowStock ? Colors.red.shade800 : Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: () => cubit.adjustProductStock(product.id, -5),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(28, 26),
                    ),
                    child: const Text('-5', style: TextStyle(fontSize: 10)),
                  ),
                  const SizedBox(width: 4),
                  OutlinedButton(
                    onPressed: () => cubit.adjustProductStock(product.id, 10),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      minimumSize: const Size(28, 26),
                    ),
                    child: const Text('+10', style: TextStyle(fontSize: 10)),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 14),

          // Action Buttons: Edit & Delete
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit SKU',
                icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueGrey),
                onPressed: () => _openAddEditProductDialog(context, cubit, product),
              ),
              IconButton(
                tooltip: 'Delete SKU',
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                onPressed: () => _confirmDeleteProduct(context, cubit, product),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, StoreCubit cubit, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Product SKU?'),
        content: Text('Are you sure you want to remove "${product.name}" from Ruposhi International catalog? This will delete it from both local state and Supabase.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              cubit.deleteProduct(product.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Product "${product.name}" removed.')),
              );
            },
            child: const Text('Delete SKU', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openAddEditProductDialog(BuildContext context, StoreCubit cubit, Product? existing) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final nameBnCtrl = TextEditingController(text: existing?.nameBn ?? '');
    final brandCtrl = TextEditingController(text: existing?.brand ?? 'COSRX');
    final categoryCtrl = TextEditingController(text: existing?.category ?? 'Skincare');
    final originCtrl = TextEditingController(text: existing?.originCountry ?? 'South Korea');
    final flagCtrl = TextEditingController(text: existing?.countryFlag ?? '🇰🇷');
    final retailCtrl = TextEditingController(text: existing != null ? existing.retailPrice.toStringAsFixed(0) : '1850');
    final oldPriceCtrl = TextEditingController(text: existing?.oldPrice != null ? existing!.oldPrice!.toStringAsFixed(0) : '2200');
    final wholesaleCtrl = TextEditingController(text: existing != null ? existing.wholesalePrice.toStringAsFixed(0) : '1450');
    final moqCtrl = TextEditingController(text: existing != null ? existing.moq.toString() : '10');
    final stockCtrl = TextEditingController(text: existing != null ? existing.stock.toString() : '50');
    final batchCtrl = TextEditingController(text: existing?.batchNo ?? 'KOR-2026-BATCH-01');
    final expiryCtrl = TextEditingController(text: existing?.expiryDate ?? '2028-12');
    final skinTypeCtrl = TextEditingController(text: existing?.skinType ?? 'All Skin Types');
    final imageCtrl = TextEditingController(
      text: existing?.imageUrl ?? 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=600&q=80',
    );
    final descCtrl = TextEditingController(text: existing?.description ?? 'Formulated with authentic active ingredients.');
    final ingredientsCtrl = TextEditingController(text: existing?.ingredients ?? 'Snail Secretion Filtrate, Betaine, Butylene Glycol');

    bool isBestSeller = existing?.isBestSeller ?? false;
    bool isNewArrival = existing?.isNewArrival ?? false;
    bool isUploadingImage = false;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(isEdit ? 'Edit Product SKU' : 'Add New Imported Cosmetics SKU'),
            content: SizedBox(
              width: 600,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Product Name (English)')),
                    const SizedBox(height: 10),
                    TextField(controller: nameBnCtrl, decoration: const InputDecoration(labelText: 'Product Name (Bengali)')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: brandCtrl, decoration: const InputDecoration(labelText: 'Brand (e.g. COSRX, CeraVe)'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: categoryCtrl, decoration: const InputDecoration(labelText: 'Category (e.g. Skincare, Makeup)'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: originCtrl, decoration: const InputDecoration(labelText: 'Origin Country'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: flagCtrl, decoration: const InputDecoration(labelText: 'Flag Emoji (e.g. 🇰🇷, 🇺🇸, 🇫🇷)'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: retailCtrl, decoration: const InputDecoration(labelText: 'Retail Price (BDT ৳)'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: oldPriceCtrl, decoration: const InputDecoration(labelText: 'Old Price (Optional ৳)'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: wholesaleCtrl, decoration: const InputDecoration(labelText: 'Wholesale Price (৳)'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: moqCtrl, decoration: const InputDecoration(labelText: 'Wholesale MOQ'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: stockCtrl, decoration: const InputDecoration(labelText: 'Stock Units'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Batch Number'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: expiryCtrl, decoration: const InputDecoration(labelText: 'Expiry Date'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: skinTypeCtrl, decoration: const InputDecoration(labelText: 'Skin Type Recommendation')),
                    const SizedBox(height: 12),

                    // ==========================================
                    // SUPABASE STORAGE IMAGE UPLOAD & COMPRESSION
                    // ==========================================
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: imageCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Product Image Public URL',
                              hintText: 'https://...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0284C7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: isUploadingImage
                                    ? null
                                    : () async {
                                        setDialogState(() => isUploadingImage = true);
                                        final res = await ImageUploadService.pickCompressAndUpload();
                                        setDialogState(() => isUploadingImage = false);

                                        if (res != null) {
                                          if (res.success) {
                                            imageCtrl.text = res.publicUrl;
                                            setDialogState(() {});
                                            if (ctx.mounted) {
                                              ScaffoldMessenger.of(ctx).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Uploaded & Compressed! ${res.originalSizeFormatted} -> ${res.compressedSizeFormatted} (${res.savingsPercent}% saved).',
                                                  ),
                                                  backgroundColor: Colors.green.shade800,
                                                ),
                                              );
                                            }
                                          } else {
                                            if (res.publicUrl.isNotEmpty) {
                                              imageCtrl.text = res.publicUrl;
                                              setDialogState(() {});
                                            }
                                            if (ctx.mounted) {
                                              ScaffoldMessenger.of(ctx).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Notice: ${res.errorMessage ?? "Storage error"}. URL generated, but ensure "product-images" bucket exists in Supabase.',
                                                  ),
                                                  backgroundColor: Colors.orange.shade800,
                                                  duration: const Duration(seconds: 5),
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                icon: isUploadingImage
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.cloud_upload_outlined, size: 16),
                                label: Text(
                                  isUploadingImage ? 'Compressing (<=100KB)...' : 'Upload Image (Auto <= 100KB Compress)',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text('Auto-compresses to strictly <= 100 KB before Supabase Storage upload.', style: TextStyle(fontSize: 10.5, color: Colors.blueGrey)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Description')),
                    const SizedBox(height: 10),
                    TextField(controller: ingredientsCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Key Active Ingredients')),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Best Seller', style: TextStyle(fontSize: 12)),
                            value: isBestSeller,
                            onChanged: (val) => setDialogState(() => isBestSeller = val),
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('New Arrival', style: TextStyle(fontSize: 12)),
                            value: isNewArrival,
                            onChanged: (val) => setDialogState(() => isNewArrival = val),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose800),
                onPressed: () {
                  final newProduct = Product(
                    id: existing?.id ?? 'p_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'New Luxury Cosmetic',
                    nameBn: nameBnCtrl.text.trim(),
                    brand: brandCtrl.text.trim(),
                    category: categoryCtrl.text.trim(),
                    originCountry: originCtrl.text.trim(),
                    countryFlag: flagCtrl.text.trim(),
                    retailPrice: double.tryParse(retailCtrl.text) ?? 1500,
                    oldPrice: double.tryParse(oldPriceCtrl.text),
                    wholesalePrice: double.tryParse(wholesaleCtrl.text) ?? 1200,
                    moq: int.tryParse(moqCtrl.text) ?? 10,
                    stock: int.tryParse(stockCtrl.text) ?? 50,
                    batchNo: batchCtrl.text.trim(),
                    expiryDate: expiryCtrl.text.trim(),
                    skinType: skinTypeCtrl.text.trim(),
                    imageUrl: imageCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    ingredients: ingredientsCtrl.text.trim(),
                    usageInstructions: 'Apply daily onto cleansed skin.',
                    isBestSeller: isBestSeller,
                    isNewArrival: isNewArrival,
                  );

                  if (isEdit) {
                    cubit.updateProduct(newProduct);
                  } else {
                    cubit.addProduct(newProduct);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? 'Product updated.' : 'New product created!')),
                  );
                },
                child: Text(isEdit ? 'Save Changes' : 'Create Product', style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // SECTION 3: ORDERS & SHIPPING FULFILLMENT
  // ==========================================
  Widget _buildOrdersSection(BuildContext context, StoreCubit cubit) {
    var orders = widget.state.orders.where((o) {
      final q = _orderSearchCtrl.text.trim().toLowerCase();
      final matchQ = q.isEmpty ||
          o.orderId.toLowerCase().contains(q) ||
          o.customerName.toLowerCase().contains(q) ||
          o.customerPhone.toLowerCase().contains(q);
      final matchStatus = _orderStatusFilter == 'All' || o.status.toLowerCase() == _orderStatusFilter.toLowerCase();
      return matchQ && matchStatus;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Orders & Express Fulfillment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('Real-time order statuses, courier dispatch assignment & invoice receipts.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Filter Bar
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                height: 38,
                child: TextField(
                  controller: _orderSearchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search Order ID or Phone...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              DropdownButton<String>(
                value: _orderStatusFilter,
                underline: const SizedBox(),
                items: ['All', 'Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _orderStatusFilter = val);
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        if (orders.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: const Text('No orders match your filter criteria.', style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildFullOrderCard(context, cubit, order);
            },
          ),
      ],
    );
  }

  Widget _buildFullOrderCard(BuildContext context, StoreCubit cubit, AdminOrder order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppTheme.rose50, borderRadius: BorderRadius.circular(8)),
                child: Text(order.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.rose900)),
              ),
              const SizedBox(width: 10),
              Text(
                'Placed ${order.createdAt.hour}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Spacer(),
              _buildOrderStatusPill(order.status),
            ],
          ),

          const SizedBox(height: 12),

          // Dedicated Verified Customer Details Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF8F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF1E4E8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.rose100,
                  child: Text(
                    order.customerName.isNotEmpty ? order.customerName[0].toUpperCase() : 'C',
                    style: const TextStyle(color: AppTheme.rose900, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              order.customerName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.shade200)),
                            child: const Text('Verified Order', style: TextStyle(color: Colors.green, fontSize: 9.5, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          SelectableText(order.customerPhone, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: order.customerPhone));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Phone number ${order.customerPhone} copied!')),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.copy, size: 13, color: Colors.blueGrey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: SelectableText(
                              '${order.customerAddress}, ${order.city}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              final fullAddress = '${order.customerName}\n${order.customerPhone}\n${order.customerAddress}, ${order.city}';
                              Clipboard.setData(ClipboardData(text: fullAddress));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Full delivery address copied for courier!')),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                              child: const Text('Copy Address', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('৳${order.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.rose900)),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: order.paymentMethod.toUpperCase().contains('BKASH') ? Colors.pink.shade50 : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.paymentMethod,
                        style: TextStyle(fontSize: 11, color: order.paymentMethod.toUpperCase().contains('BKASH') ? Colors.pink.shade700 : Colors.green.shade800, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Items summary
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...order.items.map((it) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('${it['quantity']}x', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(it['name']?.toString() ?? 'Cosmetic Item', style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Text('৳${((it['price'] as num?)?.toDouble() ?? 0) * ((it['quantity'] as num?)?.toInt() ?? 1)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }),
                const Divider(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal: ৳${order.subtotal.toStringAsFixed(0)} | Delivery: ৳${order.deliveryFee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, color: Colors.blueGrey)),
                    Text('Total: ৳${order.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.rose900)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tracking & Courier details (if available)
          if (order.courier != null || order.trackingCode != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Courier: ${order.courier ?? 'Steadfast'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Colors.blue)),
                  const SizedBox(width: 12),
                  Text('Tracking: ${order.trackingCode ?? 'N/A'}', style: const TextStyle(fontSize: 11.5, color: Colors.blueGrey)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Quick Status Selector Chips Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'].map((statusOption) {
              final isCurrent = order.status.toLowerCase() == statusOption.toLowerCase();
              return InkWell(
                onTap: () => cubit.updateOrderStatus(order.orderId, statusOption),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? AppTheme.rose900 : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isCurrent ? AppTheme.rose900 : Colors.grey.shade300),
                  ),
                  child: Text(
                    statusOption,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          // Action Toolbar: Customer Details Modal, Courier assign, Print receipt, WhatsApp alert
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // View Full Customer Profile & History Modal
              OutlinedButton.icon(
                onPressed: () {
                  final customer = widget.state.customers.firstWhere(
                    (c) => c.phone.trim() == order.customerPhone.trim(),
                    orElse: () => CustomerRecord(
                      phone: order.customerPhone,
                      name: order.customerName,
                      district: order.city,
                      totalOrders: 1,
                      totalSpent: order.grandTotal,
                      lastOrderDate: order.createdAt.toString().split(' ').first,
                    ),
                  );
                  _openCustomerDetailsDialog(context, customer);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.rose900,
                  side: const BorderSide(color: AppTheme.rose900),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.person_outline, size: 15),
                label: const Text('Customer Profile', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              ),

              // Assign Courier
              OutlinedButton.icon(
                onPressed: () => _openCourierDialog(context, cubit, order),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.local_shipping_outlined, size: 15),
                label: const Text('Dispatch / Tracking', style: TextStyle(fontSize: 11.5)),
              ),

              // Print Invoice Receipt
              OutlinedButton.icon(
                onPressed: () => _openInvoiceDialog(context, order),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.print_outlined, size: 15),
                label: const Text('Print Invoice', style: TextStyle(fontSize: 11.5)),
              ),

              // WhatsApp Customer Notify
              ElevatedButton.icon(
                onPressed: () => _sendWhatsAppAlert(order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                icon: const Icon(Icons.chat, size: 15),
                label: const Text('WhatsApp Customer', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openCustomerDetailsDialog(BuildContext context, CustomerRecord customer) {
    final customerOrders = widget.state.orders
        .where((o) => o.customerPhone.trim() == customer.phone.trim())
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 580,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Avatar and Badges
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppTheme.rose900,
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  customer.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (customer.isVip) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFF59E0B)),
                                  ),
                                  child: const Text('★ VIP CLIENT', style: TextStyle(color: Color(0xFFB45309), fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text('${customer.phone} • ${customer.district}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 12),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Orders', style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                            const SizedBox(height: 4),
                            Text('${customer.totalOrders}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.rose900)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Lifetime Spend', style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                            const SizedBox(height: 4),
                            Text('৳${customer.totalSpent.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Last Active', style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                            const SizedBox(height: 4),
                            Text(customer.lastOrderDate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick Contact Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final clean = customer.phone.replaceAll(RegExp(r'[^0-9]'), '');
                          final msg = Uri.encodeComponent('Assalamu Alaikum ${customer.name}! Greetings from Ruposhi International Customer Concierge.');
                          final url = Uri.parse('https://wa.me/$clean?text=$msg');
                          if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.chat, size: 16),
                        label: const Text('Open WhatsApp Chat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: customer.phone));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Copied ${customer.phone} to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 15),
                      label: const Text('Copy Phone', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),

                const SizedBox(height: 22),
                Text('Purchase History (${customerOrders.length} orders)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),

                if (customerOrders.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('No orders found for this phone number in current session.', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  )
                else
                  ...customerOrders.map((o) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppTheme.rose50, borderRadius: BorderRadius.circular(6)),
                              child: Text(o.orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.rose900)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text('${o.items.length} item(s) • ${o.paymentMethod}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                            ),
                            _buildOrderStatusPill(o.status),
                            const SizedBox(width: 10),
                            Text('৳${o.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.rose900)),
                          ],
                        ),
                      )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openCourierDialog(BuildContext context, StoreCubit cubit, AdminOrder order) {
    String courier = order.courier ?? 'Steadfast Courier';
    final trackingCtrl = TextEditingController(text: order.trackingCode ?? 'ST-${DateTime.now().millisecondsSinceEpoch % 1000000}');

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Courier Dispatch: ${order.orderId}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select delivery partner for consignment fulfillment:'),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  value: courier,
                  isExpanded: true,
                  items: ['Steadfast Courier', 'Pathao Express', 'RedX Logistics', 'Paperfly']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => courier = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: trackingCtrl,
                  decoration: const InputDecoration(labelText: 'Consignment Tracking Code'),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose800),
                onPressed: () {
                  cubit.assignCourier(order.orderId, courier, trackingCtrl.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order ${order.orderId} dispatched with $courier!')),
                  );
                },
                child: const Text('Confirm Dispatch', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openInvoiceDialog(BuildContext context, AdminOrder order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RUPOSHI INTERNATIONAL', style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.rose950)),
                        Text('100% Authentic Imported Cosmetics', style: TextStyle(fontSize: 10, color: AppTheme.gold600, fontWeight: FontWeight.bold)),
                        Text('Central Fulfillment Hub • Dhaka, Bangladesh', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
                    child: const Text('OFFICIAL\nINVOICE', textAlign: TextAlign.center, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Order & Customer Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Invoice ID: ${order.orderId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text('Date: ${order.createdAt.toIso8601String().substring(0, 10)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Billed To: ${order.customerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(order.customerPhone, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Delivery Address: ${order.customerAddress}, ${order.city}', style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),

              const SizedBox(height: 16),

              // Items Table
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade100,
                child: const Row(
                  children: [
                    Expanded(flex: 3, child: Text('Item Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                    Expanded(child: Text('Price', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                  ],
                ),
              ),
              ...order.items.map((it) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Text(it['name']?.toString() ?? '', style: const TextStyle(fontSize: 11))),
                        Expanded(child: Text('${it['quantity']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11))),
                        Expanded(child: Text('৳${it['price']}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 11))),
                      ],
                    ),
                  )),

              const Divider(height: 20),

              // Totals
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Subtotal: ৳${order.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                    Text('Delivery Fee: ৳${order.deliveryFee.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                    Text('Grand Total Payable: ৳${order.grandTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.rose900)),
                    Text('Payment: ${order.paymentMethod}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: AppTheme.gold600),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('200% Authenticity Guarantee: Batch-inspected with Bangladesh Customs & BSTI compliance seals.', style: TextStyle(fontSize: 9.5, color: Colors.brown)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose900),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice sent to thermal printer queue.')));
            },
            icon: const Icon(Icons.print, size: 16, color: Colors.white),
            label: const Text('Print Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _sendWhatsAppAlert(AdminOrder order) async {
    final cleanPhone = order.customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = Uri.encodeComponent(
      'Assalamu Alaikum ${order.customerName}! Your Ruposhi International order (${order.orderId}) for ৳${order.grandTotal.toStringAsFixed(0)} is currently: ${order.status}. Delivery Courier: ${order.courier ?? 'Steadfast'}. Tracking: ${order.trackingCode ?? 'N/A'}. Thank you for choosing 100% original imported cosmetics!',
    );
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ==========================================
  // SECTION 4: B2B WHOLESALE & DEALER NETWORK
  // ==========================================
  Widget _buildB2BSection(BuildContext context, StoreCubit cubit) {
    final allPartners = widget.state.b2bPartners;

    // Filter partners based on _b2bFilter
    final filteredPartners = allPartners.where((p) {
      if (_b2bFilter == 'All') return true;
      if (_b2bFilter == 'Pending Review') {
        return p.status.toLowerCase().contains('pending');
      }
      if (_b2bFilter == 'Wholesaler') {
        return p.businessType.toLowerCase() == 'wholesaler' || p.tier.toLowerCase().contains('wholesaler');
      }
      if (_b2bFilter == 'Salon & Spa') {
        return p.businessType.toLowerCase().contains('salon') ||
            p.businessName.toLowerCase().contains('salon') ||
            p.businessName.toLowerCase().contains('parlour') ||
            p.businessName.toLowerCase().contains('spa');
      }
      if (_b2bFilter == 'Pharmacy') {
        return p.businessType.toLowerCase().contains('pharmacy') ||
            p.businessName.toLowerCase().contains('pharmacy') ||
            p.businessName.toLowerCase().contains('derma');
      }
      if (_b2bFilter == 'Distributor') {
        return p.businessType.toLowerCase().contains('distributor') || p.tier.toLowerCase().contains('distributor');
      }
      return true;
    }).toList();

    final pendingCount = allPartners.where((p) => p.status.toLowerCase().contains('pending')).length;
    final approvedCount = allPartners.where((p) => p.status == 'Approved').length;
    final wholesalerCount = allPartners.where((p) => p.businessType == 'Wholesaler').length;
    final totalWholesaleSpend = allPartners.fold<double>(0.0, (sum, p) => sum + p.totalSpend);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('B2B Wholesale & Dealer Network', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('Manage approved dealers, wholesalers, trade license verifications, and pending online dealership applications.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _openAddB2BPartnerDialog(context, cubit),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold600,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.business_center, size: 18),
              label: const Text('+ Onboard Partner', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Dealer Login & Access Info Guide Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppTheme.gold400.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.verified_user, color: AppTheme.gold400, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'B2B Wholesale Dealer Authentication & Portal Access Guide',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                '• Dealers log in directly via the website top navigation under "B2B Wholesale" using their registered Mobile Phone Number or Trade License.\n'
                '• Approved dealers see exclusive wholesale rates with 15% to 35% margin discounts and bulk MOQ packaging with VAT 6.3 invoices.\n'
                '• Applications submitted via the website form appear below under "Pending Review" for 1-click executive approval.',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12, height: 1.45),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Top Metrics
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCustomerMetricCard('Approved Dealers', '$approvedCount', Icons.verified, const Color(0xFF10B981)),
            _buildCustomerMetricCard('Pending Review', '$pendingCount', Icons.pending_actions, Colors.deepOrange),
            _buildCustomerMetricCard('Wholesalers', '$wholesalerCount', Icons.storefront, const Color(0xFF0284C7)),
            _buildCustomerMetricCard('Wholesale Volume', '৳${totalWholesaleSpend.toStringAsFixed(0)}', Icons.payments, AppTheme.rose900),
          ],
        ),

        const SizedBox(height: 18),

        // Filter Chips Row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text('All Partners (${allPartners.length})', style: const TextStyle(fontSize: 12)),
              selected: _b2bFilter == 'All',
              onSelected: (_) => setState(() => _b2bFilter = 'All'),
            ),
            ChoiceChip(
              avatar: pendingCount > 0 ? const Icon(Icons.fiber_manual_record, color: Colors.deepOrange, size: 12) : null,
              label: Text('Pending Review ($pendingCount)', style: TextStyle(fontSize: 12, color: pendingCount > 0 ? Colors.deepOrange : null, fontWeight: pendingCount > 0 ? FontWeight.bold : FontWeight.normal)),
              selected: _b2bFilter == 'Pending Review',
              selectedColor: Colors.deepOrange.shade100,
              onSelected: (_) => setState(() => _b2bFilter = 'Pending Review'),
            ),
            ChoiceChip(
              label: const Text('Wholesalers', style: TextStyle(fontSize: 12)),
              selected: _b2bFilter == 'Wholesaler',
              onSelected: (_) => setState(() => _b2bFilter = 'Wholesaler'),
            ),
            ChoiceChip(
              label: const Text('Salons & Spas', style: TextStyle(fontSize: 12)),
              selected: _b2bFilter == 'Salon & Spa',
              onSelected: (_) => setState(() => _b2bFilter = 'Salon & Spa'),
            ),
            ChoiceChip(
              label: const Text('Pharmacies', style: TextStyle(fontSize: 12)),
              selected: _b2bFilter == 'Pharmacy',
              onSelected: (_) => setState(() => _b2bFilter = 'Pharmacy'),
            ),
            ChoiceChip(
              label: const Text('Distributors', style: TextStyle(fontSize: 12)),
              selected: _b2bFilter == 'Distributor',
              onSelected: (_) => setState(() => _b2bFilter = 'Distributor'),
            ),
          ],
        ),

        const SizedBox(height: 18),

        if (filteredPartners.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Center(
              child: Text('No B2B partners match the selected filter.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredPartners.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = filteredPartners[index];
              final isPending = p.status.toLowerCase().contains('pending');

              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isPending ? const Color(0xFFFFFBEB) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPending ? Colors.amber.shade400 : const Color(0xFFE2E8F0),
                    width: isPending ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPending ? Colors.amber.shade100 : AppTheme.gold100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPending ? Icons.pending_actions : Icons.storefront,
                        color: isPending ? Colors.amber.shade900 : AppTheme.gold600,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(p.businessName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: p.status == 'Approved' ? Colors.green.shade50 : Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: p.status == 'Approved' ? Colors.green.shade300 : Colors.amber.shade400),
                                ),
                                child: Text(
                                  p.status,
                                  style: TextStyle(
                                    color: p.status == 'Approved' ? Colors.green.shade900 : Colors.amber.shade900,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  p.businessType,
                                  style: const TextStyle(color: Colors.blueGrey, fontSize: 10.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Proprietor: ${p.contactPerson} • Login Mobile: ${p.phone} • Email: ${p.email.isNotEmpty ? p.email : "N/A"}',
                            style: const TextStyle(color: Colors.black87, fontSize: 12),
                          ),
                          Text(
                            'Trade License: ${p.tradeLicense} • Region: ${p.district}',
                            style: const TextStyle(color: Colors.blueGrey, fontSize: 11.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tier: ${p.tier} • Lifetime Spend: ৳${p.totalSpend.toStringAsFixed(0)} (${p.totalOrders} bulk orders)',
                            style: const TextStyle(color: AppTheme.rose800, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          if (isPending) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    cubit.approveB2BPartner(p.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Approved ${p.businessName} as official wholesale dealer!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  ),
                                  icon: const Icon(Icons.check_circle_outline, size: 14),
                                  label: const Text('Approve Dealership', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final clean = p.phone.replaceAll(RegExp(r'[^0-9]'), '');
                                    final msg = Uri.encodeComponent('Assalamu Alaikum ${p.contactPerson}! Regarding your B2B dealership application for ${p.businessName} on Ruposhi International.');
                                    final url = Uri.parse('https://wa.me/$clean?text=$msg');
                                    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  icon: const Icon(Icons.chat, size: 14, color: Color(0xFF25D366)),
                                  label: const Text('WhatsApp Applicant', style: TextStyle(fontSize: 11.5)),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Change Status',
                      child: const Icon(Icons.more_vert, color: Colors.grey),
                      onSelected: (val) => cubit.updateB2BPartnerStatus(p.id, val),
                      itemBuilder: (_) => ['Approved', 'Pending Review', 'Suspended']
                          .map((s) => PopupMenuItem(value: s, child: Text(s)))
                          .toList(),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _openAddB2BPartnerDialog(BuildContext context, StoreCubit cubit) {
    final nameCtrl = TextEditingController();
    final personCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+880 ');
    final emailCtrl = TextEditingController();
    final tradeCtrl = TextEditingController(text: 'TRAD/DNCC/');
    final districtCtrl = TextEditingController(text: 'Dhaka');
    String businessType = 'Wholesaler';
    String tier = 'Wholesaler (20% off)';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Onboard B2B Wholesale Partner'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Salon / Pharmacy Enterprise Name')),
                    const SizedBox(height: 10),
                    TextField(controller: personCtrl, decoration: const InputDecoration(labelText: 'Owner / Contact Person')),
                    const SizedBox(height: 10),
                    TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Mobile Phone')),
                    const SizedBox(height: 10),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email Address')),
                    const SizedBox(height: 10),
                    TextField(controller: tradeCtrl, decoration: const InputDecoration(labelText: 'Bangladesh Trade License Number')),
                    const SizedBox(height: 10),
                    TextField(controller: districtCtrl, decoration: const InputDecoration(labelText: 'District / Location')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: businessType,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Business Category'),
                      items: ['Wholesaler', 'Salon & Spa', 'Pharmacy', 'Distributor']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => businessType = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: tier,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Wholesale Discount Tier'),
                      items: [
                        'Wholesaler (20% off)',
                        'Gold Salon (25% off)',
                        'Platinum Partner (30% off)',
                        'Master Distributor (35% off)'
                      ].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => tier = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose800),
                onPressed: () {
                  final newPartner = B2BPartner(
                    id: 'b2b_${DateTime.now().millisecondsSinceEpoch}',
                    businessName: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : 'Elite Wholesale Enterprise',
                    contactPerson: personCtrl.text.trim(),
                    phone: phoneCtrl.text.trim(),
                    email: emailCtrl.text.trim(),
                    tradeLicense: tradeCtrl.text.trim(),
                    district: districtCtrl.text.trim(),
                    tier: tier,
                    status: 'Approved',
                    businessType: businessType,
                  );
                  cubit.addB2BPartner(newPartner);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Partner onboarded as Approved Dealer!')));
                },
                child: const Text('Approve & Onboard', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // SECTION 5: DISCOUNTS, COUPONS & TICKER
  // ==========================================
  Widget _buildCouponsSection(BuildContext context, StoreCubit cubit) {
    final coupons = widget.state.coupons;
    final enCtrl = TextEditingController(text: widget.state.announcementEn);
    final bnCtrl = TextEditingController(text: widget.state.announcementBn);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Promo Codes, Discounts & Flash Campaigns', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('Manage checkout coupons and update the top marquee banner.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _openCreateCouponDialog(context, cubit),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose800, foregroundColor: Colors.white),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create New Coupon'),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Coupons list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: coupons.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final c = coupons[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.rose50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.rose200),
                    ),
                    child: Text(
                      c.code,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2, color: AppTheme.rose900),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.discountPercent.toStringAsFixed(0)}% Off Cart (Min Spend: ৳${c.minSpend.toStringAsFixed(0)})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Redeemed ${c.usageCount} times • Valid through ${c.expiryDate}', style: const TextStyle(color: Colors.grey, fontSize: 11.5)),
                      ],
                    ),
                  ),
                  Switch(
                    value: c.isActive,
                    onChanged: (_) => cubit.toggleCoupon(c.code),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.grey),
                    onPressed: () => cubit.deleteCoupon(c.code),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 28),

        // Live Announcement Bar Editor
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Site-Wide Announcement Ticker Editor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              const Text('Updates the maroon bar at the top of the entire website in real-time.', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 14),
              TextField(
                controller: enCtrl,
                decoration: const InputDecoration(labelText: 'Ticker Message (English)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: bnCtrl,
                decoration: const InputDecoration(labelText: 'Ticker Message (Bengali)'),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () {
                  cubit.updateAnnouncement(enCtrl.text.trim(), bnCtrl.text.trim());
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Site announcement updated!')));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose900, foregroundColor: Colors.white),
                icon: const Icon(Icons.save, size: 16),
                label: const Text('Save & Publish Ticker'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openCreateCouponDialog(BuildContext context, StoreCubit cubit) {
    final codeCtrl = TextEditingController(text: 'EIDGLOW');
    final percentCtrl = TextEditingController(text: '15');
    final minSpendCtrl = TextEditingController(text: '3000');
    final expiryCtrl = TextEditingController(text: '2026-12-31');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create Discount Coupon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: 'Voucher Code (e.g. SUMMER10)')),
            const SizedBox(height: 10),
            TextField(controller: percentCtrl, decoration: const InputDecoration(labelText: 'Discount Percent (%)')),
            const SizedBox(height: 10),
            TextField(controller: minSpendCtrl, decoration: const InputDecoration(labelText: 'Minimum Order Value (৳)')),
            const SizedBox(height: 10),
            TextField(controller: expiryCtrl, decoration: const InputDecoration(labelText: 'Expiry Date (YYYY-MM-DD)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.rose800),
            onPressed: () {
              cubit.addCoupon(Coupon(
                code: codeCtrl.text.trim().toUpperCase(),
                discountPercent: double.tryParse(percentCtrl.text) ?? 10,
                minSpend: double.tryParse(minSpendCtrl.text) ?? 0,
                expiryDate: expiryCtrl.text.trim(),
              ));
              Navigator.pop(context);
            },
            child: const Text('Create Coupon', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 6: CUSTOMERS CRM DIRECTORY
  // ==========================================
  Widget _buildCustomersSection(BuildContext context, StoreCubit cubit) {
    final query = _customerSearchCtrl.text.trim().toLowerCase();
    final allCustomers = widget.state.customers;
    final filteredCustomers = allCustomers.where((c) {
      return query.isEmpty ||
          c.name.toLowerCase().contains(query) ||
          c.phone.contains(query) ||
          c.district.toLowerCase().contains(query);
    }).toList();

    final totalSpentSum = allCustomers.fold<double>(0.0, (sum, c) => sum + c.totalSpent);
    final vipCount = allCustomers.where((c) => c.isVip).length;
    final repeatBuyersCount = allCustomers.where((c) => c.totalOrders > 1).length;

    // Count how many customers are already registered as B2B Dealers or Wholesalers
    final dealerCustomersCount = allCustomers.where((c) {
      final cClean = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
      return widget.state.b2bPartners.any((p) {
        final pClean = p.phone.replaceAll(RegExp(r'[^0-9]'), '');
        return cClean.isNotEmpty &&
            (pClean == cClean ||
                (cClean.length >= 7 && pClean.endsWith(cClean)) ||
                (pClean.length >= 7 && cClean.endsWith(pClean)));
      });
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Customer Directory & Real-Time CRM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  Text('Direct phone contacts, delivery histories, and WhatsApp client relationship management. Identifies retail buyers vs B2B Dealers.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // CRM Top Metrics Row
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCustomerMetricCard('Total Customers', '${allCustomers.length}', Icons.people, const Color(0xFF0284C7)),
            _buildCustomerMetricCard('VIP Clients', '$vipCount', Icons.stars, const Color(0xFFD97706)),
            _buildCustomerMetricCard('Dealers / Wholesalers', '$dealerCustomersCount', Icons.storefront, const Color(0xFF059669)),
            _buildCustomerMetricCard('Repeat Buyers', '$repeatBuyersCount', Icons.repeat, const Color(0xFF4F46E5)),
            _buildCustomerMetricCard('Lifetime Value', '৳${totalSpentSum.toStringAsFixed(0)}', Icons.payments, AppTheme.rose900),
          ],
        ),

        const SizedBox(height: 18),

        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _customerSearchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search customer by Name, Phone Number, or District...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (_customerSearchCtrl.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _customerSearchCtrl.clear();
                    setState(() {});
                  },
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                child: Text('${filteredCustomers.length} shown', style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        if (filteredCustomers.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Center(
              child: Text('No customers matching your search query.', style: TextStyle(color: Colors.grey, fontSize: 13)),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredCustomers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final c = filteredCustomers[index];

              // Check if this customer has a matching B2B Partner / Wholesaler profile
              final cCleanPhone = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
              B2BPartner? b2bMatch;
              for (final p in widget.state.b2bPartners) {
                final pClean = p.phone.replaceAll(RegExp(r'[^0-9]'), '');
                if (cCleanPhone.isNotEmpty &&
                    (pClean == cCleanPhone ||
                        (cCleanPhone.length >= 7 && pClean.endsWith(cCleanPhone)) ||
                        (pClean.length >= 7 && cCleanPhone.endsWith(pClean)))) {
                  b2bMatch = p;
                  break;
                }
              }

              final dealerInfo = b2bMatch;
              final isApprovedDealer = dealerInfo != null && dealerInfo.status == 'Approved';
              final isPendingDealer = dealerInfo != null && dealerInfo.status.toLowerCase().contains('pending');

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isApprovedDealer
                      ? const Color(0xFFFEFDF8)
                      : (isPendingDealer ? const Color(0xFFFFFBEB) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isApprovedDealer
                        ? const Color(0xFFFDE68A)
                        : (isPendingDealer ? Colors.orange.shade300 : const Color(0xFFE2E8F0)),
                    width: (isApprovedDealer || isPendingDealer) ? 1.4 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: isApprovedDealer
                          ? const Color(0xFFFEF3C7)
                          : (c.isVip ? const Color(0xFFFEF3C7) : AppTheme.rose100),
                      child: Text(
                        c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                        style: TextStyle(
                          color: isApprovedDealer
                              ? const Color(0xFFB45309)
                              : (c.isVip ? const Color(0xFFB45309) : AppTheme.rose900),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                              if (isApprovedDealer) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFD97706)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified, size: 12, color: Color(0xFFB45309)),
                                      const SizedBox(width: 4),
                                      Text(
                                        '★ ${dealerInfo.businessType.toUpperCase()} (${dealerInfo.tier.split('(').first.trim()})',
                                        style: const TextStyle(
                                          color: Color(0xFFB45309),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (isPendingDealer) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.deepOrange.shade300),
                                  ),
                                  child: const Text(
                                    '⏳ PENDING DEALER',
                                    style: TextStyle(color: Colors.deepOrange, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ] else if (c.isVip) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFF59E0B))),
                                  child: const Text('★ VIP CLIENT', style: TextStyle(color: Color(0xFFB45309), fontSize: 9.5, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              const Icon(Icons.phone_outlined, size: 12, color: Colors.grey),
                              SelectableText(c.phone, style: const TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w600)),
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: c.phone));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${c.phone}!')));
                                },
                                child: const Icon(Icons.copy, size: 12, color: Colors.blueGrey),
                              ),
                              Text('• District: ${c.district}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          if (isApprovedDealer) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Enterprise: ${dealerInfo.businessName} • Trade License: ${dealerInfo.tradeLicense}',
                              style: const TextStyle(color: Color(0xFFB45309), fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ] else if (isPendingDealer) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Application: ${dealerInfo.businessName} (${dealerInfo.businessType}) • Awaiting Approval',
                              style: const TextStyle(color: Colors.deepOrange, fontSize: 11.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                                child: Text('${c.totalOrders} Order(s)', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                                child: Text('৳${c.totalSpent.toStringAsFixed(0)} Total Spend', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                              ),
                              Text('Last purchase: ${c.lastOrderDate}', style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Action Buttons
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        // If not a dealer yet, provide 1-click option to make them a Dealer/Wholesaler
                        if (!isApprovedDealer && !isPendingDealer)
                          ElevatedButton.icon(
                            onPressed: () => _openUpgradeCustomerToDealerDialog(context, cubit, c),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF831843), // deep plum
                              foregroundColor: AppTheme.goldLight,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            icon: const Icon(Icons.business_center, size: 13),
                            label: const Text('+ Make Dealer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          )
                        else if (isPendingDealer)
                          ElevatedButton.icon(
                            onPressed: () {
                              cubit.approveB2BPartner(dealerInfo.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Approved ${dealerInfo.businessName} as official wholesale dealer!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            icon: const Icon(Icons.check_circle_outline, size: 13),
                            label: const Text('Approve Dealer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),

                        OutlinedButton.icon(
                          onPressed: () => _openCustomerDetailsDialog(context, c),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            foregroundColor: AppTheme.rose900,
                            side: const BorderSide(color: AppTheme.rose900),
                          ),
                          icon: const Icon(Icons.receipt_long, size: 14),
                          label: const Text('Order History', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final cleanPhone = c.phone.replaceAll(RegExp(r'[^0-9]'), '');
                            final msg = Uri.encodeComponent('Assalamu Alaikum ${c.name}! Greetings from Ruposhi International Concierge.');
                            final url = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
                            if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          icon: const Icon(Icons.chat, size: 14),
                          label: const Text('WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  void _openUpgradeCustomerToDealerDialog(BuildContext context, StoreCubit cubit, CustomerRecord customer) {
    final businessNameCtrl = TextEditingController(text: '${customer.name} Cosmetics & Parlour');
    final tradeCtrl = TextEditingController(text: 'TRAD/DNCC/${DateTime.now().millisecondsSinceEpoch % 100000}/2026');
    final districtCtrl = TextEditingController(text: customer.district);
    String businessType = 'Wholesaler';
    String tier = 'Wholesaler (20% off)';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.gold100, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.storefront, color: AppTheme.gold600, size: 22),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Grant Dealer / Wholesaler Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, color: Colors.blueGrey, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Customer: ${customer.name} (${customer.phone})\nDistrict: ${customer.district} • Lifetime: ৳${customer.totalSpent.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: businessNameCtrl,
                      decoration: const InputDecoration(labelText: 'Salon / Business / Enterprise Name'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: businessType,
                            isExpanded: true,
                            decoration: const InputDecoration(labelText: 'Business Category'),
                            items: ['Wholesaler', 'Salon & Spa', 'Pharmacy', 'Distributor']
                                .map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13))))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => businessType = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: districtCtrl,
                            decoration: const InputDecoration(labelText: 'Business Region / District'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: tier,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Wholesale Discount Tier'),
                      items: [
                        'Wholesaler (20% off)',
                        'Gold Salon (25% off)',
                        'Platinum Partner (30% off)',
                        'Master Distributor (35% off)'
                      ].map((t) => DropdownMenuItem(value: t, child: Text(t, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => tier = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tradeCtrl,
                      decoration: const InputDecoration(labelText: 'Trade License Number'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.rose900,
                  foregroundColor: AppTheme.goldLight,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onPressed: () {
                  cubit.grantDealerStatusToCustomer(
                    customer,
                    businessName: businessNameCtrl.text.trim(),
                    tier: tier,
                    tradeLicense: tradeCtrl.text.trim(),
                    businessType: businessType,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.midnightPlum,
                      content: Text('${customer.name} is now an Approved Wholesale Dealer! They can now log in at B2B portal using ${customer.phone}.'),
                    ),
                  );
                },
                icon: const Icon(Icons.verified, size: 16),
                label: const Text('Confirm & Grant Dealer Login', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SECTION 7: WAREHOUSE & COLD-CHAIN COMPLIANCE
  // ==========================================
  Widget _buildComplianceSection(BuildContext context, StoreCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Climate-Controlled Warehousing & BSTI Compliance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Text('Central Dhaka hub 18-22°C active telemetry and direct air-freight customs declarations.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5)),
        const SizedBox(height: 20),

        // Live telemetry card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.ac_unit, color: Colors.blue, size: 32),
              ),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dhaka Central Fulfillment Hub - Cold Room A', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 2),
                    Text('Current Temp: 19.4°C (Target: 18.0°C - 22.0°C) • Humidity: 46% (Target: 40% - 55%)', style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
                    SizedBox(height: 4),
                    Text('Status: Optimal active cooling. Peptides, Niacinamide & Retinols protected.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text('BSTI Certified Batch Records & Air Cargo AWBs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),

        if (widget.state.warehouseBatches.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.blueGrey, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No customs batches recorded yet. BSTI batches sync directly from Supabase warehouse_batches table.',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else
          ...widget.state.warehouseBatches.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user, color: Colors.green, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.productName} (${b.originCountry})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('Batch No: ${b.batchNo} • BSTI Certificate: ${b.bstiCertNo}', style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                          Text('Customs Entry: ${b.customsEntryNo} • Air AWB: ${b.airAwb}', style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(b.status, style: TextStyle(color: Colors.green.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}

