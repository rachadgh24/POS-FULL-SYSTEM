import 'package:localmartpro/features/products/Products.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});
}

class CartState {
  final List<CartItem> items;
  final String? error;
  final bool loading;
  CartState( {required this.loading,required this.items, this.error});

  CartState copyWith({List<CartItem>? items, String? error,bool?loading}) {
    return CartState(items: items ?? this.items, error: error ?? this.error,loading:loading??this.loading);
  }
}