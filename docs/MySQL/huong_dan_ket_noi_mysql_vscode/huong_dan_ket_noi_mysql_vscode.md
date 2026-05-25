---
layout: page
title: "Kết nối MySQL Server bằng VS Code và sửa lỗi thường gặp"
---

# Kết nối MySQL Server bằng VS Code và sửa lỗi thường gặp

Nguồn: https://www.geeksforgeeks.org/sql/how-to-connect-to-mysql-server-using-vs-code-and-fix-errors/

## Mục tiêu
- Kết nối MySQL từ Visual Studio Code
- Xử lý lỗi xác thực và kết nối thường gặp

## Yêu cầu
- Visual Studio Code đã cài đặt
- MySQL Server (mysqld) đã được cài và đang chạy
- Mở rộng MySQL cho VS Code (ví dụ: MySQL Management Tool)

## Các bước kết nối

1. Mở Visual Studio Code.
2. Vào Extensions, tìm `MySQL` và cài đặt extension `MySQL Management Tool`.

![Cài extension](images/vscode-01.jpg)

3. Mở Explorer (Ctrl+Shift+E) - mục MySQL sẽ xuất hiện. Nhấn `Add Connection` để tạo kết nối mới.

![Add Connection](images/vscode-02.jpg)

4. Điền thông tin server: `Host` = `localhost`, `User` = `root` (mặc định), nhập `Password` và `Port` = `3306`.
5. Nếu gặp lỗi xác thực (ví dụ khi dùng MySQL 8 với plugin xác thực mới), ta có thể tạo user mới sử dụng phương thức xác thực cũ.

![Authentication error](images/vscode-03.jpg)

6. Mở thư mục cài đặt MySQL, vào `bin`, rồi mở `cmd` tại đó nếu cần thao tác trực tiếp.

![Open bin folder](images/vscode-04.jpg)

7. Kết nối bằng client nếu cần kiểm tra từ dòng lệnh:

```
mysql -u root -p
```

![Client connect](images/vscode-06.jpg)

