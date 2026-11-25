---
title: "Tutorial 3: MySQL Index Hints — USE INDEX và FORCE INDEX"
author: "Tên giảng viên"
duration: "150m"
difficulty: "Advanced"
prerequisites:
  - "Đã học tạo/quản lý index, composite index và EXPLAIN trên classicmodels"
  - "Đã cài đặt cơ sở dữ liệu mẫu classicmodels"
  - "Hiểu rằng index hints cần được kiểm chứng bằng execution plan và benchmark"
summary: "Dùng EXPLAIN để phân tích lựa chọn index của optimizer trên classicmodels; thực hành USE INDEX, FORCE INDEX và phạm vi FOR JOIN/ORDER BY/GROUP BY; học cách ưu tiên sửa statistics, query hoặc index design trước khi ép optimizer."
---

# Tutorial 3: MySQL Index Hints — `USE INDEX` và `FORCE INDEX`

## Link tham khảo

- [MySQL Tutorial — USE INDEX](https://www.mysqltutorial.org/mysql-index/mysql-use-index/)
- [MySQL Tutorial — FORCE INDEX](https://www.mysqltutorial.org/mysql-index/mysql-force-index/)
- [MySQL 8.4 Reference Manual — Index Hints](https://dev.mysql.com/doc/refman/8.4/en/index-hints.html)
- [MySQL 8.4 Reference Manual — EXPLAIN Statement](https://dev.mysql.com/doc/refman/8.4/en/explain.html)
- [MySQL 8.4 Reference Manual — Optimization and Indexes](https://dev.mysql.com/doc/refman/8.4/en/optimization-indexes.html)
- [MySQL 8.4 Reference Manual — Index Statistics](https://dev.mysql.com/doc/refman/8.4/en/index-statistics.html)

> **Quan trọng:** `USE INDEX` và `FORCE INDEX` là công cụ kiểm soát optimizer theo cú pháp index hints. Trong MySQL 8.4, tài liệu chính thức nêu rằng index-level optimizer hints như `INDEX`, `JOIN_INDEX`, `ORDER_INDEX`, `GROUP_INDEX` được dự định thay thế các hint `FORCE INDEX`/`IGNORE INDEX`; đồng thời `USE INDEX`, `FORCE INDEX`, `IGNORE INDEX` có thể bị deprecated trong tương lai. Bài này vẫn dạy `USE INDEX` và `FORCE INDEX` vì chúng phổ biến trong code hiện có và là nội dung của section tham khảo, nhưng chỉ nên dùng sau khi có bằng chứng từ `EXPLAIN` và benchmark.

## 1. Mục tiêu học tập

Sau khi hoàn thành tutorial này, người học có thể:

1. Dùng `EXPLAIN` để nhận biết optimizer có thể/chọn index nào trên các bảng `classicmodels`.
2. Giải thích `possible_keys`, `key`, `rows`, `filtered`, `Extra` ở mức thực hành.
3. Dùng `USE INDEX` để giới hạn danh sách index optimizer được cân nhắc.
4. Dùng `FORCE INDEX` để làm table scan trở thành lựa chọn rất đắt trong cost model.
5. Dùng `FOR JOIN`, `FOR ORDER BY`, `FOR GROUP BY` để giới hạn scope của index hint.
6. Phân biệt `USE INDEX` với `FORCE INDEX`.
7. Nhận biết index hint không thay thế index design tốt.
8. Kiểm tra stats bằng `ANALYZE TABLE`.
9. So sánh hint với các phương án tốt hơn: query rewrite, composite index, cập nhật statistics, optimizer hints hiện đại.
10. Áp dụng quy trình benchmark trước khi giữ hint trong application code.

---

## 2. Nguyên tắc trước khi dùng index hint

Không bắt đầu bằng:

```text
Optimizer chưa dùng index mình muốn → FORCE INDEX ngay.
```

Quy trình tốt hơn:

```text
1. Xác định query quan trọng và dữ liệu thực tế.
2. Chạy EXPLAIN / EXPLAIN ANALYZE trên môi trường an toàn.
3. Kiểm tra predicate, join, ORDER BY, GROUP BY.
4. Kiểm tra index definition và leftmost-prefix.
5. Kiểm tra cardinality/statistics; cân nhắc ANALYZE TABLE.
6. Viết/rewrite query theo dạng index-friendly.
7. Tạo hoặc sửa index nếu workload chứng minh cần thiết.
8. Chỉ sau đó mới thử USE INDEX/FORCE INDEX như một controlled experiment.
9. Benchmark trước/sau, kiểm tra nhiều input distributions.
10. Ghi chú lý do và review hint định kỳ.
```

### 2.1. Vì sao optimizer có thể không chọn index?

| Nguyên nhân | Ví dụ trên `classicmodels` |
|---|---|
| Table nhỏ | Table scan trên `orders` (326 dòng) đôi khi rẻ hơn index lookup |
| Predicate không selective | `WHERE status = 'Shipped'` trả về 303/326 dòng |
| Index không khớp query | Index `(status, orderDate)` nhưng query chỉ filter `orderDate` |
| Function trên indexed column | `YEAR(orderDate) = 2004` với normal index `orderDate` |
| Statistics chưa phù hợp | Data thay đổi nhiều mà chưa cập nhật statistics |
| Query cần nhiều row | Index lookup + row lookup đắt hơn full scan |
| Có index tốt hơn | Optimizer chọn index khác đúng hơn dự kiến |

### 2.2. EXPLAIN trước, hint sau

Ví dụ trên bảng `orders`:

```sql
EXPLAIN
SELECT orderNumber, customerNumber, orderDate, status
FROM orders
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01';
```

Nếu `key` hiển thị `idx_orders_customer_date`, đó thường là dấu hiệu tốt.

Nếu `key` là `NULL`, không vội kết luận lỗi. Hãy xem `rows`, table size và predicate.

### Bài tập thực hành

**Bài 2.1.** Liệt kê sáu bước cần làm trước khi dùng `FORCE INDEX`.

**Bài 2.2.** Nêu ba lý do optimizer có thể chọn table scan.

**Bài 2.3.** Nêu một tình huống nên rewrite query thay vì thêm hint.

**Bài 2.4.** Giải thích vì sao benchmark cần dùng nhiều input values.

**Bài 2.5.** Nêu một rủi ro khi giữ index hint cố định trong code lâu dài.

---

## 3. Chuẩn bị index trên `classicmodels` cho lab hints

Dọn dẹp nếu các index thử nghiệm đã tồn tại trước đó, sau đó tạo bộ indexes trên bảng `orders` của `classicmodels`:

```sql
DROP INDEX IF EXISTS idx_orders_customer
ON orders;

DROP INDEX IF EXISTS idx_orders_status
ON orders;

DROP INDEX IF EXISTS idx_orders_customer_date
ON orders;

DROP INDEX IF EXISTS idx_orders_status_date
ON orders;
```

```sql
CREATE INDEX idx_orders_customer
ON orders (customerNumber);

CREATE INDEX idx_orders_status
ON orders (status);

CREATE INDEX idx_orders_customer_date
ON orders (customerNumber, orderDate);

CREATE INDEX idx_orders_status_date
ON orders (status, orderDate);
```

Kiểm tra:

```sql
SHOW INDEX FROM orders;
```

Làm mới statistics trong `classicmodels`:

```sql
ANALYZE TABLE orders;
```

> Trong bảng nhỏ như `classicmodels.orders` (326 dòng), query plan có thể không thể hiện rõ tất cả khác biệt. Hãy xem các examples như bài thực hành về syntax và plan interpretation, không coi một kết quả trên sample table là kết luận performance production.

### Bài tập thực hành

**Bài 3.1.** Tạo `idx_orders_customer` trên `orders(customerNumber)`.

**Bài 3.2.** Tạo `idx_orders_status` trên `orders(status)`.

**Bài 3.3.** Tạo `idx_orders_customer_date` trên `orders(customerNumber, orderDate)`.

**Bài 3.4.** Tạo `idx_orders_status_date` trên `orders(status, orderDate)`.

**Bài 3.5.** Chạy `SHOW INDEX FROM orders` và `ANALYZE TABLE orders`.

---

## 4. Đọc EXPLAIN trước khi dùng hint

### 4.1. Query không hint

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01'
ORDER BY orderDate;
```

### 4.2. Cột cần quan sát

| Cột | Câu hỏi cần đặt |
|---|---|
| `possible_keys` | Optimizer biết các index nào có thể liên quan? |
| `key` | Index nào được chọn thật? |
| `key_len` | Bao nhiêu bytes/key parts có thể được dùng? |
| `ref` | Giá trị/column nào so sánh với index? |
| `rows` | Ước lượng phải xét bao nhiêu rows? |
| `filtered` | Ước lượng tỷ lệ rows qua filter? |
| `Extra` | Có `Using where`, `Using index`, `Using filesort`, ... không? |

Ví dụ lý tưởng trong query trên có thể là optimizer chọn:

```text
idx_orders_customer_date
```

vì index khớp:

```text
customerNumber → orderDate
```

### 4.3. `EXPLAIN ANALYZE`

Trên MySQL version hỗ trợ (8.0.18+), có thể dùng:

```sql
EXPLAIN ANALYZE
SELECT orderNumber, orderDate, status
FROM orders
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01'
ORDER BY orderDate;
```

`EXPLAIN ANALYZE` thực thi query và báo actual timing/rows. Vì nó thực thi query, chỉ dùng với query an toàn và trên môi trường phù hợp. Không dùng tùy tiện với DML hoặc query tốn tài nguyên trên production.

### 4.4. So sánh plan có cấu trúc

Khi thử hint, so sánh:

1. Query text.
2. Schema/indexes.
3. Data size/distribution.
4. `EXPLAIN` output.
5. Actual rows/timing nếu đo an toàn.
6. Nhiều parameter values (ví dụ `customerNumber = 103` có 3 đơn vs `customerNumber = 141` có 26 đơn).
7. Read/write impact nếu tạo index mới.

### Bài tập thực hành

**Bài 4.1.** Chạy `EXPLAIN` cho query theo `customerNumber` + `orderDate` trên `orders`.

**Bài 4.2.** Xác định `possible_keys` và `key`.

**Bài 4.3.** Tìm xem `Extra` có `Using filesort` hay không.

**Bài 4.4.** Chạy `EXPLAIN ANALYZE` nếu server hỗ trợ và query an toàn.

**Bài 4.5.** Giải thích vì sao `EXPLAIN ANALYZE` cần thận trọng hơn `EXPLAIN`.

---

## 5. `USE INDEX`

### 5.1. Cú pháp

```sql
SELECT ...
FROM table_name USE INDEX (index_name [, index_name] ...)
WHERE ...;
```

Ví dụ:

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders USE INDEX (idx_orders_customer_date)
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01'
ORDER BY orderDate;
```

`USE INDEX` giới hạn optimizer ở danh sách named indexes để tìm rows trong table đó. Nó không đơn giản đồng nghĩa “bắt buộc dùng đúng một index đó theo mọi cách”; optimizer vẫn lập plan trong phạm vi các index được cho phép.

### 5.2. Index name, không phải column name

Đúng:

```sql
USE INDEX (idx_orders_customer_date)
```

Sai:

```sql
USE INDEX (customerNumber, orderDate)
```

Muốn biết index names:

```sql
SHOW INDEX FROM orders;
```

Primary key được gọi là:

```text
PRIMARY
```

Ví dụ:

```sql
SELECT *
FROM orders USE INDEX (PRIMARY)
WHERE orderNumber = 10100;
```

### 5.3. Multiple indexes

```sql
EXPLAIN
SELECT orderNumber, customerNumber, orderDate, status
FROM orders USE INDEX (
    idx_orders_customer,
    idx_orders_customer_date
)
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01';
```

Sau `USE INDEX`, `possible_keys` thường chỉ phản ánh tập index được khuyến nghị/cho phép này.

### 5.4. `USE INDEX ()`

Cú pháp:

```sql
USE INDEX ()
```

có nghĩa không dùng index cho row lookup. Đây là công cụ thử nghiệm/diagnostic, không phải default application design.

```sql
EXPLAIN
SELECT *
FROM orders USE INDEX ()
WHERE customerNumber = 103;
```

### 5.5. Scope của `USE INDEX`

```sql
USE INDEX FOR JOIN (idx_orders_customer_date)
```

```sql
USE INDEX FOR ORDER BY (idx_orders_status_date)
```

```sql
USE INDEX FOR GROUP BY (idx_orders_status)
```

Nếu không ghi `FOR`, hint áp dụng cho toàn bộ scope liên quan của statement.

### Bài tập thực hành

**Bài 5.1.** Viết query dùng `USE INDEX (idx_orders_customer_date)` trên `orders`.

**Bài 5.2.** Sửa query sai dùng `USE INDEX(customerNumber)` thành index name đúng (`idx_orders_customer`).

**Bài 5.3.** Dùng `SHOW INDEX` trên `orders` để xác định primary key name.

**Bài 5.4.** Viết `EXPLAIN` query dùng `USE INDEX ()` trên `orders`.

**Bài 5.5.** Viết một `USE INDEX FOR ORDER BY` example cho index `idx_orders_status_date`.

---

## 6. `FORCE INDEX`

### 6.1. Cú pháp

```sql
SELECT ...
FROM table_name FORCE INDEX (index_name [, index_name] ...)
WHERE ...;
```

Ví dụ:

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders FORCE INDEX (idx_orders_customer_date)
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01'
ORDER BY orderDate;
```

### 6.2. Khác với `USE INDEX`

| Hint | Ý nghĩa khái quát |
|---|---|
| `USE INDEX` | Optimizer chỉ cân nhắc danh sách named indexes để tìm rows |
| `FORCE INDEX` | Tương tự `USE INDEX`, nhưng table scan được coi là rất đắt; scan chỉ dùng khi không có cách dùng index được chỉ định để tìm rows |

`FORCE INDEX` mạnh hơn và có nguy cơ “đóng băng” một choice có thể trở nên tệ khi:

- Data distribution đổi.
- Table lớn lên.
- MySQL upgrade.
- Query parameter distribution đổi.
- Index khác tốt hơn được thêm.
- Statistics được cập nhật.

### 6.3. Khi nào thử FORCE INDEX?

Chỉ thử sau khi:

- `EXPLAIN` cho thấy optimizer chọn plan không hợp lý.
- Statistics đã được xem xét/refresh.
- Index design đã kiểm tra.
- Có benchmark representative.
- Có bằng chứng hint ổn định tốt hơn cho workload thật.

### 6.4. Không dùng FORCE INDEX để che index design sai

Ví dụ table có query:

```sql
WHERE customerNumber = ?
  AND orderDate >= ?
```

Nếu chỉ có index `(status, orderDate)`, `FORCE INDEX(idx_orders_status_date)` không biến nó thành index tốt cho predicate trên customer.

Cách đúng hơn có thể là:

```sql
CREATE INDEX idx_orders_customer_date
ON orders (customerNumber, orderDate);
```

### Bài tập thực hành

**Bài 6.1.** Viết query dùng `FORCE INDEX (idx_orders_customer_date)` trên `orders`.

**Bài 6.2.** So sánh `EXPLAIN` của query không hint, `USE INDEX`, `FORCE INDEX`.

**Bài 6.3.** Nêu một rủi ro của `FORCE INDEX` khi data distribution thay đổi.

**Bài 6.4.** Nêu một trường hợp cần tạo/sửa index thay vì force index.

**Bài 6.5.** Giải thích “table scan được coi là rất đắt” trong `FORCE INDEX`.

---

## 7. Scope: `FOR JOIN`, `FOR ORDER BY`, `FOR GROUP BY`

### 7.1. `FOR JOIN`

Tên này liên quan pha row lookup/join planning, không chỉ có nghĩa query phải viết `JOIN`.

```sql
EXPLAIN
SELECT orderNumber, orderDate
FROM orders
USE INDEX FOR JOIN (idx_orders_customer_date)
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01';
```

### 7.2. `FOR ORDER BY`

```sql
EXPLAIN
SELECT orderNumber, status, orderDate
FROM orders
USE INDEX FOR ORDER BY (idx_orders_status_date)
ORDER BY status, orderDate;
```

Hãy kiểm tra output; hint không đảm bảo index đó giải quyết mọi `ORDER BY` nếu query có predicates/join/expressions làm index order không còn phù hợp.

### 7.3. `FOR GROUP BY`

```sql
EXPLAIN
SELECT status, COUNT(*) AS totalOrders
FROM orders
USE INDEX FOR GROUP BY (idx_orders_status)
GROUP BY status;
```

### 7.4. Không kết hợp USE và FORCE cùng scope

Không được trộn `USE INDEX` và `FORCE INDEX` cho cùng table/cùng scope tương ứng.

Ví dụ sai:

```sql
SELECT *
FROM orders
USE INDEX FOR JOIN (idx_orders_customer)
FORCE INDEX FOR JOIN (idx_orders_customer_date)
WHERE customerNumber = 103;
```

### Bài tập thực hành

**Bài 7.1.** Viết `USE INDEX FOR JOIN` cho query customer/date trên `orders`.

**Bài 7.2.** Viết `USE INDEX FOR ORDER BY` cho query theo `status, orderDate`.

**Bài 7.3.** Viết `USE INDEX FOR GROUP BY` cho `GROUP BY status`.

**Bài 7.4.** Giải thích scope `FOR JOIN` không chỉ dành cho statement có từ khóa JOIN.

**Bài 7.5.** Sửa ví dụ trộn `USE INDEX` và `FORCE INDEX` cùng scope.

---

## 8. `IGNORE INDEX` trong vai trò kiểm thử

Dù không phải trọng tâm section, `IGNORE INDEX` rất hữu ích khi muốn loại một index khỏi consideration để so sánh plan.

```sql
EXPLAIN
SELECT orderNumber, orderDate
FROM orders IGNORE INDEX (idx_orders_customer_date)
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01';
```

Dùng `IGNORE INDEX` để:

- Test giả thuyết về một index.
- So sánh plan.
- Kiểm tra index redundancy.

Không dùng `IGNORE INDEX` như công cụ “sửa nhanh” cho query mà chưa hiểu vì sao optimizer chọn index đó.

### Bài tập thực hành

**Bài 8.1.** Chạy `EXPLAIN` query customer/date không hint trên `orders`.

**Bài 8.2.** Chạy lại query với `IGNORE INDEX (idx_orders_customer_date)`.

**Bài 8.3.** So sánh `possible_keys`, `key`, `rows`, `Extra`.

**Bài 8.4.** Nêu một lý do dùng `IGNORE INDEX` trong lab.

**Bài 8.5.** Nêu một lý do không nên giữ `IGNORE INDEX` lâu dài mà không có benchmark.

---

## 9. Hints hiện đại và tính tương lai của code

Tài liệu MySQL 8.4 nêu các index-level optimizer hints trong comment syntax có vai trò thay thế cho một số index hints cũ.

Ví dụ minh họa:

```sql
EXPLAIN
SELECT /*+ INDEX(o idx_orders_customer_date) */
       o.orderNumber,
       o.orderDate
FROM orders AS o
WHERE o.customerNumber = 103
  AND o.orderDate >= '2004-01-01';
```

Các dạng liên quan có thể gồm:

```text
INDEX
JOIN_INDEX
ORDER_INDEX
GROUP_INDEX
NO_INDEX
NO_JOIN_INDEX
NO_ORDER_INDEX
NO_GROUP_INDEX
```

Trong bài này, mục tiêu chính vẫn là hiểu `USE INDEX` và `FORCE INDEX`. Khi viết code mới cho MySQL version hiện đại, cần đọc tài liệu đúng version và cân nhắc optimizer hints mới hơn.

### Bài tập thực hành

**Bài 9.1.** Viết `EXPLAIN` với comment optimizer hint `INDEX` trên `orders AS o`.

**Bài 9.2.** Nêu lý do nên đọc docs đúng version trước khi dùng hint.

**Bài 9.3.** Giải thích vì sao legacy index hint có thể trở thành technical debt.

**Bài 9.4.** Nêu điểm chung giữa `FORCE INDEX` và index-level optimizer hint.

**Bài 9.5.** Nêu điều kiện cần trước khi đưa bất kỳ hint nào vào application code.

---

## 10. Các cách cải thiện trước hints

### 10.1. Rewrite expression

Không tối ưu:

```sql
WHERE YEAR(orderDate) = 2004
```

Cân nhắc:

```sql
WHERE orderDate >= '2004-01-01'
  AND orderDate < '2005-01-01'
```

### 10.2. Tạo composite index đúng pattern

Không ép `(status, orderDate)` cho query theo customer:

```sql
WHERE customerNumber = ?
AND orderDate >= ?
```

Tạo index phù hợp:

```sql
(customerNumber, orderDate)
```

### 10.3. Cập nhật statistics

```sql
ANALYZE TABLE orders;
```

Sau đó chạy lại `EXPLAIN`.

### 10.4. Tránh select quá nhiều data

Query:

```sql
SELECT *
FROM orders
WHERE status = 'Shipped';
```

nếu trả phần lớn rows (303/326 dòng), index có thể không có nhiều lợi ích. Hãy:

- Chọn các columns cần thiết.
- Thêm selective predicates nếu đúng nghiệp vụ.
- Dùng pagination/keyset pagination khi phù hợp.
- Đo workload thật.

### 10.5. Thử invisible index để đánh giá drop

Nếu nghi một index không cần, có thể dùng invisible index thay vì drop ngay, rồi quan sát plan/performance trong môi trường test.

### Bài tập thực hành

**Bài 10.1.** Rewrite `YEAR(orderDate)=2004` thành range predicate trên `orders`.

**Bài 10.2.** Đề xuất index cho `customerNumber` + `orderDate` trên `orders`.

**Bài 10.3.** Chạy `ANALYZE TABLE orders`.

**Bài 10.4.** Nêu hai lý do `SELECT *` có thể làm đánh giá index khó hơn.

**Bài 10.5.** Giải thích khi nào invisible index phù hợp hơn drop index ngay.

---

## 11. Bài tập tổng hợp

### Bài 11.1. USE INDEX experiment

1. Chạy `EXPLAIN` query theo customer/date không hint.
2. Chạy lại với `USE INDEX (idx_orders_customer_date)`.
3. Chạy lại với `USE INDEX (idx_orders_customer)`.
4. So sánh `possible_keys`, `key`, `rows`.
5. Kết luận hint nào hợp lý hơn cho query đó và vì sao.

### Bài 11.2. FORCE INDEX experiment

1. Viết query theo status/date trên `orders`.
2. Chạy `EXPLAIN` không hint.
3. Chạy `EXPLAIN` với `FORCE INDEX (idx_orders_status_date)`.
4. So sánh plan.
5. Nêu lý do không áp dụng kết luận từ table nhỏ thẳng vào production.

### Bài 11.3. Scope hint

1. Viết query group theo status trên `orders`.
2. Dùng `USE INDEX FOR GROUP BY`.
3. Viết query sort theo status/date.
4. Dùng `USE INDEX FOR ORDER BY`.
5. Giải thích sự khác nhau giữa hai scope.

### Bài 11.4. Fix root cause

Query trên `orders`:

```sql
SELECT *
FROM orders
WHERE YEAR(orderDate) = 2004
  AND customerNumber = 103;
```

1. Viết range rewrite.
2. Đề xuất composite index.
3. Chạy `EXPLAIN`.
4. Chỉ sau đó thử hint nếu cần.
5. Viết nhận xét vì sao hint không phải bước đầu tiên.

### Bài 11.5. Hint review checklist

Lập checklist gồm:

1. Query pattern.
2. Index definitions.
3. Statistics.
4. EXPLAIN baseline.
5. Benchmark baseline.
6. Hint plan.
7. Benchmark hinted plan.
8. Version compatibility.
9. Monitoring after deployment.
10. Review/removal condition.

---

## 12. Đáp án gợi ý

### Bài 5.1

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders USE INDEX (idx_orders_customer_date)
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01'
ORDER BY orderDate;
```

### Bài 6.1

```sql
EXPLAIN
SELECT orderNumber, orderDate, status
FROM orders FORCE INDEX (idx_orders_customer_date)
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01'
ORDER BY orderDate;
```

### Bài 7.2

```sql
EXPLAIN
SELECT orderNumber, status, orderDate
FROM orders
USE INDEX FOR ORDER BY (idx_orders_status_date)
ORDER BY status, orderDate;
```

### Bài 7.3

```sql
EXPLAIN
SELECT status, COUNT(*) AS totalOrders
FROM orders
USE INDEX FOR GROUP BY (idx_orders_status)
GROUP BY status;
```

### Bài 8.2

```sql
EXPLAIN
SELECT orderNumber, orderDate
FROM orders IGNORE INDEX (idx_orders_customer_date)
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01';
```

### Bài 10.1

```sql
SELECT *
FROM orders
WHERE orderDate >= '2004-01-01'
  AND orderDate < '2005-01-01';
```

### Bài 11.4

```sql
CREATE INDEX idx_orders_customer_date
ON orders (customerNumber, orderDate);

EXPLAIN
SELECT *
FROM orders
WHERE customerNumber = 103
  AND orderDate >= '2004-01-01'
  AND orderDate < '2005-01-01';
```

### Cleanup

```sql
DROP INDEX IF EXISTS idx_orders_customer
ON orders;

DROP INDEX IF EXISTS idx_orders_status
ON orders;

DROP INDEX IF EXISTS idx_orders_customer_date
ON orders;

DROP INDEX IF EXISTS idx_orders_status_date
ON orders;
```

---

## 13. Tóm tắt

- Dùng `EXPLAIN` và statistics để hiểu optimizer trước khi áp hint.
- `USE INDEX` giới hạn tập index optimizer cân nhắc.
- `FORCE INDEX` làm table scan trở nên rất đắt, nên mạnh hơn và rủi ro hơn.
- Hints dùng index names, không dùng column names.
- `FOR JOIN`, `FOR ORDER BY`, `FOR GROUP BY` giới hạn scope của hint.
- `IGNORE INDEX` có ích cho kiểm thử plan/redundancy.
- Hints không sửa được composite index sai thứ tự, predicate không sargable hoặc statistics cũ.
- Ưu tiên query rewrite, index design và `ANALYZE TABLE` trước.
- Với MySQL 8.4, nên theo dõi index-level optimizer hints hiện đại vì các legacy hints có thể bị deprecated trong tương lai.
- Mọi quyết định hint cần benchmark, monitoring và review theo version/data growth.

---

## 14. Từ khóa chính

- Query optimizer
- Execution plan
- EXPLAIN
- EXPLAIN ANALYZE
- possible_keys
- key
- rows
- filtered
- Extra
- USE INDEX
- FORCE INDEX
- IGNORE INDEX
- FOR JOIN
- FOR ORDER BY
- FOR GROUP BY
- INDEX optimizer hint
- ANALYZE TABLE
- Cardinality
- Statistics
- Query rewrite
- Technical debt
- classicmodels
