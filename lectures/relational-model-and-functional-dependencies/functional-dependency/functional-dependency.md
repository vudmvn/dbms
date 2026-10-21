---
title: "Bài giảng: Functional Dependencies và các loại phụ thuộc trong DBMS"
author: "Tên giảng viên"
duration: "240m"
difficulty: "Intermediate"
prerequisites:
  - "Đã biết relation, attribute, tuple, superkey và candidate key"
  - "Đã biết primary key và composite key"
summary: "Bài giảng về functional dependency, cách kiểm tra và phân loại FD, partial/transitive dependency, multivalued dependency và mối liên hệ với chuẩn hóa 2NF–4NF."
---

# Functional Dependencies và các loại phụ thuộc trong DBMS

## Tài liệu tham khảo

- GeeksforGeeks – *Functional Dependency in DBMS*
- GeeksforGeeks – *Types of Functional Dependencies in DBMS*
- Giáo trình cơ sở dữ liệu quan hệ về phụ thuộc hàm và chuẩn hóa

> **Phạm vi:** Bài này dùng “dependency” theo nghĩa rộng: functional dependency (FD), các dạng FD thường gặp, và multivalued dependency (MVD). MVD không phải là một FD thông thường; nó là một loại ràng buộc dữ liệu khác, thường được học khi đến 4NF.

> **Quy ước ký hiệu:** `X`, `Y`, `Z` là tập thuộc tính. `X → Y` là functional dependency. `X →→ Y` là multivalued dependency.

---

## 1. Mục tiêu học tập

Sau bài học, người học có thể:

1. Giải thích ý nghĩa chính xác của `X → Y`.
2. Phân biệt FD đúng theo quy tắc nghiệp vụ với FD chỉ tình cờ đúng trong dữ liệu mẫu.
3. Xác định determinant, dependent attribute, superkey và composite key trong ngữ cảnh phù hợp.
4. Kiểm tra một FD bị vi phạm trên một relation instance.
5. Phân loại trivial, non-trivial và semi-non-trivial FD.
6. Phân biệt full, partial và transitive dependency.
7. Giải thích trực giác của multivalued dependency.
8. Liên hệ partial dependency, transitive dependency và MVD với 2NF, 3NF và 4NF.
9. Đề xuất decomposition đơn giản để giảm redundancy.
10. Giải thích vì sao normalization là một trade-off, không phải mục tiêu “tách càng nhiều bảng càng tốt”.

---

## 2. Tại sao Functional Dependency quan trọng?

Một relation không chỉ là một tập cột đặt cạnh nhau. Các thuộc tính thường chịu những **quy tắc xác định** xuất phát từ nghiệp vụ.

Ví dụ trong hệ thống đào tạo:

```text
StudentID → StudentName, DateOfBirth
CourseID  → CourseName, Credits
```

Các FD này mô tả điều mà hệ thống phải bảo đảm:

- Một mã sinh viên phải tương ứng với đúng một tên và ngày sinh.
- Một mã học phần phải tương ứng với đúng một tên học phần và số tín chỉ.

FD quan trọng vì nó giúp:

- Xác định cấu trúc dữ liệu có ý nghĩa.
- Nhận diện keys và các thuộc tính phụ thuộc.
- Phát hiện nguồn redundancy.
- Phân tích update, insertion và deletion anomalies.
- Làm cơ sở cho normalization.

> **Ý chính:** FD là ràng buộc về ngữ nghĩa dữ liệu. Nó không phải chỉ là một mẫu trùng hợp trong vài rows hiện có.

![Functional dependency overview](images/image.png)

*Hình 1. Functional dependency mô tả quan hệ xác định giữa các thuộc tính.*

### Quiz – Vai trò của Functional Dependency

**Câu 2.1.** Một doanh nghiệp quy định “mỗi `ProductID` luôn gắn với đúng một `ProductName`”. Mệnh đề này được mô tả trực tiếp nhất bởi:

A. `ProductID → ProductName`  
B. `ProductName → ProductID`  
C. `ProductID →→ ProductName`  
D. `ProductID, ProductName → ProductID`

**Câu 2.2.** Lý do quan trọng nhất để phân tích FD trước khi chuẩn hóa là gì?

A. Để giảm số lượng cột trong mọi bảng.  
B. Để nhận diện các quy tắc xác định và nguồn redundancy.  
C. Để thay thế toàn bộ foreign keys.  
D. Để tránh dùng SQL.

**Câu 2.3.** Phát biểu nào đúng nhất?

A. Một FD chỉ cần đúng trong dữ liệu mẫu hiện tại.  
B. FD chỉ liên quan đến tốc độ truy vấn.  
C. FD phản ánh quy tắc nghiệp vụ mà dữ liệu hợp lệ phải tuân theo.  
D. FD chỉ tồn tại khi bảng có đúng một khóa chính.

---

## 3. Khái niệm cơ bản

### 3.1. Định nghĩa chính xác

Trong relation schema `R`, functional dependency:

```text
X → Y
```

nghĩa là: với mọi relation instance hợp lệ của `R`, nếu hai tuples có cùng giá trị trên `X`, chúng phải có cùng giá trị trên `Y`.

Biểu diễn bằng ký hiệu:

```text
Nếu t1[X] = t2[X] thì t1[Y] = t2[Y].
```

| Thành phần | Ý nghĩa |
|---|---|
| `X` | Vế trái; determinant |
| `Y` | Vế phải; dependent attribute hoặc tập thuộc tính phụ thuộc |
| `X → Y` | `X` xác định duy nhất `Y` |

### 3.2. Determinant và dependent attribute

Ví dụ:

```text
StudentID → StudentName, DateOfBirth
```

| Thành phần | Vai trò |
|---|---|
| `StudentID` | Determinant |
| `StudentName`, `DateOfBirth` | Dependent attributes |

![Determinant and dependent attributes](images/image-1.png)

*Hình 2. Determinant xác định các thuộc tính phụ thuộc.*

### 3.3. FD và key

- Nếu `X` xác định **toàn bộ thuộc tính** của relation, `X` là một **superkey**.
- Nếu `X` là superkey và không thể bỏ bớt attribute nào mà vẫn là superkey, `X` là một **candidate key**.
- Không phải determinant nào cũng là key.

Ví dụ trong relation:

```text
Employee(EmployeeID, EmployeeName, DepartmentID, DepartmentName)
```

Nếu:

```text
EmployeeID → EmployeeName, DepartmentID, DepartmentName
DepartmentID → DepartmentName
```

thì `EmployeeID` có thể là superkey; còn `DepartmentID` là determinant nhưng không xác định toàn bộ employee.

### Quiz – Khái niệm cơ bản

**Câu 3.1.** Trong `X → Y`, mệnh đề nào đúng?

A. Hai rows cùng `Y` bắt buộc có cùng `X`.  
B. Hai rows cùng `X` phải có cùng `Y`.  
C. `Y` luôn là key.  
D. `X` và `Y` không được có attribute chung.

**Câu 3.2.** Trong `DepartmentID → DepartmentName`, `DepartmentID` là:

A. Determinant.  
B. Dependent attribute.  
C. Multivalued attribute.  
D. Bắt buộc là candidate key của toàn bộ relation.

**Câu 3.3.** Khi nào `X` là một superkey của relation `R`?

A. Khi `X` chỉ xác định một thuộc tính không khóa.  
B. Khi `X` xuất hiện ở vế trái của bất kỳ FD nào.  
C. Khi `X` xác định toàn bộ attributes của `R`.  
D. Khi `X` luôn có một attribute duy nhất.

---

## 4. FD đúng theo nghiệp vụ và FD đúng tình cờ trên dữ liệu mẫu

Khi nhìn vào dữ liệu mẫu, ta có thể không thấy phản ví dụ cho một dependency. Tuy nhiên, điều đó **chưa đủ** để biến nó thành FD hợp lệ.

Ví dụ, dữ liệu hiện tại có thể chỉ có một sinh viên tên “Minh”:

```text
StudentName → StudentID
```

có vẻ đúng trong bảng hiện tại. Nhưng nếu tên không được quy định là duy nhất, hai sinh viên khác nhau vẫn có thể cùng tên. Vì vậy đây không phải FD nghiệp vụ đáng tin cậy.

Ngược lại:

```text
StudentID → StudentName
```

có thể là FD hợp lệ nếu `StudentID` được quản lý như một định danh duy nhất.

### 4.1. Nguồn xác nhận FD

Một FD nên được xác nhận từ ít nhất một trong các nguồn sau:

```text
Quy tắc nghiệp vụ được phê duyệt
Constraint hoặc key được thiết kế có chủ đích
Tài liệu dữ liệu / data dictionary
Quy trình vận hành thực tế
```

Dữ liệu mẫu chủ yếu giúp **phát hiện phản ví dụ**, không tự mình chứng minh một FD là đúng cho mọi dữ liệu tương lai.

### Quiz – FD và business rules

**Câu 4.1.** Một bảng hiện chỉ có một khách hàng tên “Lan”. Kết luận nào phù hợp nhất về `CustomerName → CustomerID`?

A. Chắc chắn là FD vì hiện không có tên lặp.  
B. Có thể chỉ đúng tình cờ; cần kiểm tra business rule về tính duy nhất của tên.  
C. Luôn sai vì tên không thể nằm ở vế trái.  
D. Chắc chắn là MVD.

**Câu 4.2.** Nguồn nào đáng tin cậy nhất để xác nhận `EmployeeID → EmployeeName`?

A. Chỉ dựa vào năm rows đầu của bảng.  
B. Một dashboard đang hiển thị dữ liệu.  
C. Business rule hoặc constraint quy định EmployeeID là định danh duy nhất.  
D. Thứ tự các dòng khi `SELECT *`.

**Câu 4.3.** Vai trò phù hợp nhất của dữ liệu mẫu khi kiểm tra FD là:

A. Tìm phản ví dụ có cùng `X` nhưng khác `Y`.  
B. Thay thế hoàn toàn data dictionary.  
C. Chứng minh mọi FD theo định nghĩa toán học.  
D. Xác định storage engine.

---

## 5. Cách kiểm tra FD trên một relation instance

Để kiểm tra liệu `X → Y` có bị vi phạm trong một dataset hiện tại:

1. Nhóm các rows có cùng giá trị `X`.
2. Trong từng nhóm, kiểm tra số giá trị phân biệt của `Y`.
3. Nếu có nhóm có hơn một giá trị `Y`, FD bị vi phạm.
4. Nếu không có phản ví dụ, kết luận chính xác là: **FD không bị vi phạm trên instance này**.

Ví dụ:

| StudentID | StudentName | StudentAge |
|---|---|---:|
| 101 | Rahul | 23 |
| 102 | Ankit | 22 |
| 103 | Aditya | 22 |
| 104 | Sahil | 24 |
| 105 | Ankit | 23 |

```text
StudentID → StudentName    không bị vi phạm
StudentName → StudentAge   bị vi phạm
```

Với `StudentName = Ankit`, có hai độ tuổi khác nhau: 22 và 23.

![Checking an FD](images/image-2.png)

*Hình 3. Một FD bị vi phạm khi cùng vế trái nhưng khác vế phải.*

### 5.1. Truy vấn SQL kiểm tra phản ví dụ

Ví dụ kiểm tra `StudentName → StudentAge`:

```sql
SELECT
    StudentName
FROM Students
GROUP BY StudentName
HAVING COUNT(DISTINCT StudentAge) > 1;
```

Nếu query trả về rows, dependency bị vi phạm trong dữ liệu hiện tại.

> Query này chỉ kiểm tra dữ liệu đang có. Nó không thể thay thế việc xác nhận business rule.

### Quiz – Kiểm tra FD

**Câu 5.1.** Khi kiểm tra `X → Y`, điều gì chứng minh FD bị vi phạm?

A. Có hai rows cùng `Y` nhưng khác `X`.  
B. Có hai rows cùng `X` nhưng khác `Y`.  
C. Có hai rows hoàn toàn giống nhau.  
D. Bảng có nhiều hơn một key.

**Câu 5.2.** Query nhóm theo `X` và dùng `HAVING COUNT(DISTINCT Y) > 1` nhằm mục đích gì?

A. Tìm các giá trị `X` tạo ra nhiều giá trị `Y`, tức phản ví dụ của `X → Y`.  
B. Tìm primary key.  
C. Tạo index cho `Y`.  
D. Tách relation sang 3NF.

**Câu 5.3.** Nếu không tìm thấy phản ví dụ trong dataset, kết luận thận trọng nhất là:

A. FD luôn đúng trong mọi tương lai.  
B. FD đã được chứng minh là business rule.  
C. FD không bị vi phạm trên dataset hiện tại; vẫn cần xác nhận từ ngữ nghĩa nghiệp vụ.  
D. `Y` chắc chắn là candidate key.

---

## 6. Cách biểu diễn và suy luận cơ bản

Một FD có thể chứa nhiều attributes ở mỗi vế:

```text
EmployeeID → FirstName, LastName
StudentID, CourseID → Grade
```

### 6.1. Decomposition ở vế phải

Nếu:

```text
X → Y, Z
```

thì tương đương với:

```text
X → Y
X → Z
```

Ví dụ:

```text
StudentID → StudentName, StudentAge
```

tương đương:

```text
StudentID → StudentName
StudentID → StudentAge
```

### 6.2. Không tự động tách vế trái

Từ:

```text
StudentID, CourseID → Grade
```

không được suy ra:

```text
StudentID → Grade
CourseID → Grade
```

Vì điểm thường chỉ xác định khi biết **cả sinh viên lẫn học phần**.

### 6.3. Một số quy tắc suy luận thường gặp

| Quy tắc | Dạng | Ý nghĩa |
|---|---|---|
| Reflexivity | Nếu `Y ⊆ X` thì `X → Y` | FD tầm thường |
| Augmentation | Nếu `X → Y` thì `XZ → YZ` | Bổ sung cùng attributes vào hai vế |
| Transitivity | Nếu `X → Y` và `Y → Z` thì `X → Z` | Suy diễn qua thuộc tính trung gian |

> Các quy tắc trên là phần cốt lõi của Armstrong's Axioms; chúng giúp suy luận FD từ một tập FD đã biết.

### Quiz – Biểu diễn và suy luận

**Câu 6.1.** Từ `StudentID → StudentName, StudentAge`, tập FD nào tương đương trực tiếp?

A. `StudentID → StudentName` và `StudentID → StudentAge`  
B. `StudentName → StudentID` và `StudentAge → StudentID`  
C. `StudentID, StudentName → StudentAge` duy nhất  
D. `StudentName, StudentAge → StudentID` duy nhất

**Câu 6.2.** Từ `StudentID, CourseID → Grade`, kết luận nào không hợp lệ nếu chưa có thêm business rule?

A. Cần cả StudentID và CourseID để xác định Grade.  
B. `StudentID → Grade`.  
C. Có thể đây là full dependency.  
D. Grade phụ thuộc vào tổ hợp StudentID–CourseID.

**Câu 6.3.** Nếu `A → B` và `B → C`, theo transitivity ta suy ra:

A. `C → A`  
B. `B → A`  
C. `A → C`  
D. `A, C → B`

---

## 7. Bản đồ các loại dependency

Trong bài này, dependencies được phân tích theo bốn góc nhìn:

| Góc nhìn | Các loại chính | Câu hỏi cần trả lời |
|---|---|---|
| Quan hệ giữa hai vế | Trivial, non-trivial, semi-non-trivial | Vế phải có nằm trong vế trái không? |
| Composite key | Full, partial | Có cần toàn bộ khóa ghép không? |
| Chuỗi xác định | Transitive | Có attribute trung gian không? |
| Tập giá trị độc lập | MVD | Có các tập giá trị độc lập tạo tổ hợp dư thừa không? |

![Dependency types overview](images/image-3.png)

*Hình 4. Phân nhóm các dependency trong bài học.*

### Quiz – Bản đồ dependency

**Câu 7.1.** Khi phân biệt trivial và non-trivial FD, yếu tố nào được xét trước tiên?

A. Kích thước bảng.  
B. Quan hệ tập hợp giữa vế phải và vế trái.  
C. Số lượng index.  
D. Tốc độ của truy vấn.

**Câu 7.2.** Full và partial dependency chỉ trở nên có ý nghĩa rõ nhất khi determinant có dạng:

A. Composite key hoặc tập thuộc tính gồm nhiều phần.  
B. Một attribute không bao giờ lặp.  
C. Một view.  
D. Một storage partition.

**Câu 7.3.** MVD thường được nhận diện khi:

A. Một attribute xác định duy nhất một scalar value.  
B. Hai tables có foreign key.  
C. Có các tập giá trị độc lập làm xuất hiện nhiều tổ hợp.  
D. Vế phải là tập con của vế trái.

---

# Phần A. Trivial, Non-trivial và Semi-non-trivial FD

## 8. Trivial Functional Dependency

`X → Y` là **trivial** nếu:

```text
Y ⊆ X
```

Ví dụ:

```text
A, B → A
A, B → B
A, B → A, B
StudentID, StudentName → StudentName
```

Trivial FD luôn đúng theo cấu trúc tập thuộc tính, không cần xem dữ liệu thực tế.

### Ý nghĩa

- Không cung cấp thông tin nghiệp vụ mới.
- Quan trọng trong lý thuyết suy diễn, đặc biệt là reflexivity.
- Không phải dấu hiệu redundancy hay lỗi thiết kế.

---

## 9. Non-trivial và Semi-non-trivial Functional Dependency

### 9.1. Non-trivial FD

`X → Y` là **non-trivial** nếu:

```text
Y ⊄ X
```

Ví dụ:

```text
StudentID → StudentName
CourseID → CourseName
```

### 9.2. Completely non-trivial FD

Nếu:

```text
X ∩ Y = ∅
```

thì FD hoàn toàn không tầm thường.

Ví dụ:

```text
StudentID → StudentName
```

### 9.3. Semi-non-trivial FD

`X → Y` là **semi-non-trivial** nếu:

```text
X ∩ Y ≠ ∅
và
Y ⊄ X
```

Ví dụ:

```text
StudentID, CourseID → CourseID, CourseName
```

- `CourseID` xuất hiện ở cả hai vế.
- `CourseName` là thông tin mới ở vế phải.

Lưu ý:

```text
StudentID, CourseID → CourseID
```

là trivial, không phải semi-non-trivial.

![Trivial vs non-trivial vs semi-non-trivial](images/image-4.png)

*Hình 5. Ba trường hợp FD theo quan hệ giữa vế trái và vế phải.*

### Quiz – Trivial, Non-trivial và Semi-non-trivial

**Câu 9.1.** FD nào là trivial?

A. `A → B`  
B. `A, B → A`  
C. `StudentID → StudentName`  
D. `A → B, C`

**Câu 9.2.** FD `A, B → B, C` thuộc loại nào?

A. Trivial  
B. Completely non-trivial  
C. Semi-non-trivial  
D. Partial dependency

**Câu 9.3.** FD nào là completely non-trivial?

A. `A, B → B`  
B. `A, B → A, C`  
C. `A → B`  
D. `A, B → A, B`

---

# Phần B. Full, Partial và Transitive Dependency

## 10. Full Functional Dependency

Với `X → Y`, dependency là **full** khi:

1. `X → Y` đúng.
2. Không có proper subset nào của `X` vẫn xác định được `Y`.

Ví dụ:

```text
StudentID, CourseID → Grade
```

Nếu:

```text
StudentID ↛ Grade
CourseID ↛ Grade
```

thì Grade phụ thuộc đầy đủ vào tổ hợp `{StudentID, CourseID}`.

> Full dependency không tự động đồng nghĩa relation đã chuẩn hóa tốt; nó chỉ nói về dependency đang xét.

---

## 11. Partial Functional Dependency

Partial dependency xảy ra khi một non-prime attribute phụ thuộc vào **một proper subset** của một candidate key ghép.

Ví dụ:

| StudentID | CourseID | StudentName | CourseName | Grade |
|---|---|---|---|---|
| 101 | C01 | Rahul | Database | A |
| 101 | C02 | Rahul | Programming | B |
| 102 | C01 | Ankit | Database | A |

Giả sử candidate key là:

```text
StudentID, CourseID
```

Các FD:

```text
StudentID → StudentName
CourseID → CourseName
StudentID, CourseID → Grade
```

| FD | Nhận xét |
|---|---|
| `StudentID → StudentName` | Partial dependency |
| `CourseID → CourseName` | Partial dependency |
| `StudentID, CourseID → Grade` | Full dependency |

### 11.1. Vấn đề gây ra

Partial dependency có thể dẫn đến:

```text
StudentName lặp lại theo mỗi course enrollment
CourseName lặp lại theo mỗi student enrollment
Update anomaly khi đổi tên course
Insertion/deletion anomaly trong một số tình huống
```

### 11.2. Decomposition gợi ý

```text
Students(StudentID, StudentName)
Courses(CourseID, CourseName)
Enrollments(StudentID, CourseID, Grade)
```

![Full and partial dependency](images/image-5.png)

*Hình 6. Full dependency và partial dependency trong relation có khóa ghép.*

---

## 12. Transitive Functional Dependency

Về mặt suy luận, nếu:

```text
A → B
B → C
```

thì:

```text
A → C
```

Trong chuẩn hóa, điều đáng quan tâm là một non-key attribute phụ thuộc vào key **thông qua một non-key attribute khác**.

Ví dụ:

| EmployeeID | DepartmentID | DepartmentName |
|---|---|---|
| E01 | D01 | IT |
| E02 | D02 | HR |
| E03 | D01 | IT |

```text
EmployeeID → DepartmentID
DepartmentID → DepartmentName
```

Suy ra:

```text
EmployeeID → DepartmentName
```

### 12.1. Vấn đề và cách xử lý

`DepartmentName` lặp lại theo mỗi employee trong department. Tách:

```text
Employees(EmployeeID, DepartmentID)
Departments(DepartmentID, DepartmentName)
```

giúp thay đổi tên department ở đúng một nơi.

![Transitive dependency](images/image-6.png)

*Hình 7. Transitive dependency và tách relation để giảm redundancy.*

### Quiz – Full, Partial và Transitive

**Câu 12.1.** Với candidate key `(StudentID, CourseID)`, FD nào là full dependency trong ngữ cảnh điểm học phần?

A. `StudentID → StudentName`  
B. `CourseID → CourseName`  
C. `StudentID, CourseID → Grade`  
D. `StudentID → Grade`

**Câu 12.2.** Partial dependency có liên hệ trực tiếp nhất với mục tiêu của:

A. 2NF  
B. 3NF  
C. 4NF  
D. BCNF

**Câu 12.3.** Trong relation `Employee(EmployeeID, DepartmentID, DepartmentName)`, dependency nào tạo đường bắc cầu từ `EmployeeID` đến `DepartmentName`?

A. `EmployeeID → DepartmentName` là trivial.  
B. `DepartmentName → DepartmentID` là bắt buộc.  
C. `EmployeeID → DepartmentID` và `DepartmentID → DepartmentName`.  
D. `EmployeeID, DepartmentID → DepartmentName` là MVD.

---

# Phần C. Multivalued Dependency

## 13. Multivalued Dependency (MVD)

Multivalued dependency có ký hiệu:

```text
X →→ Y
```

Trực giác: với mỗi giá trị của `X`, có một tập giá trị của `Y` độc lập với một tập attributes khác.

Ví dụ một bike model có nhiều colors và nhiều accessories độc lập:

| bike_model | color | accessory |
|---|---|---|
| tu1001 | Black | Helmet |
| tu1001 | Black | Gloves |
| tu1001 | Red | Helmet |
| tu1001 | Red | Gloves |

Ta có:

```text
bike_model →→ color
bike_model →→ accessory
```

Với `bike_model = tu1001`:

```text
Colors      = {Black, Red}
Accessories = {Helmet, Gloves}
```

Mỗi color có thể kết hợp với mỗi accessory, tạo 4 rows.

### 13.1. Redundancy do Cartesian product

Nếu thêm accessory `Basket`, relation gốc cần thêm một row cho mỗi color:

```text
Black + Basket
Red + Basket
```

Khi hai tập giá trị độc lập, lưu các tổ hợp trong cùng relation thường tạo redundancy.

### 13.2. Decomposition gợi ý

```text
BikeColors(bike_model, color)
BikeAccessories(bike_model, accessory)
```

![Multivalued dependency](images/image-7.png)

*Hình 8. Multivalued dependency tạo tổ hợp dư thừa giữa các tập giá trị độc lập.*

### 13.3. Liên hệ 4NF

Một relation vi phạm 4NF khi tồn tại non-trivial MVD `X →→ Y` mà `X` không phải superkey. Khi đó, decomposition thường được dùng để tránh redundancy do tổ hợp.

### Quiz – Multivalued Dependency

**Câu 13.1.** Tình huống nào gợi ý MVD rõ nhất?

A. `ProductID` xác định duy nhất `ProductName`.  
B. Một course có đúng một số tín chỉ.  
C. Một instructor có tập skills và tập programming languages độc lập.  
D. `A, B → A` là trivial.

**Câu 13.2.** Vì sao MVD có thể gây redundancy?

A. Vì một attribute luôn có nhiều kiểu dữ liệu.  
B. Vì mọi combination giữa các tập giá trị độc lập có thể phải được lưu.  
C. Vì MVD luôn làm mất primary key.  
D. Vì MVD loại bỏ foreign key.

**Câu 13.3.** Decomposition hợp lý cho `bike_model →→ color` và `bike_model →→ accessory` là:

A. `Bike(bike_model, color, accessory)` duy nhất.  
B. `Colors(color)` và `Accessories(accessory)` không có bike_model.  
C. `BikeColors(bike_model, color)` và `BikeAccessories(bike_model, accessory)`.  
D. `BikeModel(bike_model)` duy nhất.

---

## 14. Quy trình nhận diện dependency

Khi phân tích một dependency, nên đi theo thứ tự:

1. **Xác định business rule:** `X` có thực sự xác định `Y` không?
2. **Tìm phản ví dụ:** có rows cùng `X` nhưng khác `Y` không?
3. **So sánh tập thuộc tính:** `Y ⊆ X` hay `X ∩ Y ≠ ∅`?
4. **Xem candidate key:** nếu key ghép, non-prime attribute phụ thuộc toàn bộ hay một phần key?
5. **Tìm đường trung gian:** có `A → B → C` không?
6. **Tìm tập giá trị độc lập:** có MVD và redundancy do tổ hợp không?
7. **Đánh giá decomposition:** có giảm redundancy mà vẫn giữ semantics cần thiết không?

![Dependency classification flow](images/image-8.png)

*Hình 9. Quy trình nhận diện các loại dependency.*

### Quiz – Quy trình nhận diện

**Câu 14.1.** Bước nên làm trước tiên khi được cho một FD dự kiến là gì?

A. Tạo index cho vế trái.  
B. Xác nhận business rule phía sau dependency.  
C. Tách relation ngay lập tức.  
D. Chạy `SELECT *`.

**Câu 14.2.** Khi có candidate key ghép, câu hỏi nào giúp phân biệt full và partial dependency?

A. Vế phải có phải là thuộc tính chuỗi không?  
B. Bảng có bao nhiêu rows?  
C. Attribute ở vế phải có cần toàn bộ key hay chỉ một phần key?  
D. Query có dùng `ORDER BY` không?

**Câu 14.3.** Dấu hiệu nào nên khiến ta kiểm tra MVD?

A. Có hai tập giá trị độc lập cùng gắn với một determinant.  
B. Vế phải là tập con của vế trái.  
C. Bảng có primary key đơn.  
D. Dữ liệu có một row duy nhất.

---

## 15. Dependency và Normalization

| Dependency | Rủi ro / ý nghĩa | Dạng chuẩn liên quan |
|---|---|---|
| Trivial | Chủ yếu hữu ích cho suy diễn lý thuyết | Không phải lỗi chuẩn hóa |
| Non-trivial | Phản ánh quy tắc dữ liệu có ý nghĩa | Cơ sở để phân tích keys/decomposition |
| Partial | Non-prime attribute phụ thuộc một phần candidate key ghép | 2NF |
| Transitive | Non-key attribute phụ thuộc qua non-key attribute khác | 3NF |
| MVD | Các tập giá trị độc lập tạo tổ hợp dư thừa | 4NF |

### 15.1. Không chuẩn hóa máy móc

Normalization không đồng nghĩa với việc “tách càng nhiều bảng càng tốt”.

Một decomposition tốt cần cân bằng:

```text
Giảm redundancy
Giữ đúng semantics
Hỗ trợ các truy vấn quan trọng
Dễ bảo trì
Không tạo chi phí join bất hợp lý
```

Trong thực tế, có những trường hợp denormalization có chủ đích cho đọc dữ liệu, reporting hoặc performance; nhưng cần dựa trên workload và cơ chế duy trì consistency rõ ràng.

![Dependency and normalization](images/image-9.png)

*Hình 10. Liên hệ giữa dependency và các dạng chuẩn.*

### Quiz – Dependency và Normalization

**Câu 15.1.** Partial dependency của non-prime attribute trên một phần candidate key ghép là vấn đề chính của:

A. 2NF  
B. 1NF  
C. 4NF  
D. 5NF

**Câu 15.2.** Vì sao không nên chuẩn hóa máy móc?

A. Vì foreign key luôn sai.  
B. Vì tách bảng nhiều nhất không tự động tối ưu semantics, workload và chi phí join.  
C. Vì normalization không liên quan dữ liệu.  
D. Vì mọi database phải có đúng một table.

**Câu 15.3.** Denormalization có thể hợp lý khi nào?

A. Khi muốn bỏ mọi constraint.  
B. Khi chưa hiểu business rule.  
C. Khi có workload rõ ràng, lợi ích performance được đánh giá và có cơ chế duy trì consistency.  
D. Khi không muốn viết query join.

---

## 16. Ví dụ tổng hợp: Enrollment

Xét relation:

```text
Enrollment(
    StudentID,
    StudentName,
    CourseID,
    CourseName,
    DepartmentID,
    DepartmentName,
    Grade
)
```

Giả sử các FD:

```text
StudentID → StudentName, DepartmentID
DepartmentID → DepartmentName
CourseID → CourseName
StudentID, CourseID → Grade
```

### 16.1. Phân tích

| FD | Loại / nhận xét |
|---|---|
| `StudentID → StudentName` | Partial nếu candidate key là `(StudentID, CourseID)` |
| `CourseID → CourseName` | Partial nếu candidate key là `(StudentID, CourseID)` |
| `StudentID, CourseID → Grade` | Full dependency |
| `StudentID → DepartmentID → DepartmentName` | Transitive path |

### 16.2. Decomposition gợi ý

```text
Students(StudentID, StudentName, DepartmentID)
Departments(DepartmentID, DepartmentName)
Courses(CourseID, CourseName)
Enrollments(StudentID, CourseID, Grade)
```

### 16.3. Vì sao cách tách hữu ích?

- StudentName không bị lặp theo mỗi enrollment.
- CourseName không bị lặp theo mỗi sinh viên học course đó.
- DepartmentName được cập nhật tại một nơi.
- Grade vẫn được gắn với đúng cặp Student–Course.

### Quiz – Ví dụ tổng hợp

**Câu 16.1.** Trong `Enrollment`, FD nào là partial dependency nếu candidate key là `(StudentID, CourseID)`?

A. `StudentID, CourseID → Grade`  
B. `StudentID → StudentName`  
C. `DepartmentID → DepartmentName` duy nhất  
D. Không có FD nào

**Câu 16.2.** Nếu DepartmentName của D01 đổi tên, bảng nào nên được cập nhật sau decomposition?

A. `Enrollments`  
B. `Students`  
C. `Departments`  
D. `Courses`

**Câu 16.3.** Lợi ích quan trọng nhất của decomposition trong ví dụ này là:

A. Loại bỏ hoàn toàn nhu cầu join.  
B. Bảo đảm mọi query chỉ đọc một table.  
C. Giảm redundancy và hạn chế update anomalies.  
D. Không cần định nghĩa keys nữa.

---

## 17. Quiz tổng hợp

**Câu 17.1.** Một relation có candidate key `(A, B)` và FD `A → C`, `A, B → D`. Nhận định nào đúng?

A. `A → C` là full dependency.  
B. `A → C` là partial dependency; `A, B → D` có thể là full dependency.  
C. Cả hai đều là transitive dependency.  
D. Cả hai đều trivial dependency.

**Câu 17.2.** Một bảng lưu `EmployeeID, DepartmentID, DepartmentName`; biết `EmployeeID → DepartmentID` và `DepartmentID → DepartmentName`. Rủi ro chính là:

A. MVD bắt buộc xuất hiện.  
B. Trivial FD gây lỗi.  
C. Transitive dependency có thể tạo redundancy.  
D. Không có dependency đáng chú ý.

**Câu 17.3.** Phát biểu nào đúng nhất về `StudentID → StudentName` khi sample data hiện tại có StudentID duy nhất?

A. Chỉ hợp lệ khi business rule hoặc constraint bảo đảm StudentID xác định StudentName.  
B. Luôn đúng chỉ vì StudentID chưa lặp trong sample.  
C. Không thể là FD.  
D. Chỉ đúng nếu StudentName là primary key.

---

## 18. Bài tập vận dụng

### Bài 18.1. Kiểm tra FD

Cho relation:

| EmployeeID | EmployeeName | Department | DepartmentPhone |
|---|---|---|---|
| E01 | Nam | IT | 028-111 |
| E02 | Hoa | HR | 028-222 |
| E03 | Bình | IT | 028-111 |

Giả sử:

```text
EmployeeID xác định một employee.
Mỗi department có đúng một department phone.
```

1. Liệt kê các FD hợp lý.
2. `Department → DepartmentPhone` có đúng không?
3. Có transitive path nào xuất phát từ EmployeeID không?

### Bài 18.2. Phân loại theo quan hệ tập hợp

Phân loại từng FD:

```text
A, B → A
A → B
A, B → B, C
A, B → A, B
A, B, C → A, C
```

### Bài 18.3. Full và Partial

Với relation:

```text
OrderLine(OrderID, ProductID, OrderDate, ProductName, Quantity)
```

Giả sử candidate key là `(OrderID, ProductID)` và:

```text
OrderID → OrderDate
ProductID → ProductName
OrderID, ProductID → Quantity
```

1. Xác định full dependency.
2. Xác định partial dependencies.
3. Đề xuất decomposition.

### Bài 18.4. Transitive Dependency

Cho:

```text
StudentID → MajorID
MajorID → MajorName, FacultyID
FacultyID → FacultyName
```

1. Liệt kê các attributes có thể được suy ra từ StudentID theo transitivity.
2. Đề xuất relations sau decomposition.
3. Nêu lợi ích khi MajorName thay đổi.

### Bài 18.5. Multivalued Dependency

Cho relation:

```text
InstructorSkillLanguage(InstructorID, Skill, ProgrammingLanguage)
```

Giả sử một instructor có nhiều skills và nhiều programming languages độc lập.

1. Viết các MVD phù hợp.
2. Mô tả redundancy xuất hiện khi có 3 skills và 4 languages.
3. Đề xuất decomposition phù hợp với trực giác 4NF.

---

## 19. Đáp án quiz

### Đáp án – Vai trò của Functional Dependency

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 2.1 | A | ProductID xác định ProductName theo quy tắc được nêu. |
| 2.2 | B | FD giúp nhận diện quy tắc xác định và nguồn redundancy. |
| 2.3 | C | FD phải phản ánh ràng buộc nghiệp vụ của dữ liệu hợp lệ. |

### Đáp án – Khái niệm cơ bản

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 3.1 | B | Cùng X phải dẫn đến cùng Y. |
| 3.2 | A | DepartmentID là vế trái/determinant. |
| 3.3 | C | Superkey xác định toàn bộ attributes của relation. |

### Đáp án – FD và business rules

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 4.1 | B | Dữ liệu hiện tại không đủ chứng minh tên khách hàng là duy nhất. |
| 4.2 | C | Constraint hoặc business rule là nguồn xác nhận đáng tin cậy. |
| 4.3 | A | Dữ liệu mẫu hữu ích để tìm phản ví dụ. |

### Đáp án – Kiểm tra FD

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 5.1 | B | Cùng X nhưng khác Y là phản ví dụ trực tiếp. |
| 5.2 | A | Query phát hiện một X liên kết với nhiều Y khác nhau. |
| 5.3 | C | Không có phản ví dụ không đồng nghĩa FD đã được chứng minh nghiệp vụ. |

### Đáp án – Biểu diễn và suy luận

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 6.1 | A | Vế phải có thể phân rã thành hai FD đơn. |
| 6.2 | B | Không thể suy ra StudentID → Grade từ FD ghép. |
| 6.3 | C | Đây là quy tắc transitivity. |

### Đáp án – Bản đồ dependency

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 7.1 | B | Cần xét quan hệ giữa hai tập thuộc tính. |
| 7.2 | A | Full/partial được xét khi determinant gồm nhiều attributes. |
| 7.3 | C | MVD liên quan các tập giá trị độc lập và tổ hợp. |

### Đáp án – Trivial, Non-trivial và Semi-non-trivial

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 9.1 | B | A là tập con của {A, B}. |
| 9.2 | C | B là phần giao, C là attribute mới. |
| 9.3 | C | A và B không giao nhau. |

### Đáp án – Full, Partial và Transitive

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 12.1 | C | Grade cần tổ hợp StudentID–CourseID trong giả định bài toán. |
| 12.2 | A | 2NF loại bỏ partial dependencies của non-prime attributes. |
| 12.3 | C | DepartmentID là attribute trung gian. |

### Đáp án – Multivalued Dependency

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 13.1 | C | Skills và languages là hai tập giá trị độc lập. |
| 13.2 | B | Các tổ hợp giữa hai tập độc lập có thể phải được lưu. |
| 13.3 | C | Mỗi relation sau tách giữ bike_model và một tập giá trị. |

### Đáp án – Quy trình nhận diện

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 14.1 | B | Business rule phải được xác nhận trước khi suy luận sâu hơn. |
| 14.2 | C | Đây là câu hỏi trung tâm để phân biệt full/partial. |
| 14.3 | A | Các tập giá trị độc lập là dấu hiệu của MVD. |

### Đáp án – Dependency và Normalization

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 15.1 | A | Partial dependency là vấn đề chính của 2NF. |
| 15.2 | B | Decomposition cần cân bằng redundancy, semantics và workload. |
| 15.3 | C | Denormalization cần lợi ích rõ, đánh giá và cơ chế consistency. |

### Đáp án – Ví dụ tổng hợp

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 16.1 | B | StudentName chỉ phụ thuộc StudentID, một phần candidate key ghép. |
| 16.2 | C | DepartmentName được quản lý tập trung trong Departments. |
| 16.3 | C | Mục tiêu là giảm redundancy và update anomalies, không phải loại joins. |

### Đáp án – Quiz tổng hợp

| Câu | Đáp án | Giải thích |
|---:|:---:|---|
| 17.1 | B | C chỉ phụ thuộc A; D có thể phụ thuộc đầy đủ vào AB. |
| 17.2 | C | DepartmentName phụ thuộc gián tiếp vào EmployeeID qua DepartmentID. |
| 17.3 | A | FD cần được bảo đảm bởi semantic rule/constraint. |

---

## 20. Tóm tắt

- `X → Y` nghĩa là cùng giá trị `X` phải đi cùng cùng giá trị `Y`.
- FD cần được xác nhận bằng business rule hoặc constraint, không chỉ bằng sample data.
- Trivial FD có `Y ⊆ X`; non-trivial FD có `Y ⊄ X`; semi-non-trivial FD có phần giao và có attribute mới.
- Full dependency cần toàn bộ determinant ghép; partial dependency chỉ cần một phần candidate key ghép.
- Transitive dependency đi qua attribute trung gian.
- MVD mô tả các tập giá trị độc lập và thường liên quan 4NF.
- Normalization nhằm giảm redundancy nhưng cần cân bằng với semantics, workload và khả năng vận hành.

## 21. Từ khóa chính

- Functional Dependency
- Determinant
- Dependent Attribute
- Superkey
- Candidate Key
- Composite Key
- Trivial Dependency
- Non-trivial Dependency
- Semi-non-trivial Dependency
- Full Dependency
- Partial Dependency
- Transitive Dependency
- Multivalued Dependency
- 2NF
- 3NF
- 4NF
- Normalization
- Redundancy
- Update Anomaly
