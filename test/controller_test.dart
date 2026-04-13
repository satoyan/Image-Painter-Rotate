import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_painter_rotate/image_painter_rotate.dart';

void main() {
  group('ImagePainterController', () {
    test('undo() should remove the last paint info', () {
      final controller = ImagePainterController();
      final paintInfo1 = PaintInfo(
          mode: PaintMode.freeStyle,
          color: Colors.red,
          strokeWidth: 1.0,
          offsets: []);
      final paintInfo2 = PaintInfo(
          mode: PaintMode.rect,
          color: Colors.blue,
          strokeWidth: 2.0,
          offsets: []);

      controller.addPaintInfo(paintInfo1);
      controller.addPaintInfo(paintInfo2);

      expect(controller.paintHistory.length, 2);

      controller.undo();

      expect(controller.paintHistory.length, 1);
      expect(controller.paintHistory.first, paintInfo1);
    });

    test('redo() should re-add the last undone paint info', () {
      final controller = ImagePainterController();
      final paintInfo1 = PaintInfo(
          mode: PaintMode.freeStyle,
          color: Colors.red,
          strokeWidth: 1.0,
          offsets: []);
      final paintInfo2 = PaintInfo(
          mode: PaintMode.rect,
          color: Colors.blue,
          strokeWidth: 2.0,
          offsets: []);

      controller.addPaintInfo(paintInfo1);
      controller.addPaintInfo(paintInfo2);
      controller.undo(); // Move paintInfo2 to undotHistory

      expect(controller.paintHistory.length, 1);

      controller.redo();

      expect(controller.paintHistory.length, 2);
      expect(controller.paintHistory.last, paintInfo2);
    });

    test('clear() should clear paintHistory', () {
      final controller = ImagePainterController();
      final paintInfo1 = PaintInfo(
          mode: PaintMode.freeStyle,
          color: Colors.red,
          strokeWidth: 1.0,
          offsets: []);
      final paintInfo2 = PaintInfo(
          mode: PaintMode.rect,
          color: Colors.blue,
          strokeWidth: 2.0,
          offsets: []);

      controller.addPaintInfo(paintInfo1);
      controller.addPaintInfo(paintInfo2);

      expect(controller.paintHistory.length, 2);

      controller.clear();

      expect(controller.paintHistory.length, 0);
    });

    test('detectObject selects line within tolerance and near endpoint', () {
      final controller = ImagePainterController();
      final line = PaintInfo(
        mode: PaintMode.line,
        color: Colors.black,
        strokeWidth: 1.0,
        offsets: [const Offset(0, 0), const Offset(100, 0)],
      );

      controller.addPaintInfo(line);

      expect(controller.detectObject(const Offset(50, 12)), line);
      controller.deselectAll();

      expect(controller.detectObject(const Offset(110, 0)), line);
    });

    test('detectObject selects freeStyle segment', () {
      final controller = ImagePainterController();
      final stroke = PaintInfo(
        mode: PaintMode.freeStyle,
        color: Colors.black,
        strokeWidth: 1.0,
        offsets: [const Offset(0, 0), const Offset(50, 0)],
      );

      controller.addPaintInfo(stroke);

      expect(controller.detectObject(const Offset(25, 12)), stroke);
    });

    test('detectObject selects freeStyle point', () {
      final controller = ImagePainterController();
      final dot = PaintInfo(
        mode: PaintMode.freeStyle,
        color: Colors.black,
        strokeWidth: 1.0,
        offsets: [const Offset(10, 10), null],
      );

      controller.addPaintInfo(dot);

      expect(controller.detectObject(const Offset(20, 10)), dot);
    });

  });
}
