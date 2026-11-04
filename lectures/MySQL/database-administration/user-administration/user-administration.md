---
title: "Tutorial: Quản lý người dùng, quyền và role trong MySQL"
author: "Tên giảng viên"
duration: "180m"
difficulty: "Intermediate"
prerequisites:
  - "Đã biết database, table, view và các lệnh SQL cơ bản"
  - "Đã biết cách kết nối MySQL bằng MySQL Workbench hoặc mysql client"
  - "Có một tài khoản quản trị được cấp quyền quản lý account trên máy chủ thực hành"
summary: "Thực hành tạo user, cấp và thu hồi quyền, quản lý role, kiểm tra quyền, đổi mật khẩu, khóa/mở khóa và xóa user trong MySQL theo nguyên tắc least privilege."
---

# Tutorial: Quản lý người dùng, quyền và role trong MySQL

## Link tham khảo

- [MySQL Tutorial — MySQL Administration](https://www.mysqltutorial.org/mysql-administration/)
- [MySQL Tutorial — Create Users](https://www.mysqltutorial.org/mysql-administration/mysql-create-user/)
- [MySQL Tutorial — Grant Privileges](https://www.mysqltutorial.org/mysql-administration/mysql-grant/)
- [MySQL Tutorial — Revoke Privileges](https://www.mysqltutorial.org/mysql-administration/mysql-revoke/)
- [MySQL Tutorial — Roles](https://www.mysqltutorial.org/mysql-administration/mysql-roles/)
- [MySQL Tutorial — Show Privileges](https://www.mysqltutorial.org/mysql-administration/mysql-show-privileges/)
- [MySQL Tutorial — Drop Users](https://www.mysqltutorial.org/mysql-administration/mysql-drop-user/)
- [MySQL Tutorial — Change Passwords](https://www.mysqltutorial.org/mysql-administration/mysql-change-user-password/)
- [MySQL Tutorial — Lock User Accounts](https://www.mysqltutorial.org/mysql-administration/mysql-lock-user-accounts/)
- [MySQL Tutorial — Unlock User Accounts](https://www.mysqltutorial.org/mysql-administration/mysql-unlock-user-accounts/)


> **Phạm vi thực hành:** Các lệnh trong bài này thay đổi account và quyền trên MySQL Server. Chỉ chạy trên server cá nhân, server lab hoặc môi trường development được phép. Không chạy nguyên xi trên production hay trên database dùng chung nếu chưa được người quản trị chấp thuận.

---

## 1. Mục tiêu học tập

Sau khi hoàn thành tutorial này, người học có thể:

1. Giải thích được account MySQL có dạng `'user_name'@'host_name'`.
2. Tạo user bằng `CREATE USER`.
3. Cấp quyền ở mức database, table và routine bằng `GRANT`.
4. Thu hồi quyền hoặc role bằng `REVOKE`.
5. Tạo role, gán quyền cho role, gán role cho user và thiết lập default role.
6. Kiểm tra quyền bằng `SHOW GRANTS` và các metadata liên quan.
7. Đổi mật khẩu bằng `ALTER USER` hoặc `SET PASSWORD` trong trường hợp phù hợp.
8. Khóa và mở khóa account bằng `ALTER USER ... ACCOUNT LOCK` và `ACCOUNT UNLOCK`.
9. Xóa account bằng `DROP USER`.
10. Áp dụng nguyên tắc **least privilege** khi thiết kế quyền truy cập.

---

## 2. Khái niệm cơ bản về User Management

MySQL kiểm soát quyền truy cập thông qua account, privilege và role.

| Khái niệm | Ý nghĩa |
|---|---|
| User account | Danh tính được dùng để xác thực khi kết nối MySQL |
| Host | Nguồn kết nối được phép cho account |
| Privilege | Quyền thực hiện một thao tác, ví dụ `SELECT`, `INSERT`, `CREATE` |
| Role | Tập hợp các privilege có tên để cấp lại cho nhiều user |
| Authentication | Quá trình xác thực danh tính, thường qua mật khẩu hoặc plugin |
| Authorization | Quá trình kiểm tra user được phép làm gì sau khi đã xác thực |
| Least privilege | Chỉ cấp tối thiểu các quyền cần thiết cho nhiệm vụ |

### 2.1. Account MySQL gồm user và host

Một account MySQL thường có dạng:

```sql
'user_name'@'host_name'
```

Ví dụ:

```sql
'lab_reader'@'localhost'
```

```sql
'lab_analyst'@'192.168.1.%'
```

```sql
'app_service'@'%'
```

Ý nghĩa:

| Account | Diễn giải |
|---|---|
| `'lab_reader'@'localhost'` | Chỉ cho phép kết nối từ chính máy chủ MySQL |
| `'lab_analyst'@'192.168.1.%'` | Cho phép kết nối từ các host khớp mẫu mạng nội bộ |
| `'app_service'@'%'` | Cho phép từ mọi host phù hợp về mặt mạng và xác thực |

> Trong production, không nên dùng `'user'@'%'` một cách mặc định. Hãy giới hạn host hoặc mạng nguồn phù hợp khi kiến trúc cho phép.

### 2.2. User và role khác nhau thế nào?

| Đối tượng | Có thể đăng nhập? | Có mật khẩu? | Mục đích chính |
|---|---:|---:|---|
| User account | Có | Có thể có | Đại diện cho người dùng hoặc ứng dụng |
| Role | Không | Không dùng như user | Gom nhóm quyền để cấp cho nhiều user |

Ví dụ:

```text
role_reporting
    ├── SELECT trên classicmodels.*
    └── SELECT trên user_mgmt_lab.*

lab_reporter@localhost
    └── được gán role_reporting
```

### 2.3. Principle of least privilege

Không nên cấp:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'student_user'@'%';
```

cho một user chỉ cần đọc báo cáo.

Thay vào đó, cấp đúng quyền cần thiết:

```sql
GRANT SELECT
ON classicmodels.*
TO 'student_user'@'localhost';
```

### Bài tập thực hành

**Bài 2.1.**

Giải thích ý nghĩa của account `'lab_reader'@'localhost'`.

**Bài 2.2.**

Nêu sự khác nhau giữa authentication và authorization.

**Bài 2.3.**

Nêu sự khác nhau giữa user account và role.

**Bài 2.4.**

Giải thích vì sao không nên cấp `ALL PRIVILEGES ON *.*` cho một account chỉ dùng để đọc báo cáo.

**Bài 2.5.**

Đề xuất một account name và host phù hợp cho một ứng dụng chạy trên cùng máy với MySQL Server.

---

## 3. Chuẩn bị môi trường lab

### 3.1. Tài khoản yêu cầu

Các thao tác quản lý user cần một account được cấp quyền quản trị thích hợp, ví dụ quyền quản lý account và quyền cấp quyền.

Kiểm tra account hiện tại:

```sql
SELECT USER() AS loginUser,
       CURRENT_USER() AS privilegeAccount;
```

| Hàm | Ý nghĩa |
|---|---|
| `USER()` | User và host mà client dùng để kết nối |
| `CURRENT_USER()` | Account MySQL được dùng để xác định quyền hiện tại |

Xem quyền của account hiện tại:

```sql
SHOW GRANTS;
```

Xem các grant của account quản trị cụ thể nếu bạn có quyền xem:

```sql
SHOW GRANTS FOR 'root'@'localhost';
```

### 3.2. Tạo schema lab

Để tránh cấp quyền ghi trực tiếp vào `classicmodels`, bài thực hành dùng schema riêng:

```sql
CREATE DATABASE IF NOT EXISTS user_mgmt_lab;

USE user_mgmt_lab;
```

Tạo bảng nhỏ để kiểm tra quyền:

```sql
CREATE TABLE IF NOT EXISTS training_notes (
    note_id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(100) NOT NULL,
    content VARCHAR(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);
```

Chèn dữ liệu mẫu:

```sql
INSERT INTO training_notes (title, content)
VALUES
    ('Welcome', 'This table is used only for MySQL user-management practice.'),
    ('Least privilege', 'Grant only the privileges required for the task.');
```

Kiểm tra:

```sql
SELECT *
FROM training_notes
ORDER BY note_id;
```

### 3.3. Các account và role được dùng trong lab

| Tên | Vai trò lab |
|---|---|
| `'lab_reader'@'localhost'` | User chỉ đọc dữ liệu |
| `'lab_editor'@'localhost'` | User được đọc và sửa dữ liệu lab |
| `'lab_analyst'@'localhost'` | User nhận quyền qua role |
| `'role_reporting'` | Role chỉ đọc |
| `'role_lab_editor'` | Role đọc và thay đổi dữ liệu lab |

> Các tên trên chỉ dành cho lab. Trong hệ thống thực, dùng naming convention thể hiện vai trò, môi trường và ứng dụng, ví dụ `app_order_api_prod`, `bi_report_reader`, `etl_loader_dev`.

### Bài tập thực hành

**Bài 3.1.**

Chạy `SELECT USER(), CURRENT_USER();` và giải thích nếu hai giá trị khác nhau.

**Bài 3.2.**

Dùng `SHOW GRANTS;` để xem quyền của account hiện tại.

**Bài 3.3.**

Tạo database `user_mgmt_lab` nếu chưa tồn tại.

**Bài 3.4.**

Tạo bảng `training_notes` theo cấu trúc ở trên.

**Bài 3.5.**

Thêm một dòng dữ liệu riêng vào `training_notes`, sau đó dùng `SELECT` để kiểm tra.

---

# Phần A. Create Users

## 4. Tạo user bằng `CREATE USER`

### 4.1. Cú pháp cơ bản

```sql
CREATE USER 'user_name'@'host_name'
IDENTIFIED BY 'password';
```

Ví dụ:

```sql
CREATE USER 'lab_reader'@'localhost'
IDENTIFIED BY 'LabReader_2026!';
```

Câu lệnh trên tạo account có:

- User name: `lab_reader`
- Host: `localhost`
- Mật khẩu minh họa: `LabReader_2026!`

> Mật khẩu trong ví dụ chỉ dùng cho lab. Trong môi trường thực, không hard-code mật khẩu vào file SQL công khai, source code hoặc tài liệu chia sẻ. Dùng secret manager, biến môi trường hoặc quy trình quản lý bí mật phù hợp.

### 4.2. Dùng `IF NOT EXISTS`

Nếu account có thể đã tồn tại:

```sql
CREATE USER IF NOT EXISTS 'lab_reader'@'localhost'
IDENTIFIED BY 'LabReader_2026!';
```

Điều này giúp script chạy lại mà không dừng vì lỗi account đã tồn tại.

Tuy nhiên, `IF NOT EXISTS` không cập nhật mật khẩu hay thuộc tính của user đã có. Muốn thay đổi account đã tồn tại, dùng `ALTER USER`.

### 4.3. Tạo nhiều user cùng lúc

```sql
CREATE USER IF NOT EXISTS
    'lab_reader'@'localhost' IDENTIFIED BY 'LabReader_2026!',
    'lab_editor'@'localhost' IDENTIFIED BY 'LabEditor_2026!',
    'lab_analyst'@'localhost' IDENTIFIED BY 'LabAnalyst_2026!';
```

### 4.4. Account ban đầu chưa có quyền dữ liệu

Tạo user không đồng nghĩa user đã có quyền `SELECT`, `INSERT` hoặc `UPDATE` trên database ứng dụng.

Ví dụ:

```sql
CREATE USER 'lab_reader'@'localhost'
IDENTIFIED BY 'LabReader_2026!';
```

Sau bước này, user tồn tại nhưng chưa được cấp quyền đọc `user_mgmt_lab.training_notes`.

Quyền được cấp bằng `GRANT` ở phần tiếp theo.

### 4.5. Kiểm tra account

Dùng:

```sql
SHOW GRANTS FOR 'lab_reader'@'localhost';
```

Ngay sau khi tạo, output thường chỉ thể hiện quyền cơ bản về kết nối hoặc usage, chưa có quyền thao tác dữ liệu trên schema lab.

Có thể xem definition account:

```sql
SHOW CREATE USER 'lab_reader'@'localhost';
```

### 4.6. Một số tùy chọn tạo account

Ví dụ tạo account ở trạng thái khóa:

```sql
CREATE USER 'lab_pending'@'localhost'
IDENTIFIED BY 'Pending_2026!'
ACCOUNT LOCK;
```

Ví dụ yêu cầu user đổi mật khẩu ở lần kết nối tiếp theo:

```sql
CREATE USER 'lab_password_reset'@'localhost'
IDENTIFIED BY 'Reset_2026!'
PASSWORD EXPIRE;
```

Các tùy chọn password policy, authentication plugin, SSL/TLS và resource limits là chủ đề quản trị nâng cao. Chỉ sử dụng theo chính sách của server và tổ chức.

### Bài tập thực hành

**Bài 4.1.**

Tạo user `'lab_reader'@'localhost'` với một mật khẩu lab.

**Bài 4.2.**

Tạo user `'lab_editor'@'localhost'` với một mật khẩu lab khác.

**Bài 4.3.**

Dùng một câu `CREATE USER IF NOT EXISTS` để tạo cả `'lab_analyst'@'localhost'` và `'lab_pending'@'localhost'`.

**Bài 4.4.**

Tạo account `'lab_locked'@'localhost'` ở trạng thái `ACCOUNT LOCK`.

**Bài 4.5.**

Dùng `SHOW CREATE USER` để xem definition của `'lab_reader'@'localhost'`.

---

# Phần B. Grant Privileges

## 5. Cấp quyền bằng `GRANT`

### 5.1. Cú pháp cơ bản

```sql
GRANT privilege_type [, privilege_type] ...
ON privilege_level
TO 'user_name'@'host_name';
```

Ví dụ cấp quyền đọc mọi bảng trong schema lab:

```sql
GRANT SELECT
ON user_mgmt_lab.*
TO 'lab_reader'@'localhost';
```

### 5.2. Các mức cấp quyền

| Mức | Cú pháp | Ví dụ |
|---|---|---|
| Global | `*.*` | `GRANT PROCESS ON *.* ...` |
| Database | `database_name.*` | `GRANT SELECT ON classicmodels.* ...` |
| Table | `database_name.table_name` | `GRANT SELECT ON user_mgmt_lab.training_notes ...` |
| Column | `database_name.table_name (column_list)` | `GRANT SELECT(title, content) ...` |
| Routine | `PROCEDURE database_name.routine_name` | `GRANT EXECUTE ON PROCEDURE ...` |

Trong bài lab, ưu tiên cấp quyền hẹp nhất có thể.

### 5.3. Cấp quyền chỉ đọc

```sql
GRANT SELECT
ON user_mgmt_lab.training_notes
TO 'lab_reader'@'localhost';
```

User này chỉ có quyền đọc bảng `training_notes`, không thể thêm, sửa hoặc xóa dữ liệu.

### 5.4. Cấp quyền đọc và thay đổi dữ liệu

```sql
GRANT SELECT, INSERT, UPDATE, DELETE
ON user_mgmt_lab.training_notes
TO 'lab_editor'@'localhost';
```

User `lab_editor` có thể đọc và thao tác dữ liệu trên một bảng lab, nhưng không có quyền `DROP`, `ALTER`, `CREATE` trên schema.

### 5.5. Cấp quyền theo database

```sql
GRANT SELECT
ON user_mgmt_lab.*
TO 'lab_analyst'@'localhost';
```

User có thể đọc mọi bảng hiện tại và bảng được tạo sau này trong `user_mgmt_lab`, nếu không bị revoke ở mức phù hợp.

### 5.6. Cấp quyền `EXECUTE` cho stored routine

Nếu một ứng dụng chỉ được phép gọi procedure hoặc function mà không được truy cập trực tiếp bảng, có thể cấp `EXECUTE`.

Ví dụ:

```sql
GRANT EXECUTE
ON PROCEDURE classicmodels.sp_lab_list_customers_by_country
TO 'lab_reader'@'localhost';
```

Hoặc cấp quyền execute ở mức schema:

```sql
GRANT EXECUTE
ON classicmodels.*
TO 'lab_reader'@'localhost';
```

> Chỉ cấp `EXECUTE` trên routine thực sự cần thiết. Cần hiểu kỹ security context `DEFINER`/`INVOKER` của routine trong hệ thống thực.

### 5.7. `WITH GRANT OPTION`

```sql
GRANT SELECT
ON user_mgmt_lab.*
TO 'lab_reader'@'localhost'
WITH GRANT OPTION;
```

Tùy chọn này cho phép user được cấp quyền tiếp tục cấp quyền đó cho account khác.

Trong hầu hết hệ thống ứng dụng và lab sinh viên, **không nên** dùng `WITH GRANT OPTION` trừ khi người nhận thực sự là account quản trị được ủy quyền.

### 5.8. Grant có hiệu lực ngay

Khi dùng các statement quản lý account như `GRANT` và `REVOKE`, thay đổi quyền có hiệu lực ngay. Không cần chạy `FLUSH PRIVILEGES` nếu bạn sử dụng các statement quản lý account chuẩn.

Không nên cập nhật trực tiếp các bảng quyền trong schema `mysql`.

### Bài tập thực hành

**Bài 5.1.**

Cấp quyền `SELECT` trên `user_mgmt_lab.training_notes` cho `'lab_reader'@'localhost'`.

**Bài 5.2.**

Cấp quyền `SELECT`, `INSERT`, `UPDATE`, `DELETE` trên `user_mgmt_lab.training_notes` cho `'lab_editor'@'localhost'`.

**Bài 5.3.**

Cấp quyền `SELECT` trên toàn bộ schema `user_mgmt_lab` cho `'lab_analyst'@'localhost'`.

**Bài 5.4.**

Cấp quyền `SELECT` trên `classicmodels.*` cho `'lab_reader'@'localhost'`, nhưng không cấp quyền ghi.

**Bài 5.5.**

Dùng `SHOW GRANTS FOR` để kiểm tra quyền vừa cấp cho `'lab_editor'@'localhost'`.

---

## 6. Kiểm tra quyền bằng cách đăng nhập account lab

Để kiểm tra thật sự quyền có hoạt động hay không, cần kết nối bằng user tương ứng.

Ví dụ trên command line:

```bash
mysql -u lab_reader -p -h localhost
```

Sau khi đăng nhập:

```sql
USE user_mgmt_lab;

SELECT *
FROM training_notes;
```

Nếu `lab_reader` chỉ được cấp `SELECT`, các câu sau phải bị từ chối:

```sql
INSERT INTO training_notes (title, content)
VALUES ('Test', 'This should fail for a read-only user.');
```

```sql
DELETE FROM training_notes
WHERE note_id = 1;
```

Với `lab_editor`, thao tác ghi trên bảng đã được grant có thể thành công:

```sql
USE user_mgmt_lab;

INSERT INTO training_notes (title, content)
VALUES ('Editor test', 'Inserted by lab_editor.');
```

> Không dùng user có quyền quản trị để kiểm tra các ràng buộc quyền của user thấp hơn, vì admin có thể vẫn làm được mọi thao tác.

### Bài tập thực hành

**Bài 6.1.**

Đăng nhập bằng `'lab_reader'@'localhost'` và chạy `SELECT * FROM user_mgmt_lab.training_notes;`.

**Bài 6.2.**

Khi đăng nhập bằng `lab_reader`, thử `INSERT` một dòng và ghi lại thông báo lỗi.

**Bài 6.3.**

Đăng nhập bằng `'lab_editor'@'localhost'` và thêm một dòng vào `training_notes`.

**Bài 6.4.**

Khi đăng nhập bằng `lab_editor`, cập nhật nội dung của dòng vừa thêm.

**Bài 6.5.**

Giải thích vì sao cần kiểm tra quyền bằng chính account được cấp quyền.

---

# Phần C. Revoke Privileges

## 7. Thu hồi quyền bằng `REVOKE`

### 7.1. Cú pháp cơ bản

```sql
REVOKE privilege_type [, privilege_type] ...
ON privilege_level
FROM 'user_name'@'host_name';
```

Ví dụ thu hồi quyền `DELETE`:

```sql
REVOKE DELETE
ON user_mgmt_lab.training_notes
FROM 'lab_editor'@'localhost';
```

Sau câu lệnh này, `lab_editor` vẫn có thể có `SELECT`, `INSERT`, `UPDATE`, nhưng không thể xóa dữ liệu trên bảng đó.

### 7.2. Thu hồi nhiều quyền

```sql
REVOKE INSERT, UPDATE, DELETE
ON user_mgmt_lab.training_notes
FROM 'lab_editor'@'localhost';
```

Sau khi thực hiện, nếu `SELECT` không bị revoke, account vẫn đọc được dữ liệu.

### 7.3. Thu hồi quyền trên schema

```sql
REVOKE SELECT
ON user_mgmt_lab.*
FROM 'lab_analyst'@'localhost';
```

### 7.4. Grant và revoke phải khớp phạm vi

Nếu đã cấp:

```sql
GRANT SELECT
ON user_mgmt_lab.training_notes
TO 'lab_reader'@'localhost';
```

thì thu hồi tương ứng:

```sql
REVOKE SELECT
ON user_mgmt_lab.training_notes
FROM 'lab_reader'@'localhost';
```

Cần kiểm tra cẩn thận:

- Privilege nào đã được cấp?
- Cấp ở cấp table hay database?
- User có nhận cùng privilege qua role hay không?

Nếu user nhận quyền qua role, revoke trực tiếp từ user có thể không làm mất effective privilege khi role vẫn active.

### 7.5. Revoke role

Role cũng có thể được thu hồi khỏi user:

```sql
REVOKE 'role_reporting'
FROM 'lab_analyst'@'localhost';
```

Phần Roles sẽ trình bày kỹ hơn.

### Bài tập thực hành

**Bài 7.1.**

Thu hồi quyền `DELETE` trên `user_mgmt_lab.training_notes` từ `'lab_editor'@'localhost'`.

**Bài 7.2.**

Dùng `SHOW GRANTS FOR` để kiểm tra rằng `DELETE` đã bị thu hồi.

**Bài 7.3.**

Thu hồi quyền `INSERT` và `UPDATE` từ `'lab_editor'@'localhost'`, giữ lại `SELECT`.

**Bài 7.4.**

Thu hồi quyền `SELECT` trên `classicmodels.*` từ `'lab_reader'@'localhost'`.

**Bài 7.5.**

Giải thích vì sao cần kiểm tra user có quyền thông qua role trước khi kết luận rằng `REVOKE` đã loại bỏ effective privilege.

---

# Phần D. Manage Roles

## 8. Quản lý role

### 8.1. Role là gì?

Role là một collection có tên của các privilege. Role giúp tránh phải lặp lại các câu `GRANT` giống nhau cho nhiều user.

Ví dụ thay vì cấp `SELECT` cho 20 analyst riêng lẻ:

```text
20 user × nhiều câu GRANT
```

ta có thể:

```text
role_reporting
    └── SELECT trên các schema báo cáo

20 user
    └── được gán role_reporting
```

Khi policy thay đổi, chỉ cần chỉnh quyền của role.

### 8.2. Tạo role

```sql
CREATE ROLE IF NOT EXISTS
    'role_reporting',
    'role_lab_editor';
```

Role được tạo không phải account đăng nhập thông thường. Role ban đầu không có mật khẩu để user kết nối như user account.

### 8.3. Cấp quyền cho role

Role chỉ đọc:

```sql
GRANT SELECT
ON user_mgmt_lab.*
TO 'role_reporting';
```

Role biên tập dữ liệu lab:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE
ON user_mgmt_lab.training_notes
TO 'role_lab_editor';
```

Kiểm tra quyền của role:

```sql
SHOW GRANTS FOR 'role_reporting';
```

### 8.4. Gán role cho user

```sql
GRANT 'role_reporting'
TO 'lab_analyst'@'localhost';
```

```sql
GRANT 'role_lab_editor'
TO 'lab_editor'@'localhost';
```

Một user có thể nhận nhiều role:

```sql
GRANT 'role_reporting', 'role_lab_editor'
TO 'lab_analyst'@'localhost';
```

### 8.5. Default role và active role

Một role được cấp cho account không nhất thiết tự động active trong session mới nếu chưa được thiết lập default role.

Thiết lập default role:

```sql
SET DEFAULT ROLE 'role_reporting'
TO 'lab_analyst'@'localhost';
```

Thiết lập nhiều default role:

```sql
SET DEFAULT ROLE
    'role_reporting',
    'role_lab_editor'
TO 'lab_analyst'@'localhost';
```

Khi user đăng nhập, có thể kiểm tra role đang active:

```sql
SELECT CURRENT_ROLE();
```

Trong session, user có thể dùng:

```sql
SET ROLE DEFAULT;
```

hoặc nếu được gán role phù hợp:

```sql
SET ROLE 'role_reporting';
```

### 8.6. Thu hồi role

```sql
REVOKE 'role_lab_editor'
FROM 'lab_editor'@'localhost';
```

### 8.7. Xóa role

```sql
DROP ROLE IF EXISTS 'role_reporting';
```

Khi drop role, role bị xóa và không thể dùng tiếp. Cần đánh giá ảnh hưởng tới các user đang được gán role đó.

### Bài tập thực hành

**Bài 8.1.**

Tạo hai role: `'role_reporting'` và `'role_lab_editor'`.

**Bài 8.2.**

Cấp `SELECT` trên `user_mgmt_lab.*` cho `'role_reporting'`.

**Bài 8.3.**

Cấp `SELECT`, `INSERT`, `UPDATE`, `DELETE` trên `user_mgmt_lab.training_notes` cho `'role_lab_editor'`.

**Bài 8.4.**

Gán `'role_reporting'` cho `'lab_analyst'@'localhost'` và đặt role này làm default role.

**Bài 8.5.**

Gán `'role_lab_editor'` cho `'lab_editor'@'localhost'`, sau đó dùng `SHOW GRANTS FOR` để kiểm tra role assignment.

---

## 9. Role hierarchy và thiết kế quyền

### 9.1. Gán role cho role

MySQL cho phép gán role này cho role khác.

Ví dụ:

```sql
CREATE ROLE IF NOT EXISTS
    'role_read_classicmodels',
    'role_read_lab',
    'role_data_analyst';
```

Cấp quyền cho role con:

```sql
GRANT SELECT
ON classicmodels.*
TO 'role_read_classicmodels';

GRANT SELECT
ON user_mgmt_lab.*
TO 'role_read_lab';
```

Gán role con cho role tổng hợp:

```sql
GRANT 'role_read_classicmodels', 'role_read_lab'
TO 'role_data_analyst';
```

Sau đó chỉ cần gán role tổng hợp:

```sql
GRANT 'role_data_analyst'
TO 'lab_analyst'@'localhost';

SET DEFAULT ROLE 'role_data_analyst'
TO 'lab_analyst'@'localhost';
```

### 9.2. Thiết kế role theo job function

Nên thiết kế role theo nhiệm vụ thay vì theo tên người dùng.

Ví dụ tốt:

```text
role_reporting_reader
role_sales_data_entry
role_inventory_manager
role_order_api
role_db_backup_operator
```

Ví dụ khó quản lý:

```text
role_minh
role_student_01
role_user_a
```

### 9.3. Tránh role quá mạnh

Không nên gộp quyền quản trị cao vào role được dùng rộng rãi.

Ví dụ cần cân nhắc rất kỹ:

```sql
GRANT ALL PRIVILEGES
ON *.*
TO 'role_everything';
```

Quyền cần tách nhỏ theo trách nhiệm:

- Reporting chỉ đọc.
- Data entry chỉ thao tác các bảng cần thiết.
- DBA quản lý account và database.
- Backup operator chỉ có các quyền cần thiết cho backup.

### Bài tập thực hành

**Bài 9.1.**

Tạo role `'role_read_classicmodels'` và cấp quyền `SELECT` trên `classicmodels.*`.

**Bài 9.2.**

Tạo role `'role_read_lab'` và cấp quyền `SELECT` trên `user_mgmt_lab.*`.

**Bài 9.3.**

Tạo role `'role_data_analyst'`, sau đó gán hai role đọc ở Bài 9.1 và Bài 9.2 cho role này.

**Bài 9.4.**

Gán `'role_data_analyst'` cho `'lab_analyst'@'localhost'` và đặt làm default role.

**Bài 9.5.**

Thiết kế ba role cho hệ thống bán hàng: reporting reader, order data entry và database administrator. Nêu quyền chính của từng role.

---

# Phần E. Show Privileges

## 10. Kiểm tra quyền bằng `SHOW GRANTS`

### 10.1. Xem quyền của user hiện tại

```sql
SHOW GRANTS;
```

Lệnh này hiển thị grant của account hiện tại.

### 10.2. Xem quyền của một user cụ thể

```sql
SHOW GRANTS FOR 'lab_reader'@'localhost';
```

Ví dụ:

```sql
SHOW GRANTS FOR 'lab_editor'@'localhost';
```

### 10.3. Xem quyền của role

```sql
SHOW GRANTS FOR 'role_reporting';
```

### 10.4. Xem quyền kết hợp với role

Có thể yêu cầu `SHOW GRANTS` hiển thị quyền của account khi dùng các role cụ thể:

```sql
SHOW GRANTS FOR 'lab_analyst'@'localhost'
USING 'role_reporting';
```

Lệnh này hữu ích khi muốn xem effective privilege trong bối cảnh một role cụ thể được dùng.

### 10.5. `SHOW PRIVILEGES`

`SHOW PRIVILEGES` hiển thị danh sách các privilege mà MySQL Server hỗ trợ, không phải danh sách quyền đã cấp cho một user cụ thể.

```sql
SHOW PRIVILEGES;
```

Ví dụ các privilege có thể thấy:

```text
SELECT
INSERT
UPDATE
DELETE
CREATE
DROP
ALTER
INDEX
EXECUTE
CREATE USER
...
```

### 10.6. `SHOW CREATE USER`

```sql
SHOW CREATE USER 'lab_reader'@'localhost';
```

Lệnh này hiển thị statement tạo account và các thuộc tính account mà người dùng có quyền xem.

### 10.7. Lưu ý về quyền xem metadata

Khả năng xem quyền hoặc definition của account khác phụ thuộc vào quyền của account đang kết nối.

Ví dụ, `SHOW GRANTS FOR` current user thường dễ thực hiện hơn việc xem account khác.

### Bài tập thực hành

**Bài 10.1.**

Dùng `SHOW GRANTS;` để xem quyền của account hiện tại.

**Bài 10.2.**

Dùng `SHOW GRANTS FOR 'lab_reader'@'localhost';`.

**Bài 10.3.**

Dùng `SHOW GRANTS FOR 'role_reporting';`.

**Bài 10.4.**

Dùng `SHOW PRIVILEGES;` và nêu ba privilege liên quan đến thao tác dữ liệu.

**Bài 10.5.**

Dùng `SHOW CREATE USER 'lab_editor'@'localhost';` để kiểm tra các thuộc tính account.

---

# Phần F. Change Passwords

## 11. Đổi mật khẩu

### 11.1. Dùng `ALTER USER`

Cách quản trị phổ biến để đổi mật khẩu của một account:

```sql
ALTER USER 'lab_reader'@'localhost'
IDENTIFIED BY 'NewLabReader_2026!';
```

Lệnh này thay đổi mật khẩu của account mục tiêu.

### 11.2. Đổi mật khẩu của account hiện tại

Trong ngữ cảnh phù hợp, user có thể đổi mật khẩu của chính mình:

```sql
SET PASSWORD = 'MyNewPassword_2026!';
```

Cú pháp và quyền cụ thể có thể phụ thuộc vào account, authentication plugin và chính sách server. Trong lab quản trị, `ALTER USER` là cách rõ ràng để administrator quản lý account.

### 11.3. Yêu cầu đổi mật khẩu ở lần đăng nhập tiếp theo

```sql
ALTER USER 'lab_reader'@'localhost'
PASSWORD EXPIRE;
```

Sau đó, account có thể cần đổi mật khẩu trước khi tiếp tục các hoạt động thông thường.

Bỏ trạng thái hết hạn:

```sql
ALTER USER 'lab_reader'@'localhost'
PASSWORD EXPIRE NEVER;
```

Chỉ dùng các tùy chọn password lifecycle theo policy của tổ chức.

### 11.4. Không chia sẻ mật khẩu trong SQL script

Không nên:

- Commit mật khẩu thật vào Git repository.
- Gửi mật khẩu thật qua email/chat công khai.
- Đặt mật khẩu production trong slide hoặc file `.md` công khai.
- Dùng cùng một mật khẩu lab cho production.

Nên:

- Dùng secret manager hoặc vault.
- Dùng biến môi trường trong pipeline.
- Xoay vòng mật khẩu theo policy.
- Giới hạn quyền của account kể cả khi mật khẩu bị lộ.

### Bài tập thực hành

**Bài 11.1.**

Đổi mật khẩu của `'lab_reader'@'localhost'` bằng `ALTER USER`.

**Bài 11.2.**

Đổi mật khẩu của `'lab_editor'@'localhost'` bằng `ALTER USER`.

**Bài 11.3.**

Đặt mật khẩu của `'lab_pending'@'localhost'` ở trạng thái hết hạn bằng `PASSWORD EXPIRE`.

**Bài 11.4.**

Bỏ trạng thái password expired của `'lab_pending'@'localhost'` bằng `PASSWORD EXPIRE NEVER`.

**Bài 11.5.**

Nêu ba lý do không nên lưu mật khẩu production trực tiếp trong file SQL chia sẻ cho nhiều người.

---

# Phần G. Lock and Unlock User Accounts

## 12. Khóa user account

### 12.1. Khóa account bằng `ACCOUNT LOCK`

```sql
ALTER USER 'lab_reader'@'localhost'
ACCOUNT LOCK;
```

Account bị khóa không thể dùng để xác thực kết nối mới.

Khóa account hữu ích khi:

- Nhân viên nghỉ việc hoặc chuyển bộ phận.
- Phát hiện dấu hiệu account bị lộ.
- Tạm ngưng account trong quá trình kiểm tra.
- Chờ hoàn tất quy trình cấp quyền.

### 12.2. Kiểm tra trạng thái account

```sql
SHOW CREATE USER 'lab_reader'@'localhost';
```

Definition hiển thị thuộc tính account lock khi bạn có quyền xem.

### 12.3. Khóa không xóa quyền

`ACCOUNT LOCK` không xóa:

- Privilege trực tiếp.
- Role assignment.
- Definition user.
- Các object do user tạo.

Account chỉ bị chặn xác thực cho đến khi được unlock hoặc bị drop.

### Bài tập thực hành

**Bài 12.1.**

Khóa account `'lab_pending'@'localhost'`.

**Bài 12.2.**

Dùng `SHOW CREATE USER` để kiểm tra trạng thái account của `'lab_pending'@'localhost'`.

**Bài 12.3.**

Khóa account `'lab_reader'@'localhost'`.

**Bài 12.4.**

Nêu hai tình huống nghiệp vụ phù hợp để khóa account thay vì xóa ngay account.

**Bài 12.5.**

Giải thích vì sao khóa account không đồng nghĩa với revoke toàn bộ privilege.

---

## 13. Mở khóa user account

### 13.1. Mở khóa bằng `ACCOUNT UNLOCK`

```sql
ALTER USER 'lab_reader'@'localhost'
ACCOUNT UNLOCK;
```

Sau khi unlock, account có thể đăng nhập lại nếu:

- Mật khẩu đúng.
- Host khớp account.
- Không bị password expiry hoặc ràng buộc authentication khác.
- Có đường mạng/kết nối phù hợp.

### 13.2. Lock và unlock trong quy trình quản trị

Một quy trình đơn giản có thể là:

```text
1. Phát hiện vấn đề hoặc yêu cầu tạm dừng.
2. ACCOUNT LOCK account.
3. Kiểm tra log, quyền, role và password policy.
4. Điều chỉnh GRANT/REVOKE hoặc đổi password nếu cần.
5. ACCOUNT UNLOCK khi đã xác nhận an toàn.
```

### 13.3. Thử nghiệm đăng nhập

Sau khi unlock, kết nối lại bằng account lab:

```bash
mysql -u lab_reader -p -h localhost
```

Sau đó kiểm tra quyền:

```sql
USE user_mgmt_lab;

SELECT *
FROM training_notes;
```

### Bài tập thực hành

**Bài 13.1.**

Mở khóa `'lab_reader'@'localhost'`.

**Bài 13.2.**

Mở khóa `'lab_pending'@'localhost'`.

**Bài 13.3.**

Dùng `SHOW CREATE USER` để kiểm tra account sau khi unlock.

**Bài 13.4.**

Đăng nhập lại bằng `lab_reader` và chạy câu `SELECT` trên bảng `training_notes`.

**Bài 13.5.**

Nêu ba điều kiện ngoài `ACCOUNT UNLOCK` có thể vẫn khiến một account không đăng nhập được.

---

# Phần H. Drop Users

## 14. Xóa user bằng `DROP USER`

### 14.1. Cú pháp

```sql
DROP USER 'user_name'@'host_name';
```

Ví dụ:

```sql
DROP USER 'lab_reader'@'localhost';
```

Sau khi drop:

- Account không thể đăng nhập.
- Privilege và role grants dành cho account bị xóa.
- Account không còn xuất hiện trong account metadata.

### 14.2. Dùng `IF EXISTS`

```sql
DROP USER IF EXISTS 'lab_reader'@'localhost';
```

Cú pháp này thuận tiện cho script dọn dẹp.

### 14.3. Xóa nhiều user

```sql
DROP USER IF EXISTS
    'lab_reader'@'localhost',
    'lab_editor'@'localhost',
    'lab_analyst'@'localhost';
```

### 14.4. Cẩn trọng trước khi drop user

Trước khi xóa account thật, cần kiểm tra:

1. Account có đang được ứng dụng sử dụng không?
2. Account có là `DEFINER` của view, stored routine, trigger hoặc event không?
3. Có cần khóa account trước để chờ xác nhận thay vì xóa ngay không?
4. Có cần lưu audit trail hoặc migration script không?
5. Có các account tương tự khác host không, ví dụ `'app_user'@'localhost'` và `'app_user'@'%'`?

Ví dụ, hai account sau là khác nhau:

```sql
'app_user'@'localhost'
```

```sql
'app_user'@'%'
```

Drop một account không tự động drop account còn lại.

### 14.5. Kiểm tra sau khi drop

```sql
SHOW GRANTS FOR 'lab_reader'@'localhost';
```

Lệnh có thể báo user không tồn tại.

Có thể dùng:

```sql
SHOW CREATE USER 'lab_reader'@'localhost';
```

để xác nhận account đã bị xóa.

### Bài tập thực hành

**Bài 14.1.**

Tạo account tạm `'lab_temp_user'@'localhost'`.

**Bài 14.2.**

Cấp quyền `SELECT` trên `user_mgmt_lab.training_notes` cho account tạm.

**Bài 14.3.**

Dùng `SHOW GRANTS FOR` để kiểm tra quyền account tạm.

**Bài 14.4.**

Xóa account tạm bằng `DROP USER IF EXISTS`.

**Bài 14.5.**

Giải thích vì sao nên kiểm tra `DEFINER` của object trước khi xóa một account production.

---

## 15. Quy trình quản lý account theo nguyên tắc least privilege

Một quy trình đề xuất cho user mới:

### Bước 1. Xác định nhu cầu truy cập

Ví dụ:

```text
Nhân viên BI cần đọc dữ liệu classicmodels.
Không được phép sửa, xóa, tạo bảng hoặc quản lý account.
```

### Bước 2. Tạo role phù hợp

```sql
CREATE ROLE IF NOT EXISTS 'role_bi_reader';
```

### Bước 3. Cấp quyền tối thiểu cho role

```sql
GRANT SELECT
ON classicmodels.*
TO 'role_bi_reader';
```

### Bước 4. Tạo user với host phù hợp

```sql
CREATE USER IF NOT EXISTS 'bi_reader'@'localhost'
IDENTIFIED BY 'BiReader_Lab_2026!';
```

### Bước 5. Gán role và set default role

```sql
GRANT 'role_bi_reader'
TO 'bi_reader'@'localhost';

SET DEFAULT ROLE 'role_bi_reader'
TO 'bi_reader'@'localhost';
```

### Bước 6. Kiểm tra quyền

```sql
SHOW GRANTS FOR 'bi_reader'@'localhost';
```

Kiểm tra bằng chính account `bi_reader`:

```sql
SELECT CURRENT_USER(), CURRENT_ROLE();
```

```sql
SELECT *
FROM classicmodels.customers
LIMIT 5;
```

Thử một thao tác không được cấp quyền, ví dụ:

```sql
DELETE FROM classicmodels.customers
WHERE customerNumber = 103;
```

Câu lệnh phải bị từ chối nếu thiết kế quyền đúng.

### Bước 7. Rà soát định kỳ

- Account còn cần thiết không?
- Role có quá nhiều quyền không?
- Account có đang sử dụng host wildcard quá rộng không?
- Password policy có được tuân thủ không?
- Có cần lock hoặc drop account không?

### Bài tập thực hành

**Bài 15.1.**

Tạo role `'role_bi_reader'`.

**Bài 15.2.**

Cấp quyền `SELECT` trên `classicmodels.*` cho role đó.

**Bài 15.3.**

Tạo user `'bi_reader'@'localhost'` và gán role `'role_bi_reader'`.

**Bài 15.4.**

Đặt `'role_bi_reader'` làm default role cho `'bi_reader'@'localhost'`.

**Bài 15.5.**

Viết ba câu kiểm tra để xác nhận `bi_reader` chỉ đọc được dữ liệu nhưng không được phép xóa dữ liệu.

---

## 16. Một số lỗi thường gặp

### Lỗi 1. Quên phần host của account

Sai hoặc dễ gây nhầm:

```sql
CREATE USER lab_reader
IDENTIFIED BY 'LabReader_2026!';
```

Nên chỉ rõ user và host:

```sql
CREATE USER 'lab_reader'@'localhost'
IDENTIFIED BY 'LabReader_2026!';
```

### Lỗi 2. Nhầm `'user'@'localhost'` và `'user'@'%'`

Hai account này khác nhau:

```sql
'lab_reader'@'localhost'
```

```sql
'lab_reader'@'%'
```

Cấp quyền cho một account không tự động cấp quyền cho account kia.

### Lỗi 3. Cấp quyền quá rộng

Không nên dùng mặc định:

```sql
GRANT ALL PRIVILEGES
ON *.*
TO 'lab_reader'@'%';
```

Thay vào đó, giới hạn:

```sql
GRANT SELECT
ON user_mgmt_lab.training_notes
TO 'lab_reader'@'localhost';
```

### Lỗi 4. Nhầm `SHOW PRIVILEGES` và `SHOW GRANTS`

| Lệnh | Trả về |
|---|---|
| `SHOW PRIVILEGES` | Danh sách loại privilege mà server hỗ trợ |
| `SHOW GRANTS` | Các grant được gán cho user/role |

### Lỗi 5. Quên default role

User có thể đã được gán role nhưng role chưa active theo cách bạn mong đợi ở session mới.

Khắc phục:

```sql
SET DEFAULT ROLE 'role_reporting'
TO 'lab_analyst'@'localhost';
```

### Lỗi 6. Revoke trực tiếp nhưng quên user có role

Nếu user vẫn nhận quyền qua role, một `REVOKE` trực tiếp có thể không loại bỏ quyền effective.

Kiểm tra:

```sql
SHOW GRANTS FOR 'lab_analyst'@'localhost';
```

```sql
SHOW GRANTS FOR 'role_reporting';
```

### Lỗi 7. Dùng `FLUSH PRIVILEGES` không cần thiết

Khi dùng các statement chuẩn như `CREATE USER`, `GRANT`, `REVOKE`, `ALTER USER`, thay đổi quyền có hiệu lực ngay.

Không cập nhật trực tiếp các grant table trong schema `mysql` chỉ để quản lý account thông thường.

### Lỗi 8. Xóa user khi chưa đánh giá object `DEFINER`

Xóa một account có thể ảnh hưởng đến object như view, routine, trigger, event đang dùng account đó làm `DEFINER`.

Trước khi drop account production, kiểm tra dependency và kế hoạch chuyển đổi.

### Bài tập thực hành

**Bài 16.1.**

Giải thích khác nhau giữa `'lab_reader'@'localhost'` và `'lab_reader'@'%'`.

**Bài 16.2.**

Sửa câu `GRANT ALL PRIVILEGES ON *.*` thành grant tối thiểu cho một reporting user.

**Bài 16.3.**

Nêu lệnh dùng để xem loại quyền MySQL hỗ trợ và lệnh dùng để xem quyền của một user cụ thể.

**Bài 16.4.**

Viết lệnh đặt default role cho `'lab_analyst'@'localhost'`.

**Bài 16.5.**

Giải thích vì sao không nên drop production user trước khi kiểm tra object có `DEFINER` là user đó.

---

## 17. Bài tập tổng hợp

### Bài 17.1. Tạo reporting user

Tạo account `'reporting_user'@'localhost'` theo yêu cầu:

1. Có thể đọc `classicmodels.*`.
2. Không được ghi dữ liệu.
3. Quyền được cấp qua role `'role_reporting_classicmodels'`.
4. Role được đặt là default role.
5. Dùng `SHOW GRANTS` để kiểm tra.

---

### Bài 17.2. Tạo data-entry user

Tạo account `'notes_editor'@'localhost'` theo yêu cầu:

1. Có thể đọc, thêm và sửa dữ liệu `user_mgmt_lab.training_notes`.
2. Không được xóa dữ liệu.
3. Không được tạo hoặc xóa bảng.
4. Kiểm tra quyền bằng `SHOW GRANTS`.
5. Đăng nhập bằng account này và thử một câu `DELETE` để xác nhận bị từ chối.

---

### Bài 17.3. Rà soát và thu hồi quyền

Giả sử `'notes_editor'@'localhost'` vô tình được cấp:

```sql
SELECT, INSERT, UPDATE, DELETE
```

Yêu cầu:

1. Viết lệnh kiểm tra quyền hiện có.
2. Thu hồi `DELETE`.
3. Kiểm tra lại quyền.
4. Nêu cách kiểm tra user có nhận `DELETE` qua role hay không.
5. Giải thích vì sao revoke privilege cần được lưu vào migration hoặc audit script.

---

### Bài 17.4. Tạm ngưng account

Giả sử user `'reporting_user'@'localhost'` tạm thời không được phép truy cập trong thời gian kiểm tra.

1. Khóa account.
2. Kiểm tra trạng thái.
3. Nêu các quyền vẫn còn được lưu sau khi account bị lock.
4. Mở khóa account.
5. Kiểm tra user có thể đăng nhập lại và role default hoạt động đúng.

---

### Bài 17.5. Dọn dẹp môi trường lab

Viết script dọn dẹp:

1. Thu hồi hoặc xóa các role lab.
2. Xóa các user lab.
3. Xóa schema `user_mgmt_lab`.
4. Kiểm tra rằng user/role lab không còn tồn tại.
5. Giải thích vì sao script cleanup phải được xem kỹ trước khi chạy.

---

## 18. Đáp án gợi ý cho một số bài tập

### Bài 4.1 và Bài 4.2

```sql
CREATE USER IF NOT EXISTS
    'lab_reader'@'localhost' IDENTIFIED BY 'LabReader_2026!',
    'lab_editor'@'localhost' IDENTIFIED BY 'LabEditor_2026!';
```

### Bài 5.1

```sql
GRANT SELECT
ON user_mgmt_lab.training_notes
TO 'lab_reader'@'localhost';
```

### Bài 5.2

```sql
GRANT SELECT, INSERT, UPDATE, DELETE
ON user_mgmt_lab.training_notes
TO 'lab_editor'@'localhost';
```

### Bài 5.4

```sql
GRANT SELECT
ON classicmodels.*
TO 'lab_reader'@'localhost';
```

### Bài 7.1

```sql
REVOKE DELETE
ON user_mgmt_lab.training_notes
FROM 'lab_editor'@'localhost';
```

### Bài 8.1 đến Bài 8.4

```sql
CREATE ROLE IF NOT EXISTS
    'role_reporting',
    'role_lab_editor';

GRANT SELECT
ON user_mgmt_lab.*
TO 'role_reporting';

GRANT SELECT, INSERT, UPDATE, DELETE
ON user_mgmt_lab.training_notes
TO 'role_lab_editor';

GRANT 'role_reporting'
TO 'lab_analyst'@'localhost';

SET DEFAULT ROLE 'role_reporting'
TO 'lab_analyst'@'localhost';
```

### Bài 9.1 đến Bài 9.4

```sql
CREATE ROLE IF NOT EXISTS
    'role_read_classicmodels',
    'role_read_lab',
    'role_data_analyst';

GRANT SELECT
ON classicmodels.*
TO 'role_read_classicmodels';

GRANT SELECT
ON user_mgmt_lab.*
TO 'role_read_lab';

GRANT 'role_read_classicmodels', 'role_read_lab'
TO 'role_data_analyst';

GRANT 'role_data_analyst'
TO 'lab_analyst'@'localhost';

SET DEFAULT ROLE 'role_data_analyst'
TO 'lab_analyst'@'localhost';
```

### Bài 10.1 đến Bài 10.4

```sql
SHOW GRANTS;

SHOW GRANTS FOR 'lab_reader'@'localhost';

SHOW GRANTS FOR 'role_reporting';

SHOW PRIVILEGES;
```

### Bài 11.1

```sql
ALTER USER 'lab_reader'@'localhost'
IDENTIFIED BY 'NewLabReader_2026!';
```

### Bài 12.1 và Bài 13.1

```sql
ALTER USER 'lab_reader'@'localhost'
ACCOUNT LOCK;

ALTER USER 'lab_reader'@'localhost'
ACCOUNT UNLOCK;
```

### Bài 14.1 đến Bài 14.4

```sql
CREATE USER IF NOT EXISTS 'lab_temp_user'@'localhost'
IDENTIFIED BY 'TempUser_2026!';

GRANT SELECT
ON user_mgmt_lab.training_notes
TO 'lab_temp_user'@'localhost';

SHOW GRANTS FOR 'lab_temp_user'@'localhost';

DROP USER IF EXISTS 'lab_temp_user'@'localhost';
```

### Bài 15.1 đến Bài 15.4

```sql
CREATE ROLE IF NOT EXISTS 'role_bi_reader';

GRANT SELECT
ON classicmodels.*
TO 'role_bi_reader';

CREATE USER IF NOT EXISTS 'bi_reader'@'localhost'
IDENTIFIED BY 'BiReader_Lab_2026!';

GRANT 'role_bi_reader'
TO 'bi_reader'@'localhost';

SET DEFAULT ROLE 'role_bi_reader'
TO 'bi_reader'@'localhost';
```

### Bài 17.1

```sql
CREATE ROLE IF NOT EXISTS 'role_reporting_classicmodels';

GRANT SELECT
ON classicmodels.*
TO 'role_reporting_classicmodels';

CREATE USER IF NOT EXISTS 'reporting_user'@'localhost'
IDENTIFIED BY 'ReportingUser_2026!';

GRANT 'role_reporting_classicmodels'
TO 'reporting_user'@'localhost';

SET DEFAULT ROLE 'role_reporting_classicmodels'
TO 'reporting_user'@'localhost';

SHOW GRANTS FOR 'reporting_user'@'localhost';
SHOW GRANTS FOR 'role_reporting_classicmodels';
```

### Bài 17.2

```sql
CREATE USER IF NOT EXISTS 'notes_editor'@'localhost'
IDENTIFIED BY 'NotesEditor_2026!';

GRANT SELECT, INSERT, UPDATE
ON user_mgmt_lab.training_notes
TO 'notes_editor'@'localhost';

SHOW GRANTS FOR 'notes_editor'@'localhost';
```

### Bài 17.3

```sql
SHOW GRANTS FOR 'notes_editor'@'localhost';

REVOKE DELETE
ON user_mgmt_lab.training_notes
FROM 'notes_editor'@'localhost';

SHOW GRANTS FOR 'notes_editor'@'localhost';
```

### Bài 17.4

```sql
ALTER USER 'reporting_user'@'localhost'
ACCOUNT LOCK;

SHOW CREATE USER 'reporting_user'@'localhost';

ALTER USER 'reporting_user'@'localhost'
ACCOUNT UNLOCK;
```

---

## 19. Script dọn dẹp sau lab

> **Cảnh báo:** Chỉ chạy script này khi chắc chắn các account, role và schema dưới đây chỉ phục vụ lab.

```sql
DROP USER IF EXISTS
    'lab_reader'@'localhost',
    'lab_editor'@'localhost',
    'lab_analyst'@'localhost',
    'lab_pending'@'localhost',
    'lab_locked'@'localhost',
    'lab_password_reset'@'localhost',
    'lab_temp_user'@'localhost',
    'bi_reader'@'localhost',
    'reporting_user'@'localhost',
    'notes_editor'@'localhost';

DROP ROLE IF EXISTS
    'role_reporting',
    'role_lab_editor',
    'role_read_classicmodels',
    'role_read_lab',
    'role_data_analyst',
    'role_bi_reader',
    'role_reporting_classicmodels';

DROP DATABASE IF EXISTS user_mgmt_lab;
```

Kiểm tra một role hoặc user lab sau cleanup:

```sql
SHOW GRANTS FOR 'lab_reader'@'localhost';
```

```sql
SHOW GRANTS FOR 'role_reporting';
```

Các lệnh trên có thể báo đối tượng không tồn tại, đó là kết quả mong đợi sau khi dọn dẹp.

---

## 20. Tóm tắt

Các kiến thức chính:

- Account MySQL có dạng `'user_name'@'host_name'`.
- `CREATE USER` tạo account; tạo account không tự cấp quyền dữ liệu.
- `GRANT` cấp privilege ở mức global, database, table, column hoặc routine.
- `REVOKE` thu hồi privilege hoặc role.
- Role là tập hợp quyền có tên, giúp quản lý quyền nhất quán cho nhiều user.
- Sau khi gán role, dùng `SET DEFAULT ROLE` để role được active mặc định trong session mới.
- `SHOW GRANTS` hiển thị grant của user hoặc role; `SHOW PRIVILEGES` hiển thị các loại privilege MySQL hỗ trợ.
- `ALTER USER ... IDENTIFIED BY` thay đổi mật khẩu.
- `ALTER USER ... ACCOUNT LOCK` khóa account; `ACCOUNT UNLOCK` mở lại account.
- `DROP USER` xóa account; cần đánh giá dependency, đặc biệt object có `DEFINER`, trước khi xóa account production.
- Dùng least privilege: chỉ cấp quyền cần thiết, ở phạm vi nhỏ nhất, cho host phù hợp.
- Các statement quản lý account chuẩn như `CREATE USER`, `GRANT`, `REVOKE`, `ALTER USER` có hiệu lực ngay; không cần chỉnh trực tiếp grant tables.

---

## 21. Từ khóa chính

- User Management
- MySQL Account
- User Name
- Host Name
- Authentication
- Authorization
- Privilege
- Least Privilege
- CREATE USER
- ALTER USER
- DROP USER
- GRANT
- REVOKE
- SHOW GRANTS
- SHOW PRIVILEGES
- SHOW CREATE USER
- Role
- CREATE ROLE
- DROP ROLE
- SET DEFAULT ROLE
- SET ROLE
- CURRENT_ROLE()
- Password Expiration
- ACCOUNT LOCK
- ACCOUNT UNLOCK
- DEFINER
- classicmodels
