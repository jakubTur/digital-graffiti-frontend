import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/core/camera/camera.dart';
import 'package:frontend/features/auth/data/models/user_update_request.dart';
import 'package:frontend/features/auth/domain/repositories/user_repository.dart';
import 'package:frontend/features/drawing/presentation/paint_screen.dart';
import 'package:frontend/features/profile/presentation/square_crop_screen.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/auth_storage.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/user_avatar.dart';

class EditProfileUi extends StatefulWidget {
  final String initialNickname;
  final String initialBio;
  final String? initialProfileImageUrl;
  final UserRepository userRepository;

  final void Function(
    String newNickname,
    String newBio,
    Uint8List? newProfileImage,
  )?
  onSave;

  final VoidCallback? onBackPressed;

  const EditProfileUi(
    this.initialNickname,
    this.initialBio, {
    this.initialProfileImageUrl,
    required this.userRepository,
    this.onSave,
    this.onBackPressed,
    super.key,
  });

  @override
  State<EditProfileUi> createState() => _EditProfileUiState();
}

class _EditProfileUiState extends State<EditProfileUi> {
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;
  Uint8List? _profileImageBytes;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.initialNickname);
    _bioController = TextEditingController(text: widget.initialBio);

    _nicknameController.addListener(_onTextChanged);
    _bioController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool get _hasUnsavedChanges {
    return _nicknameController.text != widget.initialNickname ||
        _bioController.text != widget.initialBio ||
        _profileImageBytes != null;
  }

  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges) return true;

    return ConfirmationDialog.show(
      context: context,
      title: 'Discard changes?',
      content:
          'You have unsaved changes. Are you sure you want to discard them?',
      confirmText: 'Discard',
      isDestructive: true,
    );
  }

  void _handleBackNavigation() async {
    if (await _confirmDiscardChanges()) {
      if (mounted) {
        if (widget.onBackPressed != null) {
          widget.onBackPressed!();
        } else if (context.canPop()) {
          context.pop();
        } else {
          context.go('/map');
        }
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_hasUnsavedChanges) {
      if (widget.onBackPressed != null) {
        widget.onBackPressed!();
      } else if (context.canPop()) {
        context.pop();
      } else {
        context.go('/map');
      }
      return;
    }

    final newNickname = _nicknameController.text;
    final newBio = _bioController.text;

    final bool nicknameOrBioChanged =
        newNickname != widget.initialNickname || newBio != widget.initialBio;
    final bool imageChanged = _profileImageBytes != null;

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = await const AuthStorage(FlutterSecureStorage()).readId();
      if (userId != null) {
        if (nicknameOrBioChanged) {
          final currentUser = await widget.userRepository.getUser(userId);
          final req = UserUpdateRequest(
            nickname: newNickname,
            email: currentUser.email,
            verified: currentUser.verified,
            active: currentUser.active,
            bio: newBio,
          );
          await widget.userRepository.updateUser(userId, req);
        }

        if (imageChanged) {
          final tempDirectory = await Directory.systemTemp.createTemp(
            'profile_picture_upload',
          );
          try {
            final imageFile = File('${tempDirectory.path}/picture.png');
            await imageFile.writeAsBytes(_profileImageBytes!);
            await widget.userRepository.uploadProfilePicture(
              userId,
              imageFile.path,
            );
          } finally {
            await tempDirectory.delete(recursive: true);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });
    }

    if (mounted) {
      if (widget.onSave != null) {
        widget.onSave!(newNickname, newBio, _profileImageBytes);
      } else if (context.canPop()) {
        context.pop({
          'nickname': newNickname,
          'bio': newBio,
          'image': _profileImageBytes,
        });
      } else {
        context.go('/map');
      }
    }
  }

  Future<void> _onCameraButtonPressed() async {
    final String? photoPath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          onPhotoCaptured: (path) async {
            Navigator.of(context).pop(path);
          },
        ),
      ),
    );

    if (photoPath == null || !mounted) return;

    final Uint8List? drawnImageBytes = await Navigator.of(context)
        .push<Uint8List>(
          MaterialPageRoute(
            builder: (context) => PaintScreen(
              imagePath: photoPath,
              onImageCreated: (bytes) {
                Navigator.of(context).pop(bytes);
              },
            ),
          ),
        );

    if (drawnImageBytes == null || !mounted) return;

    final Uint8List? croppedBytes = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (context) => SquareCropScreen(imageBytes: drawnImageBytes),
      ),
    );

    if (croppedBytes != null && mounted) {
      setState(() {
        _profileImageBytes = croppedBytes;
      });
    }
  }

  Future<void> _onPaintButtonPressed() async {
    final Uint8List? drawnImageBytes = await Navigator.of(context)
        .push<Uint8List>(
          MaterialPageRoute(
            builder: (context) => PaintScreen(
              onImageCreated: (bytes) {
                Navigator.of(context).pop(bytes);
              },
            ),
          ),
        );

    if (drawnImageBytes != null && mounted) {
      setState(() {
        _profileImageBytes = drawnImageBytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            ScreenHeader(
              title: 'Edit profile',
              onBackPressed: _handleBackNavigation,
            ),
            Row(
              spacing: 30,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UserAvatar(
                  imageBytes: _profileImageBytes,
                  imageUrl: widget.initialProfileImageUrl,
                ),
                IconButton(
                  onPressed: _onPaintButtonPressed,
                  icon: const Icon(Icons.draw),
                  iconSize: 60,
                  color: Colors.black,
                ),
                IconButton(
                  onPressed: _onCameraButtonPressed,
                  icon: const Icon(Icons.photo_camera),
                  iconSize: 60,
                  color: Colors.black,
                ),
              ],
            ),
            CustomTextField(
              controller: _nicknameController,
              labelText: 'Nickname',
              keyboardType: TextInputType.text,
              maxLength: 20,
            ),
            CustomTextField(
              controller: _bioController,
              labelText: 'Bio',
              keyboardType: TextInputType.name,
              maxLength: 160,
              minLines: 3,
              maxLines: 5,
            ),
            // TODO: remove parameters
            CustomButton(
              text: _isSaving ? 'Saving...' : 'Save changes',
              backgroundColor: Colors.green,
              onPressed: _isSaving ? null : _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
