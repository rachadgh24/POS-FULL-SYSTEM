import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:localmartpro/features/products/ProductState.dart';
import 'package:localmartpro/features/products/Products.dart';

class Productcontroller extends StateNotifier<ProductsState> {
  Productcontroller()
    : super(ProductsState(products: [], error: null, loading: false));

  List<Product> allProducts = [];

  void setProducts(List<Product> products) {
    state = state.copyWith(products: products);
  }

  Future<void> listenProducts() async {
    state = state.copyWith(loading: true, error: null);
    await FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .listen(
          (snap) {
            final products = snap.docs.map((e) {
              final data = e.data();
              return Product(
                id: e.id,
                name: data['name'],
                price: (data['price'] ?? 0).toDouble(),
                stock: (data['stock'] ?? 0).toInt(),
              );
            }).toList();
            state = state.copyWith(
              products: products,
              error: null,
              loading: false,
            );
            allProducts = products;
          },
          onError: (err) {
            state = state.copyWith(error: err.toString(), loading: false);
          },
        );
  }

  void decrement(Product p, int qty) {}

  void search(String query) {
    if (query == '') {
      state = state.copyWith(products: allProducts);
    } else {
      final filtered = allProducts
          .where((p) => p.name.toLowerCase().startsWith(query.toLowerCase()))
          .toList();
      state = state.copyWith(products: filtered);
    }
  }

  Future<void> addProduct(
    String name,
    double price,
    int stock,
    String id,
  ) async {
    final product = Product(name: name, price: price, stock: stock, id: id);

    state = state.copyWith(loading: true, error: null);
    try {
      state = state.copyWith(
        products: [...state.products, product],
        error: null,
      );
      await FirebaseFirestore.instance.collection('products').add({
        'id': id,
        'name': name,
        'price': price,
        'stock': stock,
      });
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> deleteProduct(String id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await FirebaseFirestore.instance.collection('products').doc(id).delete();
      state = state.copyWith(
        products: state.products.where((product) => product.id != id).toList(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> updateProduct(
    String id,
    String name,
    double price,
    int stock,
  ) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await FirebaseFirestore.instance.collection('products').doc(id).update({
        'name': name,
        'price': price,
        'stock': stock,
      });
      state = state.copyWith(
        products: state.products.map((p) {
          if (p.id == id)
            return Product(id: id, name: name, price: price, stock: stock);
          return p;
        }).toList(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    } finally {
      state = state.copyWith(loading: false);
    }
  }
}

final productControllerProvider =
    StateNotifierProvider<Productcontroller, ProductsState>((ref) {
      return Productcontroller();
    });
