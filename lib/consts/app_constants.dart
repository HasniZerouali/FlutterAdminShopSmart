import 'package:flutter/material.dart';

class AppConstants {
  static const String productImageUrl =
      "https://img.freepik.com/free-photo/white-vintage-view-new-shoes_1203-6515.jpg?w=900&t=st=1720618109~exp=1720618709~hmac=02955eb1ee0ebe58b97470a8019a1e03b2b91c5c3d494bed721cbb47f9a698ef";

  static List<String> categoriesList = [
    'Phones',
    'Laptops',
    'Electronics',
    'Clothes',
    'Books',
    'Shoes',
    'Cosmetics',
    'Watches',
    'Accessories',
  ];
  static List<DropdownMenuItem<String>>? get categoriesDropDownList {
    //generat kima drtha m3a List.generate fal dashborardScrenn
    List<DropdownMenuItem<String>>? menuItems =
        List<DropdownMenuItem<String>>.generate(
      categoriesList.length,
      (index) => DropdownMenuItem(
        value: categoriesList[index],
        //balue bach ta3raf user fach 9ima drak fiha
        child: Text(
          categoriesList[index],
        ),
      ),
    );
    return menuItems;
  }
}
