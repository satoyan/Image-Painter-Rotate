import 'package:flutter_test/flutter_test.dart';
import 'package:image_painter_rotate/src/_paint_over_image.dart';

void main() {
  test('movedOffsetsBySceneDelta applies image-space movement', () {
    final offsets = <Offset?>[
      const Offset(1000, 1000),
      const Offset(1100, 1000),
      null,
      const Offset(1200, 1100),
    ];

    final moved = movedOffsetsBySceneDelta(
      offsets,
      const Offset(200, 50),
    );

    expect(moved, [
      const Offset(1200, 1050),
      const Offset(1300, 1050),
      null,
      const Offset(1400, 1150),
    ]);
    expect(offsets[0], const Offset(1000, 1000));
  });
}
