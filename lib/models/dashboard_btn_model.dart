import 'package:flutter/material.dart';
import 'package:shopsmart_admin/screens/edit_upload_product_form.dart';
import 'package:shopsmart_admin/screens/inner_screens/orders_screen.dart';
import 'package:shopsmart_admin/screens/search_screen.dart';
import 'package:shopsmart_admin/services/assets_manager.dart';

class DashboardButtonsModel {
  final String title, imagePath;
  final Function onPressed;

  DashboardButtonsModel({
    required this.title,
    required this.imagePath,
    required this.onPressed,
  });

  static List<DashboardButtonsModel> dashboardBtnList(BuildContext context) => [
        DashboardButtonsModel(
            title: "Add a new product",
            imagePath: AssetsManager.cloud,
            onPressed: () {
              Navigator.pushNamed(
                context,
                EditOrUploadProductScreen.routeName,
              );
            }),
        DashboardButtonsModel(
            title: "inspect all products",
            imagePath: AssetsManager.shoppingCart,
            onPressed: () {
              print("hansni func model");
              Navigator.pushNamed(context, SearchScreen.routeName);
            }),
        DashboardButtonsModel(
            title: "View Orders",
            imagePath: AssetsManager.order,
            onPressed: () {
              Navigator.pushNamed(context, OrdersScreenFree.routeName);
            }),
      ];
}
