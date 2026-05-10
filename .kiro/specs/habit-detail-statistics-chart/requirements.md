# Requirements Document

## Introduction

Tài liệu này mô tả các yêu cầu cho tính năng cải tiến trang thống kê chi tiết của từng thói quen trong ứng dụng Viora. Tính năng này cho phép người dùng xem biểu đồ đường (line chart) hiển thị mức độ hoàn thành thói quen theo thời gian với các đơn vị đo lường khác nhau (calories, milliliters, giờ, v.v.).

## Glossary

- **Statistics_Chart**: Biểu đồ đường hiển thị dữ liệu thống kê thói quen theo thời gian
- **Habit_Detail_Screen**: Màn hình chi tiết của một thói quen cụ thể
- **Metric_Value**: Giá trị đo lường của thói quen (ví dụ: số calories, milliliters, giờ)
- **Unit**: Đơn vị đo lường của thói quen (cal, ml, giờ, v.v.)
- **Time_Period**: Khoảng thời gian được chọn để hiển thị dữ liệu (7 ngày, 30 ngày, 90 ngày)
- **X_Axis**: Trục hoành của biểu đồ, hiển thị ngày tháng
- **Y_Axis**: Trục tung của biểu đồ, hiển thị mức độ (metric value)
- **Data_Point**: Điểm dữ liệu trên biểu đồ đại diện cho giá trị của một ngày cụ thể
- **Habit_Log**: Bản ghi hoàn thành thói quen của người dùng trong một ngày

## Requirements

### Requirement 1: Hiển thị biểu đồ đường với trục Y là mức độ

**User Story:** Là người dùng, tôi muốn xem biểu đồ đường với trục Y hiển thị mức độ hoàn thành (calories, milliliters, giờ, v.v.), để tôi có thể theo dõi xu hướng thói quen của mình theo thời gian.

#### Acceptance Criteria

1. WHEN THE Habit_Detail_Screen is displayed, THE Statistics_Chart SHALL display the Y_Axis with the Unit corresponding to the habit type
2. WHEN a habit has Unit of "cal", THE Y_Axis SHALL display values in calories
3. WHEN a habit has Unit of "ml", THE Y_Axis SHALL display values in milliliters
4. WHEN a habit has Unit of "giờ", THE Y_Axis SHALL display values in hours
5. WHEN a habit has a custom Unit, THE Y_Axis SHALL display values with that custom Unit
6. THE Y_Axis SHALL display numeric values from 0 to the maximum Metric_Value plus 30 percent margin

### Requirement 2: Hiển thị biểu đồ đường với trục X là ngày

**User Story:** Là người dùng, tôi muốn xem trục X hiển thị các ngày trong khoảng thời gian đã chọn, để tôi có thể biết giá trị của từng ngày cụ thể.

#### Acceptance Criteria

1. THE X_Axis SHALL display dates in chronological order from oldest to newest
2. WHEN THE Time_Period is 7 days, THE X_Axis SHALL display all 7 dates
3. WHEN THE Time_Period is 30 days, THE X_Axis SHALL display dates with appropriate spacing to maintain readability
4. WHEN THE Time_Period is 90 days, THE X_Axis SHALL display dates with appropriate spacing to maintain readability
5. THE X_Axis SHALL display dates in DD/MM format

### Requirement 3: Vẽ biểu đồ đường kết nối các điểm dữ liệu

**User Story:** Là người dùng, tôi muốn xem đường kết nối các điểm dữ liệu, để tôi có thể dễ dàng nhận biết xu hướng tăng giảm của thói quen.

#### Acceptance Criteria

1. THE Statistics_Chart SHALL render a line connecting all Data_Points in chronological order
2. THE Statistics_Chart SHALL display the line with a curved interpolation for smooth visualization
3. THE Statistics_Chart SHALL use the primary color (green) for the line
4. THE Statistics_Chart SHALL display visible dots at each Data_Point position
5. THE Statistics_Chart SHALL display a shaded area below the line with 10 percent opacity of the primary color

### Requirement 4: Hiển thị dữ liệu theo khoảng thời gian được chọn

**User Story:** Là người dùng, tôi muốn chọn khoảng thời gian để xem dữ liệu, để tôi có thể phân tích thói quen trong các giai đoạn khác nhau.

#### Acceptance Criteria

1. THE Habit_Detail_Screen SHALL provide time period selection options of 7 days, 30 days, and 90 days
2. WHEN a user selects a Time_Period, THE Statistics_Chart SHALL display data for that Time_Period
3. WHEN a user changes the Time_Period, THE Statistics_Chart SHALL refresh and display data for the new Time_Period within 2 seconds
4. THE Statistics_Chart SHALL display only Data_Points that have Metric_Value greater than zero
5. WHEN no Habit_Log exists for a date within the Time_Period, THE Statistics_Chart SHALL not display a Data_Point for that date

### Requirement 5: Hiển thị giá trị cụ thể cho từng loại thói quen

**User Story:** Là người dùng, tôi muốn xem giá trị cụ thể mà tôi đã hoàn thành mỗi ngày (ví dụ: ăn bao nhiêu cal, uống bao nhiêu ml, ngủ bao nhiêu giờ), để tôi có thể đánh giá hiệu suất của mình.

#### Acceptance Criteria

1. WHEN a Habit_Log has a Metric_Value, THE Statistics_Chart SHALL display that Metric_Value as a Data_Point
2. WHEN a user views a habit with category "eat", THE Statistics_Chart SHALL display calories consumed per day
3. WHEN a user views a habit with category "hydration", THE Statistics_Chart SHALL display milliliters consumed per day
4. WHEN a user views a habit with category "sleep", THE Statistics_Chart SHALL display hours slept per day
5. WHEN a user views a habit with a custom metric, THE Statistics_Chart SHALL display the custom Metric_Value per day

### Requirement 6: Xử lý trường hợp không có dữ liệu

**User Story:** Là người dùng, tôi muốn thấy thông báo rõ ràng khi không có dữ liệu, để tôi biết rằng tôi cần check-in thói quen.

#### Acceptance Criteria

1. WHEN no Habit_Log exists for the selected Time_Period, THE Habit_Detail_Screen SHALL display an empty state message
2. THE empty state message SHALL inform the user to check-in the habit to view statistics
3. WHEN at least one Habit_Log with Metric_Value exists, THE Statistics_Chart SHALL be displayed
4. WHEN all Habit_Logs in the Time_Period have null or zero Metric_Value, THE Habit_Detail_Screen SHALL display the empty state message

### Requirement 7: Tương thích với dữ liệu hiện có

**User Story:** Là người dùng, tôi muốn tính năng mới hoạt động với dữ liệu thói quen hiện có của tôi, để tôi không mất thông tin đã ghi nhận.

#### Acceptance Criteria

1. THE Statistics_Chart SHALL retrieve data from the existing habit_logs table
2. THE Statistics_Chart SHALL use the metric_value field from Habit_Log records
3. WHEN a Habit_Log has completed_count but no metric_value, THE Statistics_Chart SHALL not display that log as a Data_Point
4. THE Statistics_Chart SHALL maintain compatibility with the existing API endpoint for habit metrics
5. THE Statistics_Chart SHALL display data for all habit categories (eat, exercise, sleep, mental, hydration, other)

### Requirement 8: Hiển thị biểu đồ với hiệu suất tốt

**User Story:** Là người dùng, tôi muốn biểu đồ hiển thị mượt mà và nhanh chóng, để tôi có trải nghiệm sử dụng tốt.

#### Acceptance Criteria

1. WHEN THE Habit_Detail_Screen loads, THE Statistics_Chart SHALL render within 2 seconds
2. WHEN a user changes the Time_Period, THE Statistics_Chart SHALL update within 2 seconds
3. THE Statistics_Chart SHALL render smoothly without visible lag on devices with at least 2GB RAM
4. THE Statistics_Chart SHALL use the fl_chart library version 0.69.0 or compatible
5. WHEN rendering 90 Data_Points, THE Statistics_Chart SHALL maintain smooth scrolling and interaction

