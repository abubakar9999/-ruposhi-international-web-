import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../cubits/store_cubit.dart';

class BlogArticle {
  final String id;
  final String title;
  final String titleBn;
  final String category;
  final String readTime;
  final String date;
  final String imageUrl;
  final String summary;
  final String content;

  const BlogArticle({
    required this.id,
    required this.title,
    required this.titleBn,
    required this.category,
    required this.readTime,
    required this.date,
    required this.imageUrl,
    required this.summary,
    required this.content,
  });
}

const List<BlogArticle> sampleArticles = [
  BlogArticle(
    id: '1',
    title: 'How to Spot Fake Cosmetics in Bangladesh: 5 Inspection Rules',
    titleBn: 'বাংলাদেশে নকল প্রসাধনী চেনার ৫টি মোক্ষম উপায়',
    category: 'Authenticity Guide',
    readTime: '4 min read',
    date: 'February 2026',
    imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    summary: 'From checking laser-etched batch codes to texture and packaging typography, our import quality team shares how to verify original bottles.',
    content: 'Counterfeit cosmetics often flood the local market in unsealed sea containers. At Ruposhi International, every single unit is imported via direct temperature-controlled air freight (18-22°C) with customs batch compliance. Always inspect laser-printed expiration dates, manufacturer barcodes, and product seal integrity.',
  ),
  BlogArticle(
    id: '2',
    title: 'Korean Glass Skin Routine: Snail Mucin & Niacinamide Layering',
    titleBn: 'কোরিয়ান গ্লাস স্কিন রুটিন: স্নেইল মিউসিন ও নায়াসিনামাইড ব্যবহার বিধি',
    category: 'Skincare Routine',
    readTime: '6 min read',
    date: 'January 2026',
    imageUrl: 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=800&q=80',
    summary: 'Master the proper order of active serums for glowing, hydrated skin in Bangladesh’s humid seasonal climate.',
    content: 'After cleansing with a gentle ceramide wash, apply COSRX Advanced Snail 96 Mucin Power Essence onto damp skin to boost cell hydration. Follow with 2-3 drops of The Ordinary Niacinamide 10% + Zinc 1% to regulate sebum and minimize enlarged pores.',
  ),
  BlogArticle(
    id: '3',
    title: 'Why Actives Degrade in Sea Freight: The 20°C Cold Chain Standard',
    titleBn: 'সমুদ্রের তাপে কেন সিরাম নষ্ট হয়: ২০°C কোল্ড চেইন সংরক্ষণ',
    category: 'Import Science',
    readTime: '5 min read',
    date: 'January 2026',
    imageUrl: 'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?auto=format&fit=crop&w=800&q=80',
    summary: 'Why shipping active skincare in sea containers damages peptides, vitamin C, and hyaluronic acid before reaching Dhaka.',
    content: 'Cargo containers crossing the Indian Ocean frequently reach temperatures above 50°C. High heat breaks down sensitive molecular bonds in clinical serums. Ruposhi International strictly mandates air cargo transport and maintains a 20°C fulfillment facility in Banani, Dhaka.',
  ),
];

class BeautyBlogView extends StatelessWidget {
  final StoreState state;
  const BeautyBlogView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 48, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 24 : 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.rose950, AppTheme.rose900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.gold400.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.gold400),
                      ),
                      child: Text(
                        state.isBangla ? 'বিউটি ও স্কিনকেয়ার ব্লগ' : 'RUPOSHI BEAUTY & AUTHENTICITY BLOG',
                        style: const TextStyle(
                          color: AppTheme.gold300,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.isBangla
                          ? 'সৌন্দর্য চর্চা ও আসল প্রসাধনী নির্দেশিকা'
                          : 'Clinical Skincare Guides & Authenticity Insights',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.isBangla
                          ? 'আমাদের ডার্মাটোলজি ও কোয়ালিটি কন্ট্রোল টিমের লেখা পরামর্শ ও বিশ্লেষণ।'
                          : 'Expert advice from our Dhaka quality verification team on authentic formulations and routine building.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Blog Grid (Adaptive for Mobile, Tablet, Desktop)
              LayoutBuilder(
                builder: (context, constraints) {
                  final available = constraints.maxWidth;
                  final double cardWidth;
                  if (available < 650) {
                    cardWidth = available;
                  } else if (available < 1050) {
                    cardWidth = (available - 20) / 2;
                  } else {
                    cardWidth = (available - 2 * 24) / 3;
                  }

                  return Wrap(
                    spacing: available < 1050 ? 20 : 24,
                    runSpacing: 24,
                    children: sampleArticles.map((article) {
                      return Container(
                        width: cardWidth,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          child: Image.network(
                            article.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.rose50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        article.category,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.rose700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    article.readTime,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                state.isBangla ? article.titleBn : article.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.5,
                                  height: 1.35,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                article.summary,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () => _showArticleDialog(context, article, state.isBangla),
                                child: Row(
                                  children: [
                                    Text(
                                      state.isBangla ? 'সম্পূর্ণ পড়ুন' : 'Read Full Guide',
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.rose600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.rose600),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

  void _showArticleDialog(BuildContext context, BlogArticle article, bool isBangla) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(isBangla ? article.titleBn : article.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(article.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 14),
              Text(
                'Published ${article.date} • ${article.category}',
                style: const TextStyle(fontSize: 12, color: AppTheme.rose700, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                article.content,
                style: const TextStyle(fontSize: 14, height: 1.6, color: AppTheme.textDark),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
