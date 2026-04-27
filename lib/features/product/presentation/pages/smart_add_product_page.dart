import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';
import '../widgets/qr_code_dialog.dart';

class SmartAddProductPage extends StatefulWidget {
  const SmartAddProductPage({super.key});

  @override
  State<SmartAddProductPage> createState() => _SmartAddProductPageState();
}

class _SmartAddProductPageState extends State<SmartAddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  double _price = 0.0;
  String? _imagePath;
  String _generatedBarcode = '';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Auto generate a unique barcode
    _generatedBarcode = const Uuid().v4().substring(0, 8).toUpperCase();
  }

  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imagePath = photo.path;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please take a picture of the product')),
        );
        return;
      }

      _formKey.currentState!.save();

      final product = Product(
        id: const Uuid().v4(),
        name: _name,
        barcode: _generatedBarcode,
        price: _price,
        imagePath: _imagePath,
      );

      context.read<ProductBloc>().add(AddProduct(product));
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return QrCodeDialog(
            productName: _name,
            barcode: _generatedBarcode,
          );
        },
      ).then((_) {
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Add Product'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Capture Section
              GestureDetector(
                onTap: _takePicture,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, size: 48, color: AppTheme.primaryColor),
                            const SizedBox(height: 8),
                            const Text('Tap to take a picture', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Generated Barcode
              const InputLabel(text: 'Generated Barcode (Auto)'),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _generatedBarcode,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Product Info
              const InputLabel(text: 'Product Name'),
              TextFormField(
                decoration: const InputDecoration(hintText: 'e.g. Smart Watch'),
                textCapitalization: TextCapitalization.words,
                validator: AppValidators.required('Please enter a name'),
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              
              const InputLabel(text: 'Price'),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '₹ ',
                  prefixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                validator: AppValidators.price,
                onSaved: (value) => _price = double.parse(value!),
              ),
              const SizedBox(height: 32),

              PrimaryButton(
                onPressed: _submit,
                icon: Icons.save,
                label: 'Save Smart Product',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
