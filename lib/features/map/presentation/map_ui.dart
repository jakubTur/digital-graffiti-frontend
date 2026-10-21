import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/data/post_data.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// UI containing buttons that display above the map.
class MapUi extends StatelessWidget {
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
              return IconButton(
                onPressed: () {
                  context.go('/canvas'); // go to drawing canvas
                  /* 
                  map.upload(
                    PostData(location: map.userLocation, title: "new post"),
                  );
                  */
                },
                icon: Icon(Icons.add_circle),
                iconSize: 72,
              ); // post
            },
          ),
          // TODO: add other UI buttons here
        ],
      ),
    );
    // TODO: add other columns / rows / aligners with buttons here
  }
}
