import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/core/camera/camera.dart';
import 'package:frontend/features/drawing/presentation/paint_screen.dart';
import 'package:frontend/features/profile/presentation/profile_button.dart';
import 'package:frontend/features/profile/presentation/square_crop_screen.dart';
import 'package:go_router/go_router.dart';

class EditProfileUi extends StatefulWidget {
  final String initialNickname;
  final String initialBio;
  final Uint8List? initialProfileImage;

  // TODO: like in profile_popup, the parameters are not required after the backend integration
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
    this.initialProfileImage,
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

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController(text: widget.initialNickname);
    _bioController = TextEditingController(text: widget.initialBio);
    _profileImageBytes = widget.initialProfileImage;

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
        _profileImageBytes != widget.initialProfileImage;
  }

  //TODO: refactor and reuse for closing the drawing screen
  Future<bool> _confirmDiscardChanges() async {
    if (!_hasUnsavedChanges) return true;

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
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
            Row(
              children: [
                const Text(
                  'Edit profile',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _handleBackNavigation,
                  iconSize: 60,
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                ),
              ],
            ),
            Row(
              spacing: 30,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipOval(
                  child: Container(
                    width: 120,
                    height: 120,
                    color: Colors.deepPurple.shade50,
                    child: _profileImageBytes != null
                        ? Image.memory(
                            _profileImageBytes!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 120,
                            color: Colors.deepPurple,
                          ),
                  ),
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
            TextFormField(
              controller: _nicknameController,
              keyboardType: TextInputType.text,
              style: const TextStyle(color: Colors.black),
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                labelStyle: TextStyle(color: Colors.black),
                fillColor: Color(0xFFE6E0E9),
                filled: true,
              ),
            ),
            TextFormField(
              controller: _bioController,
              keyboardType: TextInputType.name,
              style: const TextStyle(color: Colors.black),
              maxLength: 160,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Bio',
                labelStyle: TextStyle(color: Colors.black),
                fillColor: Color(0xFFE6E0E9),
                filled: true,
              ),
            ),
            // TODO: remove parameters
            ProfileButton('Save changes', () {
              if (widget.onSave != null) {
                widget.onSave!(
                  _nicknameController.text,
                  _bioController.text,
                  _profileImageBytes,
                );
              } else if (context.canPop()) {
                context.pop({
                  'nickname': _nicknameController.text,
                  'bio': _bioController.text,
                  'image': _profileImageBytes,
                });
              } else {
                context.go('/map');
              }
            }, Colors.green),
          ],
        ),
      ),
    );
  }
}
