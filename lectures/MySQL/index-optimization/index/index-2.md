---
title: "Phần 2 (Nâng cao): Các loại Index chuyên sâu, InnoDB Internals & Index Hints"
author: "Tên giảng viên"
duration: "240m"
difficulty: "Intermediate–Advanced"
prerequisites:
  - "Đã hoàn thành Phần 1 (Cơ bản): CREATE/DROP/SHOW INDEX, Composite Index và EXPLAIN cơ bản trên classicmodels"
  - "Khuyến nghị MySQL 8.0+ / 8.4 (hỗ trợ invisible, descending, functional index và optimizer hints)"
summary: "Phần Nâng cao hợp nhất Index Types & Index Hints trên classicmodels: InnoDB Clustered Index internals, Unique, Prefix, Invisible, Descending, Functional Index & Query Rewrite, Cardinality sâu, EXPLAIN ANALYZE, USE INDEX, FORCE INDEX, IGNORE INDEX, phạm vi FOR JOIN/ORDER BY/GROUP BY và Optimizer Hints /*+ INDEX(...) */."
---

# Phần 2 (Nâng cao): Các loại Index chuyên sâu, InnoDB Internals & Index Hints

> **Lộ trình 2 phần:** Tiếp nối [**Phần 1 (Cơ bản)**](index-1.md), phần này đi sâu vào kiến trúc lưu trữ InnoDB, các loại index chuyên sâu (`UNIQUE`, `Prefix`, `INVISIBLE`, `DESC`, Functional Index), phân tích `Cardinality`/`EXPLAIN ANALYZE` và kiểm soát Query Optimizer bằng Index Hints (`USE`/`FORCE`/`IGNORE INDEX` và Optimizer Hints MySQL 8.0+). Toàn bộ thực hành chạy trên `classicmodels`.

## Link tham khảo

- [MySQL Tutorial — UNIQUE / Prefix / Invisible / Descending / Clustered / Cardinality / Functional Index](https://www.mysqltutorial.org/mysql-index/mysql-unique-index/)
- [MySQL Tutorial — USE INDEX & FORCE INDEX](https://www.mysqltutorial.org/mysql-index/mysql-use-index/)
- [MySQL 8.4 Reference Manual — Clustered and Secondary Indexes (InnoDB)](https://dev.mysql.com/doc/refman/8.4/en/innodb-index-types.html)
- [MySQL 8.4 Reference Manual — Invisible, Descending & Functional Key Parts](https://dev.mysql.com/doc/refman/8.4/en/invisible-indexes.html)
- [MySQL 8.4 Reference Manual — Index Hints & Optimizer Hints](https://dev.mysql.com/doc/refman/8.4/en/index-hints.html)

> **Lưu ý phiên bản & Hints:** Các tính năng `INVISIBLE`, `DESC` key part, Functional Index (`8.0.13+`) và `EXPLAIN ANALYZE` (`8.0.18+`) phụ thuộc phiên bản MySQL (`SELECT VERSION();`). Đồng thời trong MySQL 8.4+, comment-based Optimizer Hints (`/*+ INDEX(...) */`, `JOIN_INDEX`, `ORDER_INDEX`, `GROUP_INDEX`) được khuyến nghị thay thế dần các legacy hints (`USE`/`FORCE`/`IGNORE INDEX`).

## 1. Mục tiêu học tập

Sau khi hoàn thành Phần 2 (Nâng cao), người học có thể:

1. Hiểu sâu kiến trúc **Clustered Index vs Secondary Index** trong InnoDB và lý do chọn `PRIMARY KEY` ngắn gọn, ổn định.
2. Phân biệt và sử dụng đúng **Unique Index**, **Prefix Index**, **Invisible Index**, **Descending Index** và **Functional Index** (cũng như ưu tiên **Query Rewrite**).
3. Đánh giá **Cardinality / Selectivity** (`COUNT(DISTINCT ...)` vs `SHOW INDEX` / `ANALYZE TABLE`), tránh bẫy `SELECT *` và dùng `EXPLAIN ANALYZE` an toàn.
4. Kiểm soát optimizer có chừng mực bằng `USE INDEX`, `FORCE INDEX`, `IGNORE INDEX` kèm scope `FOR JOIN`, `FOR ORDER BY`, `FOR GROUP BY`.
5. Hiểu chuyển dịch sang **Optimizer Hints hiện đại** (`/*+ INDEX(...) */`) và áp dụng quy trình cải thiện gốc rễ trước khi dùng hint.

---

## 2. Clustered Index Internals trong InnoDB

Mỗi bảng InnoDB có **duy nhất một Clustered Index** chứa dữ liệu dòng theo thứ tự ưu tiên:

1. `PRIMARY KEY` được khai báo tường minh (`customers.customerNumber`, `orders.orderNumber`, `products.productCode`).
2. `UNIQUE INDEX` đầu tiên có tất cả cột `NOT NULL`.
3. Hidden clustered index 6-byte do InnoDB tự sinh (`GEN_CLUST_INDEX`).

**Hệ quả thiết kế quan trọng:** Mọi bản ghi của **Secondary Index** trong InnoDB đều lưu kèm giá trị **Primary Key** để tra ngược dữ liệu gốc. Do đó, PK dài (như `products.productCode VARCHAR(15)` so với `INT 4 byte`) khiến tất cả secondary indexes trên bảng đó phình to theo. Với bảng giao dịch lớn, hãy dùng PK rõ ràng, ngắn gọn và ổn định. (Lưu ý: bảng chỉ có 1 Clustered Index nên không tự động tối ưu mọi thứ tự `ORDER BY`.)

### Bài tập thực hành

**Bài 2.1.** Xác định Clustered Index của `customers` và nêu thứ tự chọn Clustered Index của InnoDB khi thiếu Primary Key.

**Bài 2.2.** Giải thích vì sao Primary Key dài làm phình kích thước secondary indexes và đề xuất thiết kế PK cho bảng giao dịch lớn.

---

## 3. Unique Indexes

Unique index bảo vệ tính duy nhất (distinctness) cho business key ở tầng lưu trữ. Trong `classicmodels.customers`, 122 khách hàng có `customerName` hoàn toàn phân biệt:

```sql
CREATE UNIQUE INDEX uq_customers_name ON customers (customerName);
SHOW INDEX FROM customers WHERE Key_name = 'uq_customers_name'; -- Non_unique = 0
```

Chèn thêm dòng trùng `'Atelier graphique'` sẽ bị từ chối với lỗi `Duplicate entry`. Ngược lại, không đặt `UNIQUE` cho cột có dữ liệu trùng hoặc chỉ nhằm mục đích tăng tốc: ví dụ thử tạo `UNIQUE INDEX` trên `employees(email)` trong `classicmodels` sẽ lỗi vì nhân viên `1076` (Jeff Firrelli) và `1188` (Julie Firrelli) đang dùng chung `jfirrelli@classicmodelcars.com`.

| Đặc điểm | PRIMARY KEY | UNIQUE index |
|---|---|---|
| Số lượng trên bảng | Tối đa 1 | Có thể nhiều |
| Giá trị `NULL` | Không cho phép | Thường cho phép nhiều `NULL` nếu cột nullable |
| Vai trò | Clustered index định danh dòng | Bảo đảm duy nhất business key |

### Bài tập thực hành

**Bài 3.1.** Tạo `uq_customers_name` trên `customers(customerName)` và kiểm tra `Non_unique` bằng `SHOW INDEX`.

**Bài 3.2.** Phân biệt `PRIMARY KEY` với `UNIQUE`, nêu tác dụng khi chèn trùng `'Atelier graphique'` và vì sao `employees.email` không thể tạo UNIQUE trực tiếp trên `classicmodels`.

---

## 4. Prefix Indexes

Prefix index chỉ lưu N ký tự đầu của chuỗi (bắt buộc với `TEXT`/`BLOB` như `productDescription`, `comments`; cần tính giới hạn byte với `utf8mb4`):

```sql
CREATE INDEX idx_products_name_prefix ON products (productName(12));
SHOW INDEX FROM products WHERE Key_name = 'idx_products_name_prefix'; -- Sub_part = 12
```

Đo độ phân biệt prefix trên `classicmodels.products` (110 dòng):

```sql
SELECT COUNT(*) AS totalRows,
       COUNT(DISTINCT LEFT(productName, 4)) AS distinctPrefix4,
       COUNT(DISTINCT LEFT(productName, 8)) AS distinctPrefix8,
       COUNT(DISTINCT LEFT(productName, 12)) AS distinctPrefix12
FROM products;
-- Kết quả: 64 / 102 / 105 giá trị phân biệt trên 110 sản phẩm.
```

- **Hỗ trợ tốt:** `SELECT productCode, productName FROM products WHERE productName LIKE '1969%';`.
- **Hạn chế:** Không dùng được cho leading wildcard `LIKE '%Ford%'` (cần Full-Text Search) và **không dùng `UNIQUE` trên prefix** vì chỉ kiểm tra N ký tự đầu, không bảo đảm toàn chuỗi duy nhất.

### Bài tập thực hành

**Bài 4.1.** Tạo `idx_products_name_prefix` trên `products(productName(12))` và kiểm tra `Sub_part` bằng `SHOW INDEX`.

**Bài 4.2.** Chạy `EXPLAIN` kiểm tra tìm kiếm `LIKE '1969%'` với prefix index và giải thích cảnh báo vì sao không nên dùng `UNIQUE prefix`.

---

## 5. Invisible & Descending Indexes (MySQL 8.0+)

### 5.1. Invisible Indexes

Cho phép ẩn index khỏi optimizer để kiểm thử ảnh hưởng trước khi quyết định `DROP INDEX`, mà vẫn giữ phương án khôi phục tức thì (`VISIBLE`):

```sql
CREATE INDEX idx_customers_country ON customers (country);
ALTER TABLE customers ALTER INDEX idx_customers_country INVISIBLE;

SELECT INDEX_NAME, IS_VISIBLE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'classicmodels' AND TABLE_NAME = 'customers';
```

**Giới hạn:** `PRIMARY KEY` không thể `INVISIBLE`; index ẩn vẫn chiếm storage và **vẫn phải cập nhật khi DML (`INSERT`/`UPDATE`/`DELETE`)**; unique invisible index vẫn kiểm tra trùng lặp.

### 5.2. Descending Indexes

Lưu key part giảm dần trực tiếp trong B-tree — giá trị nhất với **mixed sort order** (`ASC` kết hợp `DESC`):

```sql
CREATE INDEX idx_orders_status_date_desc
ON orders (status ASC, orderDate DESC);

EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders
WHERE status = 'Shipped'
ORDER BY orderDate DESC;
```

Không cần tạo `DESC` index cho mọi `ORDER BY col DESC` đơn lẻ vì InnoDB hỗ trợ backward scan; chỉ dùng khi có mixed order (`ORDER BY status ASC, orderDate DESC`) hoặc benchmark xác nhận cần thiết.

### Bài tập thực hành

**Bài 5.1.** Chuyển `idx_customers_country` sang `INVISIBLE`, kiểm tra `IS_VISIBLE` trong `INFORMATION_SCHEMA.STATISTICS`, và giải thích chi phí ghi DML của invisible index.

**Bài 5.2.** Tạo `idx_orders_status_date_desc (status ASC, orderDate DESC)`, chạy `EXPLAIN` cho `WHERE status = 'Shipped' ORDER BY orderDate DESC` và giải thích khi nào cần `DESC` key part.

---

## 6. Functional Indexes, Query Rewrite & Cardinality nâng cao

### 6.1. Query Rewrite trước Functional Index

Khi áp dụng hàm lên cột trong `WHERE` (`YEAR(orderDate) = 2004`), B-tree thường trên `orderDate` bị vô hiệu. **Ưu tiên viết lại thành điều kiện khoảng ngày half-open (sargable):**

```sql
CREATE INDEX idx_orders_date ON orders (orderDate);

-- Thay thế WHERE YEAR(orderDate) = 2004:
SELECT COUNT(*) FROM orders
WHERE orderDate >= '2004-01-01' AND orderDate < '2005-01-01';
```

Nếu không thể sửa câu truy vấn và MySQL >= 8.0.13, mới dùng **Functional Index** với **cặp ngoặc kép bắt buộc `((expr))`**:

```sql
CREATE INDEX idx_orders_year ON orders ((YEAR(orderDate)));
EXPLAIN SELECT COUNT(*) FROM orders WHERE YEAR(orderDate) = 2004;
```

*(Giới hạn: hiện thực qua hidden virtual generated column, không dùng làm `PRIMARY KEY`/FK, không hỗ trợ subquery hoặc prefix trực tiếp.)*

### 6.2. Cardinality sâu & Covering Index

- `SHOW INDEX` hiển thị `Cardinality` ước lượng — có thể sai khác so với `SELECT COUNT(DISTINCT customerNumber) FROM orders;` (98/326) tùy thời điểm lấy mẫu; high cardinality tự thân cũng không đủ nếu predicate không khớp leftmost-prefix.
- Tránh `SELECT *` khi không cần thiết: chỉ lấy các cột đã nằm trong index + PK giúp đạt **Covering Index (`Extra: Using index`)**, không phải tra ngược về Clustered Index.

### Bài tập thực hành

**Bài 6.1.** Tạo `idx_orders_date`, chạy `EXPLAIN` cho `WHERE YEAR(orderDate) = 2004`, viết lại `EXPLAIN` với range `>= '2004-01-01' AND < '2005-01-01'`, rồi tạo `idx_orders_year` bằng `((YEAR(orderDate)))`.

**Bài 6.2.** So sánh Cardinality ước lượng (`SHOW INDEX`) với `SELECT *` vs Covering Index, và giải thích vì sao ưu tiên range rewrite trước Functional Index.

---

## 7. Đọc `EXPLAIN ANALYZE` & Nguyên tắc trước khi dùng Hint

Trước khi thêm bất kỳ Index Hint nào, luôn theo trình tự: **Xem `EXPLAIN` → Kiểm tra `ANALYZE TABLE` & thiết kế index → Rewrite query → Benchmark với nhiều input khác nhau** (ví dụ `customerNumber = 103` có 3 đơn vs `141` có 26 đơn).

```sql
EXPLAIN ANALYZE
SELECT orderNumber, orderDate, status
FROM orders
WHERE customerNumber = 103 AND orderDate >= '2004-01-01'
ORDER BY orderDate;
```

> **Cẩn trọng:** Khác với `EXPLAIN` chỉ ước lượng, **`EXPLAIN ANALYZE` thực sự chạy câu truy vấn** để đo timing/actual rows — không dùng tùy tiện với query nặng hoặc DML trên production.

### Bài tập thực hành

**Bài 7.1.** Chạy `EXPLAIN ANALYZE` cho truy vấn `orders` (`customerNumber = 103 AND orderDate >= '2004-01-01'`) và giải thích vì sao cần cẩn trọng hơn `EXPLAIN` thường.

**Bài 7.2.** Nêu quy trình chuẩn trước khi nghĩ đến `FORCE INDEX` và vì sao cần benchmark với nhiều input values (data skew).

---

## 8. `USE INDEX`, `FORCE INDEX`, `IGNORE INDEX` & Scope

### 8.1. `USE INDEX` — Giới hạn tập ứng viên

Luôn truyền **tên index** (`PRIMARY`, `idx_orders_customer`, `idx_orders_customer_date`), **không truyền tên cột**:

```sql
EXPLAIN SELECT orderNumber, orderDate, status
FROM orders USE INDEX (idx_orders_customer_date)
WHERE customerNumber = 103 AND orderDate >= '2004-01-01';

-- Không dùng index nào để tra row (chỉ dùng cho thử nghiệm):
EXPLAIN SELECT * FROM orders USE INDEX () WHERE customerNumber = 103;
```

### 8.2. `FORCE INDEX` — Ép cost table scan rất cao

```sql
EXPLAIN SELECT orderNumber, orderDate, status
FROM orders FORCE INDEX (idx_orders_customer_date)
WHERE customerNumber = 103 AND orderDate >= '2004-01-01';
```

- Khác với `USE INDEX` (vẫn cho phép table scan nếu rẻ hơn), `FORCE INDEX` coi table scan rất đắt và chỉ scan khi index không áp dụng được.
- **Rủi ro:** Đóng băng kế hoạch có thể trở nên tệ khi dữ liệu thay đổi, đồng thời `FORCE INDEX` không sửa được index thiết kế sai (vd dùng `(status, orderDate)` cho query lọc `customerNumber`).

### 8.3. Scope: `FOR JOIN`, `FOR ORDER BY`, `FOR GROUP BY` & `IGNORE INDEX`

```sql
-- FOR JOIN áp dụng cho pha tìm dòng/lookup (không bắt buộc câu SQL phải có từ khóa JOIN):
EXPLAIN SELECT orderNumber, orderDate FROM orders USE INDEX FOR JOIN (idx_orders_customer_date) WHERE customerNumber = 103 AND orderDate >= '2004-01-01';

-- Giới hạn riêng cho sắp xếp / gom nhóm:
EXPLAIN SELECT orderNumber, status, orderDate FROM orders USE INDEX FOR ORDER BY (idx_orders_status_date) ORDER BY status, orderDate;
EXPLAIN SELECT status, COUNT(*) AS totalOrders FROM orders USE INDEX FOR GROUP BY (idx_orders_status) GROUP BY status;

-- Loại bỏ một index khỏi cân nhắc để kiểm thử giả thuyết:
EXPLAIN SELECT orderNumber, orderDate FROM orders IGNORE INDEX (idx_orders_customer_date) WHERE customerNumber = 103 AND orderDate >= '2004-01-01';
```

> **Quy tắc cú pháp:** Không được trộn `USE INDEX` và `FORCE INDEX` trên cùng một bảng và cùng một scope (ví dụ đều `FOR JOIN`).

### Bài tập thực hành

**Bài 8.1.** Viết `EXPLAIN` với `USE INDEX (idx_orders_customer_date)`, sửa lỗi `USE INDEX(customerNumber)` thành `idx_orders_customer`, và thử `USE INDEX ()`.

**Bài 8.2.** Viết `EXPLAIN` với `FORCE INDEX (idx_orders_customer_date)` và so sánh 3 plan: không hint, `USE INDEX`, `FORCE INDEX`.

**Bài 8.3.** Thực hành `USE INDEX FOR JOIN`, `FOR ORDER BY`, `FOR GROUP BY`, `IGNORE INDEX (idx_orders_customer_date)` và sửa lỗi trộn `USE` + `FORCE` cùng scope `FOR JOIN`.

---

## 9. Optimizer Hints hiện đại (MySQL 8.0/8.4+) & Checklist tối ưu

MySQL 8.x/8.4 khuyến nghị dùng comment-based optimizer hints thay cho legacy index hints (giảm technical debt khi nâng cấp phiên bản):

```sql
EXPLAIN
SELECT /*+ INDEX(o idx_orders_customer_date) */
       o.orderNumber, o.orderDate
FROM orders AS o
WHERE o.customerNumber = 103 AND o.orderDate >= '2004-01-01';
```

Các optimizer hint liên quan gồm: `INDEX`, `JOIN_INDEX`, `ORDER_INDEX`, `GROUP_INDEX` và nhóm loại trừ `NO_INDEX`, `NO_JOIN_INDEX`, `NO_ORDER_INDEX`, `NO_GROUP_INDEX`.

| Nhu cầu nâng cao | Phương án ưu tiên |
|---|---|
| Business key bắt buộc distinct | `UNIQUE INDEX` (sau khi chắc chắn dữ liệu sạch) |
| Chuỗi dài chỉ lọc tiền tố / `TEXT` | `Prefix Index` (`col(N)`) |
| Kiểm thử bỏ index trước khi `DROP` | `ALTER INDEX ... INVISIBLE` |
| `ORDER BY` ngược chiều (`ASC, DESC`) | Descending composite index |
| Điều kiện bọc hàm (`YEAR(orderDate)`) | Query rewrite range trước; sau đó mới xét Functional Index `((expr))` |
| Ép/giới hạn index tạm thời khi optimizer chọn sai | Benchmark với nhiều input, ưu tiên `/*+ INDEX(...) */` theo đúng docs version |

### Bài tập thực hành

**Bài 9.1.** Viết `EXPLAIN` dùng comment optimizer hint `/*+ INDEX(o idx_orders_customer_date) */` trên `orders AS o`.

**Bài 9.2.** Giải thích vì sao cần đọc docs đúng MySQL version, rủi ro technical debt của legacy hint và điều kiện để giữ hint trong code.

---

## 10. Tóm tắt & Từ khóa chính

- **InnoDB & Kiến trúc:** 1 Clustered Index (`PRIMARY KEY`); secondary index mang theo PK; giữ PK ngắn gọn cho bảng giao dịch lớn.
- **Loại Index chuyên sâu:** `UNIQUE` (integrity), `Prefix` (tiết kiệm kích thước), `INVISIBLE` (rollback an toàn khi test drop), `DESC` (mixed sort), `Functional ((expr))` (khi không rewrite được).
- **Hints & Kỷ luật tối ưu:** `USE`/`FORCE`/`IGNORE INDEX` và `/*+ INDEX(...) */` là công cụ sau cùng sau khi đã rà soát query rewrite, composite index, `ANALYZE TABLE`, `EXPLAIN ANALYZE` và benchmark đa dữ liệu.
- **Từ khóa:** Clustered Index, `GEN_CLUST_INDEX`, `UNIQUE`, Prefix Index, `INVISIBLE`, Descending Index, Functional Index, Query Rewrite, Covering Index, `EXPLAIN ANALYZE`, `USE INDEX`, `FORCE INDEX`, `IGNORE INDEX`, `FOR JOIN / ORDER BY / GROUP BY`, `/*+ INDEX(...) */`.
