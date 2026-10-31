import 'package:flutter/material.dart';
import 'package:frontend/features/profile/data/user_relation_initiator.dart';
import 'package:frontend/features/profile/data/user_relation_status.dart';
import 'package:go_router/go_router.dart';

class ProfileUi extends StatelessWidget {
  const ProfileUi(this._relationStatus, {super.key, this._relationInitiator});

  final UserRelationStatus _relationStatus;

  final UserRelationInitiator? _relationInitiator;

  //TODO: implement the placeholder funtions

  void _blockUser() {}

  void _reportUser() {}

  void _unblockUser() {}

  void _removeFriend() {}

  void _acceptFriendRequest() {}

  void _sendFriendRequest() {}

  void _declineFriendRequest() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(left: 12.0, right: 12.0, bottom: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.0),
              border: Border.all(color: Colors.white38, width: 1),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 12),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 10,
                  children: [
                    Row(
                      children: [
                        if (_relationStatus != UserRelationStatus.SELF) ...[
                          IconButton(
                            onPressed: _reportUser,
                            iconSize: 60,
                            icon: const Icon(Icons.report, color: Colors.black),
                          ),
                          IconButton(
                            onPressed: _blockUser,
                            iconSize: 60,
                            icon: const Icon(Icons.block, color: Colors.black),
                          ),
                        ],
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/map');
                            }
                          },
                          iconSize: 60,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.purple,
                      ),
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Nickname',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_relationStatus != UserRelationStatus.BLOCKED) ...[
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'bio bio bi obio bo ibo ibo iobi obioibo bo bo ibo iobi obi oiob',
                          style: TextStyle(fontSize: 20, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...[
                        switch (_relationStatus) {
                          UserRelationStatus.PENDING =>
                            throw UnimplementedError(),
                          // TODO: Handle this case.
                          UserRelationStatus.ACCEPTED =>
                            throw UnimplementedError(),
                          // TODO: Handle this case.
                          UserRelationStatus.DECLINED =>
                            throw UnimplementedError(),
                          // TODO: Handle this case.
                          UserRelationStatus.BLOCKED =>
                            throw UnimplementedError(),
                          // TODO: Handle this case.
                          UserRelationStatus.SELF => throw UnimplementedError(),
                        },
                      ],

                      //TODO: other options if not the owner
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Posts',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      //TODO: List of posts
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
