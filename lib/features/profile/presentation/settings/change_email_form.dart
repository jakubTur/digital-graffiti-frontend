import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/datasources/auth_storage.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/core/widgets/form_secondary_text.dart';
import 'package:frontend/core/widgets/screen_header.dart';
import 'package:frontend/features/auth/data/models/user_response.dart';
import 'package:frontend/features/auth/data/models/user_update_request.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/form_main_text.dart';
import '../../../auth/data/models/credential_request.dart';
import '../../../auth/domain/repositories/user_repository.dart';

class ChangeEmailForm extends StatefulWidget {
  const ChangeEmailForm(this._authStorage, this._userRepository, {super.key});

  final AuthStorage _authStorage;
  final UserRepository _userRepository;

  @override
  State<StatefulWidget> createState() {
    return _ChangeEmailFormState();
  }
}

class _ChangeEmailFormState extends State<ChangeEmailForm> {
  final TextEditingController _currentEmailController = TextEditingController();
  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _repeatEmailController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _emailError;

  @override
  void dispose() {
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _repeatEmailController.dispose();
    super.dispose();
  }

  void _onPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _emailError = null;
    });

    try {
      int? id = await widget._authStorage.readUserId();
      if (id == null) {
        throw Exception('User ID not found');
      }

      UserResponse userData = await widget._userRepository.getUser(id);
      if (userData.email != _currentEmailController.text) {
        throw Exception('Current email is incorrect');
      }

      String newEmail = _newEmailController.text;
      CredentialRequest credentialsRequest = CredentialRequest(
        email: newEmail,
        password: '',
      );
      await widget._userRepository.updateEmail(id, credentialsRequest);

      UserUpdateRequest userRequest = UserUpdateRequest(
        nickname: userData.nickname,
        email: newEmail,
        verified: userData.verified,
        active: userData.active,
        bio: userData.bio,
      );
      await widget._userRepository.updateUser(id, userRequest);

      widget._authStorage.clear();

      if (context.mounted) {
        context.go('/email-changed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = 'Incorrect current email';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                Align(alignment: Alignment.topRight, child: ScreenHeader()),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 30,
                  children: [
                    FormMainText('Change email'),
                    FormSecondaryText(
                      'Enter your current email and your new email address',
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        spacing: 30,
                        children: [
                          CustomTextField(
                            controller: _currentEmailController,
                            labelText: 'Current email',
                            errorText: _emailError,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter your current email';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _newEmailController,
                            labelText: 'New email',
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please enter a new email';
                              }
                              final emailRegex = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegex.hasMatch(v.trim())) {
                                return 'Please enter a valid email address';
                              }
                              if (v == _currentEmailController.text) {
                                return 'New email must be different';
                              }
                              return null;
                            },
                          ),
                          CustomTextField(
                            controller: _repeatEmailController,
                            labelText: 'Repeat new email',
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Please repeat your new email';
                              }
                              if (v != _newEmailController.text) {
                                return 'Emails do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    CustomButton(
                      text: 'Change email',
                      onPressed: _onPressed,
                      backgroundColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
