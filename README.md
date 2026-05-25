# Database Management — GitHub Pages (docs/)

Trang này đã được cấu trúc để dùng trực tiếp Markdown/PDF trên GitHub Pages.

Hướng dẫn nhanh để bật GitHub Pages:

1. Đẩy (push) repository này lên GitHub.
2. Vào trang repository trên GitHub → `Settings` → `Pages`.
3. Ở phần `Source`, chọn branch bạn muốn (thường `main` hoặc `master`), và `Folder` chọn `/docs`.
4. Lưu thay đổi. Sau vài phút, trang sẽ sẵn sàng tại `https://<username>.github.io/<repo>`.

Gợi ý kiểm tra cục bộ (tuỳ chọn):
- Cài Jekyll nếu muốn preview cục bộ (`gem install bundler jekyll`) và chạy `jekyll serve --source docs`.
- Hoặc mở `docs/` bằng `Live Server` trong VS Code để xem file tĩnh (không có xử lý Jekyll).

Ghi chú:
- Tôi đã thêm `docs/_config.yml` với một cấu hình Jekyll tối giản và sao chép tất cả file Markdown, PDF và ảnh vào `docs/` để trang trở thành self-contained.
- Nếu muốn đổi theme hoặc cấu hình, chỉnh `docs/_config.yml`.
