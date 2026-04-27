import 'dart:io';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/enums.dart';
import '../../domain/entities/transaction_entity.dart';

class ReportExcelExportStrings {
  const ReportExcelExportStrings({
    required this.summarySheetName,
    required this.transactionsSheetName,
    required this.periodLabel,
    required this.generatedAtLabel,
    required this.totalSpentLabel,
    required this.transactionCountLabel,
    required this.dateLabel,
    required this.titleLabel,
    required this.categoryLabel,
    required this.noteLabel,
    required this.amountLabel,
    required this.currencyLabel,
    required this.typeLabel,
    required this.unknownCategoryLabel,
    required this.expenseLabel,
    required this.incomeLabel,
  });

  final String summarySheetName;
  final String transactionsSheetName;
  final String periodLabel;
  final String generatedAtLabel;
  final String totalSpentLabel;
  final String transactionCountLabel;
  final String dateLabel;
  final String titleLabel;
  final String categoryLabel;
  final String noteLabel;
  final String amountLabel;
  final String currencyLabel;
  final String typeLabel;
  final String unknownCategoryLabel;
  final String expenseLabel;
  final String incomeLabel;
}

class ReportExcelExportService {
  const ReportExcelExportService();

  Future<String> exportExpenseReport({
    required String reportTitle,
    required String periodTitle,
    required String periodSubtitle,
    required DateTime startDate,
    required DateTime endDate,
    required String localeTag,
    required List<TransactionEntity> transactions,
    required Map<String, String> categoryNames,
    required ReportExcelExportStrings strings,
  }) async {
    final excel = Excel.createExcel();
    final summarySheet = excel[strings.summarySheetName];
    final transactionsSheet = excel[strings.transactionsSheetName];
    final defaultSheet = excel.getDefaultSheet();
    if (defaultSheet != null &&
        defaultSheet != strings.summarySheetName &&
        defaultSheet != strings.transactionsSheetName) {
      excel.delete(defaultSheet);
    }

    final filteredTransactions =
        transactions
            .where((transaction) => transaction.type == TransactionType.expense)
            .where((transaction) {
              final date = _dateOnly(transaction.dateTime);
              return !date.isBefore(_dateOnly(startDate)) &&
                  !date.isAfter(_dateOnly(endDate));
            })
            .toList()
          ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final totalSpent = filteredTransactions.fold<double>(
      0,
      (sum, transaction) => sum + transaction.amount,
    );

    summarySheet.appendRow([
      TextCellValue(reportTitle),
      TextCellValue(periodTitle),
    ]);
    summarySheet.appendRow([
      TextCellValue(strings.periodLabel),
      TextCellValue(periodSubtitle),
    ]);
    summarySheet.appendRow([
      TextCellValue(strings.generatedAtLabel),
      TextCellValue(
        DateFormat.yMMMd(localeTag).add_jm().format(DateTime.now()),
      ),
    ]);
    summarySheet.appendRow([
      TextCellValue(strings.totalSpentLabel),
      DoubleCellValue(totalSpent),
    ]);
    summarySheet.appendRow([
      TextCellValue(strings.transactionCountLabel),
      IntCellValue(filteredTransactions.length),
    ]);

    transactionsSheet.appendRow([
      TextCellValue(strings.dateLabel),
      TextCellValue(strings.titleLabel),
      TextCellValue(strings.categoryLabel),
      TextCellValue(strings.noteLabel),
      TextCellValue(strings.amountLabel),
      TextCellValue(strings.currencyLabel),
      TextCellValue(strings.typeLabel),
    ]);

    final dateFormat = DateFormat.yMMMd(localeTag).add_jm();
    for (final transaction in filteredTransactions) {
      transactionsSheet.appendRow([
        TextCellValue(dateFormat.format(transaction.dateTime)),
        TextCellValue(transaction.title),
        TextCellValue(
          categoryNames[transaction.categoryId] ?? strings.unknownCategoryLabel,
        ),
        TextCellValue(transaction.note ?? ''),
        DoubleCellValue(transaction.amount),
        TextCellValue(transaction.currencyCode),
        TextCellValue(
          transaction.type == TransactionType.expense
              ? strings.expenseLabel
              : strings.incomeLabel,
        ),
      ]);
    }

    excel.setDefaultSheet(strings.summarySheetName);

    final bytes = excel.encode();
    if (bytes == null) {
      throw StateError('Failed to encode Excel workbook.');
    }

    final directory = await getTemporaryDirectory();
    final fileName = _buildFileName(periodTitle, startDate, endDate);
    final file = File(p.join(directory.path, fileName));
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: _xlsxMimeType, name: fileName)],
        subject: reportTitle,
        title: reportTitle,
      ),
    );

    return fileName;
  }

  String _buildFileName(
    String periodTitle,
    DateTime startDate,
    DateTime endDate,
  ) {
    final safeTitle = periodTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final range =
        '${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}';
    return 'expense_report_${safeTitle.isEmpty ? 'period' : safeTitle}_$range.xlsx';
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

const _xlsxMimeType =
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
