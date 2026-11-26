import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/map/presentation/post_pin.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import '../data/map_model.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class DisplayMap extends StatefulWidget {
  const DisplayMap({super.key});

  @override
  State<DisplayMap> createState() => _DisplayMapState();
}

class _DisplayMapState extends State<DisplayMap> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final mapModel = Provider.of<MapModel>(context, listen: false);
    mapModel.vsync = this;
    mapModel.startUserLocationUpdates();
  }

  // Quick and dirty marker maker
  Marker createMarkerFromData(LatLng location, IconData icon, Color color) {
    return Marker(
      point: location,
      width: 80,
      height: 80,
      child: Icon(icon, color: color, size: 24.0, semanticLabel: 'Marker'),
    );
  }


  List<Marker> buildMarkers(
  List<Post> posts,
  ValueChanged<Post> onViewPost,
) {
  List<Marker> markers = [];

    

for (Post post in posts) {
  markers.add(
    Marker(
      key: ValueKey<Post>(post),
      point: LatLng(post.latitude, post.longitude),
      width: 80,
      height: 80,
      child: Builder(
        builder: (context) {
          final isRead =
              context.watch<MapModel>().isPostRead(post);

          final pin = PostPin(
            post: post,
            onViewPost: onViewPost,
          );

          if (!isRead) {
            return pin;
          }

          return Opacity(
            opacity: 0.5,
            child: ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0, 0, 0, 1, 0,
              ]),
              child: pin,
            ),
          );
        },
      ),
    ),
  );
}


    return markers;
  }

  /// Builds the map. Called again when the map changes.
  @override
  Widget build(BuildContext context) {
    final mapModel = Provider.of<MapModel>(context, listen: false);

    return FlutterMap(
      mapController: mapModel.mapController,
      options: const MapOptions(),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: "digital-graffiti",
        ),
        
Consumer<MapModel>(
  builder: (context, map, child) {
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        markers: buildMarkers(
          map.visiblePosts,
          map.requestPostView,
        ),
zoomToBoundsOnClick: false,
spiderfyCluster: false,

onClusterTap: (cluster) {
  final clusterPosts = cluster.mapMarkers
      .map((marker) => (marker.key as ValueKey<Post>).value)
      .toList();

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.6,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '${clusterPosts.length} posts in this cluster',
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: clusterPosts.length,
                  itemBuilder: (context, index) {
                    final post = clusterPosts[index];

                    return ListTile(
                      leading: const Icon(Icons.article_outlined),
                      title: Text('Post #${post.id}'),
                      subtitle: Text('By ${post.username}'),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        map.requestPostView(post);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
},

        maxClusterRadius: 60,
        size: const Size(48, 48),
        padding: const EdgeInsets.all(50),
        maxZoom: 18,
        rotate: true,
        builder: (context, clusteredMarkers) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '${clusteredMarkers.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
      
    );
  },
),


Consumer<MapModel>(
  builder: (context, map, child) {
    return MarkerLayer(
      markers: [
        createMarkerFromData(
          map.userLocation,
          Icons.man,
          Colors.blue,
        ),
      ],
      rotate: true,
    );
  },
),

      ],
    );
  }
}
