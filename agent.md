# WMSD — Warehouse Management System Development
> Dự án Capstone SEP490_G56 | Cửa hàng gạch ốp lát Tân Thương (Tân An, Yên Dũng, Bắc Giang)

Tài liệu này cung cấp toàn cảnh kiến trúc, ranh giới ngữ cảnh (Bounded Context), quy tắc nghiệp vụ cốt lõi và hướng dẫn điều hướng dành cho AI Agent khi thao tác trên tài liệu SRS và mã nguồn dự án WMSD.

---

## 1. Bản chất & Mục đích Dự án (Project Mission)

WMSD là **Hệ thống Quản lý Kho Thực thi (Execution Warehouse Layer)** chuyên biệt cho ngành gạch ốp lát. 

### 1.1 Ranh giới Bounded Context (Crucial Boundaries)
* **Trong phạm vi WMSD (In-Scope)**:
  * Quản lý sự kiện vật lý và dòng di chuyển hàng hóa (Movement Ledger).
  * Kiểm soát chi tiết theo tọa độ vị trí: Kho (Warehouse) $\rightarrow$ Dãy (Aisle) $\rightarrow$ Kệ (Rack) $\rightarrow$ Ô vị trí (Bin).
  * Định danh gạch khắt khe theo bộ tuple: `(Product_ID, Lot, Tone, Calibre, Quality_Status, Bin_Location)`.
  * Quy đổi đóng gói chuẩn hóa: **Thùng** (Box) $\leftrightarrow$ **Viên** (Piece) $\leftrightarrow$ **Diện tích** ($m^2$).
  * Quản lý trạng thái tồn kho: Tồn vật lý (`On-hand`), Khả dụng (`Available`), Đã giữ cho đơn (`Reserved`), Đang chuyển liên kho (`In-Transit`), và Hàng tạm giữ không sở hữu (`Custody`).
* **Ngoài phạm vi WMSD (Out-of-Scope / Thuộc về MISA eShop & Kế toán)**:
  * Bán hàng thương mại, báo giá, chiết khấu, thu ngân (POS), quản lý công nợ khách hàng/NCC.
  * Hóa đơn giá trị gia tăng (VAT e-invoice) và Hóa đơn nội bộ (Internal Invoice).
  * Tính toán giá vốn, tỷ suất lợi nhuận (Margin), định khoản kế toán, hạch toán sổ cái.
  * Quy trình tính toán, phê duyệt và chi trả tiền hoàn lại (Refund workflow).
  * **Không có Live API Integration** với MISA trong baseline MVP: WMSD liên kết với MISA thông qua **Mã tham chiếu chứng từ ngoài (`source_order_ref`, `source_delivery_ref`)** do nhân viên nhập và Kế toán đối chiếu định kỳ (UC-108).

---

## 2. Mô hình Vai trò & Phân quyền (Actors & SoD)

Hệ thống phục vụ **5 Application Roles** chính thức:

| Vai trò | Trách nhiệm chính trong WMSD | Ràng buộc cấm kỵ |
|---|---|---|
| **Store Owner** | Phê duyệt đề xuất mua hàng (PO), điều chuyển liên kho, phương án xử lý hàng lỗi, nhận hàng trả, và Xóa chênh lệch kiểm kê (Clear Difference). | Không duyệt các thao tác chuyển vị trí kệ nội bộ thông thường. |
| **Warehouse Staff** *(Thủ kho/Bốc dỡ)* | Kiểm nhận hàng đến, bốc dỡ, put-away vào bin, soạn hàng (picking), đóng gói staging, xác nhận PGI, chuyển kệ nội bộ, kiểm kê, cách ly hàng lỗi. | Thao tác bị giới hạn theo kho được phân công (`assigned_warehouse_id`). Không tự quyết định thanh lý/hủy hàng. |
| **Sales Staff** | Tạo Yêu cầu xuất kho (*Warehouse Issue Request*) từ đơn bán MISA, lập đề nghị khách trả hàng, theo dõi tồn khả dụng theo Lot/Tone để chốt đơn với khách. | Không can thiệp kết luận chất lượng vật lý của gạch; không xác nhận xuất/nhập kho. |
| **Accountant** | Tạo PO từ nhu cầu bổ sung đã được Owner duyệt; liên hệ thỏa thuận trả hàng với NCC; ghi nhận chứng từ đối chiếu tài chính bên ngoài (UC-107, UC-108). | Không tự ý tạo nhu cầu bổ sung hàng thay bộ phận vận hành; không duyệt xử lý sai lệch kho. |
| **Administrator** | Quản trị tài khoản, phân quyền hệ thống và cấu hình tham số kỹ thuật. | Không tự ý can thiệp vào các giao dịch kho nghiệp vụ hoặc sửa nhật ký kiểm toán. |

### Ràng buộc SoD cốt lõi (Segregation of Duties)
* **Cấm tự phê duyệt**: `Creator_User_ID !== Approver_User_ID`. Kể cả người dùng có quyền Owner, nếu đã tự tay tạo đề xuất bổ sung hoặc điều chuyển thì không được tự nhấn nút Phê duyệt trên chứng từ đó.
* **Nhận hàng liên kho độc lập**: Người xác nhận xuất hàng tại Kho đi không được quyền xác nhận nhận hàng tại Kho đến.

---

## 3. Bảy Quy trình Nghiệp vụ Chuẩn (7 Business Flows)

Mọi luồng nghiệp vụ trong tài liệu và mã nguồn phải tuân thủ chuẩn 7 BF sau review 1:

* **BF-01: Bổ sung hàng, Đặt mua & Nhập kho (Replenishment & Inbound Receiving)**:
  * Trigger: Sales tạo từ đơn thiếu hoặc Warehouse Staff tạo từ cảnh báo ngưỡng tồn an toàn (`safety_stock_threshold`) $\rightarrow$ Owner duyệt $\rightarrow$ Accountant lập PO $\rightarrow$ Xe đến: Warehouse Staff kiểm đếm theo PO.
  * Phân tách 3 nhóm lượng ngay tại cửa kho: (1) Đạt $\rightarrow$ Nhập kho; (2) Lỗi của cửa hàng $\rightarrow$ Cách ly (BF-02); (3) Giao thừa/sai từ chối ngay $\rightarrow$ Giữ hộ (`Custody`), không tăng tồn sở hữu.
  * Put-away vào Bin hoàn tất mới chuyển hàng thành khả dụng (`Available`).
* **BF-02: Cách ly & Xử lý Hàng lỗi (Defective Goods Isolation & Disposition)**:
  * Trigger: Phát hiện gạch nứt vỡ, bể góc, sai quy chuẩn trong quá trình nhập, xuất, kiểm kê hoặc lưu kho.
  * Nguyên tắc: **Khóa phân bổ và đưa vào Khu cách ly (`Quarantine`) NGAY LẬP TỨC**, không chờ Owner duyệt.
  * Quyết định xử lý: Warehouse Staff chụp ảnh chứng cứ $\rightarrow$ Đề xuất (Tái phân loại / Trả NCC / Hủy) $\rightarrow$ Owner duyệt $\rightarrow$ Thực hiện và ghi giảm tồn đúng 1 lần.
* **BF-03: Di chuyển Vị trí & Điều chuyển Liên kho (Movement & Transfer)**:
  * *Nhánh A (Cùng kho)*: Warehouse Staff tự chuyển giữa các Bin (A1 $\rightarrow$ A2), cập nhật tồn vị trí tức thời, không cần Owner duyệt, không sinh TR/TO, tổng tồn kho không đổi.
  * *Nhánh B (Khác kho vật lý)*: Warehouse Staff tạo Transfer Request (TR) $\rightarrow$ Owner duyệt $\rightarrow$ Kho đi xuất hàng (giảm kho đi, tăng bucket `In-Transit`) $\rightarrow$ Kho đến kiểm nhận độc lập (giảm `In-Transit`, tăng kho đến) $\rightarrow$ Xử lý sai lệch nếu có.
* **BF-04: Kiểm kê, Đối chiếu & Điều chỉnh Tồn (Stocktake & Inventory Adjustment)**:
  * Owner tạo phiên $\rightarrow$ Xử lý dở dang $\rightarrow$ Kích hoạt: Chụp **Snapshot bất biến** tại mốc Cutoff $\rightarrow$ **Khóa phân vùng kệ kiểm kê (Bin-level Locking)**.
  * Nhân viên đếm mù (Blind Count, không thấy số tồn sổ) $\rightarrow$ Nhập kết quả $\rightarrow$ Đối soát chênh lệch $\rightarrow$ Giải trình $\rightarrow$ Owner duyệt và thực hiện **Clear Difference (UC-93)** để post delta vào tồn kho $\rightarrow$ Mở khóa Bin.
* **BF-05: Tiếp nhận Yêu cầu Xuất, Soạn hàng & Bàn giao (Outbound Fulfilment)**:
  * Trigger: Sales Staff tạo *Warehouse Issue Request* kèm `source_order_ref` từ MISA.
  * Phân bổ tồn kho theo đúng **Lot/Tone/Calibre** (ưu tiên FIFO). Cấm tự ý trộn các Tone khác nhau.
  * Tạo Picking List $\rightarrow$ Warehouse Staff lấy hàng ra Staging $\rightarrow$ Kiểm đếm $\rightarrow$ Thực xuất (**PGI - Post Goods Issue**) giảm tồn vật lý đúng 1 lần $\rightarrow$ Bàn giao vận chuyển.
* **BF-06: Tiếp nhận Hàng khách trả & Phân loại (Customer Returns)**:
  * Sales kiểm tra điều kiện xuất gốc $\rightarrow$ Khách mang gạch tới: Warehouse Staff tiếp nhận vào khu vực **Tạm giữ (`Custody Area`)**.
  * Thủ kho kiểm tra bao bì, đếm, xác định Lot/Tone/Calibre và phân loại $\rightarrow$ **Store Owner duyệt quyết định chấp nhận trả (UC-71)** $\rightarrow$ Lượng đạt nhập kho bán được; lượng lỗi nhập cách ly; lượng từ chối bàn giao lại cho khách $\rightarrow$ Accountant lưu tham chiếu hoàn tiền bên ngoài (UC-108).
* **BF-07: Xuất trả Nhà cung cấp (Supplier Returns)**:
  * Warehouse Staff lập đề xuất xuất trả hàng lỗi $\rightarrow$ Accountant làm việc và ghi nhận thỏa thuận đồng ý của NCC (Mốc 1) $\rightarrow$ Owner duyệt xuất $\rightarrow$ Thủ kho soạn hàng và PGI xuất trả $\rightarrow$ Accountant ghi nhận xác nhận thực nhận của NCC (Mốc 2 - Acknowledgement) $\rightarrow$ Owner đóng hồ sơ.

---

## 4. Bất biến Dữ liệu & Quy tắc Nghiệp vụ Cốt lõi (Invariants & Business Rules)

1. **Bất biến giao dịch (Transactional Idempotency & Immutability)**:
   * Mọi giao dịch tác động tồn kho (Receipt, PGI, Adjustment, Scrap) chỉ được POST đúng một lần, ghi đồng thời vào Sổ cái chuyển động (`Movement Ledger`) và Số dư tồn (`Inventory Balance`).
   * Không bao giờ cập nhật lùi (backdate) hoặc xóa/sửa các chứng từ kho đã Post. Sai sót phải xử lý bằng chứng từ đảo/điều chỉnh đối ứng có phê duyệt.
2. **Quy tắc Tồn khả dụng (Available Stock Formula)**:
   $$\text{Available} = \text{On-Hand (Sellable)} - \text{Allocated (Reserved)} - \text{Stocktake Locked}$$
   *Tồn khả dụng không bao giờ được phép âm.*
3. **Đặc thù gạch (Tile Consistency Rule)**:
   * Không bao giờ gộp 2 thùng gạch khác Tone màu hoặc khác Calibre vào cùng một dòng xuất công trình mà không có xác nhận bằng văn bản của khách hàng.
4. **Quy tắc Đơn vị Quy đổi (UoM Conversion)**:
   * Số lượng lưu kho cơ sở là số nguyên: **Thùng** hoặc **Viên**. Diện tích ($m^2$) tính toán dựa trên hệ số cấu hình của sản phẩm: $\text{Số } m^2 = \text{Số viên} \times \text{Diện tích 1 viên}$.

---

## 5. Dịch vụ Tích hợp Bên ngoài (External Integrations)

* **Cloudinary (`API-02`)**: Lưu trữ hình ảnh bằng chứng (ảnh gạch vỡ nứt, ảnh thùng rách, biên bản bàn giao xe có chữ ký). WMSD chỉ lưu trữ `public_id` và `secure_url`.
* **SMTP Service (`API-01`)**: Gửi email thông báo sự kiện nội bộ sau khi giao dịch đã commit (VD: gửi thông báo cho Owner khi có TR cần duyệt, có chênh lệch kiểm kê cần xử lý). *Không dùng để gửi hóa đơn bán hàng*.
* **MISA eShop**: Không kết nối API trực tiếp. Chỉ lưu trữ chuỗi tham chiếu (`external_ref_id`) phục vụ đối soát bảng kê.

---

## 6. Chỉ dẫn cho Agent khi Chỉnh sửa Tài liệu & Viết Code

* **Đối chiếu số lượng Use Case**: Bản baseline sau chuẩn hóa có **95 Active Use Cases** (đã loại bỏ 12 UC bán hàng/giá/hóa đơn/hoàn tiền và bổ sung 5 UC: UC-103, 104, 106, 107, 108). Tuyệt đối không tái đưa các UC về Selling Price hay Internal Invoice vào phạm vi.
* **Đồng bộ thuật ngữ**:
  * Luôn dùng **`Warehouse Staff`**, không dùng `Inventory Staff`.
  * Luôn dùng **`Warehouse Issue Request`**, không dùng `Sales Order` trong tầng WMS.
  * Luôn dùng **`Put-away Task`** và **`Picking Task`**, không dùng `Transfer Order (TO)` cho các thao tác nội bộ cùng kho.
* **Cấu trúc thư mục tài liệu tham chiếu**:
  * `@De_xuat_7_quy_trinh_sau_review1.md`: Căn cứ thiết kế To-be và phân tích lỗi.
  * `docs/WMSD_Report1_Fix.docx.txt`: Báo cáo giới thiệu dự án (Report 1).
  * `docs/WMSD_Report2.docx.txt`: Kế hoạch quản lý dự án (Report 2).
  * `docs/WMSD_Report3_Fix.docx.txt`: Đặc tả yêu cầu phần mềm SRS (Report 3).
