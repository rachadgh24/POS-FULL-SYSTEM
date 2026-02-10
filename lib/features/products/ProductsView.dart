import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmartpro/core/theme.dart';
import 'package:localmartpro/features/cart/cartController.dart';
import 'package:localmartpro/features/cart/cartState.dart';
import 'package:localmartpro/features/products/ProductController.dart';
import 'package:localmartpro/features/products/ProductState.dart';
import 'package:uuid/uuid.dart';

class ProductsView extends ConsumerStatefulWidget {
  const ProductsView({super.key});

  @override
  ConsumerState<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends ConsumerState<ProductsView> {
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final stockC = TextEditingController();
  final search = TextEditingController();

  final nameE = TextEditingController();
  final priceE = TextEditingController();
  final stockE = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productControllerProvider.notifier).listenProducts();
    });
  }

  @override
  void dispose() {
    nameC.dispose();
    priceC.dispose();
    stockC.dispose();
    nameE.dispose();
    priceE.dispose();
    stockE.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final cartState = ref.watch(cartControllerProvider);
    final state = ref.watch(productControllerProvider);

    ref.listen<CartState>(cartControllerProvider, (prev, next) {
      if (next.error != null && next.error!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(next.error!)));
        });
      }
    });

    if (state.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Hero(tag: 'Products', child: const Text('Products')),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.appBarGradient),
        ),
        actions: [
          SizedBox(
            width: 300,
            child: TextField(
              decoration: InputDecoration(
                labelText: 'search',
                suffixIcon: const Icon(Icons.search, color: Colors.cyanAccent),
                filled: true,
                fillColor: Colors.grey[850],
                labelStyle: const TextStyle(color: Colors.cyanAccent),
              ),
              style: const TextStyle(color: Colors.cyanAccent),
              controller: search,
              onChanged: (value) {
                ref.read(productControllerProvider.notifier).search(value);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyanAccent,
        onPressed: () {
          final key = GlobalKey<FormState>();
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (c) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(gradient: AppTheme.cardGradient),
                  child: Form(
                    key: key,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'ADD PRODUCT',
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: nameC,
                          decoration: const InputDecoration(
                            labelText: 'Product Name',
                            labelStyle: TextStyle(color: Colors.cyanAccent),
                          ),
                          style: const TextStyle(color: Colors.cyanAccent),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter product name';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: priceC,
                          decoration: const InputDecoration(
                            labelText: 'Product Price',
                            labelStyle: TextStyle(color: Colors.cyanAccent),
                          ),
                          style: const TextStyle(color: Colors.cyanAccent),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter product price';
                            if (double.tryParse(value) == null)
                              return 'Please enter a valid number';
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: stockC,
                          decoration: const InputDecoration(
                            labelText: 'Stock',
                            labelStyle: TextStyle(color: Colors.cyanAccent),
                          ),
                          style: const TextStyle(color: Colors.cyanAccent),
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'Please enter stock';
                            if (int.tryParse(value) == null)
                              return 'Please enter a valid number';
                            return null;
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                              ),
                              onPressed: () {
                                nameC.clear();
                                priceC.clear();
                                stockC.clear();
                                Navigator.pop(context);
                              },
                              child: const Text('cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                              ),
                              onPressed: () {
                                if (key.currentState!.validate()) {
                                  ref
                                      .read(productControllerProvider.notifier)
                                      .addProduct(
                                        nameC.text,
                                        double.parse(priceC.text),
                                        int.parse(stockC.text),
                                        const Uuid().v4(),
                                      );
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.76,
        ),
        itemCount: state.products.length,
        itemBuilder: (context, index) {
          final product = state.products[index];
          return Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(gradient: AppTheme.cardGradient),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            nameE.text = product.name;
                            priceE.text = product.price.toString();
                            stockE.text = product.stock.toString();

                            final key2 = GlobalKey<FormState>();
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              builder: (e) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(e).viewInsets.bottom,
                                  ),
                                  child: SingleChildScrollView(
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.cardGradient,
                                      ),
                                      child: Form(
                                        key: key2,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'EDIT PRODUCT',
                                              style: TextStyle(
                                                color: Colors.cyanAccent,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextFormField(
                                              controller: nameE,
                                              decoration: const InputDecoration(
                                                labelText: 'New Product Name',
                                                labelStyle: TextStyle(
                                                  color: Colors.cyanAccent,
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.cyanAccent,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty)
                                                  return 'Please enter a valid product name';
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              controller: priceE,
                                              decoration: const InputDecoration(
                                                labelText: 'New Product Price',
                                                labelStyle: TextStyle(
                                                  color: Colors.cyanAccent,
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.cyanAccent,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty)
                                                  return 'Please enter new product price';
                                                if (double.tryParse(value) ==
                                                    null)
                                                  return 'Please enter a valid number';
                                                return null;
                                              },
                                            ),
                                            TextFormField(
                                              controller: stockE,
                                              decoration: const InputDecoration(
                                                labelText: 'Stock',
                                                labelStyle: TextStyle(
                                                  color: Colors.cyanAccent,
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.cyanAccent,
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty)
                                                  return 'Please enter new stock';
                                                if (int.tryParse(value) == null)
                                                  return 'Please enter a valid number';
                                                return null;
                                              },
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.redAccent,
                                                      ),
                                                  onPressed: () {
                                                    nameE.clear();
                                                    priceE.clear();
                                                    stockE.clear();
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('cancel'),
                                                ),
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.cyanAccent,
                                                      ),
                                                  onPressed: () {
                                                    if (key2.currentState!
                                                        .validate()) {
                                                      ref
                                                          .read(
                                                            productControllerProvider
                                                                .notifier,
                                                          )
                                                          .updateProduct(
                                                            product.id,
                                                            nameE.text,
                                                            double.parse(
                                                              priceE.text,
                                                            ),
                                                            int.parse(
                                                              stockE.text,
                                                            ),
                                                          );
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Text('UPDATE'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: \$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.cyanAccent),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${product.stock}',
                      style: const TextStyle(color: Colors.cyanAccent),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      onPressed: () {
                        ref
                            .read(productControllerProvider.notifier)
                            .deleteProduct(product.id);
                      },
                      child: const Text('DELETE PRODUCT'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
