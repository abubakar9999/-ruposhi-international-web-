import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../admin/admin_models.dart';
import 'file_saver/file_saver.dart';

class InvoiceService {
  static const PdfColor rose950 = PdfColor.fromInt(0xFF4A0E17);
  static const PdfColor rose900 = PdfColor.fromInt(0xFF881337);
  static const PdfColor gold600 = PdfColor.fromInt(0xFFD97706);
  static const PdfColor gold100 = PdfColor.fromInt(0xFFFEF3C7);
  static const PdfColor softBg = PdfColor.fromInt(0xFFFDF8F6);
  static const PdfColor textDark = PdfColor.fromInt(0xFF1E293B);

  /// Generates a PDF invoice document for a confirmed order
  static Future<Uint8List> generateInvoicePdf(
    AdminOrder order, {
    String? couponCode,
    double discountAmount = 0,
  }) async {
    final pdf = pw.Document(
      title: 'Ruposhi Invoice ${order.orderId}',
      author: 'Ruposhi International',
    );

    final fontRegular = pw.Font.helvetica();
    final fontBold = pw.Font.helveticaBold();
    final fontOblique = pw.Font.helveticaOblique();

    final dateFormatted = DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // ==========================================
              // HEADER ROW (Brand Title + Invoice Badge)
              // ==========================================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'RUPOSHI INTERNATIONAL',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 22,
                          color: rose950,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        '100% Authentic Imported Luxury Cosmetics & Skincare',
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 9.5,
                          color: gold600,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Central Logistics Hub | Dhaka, Bangladesh | BIN: 004128912-0101',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 8.5,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Text(
                        'Hotline: +880 1700-000000 | Email: concierge@ruposhi.com',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 8.5,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: pw.BoxDecoration(
                      color: softBg,
                      border: pw.Border.all(color: rose900, width: 1.2),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'OFFICIAL TAX INVOICE',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 10,
                            color: rose900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          order.orderId,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 13,
                            color: rose950,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Status: ${order.status.toUpperCase()}',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 8,
                            color: PdfColors.green800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 14),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 10),

              // ==========================================
              // INVOICE METADATA & CUSTOMER DETAILS
              // ==========================================
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Customer Billing Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColors.grey200),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILLED & SHIPPED TO:',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: rose900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            order.customerName.isNotEmpty ? order.customerName : 'Valued Customer',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 11,
                              color: textDark,
                            ),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Mobile: ${order.customerPhone}',
                            style: pw.TextStyle(font: fontRegular, fontSize: 9.5),
                          ),
                          pw.SizedBox(height: 2),
                          pw.Text(
                            'Address: ${order.customerAddress}, ${order.city}',
                            style: pw.TextStyle(font: fontRegular, fontSize: 9.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 14),
                  // Order Details
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        borderRadius: pw.BorderRadius.circular(6),
                        border: pw.Border.all(color: PdfColors.grey200),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ORDER INFORMATION:',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: rose900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Date & Time:', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                              pw.Text(dateFormatted, style: pw.TextStyle(font: fontBold, fontSize: 9)),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Payment Mode:', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                              pw.Text(order.paymentMethod, style: pw.TextStyle(font: fontBold, fontSize: 9)),
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Courier Logistics:', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                              pw.Text(
                                order.courier != null && order.courier!.isNotEmpty ? order.courier! : 'Cold-Chain Express',
                                style: pw.TextStyle(font: fontBold, fontSize: 9),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 18),

              // ==========================================
              // ITEM TABLE
              // ==========================================
              pw.Container(
                decoration: const pw.BoxDecoration(
                  color: rose950,
                  borderRadius: pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
                ),
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 28,
                      child: pw.Text('#', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 9)),
                    ),
                    pw.Expanded(
                      flex: 5,
                      child: pw.Text('Item Description & Shade', style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 9)),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 9)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('Unit Price', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 9)),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text('Total (BDT)', textAlign: pw.TextAlign.right, style: pw.TextStyle(font: fontBold, color: PdfColors.white, fontSize: 9)),
                    ),
                  ],
                ),
              ),

              // Table Rows
              ...order.items.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final item = entry.value;
                final name = item['name']?.toString() ?? 'Imported Cosmetic Item';
                final qty = (item['quantity'] as num?)?.toInt() ?? 1;
                final unitPrice = (item['price'] as num?)?.toDouble() ?? 0.0;
                final lineTotal = unitPrice * qty;
                final isEven = entry.key % 2 == 0;

                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : softBg,
                    border: const pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                      left: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                      right: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.SizedBox(
                        width: 28,
                        child: pw.Text('$index', style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      ),
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text(
                          name,
                          style: pw.TextStyle(font: fontBold, fontSize: 9, color: textDark),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text('$qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(font: fontRegular, fontSize: 9)),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          '${unitPrice.toStringAsFixed(0)} BDT',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(font: fontRegular, fontSize: 9),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          '${lineTotal.toStringAsFixed(0)} BDT',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(font: fontBold, fontSize: 9, color: rose950),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 12),

              // ==========================================
              // TOTALS BREAKDOWN
              // ==========================================
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Authenticity Seal Card on Left
                  pw.Expanded(
                    flex: 5,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        color: gold100,
                        border: pw.Border.all(color: gold600, width: 0.8),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            '200% AUTHENTICITY ASSURANCE',
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 9,
                              color: rose950,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            'All products in this invoice have passed cold-chain laboratory compliance, BSTI quality verification, and Bangladesh Customs clearance seals.',
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 8,
                              color: PdfColors.brown900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Financial Breakdown on Right
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        _pdfAmountRow('Subtotal', '${order.subtotal.toStringAsFixed(0)} BDT', fontRegular, fontBold),
                        if (discountAmount > 0)
                          _pdfAmountRow(
                            'Promo Discount (${couponCode ?? 'Coupon'})',
                            '-${discountAmount.toStringAsFixed(0)} BDT',
                            fontRegular,
                            fontBold,
                            color: PdfColors.green800,
                          ),
                        _pdfAmountRow(
                          'Delivery Fee',
                          order.deliveryFee == 0 ? 'FREE' : '${order.deliveryFee.toStringAsFixed(0)} BDT',
                          fontRegular,
                          fontBold,
                        ),
                        pw.Divider(color: rose950, thickness: 1),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Grand Total:',
                              style: pw.TextStyle(font: fontBold, fontSize: 12, color: rose950),
                            ),
                            pw.Text(
                              '${order.grandTotal.toStringAsFixed(0)} BDT',
                              style: pw.TextStyle(font: fontBold, fontSize: 13, color: rose950),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.Spacer(),

              // ==========================================
              // FOOTER / SIGN-OFF
              // ==========================================
              pw.Divider(color: PdfColors.grey300),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Thank you for shopping with Ruposhi International!',
                    style: pw.TextStyle(font: fontOblique, fontSize: 8.5, color: PdfColors.grey700),
                  ),
                  pw.Text(
                    'Computer Generated Invoice | No Signature Required',
                    style: pw.TextStyle(font: fontRegular, fontSize: 8, color: PdfColors.grey600),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _pdfAmountRow(
    String label,
    String amount,
    pw.Font fontRegular,
    pw.Font fontBold, {
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(font: fontRegular, fontSize: 9.5, color: color ?? textDark)),
          pw.Text(amount, style: pw.TextStyle(font: fontBold, fontSize: 9.5, color: color ?? textDark)),
        ],
      ),
    );
  }

  /// Triggers direct automatic file download in the browser or saves to disk
  static Future<bool> downloadInvoice(
    AdminOrder order, {
    String? couponCode,
    double discountAmount = 0,
  }) async {
    try {
      final bytes = await generateInvoicePdf(
        order,
        couponCode: couponCode,
        discountAmount: discountAmount,
      );
      final fileName = 'Ruposhi_Invoice_${order.orderId}.pdf';
      saveFile(bytes, fileName, mimeType: 'application/pdf');
      return true;
    } catch (_) {
      return false;
    }
  }
}
