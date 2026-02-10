import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmartpro/features/auth/AuthController.dart';

import 'package:localmartpro/features/report/report.dart';
import 'package:localmartpro/features/report/reportState.dart';
// import 'package:uuid/uuid.dart';

class Reportcontroller extends StateNotifier<Reportstate> {
  Ref ref;

  Reportcontroller(this.ref) : super(Reportstate(reports: [], error: null)) {
    loadReports();
  }

  List<Report> allReports = [];
  void loadReports() {
    FirebaseFirestore.instance
        .collection('reports')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snap) {
          final reports = snap.docs.map((e) {
            final data = e.data();
            return Report(
              id: e.id,
              date: data['date'],
              total: data['total'],
              items: (data['reportList'] as List<dynamic>),
              name: data['name'],
              role: data['role'],
            );
          }).toList();

          state = state.copyWith(reports: reports, error: null);
          allReports = reports;
        });
  }

  // final authState = ref.watch(authControllerProvider);
  Future<void> newReport(
    String id,
    dynamic date,
    double total,
    List items,
  ) async {
    try {
      final role = ref.read(authControllerProvider).role ?? 'user';
      final name = ref.read(authControllerProvider).name ?? 'unknown';
      final itemMaps = items.map((e) {
        final prod = e;
        return {
          'productId': prod.id ?? '',
          'productName': prod.name ?? '',
          'qty': 1,
          'price': prod.price ?? 0.0,
        };
      }).toList();

      final newrep = Report(
        id: id,
        date: date,
        total: total,
        items: itemMaps,
        name: name,
        role: role,
      );
      state = state.copyWith(reports: [...state.reports, newrep], error: null);

      await FirebaseFirestore.instance.collection('reports').add({
        'id': id,
        'date': date,
        'total': total,
        'reportList': itemMaps,
        'role': role,
        'name': name,
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteReport(String id) async {
    await FirebaseFirestore.instance.collection('reports').doc(id).delete();
    state = state.copyWith(
      reports: state.reports.where((e) => e.id != id).toList(),
    );
  }
}

final reportControllerProvider =
    StateNotifierProvider<Reportcontroller, Reportstate>(
      (ref) => Reportcontroller(ref),
    );
