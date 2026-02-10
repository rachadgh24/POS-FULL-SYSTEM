class UsersState {
  final List<Map<String, dynamic>> users;
  final String? error;

  final bool loading;

  UsersState( {required this.loading,required this.users, required this.error,});
  UsersState copyWith({
    final List<Map<String, dynamic>>? users,
    String? error,
    bool? loading,
  }) {
    return UsersState(
      users: users ?? this.users,
      error: error,
      loading:loading??this.loading
    );
  }
}
