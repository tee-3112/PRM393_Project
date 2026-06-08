<<<<<<< HEAD
﻿# Quản Lý Thu Chi

App quản lý thu chi cá nhân - Flutter + .NET Web API

## Cấu trúc project

```
Quản lý chi tiêu/
├── quanlythuchi/           # Flutter mobile app (Android)
│   ├── lib/
│   │   ├── main.dart               # Entry point
│   │   ├── models/                 # Data models
│   │   ├── screens/                # UI screens
│   │   ├── services/               # API service
│   │   ├── utils/                  # Theme, formatters
│   └── pubspec.yaml
├── QuanLyThuChi.Api/       # .NET 9 Web API backend
│   ├── Controllers/                # API controllers
│   ├── Models/                     # Domain models
│   ├── Services/                   # Business logic
│   ├── Data/                       # In-memory DB + JSON persistence
│   └── Program.cs
└── README.md
```

## Tính năng

1. **Đăng nhập / Đăng ký** - JWT authentication
2. **Dashboard Thu nhập** - Thống kê thu nhập theo tháng, xem theo danh mục
3. **Dashboard Chi tiêu** - Thống kê chi tiêu theo tháng, xem theo danh mục
4. **Lịch** - Xem thu/chi theo ngày, tổng thu/tổng chi/tổng dư từng ngày
5. **Ngân sách** - Đặt ngân sách từng danh mục, cảnh báo đỏ khi chi ≥ 90%

## Yêu cầu

- Flutter 3.41+ (Dart 3.11+)
- .NET 9.0 SDK
- Android SDK / Emulator

## Chạy backend

```bash
cd QuanLyThuChi.Api
dotnet run
```

API chạy tại `http://localhost:5000`

Tài khoản demo: `demo` / `123456`

## Chạy Flutter app

```bash
cd quanlythuchi
flutter pub get
flutter run
```

Flutter app mặc định kết nối backend tại `http://10.0.2.2:5000` (Android emulator localhost).
Nếu chạy trên thiết bị thật hoặc backend ở IP khác, sửa trong `lib/services/api_service.dart`.
=======
# PRM393_Project
>>>>>>> 55e1c9a8a591141a604dc9f52b69081171498e2e
