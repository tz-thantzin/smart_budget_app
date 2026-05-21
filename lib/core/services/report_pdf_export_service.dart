import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:budget_app/domain/entities/enums.dart';
import 'package:budget_app/domain/entities/transaction_entity.dart';

class ReportPdfExportStrings {
  const ReportPdfExportStrings({
    required this.reportTitle,
    required this.summarySection,
    required this.transactionsSection,
    required this.periodLabel,
    required this.generatedAtLabel,
    required this.totalExpenseLabel,
    required this.totalIncomeLabel,
    required this.netLabel,
    required this.transactionCountLabel,
    required this.dateLabel,
    required this.titleLabel,
    required this.categoryLabel,
    required this.noteLabel,
    required this.amountLabel,
    required this.typeLabel,
    required this.unknownCategoryLabel,
    required this.expenseLabel,
    required this.incomeLabel,
  });

  final String reportTitle;
  final String summarySection;
  final String transactionsSection;
  final String periodLabel;
  final String generatedAtLabel;
  final String totalExpenseLabel;
  final String totalIncomeLabel;
  final String netLabel;
  final String transactionCountLabel;
  final String dateLabel;
  final String titleLabel;
  final String categoryLabel;
  final String noteLabel;
  final String amountLabel;
  final String typeLabel;
  final String unknownCategoryLabel;
  final String expenseLabel;
  final String incomeLabel;
}

class ReportPdfExportService {
  const ReportPdfExportService();

  Future<String> exportReport({
    required String periodSubtitle,
    required DateTime startDate,
    required DateTime endDate,
    required String localeTag,
    required String currencyCode,
    required int currencyDecimalDigits,
    required List<TransactionEntity> transactions,
    required Map<String, String> categoryNames,
    required double totalExpense,
    required double totalIncome,
    required double net,
    required ReportPdfExportStrings strings,
  }) async {
    final filtered = transactions
        .where((t) {
          final date = _dateOnly(t.dateTime);
          return !date.isBefore(_dateOnly(startDate)) &&
              !date.isAfter(_dateOnly(endDate));
        })
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final regular = pw.Font.helvetica();
    final bold = pw.Font.helveticaBold();

    final primaryColor = PdfColor.fromHex('0E7C66');
    const rowAltColor = PdfColor.fromInt(0xFFF5F7F6);
    final dateFormat = DateFormat.yMMMd(localeTag);
    final decimalPart = currencyDecimalDigits > 0
        ? '.${'0' * currencyDecimalDigits}'
        : '';
    final amountFmt = NumberFormat('#,##0$decimalPart');

    String fmt(double amount) => '$currencyCode ${amountFmt.format(amount)}';

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        build: (ctx) => [
          _header(
            primaryColor: primaryColor,
            reportTitle: strings.reportTitle,
            periodSubtitle: periodSubtitle,
            bold: bold,
            regular: regular,
          ),
          pw.SizedBox(height: 24),
          _summary(
            strings: strings,
            startDate: startDate,
            endDate: endDate,
            totalExpense: totalExpense,
            totalIncome: totalIncome,
            net: net,
            transactionCount: filtered.length,
            fmt: fmt,
            dateFormat: dateFormat,
            primaryColor: primaryColor,
            bold: bold,
            regular: regular,
          ),
          pw.SizedBox(height: 24),
          _transactionsTable(
            strings: strings,
            transactions: filtered,
            categoryNames: categoryNames,
            fmt: fmt,
            dateFormat: dateFormat,
            primaryColor: primaryColor,
            rowAltColor: rowAltColor,
            bold: bold,
            regular: regular,
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final fileName = _buildFileName(periodSubtitle, startDate, endDate);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, fileName));
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
        subject: strings.reportTitle,
        title: strings.reportTitle,
      ),
    );

    return fileName;
  }

  pw.Widget _header({
    required PdfColor primaryColor,
    required String reportTitle,
    required String periodSubtitle,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    return pw.Container(
      width: double.infinity,
      color: primaryColor,
      padding: const pw.EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Smart Budget',
            style: pw.TextStyle(
              font: bold,
              fontSize: 9,
              color: PdfColors.white,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            reportTitle,
            style: pw.TextStyle(
              font: bold,
              fontSize: 22,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            periodSubtitle,
            style: pw.TextStyle(
              font: regular,
              fontSize: 12,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _summary({
    required ReportPdfExportStrings strings,
    required DateTime startDate,
    required DateTime endDate,
    required double totalExpense,
    required double totalIncome,
    required double net,
    required int transactionCount,
    required String Function(double) fmt,
    required DateFormat dateFormat,
    required PdfColor primaryColor,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel(strings.summarySection, primaryColor, bold),
        pw.SizedBox(height: 8),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: const PdfColor.fromInt(0xFFF5F7F6),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            children: [
              _summaryRow(
                strings.periodLabel,
                '${dateFormat.format(startDate)} – ${dateFormat.format(endDate)}',
                bold,
                regular,
              ),
              _summaryRow(
                strings.generatedAtLabel,
                DateFormat.yMMMd().add_jm().format(DateTime.now()),
                bold,
                regular,
              ),
              pw.Divider(color: PdfColors.grey300, height: 20),
              _summaryRow(
                strings.totalExpenseLabel,
                fmt(totalExpense),
                bold,
                regular,
                valueColor: PdfColor.fromHex('E35D4F'),
              ),
              _summaryRow(
                strings.totalIncomeLabel,
                fmt(totalIncome),
                bold,
                regular,
                valueColor: PdfColor.fromHex('1B9E77'),
              ),
              _summaryRow(
                strings.netLabel,
                fmt(net),
                bold,
                regular,
              ),
              _summaryRow(
                strings.transactionCountLabel,
                '$transactionCount',
                bold,
                regular,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _transactionsTable({
    required ReportPdfExportStrings strings,
    required List<TransactionEntity> transactions,
    required Map<String, String> categoryNames,
    required String Function(double) fmt,
    required DateFormat dateFormat,
    required PdfColor primaryColor,
    required PdfColor rowAltColor,
    required pw.Font bold,
    required pw.Font regular,
  }) {
    if (transactions.isEmpty) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _sectionLabel(strings.transactionsSection, primaryColor, bold),
          pw.SizedBox(height: 8),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: const PdfColor.fromInt(0xFFF5F7F6),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              border: pw.Border.all(color: PdfColors.grey300),
            ),
            child: pw.Text(
              '–',
              style: pw.TextStyle(font: regular, fontSize: 11),
            ),
          ),
        ],
      );
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionLabel(strings.transactionsSection, primaryColor, bold),
        pw.SizedBox(height: 8),
        pw.Table(
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(3),
            2: const pw.FlexColumnWidth(2),
            3: const pw.FlexColumnWidth(2),
            4: const pw.FlexColumnWidth(1.5),
          },
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: primaryColor),
              children: [
                _tableHeaderCell(strings.dateLabel, bold),
                _tableHeaderCell(strings.titleLabel, bold),
                _tableHeaderCell(strings.categoryLabel, bold),
                _tableHeaderCell(strings.amountLabel, bold),
                _tableHeaderCell(strings.typeLabel, bold),
              ],
            ),
            for (var i = 0; i < transactions.length; i++)
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: i.isOdd ? rowAltColor : PdfColors.white,
                ),
                children: [
                  _tableDataCell(
                    dateFormat.format(transactions[i].dateTime),
                    regular,
                  ),
                  _tableDataCell(transactions[i].title, regular),
                  _tableDataCell(
                    categoryNames[transactions[i].categoryId] ??
                        strings.unknownCategoryLabel,
                    regular,
                  ),
                  _tableDataCell(
                    fmt(transactions[i].amount),
                    regular,
                    color: transactions[i].type == TransactionType.expense
                        ? PdfColor.fromHex('E35D4F')
                        : PdfColor.fromHex('1B9E77'),
                  ),
                  _tableDataCell(
                    transactions[i].type == TransactionType.expense
                        ? strings.expenseLabel
                        : strings.incomeLabel,
                    regular,
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  pw.Widget _sectionLabel(String label, PdfColor color, pw.Font bold) {
    return pw.Text(
      label.toUpperCase(),
      style: pw.TextStyle(
        font: bold,
        fontSize: 9,
        color: color,
        letterSpacing: 1.5,
      ),
    );
  }

  pw.Widget _summaryRow(
    String label,
    String value,
    pw.Font bold,
    pw.Font regular, {
    PdfColor? valueColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: regular,
              fontSize: 11,
              color: PdfColors.grey700,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              font: bold,
              fontSize: 11,
              color: valueColor ?? PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _tableHeaderCell(String text, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.white),
      ),
    );
  }

  pw.Widget _tableDataCell(
    String text,
    pw.Font regular, {
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: regular,
          fontSize: 8.5,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  String _buildFileName(
    String periodSubtitle,
    DateTime startDate,
    DateTime endDate,
  ) {
    final safeTitle = periodSubtitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final range =
        '${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}';
    return 'report_${safeTitle.isEmpty ? 'period' : safeTitle}_$range.pdf';
  }
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);
