import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/image_size.dart';

/// Gradient banner with the back button and the album cover.
class AlbumHeader extends StatelessWidget {
  final String coverUrl;
  const AlbumHeader({super.key, required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF97316), Color(0xFF7C3AED)],
        ),
      ),
      child: const Icon(Icons.album_rounded, color: Colors.white70, size: 56),
    );

    return Container(
      height: 285,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            Center(
              child: Container(
                width: 167,
                height: 167,
                margin: const EdgeInsets.only(top: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: coverUrl.trim().isEmpty
                      ? fallback
                      : CachedNetworkImage(
                          imageUrl: CloudinaryImage.resize(
                            coverUrl,
                            width: 334,
                          ),
                          fit: BoxFit.cover,
                          placeholder: (_, _) => fallback,
                          errorWidget: (_, _, _) => fallback,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
