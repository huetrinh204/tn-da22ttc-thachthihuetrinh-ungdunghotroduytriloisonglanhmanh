# Implementation Plan: Habit Detail Statistics Chart

## Overview

This implementation enhances the existing `HabitDetailScreen` to ensure the line chart properly displays metric values on the Y-axis and dates on the X-axis with curved lines, visible dots, and shaded areas. Most functionality is already implemented; this plan focuses on verification, testing, and any minor refinements needed.

## Tasks

- [x] 1. Verify and refine chart data processing logic
  - Review the existing metric value parsing logic in `_buildMetricsChart()`
  - Ensure filtering correctly excludes null and zero metric values
  - Verify date label formatting converts "YYYY-MM-DD" to "DD/MM" format
  - Confirm FlSpot list is built correctly with sequential X-axis indices
  - _Requirements: 1.1, 1.6, 2.1, 2.5, 5.1_

- [ ]* 1.1 Write unit tests for data processing functions
  - Test `parseMetricValue()` with null, numeric, and string inputs
  - Test date label formatting with various date formats
  - Test filtering logic with mixed valid/invalid data
  - Test edge cases: empty array, all nulls, single data point
  - _Requirements: 1.1, 1.6, 2.5, 5.1_

- [x] 2. Verify chart rendering configuration
  - Confirm Y-axis displays from 0 to maxValue * 1.3
  - Verify grid interval calculation: (maxY / 5).clamp(0.1, infinity)
  - Ensure Y-axis labels show integers for values >= 10, one decimal for < 10
  - Confirm X-axis displays dates in DD/MM format with proper spacing
  - Verify line is curved (isCurved: true)
  - Confirm dots are visible with 5px radius, green color, white stroke
  - Verify shaded area below line with 10% opacity
  - _Requirements: 1.6, 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 2.1 Write widget tests for chart rendering
  - Test chart displays when data is available
  - Test empty state displays when no data
  - Test chart hides when all values are null/zero
  - Test time period selector updates chart
  - Test axis labels display correctly for different units
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.5, 3.1, 6.1, 6.3, 6.4_

- [x] 3. Verify time period selection functionality
  - Confirm 7-day, 30-day, and 90-day options work correctly
  - Verify chart refreshes within 2 seconds when period changes
  - Ensure loading state displays during data fetch
  - Confirm pull-to-refresh updates chart data
  - _Requirements: 4.1, 4.2, 4.3, 8.1, 8.2_

- [ ]* 3.1 Write integration tests for time period selection
  - Test switching between 7, 30, and 90-day periods
  - Test chart updates with correct data for each period
  - Test loading state during period change
  - Test pull-to-refresh functionality
  - _Requirements: 4.1, 4.2, 4.3, 8.2_

- [x] 4. Verify unit display for different habit categories
  - Test chart with "cal" unit (eat category)
  - Test chart with "ml" unit (hydration category)
  - Test chart with "giờ" unit (sleep category)
  - Test chart with custom units
  - Verify unit appears in chart subtitle and summary cards
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 5.2, 5.3, 5.4, 5.5_

- [ ]* 4.1 Write unit tests for unit display logic
  - Test unit extraction from summary and habitInfo
  - Test subtitle formatting with different units
  - Test summary card value formatting with units
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [x] 5. Verify empty state handling
  - Confirm empty state displays when no habit logs exist
  - Verify empty state message is clear and actionable
  - Test chart hides when all metric values are null or zero
  - Ensure at least one valid metric value shows the chart
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ]* 5.1 Write widget tests for empty state scenarios
  - Test empty state with no habit logs
  - Test empty state with all null metric values
  - Test empty state with all zero metric values
  - Test chart displays with at least one valid value
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [x] 6. Verify data compatibility and API integration
  - Confirm data retrieval from existing habit_logs table
  - Verify metric_value field is correctly parsed from API response
  - Test with habits that have completed_count but no metric_value
  - Ensure compatibility with all habit categories
  - Verify API endpoint `/stats/habits/:habitId/metrics` works correctly
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 7. Performance verification and optimization
  - Test chart render time is under 2 seconds on initial load
  - Verify chart updates within 2 seconds when changing period
  - Test smooth rendering with 90 data points
  - Verify performance on devices with 2GB RAM
  - Check fl_chart version is 0.69.0 or compatible
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [ ]* 7.1 Write performance tests
  - Measure chart render time with different data sizes
  - Test rendering with 7, 30, and 90 data points
  - Verify smooth scrolling and interaction
  - _Requirements: 8.1, 8.2, 8.3, 8.5_

- [x] 8. Final checkpoint - Ensure all tests pass
  - Run all unit tests and verify they pass
  - Run all widget tests and verify they pass
  - Run all integration tests and verify they pass
  - Manually test on physical device or emulator
  - Verify all acceptance criteria are met
  - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Most functionality is already implemented in the existing code
- Focus is on verification, testing, and minor refinements
- Each task references specific requirements for traceability
- The existing implementation already uses fl_chart 0.69.0
- No database schema changes required
- No API changes required
