import 'package:flutter/material.dart';

class RegisterServiceScreen extends StatefulWidget {
  const RegisterServiceScreen({super.key});

  @override
  State<RegisterServiceScreen> createState() => _RegisterServiceScreenState();
}

class _RegisterServiceScreenState extends State<RegisterServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _experienceController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedService;
  bool _isSubmitting = false;

  // List of services (matching home_service.dart)
  final List<String> _services = [
    'Plumbing',
    'Electricity',
    'Painting',
    'Toilet Unblocking',
    'Gardening',
    'Window Cleaning',
    'Furniture Repair',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _experienceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration submitted for ${_nameController.text}!'),
            backgroundColor: Colors.blueAccent,
          ),
        );
        // Reset form
        _formKey.currentState!.reset();
        _nameController.clear();
        _contactController.clear();
        _emailController.clear();
        _experienceController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedService = null;
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: Semantics(
          label: 'Back to Home',
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            tooltip: 'Back',
          ),
        ),
        title: const Text(
          'Register as a Service Provider',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          semanticsLabel: 'Register as a Service Provider',
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Logo and Title
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.blue.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 60,
                        width: 60,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.home_repair_service,
                          size: 60,
                          color: Colors.white,
                        ),
                        semanticLabel: 'HomeFix Logo',
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Join HomeFix as a Provider',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          semanticsLabel: 'Join HomeFix as a Provider',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: const Text(
                          'Provider Registration',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                          semanticsLabel: 'Provider Registration',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name Field
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1200),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: const Icon(Icons.person, color: Colors.blueAccent),
                            suffixIcon: _nameController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.blueAccent),
                                    onPressed: () => _nameController.clear(),
                                    tooltip: 'Clear name',
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (value.length > 100) {
                              return 'Name must be 100 characters or less';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Number Field
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1300),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TextFormField(
                          controller: _contactController,
                          decoration: InputDecoration(
                            labelText: 'Contact Number',
                            prefixIcon: const Icon(Icons.phone, color: Colors.blueAccent),
                            suffixIcon: _contactController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.blueAccent),
                                    onPressed: () => _contactController.clear(),
                                    tooltip: 'Clear contact number',
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your contact number';
                            }
                            if (!RegExp(r'^\+?[\d\s-]{8,15}$').hasMatch(value)) {
                              return 'Please enter a valid phone number (8-15 digits)';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1400),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email, color: Colors.blueAccent),
                            suffixIcon: _emailController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.blueAccent),
                                    onPressed: () => _emailController.clear(),
                                    tooltip: 'Clear email',
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email address';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Experience Field
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TextFormField(
                          controller: _experienceController,
                          decoration: InputDecoration(
                            labelText: 'Experience (Years)',
                            prefixIcon: const Icon(Icons.work, color: Colors.blueAccent),
                            suffixIcon: _experienceController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.blueAccent),
                                    onPressed: () => _experienceController.clear(),
                                    tooltip: 'Clear experience',
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your years of experience';
                            }
                            final num = int.tryParse(value);
                            if (num == null || num < 0 || num > 100) {
                              return 'Please enter a valid number (0-100)';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.next,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Service Category Dropdown
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1600),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: DropdownButtonFormField<String>(
                          value: _selectedService,
                          hint: const Text(
                            'Select Service Category',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                            ),
                          ),
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.blueAccent,
                            size: 30,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                            prefixIcon: const Icon(
                              Icons.home_repair_service,
                              color: Colors.blueAccent,
                              size: 24,
                            ),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          items: _services.map((service) {
                            return DropdownMenuItem<String>(
                              value: service,
                              child: Row(
                                children: [
                                  Icon(
                                    _getServiceIcon(service),
                                    color: Colors.blueAccent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(service),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: _isSubmitting
                              ? null
                              : (value) {
                                  setState(() {
                                    _selectedService = value;
                                  });
                                },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a service category';
                            }
                            return null;
                          },
                          menuMaxHeight: 300,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description Field
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1700),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'About You (Bio)',
                            prefixIcon: const Icon(Icons.description, color: Colors.blueAccent),
                            suffixIcon: _descriptionController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.blueAccent),
                                    onPressed: () => _descriptionController.clear(),
                                    tooltip: 'Clear description',
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 2),
                            ),
                          ),
                          maxLines: 4,
                          maxLength: 500,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please provide a description';
                            }
                            if (value.length < 20) {
                              return 'Description must be at least 20 characters';
                            }
                            return null;
                          },
                          textInputAction: TextInputAction.done,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 1800),
                        curve: Curves.easeInOut,
                        builder: (context, double value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 50 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                              elevation: 4,
                            ),
                            onPressed: _isSubmitting ? null : _submitForm,
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Submit Registration',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    semanticsLabel: 'Submit Registration',
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to assign icons to services (matching home_service.dart)
  IconData _getServiceIcon(String serviceName) {
    switch (serviceName) {
      case 'Plumbing':
        return Icons.plumbing;
      case 'Electricity':
        return Icons.electrical_services;
      case 'Painting':
        return Icons.format_paint;
      case 'Toilet Unblocking':
        return Icons.bathroom;
      case 'Gardening':
        return Icons.grass;
      case 'Window Cleaning':
        return Icons.window;
      case 'Furniture Repair':
        return Icons.chair;
      default:
        return Icons.build;
    }
  }
}