import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();

  final _imageFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    imageUrl: '',
    price: 0,
  );

  @override
  void initState() {
    _imageFocusNode.addListener(_updateImage);
    super.initState();
  }

  void _updateImage() {
    if (!_imageFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) return;
      setState(() {});
    }
  }

  void _saveForm() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Provider.of<Products>(
        context,
        listen: false,
      ).addProduct(_editedProduct);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit product',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save_alt),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                  ),
                  // textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_priceFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: value,
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      price: _editedProduct.price,
                      id: null,
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) return 'Please enter title';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Price',
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.number,
                  focusNode: _priceFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_descriptionFocusNode);
                  },
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      description: _editedProduct.description,
                      imageUrl: _editedProduct.imageUrl,
                      price: double.parse(value),
                      id: null,
                    );
                  },
                  validator: (value) {
                    if (value.isEmpty) return 'Please enter price';
                    if (double.tryParse(value) == null)
                      return 'Please enter a valide number';
                    if (double.parse(value) <= 0)
                      return 'Please enter a positive number';
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  maxLines: 3,
                  focusNode: _descriptionFocusNode,
                  onSaved: (value) {
                    _editedProduct = Product(
                      title: _editedProduct.title,
                      description: value,
                      imageUrl: _editedProduct.imageUrl,
                      price: _editedProduct.price,
                      id: null,
                    );
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(top: 8, right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: Colors.grey,
                        ),
                      ),
                      child: _imageUrlController.text.isEmpty
                          ? Text(
                              'Enter Url',
                            )
                          : FittedBox(
                              fit: BoxFit.cover,
                              child: Image.network(
                                _imageUrlController.text,
                              ),
                            ),
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Image URL'),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        controller: _imageUrlController,
                        focusNode: _imageFocusNode,
                        onEditingComplete: () {
                          setState(() {});
                        },
                        onFieldSubmitted: (_) {
                          _saveForm();
                        },
                        validator: (value) {
                          if (!value.startsWith('http') &&
                              !value.startsWith('https'))
                            return 'Please enter a valide URL.';

                          if (!value.endsWith('.png') &&
                              !value.endsWith('.jpg') &&
                              !value.endsWith('.jpeg'))
                            return 'Please enter a valid image URL';
                          return null;
                        },
                        onSaved: (value) {
                          _editedProduct = Product(
                            title: _editedProduct.title,
                            description: _editedProduct.description,
                            imageUrl: value,
                            price: _editedProduct.price,
                            id: null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imageFocusNode.removeListener(_updateImage);

    _imageUrlController.dispose();
    _imageFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _priceFocusNode.dispose();

    super.dispose();
  }
}
