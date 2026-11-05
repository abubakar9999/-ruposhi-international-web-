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
    // Pipe-delimited bulk template:
    // Name | Brand | Category | Origin | Flag | RetailPrice | WholesalePrice | MOQ | Stock | ImageUrl | Batch
    const sample = '''Anua Heartleaf 77% Soothing Toner | Anua | Skincare | South Korea | 🇰🇷 | 2150 | 1650 | 10 | 45 | https://images.unsplash.com/photo-1556228720-195a672e8a03?auto=format&fit=crop&w=600&q=80 | KOR-2026-ANUA-77
Paula's Choice Skin Perfecting 2% BHA Liquid | Paula's Choice | Skincare | United States | 🇺🇸 | 3450 | 2800 | 8 | 30 | https://images.unsplash.com/photo-1608248597359-0056973e46c7?auto=format&fit=crop&w=600&q=80 | USA-2026-PC-BHA
Laneige Lip Sleeping Mask Berry | Laneige | Skincare | South Korea | 🇰🇷 | 1950 | 1450 | 12 | 60 | https://images.unsplash.com/photo-1599305090598-fe179d501227?auto=format&fit=crop&w=600&q=80 | KOR-2026-LAN-LIP
Bioderma Sensibio H2O Micellar Water 500ml | Bioderma | Skincare | France | 🇫🇷 | 2250 | 1750 | 10 | 50 | https://images.unsplash.com/photo-1571781926291-c477ebfd024b?auto=format&fit=crop&w=600&q=80 | FRA-2026-BIO-H2O
Neutrogena Hydro Boost Water Gel | Neutrogena | Skincare | United States | 🇺🇸 | 1850 | 1400 | 10 | 40 | https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=600&q=80 | USA-2026-NEU-HYD''';

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
        final brand = parts.length > 1 ? parts[1] : 'Imported';
        final category = parts.length > 2 ? parts[2] : 'Skincare';
        final origin = parts.length > 3 ? parts[3] : 'South Korea';
        final flag = parts.length > 4 ? parts[4] : '✨';
        final retailPrice = double.tryParse(parts.length > 5 ? parts[5] : '1500') ?? 1500.0;
        final wholesalePrice = double.tryParse(parts.length > 6 ? parts[6] : '1200') ?? 1200.0;
        final moq = int.tryParse(parts.length > 7 ? parts[7] : '10') ?? 10;
        final stock = int.tryParse(parts.length > 8 ? parts[8] : '50') ?? 50;
        final imgUrl = parts.length > 9 && parts[9].isNotEmpty
            ? parts[9]
            : 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=600&q=80';
        final batch = parts.length > 10 ? parts[10] : 'BATCH-2026-${i + 1}';

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
          batchNo: batch,
          expiryDate: '2028-12',
          skinType: 'All Skin Types',
          description: 'Official imported authentic cosmetics. Batch checked.',
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
                    Text('Format Guide (1 product per line):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                    SizedBox(height: 4),
                    Text(
                      'Name | Brand | Category | Origin Country | Flag | Retail Price | Wholesale Price | MOQ | Stock | Image URL | Batch No',
                      style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.blueGrey),
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

              // Preview list of parsed items
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
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
                    return ListTile(
                      dense: true,
                      leading: Text(p.countryFlag, style: const TextStyle(fontSize: 18)),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                      subtitle: Text('${p.brand} • ${p.category} • Retail: ৳${p.retailPrice.toStringAsFixed(0)} • Wholesale: ৳${p.wholesalePrice.toStringAsFixed(0)} • Stock: ${p.stock} units', style: const TextStyle(fontSize: 11)),
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

