---
layout: page
title: "Hướng dẫn Cài đặt, Công cụ Phát triển và Kết nối MySQL Server"
summary: "Hướng dẫn toàn diện về cài đặt MySQL Server trên Windows, cấu hình MySQL Workbench GUI, kết nối qua Command Line Client và Visual Studio Code."
duration: "90m"
difficulty: "Beginner"
---

# Bài giảng: Cài đặt, Công cụ Phát triển và Kết nối MySQL Server

**Cập nhật lần cuối:** 29/10/2026

Bài học này tổng hợp quy trình thiết lập môi trường phát triển cơ sở dữ liệu với MySQL Server, từ cài đặt hệ thống máy chủ trên Windows, cấu hình công cụ đồ họa MySQL Workbench, kết nối qua dòng lệnh (Command Line Client) cho đến tích hợp môi trường lập trình trong Visual Studio Code.

---

## 1. Mục tiêu bài học

Sau khi hoàn thành bài học này, người học có thể:

1. Cài đặt thành công **MySQL Community Server** trên Windows bằng MySQL Installer.
2. Thiết lập mật khẩu tài khoản `root`, cổng dịch vụ mặc định (`3306`) và cơ chế xác thực `caching_sha2_password`.
3. Cài đặt và sử dụng **MySQL Workbench** để quản lý kết nối, duyệt cấu trúc schema và thực thi truy vấn.
4. Sử dụng công cụ dòng lệnh `mysql` với đầy đủ các tham số kết nối (`-h`, `-P`, `-u`, `-p`).
5. Cấu hình tiện ích mở rộng trong **Visual Studio Code** để làm việc trực tiếp với MySQL.
6. Chẩn đoán và xử lý các lỗi kết nối phổ biến như Error 1045 (Access Denied) và Error 2003 (Can't connect to server).

---

## 2. Cài đặt MySQL Server trên Windows

### 2.1. Tải bộ cài đặt
- Truy cập trang tải chính thức: [MySQL Community Downloads](https://dev.mysql.com/downloads/installer/).
- Lựa chọn bản **MySQL Installer Community** (file cài đặt offline đầy đủ ~400MB) để không phụ thuộc vào kết nối mạng trong lúc cài.

### 2.2. Các bước cấu hình cốt lõi
1. **Choosing a Setup Type:** Chọn *Server only* (nếu chỉ cần database server) hoặc *Custom* (để chọn cả MySQL Server và MySQL Workbench).
2. **Type and Networking:**
   - *Config Type:* Chọn `Development Computer` để tối ưu tài nguyên RAM cho máy cá nhân.
   - *Port:* Giữ nguyên cổng mặc định `3306`. Nếu cổng 3306 đã bị ứng dụng khác chiếm dụng (ví dụ XAMPP/MariaDB), đổi sang cổng khác như `3307`.
3. **Authentication Method:**
   - Khuyến nghị sử dụng chuẩn bảo mật mới: `Use Strong Password Encryption for Authentication (RECOMMENDED - caching_sha2_password)`.
4. **Accounts and Roles:**
   - Thiết lập mật khẩu cho tài khoản quản trị tối cao `root`. Hãy ghi nhớ kỹ mật khẩu này.
5. **Windows Service:**
   - Đặt tên dịch vụ Windows (mặc định là `MySQL80` hoặc `MySQL84`).
   - Đánh dấu chọn *Start the MySQL Server at System Startup* nếu muốn server tự động chạy khi bật máy.

---

## 3. Cài đặt và Sử dụng MySQL Workbench

**MySQL Workbench** là công cụ quản trị giao diện đồ họa (GUI) chính thức của Oracle dành cho MySQL:

- **Connection Management:** Lưu thông tin các kết nối cục bộ (localhost) và máy chủ từ xa.
- **SQL Editor:** Trình soạn thảo truy vấn có gợi ý cú pháp, tô màu và hiển thị kết quả trực quan dạng bảng lưới.
- **Navigator & Object Browser:** Cây đối tượng thể hiện toàn bộ Schemas, Tables, Views, Stored Procedures, Functions và Triggers.
- **Server Administration:** Giám sát trạng thái hoạt động (Dashboard), xem danh sách kết nối (Client Connections), import/export dữ liệu.

---

## 4. Kết nối MySQL qua Command Line Client

Công cụ `mysql` (CLI) là phương thức kết nối nhẹ, nhanh và luôn sẵn sàng trên mọi môi trường máy chủ:

### Cú pháp tổng quát:
```bash
mysql -h <hostname_hoặc_IP> -P <cổng> -u <tên_user> -p
```

### Ví dụ kết nối localhost:
```bash
# Kết nối tài khoản root tại máy cục bộ (cổng 3306)
mysql -h 127.0.0.1 -P 3306 -u root -p
```
*Hệ thống sẽ nhắc nhập mật khẩu:*
```text
Enter password: *********
```

### Các lệnh điều khiển cơ bản sau khi đăng nhập:
```sql
-- Xem danh sách database hiện có
SHOW DATABASES;

-- Chọn database để làm việc
USE classicmodels;

-- Xem danh sách bảng
SHOW TABLES;

-- Thoát khỏi CLI
EXIT;
```

---

## 5. Tích hợp MySQL trong Visual Studio Code

Nếu bạn phát triển ứng dụng (Python, NodeJS, Java, PHP) trong **VS Code**, bạn có thể quản trị database trực tiếp mà không cần chuyển đổi ứng dụng:

1. Cài đặt tiện ích: Mở Extensions (`Ctrl+Shift+X`), tìm kiếm **Database Client** hoặc **SQLTools** kèm driver **SQLTools MySQL/MariaDB**.
2. Nhấn nút **Create Connection**:
   - *Connection Name:* `Local MySQL`
   - *Host:* `127.0.0.1`
   - *Port:* `3306`
   - *User:* `root`
   - *Password:* Nhập mật khẩu đã tạo khi cài đặt.
3. Nhấn **Save and Connect** để truy cập trực tiếp cấu trúc bảng và chạy các file `.sql` ngay trong trình soạn thảo.

---

## 6. Chẩn đoán và Xử lý Lỗi Kết nối Thường gặp

| Mã lỗi | Thông điệp | Nguyên nhân & Cách khắc phục |
|---|---|---|
| **Error 1045 (28000)** | *Access denied for user 'root'@'localhost' (using password: YES)* | Nhập sai mật khẩu tài khoản hoặc sai user. Kiểm tra lại caps lock hoặc reset mật khẩu root qua file `init.txt`. |
| **Error 2003 (HY000)** | *Can't connect to MySQL server on 'localhost' (10061)* | Dịch vụ MySQL chưa được khởi động hoặc cổng 3306 bị chặn. Kiểm tra trong `services.msc` xem service có ở trạng thái `Running` không. |
| **Port Conflict** | *Port 3306 is already in use* | Một tiến trình khác (như MariaDB, XAMPP, hoặc instance MySQL khác) đang dùng cổng. Đổi sang port 3307 trong cấu hình. |
