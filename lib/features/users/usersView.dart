import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localmartpro/core/theme.dart';
import 'package:localmartpro/features/users/usersController.dart';

class UsersView extends ConsumerStatefulWidget {
  const UsersView({super.key});

  @override
  ConsumerState<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends ConsumerState<UsersView> {
  @override
  void initState() {
    super.initState();
    ref.read(usersControllerProvider.notifier).loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    final roles = ['cashier', 'inventory', 'admin'];
    final state = ref.watch(usersControllerProvider);
    final users = state.users;

    return Scaffold(
      backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Hero(tag: 'Users', child: const Text('Users')),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.appBarGradient),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...users.map((e) {
            List<bool> isSelected = roles.map((r) => r == e['role']).toList();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(gradient: AppTheme.cardGradient),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 135,
                              child: Text(
                                e['name'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              e['email'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 40),
                            SizedBox(
                              width: 85,
                              child: Text(
                                'Role: ${e['role']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyanAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: const Text(
                          'Choose Role',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.cyanAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ToggleButtons(
                            borderRadius: BorderRadius.circular(12),
                            selectedColor: Colors.black,
                            fillColor: Colors.cyanAccent,
                            color: Colors.cyanAccent,
                            isSelected: isSelected,
                            onPressed: (index) {
                              setState(() {
                                for (int i = 0; i < isSelected.length; i++) {
                                  isSelected[i] = i == index;
                                }
                                e['role'] = roles[index];
                                ref
                                    .read(usersControllerProvider.notifier)
                                    .changeRole(roles[index], e['id']);
                              });
                            },
                            children: roles
                                .map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(r),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
