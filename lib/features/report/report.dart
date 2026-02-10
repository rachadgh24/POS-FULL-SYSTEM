class Report {
  String id;
  String name;
  String role;
  final date;
  double total;
  List items;
  Report( {
    required this.id,
    required this.name,
    this.date,
    required this.total,
    required this.items,
    required this.role
  });
}

// class ReportItem {
//   String productID;
//   int qty;
//   String productName;
//   double price;
//   ReportItem({
//     required this.productID,
//     required this.qty,
//     required this.productName,
//     required this.price,
//   });
//   factory ReportItem.fromMap(Map<String, dynamic> map) {
//     return ReportItem(
//       productID: map['productID'] ?? '',
//       qty: map['qty'] ?? 0,
//       productName: map['productName'] ?? '',
//       price: (map['price'] ?? 0).toDouble(),
//     );
//   }
// }
