# VietTour mobile

## Chạy ứng dụng

```powershell
flutter pub get
flutter run
```

`API_BASE_URL` có thể truyền lúc chạy bằng `--dart-define`. Mặc định ứng dụng
dùng `http://10.0.2.2:4000/api` trên Android Emulator và
`http://localhost:4000/api` trên iOS Simulator.

Trên điện thoại thật, kết nối điện thoại và máy chạy backend vào cùng mạng
LAN, rồi thay `192.168.1.10` bằng địa chỉ IPv4 của máy backend:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:4000/api
```

Cho phép cổng backend qua firewall và bảo đảm backend có thể nhận kết nối từ
mạng LAN. HTTP cleartext chỉ bật trong cấu hình phát triển Android; khi phát
hành cần dùng HTTPS.

## Phiên đăng nhập và thanh toán

Access/refresh token được lưu bằng `flutter_secure_storage`; yêu thích được lưu
cục bộ trên thiết bị. Luồng VNPay mở trình duyệt ngoài rồi trở lại ứng dụng
qua `viettour://payment-result`. Backend phải cấu hình callback VNPay công khai
và merchant phải cấu hình IPN theo hướng dẫn trong README của backend.

## Kiểm tra

```powershell
flutter analyze
flutter build apk --debug
```
