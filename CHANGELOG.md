# 1.1.0

- Feat: Support for removing specific drawing objects via a contextual delete menu (triggered by long-press).
- Feat: Added `removePaintInfo` and `deleteSelectedObject` to `ImagePainterController` with full undo/redo support.
- Feat: Added `onObjectLongPress` callback to `ImagePainter` for custom object interactions.
- Chore: Upgraded `devDependencies` (`mockito`, `build_runner`, `build_test`) to their latest compatible versions.
- Chore: Upgraded environment support to Flutter 3.38.7 and Dart 3.10.3.

# 1.0.4

- Fix: Test errors after fixing lint errors.
- Chore: Upgrade Gradle and Kotlin versions for the example app.

# 1.0.3

- Fix: Resolved an issue where undo functionality failed when the painter was initialized with existing paint histories.

# 1.0.2

- Fix: Export `PaintInfo` class to fix backward compatibility.

# 1.0.1

- Refactor: Extracted `PaintMode` and `PaintInfo` into separate files for better modularity.
- Refactor: Improved painting logic and `detectObject` method readability by extracting helper methods.
- Fix: Prevented unwanted lines when switching to freehand mode by clearing offsets.
- Feat: Added detection for `dashLine` objects in `detectObject` method.

# 1.0.0

- Implement movable drawing objects with undo/redo and dotted selection.
- Movable Drawing Objects: Users can now select and drag previously drawn objects (rectangles, lines, circles, arrows, text) on the canvas.
- Undo/Redo for Move Operations: The undo/redo functionality has been extended to support moving objects, allowing users to revert or reapply move actions.
- "Marching Ants" Selection Border: A dynamic, animated dashed border (marching ants effect) is now displayed around selected drawing objects, improving visibility on various backgrounds.
- Deselect on Empty Tap: Tapping on an empty area of the canvas now deselects any currently selected drawing object.

# 0.8.4

- Add DrawingUtils and tests for image painting utilities.

# 0.8.3

- Update sample screeshot

# 0.8.1

- Support image content padding.
- Support redo includes UI.
- Support image rotation with RotatedBox.