import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../domain/entities/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.distanceInMeters,
    this.distance,
    this.postedOn,
    this.onTap,
  });

  final Post post;
  final double? distanceInMeters;
  final String? distance;
  final String? postedOn;
  final VoidCallback? onTap;

  String get _formattedDistance {
    if (distance != null && distance!.isNotEmpty) {
      return distance!;
    }
    if (distanceInMeters == null) {
      return 'Distance unknown';
    }
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.round()} m';
    } else {
      final km = distanceInMeters! / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  String get _formattedDate {
    if (postedOn != null && postedOn!.isNotEmpty) {
      return postedOn!;
    }
    return DateFormat('dd-MM-yyyy HH:mm').format(post.postedAt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          size: 16,
                          color: Colors.deepPurple.shade400,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          _formattedDistance,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.deepPurple.shade300,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
