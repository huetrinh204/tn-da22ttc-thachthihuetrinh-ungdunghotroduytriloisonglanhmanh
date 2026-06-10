# Progressive Wilting System

## Overview
Hệ thống Progressive Wilting (héo dần) được thiết kế để tạo động lực cho người dùng quay lại app và duy trì thói quen hàng ngày.

## Cơ chế hoạt động

### Timeline
| Ngày | Trạng thái | Hành động | Visual |
|------|-----------|-----------|--------|
| **Day 0** | 🌱 Normal | Cây khỏe mạnh | Màu xanh tươi |
| **Day 1** | ⚠️ Warning | Hiển thị cảnh báo nhẹ | Màu cam |
| **Day 2** | ⚠️ Critical | Cảnh báo nghiêm trọng - cây sẽ héo trong 24h | Màu đỏ cam |
| **Day 3** | 🍂 Wilted | Cây bị héo, **-3 EXP** | Màu đỏ, cây héo |
| **Day 4+** | 🍂 Severe | Tiếp tục **-3 EXP mỗi ngày** | Màu đỏ đậm |

### Penalty System
- **Day 3**: -3 EXP (lần đầu tiên)
- **Day 4**: -3 EXP
- **Day 5**: -3 EXP
- ...tiếp tục cho đến khi user check-in

### Recovery
Khi user check-in lại:
- `days_without_checkin` reset về 0
- `is_wilted` = false
- Cây hồi phục về trạng thái bình thường
- **Không hoàn lại điểm đã mất** (penalty là vĩnh viễn)

## Database Schema

### Table: `plants`
```sql
ALTER TABLE plants 
ADD COLUMN days_without_checkin INT DEFAULT 0 
  COMMENT 'Number of consecutive days without completing any habit',
ADD COLUMN last_penalty_date DATE NULL 
  COMMENT 'Last date when EXP penalty was applied';
```

### Fields
- `days_without_checkin`: Đếm số ngày liên tiếp không check-in
- `last_penalty_date`: Ngăn phạt nhiều lần trong cùng 1 ngày
- `is_wilted`: Flag đánh dấu cây đang héo (days >= 3)
- `experience`: Điểm EXP (bị trừ khi héo)

## Backend Implementation

### Cron Job
File: `viora_backend/src/services/cron_service.ts`

```typescript
// Chạy mỗi nửa đêm (00:00 Asia/Ho_Chi_Minh)
cron.schedule("0 0 * * *", async () => {
  await checkProgressiveWilting();
});
```

### Logic Flow
1. **Check yesterday's activity**: Query `habit_logs` để xem user có hoàn thành habit nào không
2. **Update counter**:
   - Có activity → reset `days_without_checkin = 0`
   - Không có activity → increment `days_without_checkin += 1`
3. **Apply penalties**:
   - Days >= 3 → Set `is_wilted = 1` và trừ 3 EXP
   - Check `last_penalty_date` để tránh phạt trùng
4. **Send notifications**:
   - Day 2: Warning push notification
   - Day 3+: Critical push notification

## Frontend Implementation

### Plant Screen
File: `viora_app/lib/screens/plant_screen.dart`

#### State Variables
```dart
int daysWithoutCheckin = 0;
bool plantWilted = false;
```

#### Warning Display
```dart
// Progressive warning với màu sắc và icon khác nhau
if (daysWithoutCheckin > 0) {
  Container(
    decoration: BoxDecoration(
      color: _getWarningColor(daysWithoutCheckin),
      // ...
    ),
    child: Row(
      children: [
        Icon(_getWarningIcon(daysWithoutCheckin)),
        Text(_getWarningMessage(daysWithoutCheckin, l10n)),
      ],
    ),
  )
}
```

#### Helper Functions
- `_getWarningMessage()`: Trả về text cảnh báo theo số ngày
- `_getWarningColor()`: Trả về màu sắc (orange → deepOrange → red)
- `_getWarningIcon()`: Trả về icon (warning → error → dangerous)

## API Changes

### GET `/habits/plant`
**Response thêm field**:
```json
{
  "plant": {
    "experience": 10,
    "is_wilted": false,
    "days_without_checkin": 2  // ← NEW FIELD
  }
}
```

## Notifications

### Push Notifications
1. **Day 2 Warning**:
   - Title: "⚠️ Cây cần được chăm sóc!"
   - Body: "Cây sẽ bị héo và mất điểm nếu bạn không check-in trong 24 giờ tới!"

2. **Day 3+ Critical**:
   - Title: "🍂 Cây của bạn đang héo!"
   - Body: "Cây đã bị mất {penalty} điểm vì không check-in {days} ngày. Hãy quay lại ngay! 💧"

## Migration Instructions

### 1. Run SQL Migration
```bash
mysql -u root -p viora_app < database/10062026.sql
```

### 2. Restart Backend
```bash
cd viora_backend
npm run dev  # or pm2 restart viora-backend
```

### 3. Update Flutter App
```bash
cd viora_app
flutter gen-l10n
flutter run
```

## Testing

### Manual Test Scenarios

#### Test 1: Normal Flow
1. User check-in day 1 → `days_without_checkin = 0`
2. Skip day 2 → Cron runs → `days_without_checkin = 1`
3. Check plant screen → See orange warning
4. Check-in → Reset to 0

#### Test 2: Penalty Flow
1. Skip 3 days consecutively
2. On day 3, cron runs at midnight
3. Check: `is_wilted = 1`, `experience -= 3`
4. Check plant screen → See red critical warning

#### Test 3: Recovery
1. After wilting, user checks in
2. Verify: `days_without_checkin = 0`, `is_wilted = 0`
3. Verify: Lost EXP is NOT recovered

### Test Cron Manually
```typescript
// In cron_service.ts, temporarily add:
import { checkProgressiveWilting } from './cron_service';

// Run immediately (for testing):
checkProgressiveWilting();
```

## Future Enhancements

### Tier 2 Features
- [ ] Visual animation khi cây héo dần (màu sắc fade, lá rụng)
- [ ] Recovery animation khi tưới nước lại
- [ ] Streak countdown: "⏰ Còn 12 giờ để giữ streak!"

### Tier 3 Features
- [ ] Shield item: Bảo vệ cây 1 lần (mua bằng điểm)
- [ ] Fertilizer: Hồi phục một phần EXP đã mất
- [ ] Social comparison: "85% users đã check-in hôm nay"

## Performance Considerations

- Cron job chạy 00:00 mỗi ngày → minimal impact
- Query indexed fields: `user_id`, `log_date`
- Batch update plants → không query từng user riêng lẻ

## Troubleshooting

### Issue: Cron không chạy
- Check timezone: `Asia/Ho_Chi_Minh`
- Check server logs: `pm2 logs viora-backend`
- Verify cron schedule: `cron.schedule("0 0 * * *")`

### Issue: Penalty áp dụng sai
- Check `last_penalty_date` để tránh duplicate
- Verify query logic trong `checkProgressiveWilting()`

### Issue: Counter không reset
- Check query `habit_logs` với `yesterday` date
- Verify timezone conversion

## Credits
Designed and implemented: June 10, 2026
System: Progressive Wilting + EXP Penalty
