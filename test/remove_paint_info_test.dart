import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_painter_rotate/image_painter_rotate.dart';

void main() {
  test('removePaintInfo removes object and supports undo/redo', () {
    final controller = ImagePainterController();
    final info = PaintInfo(
      mode: PaintMode.rect,
      offsets: [Offset.zero, const Offset(10, 10)],
      color: Colors.red,
      strokeWidth: 1,
    );

    controller.addPaintInfo(info);
    expect(controller.paintHistory.length, 1);

    controller.removePaintInfo(info);
    expect(controller.paintHistory.length, 0);

    controller.undo();
    expect(controller.paintHistory.length, 1);
    expect(controller.paintHistory.first, info);

    controller.redo();
    expect(controller.paintHistory.length, 0);
  });

  test('removePaintInfo with early return if not found', () {
    final controller = ImagePainterController();
    final info = PaintInfo(
      mode: PaintMode.rect,
      offsets: [Offset.zero, const Offset(10, 10)],
      color: Colors.red,
      strokeWidth: 1,
    );

    // Not added yet
    controller.removePaintInfo(info);
    expect(controller.paintHistory.length, 0);
  });
}
