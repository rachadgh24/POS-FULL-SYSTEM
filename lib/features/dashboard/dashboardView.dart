import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmartpro/features/dashboard/dashboardController.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:localmartpro/features/dashboard/dashboardState.dart';
import 'package:localmartpro/features/products/ProductController.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView(
    this.revenue,
    this.stock,
    this.sales,
    this.salesWeek,
    this.difference,
    this.days, {
    super.key,
  });
  final revenue;
  final Map<String, int> stock;
  final sales;
  final salesWeek;
  final difference;
  final Map<DateTime, double> days;

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  // Map<String, int> stock = {};
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productControllerProvider.notifier).listenProducts();
    });
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //  widget.stock = await ref
    //       .read(dashboardControllerProvider.notifier)
    //       .prodsAndLeft();
    //   setState(() {});

    //   ref.read(dashboardControllerProvider.notifier).calculateRevenue();

    //   ref.listen<DashboardState>(dashboardControllerProvider, (prev, next) {
    //     if (next.error != null && next.error!.isNotEmpty) {
    //       ScaffoldMessenger.of(
    //         context,
    //       ).showSnackBar(SnackBar(content: Text(next.error!)));
    //     }
    //   });
    // });

    Future.microtask(() {
      ref.read(productControllerProvider.notifier).listenProducts();
      ref.read(dashboardControllerProvider.notifier).calculateRevenue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final kh = ref.watch(productControllerProvider);

    if (kh.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final list = widget.stock.keys.toList();
    final keys = widget.stock.values.toList();
    ref.watch(dashboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Hero(tag: 'my-hero', child: const Text('DASHBOARD')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.width * 0.155,
                    width: MediaQuery.of(context).size.width * 0.475,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sales today: ${widget.sales.toStringAsFixed(2)}\$',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.cyanAccent)
                              .copyWith(fontSize: 15.5),
                        ),
                        Text(
                          '${widget.difference}% than yesterday',
                          style: TextStyle(
                            color: widget.difference >= 0
                                ? Colors.greenAccent
                                : Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: MediaQuery.of(context).size.width * 0.155,
                    width: MediaQuery.of(context).size.width * 0.475,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'All time revenue: ${widget.revenue}\$',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(color: Colors.cyanAccent)
                              .copyWith(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Theme.of(context).cardColor,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text(
                                'Product',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Stock',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: Colors.white24),
                        for (int i = 0; i < list.length; i++)
                          Container(
                            height: 48,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 9,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: keys[i] > 35
                                        ? Colors.yellow
                                        : keys[i] > 10
                                        ? Colors.orange
                                        : Colors.red,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(8),
                                      bottomLeft: Radius.circular(8),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        list[i],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            keys[i].toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.warning_amber_rounded,
                                            color: Colors.redAccent,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 3),
                      child: BarChart(
                        BarChartData(
                          maxY: 800,
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  final entries = widget.days.entries.toList();
                                  if (idx < 0 || idx >= entries.length) {
                                    return const SizedBox.shrink();
                                  }

                                  String label;
                                  if (idx == entries.length - 1) {
                                    label = 'Today';
                                  } else if (idx == entries.length - 2) {
                                    label = 'Yesterday';
                                  } else {
                                    const weekdayLabels = [
                                      'Mon',
                                      'Tue',
                                      'Wed',
                                      'Thu',
                                      'Fri',
                                      'Sat',
                                      'Sun',
                                    ];
                                    final date = entries[idx].key;
                                    label = weekdayLabels[date.weekday - 1];
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      4,
                                      4,
                                      4,
                                      0,
                                    ),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 44,
                                getTitlesWidget: (value, meta) {
                                  const fixedY = [
                                    100.0,
                                    200.0,
                                    300.0,
                                    400.0,
                                    500.0,
                                    600.0,
                                    700.0,
                                    800.0,
                                  ];
                                  if (!fixedY.contains(value)) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    '\$${value.toInt()}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barGroups: List.generate(widget.days.length, (index) {
                            final entries = widget.days.entries.toList();
                            final val = entries.elementAt(index).value;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: val > 800 ? 800 : val,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.cyanAccent,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
