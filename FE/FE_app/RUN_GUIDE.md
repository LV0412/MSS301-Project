# Huong dan chay app NutriChef AI Flutter

Tai lieu nay danh cho team khong chuyen Frontend. Lam theo tung buoc tu tren xuong duoi.

## 1. Yeu cau truoc khi chay

Can cai san cac phan mem sau:

- Flutter SDK
- Android Studio hoac VS Code
- Git
- Mot thiet bi de chay app:
  - Android Emulator
  - Dien thoai Android that
  - Chrome browser

Phien ban dang dung trong project:

```powershell
Flutter 3.41.9
Dart 3.11.5
```

Neu may ban dung Flutter moi hon thi van co the chay binh thuong. Neu dung Flutter qua cu, hay cap nhat Flutter truoc.

## 2. Mo project

Mo PowerShell tai thu muc project:

```powershell
cd D:\SUM26\MSS301\project\FE_NutritionAI
```

Kiem tra da dung thu muc chua:

```powershell
dir
```

Neu thay cac thu muc/file sau la dung:

```text
android
ios
lib
test
pubspec.yaml
```

## 3. Kiem tra Flutter

Chay lenh:

```powershell
flutter --version
```

Neu hien ra thong tin Flutter va Dart la OK.

Kiem tra moi truong:

```powershell
flutter doctor
```

Neu co dau check mau xanh o Flutter va Android toolchain la tot. Neu co canh bao ve Android license, chay:

```powershell
flutter doctor --android-licenses
```

Sau do bam `y` de dong y cac license.

## 4. Cai package cho project

Chay lenh:

```powershell
flutter pub get
```

Lenh nay tai cac package trong `pubspec.yaml`.

Neu thanh cong, terminal se hien gan nhu:

```text
Got dependencies.
```

## 5. Chay app bang Chrome

Cach nay nhanh nhat de team xem UI.

```powershell
flutter run -d chrome
```

Cho vai giay, app se mo tren Chrome.

## 6. Chay app bang Android Emulator

Mo Android Studio, vao Device Manager va start mot emulator.

Kiem tra thiet bi da san sang:

```powershell
flutter devices
```

Neu thay ten emulator, chay:

```powershell
flutter run
```

Neu co nhieu device, chay theo device id:

```powershell
flutter run -d <device_id>
```

Vi du:

```powershell
flutter run -d emulator-5554
```

## 7. Chay app bang dien thoai Android that

Tren dien thoai:

1. Bat Developer Options.
2. Bat USB Debugging.
3. Cam cap USB vao may tinh.
4. Neu dien thoai hoi quyen debug, bam Allow.

Kiem tra:

```powershell
flutter devices
```

Neu thay dien thoai trong danh sach, chay:

```powershell
flutter run
```

## 8. Kiem tra code truoc khi demo

Chay analyzer:

```powershell
flutter analyze
```

Neu hien:

```text
No issues found!
```

la OK.

Chay test:

```powershell
flutter test
```

Neu hien:

```text
All tests passed!
```

la OK.

## 9. Cach thao tac app hien tai

App hien chua co backend, tat ca du lieu dang la UI mau.

Luong man hinh chinh:

1. Splash screen
2. Login hoac Sign up
3. Onboarding 4 buoc:
   - Lifestyle
   - Health status
   - Goals
   - Preferences
4. Home
5. Bottom navigation:
   - Home
   - Explore
   - Recipes
   - Meal Plan
   - Profile

Tu Home:

- Bam icon AI tren header de mo man hinh `AI Chef Ingredient Scanner`.

Tu Recipes:

- Bam card cong thuc de mo `Recipe Details`.

Tu Profile:

- Bam nut `VIEW DETAILED REPORT` de mo `Weekly Analysis`.

## 10. Hot reload khi dang code

Khi app dang chay bang `flutter run`, sau khi sua code:

- Bam `r` trong terminal de hot reload.
- Bam `R` de hot restart.
- Bam `q` de dung app.

## 11. Loi thuong gap

### Loi: Flutter command not found

May chua cai Flutter hoac chua them Flutter vao PATH.

Can cai Flutter SDK va them duong dan `flutter\bin` vao Environment Variables.

### Loi: No devices found

Chua co device de chay app.

Co 3 cach xu ly:

- Mo Android Emulator.
- Cam dien thoai Android va bat USB Debugging.
- Chay bang Chrome:

```powershell
flutter run -d chrome
```

### Loi: Android license status unknown

Chay:

```powershell
flutter doctor --android-licenses
```

Sau do bam `y` de dong y.

### Loi khi pub get

Thu chay lai:

```powershell
flutter clean
flutter pub get
```

Sau do chay app:

```powershell
flutter run -d chrome
```

### App chay nhung UI khong cap nhat

Trong terminal dang chay app:

```text
r
```

Neu van khong cap nhat:

```text
R
```

## 12. Cau truc file quan trong

```text
lib/main.dart
```

Day la file chinh dang chua toan bo UI hien tai.

```text
test/widget_test.dart
```

Test smoke de kiem tra app khoi dong duoc.

```text
pubspec.yaml
```

File khai bao package va cau hinh Flutter.

## 13. Lenh nhanh de demo

Neu moi pull project ve, chay:

```powershell
cd D:\SUM26\MSS301\project\FE_NutritionAI
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Neu da cai san package va chi muon mo app:

```powershell
cd D:\SUM26\MSS301\project\FE_NutritionAI
flutter run -d chrome
```
