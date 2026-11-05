import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isBangla;
  final bool isB2BActive;
  final double? width;

  const ProductCard({
    super.key,
    required this.product,
    required this.isBangla,
    this.isB2BActive = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isWishlisted = context.select<StoreCubit, bool>((c) => c.state.isWishlisted(product.id));
    final screenWidth = MediaQuery.sizeOf(context).width;
    final targetWidth = width ?? (screenWidth < 360 ? screenWidth - 32 : 290.0);
    final isCompact = targetWidth < 235;

    return Container(
      width: targetWidth,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
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
          // Image Container with Badges
          Stack(
            children: [
              InkWell(
                onTap: () => cubit.navigateTo(AppView.productDetails, product: product),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: isCompact ? 175 : 230,
                    width: double.infinity,
                    color: const Color(0xFFF9F7F6),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.spa_outlined, size: 48, color: Colors.grey.shade400),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: progress.expectedTotalBytes != null
                                ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                : null,
                            color: AppTheme.primaryRose,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Badges (Top Left)
              Positioned(
                top: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (product.isBestSeller)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldBadgeGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 11, color: Colors.black),
                            const SizedBox(width: 3),
                            Text(
                              isBangla ? 'বেস্টসেলার' : 'BESTSELLER',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (product.isNewArrival)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.darkPlum,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isBangla ? 'নতুন আগমন' : 'NEW ARRIVAL',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    if (product.discountPercent > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: AppTheme.rose600,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Wishlist Heart Button (Top Right)
              Positioned(
                top: 10,
                right: 10,
                child: InkWell(
                  onTap: () => cubit.toggleWishlist(product.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border_rounded,
                      color: isWishlisted ? Colors.redAccent : AppTheme.darkPlum,
                      size: 19,
                    ),
                  ),
                ),
              ),

              // Origin Country Pill (Bottom Left of Image)
              Positioned(
                bottom: 10,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(product.countryFlag, style: const TextStyle(fontSize: 11)),
                      const SizedBox(width: 4),
                      Text(
                        product.originCountry,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkPlum,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Content Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand & Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.brand.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: AppTheme.goldAccent),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkPlum,
                          ),
                        ),
                        Text(
                          ' (${product.reviewsCount})',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Product Title
                InkWell(
                  onTap: () => cubit.navigateTo(AppView.productDetails, product: product),
                  child: Text(
                    isBangla ? product.nameBn : product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      height: 1.35,
                      color: AppTheme.darkPlum,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Batch & Expiry Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.softBlush,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_outlined, size: 12, color: Colors.green),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          'Batch: ${product.batchNo} • Exp: ${product.expiryDate}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // B2B Wholesale Indicator (if active)
                if (isB2BActive) ...[
                  Container(
                    padding: const EdgeInsets.all(7),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'B2B Rate: ৳${product.wholesalePrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'MOQ: ${product.moq} pcs',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Price & Add to Bag
                if (isCompact) ...[
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 5,
                    children: [
                      Text(
                        '৳${product.retailPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkPlum,
                        ),
                      ),
                      if (product.oldPrice != null)
                        Text(
                          '৳${product.oldPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        cubit.addToCart(product);
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.midnightPlum,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppTheme.goldAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text('${product.name} added to your Beauty Bag!'),
                                ),
                              ],
                            ),
                            action: SnackBarAction(
                              label: 'View Bag',
                              textColor: AppTheme.goldLight,
                              onPressed: () => Scaffold.of(context).openEndDrawer(),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRose,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add_shopping_cart, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            isBangla ? 'কার্ট' : 'Add to Bag',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text(
                                  '৳${product.retailPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.darkPlum,
                                  ),
                                ),
                                if (product.oldPrice != null)
                                  Text(
                                    '৳${product.oldPrice!.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey.shade400,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              'BDT (Incl. VAT)',
                              style: TextStyle(fontSize: 9.5, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          cubit.addToCart(product);
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.midnightPlum,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: AppTheme.goldAccent, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text('${product.name} added to your Beauty Bag!'),
                                  ),
                                ],
                              ),
                              action: SnackBarAction(
                                label: 'View Bag',
                                textColor: AppTheme.goldLight,
                                onPressed: () => Scaffold.of(context).openEndDrawer(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_shopping_cart, size: 15),
                            const SizedBox(width: 5),
                            Text(
                              isBangla ? 'কার্ট' : 'Add',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
