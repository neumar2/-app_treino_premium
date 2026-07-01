import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'muscle_paths.dart';

class MuscleMapWidget extends StatefulWidget {
  final bool isMale;
  final Function(String) onMuscleTapped;
  final List<String> highlightedMuscles;
  final bool selectionMode;
  final Map<String, int> muscleCounts;

  const MuscleMapWidget({
    Key? key,
    required this.isMale,
    required this.onMuscleTapped,
    this.highlightedMuscles = const [],
    this.selectionMode = false,
    this.muscleCounts = const {},
  }) : super(key: key);

  @override
  _MuscleMapWidgetState createState() => _MuscleMapWidgetState();
}

class _MuscleMapWidgetState extends State<MuscleMapWidget> {
  String? _hoveredMuscle;
  bool _isFront = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTapUp: (details) {
                _handleTap(details.localPosition, constraints.biggest);
              },
              child: CustomPaint(
                size: constraints.biggest,
                painter: MusclePainter(
                  isMale: widget.isMale,
                  isFront: _isFront,
                  hoveredMuscle: _hoveredMuscle,
                  highlightedMuscles: widget.highlightedMuscles,
                  selectionMode: widget.selectionMode,
                  muscleCounts: widget.muscleCounts,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.flip, color: Colors.white, size: 28),
                onPressed: () {
                  setState(() {
                    _isFront = !_isFront;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleTap(Offset position, Size size) {
    final Map<String, List<String>> paths = _isFront
        ? (widget.isMale ? MusclePaths.maleFront : MusclePaths.femaleFront)
        : (widget.isMale ? MusclePaths.maleBack : MusclePaths.femaleBack);

    const double originalWidth = 700.0;
    const double originalHeight = 1400.0;
    
    final double scaleX = size.width / originalWidth;
    final double scaleY = size.height / originalHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;
    
    final double offsetX = (size.width - originalWidth * scale) / 2;
    final double offsetY = (size.height - originalHeight * scale) / 2;

    double svgX = (position.dx - offsetX) / scale;
    final double svgY = (position.dy - offsetY) / scale;
    
    // Se for as costas, os paths no SVG original comeÃ§am em X > 700
    if (!_isFront) {
      svgX += 700.0;
    }
    
    final Offset svgPoint = Offset(svgX, svgY);

    for (var entry in paths.entries) {
      final muscleName = entry.key;
      for (var pathString in entry.value) {
        final path = parseSvgPathData(pathString);
        if (path.contains(svgPoint)) {
          widget.onMuscleTapped(muscleName);
          if (!widget.selectionMode) {
            setState(() {
              _hoveredMuscle = muscleName;
            });
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted && _hoveredMuscle == muscleName) {
                setState(() {
                  _hoveredMuscle = null;
                });
              }
            });
          }
          return;
        }
      }
    }
  }
}

class MusclePainter extends CustomPainter {
  final bool isMale;
  final bool isFront;
  final String? hoveredMuscle;
  final List<String> highlightedMuscles;
  final bool selectionMode;
  final Map<String, int> muscleCounts;

  MusclePainter({
    required this.isMale,
    required this.isFront,
    this.hoveredMuscle,
    required this.highlightedMuscles,
    required this.selectionMode,
    this.muscleCounts = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Map<String, List<String>> paths = isFront
        ? (isMale ? MusclePaths.maleFront : MusclePaths.femaleFront)
        : (isMale ? MusclePaths.maleBack : MusclePaths.femaleBack);
    
    const double originalWidth = 700.0;
    const double originalHeight = 1400.0;
    
    final double scaleX = size.width / originalWidth;
    final double scaleY = size.height / originalHeight;
    final double scale = scaleX < scaleY ? scaleX : scaleY;
    
    final double offsetX = (size.width - originalWidth * scale) / 2;
    final double offsetY = (size.height - originalHeight * scale) / 2;

    canvas.translate(offsetX, offsetY);
    canvas.scale(scale, scale);

    if (!isFront) {
      canvas.translate(-700.0, 0);
    }

    final Paint defaultPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;
      
    final Paint outlinePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint highlightPaint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    final Paint activePaint = Paint()
      ..color = const Color(0xFFC74383).withOpacity(0.6)
      ..style = PaintingStyle.fill;

    for (var entry in paths.entries) {
      final muscleName = entry.key;
      final isHovered = hoveredMuscle == muscleName;
      final isHighlighted = highlightedMuscles.contains(muscleName);
      
      Paint currentPaint = defaultPaint;
      if (isHovered) {
        currentPaint = highlightPaint;
      } else if (isHighlighted || (muscleCounts[muscleName] ?? 0) > 0) {
        currentPaint = activePaint;
      }
      
      Rect? combinedBounds;
      for (var pathString in entry.value) {
        final path = parseSvgPathData(pathString);
        canvas.drawPath(path, currentPaint);
        canvas.drawPath(path, outlinePaint);
        
        if (combinedBounds == null) {
          combinedBounds = path.getBounds();
        } else {
          combinedBounds = combinedBounds.expandToInclude(path.getBounds());
        }
      }
      
      if (muscleCounts.containsKey(muscleName) && combinedBounds != null) {
        final int count = muscleCounts[muscleName]!;
        if (count > 0) {
          final Offset center = combinedBounds.center;
          final Paint badgePaint = Paint()..color = Colors.white;
          canvas.drawCircle(center, 18.0, badgePaint);
          
          final textSpan = TextSpan(
            text: count.toString(),
            style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.center,
          );
          textPainter.layout();
          final offset = Offset(center.dx - (textPainter.width / 2), center.dy - (textPainter.height / 2));
          textPainter.paint(canvas, offset);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant MusclePainter oldDelegate) {
    return oldDelegate.hoveredMuscle != hoveredMuscle || 
           oldDelegate.isMale != isMale ||
           oldDelegate.isFront != isFront ||
           oldDelegate.highlightedMuscles != highlightedMuscles ||
           oldDelegate.muscleCounts != muscleCounts;
  }
}
