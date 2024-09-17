import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopsmart_admin/consts/app_constants.dart';
import 'package:shopsmart_admin/models/product_model.dart';
import 'package:shopsmart_admin/screens/inner_screens/loading_manager.dart';
import 'package:shopsmart_admin/services/my_app_method.dart';
import 'package:shopsmart_admin/widgets/subtitle_text.dart';
import 'package:uuid/uuid.dart';

import '../consts/my_validators.dart';
import '../widgets/title_text.dart';

class EditOrUploadProductScreen extends StatefulWidget {
  static const routeName = '/EditOrUploadProductScreen';

  const EditOrUploadProductScreen({
    super.key,
    this.productModel,
  });
  final ProductModel? productModel;

  @override
  State<EditOrUploadProductScreen> createState() =>
      _EditOrUploadProductScreenState();
}

class _EditOrUploadProductScreenState extends State<EditOrUploadProductScreen> {
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  bool isEditing = false;
  String? productNetworkImage;

  late TextEditingController _titleController,
      _priceController,
      _descriptionController,
      _quantityController;

  String? _categoryValue;
  bool _isLoading = false;
  String? productImageUrl;

  @override
  void initState() {
    // _categoryController = TextEditingController();
    // _brandController = TextEditingController();

    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel!
          .productImage; //ndirolha sava fi variable khartdh min user ydir remove wla replace tatbadal bara tani
      _categoryValue = widget.productModel!.productCategory;
    }

    _titleController = TextEditingController(
        text: widget.productModel
            ?.productTitle); //"?." ma3natha chofah ida marahch null di valeu ta3h
    _priceController =
        TextEditingController(text: widget.productModel?.productPrice);
    _descriptionController =
        TextEditingController(text: widget.productModel?.productDescription);
    _quantityController =
        TextEditingController(text: widget.productModel?.productQuantity);

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void clearForm() {
    _titleController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _quantityController.clear();
    removePickedImage();
  }

  void removePickedImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  Future<void> _uploadProduct() async {
    //hadi hiya lita3mil submit
    final isValid = _formKey.currentState!
        .validate(); //hadi hiya li tchof ida form kompli ga3 textFormField li fih rahom valide (mha9a9 chorot ta3 li darthom fal  "validator: (value)" matalan email)

    // final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Make sure to pick up an image",
        fct: () {},
      );
      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Category is empty",
        fct: () {},
      );
      return;
      // dir return bach maydirch validat lal form ida kanat hadi  null (return tkharjah mal func ), wtani tdirisValid mor had if
    }

    //nhot l photo fal firebase storage morah ndalha url fal fireStore bach n3ayatalha bih
    if (isValid) {
      _formKey.currentState!.save();

      try {
        setState(() {
          _isLoading = true;
        });
        final productID = const Uuid().v4();
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref() //haka kichrol rak fal chemain ta3 FirebaseStorage
              .child("productsImages") //hna kriyit folder
              .child(
                  '$productID.jpg'); //hna dakhal fih creet file , "hna tmad ism lal file fa storage ykon mayatkarach khartch lakan zoj andhom nafs is yakrazih  (tnajam tmadlah id ka ism)"
          //ndirolah save fal firestor bach nado manah url
          await ref.putFile(File(_pickedImage!
              .path)); //haka dartalha puch lal image (dart putFile khatrch rsal file) rsaltha lal storage
          productImageUrl =
              await ref.getDownloadURL(); //haka njib url ta3ha mal storage
          //trim() ta9la3 space  mal awal aw l akhir
        }

        //collection kichrol hiya tableau fal DB relational , doc hiya id ta3h , set na3tiha jison wla map wtkon hiya les ligne ta3 tableux

        await FirebaseFirestore.instance
            .collection("products")
            .doc(productID)
            .set({
          'productId': productID,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productImage': productImageUrl,
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productQuantity': _quantityController.text,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
          msg: "Product has been added",
          toastLength: Toast.LENGTH_SHORT,
          // textColor: Colors.white,
        );
        if (!mounted) {
          //zadna hadi bach gla3na "indar" mal Navigator
          // ! If the widget is still mounted (part of the widget tree),(screen mazalha active)
          // ! we dispose of the controller to free up resources.
          return;
        }
        MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear form?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        //tzid on FirebaseException w tani error.message bach l erro tji makhtasra ta3 firebase
        MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured ${error.message}",
          fct: () {},
        );
      } catch (error) {
        //tzid hadi khatrch yamkan yasra error machi ta3 "FirebaseAuthException"
        MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured ${error}",
          fct: () {},
        );
      } finally //"finally" y3ayatalha min ykamal try wla error
      {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editProduct() async {
    //hadi hiya lita3mil submit
    final isValid = _formKey.currentState!
        .validate(); //hadi hiya li tchof ida form kompli ga3 textFormField li fih rahom valide (mha9a9 chorot ta3 li darthom fal  "validator: (value)" matalan email)

    // final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && productNetworkImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Please pick up an image",
        fct: () {},
      );
      return;
    }
    if (_categoryValue == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Category is empty",
        fct: () {},
      );
      return;
      // dir return bach maydirch validat lal form ida kanat hadi  null (return tkharjah mal func ), wtani tdirisValid mor had if
    }

    //nhot l photo fal firebase storage morah ndalha url fal fireStore bach n3ayatalha bih
    if (isValid) {
      _formKey.currentState!.save();

      try {
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          //id dar image jdida tam dir had code
          final ref = FirebaseStorage.instance
              .ref() //haka kichrol rak fal chemain ta3 FirebaseStorage
              .child("productsImages") //hna kriyit folder
              .child(
                  '${widget.productModel!.productId}.jpg'); //hna dakhal fih creet file , "hna tmad ism lal file fa storage ykon mayatkarach khartch lakan zoj andhom nafs is yakrazih  (tnajam tmadlah id ka ism)"
          //ndirolah save fal firestor bach nado manah url
          await ref.putFile(File(_pickedImage!
              .path)); //haka dartalha puch lal image (dart putFile khatrch rsal file) rsaltha lal storage
          productImageUrl =
              await ref.getDownloadURL(); //haka njib url ta3ha mal storage
          //trim() ta9la3 space  mal awal aw l akhir
        }
        //collection kichrol hiya tableau fal DB relational , doc hiya id ta3h , set na3tiha jison wla map wtkon hiya les ligne ta3 tableux
        await FirebaseFirestore.instance
            .collection("products")
            .doc(widget.productModel!
                .productId) //madirch id jdid , id t3 product khdm bih
            .update({
          //hna dir update machi set
          'productId': widget.productModel!.productId,
          'productTitle': _titleController.text,
          'productPrice': _priceController.text,
          'productImage': productImageUrl ?? productNetworkImage,
          //id kan productImageUrl=null(ya3ni mabdlch image) di 9imat productNetworkImage
          'productCategory': _categoryValue,
          'productDescription': _descriptionController.text,
          'productQuantity': _quantityController.text,
          'createdAt': widget.productModel!
              .createdAT // mandiroch haka bach machi kol madir edite tbdl date Timestamp.now(), nkhalo date ta3 creation
        });
        Fluttertoast.showToast(
          msg: "Product has been edited ",
          toastLength: Toast.LENGTH_SHORT,
          // textColor: Colors.white,
        );
        if (!mounted) {
          //zadna hadi bach gla3na "indar" mal Navigator
          // ! If the widget is still mounted (part of the widget tree),(screen mazalha active)
          // ! we dispose of the controller to free up resources.
          return;
        }
        MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear form?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        //tzid on FirebaseException w tani error.message bach l erro tji makhtasra ta3 firebase
        MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured ${error.message}",
          fct: () {},
        );
      } catch (error) {
        //tzid hadi khatrch yamkan yasra error machi ta3 "FirebaseAuthException"
        MyAppMethods.showErrorORWarningDialog(
          context: context,
          subtitle: "An error has been occured ${error}",
          fct: () {},
        );
      } finally //"finally" y3ayatalha min ykamal try wla error
      {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> localImagePicker() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
      context: context,
      cameraFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.camera);
        setState(() {
          productNetworkImage =
              null; // bach ynajam ybadal image min ton kayna whda mkbal fal edit
        });
      },
      galleryFCT: () async {
        _pickedImage = await picker.pickImage(source: ImageSource.gallery);
        setState(() {
          productNetworkImage =
              null; // bach ynajam ybadal image min ton kayna whda mkbal fal edit
        });
      },
      removeFCT: () {
        setState(() {
          _pickedImage = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          bottomSheet: SizedBox(
            height: kBottomNavigationBarHeight + 10,
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: Color.fromARGB(255, 249, 73, 61),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Clear",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      MyAppMethods.showErrorORWarningDialog(
                        isError: false,
                        context: context,
                        subtitle: "Clear form?",
                        fct: () {
                          clearForm();
                        },
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      // backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.upload),
                    label: Text(
                      isEditing ? "Edit Product" : "Upload Product",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    onPressed: () {
                      if (isEditing) {
                        _editProduct();
                      } else {
                        _uploadProduct();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            // backgroundColor: Theme.of(context).scaffoldBackgroundColor, // rahy by default fa theme
            title: const TitlesTextWidget(
              label: "Upload a new product",
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  if (isEditing && productNetworkImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        productNetworkImage!,
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    )
                  ] else if (_pickedImage == null) ...[
                    SizedBox(
                      width: size.width * 0.4 + 10,
                      height: size.width * 0.4 + 10,
                      child: DottedBorder(
                          radius: Radius.circular(33),
                          color: Colors.deepPurple,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 80,
                                color: Colors.deepPurple,
                              ),
                              TextButton(
                                  onPressed: () {
                                    localImagePicker();
                                  },
                                  child: Text("Pick Product Image"))
                            ],
                          )),
                    ),
                  ] else ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(
                          _pickedImage!.path,
                        ),
                        height: size.width * 0.5,
                        alignment: Alignment.center,
                      ),
                    )
                  ],
                  if (_pickedImage != null || productNetworkImage != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            localImagePicker();
                          },
                          child: Text("Pick another image"),
                        ),
                        TextButton(
                          onPressed: () {
                            removePickedImage();
                          },
                          child: Text(
                            "Remove image",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(
                    height: 25,
                  ),
                  DropdownButton<String>(
                    hint: Text(_categoryValue ?? "Select Category"),
                    value: _categoryValue,
                    // had value bach yhat 9ima mokhtara fal blasat "hint"
                    items: AppConstants.categoriesDropDownList,

                    onChanged: (String? value) {
                      setState(() {
                        _categoryValue = value;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            key: const ValueKey('Title'),
                            maxLength: 80,
                            minLines: 1,
                            maxLines: 2,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: const InputDecoration(
                              filled: true,
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'Product Title',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString:
                                    "Please enter a valid title",
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  controller: _priceController,
                                  key: const ValueKey('Price \$'),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^(\d+)?\.?\d{0,2}'),
                                      // nzid hada bach tdrk ri arkam w "."  w ". tandrak ri kharta w tani ri zoj a3dad mor nokta"
                                    ),
                                  ],
                                  decoration: const InputDecoration(
                                      filled: true,
                                      contentPadding: EdgeInsets.all(12),
                                      hintText: 'Price',
                                      prefix: SubtitleTextWidget(
                                        label: "\$ ",
                                        color: Colors.blue,
                                        fontSize: 16,
                                      )),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Price is missing",
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: TextFormField(
                                  inputFormatters: [
                                    FilteringTextInputFormatter
                                        .digitsOnly //digitsonly m3naha yadi only digital( arkam fa9at)
                                  ],
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  key: const ValueKey('Quantity'),
                                  decoration: const InputDecoration(
                                    filled: true,
                                    contentPadding: EdgeInsets.all(12),
                                    hintText: 'Qty',
                                  ),
                                  validator: (value) {
                                    return MyValidators.uploadProdTexts(
                                      value: value,
                                      toBeReturnedString: "Quantity is missed",
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            key: const ValueKey('Description'),
                            controller: _descriptionController,
                            minLines: 3, //ri fa chakl
                            maxLines: 8,
                            maxLength: 1000,
                            textCapitalization: TextCapitalization.sentences,
                            //capitalizes the first letter of each sentence
                            decoration: const InputDecoration(
                              filled: true,
                              contentPadding: EdgeInsets.all(12),
                              hintText: 'Product description',
                            ),
                            validator: (value) {
                              return MyValidators.uploadProdTexts(
                                value: value,
                                toBeReturnedString: "Description is missed",
                              );
                            },
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height:
                        WidgetsBinding.instance.window.viewInsets.bottom > 0.0
                            ? 10
                            : kBottomNavigationBarHeight + 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
