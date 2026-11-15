import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/form_main_text.dart';
import 'package:frontend/features/friends/domain/repository/relation_repository.dart';

class FriendsList extends StatelessWidget {
  const FriendsList({super.key, required this.relationRepository});
  final RelationRepository relationRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: .start,
            children: [FormMainText('Invites'), FormMainText('Friends')],
          ),
        ),
      ),
    );
  }
}
