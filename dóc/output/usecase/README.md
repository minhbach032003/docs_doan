# WMSD Use Case Diagrams

Nguồn: `Report3.docx.pdf`, mục 4.2, trang 1–4; đối chiếu thêm business rules ở trang 5 và other requirements ở trang 6.

Mở `WMSD_Use_Case_Diagrams.drawio` bằng draw.io Desktop. Mỗi actor có một tab. Các trang nhiều use case có chiều cao lớn; dùng zoom và cuộn để đọc. Ảnh `.drawio.png` là bản xuất từng tab, có nhúng dữ liệu draw.io.

| Tab / actor | Số UC nguồn gán trực tiếp |
| --- | ---: |
| Store Owner | 38 |
| Purchasing Staff | 8 |
| Inventory Staff | 36 |
| Sales Staff | 14 |
| Delivery Staff | 2 |
| Accountant | 0 |
| Administrator | 0 |
| SMTP Service | 0 |

Đã đối chiếu đủ 75 mã UC-01 đến UC-75. Một UC có nhiều actor được lặp lại trên các tab tương ứng; 98 association là tổng số cặp actor–UC trong nguồn.

## Quy ước UML

- Association: đường liền, không mũi tên, nối actor với các UC được gán cho actor đó trong bảng nguồn.
- `«include»`: đường nét đứt, mũi tên mở từ UC chính tới hành vi bắt buộc.
- `«extend»`: đường nét đứt, mũi tên mở từ hành vi có điều kiện tới UC cơ sở. Điều kiện được ghi trên sơ đồ.
- Generalization: đường liền, tam giác rỗng hướng từ UC chuyên biệt tới UC tổng quát. Ví dụ: cập nhật/hủy purchase order, cập nhật/hủy sales order, tạo/cập nhật/khóa employee account.

`UC-nn` và tên use case giữ nguyên theo tài liệu. `SUP-nn-n` là thao tác hỗ trợ hoặc chuyên biệt được phân rã từ mô tả của UC-nn; không phải mã UC mới trong SRS. Các quan hệ là diễn giải mô hình hóa từ mô tả và quy tắc nghiệp vụ, vì bảng nguồn chưa đặc tả quan hệ UML.

Các UC nguồn hiển thị màu xám kèm `(context)` chỉ làm UC cơ sở cho một quan hệ: không gán thêm quyền cho actor của trang. Thứ tự tạo, duyệt, xác nhận chứng từ không được chuyển thành `include`; duyệt trước khi xác nhận được coi là tiền điều kiện.

## Các trường hợp extend

- UC-23 mở rộng UC-22 khi phát hiện thiếu/thừa, sai lô hoặc hàng hỏng.
- UC-56 mở rộng UC-55 khi giao thiếu hoặc giao thất bại. Trên trang Sales Staff và Inventory Staff, UC-55 chỉ hiển thị làm context; actor xác nhận giao là Delivery Staff.
- UC-75 mở rộng UC-74 khi số lượng hoặc tình trạng nhận khác với xuất điều chuyển. Trang Store Owner chỉ có UC-74 làm context.
- SUP-29-1 mở rộng UC-29 khi hàng trả nhà cung cấp đã được ghi nhận vào tồn kho.

## Khoảng trống của tài liệu

Accountant, Administrator và SMTP xuất hiện ở context, nhưng không được gán UC cụ thể trong danh sách 75 UC. Ba tab tương ứng ghi rõ thiếu đặc tả, không tự thêm use case. UC-67 và UC-68 vẫn thuộc Store Owner theo bảng nguồn. Delivery Staff có UC-55/UC-56 và được thêm trang dù không được liệt kê trong đoạn context.

`usecase_model.json` lưu bảng UC, actor, mô tả, trang nguồn và căn cứ cho từng quan hệ để có thể rà soát hoặc điều chỉnh sau này.
