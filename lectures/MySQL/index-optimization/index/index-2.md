---
title: "Tutorial 2: MySQL Index Types và chiến lược chọn Index"
author: "Tên giảng viên"
duration: "210m"
difficulty: "Intermediate–Advanced"
prerequisites:
  - "Đã hoàn thành Tutorial 1 về tạo và quản lý index trên classicmodels"
  - "Đã biết EXPLAIN và composite index cơ bản"
  - "MySQL 8.x được khuyến nghị cho invisible, descending và functional indexes"
summary: "Thực hành unique, prefix, invisible, descending, composite, clustered, cardinality và functional indexes trực tiếp trên cơ sở dữ liệu classicmodels; đồng thời xây dựng tư duy chọn index theo query pattern."
---

# Tutorial 2: MySQL Index Types và chiến lược chọn Index

## Link tham khảo

- [MySQL Tutorial — MySQL Index](https://www.mysqltutorial.org/mysql-index/)
- [MySQL Tutorial — UNIQUE Index](https://www.mysqltutorial.org/mysql-index/mysql-unique-index/)
- [MySQL Tutorial — Prefix Index](https://www.mysqltutorial.org/mysql-index/mysql-prefix-index/)
- [MySQL Tutorial — Invisible Index](https://www.mysqltutorial.org/mysql-index/mysql-invisible-index/)
- [MySQL Tutorial — Descending Index](https://www.mysqltutorial.org/mysql-index/mysql-descending-index/)
- [MySQL Tutorial — Composite Index](https://www.mysqltutorial.org/mysql-index/mysql-composite-index/)
- [MySQL Tutorial — Clustered Index](https://www.mysqltutorial.org/mysql-index/mysql-clustered-index/)
- [MySQL Tutorial — Index Cardinality](https://www.mysqltutorial.org/mysql-index/mysql-index-cardinality/)
- [MySQL Tutorial — Functional Index](https://www.mysqltutorial.org/mysql-index/mysql-functional-index/)
- [MySQL 8.4 Reference Manual — Column Indexes](https://dev.mysql.com/doc/refman/8.4/en/column-indexes.html)
- [MySQL 8.4 Reference Manual — Invisible Indexes](https://dev.mysql.com/doc/refman/8.4/en/invisible-indexes.html)
- [MySQL 8.4 Reference Manual — Descending Indexes](https://dev.mysql.com/doc/refman/8.4/en/descending-indexes.html)
- [MySQL 8.4 Reference Manual — Clustered and Secondary Indexes](https://dev.mysql.com/doc/refman/8.4/en/innodb-index-types.html)
- [MySQL 8.4 Reference Manual — Functional Key Parts](https://dev.mysql.com/doc/refman/8.4/en/create-index.html)

> **Phiên bản:** Các ví dụ invisible, descending và functional index yêu cầu server hỗ trợ feature tương ứng. Hãy chạy `SELECT VERSION();` trước khi thực hành. Nếu server cũ không hỗ trợ một feature, học khái niệm và bỏ qua phần DDL đó.

## 1. Mục tiêu học tập

Sau khi hoàn thành tutorial này, người học có thể:

1. Tạo và dùng unique index để duy trì distinctness trên các cột nghiệp vụ của `classicmodels`.
2. Giải thích prefix index và đánh đổi giữa kích thước index với selectivity.
3. Dùng invisible index để kiểm thử tác động của việc bỏ index mà chưa drop ngay.
4. Dùng descending index cho query có mixed sort order.
5. Thiết kế composite index theo leftmost-prefix principle.
6. Giải thích clustered index và secondary index trong InnoDB.
7. Đọc cardinality từ `SHOW INDEX` như một estimate.
8. Tạo functional index cho expression phù hợp.
9. So sánh functional index với query rewrite theo range predicate.
10. Chọn index theo workload thay vì áp dụng “một quy tắc cho mọi query”.

---

## 2. Kiểm tra Index gốc trên `classicmodels`

Sử dụng trực tiếp cơ sở dữ liệu **`classicmodels`** (với các bảng `customers`, `orders`, `products`, `orderdetails`, `payments`, `employees`).

Kiểm tra các index mặc định (PK và FK index) hiện có:

```sql
SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM products;
```

> Trong toàn bộ tutorial, hãy tạo index thử nghiệm có prefix `idx_` hoặc `uq_`, kiểm tra bằng `SHOW INDEX`, và drop các index tự tạo sau khi hoàn thành để giữ nguyên cấu trúc gốc của `classicmodels`.

### Bài tập thực hành

**Bài 2.1.** Liệt kê index hiện có của bảng `customers`.

**Bài 2.2.** Liệt kê index hiện có của bảng `products`.

**Bài 2.3.** Liệt kê index hiện có của bảng `orders`.

**Bài 2.4.** Nêu lý do cần biết phiên bản MySQL trước khi thử functional index.

**Bài 2.5.** Nêu lý do index lab cần naming convention (`idx_`, `uq_`).

---

## 3. Unique indexes

### 3.1. Khái niệm

Unique index đảm bảo không có hai row có cùng giá trị key (theo quy tắc `NULL` của MySQL).

Cú pháp:

```sql
CREATE UNIQUE INDEX index_name
ON table_name (column_name);
```

Trong `classicmodels`, toàn bộ 122 khách hàng trong bảng `customers` có `customerName` hoàn toàn phân biệt (122/122 distinct):

```sql
CREATE UNIQUE INDEX uq_customers_name
ON customers (customerName);
```

Sau đó, insert tên khách hàng đã tồn tại (`'Atelier graphique'`) sẽ bị từ chối với lỗi Duplicate entry:

```sql
INSERT INTO customers (
    customerNumber, customerName, contactLastName, contactFirstName,
    phone, addressLine1, city, country, creditLimit
)
VALUES (
    999001, 'Atelier graphique', 'Test', 'Duplicate',
    '0123456789', '123 Test St', 'Nantes', 'France', 1000.00
);
```

> **Lưu ý thực tế trên `classicmodels`:** Nếu bạn thử tạo `UNIQUE INDEX` trên cột `employees(email)`, MySQL sẽ báo lỗi trùng khóa vì hai nhân viên `1076` (Jeff Firrelli) và `1188` (Julie Firrelli) đang dùng chung email `jfirrelli@classicmodelcars.com`. Đây là minh họa thực tế: chỉ đặt `UNIQUE` khi dữ liệu sạch và nghiệp vụ đảm bảo duy nhất.

### 3.2. UNIQUE index và PRIMARY KEY

| Đặc điểm | PRIMARY KEY | UNIQUE index |
|---|---|---|
| Số lượng trên table | Một | Có thể nhiều |
| NULL | Không cho phép | MySQL thường cho phép nhiều `NULL` nếu column nullable |
| Vai trò | Định danh chính của row (`customerNumber`) | Bảo đảm distinctness cho business key (`customerName`) |
| InnoDB | Dùng làm clustered index | Là secondary index trừ khi được InnoDB chọn làm clustered index do không có PK |

Nếu business rule yêu cầu cột luôn có và luôn unique:

```sql
ALTER TABLE customers
MODIFY customerName VARCHAR(50) NOT NULL;

CREATE UNIQUE INDEX uq_customers_name
ON customers (customerName);
```

Nếu một cột (ví dụ mã số thuế / email phụ) là optional, cần xác định rõ `NULL` có ý nghĩa gì trong nghiệp vụ.

### 3.3. Không dùng UNIQUE chỉ để tăng tốc

Unique index có thể hỗ trợ lookup, nhưng mục đích chính là integrity. Không tạo unique index nếu data hợp lệ có thể có duplicate values (như `customers.country` hay `orders.status`).

### Bài tập thực hành

**Bài 3.1.** Tạo unique index `uq_customers_name` trên `customers(customerName)`.

**Bài 3.2.** Giải thích điều gì xảy ra nếu chèn thêm một khách hàng mới trùng `customerName = 'Atelier graphique'` sau khi tạo `uq_customers_name`.

**Bài 3.3.** Dùng `SHOW INDEX` xác định `Non_unique` của `uq_customers_name`.

**Bài 3.4.** Giải thích khác nhau giữa primary key và unique index.

**Bài 3.5.** Nêu một cột trong hệ thống `classicmodels` có thể là ứng viên unique index.

---

## 4. Prefix indexes

### 4.1. Khái niệm

Prefix index chỉ index phần đầu của chuỗi.

Cú pháp:

```sql
CREATE INDEX index_name
ON table_name (string_column(prefix_length));
```

Ví dụ trên bảng `products` (`productName` là `VARCHAR(70)`):

```sql
CREATE INDEX idx_products_name_prefix
ON products (productName(12));
```

Prefix index hữu ích khi:

- Chuỗi dài (`productName`, `productDescription`, `addressLine1`).
- Full-column index quá lớn.
- Những ký tự đầu đủ phân biệt phần lớn giá trị truy vấn.
- Query thường dùng `LIKE 'prefix%'`.

### 4.2. Prefix với TEXT/BLOB

Với `TEXT` hoặc `BLOB` (như `products.productDescription`, `orders.comments`), MySQL yêu cầu prefix length khi tạo ordinary index.

Độ dài prefix bị giới hạn theo engine, row format, character set và byte limits. Đặc biệt với charset nhiều byte như `utf8mb4`, số ký tự phải được chọn có xét đến số byte mỗi ký tự.

Không hard-code một prefix length phổ quát. Cần đo:

- Tính selectivity theo prefix.
- Kích thước index.
- Mẫu search thực tế.
- Charset/collation.

### 4.3. Chọn prefix length

Có thể so sánh distinct prefixes trực tiếp trên `classicmodels.products`:

```sql
SELECT
    COUNT(*) AS totalRows,
    COUNT(DISTINCT LEFT(productName, 4)) AS distinctPrefix4,
    COUNT(DISTINCT LEFT(productName, 8)) AS distinctPrefix8,
    COUNT(DISTINCT LEFT(productName, 12)) AS distinctPrefix12,
    COUNT(DISTINCT productName) AS distinctFullName
FROM products;
```

Trên dữ liệu thật của `classicmodels.products` (110 dòng):
- Prefix 4 ký tự chỉ phân biệt được 64 giá trị (do nhiều mô hình bắt đầu bằng năm như `'1969'`, `'1957'`).
- Prefix 8 ký tự phân biệt 102 giá trị.
- Prefix 12 ký tự phân biệt 105/110 giá trị.

Prefix càng dài thường càng selective, nhưng index càng lớn.

### 4.4. Cảnh báo với UNIQUE prefix index

Ví dụ:

```sql
CREATE UNIQUE INDEX uq_products_name_prefix
ON products (productName(12));
```

Câu này chỉ đảm bảo prefix 12 ký tự unique, không đảm bảo full `productName` unique theo cách mong muốn (và thậm chí thất bại ngay trên `products` vì có các tên sản phẩm trùng nhau 12 ký tự đầu). Trong đa số trường hợp business key, cần full unique index, không dùng unique prefix index.

### 4.5. Prefix index không thay thế full-text search

Prefix index phù hợp với pattern bắt đầu bằng chuỗi:

```sql
SELECT productCode, productName
FROM products
WHERE productName LIKE '1969%';
```

Nó không phải giải pháp tổng quát cho:

```sql
WHERE productName LIKE '%Ford%'
```

vì leading wildcard thường không dùng B-tree prefix index theo cách mong muốn. Với search văn bản phong phú, xem xét FULLTEXT hoặc công cụ search phù hợp.

### Bài tập thực hành

**Bài 4.1.** Tạo `idx_products_name_prefix` trên `products(productName(12))`.

**Bài 4.2.** Dùng `SHOW INDEX` kiểm tra cột `Sub_part` của `idx_products_name_prefix`.

**Bài 4.3.** Viết query đếm distinct prefix length 4, 8, 12 của `productName` trong bảng `products`.

**Bài 4.4.** Viết query `LIKE '1969%'` trên `products(productName)` phù hợp với prefix search.

**Bài 4.5.** Giải thích vì sao không nên dùng unique prefix index để enforce full string uniqueness.

---

## 5. Invisible indexes

### 5.1. Khái niệm

Invisible index tồn tại và vẫn được duy trì khi data thay đổi, nhưng optimizer mặc định không dùng nó để lập execution plan.

Tạo invisible index:

```sql
CREATE INDEX idx_customers_country_invisible
ON customers (country) INVISIBLE;
```

Đổi một index hiện có thành invisible:

```sql
ALTER TABLE customers
ALTER INDEX idx_customers_country INVISIBLE;
```

Đưa lại visible:

```sql
ALTER TABLE customers
ALTER INDEX idx_customers_country VISIBLE;
```

### 5.2. Khi nào dùng?

Invisible index hữu ích để kiểm thử câu hỏi:

```text
Nếu index này không còn tồn tại với optimizer, các query bị ảnh hưởng thế nào?
```

Thay vì:

```text
DROP INDEX → chạy test → phải build lại index nếu cần
```

có thể:

```text
ALTER INDEX ... INVISIBLE → test → VISIBLE hoặc DROP
```

### 5.3. Các giới hạn quan trọng

- Primary key không thể invisible.
- Một unique index có thể không được phép invisible nếu InnoDB đang dùng nó như implicit clustered key do table không có primary key phù hợp.
- Invisible index vẫn chiếm storage và vẫn được update bởi DML.
- Unique invisible index vẫn enforce uniqueness.
- Optimizer mặc định bỏ qua invisible indexes; có thể kiểm thử đặc biệt với `use_invisible_indexes` theo docs, nhưng không nên đổi global behavior cho mục đích lab đơn giản.

### 5.4. Kiểm tra visibility

```sql
SHOW INDEX FROM customers;
```

Hoặc:

```sql
SELECT INDEX_NAME, IS_VISIBLE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'classicmodels'
  AND TABLE_NAME = 'customers';
```

### Bài tập thực hành

**Bài 5.1.** Tạo index visible `idx_customers_country` trên `customers(country)` nếu chưa có.

**Bài 5.2.** Đổi index đó thành invisible.

**Bài 5.3.** Dùng `SHOW INDEX` hoặc `INFORMATION_SCHEMA.STATISTICS` kiểm tra visibility trên `classicmodels.customers`.

**Bài 5.4.** Chạy `EXPLAIN` trước và sau khi index invisible cho query lọc `country = 'USA'`.

**Bài 5.5.** Đổi index về visible, sau đó giải thích vì sao invisible không có nghĩa index ngừng được DML maintenance.

---

## 6. Descending indexes

### 6.1. Khái niệm

Descending index lưu key part theo hướng giảm dần. Nó đặc biệt hữu ích cho **mixed sort order** trong composite index.

Ví dụ trên bảng `orders`:

```sql
CREATE INDEX idx_orders_status_date_desc
ON orders (status ASC, orderDate DESC);
```

Query phù hợp:

```sql
SELECT orderNumber, orderDate, status
FROM orders
WHERE status = 'Shipped'
ORDER BY orderDate DESC
LIMIT 10;
```

### 6.2. Mixed order là điểm quan trọng

Ví dụ index:

```sql
(status ASC, orderDate DESC)
```

có thể phù hợp với:

```sql
ORDER BY status ASC, orderDate DESC
```

Trong MySQL InnoDB, descending key parts giúp optimizer dùng forward scan cho những thứ tự có kết hợp ASC/DESC. Đây là trường hợp đáng chú ý hơn so với chỉ một cột đơn lẻ.

### 6.3. Lưu ý

- Descending indexes được hỗ trợ cho InnoDB (từ MySQL 8.0+).
- Không phải mọi query có `ORDER BY ... DESC` đều cần index DESC mới.
- Query vẫn cần thỏa điều kiện về index order, filter, join và selectivity.
- Dùng `EXPLAIN` để kiểm tra `Extra`, đặc biệt tình huống có/không có `Using filesort`.

### 6.4. So sánh

```sql
CREATE INDEX idx_orders_status_date_asc
ON orders (status, orderDate);
```

và:

```sql
CREATE INDEX idx_orders_status_date_desc
ON orders (status ASC, orderDate DESC);
```

Thử:

```sql
EXPLAIN
SELECT orderNumber, orderDate
FROM orders
WHERE status = 'Shipped'
ORDER BY orderDate DESC;
```

Data nhỏ có thể khiến difference không rõ (đặc biệt khi `'Shipped'` chiếm 303/326 dòng của `orders`). Mục tiêu là đọc plan và hiểu index order.

### Bài tập thực hành

**Bài 6.1.** Tạo `idx_orders_status_date_desc` trên `orders(status ASC, orderDate DESC)`.

**Bài 6.2.** Chạy `EXPLAIN` cho query `WHERE status = 'Shipped' ORDER BY orderDate DESC`.

**Bài 6.3.** Tạo index `(status, orderDate)` (`idx_orders_status_date_asc`) và so sánh metadata với index DESC.

**Bài 6.4.** Nêu một query có mixed order mà descending composite index có thể hỗ trợ.

**Bài 6.5.** Giải thích vì sao không nên tạo index DESC cho mọi cột chỉ vì ứng dụng có `ORDER BY ... DESC`.

---

## 7. Composite indexes và leftmost-prefix principle

### 7.1. Composite index

```sql
CREATE INDEX idx_customers_country_credit
ON customers (country, creditLimit);
```

Index có thứ tự:

```text
country → creditLimit
```

Nó có thể phù hợp với:

```sql
WHERE country = 'USA'
```

và:

```sql
WHERE country = 'USA'
  AND creditLimit >= 50000.00
```

Nhưng thường không phải lựa chọn trực tiếp tốt cho:

```sql
WHERE creditLimit >= 50000.00
```

vì query bỏ qua leftmost key part `country`.

### 7.2. Thứ tự key parts

Khi chọn `(a, b, c)`, phải dựa vào query patterns, không chỉ dựa vào “cardinality cao nhất trước”.

Các câu hỏi cần trả lời:

1. Cột nào xuất hiện trong equality conditions?
2. Cột nào dùng range?
3. Cột nào dùng để sort/group sau khi filter?
4. Query nào quan trọng nhất?
5. Có index đã tồn tại hỗ trợ leftmost prefix không?
6. Write workload có chấp nhận thêm index không?

### 7.3. Ví dụ trên `orders`

Query:

```sql
SELECT orderNumber, orderDate, status
FROM orders
WHERE customerNumber = 103
  AND orderDate BETWEEN '2004-01-01' AND '2004-12-31'
ORDER BY orderDate DESC;
```

Index ứng viên:

```sql
CREATE INDEX idx_orders_customer_date
ON orders (customerNumber, orderDate);
```

`customerNumber` equality trước; `orderDate` range/sort tiếp theo.

### 7.4. Composite index không thay thế hoàn toàn mọi index đơn

Một index `(a, b)` có thể hỗ trợ queries dùng `a`, nhưng không tự động thay thế index đơn `b` nếu workload thường lọc chỉ `b`.

Cần kiểm tra usage thực tế trước khi xóa index.

### Bài tập thực hành

**Bài 7.1.** Tạo `idx_customers_country_credit` trên `customers(country, creditLimit)`.

**Bài 7.2.** Viết query sử dụng cả `country` và `creditLimit`.

**Bài 7.3.** Viết query chỉ dùng leftmost key part `country`.

**Bài 7.4.** Viết query chỉ dùng `creditLimit`, rồi giải thích hạn chế của index `(country, creditLimit)`.

**Bài 7.5.** Đề xuất composite index cho query theo `customerNumber` và `orderDate` trên `orders`.

---

## 8. Clustered indexes trong InnoDB

### 8.1. Clustered index là gì?

Mỗi InnoDB table có clustered index chứa row data. Thông thường, primary key là clustered index.

Trong `classicmodels`:
- `customers`: `PRIMARY KEY(customerNumber)` là clustered index.
- `orders`: `PRIMARY KEY(orderNumber)` là clustered index.
- `products`: `PRIMARY KEY(productCode)` là clustered index.

### 8.2. Nếu không có primary key

InnoDB chọn theo thứ tự:

1. Primary key được khai báo.
2. Unique index đầu tiên với toàn bộ key columns `NOT NULL`.
3. Nếu không có hai loại trên, InnoDB sinh hidden clustered index (`GEN_CLUST_INDEX`) trên synthetic 6-byte row ID.

Do đó, nên thiết kế primary key rõ ràng cho mỗi InnoDB table.

### 8.3. Secondary index liên hệ clustered index

Trong InnoDB, record của secondary index chứa:

- Secondary key columns.
- Primary key columns của row.

Ví dụ trên `products`, vì khóa chính là `productCode VARCHAR(15)` (dài hơn `INT 4 byte` của `customerNumber`), mỗi secondary index record trên `products` phải lưu thêm chuỗi `productCode`. Primary key dài làm secondary indexes lớn hơn; primary key ngắn, ổn định thường có lợi cho storage của secondary indexes.

### 8.4. Không nhầm clustered index với “index sorted mọi cách”

InnoDB table chỉ có một clustered index. Row data được tổ chức theo clustered key, không có nghĩa table được tối ưu đồng thời cho mọi `ORDER BY`.

### Bài tập thực hành

**Bài 8.1.** Xác định clustered index của `customers` trong `classicmodels`.

**Bài 8.2.** Nêu thứ tự InnoDB chọn clustered index khi table không khai báo primary key.

**Bài 8.3.** Giải thích vì sao long primary key làm secondary indexes lớn hơn.

**Bài 8.4.** Nêu lý do một table InnoDB nên có explicit primary key.

**Bài 8.5.** Giải thích vì sao table chỉ có một clustered index.

---

## 9. Index cardinality

### 9.1. Khái niệm

Cardinality là ước lượng mức độ distinct của giá trị trong index key.

Ví dụ trên bảng `orders` (326 dòng):

- `orderNumber` (PK) là duy nhất → cardinality = 326.
- `customerNumber` (98 khách hàng khác nhau có đơn hàng) → cardinality trung bình.
- `status` chỉ có 6 trạng thái (`Shipped`, `Cancelled`, `Resolved`, `On Hold`, `Disputed`, `In Process`) → cardinality rất thấp.

Xem cardinality:

```sql
SHOW INDEX FROM orders;
```

Hoặc:

```sql
SELECT INDEX_NAME,
       SEQ_IN_INDEX,
       COLUMN_NAME,
       CARDINALITY
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_SCHEMA = 'classicmodels'
  AND TABLE_NAME = 'orders'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;
```

### 9.2. Cardinality là estimate

Cardinality từ metadata là statistic do server duy trì; không coi đó là số distinct chính xác trong mọi thời điểm.

So sánh:

```sql
SELECT COUNT(DISTINCT customerNumber) AS distinctCustomers
FROM orders;
```

với `Cardinality` của index trên `customerNumber`.

### 9.3. Cardinality không phải quy tắc duy nhất

High cardinality thường có thể hữu ích cho selective lookup, nhưng index design còn phụ thuộc:

- Query predicates.
- Composite key order.
- Row distribution.
- Range conditions.
- Table size.
- Write workload.
- Covering potential.
- Optimizer estimates.

### Bài tập thực hành

**Bài 9.1.** Dùng `SHOW INDEX` xem cardinality của `orders`.

**Bài 9.2.** Đếm `COUNT(DISTINCT customerNumber)` trong `orders`.

**Bài 9.3.** So sánh cardinality của primary key `orderNumber` và cột `status`.

**Bài 9.4.** Nêu lý do cardinality metadata có thể khác `COUNT(DISTINCT ...)`.

**Bài 9.5.** Giải thích vì sao high cardinality không tự động bảo đảm index là đúng cho mọi query.

---

## 10. Functional indexes

### 10.1. Khi expression ngăn index thường được dùng

Giả sử có index thường trên `orders`:

```sql
CREATE INDEX idx_orders_date
ON orders (orderDate);
```

Query sau áp dụng function lên cột:

```sql
SELECT COUNT(*)
FROM orders
WHERE YEAR(orderDate) = 2004;
```

Index `idx_orders_date` không nhất thiết được dùng theo cách tối ưu cho expression `YEAR(orderDate)`.

Trước hết, hãy cân nhắc rewrite query theo range:

```sql
SELECT COUNT(*)
FROM orders
WHERE orderDate >= '2004-01-01'
  AND orderDate < '2005-01-01';
```

Range predicate thường đơn giản và tận dụng index thường trên `orderDate`.

### 10.2. Tạo functional index

Khi query expression thực sự cần thiết và version hỗ trợ (MySQL 8.0.13+), tạo index trên expression:

```sql
CREATE INDEX idx_orders_year
ON orders ((YEAR(orderDate)));
```

**Dấu ngoặc kép** quanh expression là bắt buộc:

```sql
((YEAR(orderDate)))
```

Không viết:

```sql
(YEAR(orderDate))
```

như cách khai báo column index thông thường.

### 10.3. Kiểm tra

```sql
EXPLAIN
SELECT COUNT(*)
FROM orders
WHERE YEAR(orderDate) = 2004;
```

### 10.4. Những giới hạn quan trọng

Functional key parts:

- Không thể chỉ là một column name được bọc thêm parentheses.
- Không được dùng làm foreign key key part.
- Có các restrictions tương tự generated columns.
- Không cho phép subquery, parameters, variables, stored functions hoặc loadable functions trong expression.
- Không dùng prefix length trực tiếp trên functional key part.
- Không dùng cho primary key; unique functional index được hỗ trợ trong trường hợp phù hợp.

Functional index được hiện thực qua hidden virtual generated columns, vì vậy nó vẫn chiếm storage cho index và cần được thiết kế có mục đích.

### Bài tập thực hành

**Bài 10.1.** Tạo normal index `idx_orders_date` trên `orders(orderDate)`.

**Bài 10.2.** Dùng `EXPLAIN` cho `WHERE YEAR(orderDate) = 2004` trên `orders`.

**Bài 10.3.** Viết query range thay cho `YEAR(orderDate) = 2004`.

**Bài 10.4.** Tạo functional index `idx_orders_year` trên `orders ((YEAR(orderDate)))` nếu server hỗ trợ.

**Bài 10.5.** Giải thích vì sao functional index không phải lựa chọn đầu tiên nếu query có thể rewrite thành range condition đơn giản.

---

## 11. Chọn loại index: bảng quyết định

| Nhu cầu | Index/giải pháp cần xem xét |
|---|---|
| Business key bắt buộc distinct | Unique index |
| Chuỗi dài, search prefix | Prefix index |
| Thử tác động bỏ index | Invisible index |
| `ORDER BY` mixed ASC/DESC | Descending composite index |
| Lọc/join nhiều cột theo pattern cố định | Composite index |
| Lookup theo biểu thức lặp lại | Functional index hoặc query rewrite |
| Table InnoDB chưa có PK | Thiết kế explicit primary key |
| Query plan nghi do statistics cũ | `ANALYZE TABLE`, sau đó `EXPLAIN` |
| Leading wildcard text search | Không dùng prefix B-tree như giải pháp chính; xem Full-Text Search |

### Bài tập thực hành

**Bài 11.1.** Chọn index phù hợp để đảm bảo `customerName` trên `customers` là duy nhất.

**Bài 11.2.** Chọn index phù hợp cho `WHERE customerNumber = ? ORDER BY orderDate DESC` trên `orders`.

**Bài 11.3.** Chọn phương án phù hợp khi cần thử drop index nhưng muốn rollback nhanh.

**Bài 11.4.** Chọn phương án đầu tiên cho `WHERE YEAR(orderDate) = 2004`: query rewrite hay functional index? Giải thích.

**Bài 11.5.** Nêu trường hợp prefix index phù hợp và không phù hợp.

---

## 12. Bài tập tổng hợp

### Bài 12.1. Unique + prefix

1. Tạo `uq_customers_name` trên `customers(customerName)`.
2. Tạo `idx_products_name_prefix` trên `products(productName(12))`.
3. Dùng `SHOW INDEX` so sánh `Non_unique` và `Sub_part`.
4. Thử duplicate `customerName`.
5. Giải thích vì sao hai loại index này có mục tiêu khác nhau.

### Bài 12.2. Composite + descending

1. Tạo index `(status ASC, orderDate DESC)` trên `orders`.
2. Chạy query lọc `status` và sort `orderDate DESC`.
3. Dùng `EXPLAIN`.
4. Tạo index `(status ASC, orderDate ASC)` để so sánh metadata.
5. Xóa index không cần cho lab.

### Bài 12.3. Cardinality

1. Xem `SHOW INDEX FROM orders`.
2. So sánh cardinality `customerNumber`, `status`, `orderNumber`.
3. Chạy `COUNT(DISTINCT ...)` tương ứng.
4. Chạy `ANALYZE TABLE orders`.
5. Nêu nhận xét về estimate và selectivity.

### Bài 12.4. Functional index

1. Tạo normal index `orderDate` trên `orders`.
2. So sánh `YEAR(orderDate)=2004` với date range.
3. Dùng `EXPLAIN`.
4. Tạo functional index `((YEAR(orderDate)))` nếu server hỗ trợ.
5. Nêu trường hợp nên tránh functional index.

### Bài 12.5. InnoDB design review

1. Xác định primary key của ba table `customers`, `orders`, `products`.
2. Nêu clustered index của từng table.
3. Liệt kê secondary indexes.
4. Nêu ảnh hưởng của primary key dài (như `VARCHAR(15)` so với `INT`) tới secondary index.
5. Viết một khuyến nghị primary-key design cho bảng transaction lớn.

---

## 13. Đáp án gợi ý

### Bài 4.1

```sql
CREATE INDEX idx_products_name_prefix
ON products (productName(12));
```

### Bài 5.2

```sql
ALTER TABLE customers
ALTER INDEX idx_customers_country INVISIBLE;
```

### Bài 6.1

```sql
CREATE INDEX idx_orders_status_date_desc
ON orders (status ASC, orderDate DESC);
```

### Bài 7.5

```sql
CREATE INDEX idx_orders_customer_date
ON orders (customerNumber, orderDate);
```

### Bài 9.2

```sql
SELECT COUNT(DISTINCT customerNumber) AS distinctCustomers
FROM orders;
```

### Bài 10.3

```sql
SELECT COUNT(*)
FROM orders
WHERE orderDate >= '2004-01-01'
  AND orderDate < '2005-01-01';
```

### Bài 10.4

```sql
CREATE INDEX idx_orders_year
ON orders ((YEAR(orderDate)));
```

### Cleanup

```sql
DROP INDEX IF EXISTS uq_customers_name
ON customers;

DROP INDEX IF EXISTS idx_customers_country
ON customers;

DROP INDEX IF EXISTS idx_customers_country_credit
ON customers;

DROP INDEX IF EXISTS idx_products_name_prefix
ON products;

DROP INDEX IF EXISTS idx_orders_status_date_desc
ON orders;

DROP INDEX IF EXISTS idx_orders_status_date_asc
ON orders;

DROP INDEX IF EXISTS idx_orders_customer_date
ON orders;

DROP INDEX IF EXISTS idx_orders_date
ON orders;

DROP INDEX IF EXISTS idx_orders_year
ON orders;
```

---

## 14. Tóm tắt

- Unique index bảo vệ distinctness; primary key là identity chính của row.
- Prefix index giảm kích thước index bằng cách index prefix của string, nhưng có thể giảm selectivity.
- Invisible index giúp kiểm thử việc bỏ index mà chưa drop nó; index vẫn được maintain.
- Descending key parts hữu ích đặc biệt cho mixed ASC/DESC order trong InnoDB.
- Composite index phụ thuộc mạnh vào thứ tự key parts và leftmost-prefix principle.
- InnoDB dùng primary key làm clustered index; secondary index records chứa primary-key columns.
- Cardinality là estimate về distinctness, không phải số chính xác tuyệt đối.
- Functional index cần double parentheses và chỉ nên dùng khi expression thật sự cần thiết sau khi cân nhắc query rewrite.
- Index strategy luôn phải dựa vào query patterns, data distribution, `EXPLAIN` và write cost.

---

## 15. Từ khóa chính

- Unique index
- Prefix index
- Invisible index
- Descending index
- Composite index
- Leftmost-prefix principle
- Clustered index
- Secondary index
- InnoDB
- Cardinality
- Selectivity
- Functional index
- Functional key part
- Generated column
- EXPLAIN
- ANALYZE TABLE
- Query rewrite
- classicmodels
