import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'project_creation_step4.dart';
import 'project_data.dart';

class ProjectCreationStep3 extends StatefulWidget {
  final Project project;
  final String imagePath;
  final Function(Project project) onNext;

  const ProjectCreationStep3({
    Key? key,
    required this.project,
    required this.imagePath,
    required this.onNext,
  }) : super(key: key);

  @override
  _ProjectCreationStep3State createState() => _ProjectCreationStep3State();
}

class _ProjectCreationStep3State extends State<ProjectCreationStep3> {
  List<Offset> _points = [];
  List<List<Offset>> _lines = [];
  bool _isTouchEnabled = false;
  GlobalKey _imageKey = GlobalKey();
  TransformationController _controller = TransformationController();
  Size _imageSize = Size.zero;
  Size _actualImageSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _loadActualImageSize();
  }

  void _loadActualImageSize() async {
    final ImageProvider imageProvider = FileImage(File(widget.imagePath));
    final ImageStream imageStream = imageProvider.resolve(ImageConfiguration.empty);
    ImageStreamListener? listener;
    listener = ImageStreamListener((ImageInfo info, bool syncCall) {
      _actualImageSize = Size(info.image.width.toDouble(), info.image.height.toDouble());
      setState(() {});
      imageStream.removeListener(listener!);
    }, onError: (exception, stackTrace) {
      imageStream.removeListener(listener!);
    });
    imageStream.addListener(listener);
  }

  void _toggleTouch() => setState(() => _isTouchEnabled = !_isTouchEnabled);

  Offset _convertToRelativePosition(Offset globalPosition) {
    final RenderBox imageBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final Offset imagePosition = imageBox.localToGlobal(Offset.zero);
    _imageSize = imageBox.size;
    final Offset relativePosition = globalPosition - imagePosition;
    return Offset(relativePosition.dx / _imageSize.width, relativePosition.dy / _imageSize.height);
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isTouchEnabled) return;
    final Offset relativePosition = _convertToRelativePosition(details.globalPosition);
    setState(() {
      _points.add(relativePosition);
      if (_points.length == 2) {
        _lines.add(List.from(_points));
        _points.clear();
      }
    });
  }

  void _handleLongPress(LongPressStartDetails details) {
    if (_isTouchEnabled) return;
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(details.globalPosition);
    final double scale = 3.0;
    final double centerX = localPosition.dx * scale - (context.size!.width / 2);
    final double centerY = localPosition.dy * scale - (context.size!.height / 2);
    final Matrix4 matrix = Matrix4.identity()
      ..translate(-centerX, -centerY)
      ..scale(scale);
    _controller.value = matrix;
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    _controller.value = Matrix4.identity();
  }

  void _undoLastAction() {
    if (_points.isEmpty && _lines.isEmpty) return;
    setState(() {
      if (_points.isNotEmpty) {
        _points.removeLast();
      } else if (_lines.isNotEmpty) {
        _lines.removeLast();
      }
    });
  }

  void _navigateToStep4() => widget.onNext(widget.project);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step 3: Measure Points'),
        actions: [IconButton(icon: Icon(Icons.navigate_next), onPressed: _navigateToStep4)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTapDown: _handleTapDown,
              onLongPressStart: _handleLongPress,
              onLongPressEnd: _handleLongPressEnd,
              child: InteractiveViewer(
                transformationController: _controller,
                child: Stack(
                  children: [
                    Image.file(File(widget.imagePath), key: _imageKey, fit: BoxFit.contain),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: LinePainter(lines: _lines, points: _points, imageKey: _imageKey, imageSize: _imageSize),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueAccent),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  )
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: DataTable(
                headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                dataTextStyle: TextStyle(color: Colors.black),
                columns: const [
                  DataColumn(label: Text('Line')),
                  DataColumn(label: Text('Start Point')),
                  DataColumn(label: Text('End Point')),
                ],
                rows: _lines.asMap().entries.map((entry) {
                  int idx = entry.key;
                  List<Offset> line = entry.value;
                  return DataRow(cells: [
                    DataCell(Text('Line ${idx + 1}')),
                    DataCell(Text('(${(line[0].dx * _actualImageSize.width).toStringAsFixed(2)}, ${(line[0].dy * _actualImageSize.height).toStringAsFixed(2)})')),
                    DataCell(Text('(${(line[1].dx * _actualImageSize.width).toStringAsFixed(2)}, ${(line[1].dy * _actualImageSize.height).toStringAsFixed(2)})')),
                  ]);
                }).toList(),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _toggleTouch,
            tooltip: 'Toggle Touch',
            child: Icon(_isTouchEnabled ? Icons.not_interested : Icons.touch_app),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: _undoLastAction,
            tooltip: 'Undo Last Action',
            child: Icon(Icons.undo),
          ),
        ],
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Offset> points;
  final GlobalKey imageKey;
  final Size imageSize;

  LinePainter({required this.lines, required this.points, required this.imageKey, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..strokeCap = ui.StrokeCap.round;
    final Paint circlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        final Offset start = Offset(line[i].dx * imageSize.width, line[i].dy * imageSize.height);
        final Offset end = Offset(line[i + 1].dx * imageSize.width, line[i + 1].dy * imageSize.height);
        canvas.drawLine(start, end, linePaint);
        canvas.drawCircle(start, 7.0, circlePaint);
        canvas.drawCircle(end, 7.0, circlePaint);
      }
    }

    for (var point in points) {
      final Offset scaledPoint = Offset(point.dx * imageSize.width, point.dy * imageSize.height);
      canvas.drawCircle(scaledPoint, 7.0, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
