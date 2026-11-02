enum AdaptiveLayout { compact, medium, expanded }

const double kMediumBreakpoint = 600;
const double kExpandedBreakpoint = 840;

AdaptiveLayout adaptiveLayoutFor(double width) {
  return switch (width) {
    >= kExpandedBreakpoint => AdaptiveLayout.expanded,
    >= kMediumBreakpoint => AdaptiveLayout.medium,
    _ => AdaptiveLayout.compact,
  };
}
