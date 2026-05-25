---
layout: page
title: "Giới thiệu về DBMS"
---

# Giới thiệu về DBMS

*Cập nhật lần cuối: 14/05/2026*

DBMS (*Database Management System* - Hệ quản trị cơ sở dữ liệu) là một hệ thống phần mềm dùng để quản lý, lưu trữ và truy xuất dữ liệu một cách hiệu quả theo định dạng có cấu trúc. DBMS đóng vai trò như một cầu nối giữa cơ sở dữ liệu trung tâm và nhiều phía sử dụng khác nhau, bao gồm ứng dụng và người dùng.

Một hệ quản trị cơ sở dữ liệu có thể:

- Kết nối cơ sở dữ liệu trung tâm với nhiều phía sử dụng, bao gồm ứng dụng và người dùng.
- Cho phép người dùng tạo, cập nhật và truy vấn cơ sở dữ liệu một cách hiệu quả.
- Đảm bảo tính toàn vẹn, tính nhất quán và tính bảo mật của dữ liệu khi có nhiều người dùng và ứng dụng cùng sử dụng.
- Giảm dư thừa dữ liệu và tình trạng dữ liệu không nhất quán thông qua cơ chế quản lý tập trung.
- Hỗ trợ truy cập đồng thời, quản lý giao dịch và sao lưu tự động.
- Sử dụng API để xử lý các yêu cầu dữ liệu, từ đó đảm bảo truy cập an toàn và hiệu quả.

![alt text](images/image-1.png)
---

## 1. Các vấn đề của hệ thống quản lý tệp truyền thống

Trước khi các hệ quản trị cơ sở dữ liệu hiện đại ra đời, dữ liệu thường được quản lý bằng các hệ thống tệp cơ bản trên ổ cứng. Cách tiếp cận này cho phép người dùng lưu trữ, truy xuất và cập nhật tệp khi cần, nhưng cũng phát sinh nhiều hạn chế.

Các vấn đề thường gặp gồm:

- **Dư thừa dữ liệu**: Cùng một thông tin có thể bị lặp lại trong nhiều tệp khác nhau.
- **Không nhất quán dữ liệu**: Thông tin giữa các tệp có thể mâu thuẫn hoặc lỗi thời.
- **Khó truy cập dữ liệu**: Người dùng phải tìm kiếm thủ công trong các tệp.
- **Bảo mật kém**: Không có cơ chế kiểm soát quyền truy cập dữ liệu rõ ràng.
- **Thiếu hỗ trợ đa người dùng**: Không hỗ trợ tốt việc nhiều người cùng làm việc hoặc cộng tác trên dữ liệu.
- **Không có cơ chế sao lưu và phục hồi**: Khi dữ liệu bị mất, việc khôi phục thường rất khó hoặc không thể thực hiện.

Ví dụ, một hệ thống quản lý dữ liệu trong trường đại học theo kiểu tệp, trong đó dữ liệu được lưu riêng trong các tệp như *Academics*, *Results*, *Hostels*, thường gặp các vấn đề nêu trên.

![alt text](images/image-2.png)
