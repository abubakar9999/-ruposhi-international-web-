import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';

class CartDrawer extends StatelessWidget {
  final StoreState state;
  const CartDrawer({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();

    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth < 460 ? (screenWidth * 0.94).clamp(280.0, 400.0) : 400.0;

    return Drawer(
      width: drawerWidth,
      backgroundColor: AppTheme.surfaceWhite,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRose.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, color: AppTheme.primaryRose, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isBangla ? 'আপনার বিউটি ব্যাগ' : 'Your Beauty Bag',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${state.totalCartUnits} ${state.isBangla ? 'টি পণ্য যুক্ত আছে' : 'items selected'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Free Delivery Progress Banner
            if (state.cart.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                color: AppTheme.softBlush,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.isFreeDeliveryEligible ? Icons.local_shipping : Icons.local_shipping_outlined,
                          size: 16,
                          color: state.isFreeDeliveryEligible ? Colors.green : AppTheme.darkPlum,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.isFreeDeliveryEligible
                                ? (state.isBangla
                                    ? '🎉 অভিনন্দন! আপনি ফ্রি ডেলিভারি পাচ্ছেন!'
                                    : '🎉 You qualified for FREE Dhaka Delivery!')
                                : (state.isBangla
                                    ? 'ফ্রি ডেলিভারি পেতে আরও ৳${state.amountNeededForFreeDelivery.toStringAsFixed(0)} এর কেনাকাটা করুন'
                                    : 'Add ৳${state.amountNeededForFreeDelivery.toStringAsFixed(0)} more for FREE Delivery'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: state.isFreeDeliveryEligible ? Colors.green.shade800 : AppTheme.darkPlum,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (state.subtotal / StoreState.freeDeliveryThreshold).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          state.isFreeDeliveryEligible ? Colors.green : AppTheme.primaryRose,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Items List
            Expanded(
              child: state.cart.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                color: AppTheme.softBlush,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, size: 36, color: AppTheme.primaryRose),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.isBangla ? 'আপনার ব্যাগটি খালি' : 'Your bag is empty',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              state.isBangla
                                  ? 'আমাদের বিশ্বমানের আমদানিকৃত প্রসাধনী ক্যাটালগ ঘুরে দেখুন'
                                  : 'Discover authentic imported skincare & makeup',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                cubit.navigateTo(AppView.shop);
                              },
                              child: Text(state.isBangla ? 'শপিং শুরু করুন' : 'Explore Catalog'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.cart.length,
                      separatorBuilder: (_, __) => const Divider(color: AppTheme.borderSubtle, height: 24),
                      itemBuilder: (context, index) {
                        final item = state.cart[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 70,
                                height: 75,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 70,
                                  height: 75,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Info & Quantities
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.brand.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryRose,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.isBangla ? item.product.nameBn : item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.softBlush,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.selectedOption,
                                          style: const TextStyle(fontSize: 10.5, color: AppTheme.darkPlum),
                                        ),
                                      ),
                                      if (item.isWholesale) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade50,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'B2B MOQ (${item.product.moq})',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Quantity Stepper
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppTheme.borderSubtle),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: () => cubit.updateCartQty(index, -1),
                                              borderRadius: BorderRadius.circular(20),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Icon(Icons.remove, size: 14),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => cubit.updateCartQty(index, 1),
                                              borderRadius: BorderRadius.circular(20),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Icon(Icons.add, size: 14),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Total for Item
                                      Text(
                                        '৳${item.total.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: AppTheme.darkPlum,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),

            // Bottom Checkout Summary
            if (state.cart.isNotEmpty)
              Container(
                padding: EdgeInsets.all(screenWidth < 400 ? 14 : 20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  border: const Border(top: BorderSide(color: AppTheme.borderSubtle)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            state.isBangla ? 'সাবটোটাল' : 'Subtotal',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '৳${state.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            state.isBangla ? 'আনুমানিক ডেলিভারি' : 'Estimated Delivery',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          state.deliveryFee == 0
                              ? (state.isBangla ? 'ফ্রি' : 'FREE')
                              : '৳${state.deliveryFee.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                            color: state.deliveryFee == 0 ? Colors.green : AppTheme.darkPlum,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            state.isBangla ? 'সর্বমোট প্রদেয়' : 'Total Payable',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '৳${state.grandTotal.toStringAsFixed(0)} BDT',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppTheme.primaryRose,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          cubit.navigateTo(AppView.checkout);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                state.isBangla ? 'চেকআউটে যান' : 'Proceed to Checkout',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
