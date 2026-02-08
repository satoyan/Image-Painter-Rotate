import 'dart:ui';

import 'paint_info.dart';

abstract class PaintAction {
  void undo(List<PaintInfo> paintHistory);
  void redo(List<PaintInfo> paintHistory);
}

class AddAction extends PaintAction {
  final PaintInfo paintInfo;

  AddAction(this.paintInfo);

  @override
  void undo(List<PaintInfo> paintHistory) {
    paintHistory.remove(paintInfo);
  }

  @override
  void redo(List<PaintInfo> paintHistory) {
    paintHistory.add(paintInfo);
  }
}

class MoveAction extends PaintAction {
  final PaintInfo paintInfo;
  final List<Offset?> oldOffsets;
  final List<Offset?> newOffsets;

  MoveAction(this.paintInfo, this.oldOffsets, this.newOffsets);

  @override
  void undo(List<PaintInfo> paintHistory) {
    paintInfo.offsets = oldOffsets;
  }

  @override
  void redo(List<PaintInfo> paintHistory) {
    paintInfo.offsets = newOffsets;
  }
}

class RemoveAction extends PaintAction {
  final PaintInfo paintInfo;
  final int index;

  RemoveAction(this.paintInfo, this.index);

  @override
  void undo(List<PaintInfo> paintHistory) {
    paintHistory.insert(index, paintInfo);
  }

  @override
  void redo(List<PaintInfo> paintHistory) {
    paintHistory.remove(paintInfo);
  }
}
