# Deploy GitHub Pages

Tài liệu này hướng dẫn cách đẩy repo lên GitHub và bật deploy tự động cho site tài liệu.

## 1. Khởi tạo Git và push lên GitHub

Nếu thư mục hiện tại chưa phải Git repository, chạy:

```powershell
git init
git branch -M main
git add .
git commit -m "Initial site content"
git remote add origin https://github.com/<your-username>/<your-repo>.git
git push -u origin main
```

Nếu bạn đã có repo Git từ trước, chỉ cần thay `git init` và `git remote add origin` bằng remote đúng của bạn.

## 2. Bật GitHub Pages

Vào trang repo trên GitHub, mở `Settings` -> `Pages`.

Chọn:

- `Source`: `GitHub Actions`
- Workflow: file `.github/workflows/pages.yml`

Sau đó push thêm một commit nhỏ để workflow chạy.

## 3. Cập nhật nội dung về sau

Mỗi lần muốn thêm bài mới:

```powershell
git add .
git commit -m "Add new lesson"
git push
```

Workflow GitHub Actions sẽ tự build và deploy lại Pages.

## 4. Ghi chú

- Trang chủ của site là [`index.md`](index.md).
- Cấu hình site nằm ở [`.github/workflows/pages.yml`](.github/workflows/pages.yml).
- Mỗi file Markdown bài học đã có front matter để GitHub Pages render thành trang riêng.
- Nếu repo của bạn dùng nhánh khác `main`, hãy sửa lại workflow cho đúng nhánh.
