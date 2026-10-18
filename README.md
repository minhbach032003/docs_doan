# Tài liệu đồ án WMSD

Kho tài liệu đồ án **Warehouse Management System Development (WMSD)** — Capstone SEP490_G56, hệ thống quản lý kho cho cửa hàng gạch ốp lát Tân Thương.

Tài liệu được nhóm theo mục đích sử dụng. Tên file và nội dung nghiệp vụ được giữ nguyên; việc sắp xếp thư mục không thay đổi trạng thái phê duyệt hay giải quyết các khác biệt giữa các phiên bản.

## 1. Báo cáo đồ án

Thư mục: [`docs/01_bao_cao/`](docs/01_bao_cao/)

- [Report 1 — Giới thiệu dự án](docs/01_bao_cao/WMSD_Report1_Fix.docx.txt): bối cảnh, mục tiêu và phạm vi dự án.
- [Report 2 — Kế hoạch quản lý dự án](docs/01_bao_cao/WMSD_Report2.docx.txt): kế hoạch tổ chức và quản lý thực hiện.
- [Report 3 — Đặc tả yêu cầu phần mềm (SRS)](docs/01_bao_cao/WMSD_Report3_Fix.docx.txt): yêu cầu, use case và các ràng buộc hệ thống.

Các file `.docx.txt` là bản văn bản của báo cáo, không phải file Word `.docx`.

## 2. Phân tích nghiệp vụ và đề xuất sau review

Thư mục: [`docs/02_nghiep_vu/`](docs/02_nghiep_vu/)

- [Đề xuất 7 quy trình nghiệp vụ sau review 1](docs/02_nghiep_vu/De_xuat_7_quy_trinh_sau_review1.md): phương án To-be, phân tích tác động, phân quyền và các nội dung cần điều chỉnh trong báo cáo.

**Trạng thái:** tài liệu ngày 17/10/2026 tự xác định là phương án đề xuất, chưa phải xác nhận thực địa hay SRS đã được cửa hàng phê duyệt. Không mặc định các thay đổi đề xuất đã được chấp thuận.

## 3. Thiết kế hệ thống

Thư mục: [`docs/03_thiet_ke/`](docs/03_thiet_ke/)

- [Thiết kế hệ thống chi tiết](docs/03_thiet_ke/WMSD_Thiet_ke_he_thong_chi_tiet.md): phạm vi, luồng xử lý, dữ liệu, trạng thái chứng từ, kiến trúc, API và kịch bản kiểm thử.

**Trạng thái:** phiên bản 1.0 ngày 16/10/2026. Có khác biệt với đề xuất sau review ngày 17/10/2026, đặc biệt về phạm vi bán hàng, hóa đơn và trách nhiệm các vai trò. Cần đối chiếu và chốt với nhóm trước khi triển khai; lần sắp xếp này giữ nguyên cả hai tài liệu.

## 4. Sơ đồ

Thư mục: [`docs/04_so_do/`](docs/04_so_do/)

- [Business_Process.drawio](docs/04_so_do/Business_Process.drawio)
- [WMSD_Bangach.drawio](docs/04_so_do/WMSD_Bangach.drawio)
- [context-diagrem.mermaid](docs/04_so_do/context-diagrem.mermaid)

Mở file `.drawio` bằng diagrams.net hoặc ứng dụng tương thích; file `.mermaid` bằng công cụ hỗ trợ Mermaid. Tên file gốc được giữ nguyên để thuận tiện đối chiếu.

## 5. Khảo sát và biên bản họp

Thư mục: [`docs/05_khao_sat/`](docs/05_khao_sat/)

- [Biên bản họp 12_9.docx](docs/05_khao_sat/Biên%20bản%20họp%2012_9.docx)

## 6. Tài liệu tham khảo

Thư mục: [`docs/06_tham_khao/`](docs/06_tham_khao/)

### SAP Global Bike — Warehouse Management

- [Case Study WM I — v4.1](docs/06_tham_khao/sap/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_I_en_v4.1.pdf)
- [Case Study WM II — v4.1](docs/06_tham_khao/sap/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_II_en_v4.1.pdf)
- [Case Study WM III — v4.1](docs/06_tham_khao/sap/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_III_en_v4.1.pdf)
- [Case Study WM IV — v4.1](docs/06_tham_khao/sap/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_IV_en_v4.1.pdf)

### Quy trình và nguồn trực tuyến

- [Tổng hợp quy trình.pdf](docs/06_tham_khao/quy_trinh/Tổng%20hợp%20quy%20trình.pdf)
- [Liên kết tham khảo MISA](docs/06_tham_khao/link_tham_khao.md)

Tài liệu tham khảo hỗ trợ phân tích; không tự động trở thành yêu cầu nghiệp vụ của cửa hàng.

## Thứ tự đọc gợi ý

1. **Hiểu đồ án:** Report 1 → Report 2 → Report 3.
2. **Rà soát sau review:** đề xuất 7 quy trình → đối chiếu Report 1, Report 3 và sơ đồ liên quan.
3. **Chuẩn bị triển khai:** thiết kế hệ thống chi tiết → đối chiếu các thay đổi đề xuất và những quyết định chưa chốt.
4. **Kiểm tra căn cứ:** biên bản họp → tài liệu SAP, tổng hợp quy trình và nguồn MISA.

[`agent.md`](agent.md) được giữ tại thư mục gốc để agent dễ tìm hướng dẫn làm việc. Đây không phải biên bản phê duyệt yêu cầu nghiệp vụ.

## Các tham chiếu còn thiếu trong bộ tài liệu gốc

- Tài liệu thiết kế tham chiếu ảnh `WMSD_ERD_tu_Report3.png`, nhưng repo chưa có ảnh này.
- Tài liệu đề xuất còn liên kết tới `review1.md` và bộ SAP **v4.2** trên đường dẫn máy Windows `D:/Ky_9/SEP490/...`; các nguồn này không có trong repo. Bộ SAP hiện lưu trong repo là **v4.1**, không tự thay thế cho v4.2 hoặc bảo đảm cùng số trang.

Các tham chiếu trên được giữ nguyên để bảo toàn nguồn gốc; cần bổ sung đúng nguồn trước khi sử dụng để đối chiếu đầy đủ.

## Quy ước lưu tài liệu

- Báo cáo nộp theo đợt đặt trong `01_bao_cao`; phân tích và đề xuất thay đổi đặt trong `02_nghiep_vu`; thiết kế triển khai đặt trong `03_thiet_ke`.
- File sơ đồ chỉnh sửa được đặt trong `04_so_do`; biên bản khảo sát/họp đặt trong `05_khao_sat`; nguồn bên ngoài đặt trong `06_tham_khao`.
- Khi di chuyển hoặc bổ sung tài liệu, cập nhật liên kết trong mục lục này và các đường dẫn tham chiếu liên quan.
