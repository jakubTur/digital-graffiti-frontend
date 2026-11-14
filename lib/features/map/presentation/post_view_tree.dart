import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/map/data/map_model.dart';
import 'package:frontend/features/posts/domain/entities/drawing.dart';
import 'package:frontend/features/posts/domain/entities/post.dart';
import 'package:frontend/features/posts/presentation/drawing_view_node.dart';
import 'package:frontend/features/posts/presentation/post_creation_flow.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';

/// class for displaying a post and its child drawings in a tree.
/// uses GraphView.
class PostViewTree extends StatelessWidget {
  const PostViewTree(this._postCreationFlow, {super.key});

  final PostCreationFlow _postCreationFlow;

  @override
  Widget build(BuildContext context) {
    return Selector<MapModel, (Post?, List<Drawing>?, String?)>(
      selector: (_, map) =>
          (map.postToView, map.drawingsOnPostToView, map.currentUsername),
      builder: (context, data, _) {
        final (post, drawings, currentUsername) = data;
        if (post == null) return const SizedBox.shrink();
        final map = context.read<MapModel>();
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) map.clearPostToView();
          },
          child: ColoredBox(
            color: Colors.black54,
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildTree(
                      context,
                      map,
                      post,
                      drawings ?? const [],
                      currentUsername,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      tooltip: 'Close',
                      onPressed: map.clearPostToView,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTree(
    BuildContext context,
    MapModel map,
    Post post,
    List<Drawing> drawings,
    String? currentUsername,
  ) {
    final children = <int, List<Drawing>>{};
    for (final drawing in drawings) {
      if (drawing.id == null) continue;
      children.putIfAbsent(drawing.parent_id, () => []).add(drawing);
    }
    for (final siblings in children.values) {
      siblings.sort(_byAge);
    }

    final roots = children[-1];
    if (roots == null || roots.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white, size: 48),
      );
    }
    final root = roots.first;

    final graph = Graph()..isTree = true;
    final nodeDrawings = <int, Drawing>{};
    final nodeLayers = <int, List<ImageProvider>>{};

    void addSubtree(Drawing drawing, List<ImageProvider> parentLayers) {
      final imageUrl = drawing.imageUrl;
      nodeDrawings[drawing.id!] = drawing;
      nodeLayers[drawing.id!] = [
        ...parentLayers,
        if (imageUrl != null) CachedNetworkImageProvider(imageUrl),
      ];
      for (final child in (children[drawing.id!] ?? const []).reversed) {
        graph.addEdge(Node.Id(drawing.id!), Node.Id(child.id!));
        addSubtree(child, nodeLayers[drawing.id!]!);
      }
    }

    final postImageUrl = post.imageUrl;
    graph.addNode(Node.Id(root.id!));
    addSubtree(root, [
      if (postImageUrl != null) CachedNetworkImageProvider(postImageUrl),
    ]);

    final configuration = BuchheimWalkerConfiguration()
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_LEFT_RIGHT
      ..siblingSeparation = 40
      ..levelSeparation = 80
      ..subtreeSeparation = 40;

    return GraphView.builder(
      key: ValueKey(post.id),
      graph: graph,
      algorithm: BuchheimWalkerAlgorithm(
        configuration,
        TreeEdgeRenderer(configuration),
      ),
      paint: Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
      autoZoomToFit: true,
      builder: (node) {
        final id = node.key!.value as int;
        final drawing = nodeDrawings[id]!;
        final layers = nodeLayers[id]!;
        return DrawingViewNode(
          drawing: drawing,
          layers: layers,
          isOwn: drawing.username == currentUsername,
          onDraw: () async {
            if (await _postCreationFlow.drawOn(context, drawing, layers)) {
              map.requestPostView(post);
            }
          },
        );
      },
    );
  }

  static int _byAge(Drawing a, Drawing b) {
    final aPostedAt = a.postedAt;
    final bPostedAt = b.postedAt;
    if (aPostedAt != null && bPostedAt != null) {
      return aPostedAt.compareTo(bPostedAt);
    }
    return a.id!.compareTo(b.id!);
  }
}
