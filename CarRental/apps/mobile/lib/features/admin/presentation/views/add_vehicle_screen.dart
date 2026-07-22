import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../home/data/models/home_models.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../data/repositories/admin_repository.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController(text: 'Luxury Rental Vehicle');
  final _plateCtrl = TextEditingController(); // License Plate (Optional)
  final _rateCtrl = TextEditingController();
  final _kmCtrl = TextEditingController(text: '300');
  final _excessCtrl = TextEditingController(text: '0.50');
  final _seatsCtrl = TextEditingController(text: '5');
  final _yearCtrl = TextEditingController(text: '2024');
  final _engineCtrl = TextEditingController(); // e.g. 5.6L V8 / 1.5L 4-Cyl
  final _powerCtrl = TextEditingController();  // e.g. 400 hp / 115 hp
  final _quantityCtrl = TextEditingController(text: '1');
  final _descCtrl = TextEditingController();

  File? _selectedImageFile;
  int _selectedBrandId = 1; // Default: Mercedes-Benz
  int _selectedCategoryId = 1; // Default: Sedan
  String _transmission = 'Automatic';
  bool _saving = false;

  List<BrandModel> _brands = [];
  List<CategoryModel> _categories = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadBrandsAndCategories();
  }

  Future<void> _loadBrandsAndCategories() async {
    try {
      final homeRepo = ref.read(homeRepositoryProvider);
      final data = await homeRepo.fetchHomeData();
      if (mounted) {
        setState(() {
          _brands = data.brands;
          _categories = data.categories;
          if (_brands.isNotEmpty) {
            _selectedBrandId = _brands.first.id;
          }
          if (_categories.isNotEmpty) {
            _selectedCategoryId = _categories.first.id;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taglineCtrl.dispose();
    _plateCtrl.dispose();
    _rateCtrl.dispose();
    _kmCtrl.dispose();
    _excessCtrl.dispose();
    _seatsCtrl.dispose();
    _yearCtrl.dispose();
    _engineCtrl.dispose();
    _powerCtrl.dispose();
    _quantityCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e\n(Note: Rebuild app to link native image picker)'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImagePickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.surfaceDark
          : AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Vehicle Photo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.orange),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.orange),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (_selectedImageFile != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  title: const Text('Remove Selected Photo', style: TextStyle(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _selectedImageFile = null);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final repo = ref.read(adminRepositoryProvider);
      final name = _nameCtrl.text.trim();
      final yearVal = int.tryParse(_yearCtrl.text) ?? 2024;
      final daily = double.tryParse(_rateCtrl.text) ?? 100.0;
      final kms = int.tryParse(_kmCtrl.text) ?? 300;
      final excess = double.tryParse(_excessCtrl.text) ?? 0.50;
      final plate = _plateCtrl.text.trim();
      final tagline = _taglineCtrl.text.trim().isEmpty ? 'Luxury Rental Vehicle' : _taglineCtrl.text.trim();

      // Create unique slug compliant with FastAPI VehicleBase schema
      final slug = '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${DateTime.now().millisecondsSinceEpoch}';

      // 1. Submit vehicle details to /api/v1/vehicles/
      final vehicleData = <String, dynamic>{
        'name': name,
        'model': name.contains(' ') ? name.split(' ').sublist(1).join(' ') : name,
        'slug': slug,
        'brand_id': _selectedBrandId,
        'category_id': _selectedCategoryId,
        'year': yearVal,
        'tagline': tagline,
        'description': _descCtrl.text.trim().isNotEmpty
            ? _descCtrl.text.trim()
            : 'Falcon View Luxury Car Rentals LLC premium fleet vehicle.',
        'available': (int.tryParse(_quantityCtrl.text) ?? 1) > 0,
        'quantity': int.tryParse(_quantityCtrl.text) ?? 1,
        'featured': true, // Show on home screen and fleet
        'rating': 5.0,
        'review_count': 0,
        'min_driver_age': 21,
        'delivery_available': true,
        'primary_image': '${ApiEndpoints.baseUrl}/static/placeholder.png',
        'keywords': plate.isNotEmpty ? [plate] : <String>[],
        'pricing': {
          'daily': daily,
          'weekly': daily * 0.9,
          'monthly': daily * 0.75,
          'kms_daily': kms,
          'excess_per_km': excess,
          'delivery_fee': 0.0,
        },
        'specifications': {
          'seats': int.tryParse(_seatsCtrl.text) ?? 5,
          'transmission': _transmission,
          'year': yearVal,
          if (_engineCtrl.text.trim().isNotEmpty) 'engine': _engineCtrl.text.trim(),
          if (_powerCtrl.text.trim().isNotEmpty) 'power': _powerCtrl.text.trim(),
        },
      };

      final createdVehicle = await repo.addVehicle(vehicleData);
      final vehicleId = createdVehicle['id'] as int?;

      // 2. If a local image file was selected, upload it via POST /api/v1/vehicles/{id}/upload-image
      if (_selectedImageFile != null && vehicleId != null) {
        try {
          final uploadedUrl = await repo.uploadVehicleImage(
            vehicleId,
            _selectedImageFile!.path,
            imageType: 'thumbnail',
          );

          // Update primary_image to point to the newly uploaded image URL
          vehicleData['primary_image'] = uploadedUrl;
          await repo.updateVehicle(vehicleId, vehicleData);
        } catch (uploadError) {
          debugPrint('Image upload failed: $uploadError');
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vehicle added successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Failed to add vehicle: $e';
        if (e is DioException && e.response?.data is Map) {
          final detail = (e.response?.data as Map)['detail'];
          if (detail != null) errorMsg = detail.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bgDark : AppColors.bgLight;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surface2 = isDark ? AppColors.surface2Dark : AppColors.surface2Light;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final textMuted = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add New Vehicle',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: _saving
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.orange),
                  SizedBox(height: 16),
                  Text('Saving vehicle & uploading media...', style: TextStyle(color: AppColors.orange)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Photo Upload Tile
                  GestureDetector(
                    onTap: () => _showImagePickerModal(context),
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedImageFile != null ? AppColors.orange : borderColor,
                          width: _selectedImageFile != null ? 2 : 1,
                        ),
                      ),
                      child: _selectedImageFile != null
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.file(
                                    _selectedImageFile!,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                                      onPressed: () => _showImagePickerModal(context),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.add_a_photo_rounded, size: 28, color: AppColors.orange),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tap to upload vehicle photo',
                                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Gallery or Camera',
                                  style: TextStyle(color: textMuted, fontSize: 11),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Brand Predefined Dropdown
                  _fieldLabel('BRAND', textMuted),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedBrandId,
                        dropdownColor: surface,
                        style: TextStyle(color: textColor, fontSize: 14),
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedBrandId = v);
                        },
                        items: (_brands.isNotEmpty
                                ? _brands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
                                : _fallbackBrands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))))
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Make & Model Field
                  _fieldLabel('VEHICLE NAME & MODEL', textMuted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: _inputDecoration('e.g. Nissan Patrol', surface2, borderColor),
                    validator: (v) => (v == null || v.isEmpty) ? 'Vehicle name & model is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Tagline Field (Optional)
                  _fieldLabel('TAGLINE (OPTIONAL)', textMuted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _taglineCtrl,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: _inputDecoration('e.g. Flagship 7-Seat SUV — The Ultimate UAE Status Symbol', surface2, borderColor),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  _fieldLabel('DESCRIPTION', textMuted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    style: TextStyle(color: textColor, fontSize: 14),
                    maxLines: 3,
                    decoration: _inputDecoration('Enter vehicle description...', surface2, borderColor),
                  ),
                  const SizedBox(height: 16),

                  // Category & Year
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('CATEGORY', textMuted),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: surface2,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  value: _selectedCategoryId,
                                  dropdownColor: surface,
                                  style: TextStyle(color: textColor, fontSize: 14),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _selectedCategoryId = v);
                                  },
                                  items: (_categories.isNotEmpty
                                          ? _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                                          : _fallbackCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))))
                                      .toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('YEAR', textMuted),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _yearCtrl,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _inputDecoration('e.g. 2024', surface2, borderColor),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Seats & Transmission
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('SEATS', textMuted),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _seatsCtrl,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _inputDecoration('5', surface2, borderColor),
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('TRANSMISSION', textMuted),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: surface2,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _transmission,
                                  dropdownColor: surface,
                                  style: TextStyle(color: textColor, fontSize: 14),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _transmission = v);
                                  },
                                  items: const [
                                    DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                                    DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Quantity Field
                  _fieldLabel('VEHICLE QUANTITY', textMuted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: _inputDecoration('e.g. 1 (Default is 1)', surface2, borderColor),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Engine & Power Specs (OPTIONAL)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('ENGINE SPECS (OPTIONAL)', textMuted),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _engineCtrl,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _inputDecoration('e.g. 5.6L V8', surface2, borderColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('POWER SPECS (OPTIONAL)', textMuted),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _powerCtrl,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _inputDecoration('e.g. 400 hp', surface2, borderColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // License Plate Field (OPTIONAL)
                  _fieldLabel('LICENSE PLATE (OPTIONAL)', textMuted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _plateCtrl,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: _inputDecoration('e.g. DXB A 12345 (Optional)', surface2, borderColor),
                  ),
                  const SizedBox(height: 16),

                  // Daily Rate Field
                  _fieldLabel('DAILY RATE (AED)', textMuted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _rateCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: _inputDecoration('e.g. 65', surface2, borderColor),
                    validator: (v) => (v == null || v.isEmpty) ? 'Price is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Included KM & Excess Rate
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('INCLUDED KM/DAY', textMuted),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _kmCtrl,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _inputDecoration('300', surface2, borderColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel('EXCESS PER KM', textMuted),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _excessCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _inputDecoration('0.50', surface2, borderColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Add Vehicle Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text(
                        'Add Vehicle',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _fieldLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, Color bg, Color border) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      filled: true,
      fillColor: bg,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.orange)),
    );
  }
}

class _Option {
  final int id;
  final String name;
  const _Option(this.id, this.name);
}

const _fallbackBrands = [
  _Option(1, 'Mercedes-Benz'),
  _Option(2, 'BMW'),
  _Option(3, 'Audi'),
  _Option(4, 'Porsche'),
  _Option(5, 'Lamborghini'),
  _Option(6, 'Ferrari'),
  _Option(7, 'Rolls-Royce'),
  _Option(8, 'Bentley'),
  _Option(9, 'Range Rover'),
  _Option(10, 'Nissan'),
  _Option(11, 'Toyota'),
  _Option(12, 'Mitsubishi'),
  _Option(13, 'MG'),
  _Option(14, 'Chevrolet'),
  _Option(15, 'Hyundai'),
];

const _fallbackCategories = [
  _Option(1, 'Sedan'),
  _Option(2, 'SUV'),
  _Option(3, 'Sports'),
  _Option(4, 'Hatchback'),
  _Option(5, 'Luxury'),
];
