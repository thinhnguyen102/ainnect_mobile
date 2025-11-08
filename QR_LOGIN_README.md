# QR Login Feature - Ainnect Mobile

Chức năng đăng nhập QR code cho phép người dùng trên web đăng nhập vào tài khoản Ainnect bằng cách quét mã QR từ app mobile.

## 📱 Cách sử dụng

### Trên Mobile App:
1. Mở app Ainnect và đăng nhập vào tài khoản
2. Vào trang **Cá nhân** (Profile Screen)
3. Nhấn vào icon **QR Scanner** (⚡) ở góc trên bên phải
4. Cho phép quyền truy cập camera khi được yêu cầu
5. Quét mã QR hiển thị trên màn hình web

### Trên Web:
1. Truy cập trang đăng nhập Ainnect Web
2. Chọn "Đăng nhập bằng QR"
3. Mã QR sẽ hiển thị trên màn hình
4. Mở app mobile và quét mã QR
5. Xác nhận đăng nhập trên app mobile
6. Web sẽ tự động đăng nhập

## 🔧 Cấu trúc Code

### Services
- **`lib/services/qr_login_service.dart`**
  - `getSessionInfo(sessionId, token)`: Lấy thông tin phiên đăng nhập
  - `confirmLogin(sessionId, token)`: Xác nhận đăng nhập

### Screens
- **`lib/screens/qr_scanner_screen.dart`**
  - Camera scanner với overlay tùy chỉnh
  - Xử lý QR code và hiển thị dialog xác nhận
  - Hỗ trợ bật/tắt đèn flash và chuyển camera

### UI Components
- **Scanner Overlay**: Khung quét hình vuông với góc bo tròn
- **Confirmation Dialog**: Dialog gradient đẹp mắt hiển thị thông tin user
- **Status Indicators**: Loading và success/error messages

## 🎨 Features

✅ **Camera Scanner**
- Quét QR code tự động
- Bật/tắt đèn flash
- Chuyển đổi camera trước/sau
- Overlay tùy chỉnh với khung quét

✅ **Session Info**
- Hiển thị thông tin user (avatar, tên, email)
- Thời gian hết hạn của session
- Cảnh báo an toàn

✅ **Confirmation Dialog**
- UI gradient đẹp mắt
- Hiển thị đầy đủ thông tin phiên đăng nhập
- Nút xác nhận/hủy rõ ràng

✅ **Error Handling**
- Xử lý mã QR không hợp lệ
- Xử lý session hết hạn
- Hiển thị thông báo lỗi thân thiện

## 🔐 Security

- Mọi API call đều yêu cầu Bearer Token authentication
- Session có thời gian hết hạn
- Xác nhận trước khi đăng nhập
- QR code chỉ sử dụng một lần

## 📦 Dependencies

```yaml
mobile_scanner: ^5.2.3  # QR code scanner
```

## 🔗 API Endpoints

### Get Session Info
```
GET /api/qr-login/session/:sessionId
Authorization: Bearer {token}
```

Response:
```json
{
  "result": "SUCCESS",
  "message": "Session info retrieved successfully",
  "data": {
    "sessionId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "status": "PENDING",
    "user": {
      "userId": 1,
      "username": "john_doe",
      "fullName": "John Doe",
      "avatarUrl": "https://cdn.ainnect.me/avatars/avatar_1.jpg",
      "email": "john@example.com"
    },
    "expiresAt": "2025-11-08T15:30:00"
  }
}
```

### Confirm Login
```
POST /api/qr-login/confirm
Authorization: Bearer {token}
Content-Type: application/json

{
  "sessionId": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
}
```

Response:
```json
{
  "result": "SUCCESS",
  "message": "Login confirmed successfully",
  "data": "Login confirmed"
}
```

## 🎯 QR Code Format

QR code có thể ở các định dạng sau:

1. **Deep Link**: `ainnect://qr-login?sessionId=xxx`
2. **URL**: `https://ainnect.me/qr-login?sessionId=xxx`
3. **Session ID**: `a1b2c3d4-e5f6-7890-abcd-ef1234567890`

App sẽ tự động detect và extract sessionId từ QR code.

## 🚀 Testing

1. Start backend server với QR login endpoints
2. Mở web app và tạo QR login session
3. Mở mobile app đã đăng nhập
4. Quét QR code từ web
5. Xác nhận đăng nhập
6. Kiểm tra web đã đăng nhập thành công

## 💡 Notes

- Camera permission được yêu cầu khi mở QR scanner lần đầu
- QR code chỉ quét được khi nằm trong khung scanner
- Session có thể hết hạn, cần tạo QR mới nếu quá thời gian
- Chỉ user đã đăng nhập mới có thể xác nhận đăng nhập cho web
