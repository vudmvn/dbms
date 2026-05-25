---
layout: page
title: "Các loại kiến trúc DBMS"
---

# Các loại kiến trúc DBMS

**Cập nhật lần cuối:** 24/04/2026

---

## 1. Mục tiêu bài giảng

Sau khi hoàn thành bài học này, người học có thể:

1. Trình bày được khái niệm **kiến trúc DBMS**.
2. Phân biệt được các mô hình kiến trúc **1 tầng**, **2 tầng** và **3 tầng**.
3. Giải thích được vai trò của từng tầng trong hệ thống cơ sở dữ liệu.
4. Phân tích được ưu điểm và nhược điểm của từng loại kiến trúc DBMS.
5. Lựa chọn được kiến trúc DBMS phù hợp cho một số tình huống ứng dụng thực tế.

---

## 2. Khái niệm kiến trúc DBMS

Kiến trúc của một hệ quản trị cơ sở dữ liệu (**DBMS architecture**) mô tả cách người dùng tương tác với cơ sở dữ liệu để **đọc**, **ghi**, **cập nhật** hoặc **truy vấn** thông tin.

Một kiến trúc DBMS được thiết kế tốt, kết hợp với **lược đồ cơ sở dữ liệu** hợp lý, giúp hệ thống:

- Đảm bảo tính nhất quán của dữ liệu.
- Cải thiện hiệu năng xử lý.
- Tăng cường bảo mật dữ liệu.
- Hỗ trợ nhiều người dùng và nhiều ứng dụng cùng truy cập dữ liệu.
- Dễ bảo trì và mở rộng hệ thống.

Trong cơ sở dữ liệu, **schema** hay **lược đồ cơ sở dữ liệu** là bản thiết kế mô tả:

- Các bảng dữ liệu.
- Các trường dữ liệu.
- Kiểu dữ liệu.
- Khóa chính, khóa ngoại.
- Quan hệ giữa các bảng.

---

## 3. Kiến trúc 1 tầng

### 3.1. Khái niệm

Trong kiến trúc **1 tầng** (*1-Tier Architecture*), người dùng làm việc trực tiếp với cơ sở dữ liệu trên cùng một hệ thống. Điều này có nghĩa là:

- Giao diện người dùng,
- Logic xử lý,
- Và dữ liệu

đều nằm trong cùng một ứng dụng hoặc cùng một máy tính.

Người dùng có thể mở ứng dụng, nhập dữ liệu, xử lý dữ liệu và lưu trữ dữ liệu trực tiếp mà không cần máy chủ riêng hoặc kết nối mạng.
![alt text](images/image-1.png)
