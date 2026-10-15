import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/data/post_data.dart';
import 'package:provider/provider.dart';

/// UI containing buttons that display above the map.
class MapUi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      verticalDirection: VerticalDirection.up,
      children: [
        Consumer<MapModel>(
          builder: (context, map, child) {
            return IconButton(
              onPressed: () {
                map.upload(PostData(location: map.userLocation, title: "new post"));
              },
              icon: Icon(Icons.add),
            ); // post
          },
        ),
        // TODO: add other UI buttons here
      ],
    );
    // TODO: add other columns / rows / aligners with buttons here
  }
}
