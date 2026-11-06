import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/finance/ledger.dart';
import '../../../core/money/money.dart';
import '../../../core/money/money_format.dart';
import '../../../data/models/enums.dart';
import 'report_data.dart';

/// Font bytes passed into the isolate (Roboto supports Latin + Cyrillic).
class ReportFonts {
  const ReportFonts(this.regular, this.bold);
  final ByteData regular;
  final ByteData bold;
}

/// Builds the PDF report. Pure function – safe to run in a background isolate.
Future<Uint8List> buildPdfReport(
  ReportData d,
  ReportLabels l,
  ReportFonts fonts,
) async {
  final regular = pw.Font.ttf(fonts.regular);
  final bold = pw.Font.ttf(fonts.bold);
  final fmt = MoneyFormat(l.locale);
  final dateFmt = DateFormat.yMMMd(l.locale);
  final dateTimeFmt = DateFormat.yMMMd(l.locale).add_Hm();

  const primary = PdfColor.fromInt(0xFF6957E8);
  const income = PdfColor.fromInt(0xFF149C71);
  const expense = PdfColor.fromInt(0xFFE84F69);
  const muted = PdfColor.fromInt(0xFF7C8494);
  const line = PdfColor.fromInt(0xFFE2E5EE);
  const soft = PdfColor.fromInt(0xFFF6F7FB);

  // Roboto has no U+02BB; map Uzbek ʻ to the visually identical ‘.
  String t(String s) => s.replaceAll('ʻ', '‘').replaceAll('ʼ', '’');
  String money(Money m) => t(fmt.format(m));
  String sum(ConvertedSum cs) {
    final base = money(cs.money);
    final extra = cs.unconverted.toMoneyList();
    return extra.isEmpty ? base : '$base + ${extra.map(money).join(' + ')}*';
  }

  final doc = pw.Document(
    title: 'HisobAI ${l['report']}',
    author: 'HisobAI',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  pw.Widget kpi(String label, String value, PdfColor color) => pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: soft,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            t(label),
            style: const pw.TextStyle(fontSize: 9, color: muted),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );

  pw.Widget section(String title) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 18, bottom: 8),
    child: pw.Text(
      t(title),
      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
    ),
  );

  final headerStyle = pw.TextStyle(
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.white,
  );
  const cellStyle = pw.TextStyle(fontSize: 8.5);

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 40),
      header: (ctx) => ctx.pageNumber == 1
          ? pw.SizedBox()
          : pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text(
                'HisobAI · ${t(l['report'])}',
                style: const pw.TextStyle(fontSize: 8, color: muted),
              ),
            ),
      footer: (ctx) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            t('${l['generated']}: ${dateTimeFmt.format(d.generatedAt)}'),
            style: const pw.TextStyle(fontSize: 8, color: muted),
          ),
          pw.Text(
            '${ctx.pageNumber} / ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: muted),
          ),
        ],
      ),
      build: (ctx) => [
        // Branding header
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(
            color: primary,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'HisobAI',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      t(l['financialReport']),
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    t(l['reportPeriod']),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    '${dateFmt.format(d.period.start)} – ${dateFmt.format(d.period.lastDay)}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    '${t(l['currency'])}: ${d.currency.code}',
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Row(
          children: [
            kpi(l['income'], sum(d.income), income),
            pw.SizedBox(width: 8),
            kpi(l['expenses'], sum(d.expense), expense),
            pw.SizedBox(width: 8),
            kpi(
              l['netCashFlow'],
              sum(d.net),
              d.net.minor >= 0 ? income : expense,
            ),
          ],
        ),
        if (!d.income.isComplete || !d.expense.isComplete)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Text(
              t('* ${l['unconvertedNote']}'),
              style: const pw.TextStyle(fontSize: 8, color: muted),
            ),
          ),
        if (d.isEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 24),
            child: pw.Text(
              t(l['noData']),
              style: const pw.TextStyle(color: muted),
            ),
          ),
        if (d.categories.isNotEmpty) ...[
          section(l['categoryBreakdown']),
          pw.TableHelper.fromTextArray(
            headerStyle: headerStyle,
            headerDecoration: const pw.BoxDecoration(color: primary),
            cellStyle: cellStyle,
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: line, width: 0.5)),
            ),
            cellAlignments: {
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            headers: [
              l['category'],
              l['type'],
              l['count'],
              l['share'],
              l['amount'],
            ].map(t).toList(),
            data: [
              for (final c in d.categories)
                [
                  t(c.name),
                  t(
                    c.type == TransactionType.income
                        ? l['income']
                        : l['expenses'],
                  ),
                  '${c.count}',
                  '${(c.share * 100).toStringAsFixed(1)}%',
                  money(c.amount),
                ],
            ],
          ),
        ],
        if (d.budgets.isNotEmpty) ...[
          section(
            '${l['budgetOverview']} (${DateFormat.yMMMM(l.locale).format(d.budgetMonth)})',
          ),
          pw.TableHelper.fromTextArray(
            headerStyle: headerStyle,
            headerDecoration: const pw.BoxDecoration(color: primary),
            cellStyle: cellStyle,
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: line, width: 0.5)),
            ),
            cellAlignments: {
              1: pw.Alignment.centerRight,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            headers: [
              l['budget'],
              l['limit'],
              l['spent'],
              l['remaining'],
              l['used'],
            ].map(t).toList(),
            data: [
              for (final b in d.budgets)
                [
                  t(b.name.isEmpty ? l['totalBudget'] : b.name),
                  money(b.limit),
                  money(b.spent),
                  money(b.remaining),
                  '${(b.ratio * 100).round()}%',
                ],
            ],
          ),
        ],
        if (d.rows.isNotEmpty) ...[
          section('${l['transactions']} (${d.rows.length})'),
          pw.TableHelper.fromTextArray(
            headerStyle: headerStyle,
            headerDecoration: const pw.BoxDecoration(color: primary),
            cellStyle: cellStyle,
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: line, width: 0.5)),
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(62),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.6),
              4: const pw.FlexColumnWidth(2),
            },
            cellAlignments: {4: pw.Alignment.centerRight},
            headers: [
              l['date'],
              l['title'],
              l['category'],
              l['paymentMethod'],
              l['amount'],
            ].map(t).toList(),
            data: [
              for (final r in d.rows)
                [
                  dateFmt.format(r.date),
                  t(r.title),
                  t(r.category),
                  t(r.paymentMethod),
                  '${r.type == TransactionType.income ? '+' : '−'}${money(r.amount)}',
                ],
            ],
          ),
        ],
        if (d.rates.isNotEmpty) ...[
          section(l['ratesUsed']),
          for (final q in d.rates.reversed.take(5))
            pw.Text(
              t(
                '1 ${q.base.code} = ${q.rate} ${q.quote.code} · ${dateFmt.format(q.effectiveDate)} · ${q.source}',
              ),
              style: const pw.TextStyle(fontSize: 8.5, color: muted),
            ),
          pw.SizedBox(height: 4),
          pw.Text(
            t(l['conversionPolicy']),
            style: const pw.TextStyle(fontSize: 8, color: muted),
          ),
        ],
      ],
    ),
  );
  return doc.save();
}
