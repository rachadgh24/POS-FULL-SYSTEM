import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:localmartpro/features/dashboard/dashboardState.dart';
import 'package:localmartpro/features/products/ProductController.dart';
import 'package:localmartpro/features/products/ProductState.dart';

class DashboardController extends StateNotifier<DashboardState> {
  final Ref ref;
  DashboardController(this.ref)
    : super(
        DashboardState(
          revenue: 0,
          salesToday: 0,
          status: {},
          isLoading: false,
          error: null,
        ),
      ) {
    ref.watch(productControllerProvider.notifier).listenProducts();
  }
  
  //     {
  //   ref.listen<ProductsState>(productControllerProvider, (prev, next) {
  //     if (next.products.isNotEmpty) {
  //       prodsAndLeft();
  //       calculateRevenue();
  //     }
  //   });
  // }

  Future<double> calculateRevenue() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      double revenue = 0;
      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .get();
      final reports = snapshot.docs.map((e) => e.data()['total'] ?? 0).toList();
      for (int i = 0; i < reports.length; i++) {
        revenue += reports[i];
      }
      state = state.copyWith(isLoading: false);
      return revenue;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return 0;
    }
  }

  Future<double> calculateSalesLastWeek() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final start = DateTime.now().subtract(const Duration(days: 7));
      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .get();
      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['total'] ?? 0).toDouble();
      }
      state = state.copyWith(isLoading: false);
      return total;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return 0;
    }
  }

  Future<double> calculateSalesToday() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final day = DateTime(now.year, now.month, now.day);
      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(day))
          .get();
      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['total'] ?? 0).toDouble();
      }
      state = state.copyWith(isLoading: false);
      return total;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return 0;
    }
  }

  Future<double> calculateSalesYesterday() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);
      final startOfYesterday = startOfToday.subtract(const Duration(days: 1));

      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfYesterday),
          )
          .where('date', isLessThan: Timestamp.fromDate(startOfToday))
          .get();

      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['total'] ?? 0).toDouble();
      }
      state = state.copyWith(isLoading: false);
      return total;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return 0;
    }
  }

  Future<Map<String, bool>> stockAlert() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final Map<String, bool> productsState = {};
      final list = await ref.read(productControllerProvider).products;
      for (int i = 0; i < list.length; i++) {
        final name = list[i].name;
        list[i].stock < 50
            ? productsState[name] = true
            : productsState[name] = false;
      }
      state = state.copyWith(isLoading: false);
      return productsState;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {};
    }
  }

  Future<Map<DateTime, double>> calcPerDay() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 6));

      final Map<DateTime, double> totals = {
        for (int i = 0; i < 7; i++) start.add(Duration(days: i)): 0.0,
      };

      final snapshot = await FirebaseFirestore.instance
          .collection('reports')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final ts = data['date'] as Timestamp?;
        final total = (data['total'] ?? 0).toDouble();

        if (ts != null) {
          final d = ts.toDate();
          final day = DateTime(d.year, d.month, d.day);
          if (totals.containsKey(day)) {
            totals[day] = totals[day]! + total;
          }
        }
      }
      state = state.copyWith(isLoading: false);
      return totals;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {};
    }
  }

  Future<Map<String, int>> prodsAndLeft() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await ref.read(productControllerProvider).products;
      final map = await stockAlert();
      final keys = map.entries.where((e) => e.value == true).map((a) => a.key);
      final result = {
        for (var product in list)
          if (keys.contains(product.name)) product.name: product.stock,
      };
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {};
    }
  }

  Future<int> calcDifference() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final today = await calculateSalesToday();
      final yesterday = await calculateSalesYesterday();
      if (yesterday == 0) return today == 0 ? 0 : 0;

      final diff = today - yesterday;
      final percent = ((diff / yesterday) * 100);

      state = state.copyWith(isLoading: false);
      return percent.toInt();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return 0;
    }
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>(
      (ref) => DashboardController(ref),
    );
