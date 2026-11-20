// File: product_form_sheet.dart
// Author: Nana (Nurirzam Zeana binti Muhammad Zamri, 102885)
// Requirement: FR-06 Admin Product Management / Inventory (FR-09) (UI-06) | GitHub Issue #6
// Description: Add / Edit Product modal bottom sheet with validation and image picking (1 to 3 images).

import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/admin_product_provider.dart';
import '../../theme/inventory_colors.dart';
import '../../utils/product_validators.dart';
import 'product_list_tile.dart';

/// Bottom sheet form. Pass a product to edit it (pre-filled), or nothing to add a new one.
class ProductFormSheet extends StatefulWidget {
  const ProductFormSheet({super.key, this.product});

  final Product? product;

  /// Opens the sheet (rounded top, scrollable, keyboard safe).
  static Future<void> show(BuildContext context, {Product? product}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      clipBehavior: Clip.antiAlias,
      backgroundColor: InventoryColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ProductFormSheet(product: product),
    );
  }

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  static const int _maxImages = 3;

  final _formKey = GlobalKey<FormState>();
  // The sheet has its own messenger so SnackBars are not hidden behind the sheet.
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _materialController;
  late final TextEditingController _paletteController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;

  String? _category;
  late String _status;
  late List<String> _images; // Download URLs or temporary image data URIs.
  String? _imageError;

  bool get _isEditing => widget.product != null;

  /// BR-01: the status of a Pending / Reserved product cannot be changed here.
  bool get _statusLocked =>
      _isEditing &&
      ProductStatus.isManagedByReservation(widget.product!.status);

  @override
  void initState() {
    super.initState();
    final p = widget.product; // null when adding
    _nameController = TextEditingController(text: p?.name ?? '');
    _materialController = TextEditingController(text: p?.beadMaterial ?? '');
    _paletteController = TextEditingController(text: p?.colorPalette ?? '');
    _priceController = TextEditingController(
      text: p == null ? '' : p.priceMYR.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    // Old data with an unknown category falls back to "Other".
    if (p != null) {
      _category = ProductCategory.all.contains(p.category)
          ? p.category
          : ProductCategory.other;
    }
    _status = p?.status ?? ProductStatus.available;
    _images = List<String>.from(p?.imageUrls ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _materialController.dispose();
    _paletteController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Picks one image from the gallery and checks type and size.
  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        return; // user cancelled
      }
      final size = await picked.length();
      final error = ProductValidators.imageFile(picked.name, size);
      final bytes = error == null ? await picked.readAsBytes() : null;
      if (!mounted) {
        return;
      }
      setState(() {
        if (error == null) {
          final isPng = picked.name.toLowerCase().endsWith('.png');
          final mimeType = isPng ? 'image/png' : 'image/jpeg';
          _images.add('data:$mimeType;base64,${base64Encode(bytes!)}');
          _imageError = null;
        } else {
          _imageError = error; // "Please upload a JPG/PNG image under 5 MB"
        }
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => _imageError = 'Could not open the gallery. Please try again.',
        );
      }
    }
  }

  /// Removes one image from the list.
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _imageError = null;
    });
  }

  /// A new product needs at least 1 image. Editing may keep the old ones.
  bool _validateImageCount() {
    if (!_isEditing && _images.isEmpty) {
      setState(() => _imageError = 'Please add at least 1 image');
      return false;
    }
    return true;
  }

  /// Builds the Product from the form values (call only after validation).
  Product _buildProduct() {
    final now = DateTime.now();
    final base =
        widget.product ??
        Product(
          productId: '', // Firestore / mock repo creates the real id
          name: '',
          category: '',
          beadMaterial: '',
          colorPalette: '',
          description: '',
          priceMYR: 0,
          status: ProductStatus.available,
          createdAt: now,
          updatedAt: now,
        );
    return base.copyWith(
      name: _nameController.text.trim(),
      category: _category,
      beadMaterial: _materialController.text.trim(),
      colorPalette: _paletteController.text.trim(),
      description: _descriptionController.text.trim(),
      priceMYR: double.parse(_priceController.text.trim()),
      status: _status,
      imageUrls: _images,
      updatedAt: now,
    );
  }

  /// Validates, saves, and shows the result SnackBar.
  Future<void> _save() async {
    final formOk = _formKey.currentState!.validate();
    final imagesOk = _validateImageCount();
    if (!formOk || !imagesOk) {
      return;
    }

    final provider = context.read<AdminProductProvider>();
    final hostMessenger = ScaffoldMessenger.of(context); // outside the sheet
    final navigator = Navigator.of(context);

    final success = await provider.saveProduct(
      _buildProduct(),
      isNew: !_isEditing,
    );

    if (success) {
      hostMessenger.showSnackBar(
        const SnackBar(content: Text('Product saved successfully')),
      );
      if (mounted) {
        navigator.pop();
      }
    } else {
      // Keep the sheet open so the owner can try again.
      _messengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Failed to save product. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<AdminProductProvider>().isSaving;

    return ScaffoldMessenger(
      key: _messengerKey,
      child: Scaffold(
        backgroundColor: InventoryColors.cardWhite,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Edit Product' : 'Add Product',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ..._buildFields(),
                const SizedBox(height: 4),
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildButtons(isSaving),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// All text and dropdown fields, with a gap after each one.
  List<Widget> _buildFields() {
    final fields = <Widget>[
      TextFormField(
        controller: _nameController,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Product name'),
        validator: ProductValidators.name,
      ),
      DropdownButtonFormField<String>(
        // Flutter 3.33+: rename `value` to `initialValue`.
        initialValue: _category,
        decoration: const InputDecoration(labelText: 'Category'),
        items: ProductCategory.all
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (value) => setState(() => _category = value),
        validator: ProductValidators.category,
      ),
      TextFormField(
        controller: _materialController,
        decoration: const InputDecoration(labelText: 'Bead material'),
      ),
      TextFormField(
        controller: _paletteController,
        decoration: const InputDecoration(
          labelText: 'Colour palette',
          hintText: 'e.g. Cream, Sage',
        ),
      ),
      TextFormField(
        controller: _priceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        decoration: const InputDecoration(
          labelText: 'Price (RM)',
          prefixText: 'RM ',
        ),
        validator: ProductValidators.price,
      ),
      TextFormField(
        controller: _descriptionController,
        minLines: 3,
        maxLines: 5,
        decoration: const InputDecoration(labelText: 'Description'),
      ),
      DropdownButtonFormField<String>(
        initialValue: _status,
        decoration: InputDecoration(
          labelText: 'Status',
          helperText: _statusLocked ? 'Managed by reservations' : null,
        ),
        // A locked product only shows its current status (BR-01).
        items: (_statusLocked ? [_status] : ProductStatus.editable)
            .map((s) => DropdownMenuItem(value: s, child: Text(s)))
            .toList(),
        onChanged: _statusLocked
            ? null
            : (value) => setState(() => _status = value ?? _status),
        validator: ProductValidators.status,
      ),
    ];
    // Put a 14 px gap between fields.
    return [
      for (final field in fields) ...[field, const SizedBox(height: 14)],
    ];
  }

  /// Image thumbnails with remove buttons, the Add Photo button and the error text.
  Widget _buildImageSection() {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos (1 to $_maxImages, JPG/PNG, under 5 MB)',
          style: textTheme.bodyMedium?.copyWith(
            color: InventoryColors.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < _images.length; i++)
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ProductImage(source: _images[i], size: 76),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      tooltip: 'Remove image',
                      iconSize: 16,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 28,
                        height: 28,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: InventoryColors.errorRed,
                        foregroundColor: InventoryColors.cardWhite,
                      ),
                      onPressed: () => _removeImage(i),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _images.length >= _maxImages ? null : _pickImage,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text('Add Photo (${_images.length}/$_maxImages)'),
        ),
        if (_imageError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _imageError!,
              style: textTheme.bodySmall?.copyWith(
                color: InventoryColors.errorRed,
              ),
            ),
          ),
      ],
    );
  }

  /// Cancel and Save buttons. Save is disabled while saving to stop double submission.
  Widget _buildButtons(bool isSaving) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isSaving ? null : _save,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: InventoryColors.forestGreen,
              disabledForegroundColor: InventoryColors.cardWhite,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: InventoryColors.cardWhite,
                    ),
                  )
                : const Text('Save'),
          ),
        ),
      ],
    );
  }
}
