import 'package:equatable/equatable.dart';

class AdminOrder extends Equatable {
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String city;
  final String paymentMethod;
  final double subtotal;
  final double deliveryFee;
  final double grandTotal;
  final List<Map<String, dynamic>> items;
  final String status; // 'Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'
  final DateTime createdAt;
  final String? courier; // 'Steadfast', 'Pathao', 'RedX', 'Paperfly'
  final String? trackingCode;
  final String? notes;

  const AdminOrder({
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.city,
    required this.paymentMethod,
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.items,
    this.status = 'Confirmed',
    required this.createdAt,
    this.courier,
    this.trackingCode,
    this.notes,
  });

  AdminOrder copyWith({
    String? orderId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? city,
    String? paymentMethod,
    double? subtotal,
    double? deliveryFee,
    double? grandTotal,
    List<Map<String, dynamic>>? items,
    String? status,
    DateTime? createdAt,
    String? courier,
    String? trackingCode,
    String? notes,
  }) {
    return AdminOrder(
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      city: city ?? this.city,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      grandTotal: grandTotal ?? this.grandTotal,
      items: items ?? this.items,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      courier: courier ?? this.courier,
      trackingCode: trackingCode ?? this.trackingCode,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [orderId, customerPhone, status, grandTotal, trackingCode];
}

class B2BPartner extends Equatable {
  final String id;
  final String businessName;
  final String contactPerson;
  final String phone;
  final String email;
  final String tradeLicense;
  final String district;
  final String tier; // 'Gold Salon (25% off)', 'Platinum Partner (30% off)', 'Master Distributor (35% off)'
  final String status; // 'Approved', 'Pending Review', 'Suspended'
  final int totalOrders;
  final double totalSpend;

  const B2BPartner({
    required this.id,
    required this.businessName,
    required this.contactPerson,
    required this.phone,
    required this.email,
    required this.tradeLicense,
    required this.district,
    required this.tier,
    this.status = 'Approved',
    this.totalOrders = 0,
    this.totalSpend = 0.0,
  });

  B2BPartner copyWith({
    String? id,
    String? businessName,
    String? contactPerson,
    String? phone,
    String? email,
    String? tradeLicense,
    String? district,
    String? tier,
    String? status,
    int? totalOrders,
    double? totalSpend,
  }) {
    return B2BPartner(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      tradeLicense: tradeLicense ?? this.tradeLicense,
      district: district ?? this.district,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpend: totalSpend ?? this.totalSpend,
    );
  }

  @override
  List<Object?> get props => [id, businessName, phone, status, tier];
}

class Coupon extends Equatable {
  final String code;
  final double discountPercent;
  final double minSpend;
  final bool isActive;
  final int usageCount;
  final String expiryDate;

  const Coupon({
    required this.code,
    required this.discountPercent,
    this.minSpend = 0.0,
    this.isActive = true,
    this.usageCount = 0,
    required this.expiryDate,
  });

  Coupon copyWith({
    String? code,
    double? discountPercent,
    double? minSpend,
    bool? isActive,
    int? usageCount,
    String? expiryDate,
  }) {
    return Coupon(
      code: code ?? this.code,
      discountPercent: discountPercent ?? this.discountPercent,
      minSpend: minSpend ?? this.minSpend,
      isActive: isActive ?? this.isActive,
      usageCount: usageCount ?? this.usageCount,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  List<Object?> get props => [code, discountPercent, isActive];
}

class CustomerRecord extends Equatable {
  final String phone;
  final String name;
  final String district;
  final int totalOrders;
  final double totalSpent;
  final String lastOrderDate;
  final bool isVip;

  const CustomerRecord({
    required this.phone,
    required this.name,
    required this.district,
    required this.totalOrders,
    required this.totalSpent,
    required this.lastOrderDate,
    this.isVip = false,
  });

  @override
  List<Object?> get props => [phone, name, totalOrders, totalSpent];
}

class WarehouseBatch extends Equatable {
  final String batchNo;
  final String productName;
  final String originCountry;
  final String bstiCertNo;
  final String customsEntryNo;
  final String airAwb;
  final double currentTemp;
  final String status;

  const WarehouseBatch({
    required this.batchNo,
    required this.productName,
    required this.originCountry,
    required this.bstiCertNo,
    required this.customsEntryNo,
    required this.airAwb,
    required this.currentTemp,
    this.status = 'Verified & Sealed',
  });

  @override
  List<Object?> get props => [batchNo, productName, bstiCertNo];
}

// Initial Sample Data for Business Operations
final List<AdminOrder> initialSampleOrders = [
  AdminOrder(
    orderId: 'RUP-88129',
    customerName: 'Tasnim Rahman',
    customerPhone: '+880 1712-458921',
    customerAddress: 'House 42, Road 11, Block D, Banani',
    city: 'Dhaka (Inside City)',
    paymentMethod: 'Cash on Delivery',
    subtotal: 5850.0,
    deliveryFee: 0.0,
    grandTotal: 5850.0,
    status: 'Pending',
    createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
    courier: 'Steadfast Courier',
    trackingCode: 'ST-998241',
    items: const [
      {'name': 'COSRX Advanced Snail 96 Mucin Power Essence', 'quantity': 2, 'price': 1850.0},
      {'name': 'CeraVe Foaming Facial Cleanser (USA)', 'quantity': 1, 'price': 2150.0},
    ],
  ),
  AdminOrder(
    orderId: 'RUP-88120',
    customerName: 'Farhana Chowdhury',
    customerPhone: '+880 1819-332211',
    customerAddress: 'Apartment 5B, South Breeze, Dhanmondi 27',
    city: 'Dhaka (Inside City)',
    paymentMethod: 'bKash Instant',
    subtotal: 7800.0,
    deliveryFee: 0.0,
    grandTotal: 7020.0, // 10% coupon
    status: 'Shipped',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    courier: 'Pathao Express',
    trackingCode: 'PTH-7712093',
    items: const [
      {'name': 'La Roche-Posay Anthelios UVmune 400 SPF50+', 'quantity': 2, 'price': 2850.0},
      {'name': 'MAC Retro Matte Lipstick - Ruby Woo', 'quantity': 1, 'price': 2100.0},
    ],
  ),
  AdminOrder(
    orderId: 'RUP-88114',
    customerName: 'Samira Akter (Radiance Salon)',
    customerPhone: '+880 1911-884422',
    customerAddress: 'GEC Circle, Nasirabad',
    city: 'Chittagong (Outside Dhaka)',
    paymentMethod: 'Cash on Delivery',
    subtotal: 19500.0,
    deliveryFee: 0.0,
    grandTotal: 19500.0,
    status: 'Processing',
    createdAt: DateTime.now().subtract(const Duration(hours: 9)),
    courier: 'RedX Logistics',
    trackingCode: 'REDX-331094',
    items: const [
      {'name': 'Beauty of Joseon Relief Sun: Rice + Probiotics', 'quantity': 10, 'price': 1150.0},
      {'name': 'COSRX Advanced Snail 96 Mucin Power Essence', 'quantity': 5, 'price': 1600.0},
    ],
  ),
  AdminOrder(
    orderId: 'RUP-88098',
    customerName: 'Dr. Mehzabin Sultana',
    customerPhone: '+880 1733-112233',
    customerAddress: 'Khadimpara, Shahjalal Upashahar',
    city: 'Sylhet (Outside Dhaka)',
    paymentMethod: 'Nagad Pay',
    subtotal: 4700.0,
    deliveryFee: 0.0,
    grandTotal: 4700.0,
    status: 'Delivered',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    courier: 'Steadfast Courier',
    trackingCode: 'ST-991204',
    items: const [
      {'name': 'The Ordinary Niacinamide 10% + Zinc 1%', 'quantity': 3, 'price': 1450.0},
    ],
  ),
];

final List<B2BPartner> initialSampleB2BPartners = [
  const B2BPartner(
    id: 'b2b_1',
    businessName: 'Radiance Beauty Studio & Spa',
    contactPerson: 'Farida Yasmin',
    phone: '+880 1711-234567',
    email: 'info@radiancebd.com',
    tradeLicense: 'TRAD/DNCC/082194/2023',
    district: 'Gulshan 2, Dhaka',
    tier: 'Platinum Partner (30% off)',
    status: 'Approved',
    totalOrders: 18,
    totalSpend: 384000.0,
  ),
  const B2BPartner(
    id: 'b2b_2',
    businessName: 'Apex Derma Care Pharmacy',
    contactPerson: 'Dr. M. A. Karim',
    phone: '+880 1819-876543',
    email: 'contact@apexderma.com',
    tradeLicense: 'TRAD/DSCC/034981/2024',
    district: 'Dhanmondi, Dhaka',
    tier: 'Gold Salon (25% off)',
    status: 'Approved',
    totalOrders: 12,
    totalSpend: 245000.0,
  ),
  const B2BPartner(
    id: 'b2b_3',
    businessName: 'Glamour Queen Beauty Parlour',
    contactPerson: 'Nusrat Jahan',
    phone: '+880 1912-334455',
    email: 'glamourqueen.ctg@gmail.com',
    tradeLicense: 'TRAD/CCC/119284/2024',
    district: 'Panchlaish, Chittagong',
    tier: 'Gold Salon (25% off)',
    status: 'Pending Review',
    totalOrders: 0,
    totalSpend: 0.0,
  ),
  const B2BPartner(
    id: 'b2b_4',
    businessName: 'Sylhet Aesthetics & Laser Clinic',
    contactPerson: 'Dr. Sabrina Ahmed',
    phone: '+880 1722-998877',
    email: 'info@sylhetaesthetics.com',
    tradeLicense: 'TRAD/SCC/045812/2023',
    district: 'Zindabazar, Sylhet',
    tier: 'Master Distributor (35% off)',
    status: 'Approved',
    totalOrders: 26,
    totalSpend: 620000.0,
  ),
];

final List<Coupon> initialSampleCoupons = [
  const Coupon(
    code: 'RUPOSHI10',
    discountPercent: 10,
    minSpend: 2000,
    isActive: true,
    usageCount: 142,
    expiryDate: '2026-12-31',
  ),
  const Coupon(
    code: 'LUXE15',
    discountPercent: 15,
    minSpend: 5000,
    isActive: true,
    usageCount: 68,
    expiryDate: '2026-12-31',
  ),
  const Coupon(
    code: 'EIDGLOW20',
    discountPercent: 20,
    minSpend: 8000,
    isActive: true,
    usageCount: 29,
    expiryDate: '2026-06-30',
  ),
];

final List<CustomerRecord> initialSampleCustomers = [
  const CustomerRecord(
    phone: '+880 1712-458921',
    name: 'Tasnim Rahman',
    district: 'Dhaka',
    totalOrders: 6,
    totalSpent: 28400.0,
    lastOrderDate: 'Today',
    isVip: true,
  ),
  const CustomerRecord(
    phone: '+880 1819-332211',
    name: 'Farhana Chowdhury',
    district: 'Dhaka',
    totalOrders: 4,
    totalSpent: 21900.0,
    lastOrderDate: 'Today',
    isVip: true,
  ),
  const CustomerRecord(
    phone: '+880 1911-884422',
    name: 'Samira Akter',
    district: 'Chittagong',
    totalOrders: 8,
    totalSpent: 142000.0,
    lastOrderDate: 'Yesterday',
    isVip: true,
  ),
  const CustomerRecord(
    phone: '+880 1733-112233',
    name: 'Dr. Mehzabin Sultana',
    district: 'Sylhet',
    totalOrders: 3,
    totalSpent: 16400.0,
    lastOrderDate: '2 days ago',
    isVip: false,
  ),
];

final List<WarehouseBatch> initialSampleBatches = [
  const WarehouseBatch(
    batchNo: 'KOR-2026-COSRX-96',
    productName: 'COSRX Advanced Snail 96 Mucin Power Essence',
    originCountry: 'South Korea',
    bstiCertNo: 'BSTI/COS/2026/0491',
    customsEntryNo: 'DAC/AIR/C-77291',
    airAwb: 'KE-0694-8812',
    currentTemp: 19.4,
    status: 'Verified & Sealed',
  ),
  const WarehouseBatch(
    batchNo: 'USA-2026-CERAVE-FOAM',
    productName: 'CeraVe Foaming Facial Cleanser (USA)',
    originCountry: 'United States',
    bstiCertNo: 'BSTI/COS/2026/0512',
    customsEntryNo: 'DAC/AIR/C-77340',
    airAwb: 'EK-0205-9921',
    currentTemp: 19.8,
    status: 'Verified & Sealed',
  ),
  const WarehouseBatch(
    batchNo: 'FRA-2026-LRP-UVMUNE',
    productName: 'La Roche-Posay Anthelios UVmune 400 SPF50+',
    originCountry: 'France',
    bstiCertNo: 'BSTI/COS/2026/0688',
    customsEntryNo: 'DAC/AIR/C-78104',
    airAwb: 'AF-0331-7742',
    currentTemp: 19.2,
    status: 'Verified & Sealed',
  ),
  const WarehouseBatch(
    batchNo: 'CAN-2026-MAC-RUBY',
    productName: 'MAC Retro Matte Lipstick - Ruby Woo',
    originCountry: 'Canada / USA',
    bstiCertNo: 'BSTI/COS/2026/0724',
    customsEntryNo: 'DAC/AIR/C-78441',
    airAwb: 'QR-0824-3310',
    currentTemp: 20.1,
    status: 'Verified & Sealed',
  ),
];
