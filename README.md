# Tài liệu đồ án WMSD

Kho tài liệu của Warehouse Management System Development — SEP490_G56, cửa hàng gạch ốp lát Tân Thương.

**Chuẩn hiện hành: baseline 3.0.0, đồng bộ ngày 22/10/2026.** Một cửa hàng, từ 3 kho theo khảo sát; 8 BF; 5 vai trò; 111 UC (98 active/13 retired); BR-01–33; SC-01–31 (28 active/3 retired). Đây là thiết kế được chọn, không phải xác nhận mọi kiểm soát đã được triển khai hoặc nghiệm thu.

Luồng đơn: SO nhập lại từ nguồn ngoài đã xác minh → WIR liên kết → OD/soạn/PGI → Warehouse xác nhận POD có ảnh (DELIVERED) → Sales xác nhận đủ tiền ngoài hệ thống (PAY-CFM, COMPLETED). Giá bán, hóa đơn, thu/chuyển tiền và kế toán vẫn bên ngoài; không live MISA.

## Bộ tài liệu hiện hành

| Tài liệu | Vai trò / trạng thái |
|---|---|
| [Quy trình VI](docs/02_nghiep_vu/de_xuat_quy_trinh_2_VI.md) / [EN](docs/02_nghiep_vu/de_xuat_quy_trinh_2_EN.md) | Chuẩn nghiệp vụ, 8 BF, 37 A/E, quyền, chứng từ và BR |
| [Report 1](docs/01_bao_cao/WMSD_Report1_Fix.docx.txt) | Bối cảnh, GAP, 9 FE, phạm vi và 8 To-be |
| [Report 3](docs/01_bao_cao/WMSD_Report3_Fix.docx.txt) | Catalogue/permission/spec đủ 111 UC, màn hình, BR, NFR và lỗi |
| [Thiết kế hệ thống chi tiết](docs/03_thiet_ke/WMSD_Thiet_ke_he_thong_chi_tiet.md) | Bản 3.0.0 thay bản 1.0 ngày 16/10; API/trạng thái/transaction/MongoDB/truy vết |
| [Thiết kế database VI](docs/03_thiet_ke/de_xuat_database_design_VI.md) / [EN](docs/03_thiet_ke/de_xuat_database_design_EN.md) | Mô hình tham chiếu và MongoDB mapping; 21 quy tắc, 40 case nghiệm thu |
| [SQL tham chiếu](docs/03_thiet_ke/WMSD_SQL_schema.sql) | 73 bảng, 173 FK, 2 view; T-SQL để review, không phải migration MongoDB |
| [Nhật ký](change_logs.md) | Thay đổi, kiểm tra thực tế và giới hạn theo từng mốc |
| [Report 2](docs/01_bao_cao/WMSD_Report2.docx.txt) | **Giữ nguyên theo yêu cầu**; quan sát về effort/buffer tạm hoãn xử lý |

Các file .docx.txt là bản văn bản, không phải Word .docx. Bản Google Docs/Word báo cáo bên ngoài repo cần phát hành riêng từ nội dung đã đồng bộ; không suy ra đã sửa các bản trực tuyến.

## Sơ đồ hiện hành

- [Mainflow VI/EN](docs/04_so_do/WMSD_Mainflows_VI_EN.drawio): 16 trang, 8 BF × 2 ngôn ngữ; mới tạo lại theo baseline hiện hành.
- [Mainflow EN](docs/04_so_do/WMSD_Mainflows_EN.drawio): 8 trang; cùng hoạt động, quyền, chứng từ và ngoại lệ với bản song ngữ.
- [BF-04 ảnh VI](docs/04_so_do/WMSD_Mainflow_BF04_VI.png) / [EN](docs/04_so_do/WMSD_Mainflow_BF04_EN.png): xuất từ trang tương ứng của bộ mainflow hiện hành.
- [Sơ đồ database](docs/03_thiet_ke/WMSD_database_design.drawio): 10 trang; mỗi bảng có một định nghĩa đầy đủ, FK/stub có liên kết sang trang gốc.
- [Context Mermaid](docs/04_so_do/context-diagrem.mermaid): 5 vai trò, SMTP API-01 và controlled storage API-02 chưa chốt nhà cung cấp; không API MISA/thanh toán.

Mainflow chỉ có lane actor; kho đi/kho nhận là trách nhiệm theo kho của cùng Warehouse Staff. Mở .drawio bằng diagrams.net; .mermaid bằng trình hỗ trợ Mermaid.

## Tài liệu lịch sử

- [Đề xuất 7 quy trình sau review 1](docs/02_nghiep_vu/De_xuat_7_quy_trinh_sau_review1.md): mốc ghi nhận 17/10, bổ sung 19/10; bảo toàn để đối chiếu.
- [Business_Process.drawio](docs/04_so_do/Business_Process.drawio) và [WMSD_Bangach.drawio](docs/04_so_do/WMSD_Bangach.drawio): tất cả trang có banner HISTORICAL, không dùng làm thiết kế hiện hành.
- Ảnh BF-03B ngày 20/10 [VI](docs/04_so_do/WMSD_Mainflow_BF03B_VI.png) / [EN](docs/04_so_do/WMSD_Mainflow_BF03B_EN.png): giữ bản gốc; ảnh hiện hành dùng BF-04 ở trên.
- [Báo cáo rà soát trước sửa](docs/07_ra_soat/Bao_cao_dong_bo_tai_lieu_2026-10-22.md): snapshot ở commit fdf6e7a, số dòng phản ánh thời điểm trước sửa.
- [Kết quả đồng bộ và hậu kiểm](docs/07_ra_soat/Ket_qua_dong_bo_tai_lieu_2026-10-22.md): trạng thái sau sửa và phần còn để mở.

## Khảo sát và biên bản họp

Nguồn thực địa được giữ nguyên. CSV có một phản hồi, 26 câu hỏi đánh số và 47 cột gồm thời gian/cột lưới. Câu 13 chọn hai ý mâu thuẫn; D4 chọn có điều chuyển, không sửa CSV để làm khớp.

- [Khảo sát kho gạch 20/10](docs/05_khao_sat/khao_sat_kho_gach.csv)
- [Biên bản 12/9](docs/05_khao_sat/Biên%20bản%20họp%2012_9.docx)
- [Biên bản 16/9](docs/05_khao_sat/Biên%20bản%20họp%2016_9.docx)
- [Biên bản 26/9](docs/05_khao_sat/Biên%20bản%20họp%2026_9.docx)
- [Biên bản 30/9](docs/05_khao_sat/Biên%20bản%20họp%2030_9.docx)
- [Biên bản 3/10](docs/05_khao_sat/Biên%20bản%20họp%203_10.docx)
- [Biên bản 09/10](docs/05_khao_sat/Biên%20bản%20họp%2009_10.docx)

## Tài liệu tham khảo

- SAP Global Bike WM v4.1, Last Update June 2022: [I](docs/06_tham_khao/sap/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_I_en_v4.1.pdf), [II](docs/06_tham_khao/sap/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_II_en_v4.1.pdf), [III](docs/06_tham_khao/sap/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_III_en_v4.1.pdf), [IV](docs/06_tham_khao/sap/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_IV_en_v4.1.pdf).
- [Tổng hợp quy trình gốc](docs/06_tham_khao/quy_trinh/Tổng%20hợp%20quy%20trình.pdf) và [liên kết tham khảo](docs/06_tham_khao/link_tham_khao.md).

Quy trình/database hiện hành trích bộ SAP v4.1 trong repo và số trang đã đối chiếu. review1.md và bộ SAP v4.2 là nguồn lịch sử ngoài repo chưa đóng gói; không tạo bản giả hoặc dùng v4.1 để chứng minh nguyên văn v4.2. Các mô tả nguồn lịch sử được giữ dạng tên nguồn, không còn liên kết máy cá nhân.

## Duy trì đồng bộ

Đọc quy trình → Report 1/3 → thiết kế chi tiết/dữ liệu → sơ đồ → nghiệm thu. Thay BF/UC/BR/SC hoặc quyền phải cập nhật mọi phần hiện hành tương ứng, ghi change log và xuất lại hình từ nguồn chỉnh sửa được. Giữ nội dung As-is, biên bản và bản chụp lịch sử theo đúng thời điểm.
