import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/report_entity.dart';
import '../providers/reports_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/models/location_model.dart';

class CreateReportScreen extends ConsumerStatefulWidget {
  const CreateReportScreen({super.key});

  @override
  ConsumerState<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends ConsumerState<CreateReportScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  ReportCategory _selectedCategory = ReportCategory.other;
  ReportImportance _selectedImportance = ReportImportance.medium;
  List<File> _selectedImages = [];
  LocationModel? _currentLocation;
  bool _isLoadingLocation = false;
  late AnimationController _factAnimationController;
  late Animation<double> _factOpacityAnimation;

  // Category facts map
  static const Map<String, String> categoryFacts = {
    'Pothole':
        "Did you know? Reporting a single pothole can save your neighbours an average of ₹25,000 in potential car and two-wheeler repairs and prevent accidents for cyclists. You're not just fixing a hole, you're a road safety hero!",
    'Street Light':
        "Bright idea! Studies show that well-lit streets can reduce nighttime crime by over 20%. By reporting a broken streetlight, you're making your entire neighbourhood safer for evening walkers and families.",
    'Garbage':
        "Healthy streets, happy feet! An overflowing bin can become a breeding ground for diseases. By reporting it, you're protecting the public health of your community and keeping local animals safe from harm.",
    'Graffiti':
        "Community canvas! Areas that quickly remove unsolicited graffiti see a significant drop in vandalism. Your report helps maintain community pride, boosts local property values, and keeps your neighbourhood beautiful.",
    'Broken Sidewalk':
        "Step up for safety! A level sidewalk is crucial for the safety of children, the elderly, and people with disabilities. By reporting a broken pavement, you're making your community more walkable and accessible for everyone.",
    'Other':
        "You're a community scout! Reporting a unique issue helps officials spot new trends or problems they might not know about. Your keen eye helps make the system smarter and your city better!",
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    // Initialize animation controller for fact widget
    _factAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _factOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _factAnimationController,
      curve: Curves.easeInOut,
    ));

    // Start animation since we have a default category
    _factAnimationController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _factAnimationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      setState(() => _currentLocation = location);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location is required. Please wait for location to load or try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to create a report.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final location = LocationEntity(
      latitude: _currentLocation!.latitude,
      longitude: _currentLocation!.longitude,
      address: _currentLocation!.address,
    );

    await ref.read(reportsControllerProvider.notifier).createReport(
          userId: user.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          importance: _selectedImportance,
          location: location,
          images: _selectedImages,
        );
  }

  @override
  Widget build(BuildContext context) {
    final reportsState = ref.watch(reportsControllerProvider);

    ref.listen<AsyncValue<void>>(reportsControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${state.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (state.hasValue && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
        ref.refresh(allReportsProvider);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Report Issue')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Brief description of the issue',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportCategory>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ReportCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(_getCategoryName(category)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                  // Trigger animation when category changes
                  _factAnimationController.reset();
                  _factAnimationController.forward();
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportImportance>(
              value: _selectedImportance,
              decoration: const InputDecoration(
                labelText: 'Importance *',
                hintText: 'Select issue importance',
              ),
              items: ReportImportance.values.map((importance) {
                return DropdownMenuItem(
                  value: importance,
                  child: Row(
                    children: [
                      Icon(
                        _getImportanceIcon(importance),
                        color: _getImportanceColor(importance),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(_getImportanceName(importance)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedImportance = value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select importance level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Detailed description of the issue',
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 8),
                        Text(
                          'Location',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        if (_isLoadingLocation)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _getCurrentLocation,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentLocation?.toString() ?? 'Getting location...',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_camera),
                        const SizedBox(width: 8),
                        Text(
                          'Photos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        PopupMenuButton<ImageSource>(
                          icon: const Icon(Icons.add_a_photo),
                          onSelected: _pickImage,
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: ImageSource.camera,
                              child: Row(
                                children: [
                                  Icon(Icons.camera_alt),
                                  SizedBox(width: 8),
                                  Text('Camera'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: ImageSource.gallery,
                              child: Row(
                                children: [
                                  Icon(Icons.photo_library),
                                  SizedBox(width: 8),
                                  Text('Gallery'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_selectedImages.isEmpty)
                      Text(
                        'No photos selected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      )
                    else
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 100,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onError,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: reportsState.isLoading ? null : _submitReport,
              child: reportsState.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Report'),
            ),
            const SizedBox(height: 16),
            _buildCategoryFactWidget(),
            const SizedBox(height: 24), // Extra spacing at bottom
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFactWidget() {
    final categoryName = _getCategoryName(_selectedCategory);
    final fact = categoryFacts[categoryName];

    if (fact == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _factOpacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _factOpacityAnimation.value,
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '💡',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Did you know?',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        fact,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getCategoryName(ReportCategory category) {
    switch (category) {
      case ReportCategory.pothole:
        return 'Pothole';
      case ReportCategory.streetLight:
        return 'Street Light';
      case ReportCategory.garbage:
        return 'Garbage';
      case ReportCategory.graffiti:
        return 'Graffiti';
      case ReportCategory.brokenSidewalk:
        return 'Broken Sidewalk';
      case ReportCategory.other:
        return 'Other';
    }
  }

  String _getImportanceName(ReportImportance importance) {
    switch (importance) {
      case ReportImportance.low:
        return 'Low';
      case ReportImportance.medium:
        return 'Medium';
      case ReportImportance.high:
        return 'High';
      case ReportImportance.critical:
        return 'Critical';
    }
  }

  IconData _getImportanceIcon(ReportImportance importance) {
    switch (importance) {
      case ReportImportance.low:
        return Icons.low_priority;
      case ReportImportance.medium:
        return Icons.remove;
      case ReportImportance.high:
        return Icons.priority_high;
      case ReportImportance.critical:
        return Icons.warning;
    }
  }

  Color _getImportanceColor(ReportImportance importance) {
    switch (importance) {
      case ReportImportance.low:
        return Colors.green;
      case ReportImportance.medium:
        return Colors.orange;
      case ReportImportance.high:
        return Colors.red;
      case ReportImportance.critical:
        return Colors.red.shade800;
    }
  }
}
