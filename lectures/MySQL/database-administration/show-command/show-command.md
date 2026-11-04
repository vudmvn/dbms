---
title: "Tutorial: SHOW Commands và mysqldump trong MySQL"
author: "Tên giảng viên"
duration: "150m"
difficulty: "Beginner–Intermediate"
prerequisites:
  - "Đã biết database, table, column và các câu lệnh SELECT cơ bản"
  - "Đã biết kết nối bằng MySQL Workbench hoặc mysql command-line client"
  - "Đã cài MySQL client tools, gồm mysql và mysqldump, nếu thực hành backup"
summary: "Thực hành SHOW DATABASES, SHOW TABLES, SHOW COLUMNS, SHOW PROCESSLIST và mysqldump để khám phá metadata, theo dõi session cơ bản, sao lưu và kiểm tra khôi phục database MySQL."
---

# Tutorial: SHOW Commands và `mysqldump` trong MySQL

## Link tham khảo

### MySQL Tutorial

- [MySQL Administration](https://www.mysqltutorial.org/mysql-administration/)
- [SHOW DATABASES](https://www.mysqltutorial.org/mysql-administration/mysql-show-databases/)
- [SHOW TABLES](https://www.mysqltutorial.org/mysql-show-tables/)
- [SHOW COLUMNS và DESCRIBE](https://www.mysqltutorial.org/mysql-administration/mysql-show-columns/)
- [SHOW PROCESSLIST](https://www.mysqltutorial.org/mysql-show-processlist/)

> **Phạm vi an toàn:** `SHOW` chỉ đọc metadata hoặc thông tin session. Tuy nhiên, `mysqldump` có thể chứa toàn bộ dữ liệu và definition của database; file backup phải được bảo vệ như dữ liệu nhạy cảm. Chỉ restore vào database test/lab cho đến khi đã có quy trình kiểm tra và được phép thao tác trên môi trường thật.

---

## 1. Mục tiêu học tập

Sau khi hoàn thành tutorial này, người học có thể:

1. Dùng `SHOW DATABASES` để liệt kê các database có thể nhìn thấy trên MySQL Server.
2. Dùng `SHOW TABLES` và `SHOW FULL TABLES` để liệt kê table và view trong một schema.
3. Dùng `SHOW COLUMNS`, `DESCRIBE` và `SHOW FULL COLUMNS` để đọc cấu trúc table.
4. Hiểu các trường `Field`, `Type`, `Null`, `Key`, `Default`, `Extra` trong kết quả `SHOW COLUMNS`.
5. Dùng `SHOW PROCESSLIST` và `SHOW FULL PROCESSLIST` để xem session/thread đang hoạt động.
6. Hiểu giới hạn quyền xem process list, đặc biệt với privilege `PROCESS`.
7. Kiểm tra phiên bản và sự sẵn có của `mysqldump`.
8. Sao lưu một database, một table, schema-only hoặc data-only bằng `mysqldump`.
9. Sao lưu routine, trigger và event khi cần.
10. Restore dump vào môi trường kiểm thử và xác minh kết quả.
11. Nhận biết các rủi ro phổ biến khi backup/restore và áp dụng các kiểm tra cơ bản.

---

## 2. Tổng quan: Metadata, process information và backup

Ba nhóm thao tác trong tutorial này phục vụ ba nhu cầu khác nhau.

| Nhóm | Công cụ/lệnh | Mục đích |
|---|---|---|
| Khám phá metadata | `SHOW DATABASES`, `SHOW TABLES`, `SHOW COLUMNS` | Xem database, object và cấu trúc table |
| Theo dõi session | `SHOW PROCESSLIST` | Xem các thread/session đang làm gì trên server |
| Sao lưu và phục hồi | `mysqldump`, `mysql` client | Xuất database ra file SQL và nạp lại khi cần |

### 2.1. SHOW commands không thay thế INFORMATION_SCHEMA

`SHOW` commands thường ngắn, tiện cho thao tác nhanh trong client.

Ví dụ:

```sql
SHOW TABLES;
```

Nếu cần lọc phức tạp, join metadata hoặc tạo report, có thể dùng `INFORMATION_SCHEMA`.

Ví dụ:

```sql
SELECT TABLE_NAME, TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'classicmodels'
ORDER BY TABLE_NAME;
```

### 2.2. Backup không chỉ là tạo file

Một backup có giá trị khi:

1. File dump được tạo thành công.
2. File được lưu ở nơi bảo vệ phù hợp.
3. Có thể restore được.
4. Dữ liệu sau restore được kiểm tra.
5. Quy trình được thực hành định kỳ.

> Một file `.sql` chưa từng được restore thử không phải là bằng chứng đầy đủ rằng backup có thể dùng để khôi phục.

### Bài tập thực hành

**Bài 2.1.**

Nêu mục đích của `SHOW DATABASES`.

**Bài 2.2.**

Nêu mục đích của `SHOW PROCESSLIST`.

**Bài 2.3.**

Nêu hai lý do một file backup cần được kiểm tra bằng restore.

**Bài 2.4.**

Khi nào nên dùng `INFORMATION_SCHEMA` thay vì `SHOW TABLES`?

**Bài 2.5.**

Giải thích vì sao file dump cần được coi là dữ liệu nhạy cảm.

---

## 3. Chuẩn bị môi trường

### 3.1. Kết nối MySQL

Ví dụ với mysql command-line client:

```bash
mysql -u root -p
```

Sau khi nhập mật khẩu, kiểm tra server và user hiện tại:

```sql
SELECT VERSION() AS mysqlVersion;

SELECT USER() AS loginUser,
       CURRENT_USER() AS privilegeAccount;
```

### 3.2. Kiểm tra database `classicmodels`

```sql
SHOW DATABASES LIKE 'classicmodels';
```

Nếu `classicmodels` tồn tại:

```sql
USE classicmodels;
```

Kiểm tra table:

```sql
SHOW TABLES;
```

### 3.3. Kiểm tra `mysqldump`

Mở Command Prompt trên Windows hoặc Terminal trên Linux/macOS:

```bash
mysqldump --version
```

Ví dụ output có thể cho biết version của client utility.

> Nên dùng `mysqldump` có version tương thích với MySQL Server đang làm việc. Khi có thể, dùng client tools cùng major version hoặc phiên bản được nhà quản trị khuyến nghị.

### 3.4. Tạo database kiểm thử restore

Không restore đè ngay lên database nguồn. Tạo database đích riêng:

```sql
CREATE DATABASE IF NOT EXISTS classicmodels_restore_test;
```

Khi restore test hoàn tất, có thể xóa:

```sql
DROP DATABASE IF EXISTS classicmodels_restore_test;
```

> Không chạy `DROP DATABASE` trên database source hoặc production.

### Bài tập thực hành

**Bài 3.1.**

Kết nối MySQL bằng mysql client và chạy `SELECT VERSION();`.

**Bài 3.2.**

Kiểm tra account đăng nhập và account dùng để xét quyền bằng `USER()` và `CURRENT_USER()`.

**Bài 3.3.**

Kiểm tra database `classicmodels` có tồn tại hay không.

**Bài 3.4.**

Chạy `mysqldump --version` trong terminal hoặc Command Prompt.

**Bài 3.5.**

Tạo database kiểm thử `classicmodels_restore_test` nếu chưa tồn tại.

---

# Phần A. SHOW DATABASES

## 4. Hiển thị database bằng `SHOW DATABASES`

### 4.1. Cú pháp

```sql
SHOW DATABASES;
```

Lệnh hiển thị các database mà account hiện tại có quyền nhìn thấy.

Ví dụ:

```sql
SHOW DATABASES;
```

Trên server lab, kết quả có thể gồm:

```text
classicmodels
information_schema
mysql
performance_schema
sys
user_mgmt_lab
```

Danh sách thực tế phụ thuộc vào:

- Database có trên server.
- Phiên bản MySQL.
- Quyền của account đang kết nối.
- Cấu hình hệ thống.

### 4.2. Hiển thị database theo mẫu với `LIKE`

Cú pháp:

```sql
SHOW DATABASES LIKE 'pattern';
```

Ví dụ:

```sql
SHOW DATABASES LIKE 'classic%';
```

Ví dụ:

```sql
SHOW DATABASES LIKE '%lab%';
```

Trong pattern:

| Ký hiệu | Ý nghĩa |
|---|---|
| `%` | Khớp với 0 hoặc nhiều ký tự |
| `_` | Khớp với đúng một ký tự |

Ví dụ:

```sql
SHOW DATABASES LIKE 'test_';
```

có thể khớp `test1`, `testA`, nhưng không khớp `test` hoặc `test12`.

### 4.3. Hiển thị bằng `WHERE`

Một số `SHOW` statements hỗ trợ `WHERE`.

Ví dụ:

```sql
SHOW DATABASES
WHERE `Database` LIKE '%model%';
```

Tên cột kết quả thường là:

```text
Database
```

Khi dùng tên cột này trong `WHERE`, có thể đặt trong backticks:

```sql
SHOW DATABASES
WHERE `Database` = 'classicmodels';
```

### 4.4. Quyền và kết quả hiển thị

Nếu account không có `SHOW DATABASES` privilege, MySQL không nhất thiết hiển thị toàn bộ database trên server; danh sách có thể bị giới hạn ở các schema mà account có quyền truy cập nào đó.

Do đó, không suy luận rằng database không tồn tại chỉ vì user thường không nhìn thấy nó.

### 4.5. So sánh với `INFORMATION_SCHEMA.SCHEMATA`

```sql
SELECT SCHEMA_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
ORDER BY SCHEMA_NAME;
```

`INFORMATION_SCHEMA.SCHEMATA` hữu ích khi cần:

- Chọn các cột metadata khác.
- Lọc phức tạp.
- Kết hợp với truy vấn metadata khác.
- Dùng trong view hoặc stored program.

### Bài tập thực hành

**Bài 4.1.**

Dùng `SHOW DATABASES` để liệt kê database nhìn thấy được trên server.

**Bài 4.2.**

Dùng `SHOW DATABASES LIKE 'classic%';` để tìm database bắt đầu bằng `classic`.

**Bài 4.3.**

Dùng `SHOW DATABASES LIKE '%lab%';` để tìm các database có chứa chuỗi `lab`.

**Bài 4.4.**

Dùng `SHOW DATABASES WHERE` để kiểm tra `classicmodels` có xuất hiện trong danh sách hay không.

**Bài 4.5.**

Viết truy vấn từ `INFORMATION_SCHEMA.SCHEMATA` để liệt kê database theo thứ tự alphabet.

---

# Phần B. SHOW TABLES

## 5. Liệt kê table bằng `SHOW TABLES`

### 5.1. Dùng database hiện tại

Trước hết chọn database:

```sql
USE classicmodels;
```

Sau đó:

```sql
SHOW TABLES;
```

Lệnh hiển thị table và có thể cả view trong schema hiện tại, tùy object và phiên bản/cấu hình.

Ví dụ các bảng thường gặp trong `classicmodels`:

```text
customers
employees
offices
orders
orderdetails
payments
productlines
products
```

### 5.2. Không cần `USE`: chỉ rõ schema

Có thể liệt kê table của một database mà không chuyển database hiện tại:

```sql
SHOW TABLES FROM classicmodels;
```

Hoặc:

```sql
SHOW TABLES IN classicmodels;
```

Hai cách trên tương đương về mục đích.

### 5.3. Lọc table bằng `LIKE`

```sql
SHOW TABLES FROM classicmodels
LIKE 'order%';
```

Ví dụ này thường tìm các table có tên bắt đầu bằng `order`, chẳng hạn:

```text
orders
orderdetails
```

Tìm các table kết thúc bằng `s`:

```sql
SHOW TABLES FROM classicmodels
LIKE '%s';
```

### 5.4. Dùng `SHOW FULL TABLES`

`SHOW FULL TABLES` thêm cột `Table_type`, giúp phân biệt:

```text
BASE TABLE
VIEW
```

Ví dụ:

```sql
SHOW FULL TABLES FROM classicmodels;
```

Lọc chỉ view:

```sql
SHOW FULL TABLES FROM classicmodels
WHERE Table_type = 'VIEW';
```

Lọc chỉ base table:

```sql
SHOW FULL TABLES FROM classicmodels
WHERE Table_type = 'BASE TABLE';
```

> Tên cột table-name ở output phụ thuộc schema. Ví dụ với `classicmodels`, cột có thể có tên `Tables_in_classicmodels`.

### 5.5. So sánh `SHOW TABLES` với `INFORMATION_SCHEMA.TABLES`

```sql
SELECT TABLE_NAME,
       TABLE_TYPE,
       ENGINE,
       TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'classicmodels'
ORDER BY TABLE_NAME;
```

`INFORMATION_SCHEMA.TABLES` phù hợp hơn nếu cần:

- Lấy `ENGINE`.
- Xem `TABLE_TYPE`.
- Lọc theo metadata.
- Tổng hợp thông tin cho nhiều schema.

> `TABLE_ROWS` của một số storage engine có thể là ước lượng; không dùng nó thay cho `COUNT(*)` khi cần số dòng chính xác.

### Bài tập thực hành

**Bài 5.1.**

Chọn `classicmodels`, sau đó dùng `SHOW TABLES`.

**Bài 5.2.**

Dùng `SHOW TABLES FROM classicmodels;` mà không cần đổi database hiện tại.

**Bài 5.3.**

Dùng `SHOW TABLES FROM classicmodels LIKE 'order%';`.

**Bài 5.4.**

Dùng `SHOW FULL TABLES FROM classicmodels;` để xem loại object.

**Bài 5.5.**

Viết truy vấn từ `INFORMATION_SCHEMA.TABLES` để liệt kê tên table và table type trong `classicmodels`.

---

## 6. Các biến thể hữu ích của `SHOW TABLES`

### 6.1. `SHOW TABLES LIKE`

Ví dụ tìm các table chứa `product`:

```sql
SHOW TABLES FROM classicmodels
LIKE '%product%';
```

### 6.2. `SHOW FULL TABLES WHERE`

Ví dụ chỉ hiển thị base table:

```sql
SHOW FULL TABLES FROM classicmodels
WHERE Table_type = 'BASE TABLE';
```

### 6.3. `SHOW TABLE STATUS`

Lệnh sau không nằm trong phạm vi bắt buộc của phần Show Commands, nhưng hữu ích khi cần xem metadata table mở rộng:

```sql
SHOW TABLE STATUS FROM classicmodels;
```

Thông tin có thể bao gồm:

- Engine.
- Row format.
- Table rows.
- Data length.
- Index length.
- Create time.
- Update time.
- Collation.
- Comment.

Dùng cho mục đích khám phá nhanh; không coi mọi cột là số liệu tuyệt đối chính xác về dữ liệu hoặc kích thước, đặc biệt khi storage engine trả về giá trị ước lượng.

### 6.4. `SHOW CREATE TABLE`

Để xem DDL tạo một bảng:

```sql
SHOW CREATE TABLE classicmodels.orders;
```

Lệnh này rất hữu ích để kiểm tra:

- Cột.
- Data type.
- Primary key.
- Foreign key.
- Index.
- Engine.
- Charset/collation.
- Table options.

### Bài tập thực hành

**Bài 6.1.**

Dùng `SHOW TABLES FROM classicmodels LIKE '%product%';`.

**Bài 6.2.**

Dùng `SHOW FULL TABLES FROM classicmodels WHERE Table_type = 'BASE TABLE';`.

**Bài 6.3.**

Dùng `SHOW TABLE STATUS FROM classicmodels LIKE 'orders';`.

**Bài 6.4.**

Dùng `SHOW CREATE TABLE classicmodels.orders;`.

**Bài 6.5.**

Giải thích khi nào `SHOW CREATE TABLE` hữu ích hơn `SHOW COLUMNS`.

---

# Phần C. SHOW COLUMNS

## 7. Hiển thị cấu trúc table bằng `SHOW COLUMNS`

### 7.1. Cú pháp cơ bản

```sql
SHOW COLUMNS FROM table_name;
```

Ví dụ:

```sql
USE classicmodels;

SHOW COLUMNS FROM orders;
```

Hoặc chỉ rõ database:

```sql
SHOW COLUMNS FROM orders FROM classicmodels;
```

Cũng có thể dùng dạng định danh đầy đủ:

```sql
SHOW COLUMNS FROM classicmodels.orders;
```

### 7.2. `DESCRIBE` và `DESC`

`DESCRIBE` hoặc `DESC` cung cấp thông tin tương tự:

```sql
DESCRIBE orders;
```

```sql
DESC orders;
```

Trong thực hành, `DESC orders;` là dạng ngắn thường dùng; `SHOW COLUMNS` linh hoạt hơn khi cần `FULL`, `LIKE` hoặc `WHERE`.

### 7.3. Ý nghĩa các cột output

Ví dụ output của `SHOW COLUMNS` thường có các trường:

| Cột output | Ý nghĩa |
|---|---|
| `Field` | Tên cột |
| `Type` | Kiểu dữ liệu |
| `Null` | `YES` nếu cột có thể chứa `NULL`; `NO` nếu không |
| `Key` | Thông tin index chính: `PRI`, `UNI`, `MUL` hoặc trống |
| `Default` | Giá trị mặc định |
| `Extra` | Thông tin bổ sung, ví dụ `auto_increment` |

Ý nghĩa thường gặp của `Key`:

| Giá trị | Ý nghĩa |
|---|---|
| `PRI` | Cột là primary key hoặc thuộc composite primary key |
| `UNI` | Cột là cột đầu của unique index |
| `MUL` | Cột là cột đầu của non-unique index, cho phép lặp giá trị |
| Trống | Không có thông tin index chính ở vị trí này hoặc chỉ là cột sau trong composite index |

> Với composite key/index, `SHOW COLUMNS` không thay thế hoàn toàn `SHOW INDEX` hoặc `SHOW CREATE TABLE` để phân tích đầy đủ thứ tự và cấu trúc index.

### 7.4. `SHOW FULL COLUMNS`

Dùng `FULL` để có thêm thông tin như collation, column privileges và comment:

```sql
SHOW FULL COLUMNS FROM products;
```

Ví dụ có thể cung cấp thêm:

| Cột output thêm | Ý nghĩa |
|---|---|
| `Collation` | Collation cho các cột chuỗi không nhị phân |
| `Privileges` | Quyền mà account hiện tại có trên cột |
| `Comment` | Comment được khai báo cho cột |

### 7.5. Lọc cột bằng `LIKE`

```sql
SHOW COLUMNS FROM customers
LIKE '%Name%';
```

Ví dụ này có thể tìm:

```text
customerName
contactLastName
contactFirstName
```

### 7.6. Lọc cột bằng `WHERE`

```sql
SHOW COLUMNS FROM orders
WHERE `Key` = 'PRI';
```

Ví dụ tìm các cột không cho phép `NULL`:

```sql
SHOW COLUMNS FROM orders
WHERE `Null` = 'NO';
```

### 7.7. So sánh với `INFORMATION_SCHEMA.COLUMNS`

```sql
SELECT COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_KEY,
       COLUMN_DEFAULT,
       EXTRA,
       COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'classicmodels'
  AND TABLE_NAME = 'orders'
ORDER BY ORDINAL_POSITION;
```

Cách này phù hợp khi cần:

- Lọc nhiều điều kiện.
- Lấy metadata của nhiều table.
- Kết hợp metadata với constraints/indexes.
- Xuất report.

### Bài tập thực hành

**Bài 7.1.**

Dùng `SHOW COLUMNS FROM classicmodels.orders;`.

**Bài 7.2.**

Dùng `DESC classicmodels.customers;`.

**Bài 7.3.**

Dùng `SHOW FULL COLUMNS FROM classicmodels.products;`.

**Bài 7.4.**

Dùng `SHOW COLUMNS FROM classicmodels.orders WHERE \`Key\` = 'PRI';`.

**Bài 7.5.**

Viết truy vấn `INFORMATION_SCHEMA.COLUMNS` để hiển thị cấu trúc `classicmodels.orderdetails` theo thứ tự cột.

---

## 8. Đọc cấu trúc `classicmodels` bằng SHOW COLUMNS

### 8.1. Bảng `orders`

```sql
SHOW COLUMNS FROM classicmodels.orders;
```

Khi đọc output, cần chú ý:

- `orderNumber` thường là định danh đơn hàng.
- `customerNumber` liên kết logic tới khách hàng.
- `status` thể hiện trạng thái đơn hàng.
- `orderDate`, `requiredDate`, `shippedDate` là các cột ngày.

### 8.2. Bảng `orderdetails`

```sql
SHOW COLUMNS FROM classicmodels.orderdetails;
```

Bảng này thường có khóa chính ghép từ:

```text
orderNumber + productCode
```

Để xác nhận đúng DDL và key, dùng:

```sql
SHOW CREATE TABLE classicmodels.orderdetails;
```

### 8.3. Bảng `products`

```sql
SHOW COLUMNS FROM classicmodels.products;
```

Các cột đáng chú ý:

- `productCode`.
- `productName`.
- `productLine`.
- `quantityInStock`.
- `buyPrice`.
- `MSRP`.

### 8.4. Bảng `customers`

```sql
SHOW COLUMNS FROM classicmodels.customers;
```

Khi xem `customers`, có thể xác định:

- Các cột có thể `NULL`.
- Cột contact info.
- Hạn mức tín dụng.
- Cột liên kết nhân viên bán hàng.

### Bài tập thực hành

**Bài 8.1.**

Dùng `SHOW COLUMNS` để xác định các cột của bảng `orders`.

**Bài 8.2.**

Dùng `SHOW CREATE TABLE` để kiểm tra composite key trong `orderdetails`.

**Bài 8.3.**

Dùng `SHOW FULL COLUMNS` để xác định comment hoặc collation của các cột trong `products`, nếu server/schema có khai báo.

**Bài 8.4.**

Dùng `SHOW COLUMNS FROM classicmodels.customers WHERE \`Null\` = 'YES';` để tìm các cột có thể nhận `NULL`.

**Bài 8.5.**

Dùng `SHOW COLUMNS FROM classicmodels.products LIKE '%Price%';` để tìm các cột liên quan đến giá.

---

# Phần D. SHOW PROCESSLIST

## 9. Theo dõi session bằng `SHOW PROCESSLIST`

### 9.1. `SHOW PROCESSLIST` là gì?

`SHOW PROCESSLIST` hiển thị thông tin về các thread/session đang hoạt động trên MySQL Server.

Cú pháp:

```sql
SHOW PROCESSLIST;
```

Để xem phần câu SQL đầy đủ hơn trong cột `Info`:

```sql
SHOW FULL PROCESSLIST;
```

`SHOW PROCESSLIST` hữu ích khi:

- Kết nối bị tăng bất thường.
- Có query chạy lâu.
- Ứng dụng báo timeout.
- Cần xem session đang ở trạng thái nào.
- Cần xác định connection ID trước khi xử lý theo quy trình quản trị.

### 9.2. Quyền xem process list

Thông thường:

- Account có privilege `PROCESS` có thể xem các thread của người dùng khác.
- Account không có `PROCESS` thường chỉ xem được thread của chính account đó.

Do đó, một user application không nên được cấp `PROCESS` chỉ để xem session nếu không có nhu cầu vận hành rõ ràng.

### 9.3. `SHOW PROCESSLIST` và `SHOW FULL PROCESSLIST`

```sql
SHOW PROCESSLIST;
```

Dạng mặc định có thể chỉ hiển thị phần đầu của SQL trong `Info`.

```sql
SHOW FULL PROCESSLIST;
```

Dạng `FULL` hiển thị nội dung `Info` đầy đủ hơn, hữu ích khi cần đọc query dài.

### 9.4. Các cột thường gặp

| Cột | Ý nghĩa |
|---|---|
| `Id` | Connection identifier của client/thread |
| `User` | User account liên quan |
| `Host` | Host/client nguồn của kết nối |
| `db` | Default database của session, có thể là `NULL` |
| `Command` | Loại hoạt động hiện tại, ví dụ `Query`, `Sleep` |
| `Time` | Thời gian thread ở trạng thái hiện tại |
| `State` | Trạng thái chi tiết hơn |
| `Info` | Statement đang thực thi; có thể `NULL` |

Ví dụ:

```sql
SHOW FULL PROCESSLIST;
```

### 9.5. Đọc kết quả một cách thận trọng

Một session ở trạng thái `Sleep` không tự động là lỗi. Connection pooling của ứng dụng có thể giữ các kết nối rảnh để tái sử dụng.

Cần quan tâm hơn khi:

- Số lượng session tăng bất thường.
- `Time` rất lớn với một query/state đáng ngờ.
- Có nhiều session cùng chờ lock.
- Query chạy lâu gây ảnh hưởng hệ thống.
- Database đạt giới hạn kết nối.

> Không tự ý kết luận hoặc kill session chỉ dựa vào một lần chụp `SHOW PROCESSLIST`. Cần xem application context, transaction, lock, workload và hướng dẫn vận hành của hệ thống.

### Bài tập thực hành

**Bài 9.1.**

Chạy `SHOW PROCESSLIST;`.

**Bài 9.2.**

Chạy `SHOW FULL PROCESSLIST;` và so sánh cột `Info` với kết quả không dùng `FULL`.

**Bài 9.3.**

Xác định connection ID của session hiện tại bằng `SELECT CONNECTION_ID();`.

**Bài 9.4.**

Tìm dòng có `Id` tương ứng với `CONNECTION_ID()` trong output process list.

**Bài 9.5.**

Giải thích ý nghĩa của các cột `Id`, `User`, `Host`, `Command`, `Time`, `State`, `Info`.

---

## 10. Thực hành xem hai session

Để quan sát rõ hơn process list, mở hai cửa sổ MySQL client.

### Session A

Kết nối MySQL:

```bash
mysql -u root -p
```

Sau đó chạy:

```sql
USE classicmodels;

SELECT SLEEP(30);
```

### Session B

Kết nối MySQL ở cửa sổ khác:

```bash
mysql -u root -p
```

Chạy:

```sql
SHOW FULL PROCESSLIST;
```

Trong thời gian Session A đang thực hiện `SLEEP(30)`, Session B có thể thấy thread tương ứng với:

- `Command` là `Query`.
- `Time` tăng dần.
- `Info` chứa statement `SELECT SLEEP(30)`.

### 10.1. Không kill session tùy tiện

MySQL có lệnh `KILL`, ví dụ:

```sql
KILL CONNECTION connection_id;
```

Tuy nhiên, lệnh này có thể ngắt query, transaction hoặc ứng dụng đang hoạt động.

Trong lab, chỉ cân nhắc thao tác với **session do chính bạn tạo** và chỉ khi giảng viên yêu cầu.

Không chạy `KILL` trên server dùng chung hoặc production nếu chưa xác định:

- Session thuộc ứng dụng nào.
- Query có thể rollback hay không.
- Có transaction hoặc lock quan trọng không.
- Quy trình incident của tổ chức yêu cầu gì.

### 10.2. Alternative sources for process information

Ngoài `SHOW PROCESSLIST`, MySQL còn có thể cung cấp thông tin thread qua:

- `INFORMATION_SCHEMA.PROCESSLIST`.
- Performance Schema `processlist` / `threads`.
- `sys.processlist`.
- `mysqladmin processlist`.

Ví dụ:

```sql
SELECT *
FROM INFORMATION_SCHEMA.PROCESSLIST;
```

Trong các môi trường DBA/monitoring hiện đại, Performance Schema hoặc `sys` views có thể phù hợp hơn cho giám sát chi tiết và hiệu năng tốt hơn, tùy cấu hình server.

### Bài tập thực hành

**Bài 10.1.**

Mở hai session MySQL và chạy `SELECT SLEEP(15);` trong Session A.

**Bài 10.2.**

Trong Session B, dùng `SHOW FULL PROCESSLIST;` để tìm query `SELECT SLEEP(15)`.

**Bài 10.3.**

Ghi lại `Id` và `Time` của query đó trong lúc nó đang chạy.

**Bài 10.4.**

Sau khi query kết thúc, chạy lại `SHOW PROCESSLIST` và quan sát thay đổi.

**Bài 10.5.**

Viết truy vấn lấy các dòng từ `INFORMATION_SCHEMA.PROCESSLIST` mà `COMMAND <> 'Sleep'`.

---

## 11. Các lưu ý khi phân tích process list

### 11.1. `Command = Sleep`

`Sleep` chỉ cho biết client đang kết nối nhưng không thực thi statement tại thời điểm quan sát.

Có thể bình thường nếu ứng dụng dùng connection pool.

Cần kiểm tra thêm:

- Số lượng sleep session.
- Thời gian sleep.
- Giới hạn `max_connections`.
- Hành vi connection pooling.
- Cấu hình timeout.

### 11.2. `Time` lớn

`Time` là số giây thread ở trạng thái hiện tại, không phải luôn là tổng thời gian tồn tại của connection.

Một thread có `Time` cao có thể cần xem xét, nhưng không đủ để kết luận ngay query bị treo.

### 11.3. `Info = NULL`

`Info` có thể là `NULL` khi thread không thực thi statement.

### 11.4. Query dài

Dùng:

```sql
SHOW FULL PROCESSLIST;
```

để xem query dài hơn thay vì chỉ dùng `SHOW PROCESSLIST`.

### 11.5. Không cấp `PROCESS` bừa bãi

`PROCESS` cho phép quan sát thông tin thread của account khác; thông tin này có thể lộ database name hoặc statement đang chạy.

Chỉ cấp privilege này cho các account giám sát/DBA có trách nhiệm phù hợp.

### Bài tập thực hành

**Bài 11.1.**

Giải thích vì sao `Sleep` không tự động chứng minh một session có vấn đề.

**Bài 11.2.**

Nêu ý nghĩa của `Time` trong process list.

**Bài 11.3.**

Nêu một lý do `Info` có thể là `NULL`.

**Bài 11.4.**

Nêu một lý do nên dùng `SHOW FULL PROCESSLIST` thay vì `SHOW PROCESSLIST`.

**Bài 11.5.**

Giải thích vì sao `PROCESS` privilege không nên cấp cho mọi user application.

---

# Phần E. mysqldump

## 12. Giới thiệu `mysqldump`

### 12.1. `mysqldump` là gì?

`mysqldump` là command-line utility dùng để xuất cấu trúc database và/hoặc dữ liệu thành một file, thường là SQL text.

Ví dụ:

```bash
mysqldump -u root -p classicmodels > classicmodels_backup.sql
```

File `classicmodels_backup.sql` có thể chứa:

- `CREATE TABLE`.
- `INSERT INTO`.
- Index.
- Trigger.
- Có thể chứa routine, event tùy option.
- Các statement thiết lập session cần thiết cho restore.

### 12.2. Cú pháp cơ bản

```bash
mysqldump [options] database_name > backup_file.sql
```

Ví dụ backup một database:

```bash
mysqldump -u root -p classicmodels > classicmodels_backup.sql
```

Ví dụ backup một table:

```bash
mysqldump -u root -p classicmodels orders > orders_backup.sql
```

### 12.3. Không đưa password trực tiếp vào command line

Không nên:

```bash
mysqldump -u root -pMyRealPassword classicmodels > backup.sql
```

Password có thể lộ qua history, process list của OS hoặc log.

Nên dùng:

```bash
mysqldump -u root -p classicmodels > backup.sql
```

Sau đó tool sẽ hỏi mật khẩu.

Trong môi trường tự động hóa, dùng option file được bảo vệ, secret manager hoặc cơ chế quản lý credential phù hợp thay vì đưa password trực tiếp lên command line.

### 12.4. Kiểm tra client tool

```bash
mysqldump --version
```

Kiểm tra help:

```bash
mysqldump --help
```

### 12.5. File dump có chứa dữ liệu nhạy cảm

Dump có thể chứa:

- Dữ liệu cá nhân.
- Mật khẩu hash hoặc account metadata nếu dump system schema.
- Business data.
- Schema và logic ứng dụng.
- Stored routine, trigger, event.

Cần bảo vệ file backup bằng:

- Phân quyền file/folder phù hợp.
- Mã hóa at rest nếu chính sách yêu cầu.
- Không gửi qua kênh công khai.
- Retention policy.
- Kiểm soát người được phép restore.

### Bài tập thực hành

**Bài 12.1.**

Chạy `mysqldump --version`.

**Bài 12.2.**

Viết lệnh backup database `classicmodels` vào file `classicmodels_backup.sql`.

**Bài 12.3.**

Viết lệnh backup chỉ bảng `orders` trong `classicmodels`.

**Bài 12.4.**

Giải thích vì sao không nên viết password thật trực tiếp sau `-p`.

**Bài 12.5.**

Nêu ba loại thông tin có thể xuất hiện trong một file dump.

---

## 13. Backup một database và một table

### 13.1. Backup database cơ bản

```bash
mysqldump -u root -p classicmodels > classicmodels_backup.sql
```

Lệnh này tạo file SQL chứa nội dung dump của schema `classicmodels`.

### 13.2. Backup với `--databases`

```bash
mysqldump -u root -p --databases classicmodels > classicmodels_with_create_database.sql
```

Tùy chọn `--databases` yêu cầu dump bao gồm statement như:

```sql
CREATE DATABASE ...
USE classicmodels;
```

Điều này giúp restore bằng:

```bash
mysql -u root -p < classicmodels_with_create_database.sql
```

Tuy nhiên, hãy đọc nội dung file và kiểm tra tên database trước khi restore, đặc biệt nếu dump có `DROP DATABASE` hoặc được tạo bằng các option khác.

### 13.3. Backup một hoặc nhiều table

Backup một table:

```bash
mysqldump -u root -p classicmodels orders > orders_backup.sql
```

Backup nhiều table:

```bash
mysqldump -u root -p classicmodels orders orderdetails > orders_and_details_backup.sql
```

> Nếu backup các table có foreign key, restore riêng từng table có thể cần cân nhắc thứ tự hoặc các statement foreign-key checks do dump tạo ra. Hãy kiểm tra file dump và thử restore trong database test.

### 13.4. Đặt tên file có timestamp

Ví dụ trên Windows PowerShell:

```powershell
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
mysqldump -u root -p classicmodels > "classicmodels_$stamp.sql"
```

Ví dụ trên Linux/macOS shell:

```bash
stamp=$(date +%Y%m%d_%H%M%S)
mysqldump -u root -p classicmodels > "classicmodels_${stamp}.sql"
```

Tên file có timestamp giúp:

- Phân biệt các lần backup.
- Hỗ trợ retention.
- Tránh ghi đè nhầm file cũ.

### 13.5. Nén file dump

Trên Linux/macOS:

```bash
mysqldump -u root -p classicmodels | gzip > classicmodels_backup.sql.gz
```

Restore:

```bash
gunzip -c classicmodels_backup.sql.gz | mysql -u root -p
```

Trên Windows, có thể dùng công cụ nén phù hợp sau khi dump, hoặc dùng môi trường có `gzip`.

> Khi nén, vẫn cần giữ file ở vị trí bảo vệ. Nén không phải là mã hóa.

### Bài tập thực hành

**Bài 13.1.**

Backup `classicmodels` vào file `classicmodels_backup.sql`.

**Bài 13.2.**

Backup `classicmodels` bằng option `--databases` vào file riêng.

**Bài 13.3.**

Backup hai table `orders` và `orderdetails`.

**Bài 13.4.**

Viết command tạo file backup có timestamp trên hệ điều hành bạn đang dùng.

**Bài 13.5.**

Giải thích khác biệt chính giữa dump có và không có `--databases`.

---

## 14. Backup schema-only và data-only

### 14.1. Backup chỉ cấu trúc: `--no-data`

Dùng `--no-data` hoặc `-d` để dump DDL mà không dump dữ liệu:

```bash
mysqldump -u root -p --no-data classicmodels > classicmodels_schema.sql
```

File này thường chứa:

- `CREATE TABLE`.
- Index.
- Constraint.
- Có thể chứa view/routine/event theo option.
- Không chứa các `INSERT` cho dữ liệu table.

Dùng khi:

- Muốn version-control schema.
- Muốn so sánh cấu trúc.
- Muốn tạo database rỗng cho môi trường development.
- Muốn review DDL.

### 14.2. Backup chỉ dữ liệu: `--no-create-info`

Dùng `--no-create-info` hoặc `-t` để dump dữ liệu mà không dump `CREATE TABLE`:

```bash
mysqldump -u root -p --no-create-info classicmodels > classicmodels_data.sql
```

Dùng khi:

- Schema đã tồn tại ở môi trường đích.
- Cần nạp dữ liệu mẫu.
- Muốn tách schema migration và data seed.

### 14.3. Backup chỉ dữ liệu của một table

```bash
mysqldump -u root -p --no-create-info classicmodels orders > orders_data.sql
```

### 14.4. Backup chỉ schema của một table

```bash
mysqldump -u root -p --no-data classicmodels orders > orders_schema.sql
```

### 14.5. Kiểm tra nội dung file

Trên Linux/macOS:

```bash
head -n 40 classicmodels_schema.sql
```

Trên Windows PowerShell:

```powershell
Get-Content .\classicmodels_schema.sql -TotalCount 40
```

Bạn nên kiểm tra:

- File có đúng tên database/table mong muốn không.
- Có `CREATE TABLE` hay không.
- Có `INSERT INTO` hay không.
- Có `DROP TABLE`/`DROP DATABASE` hay không.
- Có thông tin `DEFINER` hoặc security context cần xem xét không.

### Bài tập thực hành

**Bài 14.1.**

Tạo file `classicmodels_schema.sql` chỉ chứa schema.

**Bài 14.2.**

Tạo file `classicmodels_data.sql` chỉ chứa dữ liệu.

**Bài 14.3.**

Tạo schema-only dump cho bảng `orders`.

**Bài 14.4.**

Tạo data-only dump cho bảng `orders`.

**Bài 14.5.**

Mở file schema-only và chỉ ra một dấu hiệu cho thấy file không chứa dữ liệu `INSERT`.

---

## 15. Backup routine, trigger và event

### 15.1. Vì sao cần quan tâm?

Database có thể chứa nhiều object ngoài table:

| Object | Ví dụ |
|---|---|
| Stored procedure | `sp_lab_list_customers_by_country` |
| Stored function | `fn_lab_order_total` |
| Trigger | Trigger kiểm tra hoặc log dữ liệu |
| Event | Tác vụ chạy theo lịch |
| View | View báo cáo |

Nếu chỉ backup table/data mà bỏ qua routine hoặc event, restore có thể thiếu logic nghiệp vụ hoặc automation.

### 15.2. Option thường dùng

Ví dụ backup đầy đủ database kèm stored programs:

```bash
mysqldump -u root -p \
  --single-transaction \
  --routines \
  --events \
  --triggers \
  --databases classicmodels \
  > classicmodels_full_backup.sql
```

Ý nghĩa:

| Option | Mục đích |
|---|---|
| `--single-transaction` | Tạo snapshot nhất quán cho các table transactional như InnoDB, trong điều kiện phù hợp |
| `--routines` | Bao gồm stored procedures và stored functions |
| `--events` | Bao gồm scheduled events |
| `--triggers` | Bao gồm triggers |
| `--databases` | Bao gồm statement tạo/chọn database |
| `>` | Redirect output vào file |

### 15.3. `--single-transaction`

`--single-transaction` thường phù hợp khi backup dữ liệu InnoDB vì nó tạo snapshot nhất quán mà không cần khóa table theo cách truyền thống trong toàn bộ thời gian dump.

Tuy nhiên:

- Nó không đảm bảo snapshot nhất quán tương tự cho non-transactional table như MyISAM.
- Không nên thực hiện DDL như `ALTER TABLE`, `CREATE TABLE`, `DROP TABLE`, `RENAME TABLE`, `TRUNCATE TABLE` đồng thời trong lúc dump nếu muốn tránh rủi ro về consistency.
- Cần đánh giá workload và chính sách backup của hệ thống thực.

### 15.4. Trigger

`mysqldump` có thể dump trigger; dùng `--triggers` một cách tường minh giúp script dễ đọc.

Nếu restore vào server khác, cần kiểm tra:

- DEFINER.
- Quyền tạo trigger.
- Charset/collation.
- Các dependency của trigger.

### 15.5. Routine và event

Dùng `--routines` để bao gồm stored procedures/functions.

Dùng `--events` để bao gồm scheduled events.

Nếu không có các options này, database restore có thể không có những object tương ứng.

### Bài tập thực hành

**Bài 15.1.**

Viết lệnh backup `classicmodels` có `--routines`, `--events`, `--triggers`.

**Bài 15.2.**

Giải thích mục đích của `--routines`.

**Bài 15.3.**

Giải thích mục đích của `--events`.

**Bài 15.4.**

Nêu hai lưu ý khi dùng `--single-transaction`.

**Bài 15.5.**

Mở file dump đầy đủ và tìm một từ khóa liên quan đến trigger, routine hoặc event nếu database có object tương ứng.

---

## 16. Restore database từ file dump

### 16.1. Restore dump không có `--databases`

Giả sử dump được tạo bằng:

```bash
mysqldump -u root -p classicmodels > classicmodels_backup.sql
```

Trước hết tạo database đích:

```sql
CREATE DATABASE IF NOT EXISTS classicmodels_restore_test;
```

Restore:

```bash
mysql -u root -p classicmodels_restore_test < classicmodels_backup.sql
```

Sau đó kiểm tra:

```bash
mysql -u root -p -e "SHOW TABLES FROM classicmodels_restore_test;"
```

### 16.2. Restore dump có `--databases`

Giả sử dump được tạo bằng:

```bash
mysqldump -u root -p --databases classicmodels > classicmodels_with_create_database.sql
```

Restore:

```bash
mysql -u root -p < classicmodels_with_create_database.sql
```

Vì file thường có `CREATE DATABASE`/`USE`, không cần chỉ schema đích trên command line.

> Trước restore, mở file để xác nhận database name và các statement có trong file. Không restore file chưa kiểm tra vào server production.

### 16.3. Restore schema-only

```bash
mysql -u root -p classicmodels_restore_test < classicmodels_schema.sql
```

Sau đó kiểm tra table:

```sql
SHOW TABLES FROM classicmodels_restore_test;
```

### 16.4. Restore data-only

Data-only dump chỉ restore được khi schema/table đích đã tồn tại và tương thích.

```bash
mysql -u root -p classicmodels_restore_test < classicmodels_data.sql
```

### 16.5. Restore file nén trên Linux/macOS

```bash
gunzip -c classicmodels_backup.sql.gz | mysql -u root -p
```

### Bài tập thực hành

**Bài 16.1.**

Tạo database `classicmodels_restore_test`.

**Bài 16.2.**

Restore file dump cơ bản của `classicmodels` vào `classicmodels_restore_test`.

**Bài 16.3.**

Dùng `SHOW TABLES FROM classicmodels_restore_test;` để kiểm tra table sau restore.

**Bài 16.4.**

Restore schema-only dump vào một database test rỗng.

**Bài 16.5.**

Giải thích vì sao data-only dump yêu cầu schema đích tồn tại trước.

---

## 17. Xác minh backup và restore

### 17.1. Kiểm tra object

Sau restore:

```sql
SHOW TABLES FROM classicmodels_restore_test;
```

Kiểm tra cấu trúc:

```sql
SHOW CREATE TABLE classicmodels_restore_test.orders;
```

Kiểm tra cột:

```sql
SHOW COLUMNS FROM classicmodels_restore_test.orders;
```

### 17.2. Kiểm tra số dòng mẫu

Ví dụ:

```sql
SELECT COUNT(*) AS totalCustomers
FROM classicmodels_restore_test.customers;
```

```sql
SELECT COUNT(*) AS totalOrders
FROM classicmodels_restore_test.orders;
```

```sql
SELECT COUNT(*) AS totalOrderDetails
FROM classicmodels_restore_test.orderdetails;
```

So sánh với database nguồn:

```sql
SELECT COUNT(*) AS totalCustomers
FROM classicmodels.customers;
```

### 17.3. Kiểm tra dữ liệu mẫu

```sql
SELECT customerNumber, customerName, country
FROM classicmodels_restore_test.customers
ORDER BY customerNumber
LIMIT 10;
```

```sql
SELECT orderNumber, orderDate, status, customerNumber
FROM classicmodels_restore_test.orders
ORDER BY orderNumber
LIMIT 10;
```

### 17.4. Kiểm tra routine/event/trigger nếu có

```sql
SHOW PROCEDURE STATUS
WHERE Db = 'classicmodels_restore_test';
```

```sql
SHOW FUNCTION STATUS
WHERE Db = 'classicmodels_restore_test';
```

```sql
SHOW TRIGGERS FROM classicmodels_restore_test;
```

```sql
SHOW EVENTS FROM classicmodels_restore_test;
```

### 17.5. Không chỉ dựa vào file size

File `.sql` có dung lượng lớn không đảm bảo:

- Nội dung đúng.
- Có đủ object.
- Không bị lỗi giữa chừng.
- Restore được.
- Dữ liệu khớp snapshot mong muốn.

Restore test và kiểm tra có chủ đích là bước quan trọng.

### Bài tập thực hành

**Bài 17.1.**

So sánh số dòng của `customers` giữa source và restore test.

**Bài 17.2.**

So sánh số dòng của `orders` giữa source và restore test.

**Bài 17.3.**

Dùng `SHOW CREATE TABLE` để so sánh DDL của `orders` ở source và restore test.

**Bài 17.4.**

Kiểm tra trigger, routine hoặc event trong restore test nếu source có các object này.

**Bài 17.5.**

Nêu ba kiểm tra cần thực hiện ngoài việc chỉ xem file dump có tồn tại.

---

## 18. Quyền cần thiết và các lưu ý thực tế

### 18.1. Quyền backup phụ thuộc object và option

Để dump table dữ liệu, user backup thường cần quyền đọc phù hợp như `SELECT`.

Tùy object và option, có thể cần thêm quyền, ví dụ:

| Nội dung dump | Quyền có thể cần |
|---|---|
| Table data | `SELECT` |
| View definition | `SHOW VIEW` |
| Trigger | `TRIGGER` |
| Lock table nếu không dùng snapshot phù hợp | `LOCK TABLES` |
| Routine/event hoặc metadata đặc biệt | Phụ thuộc server version, object và option |

Không nên cấp quyền quản trị toàn cục chỉ để backup nếu có thể tạo một backup account với quyền tối thiểu phù hợp.

### 18.2. Account backup riêng

Một cách thiết kế tốt là tạo account chuyên backup, ví dụ:

```text
backup_service@localhost
```

Account này:

- Chỉ có các quyền cần để dump phạm vi dữ liệu được chỉ định.
- Không có quyền thay đổi dữ liệu ứng dụng.
- Có password/secret được quản lý riêng.
- Được audit và xoay vòng credential theo policy.

### 18.3. Dump system databases cần thận trọng

Không dùng tùy tiện:

```bash
mysqldump -u root -p --all-databases > all_databases.sql
```

Vì dump này có thể bao gồm các schema hệ thống, metadata account và những thành phần không phù hợp để restore sang môi trường khác.

Chỉ dùng backup toàn server theo runbook đã được phê duyệt.

### 18.4. Backup không thay thế binlog/PITR

`mysqldump` là logical backup. Trong hệ thống cần phục hồi đến một thời điểm cụ thể (*point-in-time recovery*), thường còn cần binary logs và chiến lược backup/recovery đầy đủ.

Đây là chủ đề quản trị nâng cao; không tự giả định một dump hằng ngày là đủ cho mọi yêu cầu RPO/RTO.

### Bài tập thực hành

**Bài 18.1.**

Nêu quyền tối thiểu thường cần để dump dữ liệu table.

**Bài 18.2.**

Nêu một lý do backup account nên tách khỏi application account.

**Bài 18.3.**

Giải thích vì sao `--all-databases` cần thận trọng.

**Bài 18.4.**

Nêu khác biệt khái quát giữa logical backup bằng `mysqldump` và point-in-time recovery.

**Bài 18.5.**

Đề xuất ba đặc điểm của một backup account theo least privilege.

---

## 19. Một số lỗi thường gặp

### Lỗi 1. Không chọn database trước khi `SHOW TABLES`

Sai nếu không có database hiện tại:

```sql
SHOW TABLES;
```

Có thể báo lỗi:

```text
No database selected
```

Khắc phục:

```sql
USE classicmodels;

SHOW TABLES;
```

Hoặc:

```sql
SHOW TABLES FROM classicmodels;
```

---

### Lỗi 2. Nhầm `SHOW COLUMNS` với `SHOW CREATE TABLE`

`SHOW COLUMNS` tốt để xem nhanh danh sách cột.

```sql
SHOW COLUMNS FROM orders;
```

`SHOW CREATE TABLE` tốt để xem DDL đầy đủ:

```sql
SHOW CREATE TABLE orders;
```

Không dùng `SHOW COLUMNS` để suy luận đầy đủ thứ tự mọi cột trong composite index hoặc toàn bộ foreign-key definition.

---

### Lỗi 3. Không dùng `FULL` khi cần đọc query dài

```sql
SHOW PROCESSLIST;
```

có thể không hiển thị hết câu SQL trong `Info`.

Dùng:

```sql
SHOW FULL PROCESSLIST;
```

---

### Lỗi 4. Kill session không rõ nguồn gốc

Không chạy:

```sql
KILL 12345;
```

chỉ vì thấy session có `Time` cao.

Cần xác định owner, application, transaction, lock và quy trình vận hành trước.

---

### Lỗi 5. Dùng password trên command line

Không nên:

```bash
mysqldump -u root -pMyPassword classicmodels > backup.sql
```

Nên:

```bash
mysqldump -u root -p classicmodels > backup.sql
```

---

### Lỗi 6. Restore nhầm database

Trước restore:

1. Kiểm tra database đích.
2. Kiểm tra file dump.
3. Restore vào test database trước.
4. Chỉ restore production theo runbook được phê duyệt.

---

### Lỗi 7. Quên `--routines` hoặc `--events`

Nếu database có procedure, function hoặc event, dump chỉ table/data có thể làm mất các object này khi restore sang môi trường mới.

Dùng option phù hợp:

```bash
--routines --events --triggers
```

---

### Lỗi 8. Không kiểm tra restore

Tạo dump thành công không đồng nghĩa restore thành công.

Cần ít nhất:

- Restore vào database test.
- Kiểm tra table.
- Kiểm tra row count mẫu.
- Kiểm tra object quan trọng.
- Ghi nhận thời điểm và kết quả test.

### Bài tập thực hành

**Bài 19.1.**

Sửa câu `SHOW TABLES;` để hoạt động khi chưa chọn database.

**Bài 19.2.**

Viết lệnh phù hợp để xem DDL đầy đủ của `classicmodels.orderdetails`.

**Bài 19.3.**

Viết lệnh phù hợp để xem SQL dài trong process list.

**Bài 19.4.**

Sửa command `mysqldump` có password lộ trên command line.

**Bài 19.5.**

Nêu bốn bước kiểm tra an toàn trước khi restore file dump.

---

## 20. Bài tập tổng hợp

### Bài 20.1. Khám phá schema

Với database `classicmodels`:

1. Liệt kê database nhìn thấy được.
2. Kiểm tra `classicmodels` có tồn tại.
3. Liệt kê tất cả table trong `classicmodels`.
4. Chỉ liệt kê table bắt đầu bằng `order`.
5. Xem DDL đầy đủ của `orderdetails`.

---

### Bài 20.2. Phân tích cấu trúc bảng

Với `customers`, `orders`, `orderdetails`:

1. Dùng `SHOW COLUMNS` để xem cấu trúc từng table.
2. Xác định primary key hoặc các cột liên quan đến key.
3. Xác định các cột có thể chứa `NULL`.
4. Dùng `SHOW FULL COLUMNS` cho một table.
5. Dùng `SHOW CREATE TABLE` để xác minh foreign key/index.

---

### Bài 20.3. Quan sát session

1. Mở Session A và chạy `SELECT SLEEP(20);`.
2. Mở Session B và chạy `SHOW FULL PROCESSLIST;`.
3. Tìm session đang sleep/query.
4. Ghi lại `Id`, `Command`, `Time`, `Info`.
5. Sau khi query kết thúc, chạy lại process list và mô tả thay đổi.

---

### Bài 20.4. Backup và restore cơ bản

1. Dùng `mysqldump` backup `classicmodels`.
2. Tạo `classicmodels_restore_test`.
3. Restore dump vào database test.
4. So sánh số dòng của `customers`, `orders`, `orderdetails`.
5. Dùng `SHOW CREATE TABLE` để kiểm tra DDL table `orders`.

---

### Bài 20.5. Thiết kế backup command

Viết command backup `classicmodels` theo yêu cầu:

1. Có timestamp trong tên file.
2. Bao gồm schema và data.
3. Bao gồm routines, triggers và events.
4. Dùng snapshot option phù hợp cho InnoDB.
5. Không ghi password trực tiếp trong command.

Sau đó, viết các command/SQL để restore vào môi trường test và xác minh một phần kết quả.

---

## 21. Đáp án gợi ý cho một số bài tập

### Bài 4.2

```sql
SHOW DATABASES LIKE 'classic%';
```

### Bài 4.5

```sql
SELECT SCHEMA_NAME
FROM INFORMATION_SCHEMA.SCHEMATA
ORDER BY SCHEMA_NAME;
```

### Bài 5.3

```sql
SHOW TABLES FROM classicmodels
LIKE 'order%';
```

### Bài 5.5

```sql
SELECT TABLE_NAME,
       TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'classicmodels'
ORDER BY TABLE_NAME;
```

### Bài 7.4

```sql
SHOW COLUMNS FROM classicmodels.orders
WHERE `Key` = 'PRI';
```

### Bài 7.5

```sql
SELECT COLUMN_NAME,
       COLUMN_TYPE,
       IS_NULLABLE,
       COLUMN_KEY,
       COLUMN_DEFAULT,
       EXTRA,
       COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'classicmodels'
  AND TABLE_NAME = 'orderdetails'
ORDER BY ORDINAL_POSITION;
```

### Bài 9.3

```sql
SELECT CONNECTION_ID() AS currentConnectionId;
```

### Bài 10.5

```sql
SELECT *
FROM INFORMATION_SCHEMA.PROCESSLIST
WHERE COMMAND <> 'Sleep';
```

### Bài 13.1

```bash
mysqldump -u root -p classicmodels > classicmodels_backup.sql
```

### Bài 13.2

```bash
mysqldump -u root -p --databases classicmodels > classicmodels_with_create_database.sql
```

### Bài 13.3

```bash
mysqldump -u root -p classicmodels orders orderdetails > orders_and_details_backup.sql
```

### Bài 14.1

```bash
mysqldump -u root -p --no-data classicmodels > classicmodels_schema.sql
```

### Bài 14.2

```bash
mysqldump -u root -p --no-create-info classicmodels > classicmodels_data.sql
```

### Bài 15.1

```bash
mysqldump -u root -p \
  --single-transaction \
  --routines \
  --events \
  --triggers \
  --databases classicmodels \
  > classicmodels_full_backup.sql
```

### Bài 16.2

```bash
mysql -u root -p classicmodels_restore_test < classicmodels_backup.sql
```

### Bài 17.1 và Bài 17.2

```sql
SELECT COUNT(*) AS totalCustomers
FROM classicmodels.customers;

SELECT COUNT(*) AS totalCustomers
FROM classicmodels_restore_test.customers;
```

```sql
SELECT COUNT(*) AS totalOrders
FROM classicmodels.orders;

SELECT COUNT(*) AS totalOrders
FROM classicmodels_restore_test.orders;
```

### Bài 20.5 — Linux/macOS

```bash
stamp=$(date +%Y%m%d_%H%M%S)

mysqldump -u root -p \
  --single-transaction \
  --routines \
  --events \
  --triggers \
  classicmodels \
  > "classicmodels_${stamp}.sql"
```

Restore test:

```sql
CREATE DATABASE IF NOT EXISTS classicmodels_restore_test;
```

```bash
mysql -u root -p classicmodels_restore_test \
  < "classicmodels_YYYYMMDD_HHMMSS.sql"
```

Verification:

```sql
SELECT COUNT(*) AS totalCustomers
FROM classicmodels_restore_test.customers;

SHOW CREATE TABLE classicmodels_restore_test.orders;
```

### Bài 20.5 — Windows PowerShell

```powershell
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"

mysqldump -u root -p `
  --single-transaction `
  --routines `
  --events `
  --triggers `
  classicmodels `
  > "classicmodels_$stamp.sql"
```

Restore test:

```powershell
mysql -u root -p classicmodels_restore_test `
  < "classicmodels_YYYYMMDD_HHMMSS.sql"
```

---

## 22. Script dọn dẹp sau lab

Chỉ xóa database test, không xóa source database:

```sql
DROP DATABASE IF EXISTS classicmodels_restore_test;
```

Nếu đã tạo các file dump chỉ để thực hành, có thể xóa file theo quy định lab sau khi đã xác nhận không cần giữ lại.

Ví dụ PowerShell:

```powershell
Remove-Item .\classicmodels_backup.sql
```

Ví dụ Linux/macOS:

```bash
rm classicmodels_backup.sql
```

> Chỉ chạy lệnh xóa file sau khi kiểm tra đúng folder và đúng filename.

---

## 23. Tóm tắt

Các kiến thức chính:

- `SHOW DATABASES` liệt kê database mà account có thể nhìn thấy.
- `SHOW TABLES` liệt kê table trong schema hiện tại hoặc schema được chỉ rõ.
- `SHOW FULL TABLES` giúp phân biệt `BASE TABLE` và `VIEW`.
- `SHOW COLUMNS`/`DESC` hiển thị nhanh cấu trúc cột; `SHOW FULL COLUMNS` cung cấp thêm collation, privileges và comment.
- `SHOW CREATE TABLE` hiển thị DDL chi tiết, hữu ích để kiểm tra key, index, constraint và options.
- `SHOW PROCESSLIST` hiển thị session/thread; `SHOW FULL PROCESSLIST` giúp đọc đầy đủ hơn SQL ở cột `Info`.
- Privilege `PROCESS` ảnh hưởng đến khả năng xem thread của user khác.
- `mysqldump` tạo logical backup ở dạng SQL text.
- `--no-data` tạo schema-only dump; `--no-create-info` tạo data-only dump.
- `--routines`, `--events`, `--triggers` cần được cân nhắc khi database có các object này.
- `--single-transaction` thường phù hợp cho InnoDB snapshot nhưng có giới hạn với non-transactional table và hoạt động DDL đồng thời.
- Luôn restore vào môi trường test và kiểm tra object/data trước khi dựa vào backup cho recovery.
- Không ghi password trực tiếp trong command line hoặc lưu file dump ở nơi không được bảo vệ.

---

## 24. Từ khóa chính

- SHOW DATABASES
- SHOW TABLES
- SHOW FULL TABLES
- SHOW TABLE STATUS
- SHOW COLUMNS
- SHOW FULL COLUMNS
- DESCRIBE
- DESC
- SHOW CREATE TABLE
- SHOW PROCESSLIST
- SHOW FULL PROCESSLIST
- PROCESS Privilege
- INFORMATION_SCHEMA
- Performance Schema
- sys Schema
- mysqldump
- Logical Backup
- Restore
- Schema-only Backup
- Data-only Backup
- --no-data
- --no-create-info
- --databases
- --single-transaction
- --routines
- --events
- --triggers
- classicmodels
