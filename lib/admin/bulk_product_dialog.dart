import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';
import '../models/product_model.dart';

class BulkProductDialog extends StatefulWidget {
  final StoreCubit cubit;
  const BulkProductDialog({super.key, required this.cubit});

  @override
  State<BulkProductDialog> createState() => _BulkProductDialogState();
}

class _BulkProductDialogState extends State<BulkProductDialog> {
  final TextEditingController _rawTextCtrl = TextEditingController();
  List<Product> _parsedProducts = [];
  String? _parseError;

  @override
  void initState() {
    super.initState();
    _loadSampleBulkTemplate();
  }

  @override
  void dispose() {
    _rawTextCtrl.dispose();
    super.dispose();
  }

  void _loadSampleBulkTemplate() {
    // Pipe-delimited bulk template with Multi-Image Support (comma-separated URLs):
    // Name | Brand | Category | Origin | Flag | RetailPrice | WholesalePrice | MOQ | Stock | Image URLs (comma-separated for up to 5 angles) | Batch No
    const sample = '''TIA'M Vita B3 Source (10% Niacinamide + 2% Arbutin) | TIA'M | Serums | South Korea | 🇰🇷 | 1650 | 1180 | 10 | 45 | https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80 | TM-VB3-2026-01
TIA'M Pore Minimizing 21 Serum (20% Niacinamide) | TIA'M | Serums | South Korea | 🇰🇷 | 1750 | 1250 | 10 | 38 | https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80 | TM-PM21-2026-02
TIA'M Snail & Azulene Water Essence (87% Mucin) | TIA'M | Toner & Essence | South Korea | 🇰🇷 | 1750 | 1250 | 10 | 52 | https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80 | TM-SAE-2026-04
TIA'M B3 Niacin Sunscreen SPF 50+ PA++++ | TIA'M | Sun Care | South Korea | 🇰🇷 | 1750 | 1250 | 10 | 60 | https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80 | TM-B3S-2026-10
TIA'M Glow 333 Capsule Cream (NMN + Vit C) | TIA'M | Creams & Moisturizers | South Korea | 🇰🇷 | 2150 | 1520 | 8 | 25 | https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1608248597359-26d11b228f41?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=800&q=80, https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80 | TM-G333-2026-11''';

    _rawTextCtrl.text = sample;
    _parseText(sample);
  }

  void _parseText(String text) {
    final lines = text.split('\n');
    final List<Product> list = [];
    String? err;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final parts = line.split('|').map((s) => s.trim()).toList();
      if (parts.length >= 6) {
        final name = parts[0];
        final brand = parts.length > 1 && parts[1].isNotEmpty ? parts[1] : 'TIA\'M';
        final category = parts.length > 2 && parts[2].isNotEmpty ? parts[2] : 'Skincare';
        final origin = parts.length > 3 && parts[3].isNotEmpty ? parts[3] : 'South Korea';
        final flag = parts.length > 4 && parts[4].isNotEmpty ? parts[4] : '🇰🇷';
        final retailPrice = double.tryParse(parts.length > 5 ? parts[5] : '1500') ?? 1500.0;
        final wholesalePrice = double.tryParse(parts.length > 6 ? parts[6] : '1200') ?? 1200.0;
        final moq = int.tryParse(parts.length > 7 ? parts[7] : '10') ?? 10;
        final stock = int.tryParse(parts.length > 8 ? parts[8] : '50') ?? 50;

        // Multi-image parsing:
        // Column 10 can contain multiple comma- or semicolon-separated URLs.
        // Also supports an optional Column 12 for extra gallery URLs.
        final List<String> parsedImages = [];
        if (parts.length > 9 && parts[9].isNotEmpty) {
          final rawUrls = parts[9].split(RegExp(r'[,;]')).map((s) => s.trim()).where((s) => s.isNotEmpty);
          parsedImages.addAll(rawUrls);
        }

        final batch = parts.length > 10 && parts[10].isNotEmpty ? parts[10] : 'BATCH-2026-${i + 1}';

        if (parts.length > 11 && parts[11].isNotEmpty) {
          final rawExtra = parts[11].split(RegExp(r'[,;]')).map((s) => s.trim()).where((s) => s.isNotEmpty);
          for (final u in rawExtra) {
            if (!parsedImages.contains(u)) parsedImages.add(u);
          }
        }

        final imgUrl = parsedImages.isNotEmpty
            ? parsedImages.first
            : 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80';
        final gallery = parsedImages.length > 1
            ? parsedImages.sublist(1)
            : <String>[];

        list.add(Product(
          id: 'p_bulk_${DateTime.now().millisecondsSinceEpoch}_$i',
          name: name,
          nameBn: name,
          brand: brand,
          category: category,
          originCountry: origin,
          countryFlag: flag,
          retailPrice: retailPrice,
          wholesalePrice: wholesalePrice,
          moq: moq,
          stock: stock,
          imageUrl: imgUrl,
          gallery: gallery,
          batchNo: batch,
          expiryDate: '2028-12',
          skinType: 'All Skin Types',
          description: 'Official imported authentic cosmetics. Batch checked and BSTI verified.',
          descriptionBn: 'অফিসিয়াল আমদানিকৃত অথেনটিক কসমেটিকস। ব্যাচ ও বিএসটিআই ভেরিফাইড।',
          ingredients: 'Active botanical and clinical skincare ingredients.',
          usageInstructions: 'Apply daily onto cleansed skin.',
          isNewArrival: true,
        ));
      } else {
        err = 'Line ${i + 1} has insufficient columns (expected at least 6 pipe-separated values).';
      }
    }

    setState(() {
      _parsedProducts = list;
      _parseError = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.rose50, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.playlist_add, color: AppTheme.rose900, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bulk Product SKU Batch Import', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Add multiple imported products at once using pipe (|) separated format.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 750,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.photo_library, size: 16, color: Colors.blue),
                        SizedBox(width: 6),
                        Text('Format Guide (Supports Multiple Images per SKU):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Name | Brand | Category | Origin Country | Flag | Retail Price | Wholesale Price | MOQ | Stock | Image URLs (comma-separated for multiple angles) | Batch No',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.blueGrey),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '💡 Multiple Images: In the 10th column, supply multiple comma-separated (,) URLs for Main Hero, Texture, Packaging, In-Hand, and Authentic Batch Seal angles matching Bioxin standards.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _rawTextCtrl,
                maxLines: 8,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                onChanged: _parseText,
                decoration: InputDecoration(
                  hintText: 'Paste bulk product lines here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),

              if (_parseError != null) ...[
                const SizedBox(height: 10),
                Text(_parseError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
              ],

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Parsed Ready to Import: ${_parsedProducts.length} Product(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.rose900),
                  ),
                  TextButton.icon(
                    onPressed: _loadSampleBulkTemplate,
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reload 5 Popular SKUs Template', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Preview list of parsed items with multi-image badges
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _parsedProducts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final p = _parsedProducts[idx];
                    final allImgs = p.allImages;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              p.imageUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 44,
                                height: 44,
                                color: Colors.grey.shade100,
                                child: Center(child: Text(p.countryFlag, style: const TextStyle(fontSize: 16))),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        p.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: allImgs.length >= 5 ? Colors.green.shade50 : AppTheme.rose50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: allImgs.length >= 5 ? Colors.green.shade300 : AppTheme.rose200,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.photo_library,
                                            size: 11,
                                            color: allImgs.length >= 5 ? Colors.green.shade800 : AppTheme.rose800,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${allImgs.length} Images',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: allImgs.length >= 5 ? Colors.green.shade800 : AppTheme.rose800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${p.brand} • ${p.category} • Retail: ৳${p.retailPrice.toStringAsFixed(0)} • Wholesale: ৳${p.wholesalePrice.toStringAsFixed(0)} • Stock: ${p.stock} units • Batch: ${p.batchNo}',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.rose900,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          ),
          onPressed: _parsedProducts.isEmpty
              ? null
              : () {
                  for (final product in _parsedProducts) {
                    widget.cubit.addProduct(product);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully imported ${_parsedProducts.length} products in bulk!')),
                  );
                },
          child: Text('Import ${_parsedProducts.length} SKUs Now', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

