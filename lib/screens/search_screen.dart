import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/widgets/rotating_Indicator_widget.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../services/assets_manager.dart';
import 'package:dynamic_height_grid_view/dynamic_height_grid_view.dart';

import '../widgets/product_widget.dart';
import '../widgets/title_text.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/SearchScreen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController searchTextController;

  @override
  void initState() {
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    searchTextController.dispose();
    super.dispose();
  }

  List<ProductModel> productListSearch = [];
  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);

    String? passedCategory =
        ModalRoute.of(context)!.settings.arguments as String?;

    final List<ProductModel> productList = passedCategory == null
        ? productProvider.getProducts
        : productProvider.findByCategory(ctgName: passedCategory);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: TitlesTextWidget(label: passedCategory ?? "Search"),
        ),
        body:StreamBuilder<List<ProductModel>>(
                // hasi stream bach min njibo data mal firesotr nkono real time
                stream: productProvider.fetchProductsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: RotatingProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: TitlesTextWidget(
                        label: snapshot.error.toString(),
                      ),
                    );
                  } else if (snapshot.data == null) {
                    return Center(
                      child: TitlesTextWidget(
                        label: "No product has been added",
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          TextField(
                            controller: searchTextController,
                            //bach min tadrak 3la khwa yagla3 keybord
                            decoration: InputDecoration(
                              hintText: "Search",
                              prefixIcon: GestureDetector(
                                onTap: () {},
                                child: const Icon(Icons.search),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  // setState(() {
                                  searchTextController
                                      .clear(); //bla mandir setState khartch .clear() roha dir rebuld lal widget
                                  FocusScope.of(context).unfocus();
                                  // });
                                },
                                child: const Icon(
                                  Icons.clear,
                                  color: Color(0xffb3271c),
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              //kol mayadrk ok fal clavie t3ayat lhad i l fun
                              setState(() {
                                productListSearch = productProvider.searchQuery(
                                    list: productList,
                                    searchText: searchTextController.text);
                              }); //hata yadrok ok y affiche bach matakalch l app labrit kol mayaktab dirha fal onChanged
                            },
                            onChanged: (value) {
                              //kol mayaktab haja y3ayat lhadi l fuc
                            },
                          ),
                          const SizedBox(height: 15),
                          if (searchTextController.text.isNotEmpty &&
                              productListSearch
                                  .isEmpty) // dir "..."bach traja3 list<widget>
                            ...[
                            const Center(
                              child: TitlesTextWidget(
                                label: "No result found",
                                fontSize: 40,
                              ),
                            )
                          ],
                          Container(
                            child: DynamicHeightGridView(
                              shrinkWrap:
                                  true, //dir hado wla dirha fi expanded + column fi SingleChildScrollView
                              physics: const NeverScrollableScrollPhysics(),
                              // itemCount: ProductModel.localProds.length,
                              itemCount: searchTextController.text.isNotEmpty
                                  ? productListSearch.length
                                  : productList.length,
                              builder: ((context, index) {
                                return
                                    //  ChangeNotifierProvider.value( "najmo nagal3oha (ChangeN...) khatrch gl3na productModelProvider mal ProductWidget"
                                    // hadi tarika lawla bsh haka tatmacha ri fal searchscreen bsh matl3ch fal wishlis w ..
                                    //  lazam ykon fal paren lisiner, yatsama3 3la tarayorat (lal productModel)
                                    // haka mastakhdamnach constructor

                                    // value: productList[index],
                                    // child:
                                    ProductWidget(
                                  productId:
                                      searchTextController.text.isNotEmpty
                                          ? productListSearch[index].productId
                                          : productList[index].productId,
                                  // image: ProductModel.localProds[index].productImage,
                                  // image: productProvider.getProducts[index].productImage,
                                  //  tagla3 paramter li fal constructur (hadi hiya faydat provider tasta3amlah bla matmarar l9iyam fal constructor)
                                );
                              }),
                              crossAxisCount: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
