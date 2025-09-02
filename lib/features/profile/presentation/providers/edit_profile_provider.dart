import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:midi_location/features/profile/domain/repositories/profile_repository.dart';
import 'package:midi_location/features/profile/presentation/providers/profile_provider.dart';

// Class untuk menampung state dari halaman edit
class EditProfileState {
  final File? imageFile;
  final bool isLoading;
  final String? errorMessage;

  EditProfileState({
    this.imageFile,
    this.isLoading = false,
    this.errorMessage,
  });

  EditProfileState copyWith({
    File? imageFile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return EditProfileState(
      imageFile: imageFile ?? this.imageFile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// StateNotifier sebagai ViewModel
class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final ProfileRepository _profileRepository;

  EditProfileNotifier(this._profileRepository) : super(EditProfileState());

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 50);

    if (pickedFile != null) {
      state = state.copyWith(imageFile: File(pickedFile.path));
    }
  }

  Future<bool> saveProfile({
    required String name,
    required String email,
    required String phone,
    required String nik,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _profileRepository.updateProfile(
        name: name,
        email: email,
        phone: phone,
        nik: nik,
        avatarFile: state.imageFile,
      );
      state = state.copyWith(isLoading: false);
      return true; // Berhasil
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false; // Gagal
    }
  }
}

// Provider untuk ViewModel kita
final editProfileProvider = StateNotifierProvider<EditProfileNotifier, EditProfileState>((ref) {
  final profileRepository = ref.watch(profileRepositoryProvider);
  return EditProfileNotifier(profileRepository);
});

