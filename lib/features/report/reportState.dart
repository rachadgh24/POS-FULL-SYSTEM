import 'package:localmartpro/features/report/report.dart';

class Reportstate {
  final List<Report> reports;
  final String? error;
  Reportstate({required this.reports, required this.error});
  Reportstate copyWith({List<Report>? reports, String? error}) {
    return Reportstate(
      reports: reports ?? this.reports,
      error: error ?? this.error,
    );
  }
}
