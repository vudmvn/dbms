---
title: "Phần 1 (Cơ bản): Tạo, Quản lý, Metadata, Composite Index & EXPLAIN"
author: "Tên giảng viên"
duration: "150m"
difficulty: "Basic–Intermediate"
prerequisites:
  - "Đã biết SELECT, WHERE, ORDER BY, JOIN và CREATE TABLE"
  - "Đã cài đặt cơ sở dữ liệu mẫu classicmodels"
summary: "Phần Cơ bản về Index trong MySQL trên cơ sở dữ liệu classicmodels: khái niệm, trade-off đọc/ghi, index mặc định, CREATE/ALTER/DROP INDEX, SHOW INDEX, SHOW CREATE TABLE, INFORMATION_SCHEMA.STATISTICS, ANALYZE TABLE, Composite Index (Leftmost-Prefix) và đọc EXPLAIN cơ bản."
---

# Phần 1 (Cơ bản): Tạo, Quản lý, Metadata, Composite Index & `EXPLAIN`

> **Lộ trình 2 phần:** Tài liệu này trình bày **Phần Cơ bản** (tạo/xóa/kiểm tra index, composite index và đọc `EXPLAIN`). Các kỹ thuật chuyên sâu (`UNIQUE`, `Prefix`, `INVISIBLE`, `DESC`, InnoDB Clustered Index internals, Functional Index và `USE`/`FORCE`/`IGNORE INDEX` Hints) nằm ở [**Phần 2 (Nâng cao)**](index-2.md).

## Link tham khảo

- [MySQL Tutorial — MySQL Index](https://www.mysqltutorial.org/mysql-index/)
- [MySQL Tutorial — CREATE / DROP / SHOW INDEX](https://www.mysqltutorial.org/mysql-index/mysql-create-index/)
- [MySQL 8.4 Reference Manual — Optimization and Indexes](https://dev.mysql.com/doc/refman/8.4/en/optimization-indexes.html)
- [MySQL 8.4 Reference Manual — EXPLAIN Statement](https://dev.mysql.com/doc/refman/8.4/en/explain.html)

## 1. Mục tiêu học tập

Sau khi hoàn thành Phần 1 (Cơ bản), người học có thể:

1. Giải thích index là gì, phép toán B-tree hỗ trợ và trade-off giữa tốc độ đọc với chi phí ghi/lưu trữ.
2. Kiểm tra các `PRIMARY KEY` và foreign key index mặc định trên `classicmodels`.
3. Tạo và xóa secondary index bằng `CREATE INDEX`, `ALTER TABLE` và `DROP INDEX` đúng quy ước đặt tên.
4. Đọc metadata và thống kê index qua `SHOW INDEX`, `SHOW CREATE TABLE`, `INFORMATION_SCHEMA.STATISTICS` và `ANALYZE TABLE`.
5. Thiết kế composite index cơ bản theo **Leftmost-Prefix Principle** và đọc các cột chính của `EXPLAIN`.

---

## 2. Index là gì & Trade-off đọc / ghi

### 2.1. Khái niệm và phép toán B-tree hỗ trợ

Index là cấu trúc dữ liệu giúp MySQL tìm row nhanh hơn cho một số điều kiện lọc, kết nối hoặc sắp xếp thay vì quét tuần tự toàn bảng:

```sql
SELECT customerNumber, contactFirstName, contactLastName, creditLimit
FROM customers
WHERE country = 'USA';
```

B-tree index hỗ trợ hiệu quả các phép toán `=`, `>`, `>=`, `<`, `<=`, `BETWEEN`, `IN (...)` và mẫu `LIKE 'prefix%'` (không có wildcard `%` ở đầu chuỗi).

### 2.2. Primary Key vs Secondary Index & Chi phí của Index

- **Primary Key:** Định danh duy nhất mỗi dòng (InnoDB tổ chức dữ liệu vật lý của bảng theo Primary Key — Clustered Index).
- **Secondary Index:** Cấu trúc phụ bổ sung lối truy cập theo cột khác (ví dụ `country` hay `(country, creditLimit)`).

Index không tự động làm mọi query nhanh hơn và đi kèm chi phí:

| Thành phần | Tác động |
|---|---|
| **Storage** | Mỗi index chiếm thêm dung lượng đĩa và bộ nhớ đệm |
| **INSERT / UPDATE / DELETE** | Mọi thao tác thay đổi dữ liệu khóa đều phải cập nhật các index liên quan |
| **Optimizer complexity** | Quá nhiều index làm quá trình ước lượng plan phức tạp hơn |
| **DDL impact** | Tạo/xóa index trên bảng lớn tốn thời gian và tài nguyên hệ thống |

### Bài tập thực hành

**Bài 2.1.** Giải thích index là gì và nêu các phép toán B-tree hỗ trợ (vì sao `LIKE '%mit'` không tận dụng tra tiền tố).

**Bài 2.2.** Nêu hai lợi ích và hai chi phí khi thêm secondary index; giải thích vì sao không nên tạo index cho mọi cột.

---

## 3. Cơ sở dữ liệu `classicmodels` & Index mặc định

### 3.1. Các bảng trọng tâm

Toàn bộ bài tập thực hành trực tiếp trên 8 bảng chuẩn của **`classicmodels`** (tổng 3.864 bản ghi):

| Bảng | Số dòng | Khóa chính (PK) | Khóa ngoại có index mặc định |
|---|---|---|---|
| `customers` | 122 | `customerNumber` | `salesRepEmployeeNumber` |
| `orders` | 326 | `orderNumber` | `customerNumber` |
| `products` | 110 | `productCode` | `productLine` |
| `orderdetails` | 2.996 | `(orderNumber, productCode)` | `productCode` |
| `payments` | 273 | `(customerNumber, checkNumber)` | — |

### 3.2. Kiểm tra index mặc định & Quy ước đặt tên

```sql
SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM products;
```

- **Quy ước tên:** Đặt `idx_<table_or_feature>_<cols>` cho index thường (vd `idx_customers_country`, `idx_orders_customer_date`) và `uq_<table>_<col>` cho unique index. Tránh tên mơ hồ như `idx1`, `temp`.
- **Lưu ý quy mô dữ liệu:** `classicmodels` nhỏ nên optimizer có thể chọn Full Table Scan dù index tồn tại. Mục tiêu của lab là nắm DDL, metadata và đọc `EXPLAIN` (để đo ms trên toàn bộ dữ liệu thực, dùng thêm trang Benchmark).
- **An toàn dữ liệu gốc:** Chỉ xóa các index tự tạo; giữ nguyên PK và FK index gốc của `classicmodels`.

### Bài tập thực hành

**Bài 3.1.** Dùng `SHOW INDEX` kiểm tra các index mặc định trên `customers`, `orders`, `products`.

**Bài 3.2.** Giải thích vì sao bảng nhỏ như `classicmodels` có thể vẫn chọn full scan dù đã có index, và nêu lợi ích của quy ước đặt tên `idx_`/`uq_`.

---

## 4. Tạo và Xóa Secondary Index

### 4.1. `CREATE INDEX` và `ALTER TABLE ... ADD INDEX`

```sql
CREATE INDEX idx_customers_country ON customers (country);
CREATE INDEX idx_orders_status ON orders (status);

-- Tương đương bằng ALTER TABLE:
ALTER TABLE products ADD INDEX idx_products_line (productLine);
```

### 4.2. `DROP INDEX` và `ALTER TABLE ... DROP INDEX`

```sql
DROP INDEX idx_customers_country ON customers;
-- MySQL 8.0+: DROP INDEX IF EXISTS idx_customers_country ON customers;

ALTER TABLE products DROP INDEX idx_products_line;
```

- **Không dùng `DROP INDEX` cho `PRIMARY KEY`:** Để xóa khóa chính phải dùng `ALTER TABLE table_name DROP PRIMARY KEY;` (chỉ làm khi thực sự cần và đã xử lý FK liên quan).
- **DDL và Transaction:** `CREATE INDEX` và `DROP INDEX` là DDL (có thể gây implicit commit), không thể giả định `ROLLBACK` lại như `INSERT`. Trước khi xóa trên hệ thống thật cần kiểm tra query plan phụ thuộc, FK constraints và chuẩn bị script khôi phục.

### Bài tập thực hành

**Bài 4.1.** Tạo `idx_customers_country` trên `customers(country)` và `idx_orders_status` trên `orders(status)`.

**Bài 4.2.** Dùng `ALTER TABLE` tạo `idx_products_line` trên `products(productLine)`.

**Bài 4.3.** Xóa `idx_customers_country` bằng `DROP INDEX` và xóa `idx_products_line` bằng `ALTER TABLE ... DROP INDEX`.

**Bài 4.4.** Nêu lệnh xóa `PRIMARY KEY`, đặc tính transaction (implicit commit) của DDL và các kiểm tra trước khi drop index.

---

## 5. Kiểm tra Metadata & `ANALYZE TABLE`

### 5.1. `SHOW INDEX` & `SHOW CREATE TABLE`

```sql
SHOW INDEX FROM orders;
SHOW INDEX FROM orders WHERE Key_name = 'idx_orders_customer_date';
SHOW CREATE TABLE orders;
```

*(Alias tương đương: `SHOW INDEXES`, `SHOW KEYS`.)*

| Cột output | Ý nghĩa |
|---|---|
| `Non_unique` | `0` nếu là `PRIMARY`/`UNIQUE`; `1` nếu cho phép trùng giá trị |
| `Key_name` | Tên index |
| `Seq_in_index` | Vị trí cột trong index (`1, 2, ...` với composite index) |
| `Column_name` | Tên cột key part |
| `Collation` | Chiều lưu khóa (`A` = tăng dần, `D` = giảm dần) |
| `Cardinality` | Ước lượng số giá trị phân biệt trong index |
| `Sub_part` / `Visible` | Độ dài prefix (nếu có) và trạng thái hiển thị với optimizer (`YES`/`NO`) |

### 5.2. `INFORMATION_SCHEMA.STATISTICS` & `ANALYZE TABLE`

```sql
SELECT INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME,
       COLLATION, CARDINALITY, SUB_PART, INDEX_TYPE, IS_VISIBLE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'classicmodels'
  AND TABLE_NAME = 'products'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;
```

Khi dữ liệu thay đổi nhiều khiến thống kê ước lượng cũ, dùng:

```sql
ANALYZE TABLE orders;
```

để làm mới `Cardinality` (trả về bảng `Table | Op | Msg_type | Msg_text` với `status = OK`).

### Bài tập thực hành

**Bài 5.1.** Dùng `SHOW INDEX FROM orders WHERE Key_name = 'idx_orders_customer_date';` và `SHOW CREATE TABLE orders;`.

**Bài 5.2.** Viết `SELECT` lấy 9 cột metadata của bảng `products` từ `INFORMATION_SCHEMA.STATISTICS`.

**Bài 5.3.** Chạy `ANALYZE TABLE orders;` và giải thích ý nghĩa các cột `Non_unique = 0`, `Seq_in_index = 2`, `Cardinality`.

---

## 6. Composite Index & Leftmost-Prefix Principle

```sql
CREATE INDEX idx_orders_customer_date ON orders (customerNumber, orderDate);
CREATE INDEX idx_customers_country_credit ON customers (country, creditLimit);
```

Với `idx_customers_country_credit (country, creditLimit)`:
- **Dùng được index:** `WHERE country = 'USA'` và `WHERE country = 'USA' AND creditLimit >= 50000`.
- **Không dùng trực tiếp:** `WHERE creditLimit >= 50000` (bỏ qua cột đầu tiên `country`).

Khi sắp xếp thứ tự cột `(a, b, c)`: đặt cột lọc bằng (`=`) trước cột lọc khoảng (`>=`, `BETWEEN`) hoặc sắp xếp (`ORDER BY`).

### Bài tập thực hành

**Bài 6.1.** Tạo `idx_orders_customer_date` trên `orders(customerNumber, orderDate)` và `idx_customers_country_credit` trên `customers(country, creditLimit)`.

**Bài 6.2.** Chạy `EXPLAIN` trên `customers` chỉ lọc `creditLimit >= 50000` (bỏ qua cột đầu `country`) để quan sát `key = NULL`, sau đó giải thích nguyên tắc Leftmost-Prefix của `INDEX(a, b)`.

---

## 7. Đọc `EXPLAIN` cơ bản & Thiết kế Index theo Workload

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders
WHERE customerNumber = 103
ORDER BY orderDate;
```

| Cột EXPLAIN | Cách đọc cơ bản |
|---|---|
| `possible_keys` | Danh sách index ứng viên |
| `key` | Index optimizer thực sự chọn (`NULL` nếu Full Table Scan `type = ALL`) |
| `key_len` | Độ dài phần khóa được dùng |
| `rows` & `filtered` | Số dòng ước lượng đọc và tỷ lệ lọc qua điều kiện |
| `Extra` | `Using where`, `Using index` (Covering), `Using filesort`... |

- **Không coi `key = NULL` luôn là lỗi:** Ví dụ `WHERE status = 'Shipped'` khớp 303/326 (~93%) dòng bảng `orders` nên table scan rẻ hơn lookup.
- **Thiết kế từ workload:** Tìm ứng viên từ `WHERE`, `JOIN`, `ORDER BY`, `GROUP BY`. Nếu đã có `(customerNumber, orderDate)`, index đơn `(customerNumber)` có thể dư cho lookup nhưng cần giữ nếu đang phục vụ khóa ngoại (`FK`) hoặc workload riêng.

### Bài tập thực hành

**Bài 7.1.** Chạy `EXPLAIN` cho `orders` lọc `customerNumber = 103 ORDER BY orderDate` và cho `WHERE status = 'Shipped'`.

**Bài 7.2.** Tạo `idx_orders_customer_date_desc` cho `customerNumber, orderDate DESC` và `idx_products_line_msrp_desc` cho `productLine, MSRP DESC`.

**Bài 7.3.** Chạy `EXPLAIN SELECT productCode, productName, MSRP FROM products WHERE productLine = 'Motorcycles' ORDER BY MSRP DESC;` và giải thích câu hỏi về `possible_keys`/`key`, `key = NULL` và index dư thừa.

---

## 8. Tóm tắt & Bước tiếp theo

- Index giúp tăng tốc truy vấn chọn lọc nhưng tốn storage và làm chậm thao tác ghi.
- Luôn kiểm tra metadata (`SHOW INDEX`, `INFORMATION_SCHEMA.STATISTICS`, `ANALYZE TABLE`) và kế hoạch `EXPLAIN`, đặt thứ tự composite index theo **Leftmost-Prefix**.
- Tiếp tục sang [**Phần 2 (Nâng cao): Các loại Index chuyên sâu, InnoDB Internals & Index Hints**](index-2.md) để học `UNIQUE`, `Prefix`, `INVISIBLE`, `DESC`, Functional Index, `EXPLAIN ANALYZE` và `USE`/`FORCE`/`IGNORE INDEX`.
