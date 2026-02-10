import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:flutter_riverpod/legacy.dart' show StateNotifier, StateNotifierProvider;
import 'package:localmartpro/features/cart/cartState.dart';
import 'package:localmartpro/features/products/ProductController.dart';
import 'package:localmartpro/features/products/Products.dart';

class CartController extends StateNotifier<CartState> {
  CartController() : super(CartState(items: [], error: null, loading: false));

  Future<void> addToCart(String id, int quantity, WidgetRef ref) async {
    if (quantity <= 0) return;

    state = state.copyWith(loading: true, error: null);

    try {
      final products = ref.read(productControllerProvider).products;
      final prodIndex = products.indexWhere((p) => p.id == id);
      if (prodIndex == -1) throw "Product not found";

      final product = products[prodIndex];

      final items = [...state.items];
      final cartIndex = items.indexWhere((i) => i.product.id == id);

      if (cartIndex != -1) {
        final existing = items[cartIndex];
        items[cartIndex] = CartItem(
          product: product,
          quantity: existing.quantity + quantity,
        );
      } else {
        items.add(CartItem(product: product, quantity: quantity));
      }

      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        stock: product.stock - quantity,
      );
      final updatedProducts = [...products];
      updatedProducts[prodIndex] = updatedProduct;
      ref.read(productControllerProvider.notifier).setProducts(updatedProducts);

      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .update({'stock': product.stock - quantity});

      state = state.copyWith(items: items, loading: false, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> removeFromCart(String prodId, WidgetRef ref) async {
    state = state.copyWith(loading: true, error: null);

    try {
      final cartIndex = state.items.indexWhere((i) => i.product.id == prodId);
      if (cartIndex == -1) throw "Item not in cart";

      final item = state.items[cartIndex];
      final qt = item.quantity;

      final products = ref.read(productControllerProvider).products;
      final prodIndex = products.indexWhere((p) => p.id == prodId);
      if (prodIndex != -1) {
        final prod = products[prodIndex];
        final updatedProduct = Product(
          id: prod.id,
          name: prod.name,
          price: prod.price,
          stock: prod.stock + qt,
        );
        final updatedProducts = [...products];
        updatedProducts[prodIndex] = updatedProduct;
        ref.read(productControllerProvider.notifier).setProducts(updatedProducts);

        await FirebaseFirestore.instance
            .collection('products')
            .doc(prodId)
            .update({'stock': prod.stock + qt});
      }

      final updatedItems =
          state.items.where((i) => i.product.id != prodId).toList();

      state = state.copyWith(items: updatedItems, loading: false, error: null);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void clearCart() {
    state = state.copyWith(items: [], error: null);
  }
}

final cartControllerProvider =
    StateNotifierProvider<CartController, CartState>((ref) => CartController());
