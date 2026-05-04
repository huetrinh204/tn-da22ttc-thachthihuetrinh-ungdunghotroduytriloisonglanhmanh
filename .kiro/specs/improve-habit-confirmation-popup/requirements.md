# Requirements Document

## Introduction

Tài liệu này mô tả các yêu cầu cho tính năng cải thiện UI popup xác nhận thói quen trong ứng dụng Viora. Popup hiện tại sử dụng màu sắc hardcoded không tương thích với dark mode và có UI không cân xứng giữa hai nút hành động. Tính năng này sẽ cải thiện popup để đồng bộ với theme system hiện có và tạo giao diện chuyên nghiệp, nhất quán hơn.

## Glossary

- **Habit_Confirmation_Popup**: Dialog hiển thị khi người dùng tick hoàn thành thói quen, yêu cầu xác nhận hành động
- **Theme_System**: Hệ thống quản lý giao diện sáng/tối của ứng dụng, bao gồm AppTheme.light, AppTheme.dark và ThemeContext extension
- **ThemeContext**: Extension cung cấp các helper methods để truy cập màu sắc theo theme hiện tại (isDark, cardColor, textPrimary, etc.)
- **Action_Buttons**: Hai nút "Chưa Chắc" và "Đã hoàn thành" trong popup
- **Dark_Mode**: Chế độ giao diện tối của ứng dụng
- **Light_Mode**: Chế độ giao diện sáng của ứng dụng

## Requirements

### Requirement 1: Dark Mode Compatibility

**User Story:** Là người dùng, tôi muốn popup xác nhận thói quen hiển thị đúng màu sắc theo theme hiện tại, để giao diện nhất quán và dễ nhìn trong cả chế độ sáng và tối.

#### Acceptance Criteria

1. WHEN Dark_Mode is active, THE Habit_Confirmation_Popup SHALL use dark theme colors from Theme_System
2. WHEN Light_Mode is active, THE Habit_Confirmation_Popup SHALL use light theme colors from Theme_System
3. THE Habit_Confirmation_Popup SHALL NOT use hardcoded colors (Colors.black87, Colors.grey, Color(0xFF4CAF50))
4. THE Habit_Confirmation_Popup SHALL use ThemeContext extension methods for all color values
5. WHEN theme changes, THE Habit_Confirmation_Popup SHALL reflect the new theme colors immediately

### Requirement 2: Consistent Button Styling

**User Story:** Là người dùng, tôi muốn hai nút hành động trong popup có giao diện cân xứng và chuyên nghiệp, để dễ dàng nhận biết và sử dụng.

#### Acceptance Criteria

1. THE Action_Buttons SHALL have consistent button types (both ElevatedButton or both OutlinedButton)
2. THE Action_Buttons SHALL have equal visual weight and spacing
3. THE "Chưa chắc" button SHALL use theme-aware secondary styling
4. THE "Đã hoàn thành" button SHALL use theme-aware primary styling with AppColors.primary
5. THE Action_Buttons SHALL have consistent border radius matching Theme_System standards

### Requirement 3: Theme-Aware Text Colors

**User Story:** Là người dùng, tôi muốn văn bản trong popup hiển thị rõ ràng theo theme hiện tại, để dễ đọc trong mọi điều kiện ánh sáng.

#### Acceptance Criteria

1. THE popup title SHALL use ThemeContext.textPrimary for text color
2. THE popup content text SHALL use ThemeContext.textPrimary for text color
3. THE popup content text SHALL NOT use hardcoded Colors.black87
4. WHEN Dark_Mode is active, THE popup text SHALL be readable on dark background
5. WHEN Light_Mode is active, THE popup text SHALL be readable on light background

### Requirement 4: Theme-Aware Dialog Background

**User Story:** Là người dùng, tôi muốn nền popup phù hợp với theme hiện tại, để trải nghiệm giao diện mượt mà và nhất quán.

#### Acceptance Criteria

1. THE Habit_Confirmation_Popup SHALL use Theme_System's dialog background color
2. WHEN Dark_Mode is active, THE popup background SHALL use dark surface color
3. WHEN Light_Mode is active, THE popup background SHALL use light surface color
4. THE popup background color SHALL match the app's card color scheme
5. THE popup SHALL maintain existing border radius of 20 pixels

### Requirement 5: Preserve Existing Functionality

**User Story:** Là người dùng, tôi muốn popup hoạt động giống như trước đây, để không bị gián đoạn trong quy trình sử dụng.

#### Acceptance Criteria

1. WHEN user taps "Chưa chắc" button, THE Habit_Confirmation_Popup SHALL return false and close
2. WHEN user taps "Đã hoàn thành" button, THE Habit_Confirmation_Popup SHALL return true and close
3. THE popup SHALL display the same title text "✅ Xác nhận hoàn thành"
4. THE popup SHALL display the same content message about confirmation and inability to untick
5. THE popup SHALL maintain the same dialog structure (AlertDialog with title, content, actions)

### Requirement 6: Visual Consistency

**User Story:** Là người dùng, tôi muốn popup có khoảng cách và căn chỉnh hợp lý, để giao diện trông chuyên nghiệp và dễ sử dụng.

#### Acceptance Criteria

1. THE Action_Buttons SHALL have consistent horizontal padding
2. THE Action_Buttons SHALL have consistent vertical spacing from content
3. THE popup content text SHALL maintain line height of 1.5 for readability
4. THE emoji icon SHALL remain in the title with consistent spacing
5. THE Action_Buttons SHALL be horizontally aligned in the actions row
