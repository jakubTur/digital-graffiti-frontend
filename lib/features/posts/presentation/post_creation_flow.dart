import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/features/posts/data/post_publisher.dart';
import 'package:frontend/features/posts/domain/entities/post_draft.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

enum _PostSource { drawing, photo }

/// Walks the user through creating a post: choosing its type, making the image, then publishing it.
class PostCreationFlow {
  const PostCreationFlow(this._publisher);

  final PostPublisher _publisher;

  /// Returns true if a post was published.
  Future<bool> run(BuildContext context, LatLng location) async {
    final source = await _chooseSource(context);
    if (source == null || !context.mounted) return false;
    String? backgroundPath;
    if (source == _PostSource.photo) {
      backgroundPath = await context.push<String>('/post/camera');
      if (backgroundPath == null || !context.mounted) return false;
    }
    final image = await context.push<Uint8List>(
      backgroundPath == null ? '/post/draw' : '/post/photo-edit',
      extra: backgroundPath,
    );
    if (image == null) return false;
    try {
      await _publisher.publish(
        PostDraft(location: location, image: image, backgroundPath: backgroundPath),
      );
      return true;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $error')),
        );
      }
      return false;
    }
  }

  /// shows options: create post from drawing, or from photo.
  Future<_PostSource?> _chooseSource(BuildContext context) {
    return showDialog<_PostSource>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Choose Graffiti Type',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Inter',
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton.icon(
              icon: const Icon(Icons.brush),
              label: const Text('Drawing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_PostSource.drawing),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(_PostSource.photo),
            ),
          ],
        );
      },
    );
  }
}
