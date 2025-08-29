// ignore_for_file: use_super_parameters, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:midi_location/core/constants/color.dart';

class EditProfilePage extends StatefulWidget {
  final String currentEmail;
  final String currentPhone;
  final String currentName;
  final String currentPosition;
  final String currentBranch;

  const EditProfilePage({
    Key? key,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentName,
    required this.currentPosition,
    required this.currentBranch,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _positionController;
  late TextEditingController _branchController;

  late FocusNode _nameFocusNode;
  late FocusNode _emailFocusNode;
  late FocusNode _phoneFocusNode;
  late FocusNode _positionFocusNode;
  late FocusNode _branchFocusNode;

  bool _nameHasFocus = false;
  bool _emailHasFocus = false;
  bool _phoneHasFocus = false;
  bool _positionHasFocus = false;
  bool _branchHasFocus = false;

  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _positionController = TextEditingController(text: widget.currentPosition);
    _branchController = TextEditingController(text: widget.currentBranch);

    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _positionFocusNode = FocusNode();
    _branchFocusNode = FocusNode();

    _nameFocusNode.addListener(() {
      setState(() {
        _nameHasFocus = _nameFocusNode.hasFocus;
      });
    });
    _emailFocusNode.addListener(() {
      setState(() {
        _emailHasFocus = _emailFocusNode.hasFocus;
      });
    });
    _phoneFocusNode.addListener(() {
      setState(() {
        _phoneHasFocus = _phoneFocusNode.hasFocus;
      });
    });
    _positionFocusNode.addListener(() {
      setState(() {
        _positionHasFocus = _positionFocusNode.hasFocus;
      });
    });
    _branchFocusNode.addListener(() {
      setState(() {
        _branchHasFocus = _branchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _branchController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _positionFocusNode.dispose();
    _branchFocusNode.dispose();

    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required FocusNode focusNode,
    required bool hasFocus,
    double fontSize = 16,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: fontSize),
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: AppColors.black),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 75, bottom: 40),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  Positioned(
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        "assets/icons/left_arrow.svg",
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.textColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 120,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.transparent,

                      child:
                          _imageFile != null
                              ? ClipOval(
                                child: Image.file(
                                  _imageFile!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : SvgPicture.asset(
                                "assets/icons/avatar.svg",
                                width: 100,
                                height: 100,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.black,
                                  BlendMode.srcIn,
                                ),
                              ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 27,
                    right: screenWidth * 0.36,
                    child: GestureDetector(
                      onTap: () {
                        _showImageSourceActionSheet(context);
                      },
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white,
                        child: SvgPicture.asset(
                          "assets/icons/edit_profile.svg",
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primaryColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: "Nama",
                    hint: "Apriyanto Dwi Herlambang",
                    fontSize: 14,
                    focusNode: _nameFocusNode,
                    hasFocus: _nameHasFocus,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: "Email",
                    hint: "email@mu.co.id",
                    fontSize: 14,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocusNode,
                    hasFocus: _emailHasFocus,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: "Phone",
                    hint: "+62 812 - 1234 - 1234",
                    fontSize: 14,
                    keyboardType: TextInputType.phone,
                    focusNode: _phoneFocusNode,
                    hasFocus: _phoneHasFocus,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _positionController,
                    label: "Position",
                    hint: "Location Manager",
                    fontSize: 14,
                    focusNode: _positionFocusNode,
                    hasFocus: _positionHasFocus,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _branchController,
                    label: "Branch",
                    hint: "Head Office",
                    fontSize: 14,
                    focusNode: _branchFocusNode,
                    hasFocus: _branchHasFocus,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'name': _nameController.text,
                          'email': _emailController.text,
                          'phone': _phoneController.text,
                          'position': _positionController.text,
                          'branch': _branchController.text,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cardColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
