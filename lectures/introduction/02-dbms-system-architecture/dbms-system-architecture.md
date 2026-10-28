---
layout: page
title: "Các loại kiến trúc DBMS"
---

# Các loại kiến trúc DBMS

**Cập nhật lần cuối:** 24/04/2026

**Nguồn tham khảo:** GeeksforGeeks - [DBMS Architecture 1-level, 2-Level, 3-Level](https://www.geeksforgeeks.org/dbms-architecture-2-level-3-level/)

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
### 3.2. Ví dụ

Một ví dụ phổ biến của kiến trúc 1 tầng là **Microsoft Access**.

Trong MS Access:

- Người dùng nhập dữ liệu trực tiếp.
- Ứng dụng xử lý các thao tác tính toán hoặc truy vấn.
- Dữ liệu được lưu trực tiếp trên máy tính cá nhân.
- Không cần máy chủ cơ sở dữ liệu riêng.

Kiến trúc này phù hợp với các ứng dụng cá nhân, ứng dụng độc lập hoặc hệ thống nhỏ.

### 3.3. Ưu điểm

1. **Kiến trúc đơn giản**

   Chỉ cần một máy tính để cài đặt, vận hành và bảo trì hệ thống.

2. **Chi phí thấp**

   Không cần đầu tư thêm máy chủ, hạ tầng mạng hoặc phần cứng phức tạp.

3. **Dễ triển khai**

   Phù hợp với các dự án nhỏ, bài thực hành cá nhân hoặc ứng dụng nội bộ đơn giản.

4. **Không phụ thuộc vào mạng**

   Người dùng có thể làm việc trực tiếp trên máy tính cá nhân mà không cần kết nối đến máy chủ.

### 3.4. Nhược điểm

1. **Chỉ phù hợp với một người dùng**

   Kiến trúc này không được thiết kế tốt cho môi trường nhiều người dùng hoặc làm việc nhóm.

2. **Bảo mật kém**

   Vì ứng dụng và dữ liệu đều nằm trên cùng một máy, nếu người khác truy cập được vào máy tính thì họ có thể truy cập cả chương trình và dữ liệu.

3. **Không có kiểm soát tập trung**

   Dữ liệu được lưu cục bộ, không có cơ sở dữ liệu trung tâm. Điều này gây khó khăn cho việc quản lý, sao lưu và đồng bộ dữ liệu.

4. **Khó chia sẻ dữ liệu**

   Vì dữ liệu nằm trên một máy tính, việc chia sẻ dữ liệu với người khác hoặc thiết bị khác không thuận tiện.

---

### Quiz nhanh: Kiến trúc 1 tầng

**Câu 1.** Một nhân viên dùng ứng dụng quản lý kho trên đúng một laptop; giao diện, xử lý nghiệp vụ và dữ liệu đều ở máy đó. Khi muốn cho ba nhân viên khác cùng cập nhật dữ liệu theo thời gian thực, hạn chế nào cần được xem xét trước tiên?

A. Kiến trúc thiếu cơ chế chia sẻ và điều phối truy cập tập trung cho nhiều người dùng.
B. Máy không thể lưu bất kỳ dữ liệu nào.
C. Ứng dụng không thể hiển thị giao diện.
D. Người dùng bắt buộc phải dùng ODBC/JDBC.

**Câu 2.** Một doanh nghiệp chọn kiến trúc 1 tầng cho phần mềm cá nhân chạy offline. Quyết định này hợp lý nhất khi điều kiện nào đúng?

A. Có hàng nghìn người dùng đồng thời từ Internet.
B. Dữ liệu cần được nhiều chi nhánh cập nhật liên tục.
C. Hệ thống nhỏ, một hoặc rất ít người dùng và không cần chia sẻ qua mạng.
D. Cần tách logic nghiệp vụ khỏi mọi máy người dùng.

**Câu 3.** Một máy tính chạy ứng dụng 1 tầng bị sao chép toàn bộ thư mục ứng dụng và dữ liệu bởi người không được phép. Rủi ro này phản ánh rõ nhất nhược điểm nào?

A. Khó tạo giao diện người dùng.
B. Bảo mật và kiểm soát truy cập bị hạn chế do dữ liệu nằm cục bộ cùng ứng dụng.
C. Không thể thực hiện truy vấn dữ liệu.
D. Không thể sao lưu dữ liệu.


---

## 4. Kiến trúc 2 tầng

### 4.1. Khái niệm

Kiến trúc **2 tầng** (*2-Tier Architecture*) tương tự mô hình **client-server** cơ bản.

Trong mô hình này:

- Tầng thứ nhất là **client**, nơi chạy giao diện người dùng và chương trình ứng dụng.
- Tầng thứ hai là **database server**, nơi lưu trữ và xử lý dữ liệu.

Ứng dụng phía client giao tiếp trực tiếp với cơ sở dữ liệu ở phía server. Các API như **ODBC** và **JDBC** thường được sử dụng để hỗ trợ quá trình kết nối này.

Phía server chịu trách nhiệm:

- Xử lý truy vấn.
- Quản lý giao dịch.
- Lưu trữ dữ liệu.
- Trả kết quả về cho client.
![alt text](images/image-2.png)
### 4.2. Ví dụ

Một ví dụ điển hình của kiến trúc 2 tầng là **hệ thống quản lý thư viện** trong trường học hoặc tổ chức nhỏ.

#### Tầng client

Đây là giao diện mà nhân viên thư viện hoặc người dùng tương tác. Ví dụ, họ có thể dùng một ứng dụng desktop để:

- Tìm kiếm sách.
- Mượn sách.
- Trả sách.
- Kiểm tra hạn trả sách.

#### Tầng cơ sở dữ liệu

Máy chủ cơ sở dữ liệu lưu trữ:

- Thông tin sách.
- Thông tin người dùng.
- Lịch sử mượn trả.
- Nhật ký giao dịch.

Khi người dùng tìm kiếm một cuốn sách, tầng client gửi yêu cầu đến tầng cơ sở dữ liệu. Máy chủ xử lý yêu cầu và gửi kết quả trở lại cho client.

### 4.3. Ưu điểm

1. **Truy cập dữ liệu nhanh**

   Client có thể gửi truy vấn trực tiếp đến server, giúp việc lấy dữ liệu tương đối nhanh trong các hệ thống nhỏ hoặc vừa.

2. **Chi phí thấp hơn kiến trúc 3 tầng**

   Kiến trúc 2 tầng không cần thêm tầng ứng dụng trung gian, do đó chi phí triển khai thấp hơn.

3. **Dễ triển khai**

   Mô hình chỉ gồm client và server nên dễ cài đặt hơn kiến trúc nhiều tầng.

4. **Đơn giản**

   Hệ thống chỉ gồm hai thành phần chính: ứng dụng phía client và cơ sở dữ liệu phía server.

### 4.4. Nhược điểm

1. **Khả năng mở rộng hạn chế**

   Khi số lượng người dùng tăng, server có thể bị quá tải do phải xử lý quá nhiều kết nối trực tiếp từ client.

2. **Vấn đề bảo mật**

   Client kết nối trực tiếp đến cơ sở dữ liệu, do đó hệ thống dễ gặp rủi ro về tấn công hoặc rò rỉ dữ liệu nếu kiểm soát truy cập không tốt.

3. **Liên kết chặt giữa client và database**

   Nếu cấu trúc cơ sở dữ liệu thay đổi, ứng dụng phía client thường cũng cần được cập nhật.

4. **Khó bảo trì**

   Việc cập nhật phần mềm, sửa lỗi hoặc bổ sung tính năng trở nên phức tạp hơn khi số lượng client tăng.

---

### Quiz nhanh: Kiến trúc 2 tầng

**Câu 1.** Một ứng dụng desktop tại thư viện gửi yêu cầu tìm sách trực tiếp đến database server trong mạng nội bộ. Khi thay đổi quy tắc tính tiền phạt, đội kỹ thuật phải cập nhật nhiều máy client. Điều này phản ánh nhược điểm nào của kiến trúc 2 tầng?

A. Database server không thể lưu dữ liệu.
B. Client và database có mức liên kết chặt, làm việc bảo trì/triển khai trên nhiều client phức tạp hơn.
C. Client không thể gửi truy vấn qua mạng.
D. Hệ thống thiếu hoàn toàn tầng giao diện.

**Câu 2.** Một database server bắt đầu chậm khi số lượng ứng dụng client kết nối trực tiếp tăng mạnh. Nguyên nhân phù hợp nhất là gì?

A. Server phải xử lý nhiều kết nối và yêu cầu trực tiếp từ client.
B. Client đã bị loại khỏi kiến trúc.
C. Tầng ứng dụng trung gian đang xử lý quá tải.
D. Dữ liệu không còn được lưu trên server.

**Câu 3.** Vì sao kiến trúc 2 tầng thường phù hợp hơn với hệ thống nội bộ nhỏ hoặc vừa so với một website Internet lớn?

A. Vì 2 tầng không dùng mạng.
B. Vì database server không cần bảo mật.
C. Vì client chỉ chạy được trên một máy duy nhất.
D. Mô hình đơn giản và trực tiếp, nhưng việc để nhiều client kết nối thẳng vào database khó mở rộng và kiểm soát hơn ở quy mô lớn.


---

## 5. Kiến trúc 3 tầng

### 5.1. Khái niệm

Trong kiến trúc **3 tầng** (*3-Tier Architecture*), có thêm một tầng trung gian giữa client và database server.

Ba tầng chính gồm:

1. **Tầng trình bày** (*Presentation Layer*)
2. **Tầng ứng dụng hoặc tầng xử lý nghiệp vụ** (*Application / Business Logic Layer*)
3. **Tầng cơ sở dữ liệu** (*Database Layer*)

Trong mô hình này, client không giao tiếp trực tiếp với cơ sở dữ liệu. Thay vào đó:

1. Client gửi yêu cầu đến application server.
2. Application server xử lý logic nghiệp vụ.
3. Application server gửi truy vấn đến database server khi cần.
4. Database server trả dữ liệu về application server.
5. Application server xử lý kết quả và gửi phản hồi về client.

Tầng trung gian đóng vai trò là cầu nối giữa người dùng và cơ sở dữ liệu.

Kiến trúc này thường được sử dụng trong các ứng dụng web lớn, hệ thống doanh nghiệp, thương mại điện tử, ngân hàng trực tuyến và các hệ thống cần nhiều người dùng truy cập đồng thời.
![alt text](images/image-3.png)
### 5.2. Ví dụ: Cửa hàng thương mại điện tử

Giả sử người dùng truy cập một cửa hàng trực tuyến.

#### Người dùng

Người dùng truy cập website, tìm kiếm sản phẩm và thêm sản phẩm vào giỏ hàng.

#### Tầng xử lý

Hệ thống xử lý các công việc như:

- Kiểm tra sản phẩm còn hàng hay không.
- Tính tổng giá trị đơn hàng.
- Áp dụng mã giảm giá.
- Tính phí vận chuyển.
- Xác thực tài khoản người dùng.

#### Tầng cơ sở dữ liệu

Cơ sở dữ liệu lưu trữ:

- Thông tin sản phẩm.
- Thông tin khách hàng.
- Giỏ hàng.
- Lịch sử đơn hàng.
- Trạng thái thanh toán.

### 5.3. Ưu điểm

1. **Khả năng mở rộng tốt hơn**

   Vì tầng ứng dụng có thể được triển khai phân tán trên nhiều máy chủ, hệ thống dễ mở rộng khi số lượng người dùng tăng.

2. **Tăng tính toàn vẹn dữ liệu**

   Tầng trung gian kiểm soát dữ liệu trước khi gửi đến database, giúp giảm nguy cơ dữ liệu sai hoặc dữ liệu không hợp lệ.

3. **Bảo mật tốt hơn**

   Client không truy cập trực tiếp vào cơ sở dữ liệu. Điều này giúp giảm nguy cơ truy cập trái phép vào dữ liệu quan trọng.

4. **Dễ bảo trì hơn**

   Logic nghiệp vụ được đặt ở tầng ứng dụng, nên khi cần thay đổi quy trình xử lý, lập trình viên có thể cập nhật tầng ứng dụng mà không nhất thiết phải thay đổi client hoặc database.

5. **Phù hợp với ứng dụng lớn**

   Kiến trúc 3 tầng phù hợp với hệ thống có nhiều người dùng, nhiều chức năng và yêu cầu bảo mật cao.

### 5.4. Nhược điểm

1. **Phức tạp hơn**

   So với kiến trúc 2 tầng, kiến trúc 3 tầng có thêm một tầng trung gian nên thiết kế, triển khai và vận hành phức tạp hơn.

2. **Khó tương tác hơn**

   Dữ liệu phải đi qua nhiều tầng, do đó việc thiết kế giao tiếp giữa các tầng cần được thực hiện cẩn thận.

3. **Thời gian phản hồi có thể chậm hơn**

   Vì yêu cầu phải đi qua application server trước khi đến database server, thời gian phản hồi có thể lâu hơn so với kiến trúc 2 tầng trong một số trường hợp.

4. **Chi phí cao hơn**

   Cần thêm phần cứng, phần mềm và nhân lực có chuyên môn để thiết lập, vận hành và bảo trì hệ thống.

---

### Quiz nhanh: Kiến trúc 3 tầng

**Câu 1.** Trong website thương mại điện tử, thao tác “kiểm tra tồn kho, áp mã giảm giá, xác thực người dùng rồi mới gửi yêu cầu lưu đơn hàng” nên nằm chủ yếu ở đâu?

A. Tầng ứng dụng / business logic.
B. Tầng trình bày trên trình duyệt.
C. Tầng cơ sở dữ liệu duy nhất.
D. Thiết bị mạng của người dùng.

**Câu 2.** Một công ty muốn thay đổi quy tắc miễn phí vận chuyển mà không phát hành lại ứng dụng mobile cho toàn bộ khách hàng. Lợi ích kiến trúc 3 tầng nào hỗ trợ tốt nhất?

A. Client có thể ghi trực tiếp vào database.
B. Logic nghiệp vụ được tách ở tầng ứng dụng nên có thể cập nhật tập trung.
C. Database không còn cần lưu dữ liệu.
D. Hệ thống không còn cần quản lý quyền truy cập.

**Câu 3.** Đổi lại cho lợi ích mở rộng và bảo mật, kiến trúc 3 tầng thường phát sinh chi phí hoặc độ phức tạp nào?

A. Không thể triển khai trên mạng.
B. Không thể dùng cho ứng dụng web.
C. Phải thiết kế, vận hành và giám sát thêm tầng ứng dụng cùng giao tiếp giữa các tầng.
D. Client buộc phải truy cập trực tiếp database.


---

## 6. Bảng so sánh các loại kiến trúc DBMS

| Tiêu chí | Kiến trúc 1 tầng | Kiến trúc 2 tầng | Kiến trúc 3 tầng |
|---|---|---|---|
| Số tầng chính | 1 | 2 | 3 |
| Thành phần | Ứng dụng và dữ liệu cùng một máy | Client và database server | Client, application server và database server |
| Cách client truy cập dữ liệu | Trực tiếp trên máy cục bộ | Trực tiếp đến database server | Thông qua application server |
| Ví dụ | MS Access cá nhân | Hệ thống quản lý thư viện nhỏ | Website thương mại điện tử |
| Khả năng mở rộng | Thấp | Trung bình | Cao |
| Bảo mật | Thấp | Trung bình | Tốt hơn |
| Chi phí | Thấp | Trung bình | Cao hơn |
| Độ phức tạp | Thấp | Trung bình | Cao |
| Phù hợp với | Cá nhân, ứng dụng nhỏ | Tổ chức nhỏ hoặc vừa | Hệ thống lớn, ứng dụng web, doanh nghiệp |

---

## 7. Câu hỏi ôn tập

### 7.1. Câu hỏi trắc nghiệm

**Câu 1.** Một ứng dụng desktop nội bộ được triển khai cho 20 nhân viên. Mỗi client kết nối trực tiếp database server. Khi thay đổi cách kiểm tra dữ liệu, đội kỹ thuật phải cập nhật từng máy. Kiến trúc hiện tại có khả năng cao là:

A. 1 tầng.
B. 3 tầng.
C. 2 tầng.
D. File-based system không có server.

**Câu 2.** Một hệ thống có client, application server và database server. Nếu database schema thay đổi nhưng API của application server được giữ ổn định, bên nào thường ít bị ảnh hưởng trực tiếp nhất?

A. Client/presentation layer.
B. Database server.
C. Tầng ứng dụng.
D. Toàn bộ client bắt buộc phải sửa ngay.

**Câu 3.** Một nhóm đề xuất cho trình duyệt web kết nối thẳng database server để “bỏ bớt một tầng cho nhanh”. Rủi ro chính cần đánh giá là gì?

A. Trình duyệt sẽ không hiển thị HTML.
B. Database không thể xử lý truy vấn.
C. Không thể triển khai website trên Internet.
D. Khó kiểm soát bảo mật, logic nghiệp vụ và kết nối trực tiếp từ số lượng lớn client.

**Câu 4.** Một hệ thống 3 tầng có response time tăng. Kết luận nào hợp lý nhất?

A. Cần đo từng tầng; độ trễ có thể đến từ client, mạng, application server hoặc database.
B. Kiến trúc 3 tầng luôn chậm hơn 2 tầng và không thể tối ưu.
C. Database chắc chắn là nguyên nhân duy nhất.
D. Chỉ cần bỏ toàn bộ tầng ứng dụng.

**Câu 5.** Lý do nào giải thích đúng nhất vì sao tầng ứng dụng giúp tăng bảo mật trong 3 tầng?

A. Nó loại bỏ mọi nhu cầu xác thực người dùng.
B. Nó che database hoàn toàn khỏi đội vận hành.
C. Nó làm database không còn lưu dữ liệu nhạy cảm.
D. Nó tạo điểm kiểm soát trung tâm để xác thực, phân quyền và giới hạn yêu cầu trước khi truy cập database.

**Câu 6.** Một cửa hàng nhỏ chỉ có chủ cửa hàng dùng một máy tính, không cần truy cập từ xa, muốn chi phí thấp và triển khai nhanh. Lựa chọn hợp lý nhất là:

A. Kiến trúc 3 tầng có nhiều application server.
B. Kiến trúc 1 tầng.
C. Kiến trúc 2 tầng với nhiều database replicas.
D. Microservices bắt buộc.

**Câu 7.** Khi chọn giữa 2 tầng và 3 tầng, tiêu chí nào có giá trị nhất?

A. Chỉ dựa vào số màu của giao diện.
B. Quy mô người dùng, yêu cầu bảo mật, mức độ thay đổi logic nghiệp vụ, khả năng mở rộng và năng lực vận hành.
C. Chỉ dựa vào loại hệ điều hành client.
D. Luôn chọn 3 tầng vì có nhiều tầng hơn.

**Câu 8.** Trong kiến trúc 2 tầng, ODBC/JDBC đóng vai trò gần đúng nhất là gì?

A. Công cụ vẽ giao diện người dùng.
B. Hệ thống backup vật lý.
C. Cơ chế/kết nối giúp ứng dụng client giao tiếp với database server.
D. Một loại database server.

**Câu 9.** Một thay đổi trong quy tắc tính khuyến mãi cần được áp dụng đồng nhất cho web, mobile và desktop clients. Kiến trúc nào hỗ trợ điều này tự nhiên nhất?

A. 1 tầng, vì mỗi máy giữ logic riêng.
B. 2 tầng, vì mọi client sửa logic độc lập.
C. 3 tầng, vì quy tắc có thể tập trung tại application/business logic layer.
D. Không kiến trúc nào hỗ trợ.

**Câu 10.** Phát biểu nào là đánh giá cân bằng nhất về kiến trúc 3 tầng?

A. Luôn rẻ hơn và đơn giản hơn 1 tầng.
B. Không cần database server.
C. Thường dễ mở rộng và kiểm soát hơn, nhưng cần đầu tư thêm cho tầng ứng dụng, vận hành và giao tiếp giữa các tầng.
D. Chỉ phù hợp cho ứng dụng offline một người dùng.


### 7.2. Câu hỏi tự luận ngắn

**Câu 1.** Giải thích vì sao kiến trúc 1 tầng không phù hợp với hệ thống có nhiều người dùng.

---

**Câu 2.** Phân biệt kiến trúc 2 tầng và 3 tầng về cách client truy cập cơ sở dữ liệu.

---

**Câu 3.** Vì sao kiến trúc 3 tầng thường được dùng cho ứng dụng web lớn?

---

**Câu 4.** Nêu một ví dụ thực tế cho từng loại kiến trúc DBMS.

---

## 8. Bài tập vận dụng

### Bài tập 1

Một cửa hàng nhỏ muốn quản lý danh sách sản phẩm và doanh thu bán hàng trên một máy tính cá nhân. Cửa hàng chỉ có một người dùng hệ thống.

**Yêu cầu:**  
Hãy đề xuất kiến trúc DBMS phù hợp và giải thích lý do.

---

### Bài tập 2

Một thư viện trường học muốn xây dựng phần mềm desktop để nhiều nhân viên có thể tra cứu sách và cập nhật thông tin mượn trả. Dữ liệu được lưu trên một máy chủ trong mạng nội bộ.

**Yêu cầu:**  
Hãy đề xuất kiến trúc DBMS phù hợp và giải thích lý do.

---

### Bài tập 3

Một công ty muốn xây dựng website thương mại điện tử phục vụ hàng nghìn người dùng truy cập cùng lúc. Hệ thống cần bảo mật, xử lý đơn hàng, kiểm tra tồn kho và lưu lịch sử mua hàng.

**Yêu cầu:**  
Hãy đề xuất kiến trúc DBMS phù hợp và giải thích lý do.

---

## 9. Tóm tắt bài học

- Kiến trúc DBMS mô tả cách người dùng, ứng dụng và cơ sở dữ liệu tương tác với nhau.
- Kiến trúc 1 tầng đơn giản, chi phí thấp nhưng khó mở rộng và bảo mật thấp.
- Kiến trúc 2 tầng gồm client và database server, phù hợp với hệ thống nhỏ hoặc vừa.
- Kiến trúc 3 tầng bổ sung application server, giúp tăng bảo mật, khả năng mở rộng và dễ bảo trì hơn.
- Việc lựa chọn kiến trúc phụ thuộc vào quy mô hệ thống, số lượng người dùng, yêu cầu bảo mật, chi phí và khả năng mở rộng.

---

## 10. Từ khóa chính

- DBMS Architecture
- 1-Tier Architecture
- 2-Tier Architecture
- 3-Tier Architecture
- Client
- Server
- Database Server
- Application Server
- Presentation Layer
- Business Logic Layer
- Database Layer
- ODBC
- JDBC
- Scalability
- Security
- Data Integrity
---

## 11. Đáp án và gợi ý trả lời

### Quiz nhanh: Kiến trúc 1 tầng

- **Câu 1.** A
- **Câu 2.** C
- **Câu 3.** B

### Quiz nhanh: Kiến trúc 2 tầng

- **Câu 1.** B
- **Câu 2.** A
- **Câu 3.** D

### Quiz nhanh: Kiến trúc 3 tầng

- **Câu 1.** A
- **Câu 2.** B
- **Câu 3.** C

### Câu hỏi ôn tập - Trắc nghiệm

- **Câu 1.** C
- **Câu 2.** A
- **Câu 3.** D
- **Câu 4.** A
- **Câu 5.** D
- **Câu 6.** B
- **Câu 7.** B
- **Câu 8.** C
- **Câu 9.** C
- **Câu 10.** C

### Câu hỏi ôn tập - Tự luận ngắn

#### Câu 1.

**Gợi ý trả lời:**

Vì dữ liệu và ứng dụng nằm trên cùng một máy, không có cơ chế quản lý truy cập tập trung, khó chia sẻ dữ liệu, khó đồng bộ và bảo mật thấp.

#### Câu 2.

**Gợi ý trả lời:**

Trong kiến trúc 2 tầng, client kết nối trực tiếp đến database server. Trong kiến trúc 3 tầng, client gửi yêu cầu đến application server, sau đó application server mới làm việc với database server.

#### Câu 3.

**Gợi ý trả lời:**

Vì kiến trúc 3 tầng có khả năng mở rộng tốt, bảo mật cao hơn, dễ tách biệt giao diện, logic nghiệp vụ và dữ liệu, đồng thời phù hợp với nhiều người dùng truy cập đồng thời.

#### Câu 4.

**Gợi ý trả lời:**

- 1 tầng: MS Access chạy trên máy cá nhân.
- 2 tầng: Hệ thống quản lý thư viện nhỏ dùng ứng dụng desktop kết nối database server.
- 3 tầng: Website thương mại điện tử với trình duyệt, server ứng dụng và database server.

### Bài tập 1

#### Bài tập 1

**Gợi ý:**

Kiến trúc 1 tầng có thể phù hợp vì hệ thống nhỏ, chỉ một người dùng, chi phí thấp và dễ triển khai.

### Bài tập 2

#### Bài tập 2

**Gợi ý:**

Kiến trúc 2 tầng phù hợp vì ứng dụng desktop có thể kết nối trực tiếp đến database server trong mạng nội bộ.

### Bài tập 3

#### Bài tập 3

**Gợi ý:**

Kiến trúc 3 tầng phù hợp vì có tầng ứng dụng xử lý nghiệp vụ, tăng bảo mật, dễ mở rộng và phù hợp với hệ thống web lớn.
