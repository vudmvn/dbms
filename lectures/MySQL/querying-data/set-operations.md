---
title: "Tutorial: Các phép toán tập hợp UNION, EXCEPT và INTERSECT trong MySQL"
author: "Tên giảng viên"
duration: "120m"
difficulty: "Intermediate"
prerequisites:
    - "Đã biết SELECT, WHERE, DISTINCT, ORDER BY và LIMIT"
    - "Đã biết cách truy vấn các bảng customers, employees, offices, orders và payments trong classicmodels"
    - "Sử dụng MySQL 8.0.31 trở lên để hỗ trợ đầy đủ các phép toán EXCEPT và INTERSECT"
summary: "Thực hành UNION, UNION ALL, EXCEPT và INTERSECT để kết hợp, so sánh và tìm phần chung giữa các result set trên classicmodels."
---

# Tutorial: Các phép toán tập hợp `UNION`, `EXCEPT` và `INTERSECT` trong MySQL

## Link tham khảo

- [MySQL Tutorial — MySQL Basics: Set operators](https://www.mysqltutorial.org/mysql-basics/)
- [MySQL Tutorial — UNION](https://www.mysqltutorial.org/mysql-basics/mysql-union/)
- [MySQL Tutorial — EXCEPT](https://www.mysqltutorial.org/mysql-basics/mysql-except/)
- [MySQL Tutorial — INTERSECT](https://www.mysqltutorial.org/mysql-intersect/)
- [MySQL 8.4 Reference Manual — Set Operations](https://dev.mysql.com/doc/refman/8.4/en/set-operations.html)

## 1. Mục tiêu học tập

Sau khi hoàn thành tutorial này, người học có thể:

1. Giải thích được result set và ý nghĩa của phép toán tập hợp trong SQL.
2. Dùng `UNION` để gộp hai hoặc nhiều result set và loại bỏ dòng trùng.
3. Dùng `UNION ALL` để gộp result set nhưng giữ các dòng trùng.
4. Dùng `EXCEPT` để tìm các dòng xuất hiện ở tập thứ nhất nhưng không có ở tập thứ hai.
5. Dùng `INTERSECT` để tìm các dòng chung giữa hai result set.
6. Tuân thủ các quy tắc tương thích cột khi dùng set operators.
7. Dùng `ORDER BY`, `LIMIT` và dấu ngoặc đơn đúng vị trí.
8. Hiểu thứ tự ưu tiên giữa `INTERSECT`, `UNION` và `EXCEPT`.
9. Viết truy vấn trên cơ sở dữ liệu `classicmodels` bằng các phép toán tập hợp thuần túy.

---

## 2. Khái niệm phép toán tập hợp trong SQL

Mỗi câu lệnh `SELECT` trả về một **result set** — tập hợp các dòng kết quả.

Ví dụ:

```sql
SELECT country
FROM customers;
```

Các phép toán tập hợp kết hợp hoặc so sánh result set của nhiều truy vấn `SELECT`.

| Toán tử | Ý nghĩa |
|---|---|
| `UNION` | Hợp các result set và loại bỏ dòng trùng |
| `UNION ALL` | Hợp các result set và giữ tất cả dòng trùng |
| `EXCEPT` | Các dòng có ở result set thứ nhất nhưng không có ở result set thứ hai |
| `INTERSECT` | Các dòng xuất hiện trong cả hai result set |

Có thể hình dung:

```text
A UNION B       = các dòng thuộc A hoặc B
A UNION ALL B   = nối A với B, giữ mọi bản sao
A EXCEPT B      = các dòng thuộc A nhưng không thuộc B
A INTERSECT B   = các dòng thuộc đồng thời A và B
```

Ví dụ:

- Tập A: các quốc gia có khách hàng.
- Tập B: các quốc gia có văn phòng.
- `A UNION B`: quốc gia có khách hàng hoặc văn phòng.
- `A EXCEPT B`: quốc gia có khách hàng nhưng không có văn phòng.
- `A INTERSECT B`: quốc gia vừa có khách hàng vừa có văn phòng.

### Bài tập thực hành

**Bài 2.1.** Nêu ý nghĩa của `UNION`.

**Bài 2.2.** Nêu khác biệt chính giữa `UNION` và `UNION ALL`.

**Bài 2.3.** Diễn giải bằng lời ý nghĩa của `A EXCEPT B`.

**Bài 2.4.** Diễn giải bằng lời ý nghĩa của `A INTERSECT B`.

**Bài 2.5.** Trong `classicmodels`, nêu hai bảng có thể dùng để so sánh danh sách quốc gia.

---

## 3. Chuẩn bị môi trường

Chọn cơ sở dữ liệu:

```sql
USE classicmodels;
```

Xem một số bảng liên quan:

```sql
SHOW TABLES;
```

```sql
SELECT customerNumber, customerName, country
FROM customers
ORDER BY customerNumber
LIMIT 10;
```

```sql
SELECT officeCode, city, country, territory
FROM offices
ORDER BY officeCode;
```

```sql
SELECT employeeNumber, firstName, lastName, officeCode
FROM employees
ORDER BY employeeNumber
LIMIT 10;
```

```sql
SELECT customerNumber, checkNumber, paymentDate, amount
FROM payments
ORDER BY customerNumber
LIMIT 10;
```

Kiểm tra phiên bản MySQL:

```sql
SELECT VERSION();
```

> `UNION` và `UNION ALL` đã được MySQL hỗ trợ từ các phiên bản đầu. Các phép toán `EXCEPT` và `INTERSECT` được bổ sung và hỗ trợ chính thức từ MySQL 8.0.31.

### Bài tập thực hành

**Bài 3.1.** Viết lệnh chọn cơ sở dữ liệu `classicmodels`.

**Bài 3.2.** Viết truy vấn xem 10 khách hàng đầu tiên gồm `customerNumber`, `customerName`, `country`.

**Bài 3.3.** Viết truy vấn xem `officeCode`, `city`, `country` từ `offices`.

**Bài 3.4.** Viết truy vấn xem phiên bản MySQL đang sử dụng.

**Bài 3.5.** Kiểm tra server có phải MySQL 8.0.31 trở lên trước khi chạy `EXCEPT` và `INTERSECT`.

---

## 4. Quy tắc chung khi dùng set operators

### 4.1. Các query block phải có cùng số cột

Sai:

```sql
SELECT customerNumber, customerName
FROM customers

UNION

SELECT officeCode
FROM offices;
```

Đúng:

```sql
SELECT customerNumber, customerName
FROM customers

UNION

SELECT officeCode, city
FROM offices;
```

### 4.2. Cột ở cùng vị trí phải tương thích kiểu và ý nghĩa

```sql
SELECT customerNumber, customerName
FROM customers

UNION

SELECT employeeNumber, CONCAT(firstName, ' ', lastName)
FROM employees;
```

Cột thứ nhất ở cả hai query block là mã số; cột thứ hai là tên.

### 4.3. Tên cột kết quả thường lấy từ query block đầu tiên

```sql
SELECT customerNumber AS personNumber,
       customerName AS personName
FROM customers

UNION

SELECT employeeNumber,
       CONCAT(firstName, ' ', lastName)
FROM employees;
```

Kết quả dùng hai tên cột `personNumber` và `personName`.

### 4.4. Thứ tự cột phải thống nhất

Không nên viết:

```sql
SELECT customerNumber, customerName
FROM customers

UNION

SELECT CONCAT(firstName, ' ', lastName), employeeNumber
FROM employees;
```

Dù có cùng số cột, các cột không cùng ý nghĩa theo từng vị trí.

### Bài tập thực hành

**Bài 4.1.** Sửa truy vấn dưới đây để hai query block có cùng số cột.

```sql
SELECT customerNumber, customerName
FROM customers
UNION
SELECT officeCode
FROM offices;
```

**Bài 4.2.** Viết hai query block có cùng hai cột để kết hợp danh sách khách hàng và nhân viên.

**Bài 4.3.** Đặt alias `personNumber`, `personName` cho kết quả kết hợp ở Bài 4.2.

**Bài 4.4.** Giải thích vì sao thứ tự cột trong các query block phải thống nhất.

**Bài 4.5.** Viết truy vấn tập hợp gồm hai query block, mỗi query block trả về đúng một cột `country`.

---

# Phần A. `UNION` và `UNION ALL`

## 5. `UNION`: Hợp các result set và loại bỏ dòng trùng

`UNION` kết hợp các dòng của hai hoặc nhiều query block thành một result set và tự động loại bỏ các dòng trùng.

Cú pháp:

```sql
SELECT column_list
FROM table_1

UNION [DISTINCT]

SELECT column_list
FROM table_2;
```

`DISTINCT` là mặc định, vì vậy hai cách sau tương đương:

```sql
SELECT country
FROM customers
UNION
SELECT country
FROM offices;
```

```sql
SELECT country
FROM customers
UNION DISTINCT
SELECT country
FROM offices;
```

Ví dụ: lấy tất cả quốc gia có khách hàng hoặc văn phòng.

```sql
SELECT country
FROM customers

UNION

SELECT country
FROM offices
ORDER BY country;
```

Nếu `USA` xuất hiện nhiều lần ở `customers` và cũng xuất hiện ở `offices`, kết quả cuối chỉ có một dòng `USA`.

### Bài tập thực hành

**Bài 5.1.** Dùng `UNION` để lấy danh sách quốc gia xuất hiện trong `customers` hoặc `offices`.

**Bài 5.2.** Dùng `UNION` để lấy danh sách thành phố xuất hiện trong `customers` hoặc `offices`.

**Bài 5.3.** Dùng `UNION` để tạo danh sách mã gồm `customerNumber` và `employeeNumber`; đặt tên cột là `personNumber`.

**Bài 5.4.** Dùng `UNION` để tạo danh sách tên gồm khách hàng ở `USA` và nhân viên làm việc tại văn phòng ở `USA`.

**Bài 5.5.** Dùng `UNION` để lấy các `customerNumber` có trong `customers` hoặc `payments`.

---

## 6. `UNION` với hằng số và alias

Có thể thêm một hằng số để cho biết nguồn của từng dòng.

```sql
SELECT customerNumber AS partyNumber,
       customerName AS partyName,
       'Customer' AS partyType
FROM customers

UNION

SELECT employeeNumber,
       CONCAT(firstName, ' ', lastName),
       'Employee'
FROM employees
ORDER BY partyType, partyName;
```

Ví dụ: gộp danh sách thành phố và chỉ rõ nguồn.

```sql
SELECT city AS locationName,
       'Customer city' AS sourceType
FROM customers

UNION

SELECT city,
       'Office city'
FROM offices
ORDER BY locationName, sourceType;
```

> Hai dòng có cùng mã và tên nhưng khác cột `partyType` vẫn được xem là khác nhau.

### Bài tập thực hành

**Bài 6.1.** Tạo danh sách mã, tên và loại đối tượng cho khách hàng và nhân viên bằng `UNION`.

**Bài 6.2.** Đặt nhãn `'Customer'` cho dòng từ `customers` và `'Employee'` cho dòng từ `employees`.

**Bài 6.3.** Tạo danh sách quốc gia kèm nguồn `'Customer country'` hoặc `'Office country'`.

**Bài 6.4.** Tạo danh sách gồm mã và thành phố của khách hàng, mã và thành phố của văn phòng, kèm một cột ghi nguồn.

**Bài 6.5.** Tạo danh sách tên khách hàng ở `France` và nhân viên có `jobTitle = 'Sales Rep'`, kèm cột phân loại nguồn.

---

## 7. `UNION ALL`: Gộp result set và giữ dòng trùng

`UNION ALL` kết hợp các result set nhưng không loại bỏ dòng trùng.

Cú pháp:

```sql
SELECT column_list
FROM table_1

UNION ALL

SELECT column_list
FROM table_2;
```

Ví dụ:

```sql
SELECT country
FROM customers
WHERE country IN ('USA', 'France')

UNION ALL

SELECT country
FROM offices
WHERE country IN ('USA', 'France')
ORDER BY country;
```

### So sánh `UNION` và `UNION ALL`

| Tiêu chí | `UNION` | `UNION ALL` |
|---|---|---|
| Loại bỏ dòng trùng | Có | Không |
| Số dòng kết quả | Có thể nhỏ hơn tổng số dòng đầu vào | Bằng tổng số dòng các query block |
| Phù hợp khi | Muốn tập giá trị khác nhau | Muốn giữ số lần xuất hiện và nguồn dữ liệu |

### Bài tập thực hành

**Bài 7.1.** Dùng `UNION ALL` để kết hợp `country` từ `customers` và `offices`.

**Bài 7.2.** Chạy lại Bài 7.1 bằng `UNION`; so sánh số dòng trả về.

**Bài 7.3.** Dùng `UNION ALL` để kết hợp các thành phố từ `customers` và `offices`, kèm nguồn dữ liệu.

**Bài 7.4.** Dùng `UNION ALL` để kết hợp `customerNumber` từ `customers` và `payments`.

**Bài 7.5.** Dùng `UNION ALL` để kết hợp tên khách hàng ở `USA` và `France`, kèm một cột ghi quốc gia nguồn.

---

## 8. `ORDER BY` và `LIMIT` với `UNION`

`ORDER BY` và `LIMIT` ở cuối câu lệnh áp dụng cho **toàn bộ result set**.

```sql
SELECT country
FROM customers

UNION

SELECT country
FROM offices
ORDER BY country
LIMIT 5;
```

Muốn áp dụng `ORDER BY` hoặc `LIMIT` riêng cho từng query block, cần dùng dấu ngoặc đơn.

```sql
(
    SELECT customerNumber AS partyNumber,
           customerName AS partyName
    FROM customers
    ORDER BY customerNumber
    LIMIT 3
)

UNION ALL

(
    SELECT employeeNumber,
           CONCAT(firstName, ' ', lastName)
    FROM employees
    ORDER BY employeeNumber
    LIMIT 3
)

ORDER BY partyNumber;
```

### Bài tập thực hành

**Bài 8.1.** Dùng `UNION` để lấy quốc gia từ `customers` và `offices`, sau đó sắp xếp tăng dần.

**Bài 8.2.** Dùng `UNION` để lấy thành phố khác nhau từ `customers` và `offices`, sau đó chỉ lấy 10 dòng đầu.

**Bài 8.3.** Dùng `UNION ALL` để kết hợp 5 khách hàng đầu tiên và 5 nhân viên đầu tiên theo mã số.

**Bài 8.4.** Dùng dấu ngoặc đơn để lấy 3 quốc gia đầu tiên theo thứ tự chữ cái từ `customers` và 3 quốc gia đầu tiên từ `offices`, rồi kết hợp bằng `UNION ALL`.

**Bài 8.5.** Kết hợp khách hàng và nhân viên, sau đó sắp xếp toàn bộ kết quả theo tên đối tượng.

---

# Phần B. `EXCEPT`

## 9. `EXCEPT`: Hiệu của hai result set

`EXCEPT` trả về các dòng có trong result set của truy vấn thứ nhất nhưng không xuất hiện trong result set của truy vấn thứ hai.

Cú pháp:

```sql
SELECT column_list
FROM table_1

EXCEPT [DISTINCT | ALL]

SELECT column_list
FROM table_2;
```

Nếu không ghi `DISTINCT` hoặc `ALL`, MySQL dùng `DISTINCT`.

Ví dụ: tìm các quốc gia có khách hàng nhưng không có văn phòng.

```sql
SELECT DISTINCT country
FROM customers

EXCEPT

SELECT DISTINCT country
FROM offices
ORDER BY country;
```

### Lưu ý về thứ tự

`EXCEPT` không có tính giao hoán:

```text
A EXCEPT B ≠ B EXCEPT A
```

Do đó, cần xác định rõ result set nào là tập ban đầu và result set nào cần loại bỏ.

### Bài tập thực hành

**Bài 9.1.** Dùng `EXCEPT` để tìm quốc gia có khách hàng nhưng không có văn phòng.

**Bài 9.2.** Dùng `EXCEPT` để tìm quốc gia có văn phòng nhưng không có khách hàng.

**Bài 9.3.** Dùng `EXCEPT` để tìm `customerNumber` có trong `customers` nhưng chưa xuất hiện trong `payments`.

**Bài 9.4.** Dùng `EXCEPT` để tìm thành phố có khách hàng nhưng không có văn phòng.

**Bài 9.5.** Dùng `EXCEPT` để tìm các `customerNumber` xuất hiện trong `orders` nhưng không xuất hiện trong `payments`.

---

## 10. `EXCEPT DISTINCT` và `EXCEPT ALL`

### `EXCEPT DISTINCT`

`EXCEPT DISTINCT` là hành vi mặc định, mỗi dòng kết quả chỉ xuất hiện một lần.

```sql
SELECT country
FROM customers

EXCEPT DISTINCT

SELECT country
FROM offices;
```

### `EXCEPT ALL`

`EXCEPT ALL` xét cả số lần xuất hiện của dòng.

Nếu một dòng xuất hiện `m` lần trong A và `n` lần trong B, `A EXCEPT ALL B` giữ tối đa `max(m - n, 0)` bản sao của dòng đó.

Ví dụ:

```sql
SELECT 'USA' AS country
UNION ALL
SELECT 'USA'
UNION ALL
SELECT 'France'

EXCEPT ALL

SELECT 'USA';
```

Kết quả giữ lại một dòng `USA` và một dòng `France`.

### Bài tập thực hành

**Bài 10.1.** Viết lại Bài 9.1 bằng `EXCEPT DISTINCT`.

**Bài 10.2.** Dùng `EXCEPT ALL` với literal sao cho `'A'` xuất hiện hai lần ở tập đầu, một lần ở tập sau.

**Bài 10.3.** Giải thích khác biệt giữa `EXCEPT DISTINCT` và `EXCEPT ALL`.

**Bài 10.4.** Dùng `EXCEPT DISTINCT` để lấy tất cả `productLine` trong `products` ngoại trừ `'Classic Cars'`.

**Bài 10.5.** Dùng `EXCEPT` để lấy các trạng thái có trong `orders`, ngoại trừ `'Shipped'`.

---

# Phần C. `INTERSECT`

## 12. `INTERSECT`: Giao của hai result set

`INTERSECT` trả về các dòng xuất hiện trong cả hai result set.

Cú pháp:

```sql
SELECT column_list
FROM table_1

INTERSECT [DISTINCT | ALL]

SELECT column_list
FROM table_2;
```

Ví dụ: tìm quốc gia vừa có khách hàng vừa có văn phòng.

```sql
SELECT DISTINCT country
FROM customers

INTERSECT

SELECT DISTINCT country
FROM offices
ORDER BY country;
```

Ví dụ: tìm khách hàng vừa có trong `customers` vừa có ít nhất một khoản thanh toán.

```sql
SELECT customerNumber
FROM customers

INTERSECT

SELECT customerNumber
FROM payments
ORDER BY customerNumber;
```

### Bài tập thực hành

**Bài 12.1.** Dùng `INTERSECT` để tìm quốc gia vừa có khách hàng vừa có văn phòng.

**Bài 12.2.** Dùng `INTERSECT` để tìm thành phố vừa có khách hàng vừa có văn phòng.

**Bài 12.3.** Dùng `INTERSECT` để tìm `customerNumber` vừa có trong `customers` vừa có trong `payments`.

**Bài 12.4.** Dùng `INTERSECT` để tìm `customerNumber` vừa có trong `orders` vừa có trong `payments`.

**Bài 12.5.** Dùng `INTERSECT` để tìm quốc gia vừa có khách hàng vừa có văn phòng thuộc territory `NA`.

---

## 13. `INTERSECT DISTINCT` và `INTERSECT ALL`

### `INTERSECT DISTINCT`

Đây là hành vi mặc định. Mỗi dòng chung xuất hiện một lần.

```sql
SELECT country
FROM customers

INTERSECT DISTINCT

SELECT country
FROM offices;
```

### `INTERSECT ALL`

`INTERSECT ALL` giữ lại số bản sao bằng số lần xuất hiện nhỏ hơn giữa hai tập.

Nếu X xuất hiện `m` lần trong A và `n` lần trong B, kết quả giữ lại `min(m, n)` bản sao X.

```sql
SELECT 'USA' AS country
UNION ALL
SELECT 'USA'
UNION ALL
SELECT 'France'

INTERSECT ALL

SELECT 'USA'
UNION ALL
SELECT 'USA'
UNION ALL
SELECT 'USA'
UNION ALL
SELECT 'Germany';
```

Kết quả có hai dòng `USA`.

### Bài tập thực hành

**Bài 13.1.** Viết lại Bài 12.1 bằng `INTERSECT DISTINCT`.

**Bài 13.2.** Viết truy vấn `INTERSECT ALL` với literal sao cho `'A'` xuất hiện hai lần ở kết quả.

**Bài 13.3.** Giải thích khác biệt giữa `INTERSECT DISTINCT` và `INTERSECT ALL`.

**Bài 13.4.** Dùng `INTERSECT DISTINCT` để tìm các `customerNumber` có trong cả `orders` và `payments`.

**Bài 13.5.** Dùng `INTERSECT` để tìm quốc gia có trong `customers` và `offices` thuộc territory `EMEA`.

---

# Phần D. Kết hợp nhiều set operators

## 15. Thứ tự ưu tiên và dấu ngoặc đơn

Có thể dùng nhiều set operator trong cùng một câu truy vấn.

Trong MySQL:

1. `INTERSECT` có độ ưu tiên cao hơn.
2. `UNION` và `EXCEPT` có cùng độ ưu tiên, được đánh giá từ trái sang phải.
3. Dấu ngoặc đơn thay đổi hoặc làm rõ thứ tự đánh giá.

Ví dụ:

```sql
SELECT country
FROM customers

UNION

SELECT country
FROM offices

INTERSECT

SELECT country
FROM customers;
```

Tương đương với:

```sql
SELECT country
FROM customers

UNION

(
    SELECT country
    FROM offices

    INTERSECT

    SELECT country
    FROM customers
);
```

Muốn ép `UNION` chạy trước:

```sql
(
    SELECT country
    FROM customers

    UNION

    SELECT country
    FROM offices
)

INTERSECT

SELECT country
FROM customers
ORDER BY country;
```

### Bài tập thực hành

**Bài 15.1.** Viết truy vấn lấy quốc gia có trong `customers`, `offices` hoặc cả hai bằng `UNION`.

**Bài 15.2.** Viết truy vấn lấy quốc gia có trong `customers` nhưng không có trong `offices` bằng `EXCEPT`.

**Bài 15.3.** Viết truy vấn lấy quốc gia vừa có trong `customers` vừa có trong `offices` bằng `INTERSECT`.

**Bài 15.4.** Dùng dấu ngoặc đơn để viết: “các quốc gia có trong customers hoặc offices, sau đó chỉ giữ các quốc gia có trong customers”.

**Bài 15.5.** Giải thích vì sao dấu ngoặc đơn làm truy vấn nhiều set operator dễ đọc hơn.

---

## 16. So sánh set operators với JOIN và subquery

| Cách tiếp cận | Phù hợp khi |
|---|---|
| `UNION` | Muốn gộp các result set có cùng cấu trúc |
| `EXCEPT` | Muốn tìm dòng có ở tập A nhưng không ở tập B |
| `INTERSECT` | Muốn tìm dòng chung giữa hai tập |
| `JOIN` | Muốn kết hợp thêm cột từ nhiều bảng |
| `EXISTS` / `NOT EXISTS` | Muốn kiểm tra sự tồn tại hoặc không tồn tại của dòng liên quan |

Ví dụ `INTERSECT`:

```sql
SELECT customerNumber
FROM customers

INTERSECT

SELECT customerNumber
FROM payments;
```

Ví dụ `EXISTS` tương đương về ý nghĩa:

```sql
SELECT customerNumber
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM payments AS p
    WHERE p.customerNumber = c.customerNumber
);
```

Ví dụ `JOIN` trả thêm thông tin thanh toán:

```sql
SELECT DISTINCT c.customerNumber, c.customerName,
       p.checkNumber, p.amount
FROM customers AS c
JOIN payments AS p
    ON p.customerNumber = c.customerNumber;
```

### Bài tập thực hành

**Bài 16.1.** Viết truy vấn dùng `INTERSECT` để tìm khách hàng có thanh toán.

**Bài 16.2.** Viết lại Bài 16.1 bằng `EXISTS`.

**Bài 16.3.** Viết lại Bài 16.1 bằng `JOIN`.

**Bài 16.4.** Giải thích vì sao `JOIN` có thể trả về nhiều dòng cho cùng một khách hàng.

**Bài 16.5.** Nêu trường hợp nên ưu tiên `UNION` thay vì `JOIN`.

---

## 17. Một số lỗi thường gặp

### Lỗi 1. Hai query block có số cột khác nhau

```sql
SELECT customerNumber, customerName
FROM customers
UNION
SELECT officeCode
FROM offices;
```

### Lỗi 2. Cột cùng vị trí không cùng ý nghĩa

```sql
SELECT customerNumber, customerName
FROM customers
UNION
SELECT CONCAT(firstName, ' ', lastName), employeeNumber
FROM employees;
```

### Lỗi 3. Dùng `UNION` khi cần giữ dòng trùng

Khi cần biết số lần xuất hiện từ từng nguồn, dùng `UNION ALL`.

### Lỗi 4. Nhầm hướng của `EXCEPT`

```text
A EXCEPT B khác B EXCEPT A.
```

### Lỗi 5. Đặt `ORDER BY` sai vị trí

Sai:

```sql
SELECT country
FROM customers
ORDER BY country
UNION
SELECT country
FROM offices;
```

Đúng:

```sql
SELECT country
FROM customers
UNION
SELECT country
FROM offices
ORDER BY country;
```


### Bài tập thực hành

**Bài 17.1.** Sửa truy vấn ở Lỗi 1.

**Bài 17.2.** Sửa truy vấn ở Lỗi 2.

**Bài 17.3.** Viết ví dụ cần dùng `UNION ALL` thay vì `UNION`.

**Bài 17.4.** Viết hai truy vấn khác nhau cho `A EXCEPT B` và `B EXCEPT A`, với A là quốc gia khách hàng, B là quốc gia văn phòng.

**Bài 17.5.** Sửa truy vấn ở Lỗi 5 để `ORDER BY` áp dụng cho toàn bộ result set.

---

## 18. Bài tập tổng hợp

### Bài 18.1. Danh sách quốc gia

Viết ba truy vấn:

1. Quốc gia có khách hàng hoặc văn phòng.
2. Quốc gia có khách hàng nhưng không có văn phòng.
3. Quốc gia vừa có khách hàng vừa có văn phòng.

### Bài 18.2. Khách hàng, đơn hàng và thanh toán

Viết ba truy vấn, chỉ hiển thị `customerNumber`:

1. Khách hàng có đơn hàng hoặc có thanh toán.
2. Khách hàng có đơn hàng nhưng không có thanh toán.
3. Khách hàng vừa có đơn hàng vừa có thanh toán.

### Bài 18.3. So sánh theo thành phố

Viết ba truy vấn:

1. Thành phố xuất hiện trong `customers` hoặc `offices`.
2. Thành phố có khách hàng nhưng không có văn phòng.
3. Thành phố vừa có khách hàng vừa có văn phòng.

### Bài 18.4. Phân tích tập hợp đối xứng và phần bù

Dùng `EXCEPT` và `UNION`, hãy viết:

1. Quốc gia có văn phòng nhưng không có khách hàng nào (`offices EXCEPT customers`).
2. Khách hàng đã phát sinh thanh toán nhưng chưa có đơn hàng nào trong bảng `orders` (`payments EXCEPT orders`).
3. Tìm các quốc gia chỉ xuất hiện ở đúng một trong hai bảng `customers` hoặc `offices`, không xuất hiện ở cả hai (hiệu đối xứng).

### Bài 18.5. Truy vấn nhiều toán tử

Viết truy vấn:

> Các quốc gia có trong `customers` hoặc `offices`, nhưng loại bỏ các quốc gia không có khách hàng.

Dùng dấu ngoặc đơn để thể hiện rõ thứ tự thực hiện.

---

## 19. Đáp án gợi ý cho một số bài tập

### Bài 5.1

```sql
SELECT country
FROM customers
UNION
SELECT country
FROM offices
ORDER BY country;
```

### Bài 5.4

```sql
SELECT customerName AS personName
FROM customers
WHERE country = 'USA'

UNION

SELECT CONCAT(e.firstName, ' ', e.lastName)
FROM employees AS e
JOIN offices AS o
    ON e.officeCode = o.officeCode
WHERE o.country = 'USA'
ORDER BY personName;
```

### Bài 7.3

```sql
SELECT city AS locationName,
       'Customer' AS sourceType
FROM customers

UNION ALL

SELECT city,
       'Office'
FROM offices
ORDER BY locationName, sourceType;
```

### Bài 8.3

```sql
(
    SELECT customerNumber AS partyNumber,
           customerName AS partyName
    FROM customers
    ORDER BY customerNumber
    LIMIT 5
)

UNION ALL

(
    SELECT employeeNumber,
           CONCAT(firstName, ' ', lastName)
    FROM employees
    ORDER BY employeeNumber
    LIMIT 5
)

ORDER BY partyNumber;
```

### Bài 9.1

```sql
SELECT DISTINCT country
FROM customers
EXCEPT
SELECT DISTINCT country
FROM offices
ORDER BY country;
```

### Bài 9.3

```sql
SELECT customerNumber
FROM customers
EXCEPT
SELECT customerNumber
FROM payments
ORDER BY customerNumber;
```

### Bài 12.1

```sql
SELECT DISTINCT country
FROM customers
INTERSECT
SELECT DISTINCT country
FROM offices
ORDER BY country;
```

### Bài 12.3

```sql
SELECT customerNumber
FROM customers
INTERSECT
SELECT customerNumber
FROM payments
ORDER BY customerNumber;
```

### Bài 15.4

```sql
(
    SELECT country
    FROM customers
    UNION
    SELECT country
    FROM offices
)
INTERSECT
SELECT country
FROM customers
ORDER BY country;
```

### Bài 18.2

```sql
-- 1. Có đơn hàng hoặc có thanh toán
SELECT customerNumber
FROM orders
UNION
SELECT customerNumber
FROM payments
ORDER BY customerNumber;
```

```sql
-- 2. Có đơn hàng nhưng không có thanh toán
SELECT customerNumber
FROM orders
EXCEPT
SELECT customerNumber
FROM payments
ORDER BY customerNumber;
```

```sql
-- 3. Có cả đơn hàng và thanh toán
SELECT customerNumber
FROM orders
INTERSECT
SELECT customerNumber
FROM payments
ORDER BY customerNumber;
```

---

## 20. Tóm tắt

- `UNION` gộp nhiều result set và loại bỏ dòng trùng.
- `UNION ALL` gộp nhiều result set và giữ mọi dòng trùng.
- `EXCEPT` trả về dòng có ở result set đầu nhưng không có ở result set sau.
- `INTERSECT` trả về dòng chung giữa các result set.
- Các query block phải có cùng số cột; cột cùng vị trí nên tương thích về kiểu và ý nghĩa.
- Tên cột kết quả thường lấy từ query block đầu tiên.
- `ORDER BY` và `LIMIT` đặt ở cuối áp dụng cho toàn bộ result set.
- Dùng dấu ngoặc đơn khi cần sắp xếp/giới hạn từng query block hoặc muốn điều khiển thứ tự tính.
- `INTERSECT` có độ ưu tiên cao hơn `UNION` và `EXCEPT`.
- MySQL hỗ trợ đầy đủ các phép toán tập hợp chuẩn: `UNION`, `UNION ALL`, `EXCEPT` và `INTERSECT` (yêu cầu MySQL 8.0.31+ cho `EXCEPT` và `INTERSECT`).

---

## 21. Từ khóa chính

- Set operation
- Result set
- UNION
- UNION DISTINCT
- UNION ALL
- EXCEPT
- EXCEPT DISTINCT
- EXCEPT ALL
- INTERSECT
- INTERSECT DISTINCT
- INTERSECT ALL
- ORDER BY
- LIMIT
- Parenthesized query expression
- classicmodels
