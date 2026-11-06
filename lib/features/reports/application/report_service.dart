import 'dart:io';
import 'dart:isolate';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/l10n.dart';
import '../domain/excel_report_builder.dart';
import '../domain/pdf_report_builder.dart';
import '../domain/report_data.dart';

enum ReportFormat { pdf, excel }

class GeneratedReport {
  const GeneratedReport(this.bytes, this.fileName, this.mimeType);
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

/// Generates reports off the UI thread and shares / saves them.
///
/// Saving uses the system file dialog (Storage Access Framework on Android,
/// document picker on iOS), so no broad storage permission is required.
class ReportService {
  const ReportService();

  static ReportLabels labels(AppLocalizations l) => ReportLabels({
    'report': l.rptReport,
    'financialReport': l.rptFinancialReport,
    'generated': l.rptGenerated,
    'reportPeriod': l.rptPeriod,
    'currency': l.currency,
    'income': l.income,
    'expenses': l.expenses,
    'netCashFlow': l.netCashFlow,
    'unconvertedNote': l.rptUnconvertedNote,
    'unconverted': l.rptUnconverted,
    'noData': l.noDataForPeriod,
    'categoryBreakdown': l.rptCategoryBreakdown,
    'category': l.category,
    'type': l.rptType,
    'count': l.rptCount,
    'share': l.rptShare,
    'amount': l.amount,
    'budgetOverview': l.rptBudgetOverview,
    'budget': l.rptBudget,
    'limit': l.limit,
    'spent': l.spent,
    'remaining': l.remaining,
    'used': l.rptUsed,
    'totalBudget': l.allExpenses,
    'transactions': l.rptTransactions,
    'date': l.date,
    'title': l.title,
    'paymentMethod': l.paymentMethod,
    'description': l.description,
    'ratesUsed': l.rptRatesUsed,
    'rate': l.rptRate,
    'source': l.source,
    'conversionPolicy': l.conversionPolicyShort,
    'summary': l.rptSummary,
    'metric': l.rptMetric,
  }, l.localeName);

  static String fileName(ReportData d, ReportFormat f) {
    final df = DateFormat('yyyy-MM-dd');
    final ext = f == ReportFormat.pdf ? 'pdf' : 'xlsx';
    return 'HisobAI_Report_${df.format(d.period.start)}_${df.format(d.period.lastDay)}.$ext';
  }

  Future<GeneratedReport> generate(
    ReportData data,
    ReportFormat format,
    AppLocalizations l,
  ) async {
    final lbl = labels(l);
    final name = fileName(data, format);
    if (format == ReportFormat.pdf) {
      final fonts = ReportFonts(
        await rootBundle.load('assets/fonts/roboto-regular.ttf'),
        await rootBundle.load('assets/fonts/roboto-bold.ttf'),
      );
      final bytes = await Isolate.run(() => buildPdfReport(data, lbl, fonts));
      return GeneratedReport(bytes, name, 'application/pdf');
    }
    final bytes = await Isolate.run(() => buildExcelReport(data, lbl));
    return GeneratedReport(
      bytes,
      name,
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }

  Future<void> share(GeneratedReport r, {String? subject}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/${r.fileName}');
    await file.writeAsBytes(r.bytes, flush: true);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: r.mimeType)],
        subject: subject ?? r.fileName,
      ),
    );
  }

  /// Returns true if the user picked a location and the file was saved.
  Future<bool> save(GeneratedReport r) async {
    final uri = await FilePicker.saveFile(
      fileName: r.fileName,
      bytes: r.bytes,
      mimeType: r.mimeType,
    );
    return uri != null;
  }
}
