import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/data/post_data.dart';
import 'package:provider/provider.dart';

/// UI containing buttons that display above the map.
class MapUi extends StatelessWidget {
  const MapUi({super.key});

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
                      map.upload(
                        PostData(location: map.userLocation, title: "new post"),
                      ); // TODO replace this with local post UI
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
          // TODO: add other UI buttons here
        ],
      ),
    );
    // TODO: add other columns / rows / aligners with buttons here
  }
}
