import 'package:flutter_test/flutter_test.dart';
import 'package:magpie_nest/core/constants/breakpoints.dart';

void main() {
  test('adaptiveLayoutFor maps below medium to compact', () {
    expect(adaptiveLayoutFor(0), AdaptiveLayout.compact);
    expect(adaptiveLayoutFor(599), AdaptiveLayout.compact);
  });

  test('adaptiveLayoutFor maps medium range to medium', () {
    expect(adaptiveLayoutFor(600), AdaptiveLayout.medium);
    expect(adaptiveLayoutFor(839), AdaptiveLayout.medium);
  });

  test('adaptiveLayoutFor maps expanded range to expanded', () {
    expect(adaptiveLayoutFor(840), AdaptiveLayout.expanded);
    expect(adaptiveLayoutFor(1024), AdaptiveLayout.expanded);
  });
}
