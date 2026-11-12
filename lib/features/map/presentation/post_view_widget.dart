import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/posts/domain/entities/drawing.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';

/// widget that displays a post's data.
/// pops up from the bottom of the screen.
class PostViewWidget extends StatelessWidget {
  const PostViewWidget({super.key, required this.post, required this.drawing});

  final Post post;
  final Drawing? drawing;

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.imageUrl;
    final drawingUrl = drawing?.imageUrl;

    if (drawingUrl == null) {
      print("Drawing URL null");
    } else {
      print("Drawing URL not null");
    }

    // a post/drawing has no image until its upload has finished.
    // this is a helper method for displaying them null-safely.
    Expanded expanded_image(String? url) {
      return Expanded(
        child: url == null
            ? const Center(child: Icon(Icons.broken_image))
            : CachedNetworkImage(
                imageUrl: url,
                width: double.infinity,
                fit: BoxFit.contain,
                placeholder: (_, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) =>
                    const Center(child: Icon(Icons.broken_image)),
              ),
      );
    }

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height;

          return SizedBox(
            height: availableHeight * 0.8,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.username,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          expanded_image(imageUrl),
                          if (drawing != null) expanded_image(drawingUrl),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
