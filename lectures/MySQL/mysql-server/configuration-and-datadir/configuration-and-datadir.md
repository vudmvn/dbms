---
layout: page
title: "Cấu hình Hệ thống MySQL và Thư mục Dữ liệu (Configuration File & Data Directory)"
summary: "Tìm hiểu cấu trúc file cấu hình my.ini/my.cnf, các option groups, biến hệ thống động/tĩnh và tổ chức thư mục dữ liệu datadir trong MySQL."
duration: "90m"
difficulty: "Intermediate"
---

# Bài giảng: Cấu hình Hệ thống MySQL và Thư mục Dữ liệu

**Cập nhật lần cuối:** 29/10/2026

Bài học này làm rõ cách quản trị cấu hình MySQL Server thông qua option files (`my.ini` / `my.cnf`), phân biệt biến hệ thống (System Variables), phân tích kiến trúc thư mục dữ liệu (`datadir`), và nguyên lý hoạt động của các file log cốt lõi (Redo Log, Undo Log, Binary Log) bảo đảm tính toàn vẹn và độ bền (Durability) trong ACID.

---

## 1. Mục tiêu bài học

Sau khi hoàn thành bài học này, người học có thể:

1. Xác định vị trí và thứ tự ưu tiên nạp file cấu hình (`my.ini` trên Windows, `my.cnf` trên Linux).
2. Hiểu cấu trúc các nhóm tùy chọn (Option Groups): `[mysqld]`, `[client]`, `[mysql]`.
3. Phân biệt biến hệ thống cấp toàn cục (Global) và cấp phiên làm việc (Session).
4. Phân biệt biến động (Dynamic Variables) có thể thay đổi trực tiếp lúc runtime và biến tĩnh (Static Variables) cần khởi động lại server.
5. Tra cứu vị trí thư mục dữ liệu (`datadir`) thông qua câu lệnh SQL an toàn.
6. Mô tả cấu trúc các file vật lý trong `datadir`: tablespace `.ibd`, `ibdata1`, redo log và undo log.
7. Giải thích vai trò của Redo log và Undo log trong việc bảo đảm giao dịch ACID.

---

## 2. Option Files và Thứ tự Ưu tiên

### 2.1. File cấu hình là gì?
MySQL Server đọc các tùy chọn cấu hình từ các file văn bản khi khởi động:
- Trên Windows: thường là `C:\ProgramData\MySQL\MySQL Server 8.0\my.ini`.
- Trên Linux: thường là `/etc/mysql/my.cnf` hoặc `/etc/my.cnf`.

### 2.2. Thứ tự ưu tiên (Precedence)
Nếu một tham số xuất hiện ở nhiều file cấu hình khác nhau, quy tắc chung là: **Cấu hình đọc sau sẽ ghi đè cấu hình đọc trước**.

Để kiểm tra các file cấu hình mà `mysqld` tìm kiếm trên máy hiện tại, chạy lệnh:
```bash
mysqld --verbose --help
```
Trong phần đầu kết quả, dòng chữ xuất hiện tương tự:
```text
Default options are read from the following files in the given order:
C:\Windows\my.ini C:\Windows\my.cnf C:\my.ini C:\my.cnf C:\Program Files\MySQL\MySQL Server 8.0\my.ini C:\Program Files\MySQL\MySQL Server 8.0\my.cnf
```

---

## 3. Các Option Groups

Trong file cấu hình, các tham số được chia theo nhóm đặt trong dấu ngoặc vuông:

```ini
# Nhóm cấu hình dành cho server daemon mysqld
[mysqld]
port=3306
datadir="C:/ProgramData/MySQL/MySQL Server 8.0/Data"
default_storage_engine=InnoDB
max_connections=151
innodb_buffer_pool_size=128M

# Nhóm cấu hình áp dụng cho mọi MySQL client
[client]
port=3306
default-character-set=utf8mb4

# Nhóm cấu hình riêng cho công cụ dòng lệnh mysql CLI
[mysql]
no-auto-rehash
```

---

## 4. Biến Hệ thống: Global vs Session & Dynamic vs Static

### 4.1. Phạm vi biến (Scope)
- **GLOBAL:** Tác động đến toàn bộ server và mọi kết nối mới.
- **SESSION:** Chỉ có hiệu lực trong phạm vi kết nối hiện tại của client đó.

```sql
-- Xem giá trị biến toàn cục
SHOW GLOBAL VARIABLES LIKE 'max_connections';

-- Xem giá trị biến cấp phiên kết nối
SHOW SESSION VARIABLES LIKE 'autocommit';
```

### 4.2. Khả năng thay đổi lúc runtime
- **Dynamic Variables (Biến động):** Có thể thay đổi ngay lập tức bằng lệnh `SET GLOBAL ...` mà không cần restart server:
  ```sql
  SET GLOBAL max_connections = 200;
  ```
- **Static Variables (Biến tĩnh):** Là các tham số chỉ được nạp một lần khi tiến trình server khởi động (ví dụ: `datadir`, `port`, `lower_case_table_names`). Muốn thay đổi bắt buộc phải sửa file `my.ini` và restart dịch vụ.

---

## 5. Thư mục Dữ liệu (Data Directory) và Cấu trúc Lưu trữ

### 5.1. Xác định thư mục dữ liệu
Không nên tìm kiếm thủ công mà hãy truy vấn trực tiếp từ server:
```sql
SHOW VARIABLES LIKE 'datadir';
```

### 5.2. Các thành phần chính trong `datadir`
1. **Các thư mục database:** Mỗi database người dùng tạo là một thư mục riêng (ví dụ: thư mục `classicmodels/`).
2. **File Tablespace (`*.ibd`):** Khi kích hoạt `innodb_file_per_table` (mặc định trong MySQL 8.x), mỗi bảng sẽ có một file `.ibd` chứa toàn bộ dữ liệu dòng và cây chỉ mục B-Tree của bảng đó.
3. **System Tablespace (`ibdata1`):** Chứa dữ liệu nội bộ của engine InnoDB, data dictionary (trong phiên bản cũ), và doublewrite buffer.
4. **Hệ thống Log files:**
   - **Redo Log (`#ib_redo*`):** Ghi nhận các thao tác ghi dữ liệu trước khi flush xuống đĩa (Write-Ahead Logging - WAL). Đảm bảo phục hồi dữ liệu khi mất điện đột ngột (Crash Recovery).
   - **Undo Log:** Lưu lại trạng thái cũ của dữ liệu phục vụ cho rollback giao dịch và cơ chế đọc nhất quán (MVCC).
   - **Binary Log (`binlog.*`):** Lưu trữ tuần tự các sự kiện thay đổi dữ liệu để phục vụ nhân bản dữ liệu (Replication) và khôi phục về điểm thời gian cụ thể (Point-in-time Recovery).
