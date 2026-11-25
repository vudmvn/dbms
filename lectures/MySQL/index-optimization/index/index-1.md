---
title: "Tutorial 1: Tạo và quản lý Index trong MySQL"
author: "Tên giảng viên"
duration: "150m"
difficulty: "Intermediate"
prerequisites:
  - "Đã biết SELECT, WHERE, ORDER BY, JOIN và CREATE TABLE"
  - "Đã biết dùng SHOW CREATE TABLE và SHOW INDEX"
  - "Đã cài đặt cơ sở dữ liệu mẫu classicmodels và có quyền CREATE, ALTER, INDEX, DROP"
summary: "Giải thích index là gì; thực hành tạo, liệt kê, phân tích và xóa single-column hoặc composite index trực tiếp trên cơ sở dữ liệu mẫu classicmodels."
---

# Tutorial 1: Tạo và quản lý Index trong MySQL

## Link tham khảo

- [MySQL Tutorial — MySQL Index](https://www.mysqltutorial.org/mysql-index/)
- [MySQL Tutorial — CREATE INDEX](https://www.mysqltutorial.org/mysql-index/mysql-create-index/)
- [MySQL Tutorial — DROP INDEX](https://www.mysqltutorial.org/mysql-index/mysql-drop-index/)
- [MySQL Tutorial — SHOW INDEXES](https://www.mysqltutorial.org/mysql-index/mysql-show-indexes/)
- [MySQL 8.4 Reference Manual — Optimization and Indexes](https://dev.mysql.com/doc/refman/8.4/en/optimization-indexes.html)
- [MySQL 8.4 Reference Manual — Column Indexes](https://dev.mysql.com/doc/refman/8.4/en/column-indexes.html)
- [MySQL 8.4 Reference Manual — CREATE INDEX](https://dev.mysql.com/doc/refman/8.4/en/create-index.html)
- [MySQL 8.4 Reference Manual — DROP INDEX](https://dev.mysql.com/doc/refman/8.4/en/drop-index.html)
- [MySQL 8.4 Reference Manual — SHOW INDEX](https://dev.mysql.com/doc/refman/8.4/en/show-index.html)

> **Phạm vi lab:** Index là database object ảnh hưởng đến storage, tốc độ ghi và execution plan. Mọi bài thực hành trong chuyên đề này thực hiện trực tiếp trên cơ sở dữ liệu mẫu `classicmodels` (môi trường học tập/test) và nên dọn dẹp các index tạo thêm sau khi hoàn thành. Không thử trực tiếp trên bảng production hay bảng dùng chung nếu chưa đo workload, kiểm tra query plan và có kế hoạch rollback.

## 1. Mục tiêu học tập

Sau khi hoàn thành tutorial này, người học có thể:

1. Giải thích index là gì và trade-off giữa tốc độ đọc với chi phí ghi/lưu trữ.
2. Tạo single-column index bằng `CREATE INDEX` hoặc `ALTER TABLE`.
3. Tạo composite index cho mẫu truy vấn nhiều điều kiện trên các bảng `classicmodels`.
4. Đọc metadata index bằng `SHOW INDEX`, `SHOW CREATE TABLE` và `INFORMATION_SCHEMA.STATISTICS`.
5. Xóa secondary index bằng `DROP INDEX` hoặc `ALTER TABLE ... DROP INDEX` mà vẫn giữ nguyên `PRIMARY KEY` và foreign key indexes gốc.
6. Phân biệt primary key, secondary index và composite index ở mức thực hành.
7. Dùng `EXPLAIN` để kiểm tra kế hoạch trước/sau khi tạo index.
8. Chọn tên index rõ nghĩa và tránh tạo index trùng lặp.
9. Dùng `ANALYZE TABLE` như một bước làm mới statistics khi phù hợp.
10. Nhận biết trường hợp optimizer vẫn có thể không dùng index vừa tạo.

---

## 2. Index là gì?

Index là một cấu trúc dữ liệu giúp MySQL tìm row nhanh hơn cho một số điều kiện và thứ tự truy vấn.

Ví dụ trên bảng `customers` của `classicmodels`:

```sql
SELECT customerNumber, contactFirstName, contactLastName, creditLimit
FROM customers
WHERE country = 'USA';
```

Nếu có index trên `country`, MySQL có thể dùng index để tìm nhanh các row khớp thay vì đọc mọi row trong table, tùy vào dữ liệu và optimizer plan.

Với B-tree index, MySQL có thể hỗ trợ tra cứu theo:

```text
=
>
>=
<
<=
BETWEEN
IN (...)
```

và một số mẫu `LIKE 'prefix%'`.

### 2.1. Index không làm mọi query nhanh hơn

Index có lợi khi query cần chọn một phần tương đối nhỏ dữ liệu hoặc khi index hỗ trợ join, sort hoặc grouping phù hợp.

Index có chi phí:

| Chi phí | Diễn giải |
|---|---|
| Storage | Mỗi index chiếm thêm disk/memory cache |
| INSERT | Mỗi row insert có thể phải thêm entry cho nhiều index |
| UPDATE | Update index key cần cập nhật index |
| DELETE | Delete row cần xóa entry trong index |
| Optimizer complexity | Quá nhiều index làm lựa chọn plan phức tạp hơn |
| DDL impact | Tạo/xóa index trên table lớn có thể tốn thời gian và ảnh hưởng workload |

Không tạo index cho mọi cột. Cần dựa vào query workload, `EXPLAIN`, dữ liệu thực tế và đo đạc.

### 2.2. Primary key và secondary index

| Loại | Ví dụ trong `classicmodels` | Vai trò |
|---|---|---|
| Primary key | `PRIMARY KEY(customerNumber)` | Định danh row; InnoDB dùng làm clustered index |
| Secondary index | `INDEX idx_customers_country(country)` | Hỗ trợ lookup/sort/join ngoài primary key |
| Composite index | `INDEX idx_customers_country_credit(country, creditLimit)` | Hỗ trợ mẫu query dùng nhiều cột theo thứ tự key parts |

### 2.3. Mô hình “mục lục sách”

Index có thể hình dung như mục lục của sách:

- Không có mục lục: đọc nhiều trang để tìm chủ đề.
- Có mục lục: tìm từ khóa → đến vùng trang có khả năng chứa nội dung.
- Mục lục cũng phải được cập nhật khi sách thay đổi.

Đây chỉ là trực giác. Database index có cấu trúc, cache, concurrency và optimizer phức tạp hơn.

### Bài tập thực hành

**Bài 2.1.** Giải thích index là gì bằng một hoặc hai câu.

**Bài 2.2.** Nêu hai lợi ích của index.

**Bài 2.3.** Nêu hai chi phí của việc thêm index.

**Bài 2.4.** Phân biệt primary key với secondary index.

**Bài 2.5.** Giải thích vì sao “tạo index cho mọi cột” là chiến lược không tốt.

---

## 3. Cơ sở dữ liệu `classicmodels` & Index mặc định

### 3.1. Các bảng trọng tâm trong `classicmodels`

Toàn bộ bài thực hành sử dụng trực tiếp các bảng có sẵn trong cơ sở dữ liệu mẫu **`classicmodels`** (không cần tạo database hay tạo bảng mới):

- **`customers` (122 dòng):** `customerNumber (PK)`, `customerName`, `contactLastName`, `contactFirstName`, `phone`, `city`, `state`, `country`, `salesRepEmployeeNumber (FK)`, `creditLimit`.
- **`orders` (326 dòng):** `orderNumber (PK)`, `orderDate`, `requiredDate`, `shippedDate`, `status`, `comments`, `customerNumber (FK)`.
- **`products` (110 dòng):** `productCode (PK)`, `productName`, `productLine (FK)`, `productScale`, `productVendor`, `quantityInStock`, `buyPrice`, `MSRP`.
- **`orderdetails` (2.996 dòng):** `(orderNumber, productCode) (PK)`, `quantityOrdered`, `priceEach`, `orderLineNumber`.
- **`payments` (273 dòng):** `(customerNumber, checkNumber) (PK)`, `paymentDate`, `amount`.

### 3.2. Kiểm tra index mặc định trên `classicmodels`

Kiểm tra các index đã có sẵn (bao gồm `PRIMARY KEY` và các index do `FOREIGN KEY` tự động tạo trong InnoDB):

```sql
SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM products;
```

> **Lưu ý:** Trong `classicmodels`, các cột khóa ngoại như `orders.customerNumber`, `products.productLine`, `customers.salesRepEmployeeNumber`, `orderdetails.productCode` thường đã có index tự động do InnoDB tạo để hỗ trợ ràng buộc `FOREIGN KEY`. Khi tạo thêm index trong bài tập, cần giữ nguyên các index mặc định này và chỉ xóa các index thử nghiệm bạn tự thêm.

### 3.3. Lưu ý về quy mô dữ liệu lab

`classicmodels` có kích thước nhỏ (tổng 3.864 bản ghi trên 8 bảng). Vì vậy, optimizer có thể chọn table scan dù index tồn tại, vì đọc toàn table nhỏ đôi khi rẻ hơn đi qua index.

Trong lab, mục tiêu chính là:

- Đọc DDL index.
- Quan sát `EXPLAIN`.
- So sánh `possible_keys`, `key`, `rows`, `Extra`.
- Hiểu mẫu query phù hợp với index.

Không lấy thời gian chạy trên dữ liệu nhỏ làm bằng chứng duy nhất về thiết kế production.

### Bài tập thực hành

**Bài 3.1.** Dùng `SHOW INDEX` kiểm tra các index mặc định trên bảng `customers`.

**Bài 3.2.** Dùng `SHOW INDEX` kiểm tra các index mặc định trên bảng `orders`.

**Bài 3.3.** Dùng `SHOW INDEX` kiểm tra các index mặc định trên bảng `products`.

**Bài 3.4.** Giải thích vì sao small table trong `classicmodels` có thể không dùng index dù index tồn tại.

**Bài 3.5.** Nêu lý do không nên chỉ dựa vào thời gian chạy trên dữ liệu nhỏ để kết luận thiết kế production.

---

## 4. Tạo index bằng `CREATE INDEX`

### 4.1. Single-column index

Cú pháp:

```sql
CREATE INDEX index_name
ON table_name (column_name);
```

Ví dụ tạo index hỗ trợ lọc khách hàng theo quốc gia trên bảng `customers`:

```sql
CREATE INDEX idx_customers_country
ON customers (country);
```

Kiểm tra:

```sql
SHOW INDEX FROM customers;
```

Dùng query:

```sql
EXPLAIN
SELECT customerNumber, contactFirstName, contactLastName, creditLimit
FROM customers
WHERE country = 'USA';
```

### 4.2. Naming convention

Tên index nên mô tả:

```text
idx_<table_or_feature>_<column_or_pattern>
```

Ví dụ:

```text
idx_customers_country
idx_orders_customer_date
idx_products_line_msrp
```

Với unique index:

```text
uq_customers_name
```

Không đặt tên mơ hồ:

```text
idx1
index_a
new_index
```

### 4.3. Tạo index nhiều cột

```sql
CREATE INDEX idx_customers_country_credit
ON customers (country, creditLimit);
```

Đây là **một composite index**, không phải hai index độc lập.

Nó phù hợp với các query như:

```sql
SELECT customerNumber, customerName, country, creditLimit
FROM customers
WHERE country = 'USA'
  AND creditLimit >= 50000.00;
```

Chi tiết về thứ tự cột của composite index sẽ học sâu ở Tutorial 2.

### 4.4. Tạo index bằng `ALTER TABLE`

```sql
ALTER TABLE products
ADD INDEX idx_products_line (productLine);
```

Hoặc:

```sql
ALTER TABLE products
ADD INDEX idx_products_line_msrp (productLine, MSRP);
```

`CREATE INDEX` và `ALTER TABLE ... ADD INDEX` đều là cách hợp lệ để thêm secondary index. Chọn một style thống nhất trong project.

### Bài tập thực hành

**Bài 4.1.** Tạo index `idx_customers_country` trên `customers(country)`.

**Bài 4.2.** Tạo index `idx_orders_status` trên `orders(status)`.

**Bài 4.3.** Tạo composite index `idx_orders_customer_date` trên `orders(customerNumber, orderDate)`.

**Bài 4.4.** Dùng `ALTER TABLE` tạo index `idx_products_line` trên `products(productLine)`.

**Bài 4.5.** Viết query trên `orders` phù hợp với index `(customerNumber, orderDate)`.

---

## 5. Kiểm tra index bằng `SHOW INDEX`

### 5.1. Cú pháp

```sql
SHOW INDEX FROM table_name;
```

Các alias thường gặp:

```sql
SHOW INDEXES FROM table_name;
SHOW KEYS FROM table_name;
```

Ví dụ:

```sql
SHOW INDEX FROM orders;
```

### 5.2. Các cột quan trọng

| Cột output | Ý nghĩa |
|---|---|
| `Table` | Tên table |
| `Non_unique` | `0` nếu unique, `1` nếu index cho phép trùng |
| `Key_name` | Tên index |
| `Seq_in_index` | Vị trí cột trong index |
| `Column_name` | Cột index key part |
| `Collation` | Hướng lưu key part, thường `A` hoặc `D` |
| `Cardinality` | Ước lượng distinct values |
| `Sub_part` | Prefix length nếu là prefix index |
| `Index_type` | Ví dụ `BTREE` |
| `Visible` | `YES`/`NO` nếu server hỗ trợ invisible index |

Ví dụ nhìn composite index:

```sql
SHOW INDEX FROM orders
WHERE Key_name = 'idx_orders_customer_date';
```

Nếu output có hai dòng:

```text
Seq_in_index = 1, Column_name = customerNumber
Seq_in_index = 2, Column_name = orderDate
```

thì thứ tự key parts là:

```text
(customerNumber, orderDate)
```

### 5.3. `SHOW CREATE TABLE`

`SHOW INDEX` tốt cho overview index metadata. `SHOW CREATE TABLE` cho DDL tổng thể:

```sql
SHOW CREATE TABLE orders;
```

Dùng lệnh này để xem:

- Columns.
- Primary key.
- Secondary indexes.
- Foreign keys.
- Engine.
- Table options.

### 5.4. `INFORMATION_SCHEMA.STATISTICS`

Khi cần query metadata theo điều kiện:

```sql
SELECT INDEX_NAME,
       NON_UNIQUE,
       SEQ_IN_INDEX,
       COLUMN_NAME,
       COLLATION,
       CARDINALITY,
       SUB_PART,
       INDEX_TYPE,
       IS_VISIBLE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'classicmodels'
  AND TABLE_NAME = 'orders'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;
```

### Bài tập thực hành

**Bài 5.1.** Dùng `SHOW INDEX FROM customers`.

**Bài 5.2.** Dùng `SHOW INDEX FROM orders WHERE Key_name = 'idx_orders_customer_date';`.

**Bài 5.3.** Xác định thứ tự cột của `idx_orders_customer_date`.

**Bài 5.4.** Dùng `SHOW CREATE TABLE orders`.

**Bài 5.5.** Viết query `INFORMATION_SCHEMA.STATISTICS` liệt kê metadata index của `products` trong `classicmodels`.

---

## 6. Dùng `EXPLAIN` để kiểm tra index usage

### 6.1. Cú pháp

```sql
EXPLAIN
SELECT ...
```

Ví dụ:

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01';
```

Các cột cần quan sát ban đầu:

| Cột | Cách đọc cơ bản |
|---|---|
| `possible_keys` | Các index optimizer có thể cân nhắc |
| `key` | Index được chọn thực tế; `NULL` nghĩa là không chọn index |
| `key_len` | Độ dài key part được dùng |
| `rows` | Số row optimizer ước lượng cần xem |
| `filtered` | Tỷ lệ row ước lượng qua filter |
| `Extra` | Thông tin bổ sung như `Using where`, `Using index`, `Using filesort` |

Ví dụ tạo index rồi so sánh:

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders
WHERE customerNumber = 103
ORDER BY orderDate;
```

Sau đó:

```sql
CREATE INDEX idx_orders_customer_date
ON orders (customerNumber, orderDate);
```

Chạy `EXPLAIN` lại.

### 6.2. Không coi `key = NULL` luôn là lỗi

Optimizer có thể quyết định full table scan nếu:

- Table rất nhỏ.
- Điều kiện trả về phần lớn row (ví dụ `WHERE status = 'Shipped'` chiếm 303/326 dòng bảng `orders`).
- Index không đủ selective.
- Cost estimate cho table scan thấp hơn.
- Query expression không phù hợp với index.

Cần đánh giá bằng query, plan và workload thực, không chỉ nhìn một dấu hiệu.

### 6.3. `ANALYZE TABLE`

Khi statistics cũ hoặc sau thay đổi dữ liệu lớn, có thể xem xét:

```sql
ANALYZE TABLE orders;
```

Sau đó chạy lại `EXPLAIN`.

Không chạy maintenance operations tùy tiện trên production. Cần hiểu impact theo storage engine, version và workload.

### Bài tập thực hành

**Bài 6.1.** Chạy `EXPLAIN` cho query lọc `orders` theo `customerNumber`.

**Bài 6.2.** Xác định `possible_keys` và `key` trong output.

**Bài 6.3.** Chạy `EXPLAIN` cho query lọc theo `status`.

**Bài 6.4.** Chạy `ANALYZE TABLE orders;` trong `classicmodels`.

**Bài 6.5.** Nêu hai lý do optimizer có thể không dùng index trên table nhỏ.

---

## 7. Xóa index

### 7.1. `DROP INDEX`

Cú pháp:

```sql
DROP INDEX index_name
ON table_name;
```

Ví dụ:

```sql
DROP INDEX idx_customers_country
ON customers;
```

### 7.2. `ALTER TABLE ... DROP INDEX`

```sql
ALTER TABLE customers
DROP INDEX idx_customers_country;
```

Hai cách trên đều dùng để xóa secondary index.

### 7.3. Không dùng `DROP INDEX` để xóa primary key

Primary key là constraint/index đặc biệt.

Để xóa primary key:

```sql
ALTER TABLE table_name
DROP PRIMARY KEY;
```

Không làm việc này trong production chỉ để “thử index”. Primary key có thể liên quan foreign keys, clustered storage layout và application assumptions.

### 7.4. Kiểm tra trước khi drop

Trước khi drop:

```sql
SHOW INDEX FROM customers;
```

Sau drop:

```sql
SHOW INDEX FROM customers;
```

Cần kiểm tra:

- Index có thật sự redundant không?
- Có query hay foreign key phụ thuộc index không?
- Có cần dùng invisible index để thử impact trước không?
- Có migration/rollback script không?

### 7.5. DDL và transaction

Tạo/xóa index là DDL. Trong MySQL, DDL thường có transactional behavior khác DML và có thể gây implicit commit. Không giả định có thể `ROLLBACK` một `CREATE INDEX` hoặc `DROP INDEX` như rollback `INSERT`.

Trên table lớn, hoạt động DDL cần được lên kế hoạch theo version, engine và yêu cầu availability.

### Bài tập thực hành

**Bài 7.1.** Xóa `idx_customers_country` trên bảng `customers` bằng `DROP INDEX`.

**Bài 7.2.** Tạo lại index đó bằng `CREATE INDEX`.

**Bài 7.3.** Xóa `idx_products_line` trên bảng `products` bằng `ALTER TABLE ... DROP INDEX`.

**Bài 7.4.** Giải thích vì sao không dùng `DROP INDEX` để xóa primary key.

**Bài 7.5.** Nêu hai kiểm tra cần làm trước khi drop index trên production.

---

## 8. Thiết kế index cơ bản

### 8.1. Bắt đầu từ workload

Không bắt đầu bằng câu hỏi:

```text
Table này có cột nào chưa có index?
```

Hãy bắt đầu bằng:

```text
Các query quan trọng nào chạy thường xuyên, chậm hoặc phục vụ nghiệp vụ chính?
```

Ví dụ workload trên `orders`:

```sql
SELECT *
FROM orders
WHERE customerNumber = ?
ORDER BY orderDate DESC
LIMIT 20;
```

Index ứng viên:

```sql
CREATE INDEX idx_orders_customer_date_desc
ON orders (customerNumber, orderDate DESC);
```

Ví dụ trên `customers`:

```sql
SELECT *
FROM customers
WHERE country = ?
  AND creditLimit >= ?;
```

Index ứng viên:

```sql
CREATE INDEX idx_customers_country_credit
ON customers (country, creditLimit);
```

### 8.2. Tránh index dư thừa

Nếu đã có:

```text
(customerNumber, orderDate)
```

thì một index riêng chỉ trên `customerNumber` có thể trở nên dư thừa cho một số workload, vì composite index có thể hỗ trợ leftmost key part `customerNumber`.

Tuy nhiên, không drop index chỉ bằng quy tắc này. Cần kiểm tra:

- Unique/foreign-key requirements (lưu ý trong `classicmodels`, `orders.customerNumber` gắn với Foreign Key).
- Query patterns.
- Covering behavior.
- Existing plans.
- Write cost và object dependencies.

### 8.3. Cột nào thường là ứng viên?

Cần xem xét cột được dùng thường xuyên trong:

- `WHERE`.
- Join conditions.
- `ORDER BY`.
- `GROUP BY`.
- Foreign-key lookups.

Nhưng selectivity, thứ tự cột, expression, số row trả về và write workload đều quan trọng.

### Bài tập thực hành

**Bài 8.1.** Đề xuất index cho query lọc `customerNumber` rồi sắp xếp `orderDate DESC` trên `orders`.

**Bài 8.2.** Đề xuất index cho query lọc `country` và `creditLimit` trên `customers`.

**Bài 8.3.** Nêu ba nơi trong query thường là nguồn để tìm index candidate.

**Bài 8.4.** Giải thích vì sao cột xuất hiện trong `WHERE` không tự động có nghĩa phải tạo index.

**Bài 8.5.** Nêu ba yếu tố cần kiểm tra trước khi drop một index bị nghi dư thừa.

---

## 9. Bài tập tổng hợp

### Bài 9.1. Quản lý index `customers`

1. Tạo index trên `customers(country)`.
2. Tạo composite index trên `(country, creditLimit)`.
3. Liệt kê index bằng `SHOW INDEX`.
4. Dùng `EXPLAIN` cho query lọc country + credit limit.
5. Xóa index single-column nếu bạn xác nhận chỉ dùng để lab.

### Bài 9.2. Quản lý index `orders`

1. Tạo index `(customerNumber, orderDate)`.
2. Dùng `SHOW CREATE TABLE`.
3. Chạy `EXPLAIN` cho query theo customer và date range.
4. Chạy `ANALYZE TABLE`.
5. So sánh plan trước/sau theo các cột `possible_keys`, `key`, `rows`.

### Bài 9.3. Metadata report

Viết query từ `INFORMATION_SCHEMA.STATISTICS` trả về:

1. Table name.
2. Index name.
3. Non-unique flag.
4. Sequence in index.
5. Column name.
6. Cardinality.
7. Visibility.

Chỉ áp dụng cho schema `classicmodels`.

### Bài 9.4. Index decision

Với query trên `products`:

```sql
SELECT productCode, productName, MSRP
FROM products
WHERE productLine = 'Motorcycles'
ORDER BY MSRP DESC;
```

1. Đề xuất composite index.
2. Viết `CREATE INDEX`.
3. Dùng `EXPLAIN`.
4. Nêu vì sao data nhỏ có thể vẫn scan.
5. Nêu cách rollback lab index.

### Bài 9.5. Cleanup

Xóa các secondary index lab đã tạo thêm trong tutorial này trên `customers`, `orders`, `products`, nhưng giữ nguyên primary keys và foreign key indexes gốc của `classicmodels`.

---

## 10. Đáp án gợi ý

### Bài 4.3

```sql
CREATE INDEX idx_orders_customer_date
ON orders (customerNumber, orderDate);
```

### Bài 5.5

```sql
SELECT INDEX_NAME,
       NON_UNIQUE,
       SEQ_IN_INDEX,
       COLUMN_NAME,
       COLLATION,
       CARDINALITY,
       SUB_PART,
       INDEX_TYPE,
       IS_VISIBLE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'classicmodels'
  AND TABLE_NAME = 'products'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;
```

### Bài 6.1

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders
WHERE customerNumber = 103;
```

### Bài 7.1

```sql
DROP INDEX idx_customers_country
ON customers;
```

### Bài 8.1

```sql
CREATE INDEX idx_orders_customer_date_desc
ON orders (customerNumber, orderDate DESC);
```

### Bài 9.4

```sql
CREATE INDEX idx_products_line_msrp_desc
ON products (productLine, MSRP DESC);

EXPLAIN
SELECT productCode, productName, MSRP
FROM products
WHERE productLine = 'Motorcycles'
ORDER BY MSRP DESC;
```

### Cleanup

```sql
DROP INDEX IF EXISTS idx_customers_country
ON customers;

DROP INDEX IF EXISTS idx_customers_country_credit
ON customers;

DROP INDEX IF EXISTS idx_orders_status
ON orders;

DROP INDEX IF EXISTS idx_orders_customer_date
ON orders;

DROP INDEX IF EXISTS idx_orders_customer_date_desc
ON orders;

DROP INDEX IF EXISTS idx_products_line
ON products;

DROP INDEX IF EXISTS idx_products_line_msrp_desc
ON products;
```

> `DROP INDEX IF EXISTS` được hỗ trợ trên các phiên bản MySQL hiện tại (8.0+). Nếu server từ chối cú pháp này, hãy kiểm tra `SHOW INDEX` trước và dùng `DROP INDEX index_name ON table_name` cho các index đang tồn tại.

---

## 11. Tóm tắt

- Index hỗ trợ lookup, join, sort hoặc grouping cho các query phù hợp.
- Index có chi phí storage và làm INSERT/UPDATE/DELETE đắt hơn.
- Dùng `CREATE INDEX` hoặc `ALTER TABLE ... ADD INDEX` để tạo secondary index.
- Dùng `SHOW INDEX`, `SHOW CREATE TABLE` và `INFORMATION_SCHEMA.STATISTICS` để kiểm tra metadata.
- Dùng `EXPLAIN` để quan sát plan; không mặc định mọi index phải được optimizer chọn.
- Dùng `DROP INDEX` hoặc `ALTER TABLE ... DROP INDEX` để xóa secondary index.
- Thiết kế index dựa trên workload, không dựa trên việc “mỗi cột một index”.
- Tạo/xóa index là DDL, cần thực hiện thận trọng trên table lớn hoặc production.

---

## 12. Từ khóa chính

- Index
- Secondary index
- Primary key
- Composite index
- CREATE INDEX
- ALTER TABLE ADD INDEX
- DROP INDEX
- SHOW INDEX
- INFORMATION_SCHEMA.STATISTICS
- EXPLAIN
- ANALYZE TABLE
- Cardinality
- Selectivity
- Query plan
- InnoDB
- DDL
- classicmodels
