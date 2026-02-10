import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:input_quantity/input_quantity.dart';
import 'package:localmartpro/core/theme.dart';
import 'package:localmartpro/features/cart/cartController.dart';
import 'package:localmartpro/features/cart/cartState.dart';
import 'package:localmartpro/features/products/ProductController.dart';
import 'package:localmartpro/features/report/reportController.dart';
import 'package:uuid/uuid.dart';

class cartView extends ConsumerStatefulWidget {
  const cartView({super.key});

  @override
  ConsumerState<cartView> createState() => _cartViewState();
}

class _cartViewState extends ConsumerState<cartView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productControllerProvider.notifier).listenProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartControllerProvider);

    ref.watch(cartControllerProvider);
    if (cartState.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    ref.listen<CartState>(cartControllerProvider, (prev, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.error!)));
        });
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Hero(tag: 'POS', child: const Text('POS')),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.appBarGradient),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            useSafeArea: true,
            context: context,
            builder: (c) => Consumer(
              builder: (context, ref, _) {
                final products = ref.watch(productControllerProvider).products;

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final e = products[index];
                    int quantity = 0;

                    final stock = ref
                        .watch(productControllerProvider)
                        .products[index]
                        .stock;

                    return SingleChildScrollView(
                      // scrollDirection: Axis.horizontal,
                      child: Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    e.name,
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    ' in stock: $stock',
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Expanded(
                                    child: InputQty(
                                      minVal: 0,
                                      maxVal: stock.toDouble(),
                                      initVal: 0,
                                      onQtyChanged: (value) =>
                                          quantity = value?.toInt() ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                    '\$${e.price}',
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                  const Text(''),
                                  const Text(''),
                                ],
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  if (quantity > 0) {
                                    ref
                                        .read(cartControllerProvider.notifier)
                                        .addToCart(e.id, quantity, ref);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                ),
                                child: const Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        backgroundColor: Colors.cyanAccent,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        child: ListView(
          children: [
            ...cartState.items.map(
              (item) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Name: ${item.product.name}, Price: ${item.product.price}\$  quantity: ${item.quantity}',
                          style: const TextStyle(color: Colors.cyanAccent),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final id = item.product.id;
                          ref
                              .read(cartControllerProvider.notifier)
                              .removeFromCart(id, ref);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                double total = cartState.items.fold(
                  0.0,
                  (sum, item) => sum + item.product.price * item.quantity,
                );
                if (total == 0) return;

                ref
                    .read(reportControllerProvider.notifier)
                    .newReport(
                      Uuid().v4(),
                      Timestamp.now(),
                      total,
                      cartState.items.map((i) => i.product).toList(),
                    );
                ref.read(cartControllerProvider.notifier).clearCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Total = \$${cartState.items.fold(0.0, (sum, item) => sum + item.product.price * item.quantity)}',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
