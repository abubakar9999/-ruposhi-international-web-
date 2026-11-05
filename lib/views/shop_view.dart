import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../widgets/product_card.dart';

class ShopCatalogView extends StatelessWidget {
  final StoreState state;
  const ShopCatalogView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StoreCubit>();
    final isMobile = MediaQuery.of(context).size.width < 800;
    final products = state.filteredProducts;

    const categories = ['All', 'Skincare', 'Makeup', 'Haircare', 'Fragrance'];
    const brands = [
      'All',
      'COSRX',
      'The Ordinary',
      'Beauty of Joseon',
      'CeraVe',
      'MAC Cosmetics',
      "L'Oréal Paris",
      'Laneige / Amore',
      'Dior Beauty',
    ];
    const sortOptions = ['Featured', 'Price: Low to High', 'Price: High to Low', 'Top Rated', 'Newest'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Count
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 16,
                runSpacing: 10,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isBangla ? 'আমদানিকৃত প্রসাধনী ক্যাটালগ' : 'Imported Cosmetics Catalog',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.isBangla
                              ? '১০০% আসল প্রোডাক্টস | ব্যাচ ট্র্যাকিং ও তাপমাত্রা-নিয়ন্ত্রিত প্যাকেজিং'
                              : 'Authentic imported Korean, French & USA skincare & makeup collection',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${products.length} ${state.isBangla ? 'টি প্রসাধনী' : 'Items'}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Filter Controls Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Input & Sort
                    if (isMobile) ...[
                      TextField(
                        onChanged: cubit.setSearch,
                        decoration: InputDecoration(
                          hintText: state.isBangla
                              ? 'নাম, উপাদান বা ব্র্যান্ড দিয়ে খুঁজুন...'
                              : 'Search by product name, active ingredient or brand...',
                          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryRose),
                          suffixIcon: state.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () => cubit.setSearch(''),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.softBlush,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.sortBy,
                            isExpanded: true,
                            icon: const Icon(Icons.sort_rounded, color: AppTheme.primaryRose, size: 20),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkPlum,
                            ),
                            items: sortOptions
                                .map((s) => DropdownMenuItem(value: s, child: Text('Sort: $s')))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) cubit.setSortBy(v);
                            },
                          ),
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: cubit.setSearch,
                              decoration: InputDecoration(
                                hintText: state.isBangla
                                    ? 'নাম, উপাদান বা ব্র্যান্ড দিয়ে খুঁজুন...'
                                    : 'Search by product name, active ingredient or brand...',
                                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryRose),
                                suffixIcon: state.searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () => cubit.setSearch(''),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.softBlush,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.borderSubtle),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.sortBy,
                                icon: const Icon(Icons.sort_rounded, color: AppTheme.primaryRose, size: 20),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.darkPlum,
                                ),
                                items: sortOptions
                                    .map((s) => DropdownMenuItem(value: s, child: Text('Sort: $s')))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) cubit.setSortBy(v);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Category Filter Pills
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected = state.selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: AppTheme.primaryRose,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.darkPlum,
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          backgroundColor: AppTheme.softBlush,
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryRose : AppTheme.borderSubtle,
                          ),
                          onSelected: (_) => cubit.setCategory(cat),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Brand Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: brands.map((b) {
                          final isSelected = state.selectedBrand == b;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(b),
                              selected: isSelected,
                              selectedColor: AppTheme.goldAccent.withValues(alpha: 0.25),
                              checkmarkColor: AppTheme.darkPlum,
                              labelStyle: TextStyle(
                                color: isSelected ? AppTheme.darkPlum : Colors.grey.shade700,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: isSelected ? AppTheme.goldAccent : AppTheme.borderSubtle,
                              ),
                              onSelected: (_) => cubit.setBrand(b),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Product Grid
              if (products.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 54, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          state.isBangla
                              ? 'আপনার পছন্দের কোনো প্রসাধনী খুঁজে পাওয়া যায়নি'
                              : 'No products matched your search or filter',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.isBangla
                              ? 'ফিল্টার পরিবর্তন করে পুনরায় চেষ্টা করুন'
                              : 'Try clearing your search query or selecting "All" categories.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            cubit.setSearch('');
                            cubit.setCategory('All');
                            cubit.setBrand('All');
                          },
                          child: const Text('Reset All Filters'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final available = constraints.maxWidth;
                    final double cardWidth;
                    if (available < 380) {
                      cardWidth = available;
                    } else if (available < 660) {
                      cardWidth = (available - 14) / 2;
                    } else if (available < 1000) {
                      cardWidth = (available - 2 * 18) / 3;
                    } else {
                      cardWidth = (available - 3 * 20) / 4;
                    }

                    return Wrap(
                      spacing: available < 660 ? 14 : 20,
                      runSpacing: 22,
                      alignment: WrapAlignment.start,
                      children: products.map((p) {
                        return ProductCard(
                          product: p,
                          isBangla: state.isBangla,
                          isB2BActive: state.isB2BAuthenticated,
                          width: cardWidth,
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

