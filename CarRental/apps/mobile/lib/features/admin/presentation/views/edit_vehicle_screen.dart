import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/models/home_models.dart';
import '../../../home/data/repositories/home_repository.dart';
import '../../data/repositories/admin_repository.dart';

class EditVehicleScreen extends ConsumerStatefulWidget {
  const EditVehicleScreen({super.key, required this.vehicle});
  final VehicleModel vehicle;

  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _taglineCtrl;
  late final TextEditingController _plateCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _kmCtrl;
  late final TextEditingController _excessCtrl;
  late final TextEditingController _seatsCtrl;
  late final TextEditingController _yearCtrl;
  late final TextEditingController _engineCtrl;
  late final TextEditingController _powerCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _descCtrl;

  File? _selectedImageFile;
  int _selectedBrandId = 1;
  int _selectedCategoryId = 1;
  late String _transmission;
  late bool _available;
  late bool _featured;
  bool _saving = false;

  List<BrandModel> _brands = [];
  List<CategoryModel> _categories = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _nameCtrl = TextEditingController(text: v.name);
    _taglineCtrl = TextEditingController(text: v.tagline ?? 'Luxury Rental Vehicle');
    _plateCtrl = TextEditingController(text: v.keywords ?? '');
    _rateCtrl = TextEditingController(text: v.dailyPrice?.toStringAsFixed(0) ?? '');
    _kmCtrl = TextEditingController(text: '300');
    _excessCtrl = TextEditingController(text: '0.50');
    _seatsCtrl = TextEditingController(text: (v.seats ?? 5).toString());
    _yearCtrl = TextEditingController(text: '2024');
    _engineCtrl = TextEditingController(text: v.engine ?? '');
    _powerCtrl = TextEditingController(text: v.power ?? '');
    _quantityCtrl = TextEditingController(text: v.quantity.toString());
    _descCtrl = TextEditingController(text: v.description ?? '');

    _selectedBrandId = v.brandRel?.id ?? 1;
    _selectedCategoryId = v.categoryRel?.id ?? 1;

    final tx = v.transmission ?? 'Automatic';
    _transmission = (tx == 'Manual') ? 'Manual' : 'Automatic';

    _available = v.available;
    _featured = v.featured;

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
                'Change Vehicle Photo',
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
                  title: const Text('Clear Selected New Photo', style: TextStyle(color: AppColors.error)),
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

    final daily = double.tryParse(_rateCtrl.text) ?? widget.vehicle.dailyPrice ?? 100.0;
    final kms = int.tryParse(_kmCtrl.text) ?? 300;
    final excess = double.tryParse(_excessCtrl.text) ?? 0.50;
    final name = _nameCtrl.text.trim();
    final yearVal = int.tryParse(_yearCtrl.text) ?? 2024;
    final plate = _plateCtrl.text.trim();
    final tagline = _taglineCtrl.text.trim().isEmpty ? 'Luxury Rental Vehicle' : _taglineCtrl.text.trim();

    try {
      final repo = ref.read(adminRepositoryProvider);
      String primaryImgUrl = widget.vehicle.primaryImage.isNotEmpty
          ? widget.vehicle.primaryImage
          : 'https://falconviewcarrental.onrender.com/static/placeholder.png';

      // 1. Upload new image if selected
      if (_selectedImageFile != null) {
        try {
          primaryImgUrl = await repo.uploadVehicleImage(
            widget.vehicle.id,
            _selectedImageFile!.path,
            imageType: 'thumbnail',
          );
        } catch (uploadError) {
          debugPrint('Image upload error: $uploadError');
        }
      }

      // 2. Update vehicle details
      await repo.updateVehicle(widget.vehicle.id, {
        'name': name,
        'model': name.contains(' ') ? name.split(' ').sublist(1).join(' ') : name,
        'slug': widget.vehicle.slug.isNotEmpty
            ? widget.vehicle.slug
            : '${name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-')}-${widget.vehicle.id}',
        'brand_id': _selectedBrandId,
        'category_id': _selectedCategoryId,
        'year': yearVal,
        'tagline': tagline,
        'description': _descCtrl.text.trim().isEmpty
            ? 'Falcon View Luxury Car Rentals LLC premium fleet vehicle.'
            : _descCtrl.text.trim(),
        'available': _available && ((int.tryParse(_quantityCtrl.text) ?? 1) > 0),
        'quantity': int.tryParse(_quantityCtrl.text) ?? 1,
        'featured': _featured,
        'rating': widget.vehicle.rating,
        'review_count': 0,
        'min_driver_age': 21,
        'delivery_available': true,
        'primary_image': primaryImgUrl,
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
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vehicle updated successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        String errorMsg = 'Failed to update vehicle: $e';
        if (e is DioException && e.response?.data is Map) {
          final detail = (e.response?.data as Map)['detail'];
          if (detail != null) errorMsg = detail.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ));
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
        title: Text('Edit Vehicle',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _onSave,
              child: Text('Save',
                  style: TextStyle(
                      color: _saving ? textMuted : AppColors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
            ),
          ),
        ],
      ),
      body: _saving
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.orange),
                  SizedBox(height: 16),
                  Text('Saving changes...', style: TextStyle(color: AppColors.orange)),
                ],
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Image preview / picker box
                  GestureDetector(
                    onTap: () => _showImagePickerModal(context),
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: surface2,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Stack(
                        children: [
                          if (_selectedImageFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                _selectedImageFile!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (widget.vehicle.primaryImage.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                widget.vehicle.primaryImage,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Icon(Icons.directions_car_rounded, size: 48, color: textMuted),
                                ),
                              ),
                            )
                          else
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.directions_car_rounded, size: 48, color: textMuted),
                                  const SizedBox(height: 8),
                                  Text('Tap to select photo', style: TextStyle(color: textMuted, fontSize: 12)),
                                ],
                              ),
                            ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                            ),
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

                  // Make & Model
                  _fieldLabel('VEHICLE NAME & MODEL', textMuted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameCtrl,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: _inputDecoration('e.g. Nissan Patrol', surface2, borderColor),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
                          mainAxisSize: MainAxisSize.min,
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _fieldLabel('YEAR', textMuted),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _yearCtrl,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _inputDecoration('2024', surface2, borderColor),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _fieldLabel('SEATS', textMuted),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _seatsCtrl,
                              keyboardType: TextInputType.number,
                              style: TextStyle(color: textColor, fontSize: 14),
                              decoration: _inputDecoration('5', surface2, borderColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                    decoration: _inputDecoration('e.g. 1', surface2, borderColor),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Engine & Power Specs (OPTIONAL)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                          mainAxisSize: MainAxisSize.min,
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

                  // License Plate (OPTIONAL)
                  _fieldLabel('LICENSE PLATE / KEYWORDS (OPTIONAL)', textMuted),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _plateCtrl,
                    style: TextStyle(color: textColor, fontSize: 14),
                    decoration: _inputDecoration('e.g. DXB A 12345 (Optional)', surface2, borderColor),
                  ),
                  const SizedBox(height: 16),

                  // Daily Rate
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

                  // KM & Excess
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                          mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 16),

                  // Toggles: Available & Featured
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface2,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Available for Booking',
                                    style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                                Text('Toggle to enable/disable rental',
                                    style: TextStyle(color: textMuted, fontSize: 11)),
                              ],
                            ),
                            Switch(
                              value: _available,
                              onChanged: (v) => setState(() => _available = v),
                              activeThumbColor: AppColors.success,
                              activeTrackColor: AppColors.success.withValues(alpha: 0.3),
                              inactiveThumbColor: textMuted,
                              inactiveTrackColor: borderColor,
                            ),
                          ],
                        ),
                        Divider(color: borderColor, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Featured Vehicle',
                                    style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                                Text('Show on home screen',
                                    style: TextStyle(color: textMuted, fontSize: 11)),
                              ],
                            ),
                            Switch(
                              value: _featured,
                              onChanged: (v) => setState(() => _featured = v),
                              activeThumbColor: AppColors.orange,
                              activeTrackColor: AppColors.orange.withValues(alpha: 0.3),
                              inactiveThumbColor: textMuted,
                              inactiveTrackColor: borderColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Save Changes',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _fieldLabel(String label, Color color) => Text(label,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1));

  InputDecoration _inputDecoration(String hint, Color bg, Color border) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: bg,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.orange)),
      );
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
