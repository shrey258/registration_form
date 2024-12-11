import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import 'success_screen.dart';
import '../models/form_data.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class RegistrationFormScreen extends StatefulWidget {
  const RegistrationFormScreen({super.key});

  @override
  State<RegistrationFormScreen> createState() => _RegistrationFormScreenState();
}

class _RegistrationFormScreenState extends State<RegistrationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final List<String> _links = [];
  String? _resumeBase64;
  String? _resumeFileName;
  Uint8List? _resumeBytes;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currentCityController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _roleController = TextEditingController();
  final _expectationsController = TextEditingController();
  final _whyApplyController = TextEditingController();
  final _linkController = TextEditingController();

  static const int _maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentCityController.dispose();
    _experienceController.dispose();
    _roleController.dispose();
    _bioController.dispose();
    _expectationsController.dispose();
    _whyApplyController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        if (file.size > _maxFileSizeInBytes) {
          throw Exception('File size must be less than 5MB');
        }

        if (file.bytes != null) {
          final extension = file.extension?.toLowerCase();
          if (extension != 'pdf' && extension != 'doc' && extension != 'docx') {
            throw Exception('Only PDF, DOC, and DOCX files are allowed');
          }

          final String mimePrefix = extension == 'pdf'
              ? 'data:application/pdf;base64,'
              : 'data:application/msword;base64,';

          final base64String = base64Encode(file.bytes!);
              
          setState(() {
            _resumeBytes = file.bytes;
            _resumeFileName = file.name;
            _resumeBase64 = mimePrefix + base64String;
          });

          print('File picked: ${file.name}');
          print('File size: ${file.size} bytes');
          print('Base64 length: ${_resumeBase64?.length}');
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addLink() {
    final link = _linkController.text.trim();
    if (link.isNotEmpty) {
      if (!link.startsWith('http://') && !link.startsWith('https://')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid URL starting with http:// or https://'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _links.add(link);
        _linkController.clear();
      });
    }
  }

  void _removeLink(int index) {
    setState(() {
      _links.removeAt(index);
    });
  }

  bool _validateForm() {
    if (_roleController.text.isEmpty ||
        _firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _currentCityController.text.isEmpty ||
        _experienceController.text.isEmpty ||
        _bioController.text.isEmpty ||
        _whyApplyController.text.isEmpty ||
        _expectationsController.text.isEmpty ||
        _resumeBase64 == null) {
      return false;
    }
    return true;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _validateForm()) {
      if (_resumeBase64 == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your resume'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        final formData = FormData(
          roleName: _roleController.text.trim(),
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          currentCity: _currentCityController.text.trim(),
          experience: _experienceController.text.trim(),
          bio: _bioController.text.trim(),
          whyApply: _whyApplyController.text.trim(),
          expectationFromRole: _expectationsController.text.trim(),
          resume: _resumeBase64!,
          links: _links,
        );

        final success = await _apiService.submitForm(formData);

        if (mounted) {
          Navigator.pop(context); 
        }

        if (success && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SuccessScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); 
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildResumeUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload your resume *',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _pickFile,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _resumeFileName ?? 'Upload your file here (PDF, DOC, DOCX, max 5MB)',
                        style: TextStyle(
                          color: _resumeFileName != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD233),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.upload_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other links',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _links.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(_links[index]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _removeLink(index),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B6B),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Remove',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    hintText: 'Add link (https://...)',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _addLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD233),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REGISTRATION FORM',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    label: 'Mention the role you are looking for at IM *',
                    hint: 'Enter your role',
                    controller: _roleController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the role';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'First Name *',
                    hint: 'Enter your first name',
                    controller: _firstNameController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Last Name *',
                    hint: 'Enter your last name',
                    controller: _lastNameController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Email *',
                    hint: 'example@domain.com',
                    controller: _emailController,
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Phone Number *',
                    hint: '+91 00000 00000',
                    controller: _phoneController,
                    isRequired: true,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Current City *',
                    hint: 'Add Current City',
                    controller: _currentCityController,
                    isRequired: true,
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current city';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Your Experience *',
                    hint: 'Enter your experience',
                    controller: _experienceController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your experience';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Your Bio *',
                    hint: 'Add your bio',
                    controller: _bioController,
                    isRequired: true,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your bio';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'Why do you want to apply for this role? *',
                    hint: 'Enter your reason',
                    controller: _whyApplyController,
                    isRequired: true,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter why you want to apply';
                      }
                      return null;
                    },
                  ),
                  CustomTextField(
                    label: 'What do you expect out of this role and us? *',
                    hint: 'Enter your expectations',
                    controller: _expectationsController,
                    isRequired: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your expectations';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildResumeUpload(),
                  const SizedBox(height: 24),
                  _buildLinksSection(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD233),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
