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

  factory AdminOrder.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>> itemsList = [];
    final rawItems = map['items'];
    if (rawItems is List) {
      itemsList = rawItems.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return AdminOrder(
      orderId: map['order_id'] ?? map['orderId'] ?? 'RUP-000',
      customerName: map['customer_name'] ?? map['customerName'] ?? 'Valued Customer',
      customerPhone: map['customer_phone'] ?? map['customerPhone'] ?? '',
      customerAddress: map['delivery_address'] ?? map['customerAddress'] ?? '',
      city: map['city'] ?? 'Dhaka',
      paymentMethod: map['payment_method'] ?? map['paymentMethod'] ?? 'COD',
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (map['delivery_fee'] as num?)?.toDouble() ?? (map['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grand_total'] as num?)?.toDouble() ?? (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
      items: itemsList,
      status: map['status'] ?? 'Pending',
      createdAt: map['created_at'] != null ? (DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()) : (map['createdAt'] is DateTime ? map['createdAt'] : DateTime.now()),
      courier: map['courier'],
      trackingCode: map['tracking_code'] ?? map['trackingCode'],
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order_id': orderId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'delivery_address': customerAddress,
      'city': city,
      'payment_method': paymentMethod,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'grand_total': grandTotal,
      'items': items,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      if (courier != null) 'courier': courier,
      if (trackingCode != null) 'tracking_code': trackingCode,
      if (notes != null) 'notes': notes,
    };
  }
}

class B2BPartner extends Equatable {
  final String id;
  final String businessName;
  final String contactPerson;
  final String phone;
  final String email;
  final String tradeLicense;
  final String district;
  final String tier; // 'Gold Salon (25% off)', 'Platinum Partner (30% off)', 'Master Distributor (35% off)', 'Wholesaler (20% off)'
  final String status; // 'Approved', 'Pending Review', 'Suspended'
  final String businessType; // 'Wholesaler', 'Salon & Spa', 'Pharmacy', 'Distributor'
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
    this.businessType = 'Wholesaler',
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
    String? businessType,
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
      businessType: businessType ?? this.businessType,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpend: totalSpend ?? this.totalSpend,
    );
  }

  factory B2BPartner.fromMap(Map<String, dynamic> map) {
    final rawStatus = map['status'] ?? 'Pending Review';
    final normalizedStatus = (rawStatus == 'Active' || rawStatus == 'Approved') ? 'Approved' : rawStatus;

    var tierStr = map['tier']?.toString() ?? 'Wholesaler (20% off)';
    if (tierStr == 'Platinum') tierStr = 'Platinum Partner (30% off)';
    if (tierStr == 'Gold') tierStr = 'Gold Salon (25% off)';
    if (tierStr == 'Silver' || tierStr == 'Bronze') tierStr = 'Wholesaler (20% off)';

    final rawName = map['business_name'] ?? map['businessName'] ?? 'Wholesale Partner';
    var bType = map['business_type'] ?? map['businessType'];
    if (bType == null || bType.toString().isEmpty) {
      final lowerName = rawName.toString().toLowerCase();
      if (lowerName.contains('salon') || lowerName.contains('spa') || lowerName.contains('studio')) {
        bType = 'Salon & Spa';
      } else if (lowerName.contains('pharma') || lowerName.contains('drug') || lowerName.contains('chemist')) {
        bType = 'Pharmacy';
      } else if (lowerName.contains('distributor') || lowerName.contains('agency')) {
        bType = 'Distributor';
      } else {
        bType = 'Wholesaler';
      }
    }

    return B2BPartner(
      id: map['id']?.toString() ?? 'b2b_${DateTime.now().millisecondsSinceEpoch}',
      businessName: rawName,
      contactPerson: map['contact_person'] ?? map['contactPerson'] ?? 'Proprietor',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      tradeLicense: map['trade_license'] ?? map['tradeLicense'] ?? '',
      district: map['district'] ?? 'Dhaka',
      tier: tierStr,
      status: normalizedStatus,
      businessType: bType.toString(),
      totalOrders: (map['total_orders'] as num?)?.toInt() ?? 0,
      totalSpend: (map['total_spend'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'business_name': businessName,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'trade_license': tradeLicense,
      'district': district,
      'tier': tier,
      'status': status,
      'business_type': businessType,
      'total_orders': totalOrders,
      'total_spend': totalSpend,
    };
  }

  @override
  List<Object?> get props => [id, businessName, phone, status, tier, businessType];
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

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      code: map['code']?.toString() ?? '',
      discountPercent: (map['discount_percent'] as num?)?.toDouble() ?? 10.0,
      minSpend: (map['min_spend'] as num?)?.toDouble() ?? 0.0,
      isActive: map['is_active'] ?? true,
      usageCount: (map['usage_count'] as num?)?.toInt() ?? 0,
      expiryDate: map['expiry_date']?.toString() ?? '2026-12-31',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'discount_percent': discountPercent,
      'min_spend': minSpend,
      'is_active': isActive,
      'usage_count': usageCount,
      'expiry_date': expiryDate,
    };
  }
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

  factory CustomerRecord.fromMap(Map<String, dynamic> map) {
    return CustomerRecord(
      phone: map['phone'] ?? '',
      name: map['name'] ?? 'Valued Customer',
      district: map['district'] ?? 'Dhaka',
      totalOrders: (map['total_orders'] as num?)?.toInt() ?? 1,
      totalSpent: (map['total_spent'] as num?)?.toDouble() ?? 0.0,
      lastOrderDate: map['last_order_date'] != null ? map['last_order_date'].toString().split('T').first : 'Recent',
      isVip: map['is_vip'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'district': district,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'last_order_date': lastOrderDate,
      'is_vip': isVip,
    };
  }
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

  factory WarehouseBatch.fromMap(Map<String, dynamic> map) {
    final tempVal = map['current_temp'];
    double temp = 21.0;
    if (tempVal is num) {
      temp = tempVal.toDouble();
    } else if (tempVal is String) {
      temp = double.tryParse(tempVal.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 21.0;
    }
    return WarehouseBatch(
      batchNo: map['batch_no'] ?? map['batchNo'] ?? '',
      productName: map['product_name'] ?? map['productName'] ?? '',
      originCountry: map['origin_country'] ?? map['originCountry'] ?? '',
      bstiCertNo: map['bsti_cert_no'] ?? map['bstiCertNo'] ?? '',
      customsEntryNo: map['customs_entry_no'] ?? map['customsEntryNo'] ?? '',
      airAwb: map['air_awb'] ?? map['airAwb'] ?? '',
      currentTemp: temp,
      status: map['status'] ?? 'Verified & Sealed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'batch_no': batchNo,
      'product_name': productName,
      'origin_country': originCountry,
      'bsti_cert_no': bstiCertNo,
      'customs_entry_no': customsEntryNo,
      'air_awb': airAwb,
      'current_temp': '${currentTemp.toStringAsFixed(1)}°C',
      'status': status,
    };
  }
}

// Production Initial Empty Lists (Populated dynamically via Supabase)
const List<AdminOrder> initialSampleOrders = [];
const List<B2BPartner> initialSampleB2BPartners = [];
const List<Coupon> initialSampleCoupons = [];
const List<CustomerRecord> initialSampleCustomers = [];
const List<WarehouseBatch> initialSampleBatches = [];
