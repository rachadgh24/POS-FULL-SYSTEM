class DashboardState {
  final double revenue;
  final double salesToday;
  final Map<String, bool> status;
  final bool isLoading;
  final String? error;

  DashboardState({
    required this.revenue,
    required this.salesToday,
    required this.status,
    required this.isLoading,
    required this.error,
  });

  DashboardState copyWith({
    double? revenue,
    double? salesToday,
    Map<String, bool>? status,
    bool? isLoading,
    String? error, 
  }) {
    return DashboardState(
      salesToday: salesToday ?? this.salesToday,
      revenue: revenue ?? this.revenue,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
