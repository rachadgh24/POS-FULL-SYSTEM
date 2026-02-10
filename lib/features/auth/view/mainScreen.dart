import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmartpro/core/theme.dart';
import 'package:localmartpro/features/auth/AuthController.dart';
import 'package:localmartpro/features/auth/view/login.dart';
import 'package:localmartpro/features/auth/switchScreen.dart';
import 'package:localmartpro/features/dashboard/dashboardController.dart';
import 'package:localmartpro/features/dashboard/dashboardView.dart';
import 'package:localmartpro/features/products/ProductController.dart';
import 'package:localmartpro/features/users/usersController.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final dashState = ref.watch(dashboardControllerProvider);

    if (dashState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final state = ref.watch(usersControllerProvider);

    final authState = ref.watch(authControllerProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.error!)));
        ref.read(usersControllerProvider.notifier).state = ref
            .read(usersControllerProvider)
            .copyWith(error: null);
      }
    });
    // if (state.loading) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    if (authState.user == null) return const Login();
    if (authState.role == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Main Screen'),
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: AppTheme.appBarGradient),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Main Screen'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.appBarGradient),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              ref.read(dashboardControllerProvider.notifier).state = ref
                  .read(dashboardControllerProvider.notifier)
                  .state
                  .copyWith(isLoading: true);

              final revenue = await ref
                  .read(dashboardControllerProvider.notifier)
                  .calculateRevenue();

              final stock = await ref
                  .read(dashboardControllerProvider.notifier)
                  .prodsAndLeft();

              final sales = await ref
                  .read(dashboardControllerProvider.notifier)
                  .calculateSalesToday();

              final salesWeek = await ref
                  .read(dashboardControllerProvider.notifier)
                  .calculateSalesLastWeek();

              final difference = await ref
                  .read(dashboardControllerProvider.notifier)
                  .calcDifference();

              final days = await ref
                  .read(dashboardControllerProvider.notifier)
                  .calcPerDay();
              final prods =await ref
                  .read(productControllerProvider.notifier)
                  .listenProducts();

              ref.read(dashboardControllerProvider.notifier).state = ref
                  .read(dashboardControllerProvider.notifier)
                  .state
                  .copyWith(isLoading: false);

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DashboardView(
                    revenue,
                    stock,
                    sales,
                    salesWeek,
                    difference,
                    days,
                  ),
                ),
              );
            },
            child: Hero(
              tag: 'my-hero',
              child: const Text(
                'DASHBOARD',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout, color: Colors.cyanAccent),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: authState.role == 'admin'
            ? _buildGrid(context, 'Welcome Admin', [
                _GridItem('Products', 'products'),
                _GridItem('POS', 'cartview'),
                _GridItem('Report', 'reportview'),
                _GridItem('Users', 'users'),
              ])
            : authState.role == 'cashier'
            ? _buildGrid(context, 'Welcome Cashier', [
                _GridItem('POS', 'cartview'),
              ])
            : _buildGrid(context, 'Welcome Inventory', [
                _GridItem('Products', 'products'),
              ]),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, String title, List<_GridItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: item.route != null
                    ? () => switchScreen(context, item.route!)
                    : null,
                child: Hero(
                  tag: item.title,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.cardGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GridItem {
  final String title;
  final String? route;
  _GridItem(this.title, this.route);
}
