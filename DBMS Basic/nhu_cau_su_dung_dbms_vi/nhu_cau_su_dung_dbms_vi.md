?---
layout: page
title: "Nhu cầu sử dụng DBMS"
---

# Nhu cầu sử dụng DBMS

*Cập nhật lần cuối: 24/04/2026*

Hệ quản trị cơ sở dữ liệu (**Database Management System – DBMS**) là phần mềm cho phép lưu trữ, tổ chức và quản lý lượng dữ liệu lớn. DBMS đảm bảo tính nhất quán, toàn vẹn và bảo mật của dữ liệu, đồng thời cho phép nhiều người dùng truy cập và thao tác với dữ liệu.

## Các lợi ích chính của DBMS

- **Tổ chức và quản lý dữ liệu:** Giúp dữ liệu dễ tìm kiếm và dễ sử dụng thông qua các tính năng như lập chỉ mục và tìm kiếm nhanh.
- **Bảo mật và quyền riêng tư dữ liệu:** Bảo vệ dữ liệu bằng cơ chế đăng nhập, mã hóa và các quy tắc kiểm soát truy cập nghiêm ngặt.
- **Cải thiện khả năng khai thác thông tin:** Giúp chuyển đổi dữ liệu thô thành thông tin hữu ích, hỗ trợ ra quyết định nhanh hơn.
- **Tiết kiệm thời gian và chi phí:** Giảm chi phí bằng cách hạn chế trùng lặp dữ liệu và hoạt động hiệu quả hơn so với các hệ thống tệp truyền thống.
![alt text](images/image.png)
## Tầm quan trọng của DBMS

DBMS đóng vai trò quan trọng trong việc quản lý dữ liệu hiện đại. Thay vì lưu trữ dữ liệu rời rạc trong nhiều tệp riêng biệt, DBMS cung cấp một môi trường tập trung, có tổ chức và an toàn hơn để lưu trữ, truy vấn, cập nhật và phân tích dữ liệu.

## Hệ thống tệp truyền thống

Trong một hệ thống tệp thông thường, dữ liệu được lưu trữ và truy xuất thông qua các tệp.

Ví dụ, một công ty có thể lưu các tệp riêng biệt cho:

- Thông tin nhân viên;
- Thông tin khách hàng;
- Doanh số bán hàng hằng ngày.

Các tệp này có thể được lưu dưới dạng tài liệu văn bản, bảng tính hoặc hồ sơ giấy trong tủ tài liệu.

Một số đặc điểm của hệ thống tệp truyền thống gồm:

- Dễ tạo và quản lý tệp mà không cần phần mềm chuyên dụng.
- Không cần đầu tư thêm công cụ hoặc đào tạo chuyên sâu để sử dụng hệ thống tệp.
- Người dùng có thể truy cập trực tiếp các tệp từ thiết bị lưu trữ.

Tuy nhiên, khi lượng dữ liệu tăng lên và có nhiều người dùng cùng làm việc, hệ thống tệp truyền thống thường gặp nhiều hạn chế về trùng lặp dữ liệu, tính nhất quán, bảo mật và khả năng truy vấn.

## Ưu điểm của DBMS so với hệ thống tệp

### 1. Giảm dư thừa dữ liệu

Dữ liệu được lưu trữ tại một vị trí tập trung, nhờ đó loại bỏ sự sao chép không cần thiết.

**Ví dụ:** Thông tin khách hàng được lưu trong một cơ sở dữ liệu trung tâm và có thể được truy cập bởi tất cả các bộ phận liên quan.

### 2. Cải thiện tính toàn vẹn và nhất quán của dữ liệu

Những thay đổi trong cơ sở dữ liệu sẽ được phản ánh trên tất cả các điểm dữ liệu liên quan.

**Ví dụ:** Nếu địa chỉ của khách hàng được cập nhật, tất cả các đơn hàng liên quan sẽ phản ánh địa chỉ mới.

### 3. Tăng cường bảo mật

DBMS cung cấp cơ chế truy cập dựa trên vai trò, đảm bảo chỉ người dùng được cấp quyền mới có thể xem hoặc chỉnh sửa dữ liệu.

**Ví dụ:** Chỉ nhân viên phòng nhân sự mới có quyền truy cập thông tin lương của nhân viên.

### 4. Hỗ trợ quan hệ giữa các dữ liệu

DBMS quan hệ cho phép liên kết các điểm dữ liệu với nhau, giúp việc quản lý các mối quan hệ trở nên dễ dàng hơn.

**Ví dụ:** Khách hàng và đơn hàng của họ có thể được liên kết thông qua một mã định danh gọi là `customer ID`.

### 5. Độc lập dữ liệu

DBMS cung cấp tính độc lập dữ liệu ở mức logic và vật lý. Điều này có nghĩa là các thay đổi về lược đồ hoặc cách lưu trữ dữ liệu không nhất thiết ảnh hưởng đến chương trình ứng dụng.

**Ví dụ:** Có thể tạo chỉ mục trên trường `CustomerID` để tăng tốc độ tìm kiếm mà không cần thay đổi các câu truy vấn trong ứng dụng.

### 6. Tối ưu hóa truy vấn

DBMS sử dụng bộ tối ưu hóa truy vấn dựa trên chi phí để chọn kế hoạch thực thi hiệu quả nhất cho các câu truy vấn SQL.

**Ví dụ:** Sử dụng `CustomerID` để nhanh chóng tìm các đơn hàng của một khách hàng thay vì quét toàn bộ bảng.

## Vai trò của DBMS

DBMS có các vai trò chính sau:

- Quản lý dữ liệu hiệu quả thông qua cơ chế lưu trữ và truy xuất được tối ưu hóa.
- Cung cấp các ngôn ngữ truy vấn đơn giản như SQL.
- Đảm bảo tính nhất quán dữ liệu và kiểm soát truy cập đồng thời thông qua cơ chế giao dịch.
- Thực thi các chính sách bảo mật mạnh mẽ bằng các cơ chế kiểm soát truy cập tích hợp sẵn.

## Ứng dụng của hệ thống tệp

Hệ thống tệp được dùng để lưu trữ và tổ chức các tệp thô trên thiết bị lưu trữ. Do không có khả năng truy vấn nâng cao hoặc quản lý quan hệ dữ liệu phức tạp, hệ thống tệp phù hợp với các trường hợp sử dụng đơn giản, ít người dùng truy cập đồng thời.

### 1. Máy tính cá nhân

Hệ thống tệp được dùng để lưu trữ các tệp hằng ngày như tài liệu, ảnh và video.

**Ví dụ:** NTFS được dùng trên Windows để quản lý các thư mục cá nhân, còn ext4 được dùng trên Linux cho các thư mục người dùng.

### 2. Hệ thống nhúng

Hệ thống tệp phù hợp với việc ghi nhật ký dữ liệu cơ bản trong các hệ thống có tài nguyên hạn chế.

**Ví dụ:** Thiết bị IoT hoặc bộ định tuyến có thể lưu nhật ký firmware trên bộ nhớ flash mà không cần dùng SQL.

### 3. Phân phối nội dung

Hệ thống tệp có thể được dùng để phục vụ nội dung tĩnh như hình ảnh và video.

**Ví dụ:** NFS được dùng để chia sẻ các tệp media giữa các máy chủ web nhỏ trong cùng một mạng.

