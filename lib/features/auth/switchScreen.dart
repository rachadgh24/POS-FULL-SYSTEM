import 'package:flutter/material.dart';
import 'package:localmartpro/features/auth/view/login.dart';
import 'package:localmartpro/features/auth/view/mainScreen.dart';
import 'package:localmartpro/features/auth/view/register.dart';
import 'package:localmartpro/features/cart/cartView.dart';
// import 'package:localmartpro/features/dashboard/dashboardView.dart';
import 'package:localmartpro/features/products/ProductsView.dart';
import 'package:localmartpro/features/report/reportsView.dart';
import 'package:localmartpro/features/users/usersView.dart';

void switchScreen(BuildContext ctx, String passed) {
  Navigator.of(ctx).push(
    MaterialPageRoute(
      builder: (_) {
        switch (passed) {
          case 'mainscreen':
            return const MainScreen();
          case 'login':
            return const Login();
          case 'register':
            return const Register();
          case 'products':
            return const ProductsView();
          case 'cartview':
            return cartView();
          case 'reportview':
            return ReportsView();
          case 'users':
            return UsersView();
          // case 'dashboard':
          //   return DashboardView();

          default:
            return MainScreen();
        }
      },
    ),
  );
}
