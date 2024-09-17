import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/consts/theme.data.dart';
import 'package:shopsmart_admin/providers/product_provider.dart';
import 'package:shopsmart_admin/providers/theme_provider.dart';
import 'package:shopsmart_admin/screens/dashboard_screen.dart';
import 'package:shopsmart_admin/screens/edit_upload_product_form.dart';
import 'package:shopsmart_admin/screens/inner_screens/orders_screen.dart';
import 'package:shopsmart_admin/screens/search_screen.dart';
import 'package:shopsmart_admin/widgets/rotating_Indicator_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: Firebase.initializeApp(), //initiali l firebase lga3 l app
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //hadi lawla fi halat waiting rah 3ad ydir initialisation la firebase
            return Scaffold(
                body: Center(
              child: RotatingProgressIndicator(),
            ));
          } else if (snapshot.hasError) {
            //whadi ida sra error atnaa initialisation ta3 firebase
            return Scaffold(
              body: Center(
                child: SelectableText(
                    "An error has been occured ${snapshot.error}"),
              ),
            );
          }
          //w ida masra hata error fal initaialisation ta3 firebase t return app ta3na nrml
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => ThemeProvider(),
              ),
              ChangeNotifierProvider(
                create: (_) => ProductProvider(),
              ),
            ],
            //Consumer min tkon widget wahda tatsama3 ela tarayoro=)
            // bach n3araf var (themeProvider)li fig theme t or f ta3 li jabnaha ml SwitchListTile
            //kona najmo fiblassat consumer n3awdo ndiclaro l var   :  final themeProvider = Provider.of<ThemeProvider>(context);
            child: Consumer<ThemeProvider>(
              builder: (
                context,
                themeProvider,
                child,
              ) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Shop Smart ADMIN AR',
                  theme: Styles.themeData(
                      isDarkTheme: themeProvider.getIsDarkTheme,
                      context: context),
                  home: DashboardScreen(),
                  routes: {
                    OrdersScreenFree.routeName: (context) =>
                        const OrdersScreenFree(),
                    SearchScreen.routeName: (context) => const SearchScreen(),
                    EditOrUploadProductScreen.routeName: (context) =>
                        const EditOrUploadProductScreen(),
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
