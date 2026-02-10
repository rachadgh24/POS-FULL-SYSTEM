import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:localmartpro/features/users/usersState.dart';

class UsersController extends StateNotifier<UsersState> {
  UsersController() : super(UsersState(users: [], error: null,loading: true));

  
  void loadUsers() async {


    try {
  final snapshot = await FirebaseFirestore.instance.collection('users').get();
  final users = snapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return data; 
     

  }).toList();  state=state.copyWith(users: users, error: null,loading: false);
} on Exception catch (e) {
        state = state.copyWith(error: e.toString(), loading: false);

}

  }
 
  Future<void> changeRole(String role, String id) async {
    state = state.copyWith(loading: true, error: null);

     try {
  await FirebaseFirestore.instance
     .collection('users')
     .doc(id)
     .update({'role': role});
      final updatedUsers = state.users.map((user) {
        if (user['id'] == id) user['role'] = role;
        return user;
      }).toList();
             state = state.copyWith(users: updatedUsers, error: null,loading: false);

}  catch (e) {
      state = state.copyWith(loading: false, error: e.toString());

}

  }

  Future<void> deleteUser(String id) async {
    state = state.copyWith(loading: true, error: null);

    try {
  await FirebaseFirestore.instance.collection('users').doc(id).delete();
     final updatedUsers = state.users.where((user) => user['id'] != id).toList();
      state = state.copyWith(users: updatedUsers, loading: false, error: null);
}  catch (e) {
    state = state.copyWith(loading: false, error: e.toString());
}

  }
}

final usersControllerProvider =
    StateNotifierProvider<UsersController, UsersState>(
      (ref) => UsersController(),
    );
