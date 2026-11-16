import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/entities/post.dart';
import 'post_card.dart';

enum PostSortCriteria { date, distance }

class PostList extends StatefulWidget {
  const PostList({
    super.key,
    required this.posts,
    this.userPosition,
    this.onPostTap,
  });

  final List<Post> posts;
  final Position? userPosition;
  final ValueChanged<Post>? onPostTap;

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  PostSortCriteria _sortCriteria = PostSortCriteria.date;

  double? _calculateDistance(Post post) {
    if (widget.userPosition == null) return null;
    return Geolocator.distanceBetween(
      widget.userPosition!.latitude,
      widget.userPosition!.longitude,
      post.latitude,
      post.longitude,
    );
  }

  List<Post> get _sortedPosts {
    final sorted = List<Post>.from(widget.posts);
    if (_sortCriteria == PostSortCriteria.date) {
      sorted.sort((a, b) => b.postedAt.compareTo(a.postedAt));
    } else {
      if (widget.userPosition != null) {
        sorted.sort((a, b) {
          final distA = _calculateDistance(a) ?? double.infinity;
          final distB = _calculateDistance(b) ?? double.infinity;
          return distA.compareTo(distB);
        });
      } else {
        sorted.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      }
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return const SizedBox.shrink();
    }

    final postsToDisplay = _sortedPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'Order by:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text('Date'),
              selected: _sortCriteria == PostSortCriteria.date,
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: _sortCriteria == PostSortCriteria.date
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _sortCriteria = PostSortCriteria.date;
                  });
                }
              },
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('Distance'),
              selected: _sortCriteria == PostSortCriteria.distance,
              selectedColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: _sortCriteria == PostSortCriteria.distance
                    ? Colors.white
                    : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _sortCriteria = PostSortCriteria.distance;
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: postsToDisplay.map((post) {
            return PostCard(
              post: post,
              distanceInMeters: _calculateDistance(post),
              onTap: widget.onPostTap != null
                  ? () => widget.onPostTap!(post)
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }
}
