import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:provider/provider.dart';

/// custom mini-widget describing a post's pin.
/// it can be clicked on to trigger a callback (which will be used for displaying the post)
class PostPin extends StatelessWidget {
  const PostPin({super.key, required this.post, required this.onViewPost});

  final Post post;
  final ValueChanged<Post> onViewPost;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'View post',
      onPressed: () {
        try {
          final mapModel = context.read<MapModel>();
          if (!mapModel.isPostWithinViewDistance(post)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'You must be within 10 meters to open this post.',
                ),
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }
        } catch (_) {}
        onViewPost(post);
      },
      icon: const Icon(Icons.location_pin, color: Colors.green, size: 40),
    );
  }
}
