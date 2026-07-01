import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gif_view/gif_view.dart';

class ExerciseImage extends StatefulWidget {
  final String gifUrl;
  final List<String> images;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ExerciseImage({
    Key? key,
    required this.gifUrl,
    this.images = const [],
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  _ExerciseImageState createState() => _ExerciseImageState();
}

class _ExerciseImageState extends State<ExerciseImage> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.images.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.images.length;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isNotEmpty) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Image.network(
          widget.images[_currentIndex],
          key: ValueKey<int>(_currentIndex),
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholder();
          },
          errorBuilder: (context, error, stackTrace) => _buildError(),
        ),
      );
    }

    if (widget.gifUrl.isEmpty) {
      return _buildError();
    }

    return GifView.network(
      widget.gifUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[900],
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC74383),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[800],
      child: const Icon(Icons.fitness_center, color: Colors.white54),
    );
  }
}
