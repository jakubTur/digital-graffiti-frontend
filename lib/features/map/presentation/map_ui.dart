import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/data/post_data.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// UI containing buttons that display above the map.
class MapUi extends StatelessWidget {
  const MapUi({super.key});

  Future<void> _createPost(BuildContext context, MapModel map, String path) async {
    final post = map.beginPost(map.userLocation);
    try {
      final image = await context.push<Uint8List>(path, extra: post);
      if (image == null) {
        map.cancelPost();
      } else {
        map.completePost(image);
      }
    } catch (error) {
      map.cancelPost();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post: $error')),
        );
      }
    }
  }

  void _showCanvasOptions(BuildContext context, MapModel map) {
    showDialog(
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _createPost(context, map, '/post/draw');
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _createPost(context, map, '/post/camera');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment(1, 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        verticalDirection: VerticalDirection.up,
        children: [
          Consumer<MapModel>(
            builder: (context, map, child) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: FloatingActionButton(
                    heroTag: 'upload_button',
                    backgroundColor: Colors.deepPurple,
                    onPressed: () {
                      _showCanvasOptions(context, map);
                    },
                    child: const Icon(
                      Icons.add_circle,
                      color: Colors.white,
                      size: 65,
                    ),
                  ),
                ),
              ); // post
            },
          ),
          Consumer<MapModel>(
            builder: (context, map, child) {
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: FloatingActionButton(
                    heroTag: 'location_button',
                    backgroundColor: Colors.deepPurple,
                    onPressed: () {
                      map.moveMap(map.userLocation, 19.4, 0.0);
                    },
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.white,
                      size: 65,
                    ),
                  ), // location
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
