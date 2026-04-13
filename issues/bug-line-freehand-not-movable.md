# Bug: line/freehand objects cannot be moved by drag

## Summary
Line and freehand drawing objects cannot be moved via drag after selection. Other shapes can be moved as expected.

## Environment
- Package: image_painter_rotate
- App: example
- Flutter: stable (per README)

## Steps to Reproduce
1. Open the example app.
2. Draw a Line.
3. Tap to select the line (marching ants appears).
4. Drag the selected line.
5. Repeat with Freehand.

## Expected
Selected line/freehand objects move with the drag gesture (same as rectangle/circle/etc).

## Actual
Line/freehand objects do not move; drag has no effect.

## Notes
- Likely related to selection hit-testing or move offset application for these modes.
