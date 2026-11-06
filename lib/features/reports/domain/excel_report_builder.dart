import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import '../../../core/money/money.dart';
import '../../../data/models/enums.dart';
import 'report_data.dart';

/// Builds the Excel workbook with Summary, Transactions, Categories and
/// Budget sheets. Amounts are written as numbers (major units) so they can be
/// used in formulas; the currency is a separate column.
Uint8List buildExcelReport(ReportData d, ReportLabels l) {
  final excel = Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
  final dateFmt = DateFormat('yyyy-MM-dd');
  final header = CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.fromHexString('#6957E8'),
    fontColorHex: ExcelColor.white,
  );
  final titleStyle = CellStyle(bold: true, fontSize: 14);

  CellValue txt(String s) => TextCellValue(s);
  CellValue num(Money m) => DoubleCellValue(m.major);

  void headerRow(Sheet sheet, List<String> cols) {
    sheet.appendRow([for (final c in cols) txt(c)]);
    final r = sheet.maxRows - 1;
    for (var i = 0; i < cols.length; i++) {
      sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: r))
              .cellStyle =
          header;
    }
  }

  // Summary
  final summaryName = l['summary'];
  excel.rename(defaultSheet, summaryName);
  final summary = excel[summaryName];
  summary.appendRow([txt('HisobAI — ${l['financialReport']}')]);
  summary
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .cellStyle =
      titleStyle;
  summary.appendRow([
    txt(l['reportPeriod']),
    txt(
      '${dateFmt.format(d.period.start)} – ${dateFmt.format(d.period.lastDay)}',
    ),
  ]);
  summary.appendRow([txt(l['currency']), txt(d.currency.code)]);
  summary.appendRow([
    txt(l['generated']),
    txt(DateFormat('yyyy-MM-dd HH:mm').format(d.generatedAt)),
  ]);
  summary.appendRow([]);
  headerRow(summary, [l['metric'], l['amount'], l['currency']]);
  summary.appendRow([
    txt(l['income']),
    num(d.income.money),
    txt(d.currency.code),
  ]);
  summary.appendRow([
    txt(l['expenses']),
    num(d.expense.money),
    txt(d.currency.code),
  ]);
  summary.appendRow([
    txt(l['netCashFlow']),
    num(d.net.money),
    txt(d.currency.code),
  ]);
  summary.appendRow([txt(l['transactions']), IntCellValue(d.rows.length)]);
  for (final m in [
    ...d.income.unconverted.toMoneyList(),
    ...d.expense.unconverted.toMoneyList(),
  ]) {
    summary.appendRow([
      txt('${l['unconverted']} (${m.currency.code})'),
      num(m),
      txt(m.currency.code),
    ]);
  }
  if (d.rates.isNotEmpty) {
    summary.appendRow([]);
    headerRow(summary, [l['ratesUsed'], l['rate'], l['date'], l['source']]);
    for (final q in d.rates) {
      summary.appendRow([
        txt('1 ${q.base.code} → ${q.quote.code}'),
        DoubleCellValue(q.rate),
        txt(dateFmt.format(q.effectiveDate)),
        txt(q.source),
      ]);
    }
  }
  summary.setColumnWidth(0, 28);
  summary.setColumnWidth(1, 20);

  // Transactions
  final txSheet = excel[l['transactions']];
  headerRow(txSheet, [
    l['date'],
    l['title'],
    l['type'],
    l['category'],
    l['paymentMethod'],
    l['amount'],
    l['currency'],
    '${l['amount']} (${d.currency.code})',
    l['description'],
  ]);
  for (final r in d.rows) {
    txSheet.appendRow([
      txt(dateFmt.format(r.date)),
      txt(r.title),
      txt(r.type == TransactionType.income ? l['income'] : l['expenses']),
      txt(r.category),
      txt(r.paymentMethod),
      DoubleCellValue(
        r.type == TransactionType.income ? r.amount.major : -r.amount.major,
      ),
      txt(r.amount.currency.code),
      r.converted == null
          ? txt('—')
          : DoubleCellValue(
              r.type == TransactionType.income
                  ? r.converted!.major
                  : -r.converted!.major,
            ),
      txt(r.description ?? ''),
    ]);
  }
  txSheet.setColumnWidth(1, 30);
  txSheet.setColumnWidth(3, 18);

  // Categories
  final catSheet = excel[l['categoryBreakdown']];
  headerRow(catSheet, [
    l['category'],
    l['type'],
    l['count'],
    l['share'],
    '${l['amount']} (${d.currency.code})',
  ]);
  for (final c in d.categories) {
    catSheet.appendRow([
      txt(c.name),
      txt(c.type == TransactionType.income ? l['income'] : l['expenses']),
      IntCellValue(c.count),
      DoubleCellValue(double.parse((c.share * 100).toStringAsFixed(2))),
      num(c.amount),
    ]);
  }
  catSheet.setColumnWidth(0, 24);

  // Budget
  final budgetSheet = excel[l['budget']];
  budgetSheet.appendRow([
    txt(
      '${l['budgetOverview']} — ${DateFormat.yMMMM(l.locale).format(d.budgetMonth)}',
    ),
  ]);
  headerRow(budgetSheet, [
    l['budget'],
    l['limit'],
    l['spent'],
    l['remaining'],
    l['used'],
    l['currency'],
  ]);
  for (final b in d.budgets) {
    budgetSheet.appendRow([
      txt(b.name.isEmpty ? l['totalBudget'] : b.name),
      num(b.limit),
      num(b.spent),
      num(b.remaining),
      DoubleCellValue(double.parse((b.ratio * 100).toStringAsFixed(1))),
      txt(b.limit.currency.code),
    ]);
  }
  budgetSheet.setColumnWidth(0, 24);

  excel.setDefaultSheet(summaryName);
  final bytes = excel.encode();
  if (bytes == null) throw StateError('Excel encoding failed');
  return Uint8List.fromList(bytes);
}
