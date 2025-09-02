import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midi_location/core/constants/color.dart';
import 'package:midi_location/core/widgets/topbar.dart';
import 'package:midi_location/features/profile/domain/entities/profile.dart';
import 'package:midi_location/features/profile/presentation/providers/edit_profile_provider.dart';
import 'package:midi_location/features/profile/presentation/providers/profile_provider.dart';
import 'package:midi_location/features/profile/presentation/widgets/profile_avatar.dart';
import 'package:midi_location/features/profile/presentation/widgets/textField.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final Profile currentProfile;

  const EditProfilePage({
    super.key,
    required this.currentProfile,
  });

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _nikController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentProfile.name);
    _phoneController = TextEditingController(text: widget.currentProfile.phone);
    _emailController = TextEditingController(text: widget.currentProfile.email);
    _nikController = TextEditingController(text: widget.currentProfile.nik ?? '-');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final notifier = ref.read(editProfileProvider.notifier);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.pop(context);
                  notifier.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.pop(context);
                  notifier.pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onSave() async {
    final notifier = ref.read(editProfileProvider.notifier);
    final success = await notifier.saveProfile(
      name: _nameController.text,
      email: _emailController.text,
      nik: _nikController.text,
      phone: _phoneController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: AppColors.successColor),
      );
      // Refresh provider profil agar data di halaman sebelumnya terupdate
      ref.invalidate(profileDataProvider);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileProvider);
    final profile = widget.currentProfile;

    ref.listen<EditProfileState>(editProfileProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: AppColors.errorColor),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomTopBar.general(
        title: 'Edit Profile',
        showNotificationButton: false,
        leadingWidget: IconButton(
          icon: SvgPicture.asset(
            "assets/icons/left_arrow.svg",
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            ProfileAvatar(
              imageFile: state.imageFile,
              avatarUrl: profile.avatarUrl, // KIRIM URL AVATAR LAMA KE WIDGET
              onEditTap: () => _showImageSourceActionSheet(context),
            ),
            const SizedBox(height: 40),
            
            Column(
              children: [
                ProfileTextField(controller: _nameController, label: "Nama"),
                const SizedBox(height: 16),
                ProfileTextField(
                  controller: _nikController, 
                  label: "NIK", 
                  isEnabled: false,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ProfileTextField(
                  controller: _emailController,
                  label: "Email",
                  isEnabled: false,
                ),
                const SizedBox(height: 16),
                ProfileTextField(
                  controller: _phoneController,
                  label: "Telepon",
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isLoading ? null : _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
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
          ],
        ),
      ),
    );
  }
}

