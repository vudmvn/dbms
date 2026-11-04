---
layout: page
title: "Giám sát Tiến trình, Sao lưu và Phục hồi CSDL trong MySQL (Process Monitoring & mysqldump)"
summary: "Hướng dẫn thực hành theo dõi các kết nối đang chạy với SHOW PROCESSLIST, ngắt truy vấn treo bằng KILL, sao lưu toàn diện bằng mysqldump và phục hồi dữ liệu an toàn."
duration: "120m"
difficulty: "Beginner–Intermediate"
---

# Bài giảng: Giám sát Tiến trình, Sao lưu và Phục hồi CSDL trong MySQL

**Cập nhật lần cuối:** 03/11/2026

Bài học này hướng dẫn các kỹ thuật cốt lõi trong vận hành và bảo vệ dữ liệu MySQL: giám sát luồng kết nối client qua `SHOW PROCESSLIST`, xử lý các câu truy vấn bị nghẽn (long-running queries) với lệnh `KILL`, sử dụng công cụ tiêu chuẩn `mysqldump` để sao lưu cấu trúc và dữ liệu, cùng quy trình phục hồi (restore) và kiểm tra toàn vẹn bản sao lưu.

---

## 1. Mục tiêu bài học

Sau khi hoàn thành bài học này, người học có thể:

1. Sử dụng `SHOW PROCESSLIST` và `SHOW FULL PROCESSLIST` để giám sát trạng thái các thread/session đang kết nối tới server.
2. Hiểu các trạng thái hoạt động quan trọng: `Sleep`, `Query`, `Locked`, `Copying to tmp table`.
3. Sử dụng câu lệnh `KILL` và `KILL QUERY` để ngắt các truy vấn bị treo một cách có kiểm soát.
4. Nắm vững cú pháp công cụ `mysqldump` để xuất dữ liệu ra file SQL thuần.
5. Sao lưu linh hoạt: sao lưu một database, nhiều database, toàn bộ server, hoặc chỉ một bảng riêng biệt.
6. Sử dụng các tùy chọn nâng cao: `--no-data` (schema-only), `--no-create-info` (data-only), `--routines`, `--triggers` và `--single-transaction` (dành cho InnoDB).
7. Thực hiện quy trình phục hồi database từ file dump bằng `mysql` CLI hoặc lệnh `SOURCE`.
8. Lập checklist kiểm tra xác minh tính toàn vẹn của dữ liệu sau khi phục hồi.

---

## 2. Giám sát Kết nối & Luồng xử lý với `SHOW PROCESSLIST`

### 2.1. Lệnh `SHOW PROCESSLIST` và `SHOW FULL PROCESSLIST`
Để kiểm tra máy chủ đang phục vụ những client nào và thực thi những câu lệnh SQL nào:

```sql
SHOW FULL PROCESSLIST;
```

> **Lưu ý:** Nếu chỉ dùng `SHOW PROCESSLIST;`, trường `Info` chứa câu lệnh SQL sẽ bị cắt ngắn ở 100 ký tự đầu tiên. Thêm từ khóa `FULL` giúp đọc trọn vẹn toàn bộ câu truy vấn dài.

### 2.2. Ý nghĩa các trường thông tin:
- **Id:** Mã định danh duy nhất của connection thread. Số này được dùng làm tham số cho lệnh `KILL`.
- **User:** Tên tài khoản MySQL đang thực thi câu lệnh.
- **Host:** Địa chỉ IP và cổng mạng của máy client kết nối vào.
- **db:** Tên database mặc định mà session đang trỏ tới.
- **Command:** Loại lệnh đang thực hiện (phổ biến nhất là `Sleep` - kết nối nhàn rỗi đang chờ lệnh mới, và `Query` - đang xử lý câu lệnh SQL).
- **Time:** Số giây mà thread đã ở trạng thái hiện tại. Nếu `Time` quá lớn trong trạng thái `Query`, đó là dấu hiệu của câu truy vấn chậm hoặc bị khóa.
- **State:** Trạng thái chi tiết (ví dụ: `Sending data`, `Waiting for table metadata lock`).
- **Info:** Câu lệnh SQL thực tế đang chạy.

---

## 3. Xử lý Truy vấn Treo bằng Lệnh `KILL`

Khi phát hiện một câu query chạy tốn CPU hoặc gây deadlock giữ khóa các bảng khác:

### 3.1. Phân biệt `KILL` và `KILL QUERY`
```sql
-- Cách 1: Chỉ ngắt câu query đang chạy dở, giữ nguyên kết nối của client
KILL QUERY 42;

-- Cách 2: Đóng hoàn toàn kết nối mạng của thread 42 (ngắt hẳn session)
KILL 42;
```

---

## 4. Sao lưu CSDL với `mysqldump`

`mysqldump` là công cụ dòng lệnh (CLI utility) do Oracle phát triển kèm theo MySQL. Nó đọc cấu trúc bảng và các dòng dữ liệu rồi xuất ra một file văn bản chứa các câu lệnh SQL (`CREATE TABLE`, `INSERT INTO`).

### 4.1. Các lệnh sao lưu cơ bản:

```bash
# 1. Sao lưu một database duy nhất
mysqldump -u root -p classicmodels > classicmodels_backup.sql

# 2. Sao lưu riêng một bảng cụ thể
mysqldump -u root -p classicmodels customers > customers_only.sql

# 3. Sao lưu nhiều database cùng lúc
mysqldump -u root -p --databases db1 db2 > multiple_dbs.sql

# 4. Sao lưu toàn bộ mọi database trên server
mysqldump -u root -p --all-databases > full_server_backup.sql
```

### 4.2. Các cờ tùy chọn nâng cao:
- `--no-data` (hoặc `-d`): Chỉ sao lưu cấu trúc bảng (DDL), không xuất các câu lệnh `INSERT` dữ liệu.
- `--no-create-info` (hoặc `-t`): Chỉ sao lưu dữ liệu dòng (`INSERT INTO`), không xuất lệnh `CREATE TABLE`.
- `--routines` (hoặc `-R`): Sao lưu cả Stored Procedures và Stored Functions.
- `--triggers`: Sao lưu Triggers gắn kèm bảng.
- `--single-transaction`: Dành riêng cho bảng InnoDB, cho phép tạo bản sao lưu nhất quán (Consistent Snapshot) mà không cần khóa ghi toàn bộ database.

Ví dụ lệnh sao lưu chuẩn doanh nghiệp cho production:
```bash
mysqldump -u root -p --single-transaction --routines --triggers classicmodels > classicmodels_prod.sql
```

---

## 5. Quy trình Phục hồi (Restore) & Kiểm tra Toàn vẹn

### 5.1. Phục hồi dữ liệu
File dump thực chất là một chuỗi các câu lệnh SQL. Có thể phục hồi bằng tiện ích `mysql` client qua toán tử chuyển hướng `<`:

```bash
# Bước 1: Tạo database rỗng nếu file backup không có lệnh CREATE DATABASE
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS classicmodels_restore;"

# Bước 2: Nạp dữ liệu từ file dump vào database
mysql -u root -p classicmodels_restore < classicmodels_backup.sql
```

Hoặc trong môi trường MySQL console:
```sql
USE classicmodels_restore;
SOURCE /path/to/classicmodels_backup.sql;
```

### 5.2. Checklist xác minh sau phục hồi:
1. **Kiểm tra danh sách bảng:** `SHOW TABLES;` bảo đảm đủ số lượng đối tượng.
2. **Kiểm tra số lượng dòng:** `SELECT COUNT(*) FROM customers;` đối chiếu với hệ thống nguồn.
3. **Kiểm tra đối tượng lập trình:** `SHOW PROCEDURE STATUS WHERE Db = 'classicmodels_restore';`.
