import 'package:localmartpro/features/products/Products.dart';

class ProductsState {
  final List<Product> products;
  final String? error;
  final bool loading;
  ProductsState({
    required this.loading,
    required this.products,
    required this.error,
  });

  ProductsState copyWith({
    List<Product>? products,
    String? error,
    bool? loading,
  }) {
    return ProductsState(
      products: products ?? this.products,
      error: error ?? this.error,
      loading: loading ?? this.loading,
    );
  }
}
