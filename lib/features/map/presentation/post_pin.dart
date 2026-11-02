import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/post_data.dart';

/// custom mini-widget describing a post's pin.
/// it can be clicked on to trigger a callback (which will be used for displaying the post)
class PostPin extends StatelessWidget {
  const PostPin({super.key, required this.post, required this.onViewPost});

  final PostData post;
  final ValueChanged<PostData> onViewPost;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'View post',
      onPressed: () => onViewPost(post),
      icon: const Icon(Icons.location_pin, color: Colors.green, size: 40),
    );
  }
}
