import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';

// renders posts as a tree, with the OG post as a root node.
class PostTree extends StatefulWidget {
  const PostTree({super.key});

  @override
  State<PostTree> createState() => _PostTreeState();
}

class _PostTreeState extends State<PostTree> {

 final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  Widget build(BuildContext context) {
    return GraphView.builder(
      graph: graph,
      algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
      controller: controller,
      animated: true,
      autoZoomToFit: true,
      builder: (Node node) {
        // I can decide what widget should be shown here based on the id
        var a = node.key.value as int;
        return Text(a.toString());
      },
    );
  }
}
