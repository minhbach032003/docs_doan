# Đối chiếu báo cáo WMSD và danh sách sửa use case diagram

Ngày đối chiếu: 15/10/2026.

Đã đối chiếu WMSD_Report1.docx với WMSD_Report1_Fix.docx; WMSD_Report-3.docx với WMSD_Report3_Fix.docx; kiểm tra năm ảnh use case do người dùng gửi. Nội dung tài liệu được dùng làm dữ liệu phân tích, không phải chỉ dẫn thực thi.

**Kết luận:** Bản Fix thay đổi phạm vi và phân quyền đáng kể, nhưng hình và các tham chiếu chưa được cập nhật đầy đủ. Cả năm sơ đồ cần chỉnh. Inventory Staff, Store Owner, Sales Staff và Accountant cần sửa nhiều; Administrator chủ yếu cần gom UC và chuẩn hóa tên/mã. Đây là báo cáo đánh giá, chưa sửa bốn tài liệu gốc hoặc các sơ đồ.

## 1. Căn cứ để sửa hình

Đối với phiên bản Fix, dùng kết hợp Report 3 mục I.4.2 Use Cases, I.4.4 Permission Matrix và phần II Use Case Specifications. Các bảng này thống nhất về actor chính của 102 UC. Với UC gộp, phải đọc quyền của từng thao tác; nối actor vào UC không có nghĩa actor được thực hiện toàn bộ thao tác của UC đó.

Số UC trong báo cáo này là **số mới của bản Fix**. Số UC cũ có thể chỉ một chức năng hoàn toàn khác.

Việc kiểm tra gồm trích xuất đầy đủ văn bản và bảng, so sánh nội dung, kiểm tra hình nhúng theo thứ tự xuất hiện và đối chiếu điểm ảnh, đọc ảnh người dùng gửi và XML draw.io nhúng. Không dùng tên imageN.png để suy ra thay đổi vì việc lưu lại DOCX đã đánh số lại các ảnh. Trình render DOCX đi kèm không chạy được do thiếu LibreOffice; vì vậy báo cáo không xác nhận phân trang, bố cục Word hoặc số trang.

## 2. Report 1 đã sửa gì

| Vị trí | Bản gốc | Bản Fix |
|---|---|---|
| I.2 Project Purpose | Tập trung kho và truy vết; sales orders, pricing, fulfilment, invoice và refund nằm ngoài phạm vi | Bổ sung Sales Order, Outbound Delivery, picking TO, PGI, hóa đơn nội bộ/PDF, SMTP, giá bán nhập tay và ghi nhận hoàn tiền thực hiện ngoài hệ thống |
| III.3 Section Summary | WMSD chủ yếu xử lý bằng chứng và nghiệp vụ kho; retail/financial records ở MISA | Nêu thêm fulfilment và internal invoicing; kế toán tài chính, thu tiền và công nợ vẫn ngoài phạm vi |
| IV Proposed Solution | Mô tả thiên về Store Owner, kế toán và kho | Nêu năm role: Store Owner, Accountant, Inventory Staff, Sales Staff, Administrator; làm rõ phạm vi và ngoại lệ |
| Bảng GAP → giải pháp | GAP-06 là request-linked warehouse issue; GAP-07 loại trừ refund | GAP-06 thành chuỗi Sales Order → xuất kho → hóa đơn; GAP-07 thêm yêu cầu, duyệt và bằng chứng hoàn tiền bên ngoài |
| Quy trình bán hàng đề xuất | Shipping Staff tạo delivery; Billing Staff tạo billing document | Sales Staff tạo Outbound Delivery; Inventory Staff bàn giao; Accountant tạo/phát hành internal invoice |
| Picking và PGI | Nhắc FIFO/configured strategy và khả năng sinh accounting documents | Dùng quy tắc picking cố định; PGI ghi nhận xuất thực tế đúng một lần, không sinh sổ kế toán hoặc thu tiền |
| Kiểm kê | Các bước plan/count/reconcile/adjust chưa tách rõ tác động tồn | Owner tạo phiên; Inventory Staff đếm/đối soát/đề nghị; Owner phê duyệt rồi thực hiện Clear Difference riêng; phê duyệt chưa đổi tồn |
| Chuyển kho | Mô tả confirm TO khá tổng quát | Ghi dispatch/handover/receipt trong workflow confirm, theo dõi In Transit và giữ mở chênh lệch |
| Mua hàng | Supplier xuất hiện trong các hàng vai trò nghiệp vụ | Các hàng liên quan được chuyển thành Accountant ghi nhận/phối hợp hành động bên ngoài; không tạo tài khoản Supplier |
| Khách trả hàng | Có mô tả cập nhật average cost | Bỏ tác động kế toán/average cost tự động; phân loại, nhận hàng, vị trí và trạng thái chất lượng; không tự hoàn tiền |
| Trả nhà cung cấp | Có refund/debt reduction và current average value | Nhấn mạnh trả hàng vật lý, chứng từ, xác nhận và chống trừ tồn hai lần; settlement/công nợ NCC ngoài phạm vi |
| V.1 Major Features | Đã có 9 FE | Vẫn 9 FE nhưng mở rộng/đổi tên, nổi bật FE-02, FE-06, FE-07, FE-09 |
| V.2 Limitations | 9 mục; loại sales order/pricing/refund khỏi hệ thống | 10 mục; cho phép sales/internal invoice/refund evidence; thêm LI-10 loại trừ trình tạo/sửa chính sách nghiệp vụ tổng quát |

Các chỉnh sửa nhỏ: thêm Change Log ngày 15/10/2026; chỉnh câu chữ ở quy trình hiện tại; bỏ hai dòng liên kết “Official product guidance reviewed” ở phần KiotViet và MISA. Cần cân nhắc giữ lại nguồn tham khảo ở vị trí thích hợp nếu báo cáo cần bằng chứng cho nhận định so sánh.

Về hình: 11/12 ảnh giữ nguyên điểm ảnh khi so theo vị trí; hình Inventory Audit TO-BE là ảnh duy nhất thay đổi. Các hình quy trình còn lại chưa được đồng bộ chỉ vì phần mô tả đã sửa.

## 3. Report 3 đã sửa gì

| Nhóm | Thay đổi thực tế |
|---|---|
| Phạm vi | Đồng bộ phần mở đầu với sales fulfilment, internal invoice, manual prices, SMTP và refund evidence |
| Feature và UC | 13 nhóm FE trong danh mục cũ → 9 FE; 109 UC → 102 UC. Có thêm UC mới đồng thời gom nhiều UC cũ, không phải đơn thuần xóa 7 chức năng |
| Actor | Store Manager → Store Owner; Warehouse Staff → Inventory Staff; giữ đúng 5 role ứng dụng |
| Business flow | Sửa trigger, decision handling và end condition, đặc biệt BF-01, BF-03 đến BF-07; phân biệt picking với PGI, duyệt với posting, nhận hàng trả với refund |
| Permission Matrix | Thay bằng 102 dòng quyền theo thao tác; giới hạn create/update/activate, view/issue/export, phạm vi kho và báo cáo |
| Đặc tả UC | Thay bộ 109 đặc tả bằng 102 đặc tả theo danh mục mới; thêm phân quyền phía server, kiểm tra trạng thái, chống thao tác lặp và kiểm soát phiên bản |
| Screen Inventory | 21 → 27 màn hình; SC-16 đổi từ Goods Issue Requests sang Sales Orders |
| 6 màn hình mới | SC-22 Outbound Deliveries; SC-23 Picking Transfer Orders; SC-24 Customers; SC-25 Selling Prices; SC-26 Internal Invoices; SC-27 Refund Requests |
| Công nghệ lưu trữ | SQL Server/kiểu dữ liệu quan hệ được chuyển trong phần yêu cầu sang MongoDB, ObjectId, Date UTC, Decimal128… |
| Tích hợp và job | Thêm API-01 SMTP và JOB-01 gửi email trạng thái sau commit; lỗi email không rollback nghiệp vụ; có retry/deduplication |
| NFR | Bổ sung MongoDB, SMTP, PDF/Print; tính nguyên tử, chống lặp, concurrency và snapshot bất biến |
| Business Rules, Messages | Bổ sung nhóm GB-NEW, GB-AUTH, GB-POLICY và 7 thông báo MSG-01…MSG-07 |

### Những nhóm UC được gom đáng chú ý

| Chức năng/nhãn cũ | UC đích của bản Fix |
|---|---|
| Create / Update / Cancel PO, Record Supplier Confirmation | UC-07 Manage Purchase Order and Supplier Confirmation |
| View Outstanding Purchase Quantity | Nội dung đọc trong UC-06 View purchase order details |
| Create / Update / Activate-Deactivate Product, Configure Packaging and Unit Conversion | UC-13 Maintain Product and Packaging |
| Create Lot, Update Lot Information | UC-16 Maintain Product Lot, với quyền khác nhau theo actor |
| Create / Update / Activate-Deactivate Supplier | UC-19 Maintain Supplier, với quyền khác nhau theo thao tác |
| Actual receipt characteristics, inspection classification, defect evidence, discrepancy, accepted receipt posting | UC-26 Inspect and Post Goods Receipt |
| Create / Update / Activate-Deactivate Location | UC-29 Maintain Storage Location |
| Dispatch / handover / destination receipt / discrepancy recording của chuyển kho | UC-43 Confirm Warehouse Transfer Order; phê duyệt xử lý chênh lệch vẫn tách UC-44 |
| Kiểm tra hàng lỗi, cách ly, lập đề xuất xử lý | UC-65 Inspect Defective Goods and Submit Disposition; duyệt UC-66 và thực hiện UC-67 tách riêng |
| Capture Book Balance, Count, Recount | UC-87 Perform Stocktake Count and Record Results |
| Đối soát, xác định nguyên nhân chênh lệch kiểm kê | UC-88 Reconcile Stocktake |
| Năm báo cáo kho riêng | UC-99 View Operational Reports, giữ giới hạn nhóm báo cáo theo role |
| Create / Update / Activate-Deactivate Staff Account | UC-97 Maintain Staff Account; phân quyền UC-98 vẫn riêng |

### Hình đã thay nhưng chưa đồng bộ xong

Report 3 có 37 ảnh ở cả hai phiên bản. Khi so theo vị trí nội dung, 6 ảnh thay đổi: Context Diagram, ERD, và bốn hình UC ở mục 4.3.1–4.3.4. 31 ảnh còn lại giữ nguyên điểm ảnh, gồm cả 7 business flow, hình UC mục 4.3.5, Screen Flow và 21 mockup cũ. Sáu màn hình mới chỉ có bảng mô tả/trường dữ liệu, chưa có mockup mới trong tài liệu.

SC-16 là ví dụ rõ: tiêu đề phần văn bản đã thành Sales Orders nhưng ảnh vẫn ghi Goods Issue Requests.

## 4. Những vấn đề còn tồn tại trong bản Fix

1. **Mục I.3.2 Entity Descriptions của Report 3 giữ nguyên toàn bộ văn bản.** Ví dụ Stocktake vẫn trỏ UC-70–76, trong khi bộ kiểm kê mới là UC-84–93; Goods Issue vẫn trỏ UC-82–89. Replenishment Request vẫn dùng Store Manager. Cần cập nhật ý nghĩa thực thể và toàn bộ traceability theo số mới.
2. **Các tham chiếu đã thay tự động còn lỗi.** DR-04 có `UC-65–56`; GB-04 có `UC-65–50,92–95`; Security/Approval protection có `UC-91–81,95,100`. Đây là khoảng đảo hoặc mã thuộc chức năng khác. Cần ánh xạ theo ý nghĩa, không chỉ thay chuỗi số.
3. **ERD thay ảnh nhưng chưa bao phủ phạm vi mới.** Hình hiện tại chưa thể hiện Customer, Sales Order, Outbound Delivery, Selling Price, Internal Invoice, Refund Request; cũng thiếu Lot và Location dù đặc tả tồn kho phụ thuộc chúng. Cần cập nhật mô hình và mô tả thực thể cùng nhau.
4. **Context Diagram chưa khớp toàn bộ quyền mới.** Vẫn có Supplier Return Request Data từ Accountant và Sales Return Data từ Sales Staff vào hệ thống, trong khi UC-81 và UC-70 giao Inventory Staff tạo. Thiếu luồng invoice/refund tương ứng. Cloudinary xuất hiện trên hình nhưng bảng External API mới chỉ có SMTP: cần bổ sung hợp đồng tích hợp nếu giữ Cloudinary, hoặc điều chỉnh hình để thống nhất.
5. **Hình business flow còn phiên bản cũ.** BF-05 vẫn có caption Warehouse Issue and Stock Deduction, trong khi heading đã là Sales Order Fulfilment and Internal Invoice. BF-04 cần đồng bộ Owner Clear Difference; BF-06 cần thể hiện nhánh refund mới ở mức phù hợp.
6. **Report 1 chưa đồng bộ hết các đoạn giữ lại.** GAP-09 còn câu “rather than duplicate retail or financial processing”, trong khi phạm vi mới đã có sales order và internal invoice. Cần diễn đạt lại ranh giới retail nội bộ với kế toán tài chính. Quy trình customer return đề xuất chưa vẽ nhánh refund dù scope và GAP-07 đã thêm.
7. **Vai trò nghiệp vụ bên ngoài và người nhập liệu cần phân biệt.** Report 1 chuyển dòng Deliver goods sang Accountant nhưng mô tả vẫn là chuẩn bị/giao hàng của Supplier. Nên ghi rõ “Supplier thực hiện ngoài hệ thống; Accountant phối hợp/ghi nhận” trong business flow. Việc Supplier không có tài khoản không có nghĩa Accountant thực hiện việc giao hàng.
8. **UC-92 đã đổi ý nghĩa chi tiết.** Đặc tả mới chỉ mô tả phê duyệt, giữ yêu cầu chưa giải quyết nếu thiếu bằng chứng; không định nghĩa thêm nhánh reject-and-rework. Vì thế nhãn cũ Approve or Reject Adjustment cần đổi đúng thành Approve Inventory Adjustment nếu lấy bản Fix làm chuẩn.

## 5. Sửa sơ đồ Store Owner

**Xóa đường generalization Inventory Staff → Store Owner.** XML nhúng xác nhận đầu tam giác rỗng hướng vào Store Owner. Quan hệ này biểu diễn Inventory Staff kế thừa Store Owner và dẫn đến thể hiện sai quyền duyệt/quản trị nghiệp vụ. Đảo chiều cũng không phù hợp bảng quyền mới: Owner không tự có quyền nhận hàng, PGI hoặc đếm kho. Vẽ liên kết trực tiếp theo ma trận.

| Vùng hiện có | Chỉnh sửa |
|---|---|
| Create/Update/Activate Product + Packaging | Gom thành UC-13 Maintain Product and Packaging; giữ UC-11/12 list/detail |
| Update Lot Information | Đổi thành UC-16 Maintain Product Lot; Owner được Create/Update; bổ sung UC-15 lot detail |
| Activate/Deactivate Supplier | Thể hiện UC-19 với note Owner chỉ Activate/Deactivate; không gán Create/Update |
| Ba UC quản lý location | Gom UC-29 Maintain Storage Location; bổ sung UC-28 detail |
| Approve or Reject Supplier Return Request | Đổi thành UC-83 Review Supplier Return Closure; duyệt đóng sau dispatch/acknowledgement, không chỉ đổi tên một bước duyệt trước xuất |
| Warehouse Transfer | Thêm UC-39 detail, UC-41 Review Transfer Request; đổi duyệt discrepancy thành UC-44 |
| Stocktake | Create Stocktake → UC-86 Create Stocktake Session; bổ sung UC-85 detail |
| Adjustment | Dùng UC-89 list, UC-90 detail, UC-92 Approve Inventory Adjustment; thêm UC-93 Clear Stocktake Difference riêng |
| Hai báo cáo đang vẽ | Gom UC-99, note Owner được cả 5 nhóm báo cáo |
| Trace Lot | Dùng UC-102; bổ sung UC-100/101 movement log/detail |

Các nhóm cần bổ sung đầy đủ: xem PO và receipt (UC-05/06/08/09); Customer list/detail (20/21); Selling Price list/detail và Maintain Selling Price (23/24/25); inventory list/detail và location movement list/detail (30/31/34/35); xem Sales Order, Outbound Delivery, Picking TO, Goods Issue (45/46/49/50/52/53/56/57); hóa đơn (59/60/62, chỉ export/print bản đã phát hành); defective goods list/detail và approve disposition (63/64/66); customer return list/detail/review (68/69/71); refund list/detail/review (74/75/77); supplier return list/detail (79/80); Sign in (94).

## 6. Sửa sơ đồ Sales Staff

| Hiện có | Chỉnh sửa theo Fix |
|---|---|
| View Product List/Detail | Giữ, gắn UC-11/12 |
| View Inventory List | Đổi đúng UC-30 View stock by lot, location, and quality status; note chỉ usable stock, không cost/unrestricted quarantine data |
| View Issue Request List/Detail, Create Issue Request | Thay nhóm cũ bằng UC-45/46/47 Sales Order; thêm UC-48 Update or Cancel Sales Order. Đây là thay mô hình nghiệp vụ, không chỉ đổi nhãn |
| Record Customer Return into Warehouse | Bỏ quyền thao tác này khỏi Sales Staff; UC-70/72/73 thuộc Inventory Staff |

Bổ sung UC-20/21/22 Customers; UC-23/24 xem giá; UC-49/50/51 Outbound Delivery; UC-68/69 xem customer return trong phạm vi bán hàng liên quan; UC-94 Sign in. Không thêm quyền duyệt refund, ghi nhận refund, PGI hoặc phát hành hóa đơn cho Sales Staff.

## 7. Sửa sơ đồ Inventory Staff

Đây là hình thiếu nhiều thao tác thực hiện nhất; hiện chủ yếu thể hiện list/detail.

| Nhóm | Chỉnh sửa |
|---|---|
| Lot | Create Lot → UC-16 Maintain Product Lot với note **Create only**; không được Update lot |
| PO | Bỏ ellipse View Outstanding Purchase Quantity độc lập; dữ liệu nằm trong UC-06. UC-05/06 giới hạn receiving scope |
| Receipt | Giữ UC-08/09/10. Gom Record Actual Receipt Characteristics, Classify Inspection Result, Record Defective Goods on Receipt, Record Receipt Discrepancy, Complete Accepted Receipt thành UC-26 |
| Put-away | Thêm UC-32 Create Put-away Transfer Order và UC-33 Confirm Put-away Transfer Order |
| Location movement | Giữ UC-34/35; thêm UC-36 Create location movement và UC-37 Confirm actual location movement |
| Warehouse transfer | Giữ UC-38/39; thêm UC-40 Create Transfer Request, UC-42 Create Warehouse Transfer Order, UC-43 Confirm Warehouse Transfer Order. Không nối quyền duyệt UC-41/44 cho Inventory Staff |
| Outbound | Thêm UC-49/50 xem delivery, UC-52/53 xem Picking TO, UC-54 tạo Picking TO, UC-55 confirm Picking TO, UC-56/57 xem goods issue, UC-58 PGI |
| Hàng lỗi | Move Goods to Pending or Damaged Status chuyển thành một phần UC-65 Inspect Defective Goods and Submit Disposition; thêm UC-67 Record approved defective goods disposition; giữ UC-63/64 |
| Customer return | Thêm UC-68/69/70/72/73; Owner thực hiện UC-71, không phải Inventory Staff |
| Supplier return | Giữ UC-79/80; thêm UC-81 Create Supplier Return Request và UC-82 Confirm Supplier Return Dispatch; Owner đóng qua UC-83 |
| Stocktake | Capture Book Balance at Cut-off không là UC riêng; gom trong UC-87 Perform Stocktake Count and Record Results, gồm count/recount history; thêm UC-88 Reconcile Stocktake |
| Adjustment | Giữ UC-89/90; thêm UC-91 Create Inventory Adjustment Request. UC-92/93 thuộc Owner |
| Report | Gom 4 ellipse report thành UC-99; note chỉ Movement, Stock by lot/location, Transfer, Stocktake; theo kho được phân công |
| Trace và login | Giữ/chuẩn hóa UC-100/101/102; thêm UC-94 |

Phải giữ UC-55 và UC-58 riêng: confirm picking chuyển hàng vào staging; PGI mới trừ tổng tồn kho. Không gom hai bước này thành một thao tác.

## 8. Sửa sơ đồ Accountant

| Vùng hiện có | Chỉnh sửa |
|---|---|
| Create/Update Supplier | Gom UC-19 Maintain Supplier, note **Create/Update only** |
| Activate/Deactivate Supplier | Bỏ quyền này khỏi Accountant; chỉ Store Owner có quyền |
| Create Supplier Return Request | Bỏ khỏi Accountant; chuyển sang Inventory Staff dưới UC-81. Accountant giữ UC-79/80 đọc |
| Create Replenishment Request | Giữ UC-03; thêm UC-01/02 list/detail |
| Create/Update/Cancel PO, Record Supplier Confirmation | Gom UC-07; giữ UC-05/06 list/detail |
| Create Purchase Order extend Create Replenishment Request | Bỏ đường này: PO dựa trên request đã duyệt là điều kiện nghiệp vụ, không phải mở rộng trực tiếp hành vi tạo request |
| View Return List/Detail | Chuẩn hóa UC-68/69 View customer return list/details |
| Report | Gom UC-99; chỉ Movement và Purchase/Receipt |

Thêm Customer list/detail UC-20/21; Selling Price list/detail UC-23/24; Internal Invoice UC-59/60/61/62; Refund UC-74/75/76/78; movement log/detail và lot trace UC-100/101/102 trong phạm vi mua hàng/NCC. Giữ product UC-11/12, receipt UC-08/09, inventory UC-30 và Sign in UC-94.

Accountant tạo yêu cầu hoàn tiền và ghi nhận bằng chứng đã hoàn ngoài hệ thống; không duyệt yêu cầu và không chuyển tiền qua WMSD.

## 9. Sửa sơ đồ Administrator

Chuẩn hóa tên actor thành Administrator. Bộ UC cuối cùng gồm đúng 5 UC:

| UC | Tên |
|---|---|
| UC-94 | Sign in to the system |
| UC-95 | View account list |
| UC-96 | View account details |
| UC-97 | Maintain Staff Account |
| UC-98 | Assign roles and operation permissions |

Gom Create Staff Account, Update Staff Account và Activate/Deactivate Account vào UC-97. UC-98 vẫn độc lập. Không thêm quyền duyệt nghiệp vụ, posting tồn kho hoặc tạo chính sách tùy ý.

## 10. Sửa quan hệ và cách trình bày chung

- Gắn mã UC mới lên từng ellipse để kiểm tra với báo cáo. List và Detail vẫn là các UC riêng vì danh mục Fix giữ riêng.
- Không dùng `<<extend>>` như mũi tên chuyển trang từ List sang Detail/Create/Update. Extend mô tả hành vi bổ sung tại extension point của UC cơ sở; include mô tả hành vi UC khác được chèn vào UC gọi. Với các chức năng độc lập trong bộ tài liệu này, ưu tiên liên kết actor–UC trực tiếp; chỉ giữ include/extend khi đặc tả thực sự nêu hành vi tương ứng.
- Vì vậy cần rà lại toàn bộ chuỗi `List ← extend ← Detail ← extend ← Action` ở cả năm hình, không chỉ đổi hướng mũi tên.
- Trong hình Accountant, hai đường include từ Update Purchase Order/Record Supplier Confirmation sang View Purchase Order Detail được loại khi gom UC-07; không cần cố giữ cấu trúc quan hệ cũ.
- Trong hình Owner, list/detail của Adjustment đang nối ngược mô hình phổ biến của các vùng còn lại. Nên thay bằng association trực tiếp tới UC-89 và UC-90, thay vì chỉ đảo mũi tên extend.
- Dùng note quyền thao tác cho UC-16, UC-19, UC-62, UC-99. Ví dụ Owner nối UC-62 phải ghi “Export/Print issued only”, không để hình ngụ ý Owner được Issue.
- Mọi role có UC-94. Có thể đặt đăng nhập ở một hình chung, nhưng phải ghi rõ các hình actor chỉ là view bộ phận nếu bỏ login để giảm rối.
- Năm role là role ứng dụng. SMTP là hệ thống ngoài, có thể thể hiện ở hình tương tác/context hoặc supporting actor nếu mô hình cần; không biến thành role người dùng thứ sáu và không tự thêm mã UC-103 vì catalogue hiện có 102 UC. Cloudinary cũng cần được thống nhất với API inventory trước khi bổ sung vào mô hình UC.
- Không dùng include để biểu diễn thứ tự Sales Order → Delivery → Picking → PGI → Invoice hoặc Request → Approval → Posting. Thứ tự và điều kiện trạng thái thuộc business/activity flow và preconditions.
- Các hình lớn có thể tách theo FE hoặc nhóm nghiệp vụ để giảm đường giao nhau; vẫn dùng cùng mã UC ở các view và không tăng số UC chỉ vì cùng UC xuất hiện trên nhiều hình.

Căn cứ ngữ nghĩa UML: [OMG về Extend](https://issues.omg.org/issues/UML25-418), [OMG về Include](https://issues.omg.org/issues/UML25-421). Các khuyến nghị liên kết trực tiếp là áp dụng ngữ nghĩa này vào đặc tả hiện có, không khẳng định mọi mô hình List/Detail dùng extend đều sai trong mọi trường hợp.

## 11. Thứ tự chỉnh sửa đề xuất

1. Chốt catalogue 102 UC và operation-level permissions làm chuẩn cho lần đồng bộ này; sửa các tham chiếu cũ/sai trong Report 3.
2. Sửa Inventory Staff và Sales Staff để đủ chuỗi thực thi kho/bán hàng; chuyển đúng hai chức năng tạo trả hàng.
3. Sửa Store Owner để đúng quyền duyệt, Clear Difference, giá bán và quyền xem; bỏ kế thừa actor.
4. Sửa Accountant để đủ invoice/refund, bỏ quyền supplier không được cấp; gom Administrator.
5. Sửa Context, ERD, business flows, Screen Flow và mockup cho cùng phạm vi; thay hình vào Report 1/3.
6. Kiểm tra từng UC có ít nhất một actor đúng quyền, mọi thao tác duyệt/posting có đúng người, các UC gộp có note hạn chế và không phát sinh chức năng ngoài scope.

Phụ lục dưới đây trích nguyên tên UC và quyền từ I.4.4 của Report 3 Fix, dùng làm checklist đầy đủ khi vẽ, bao gồm các quyền xem dễ bị bỏ sót.


## Phụ lục A Danh sách đầy đủ theo actor

Các UC xuất hiện ở nhiều actor vẫn chỉ tính một lần trong catalogue 102 UC. Số bên dưới là số liên kết actor–UC, đã bao gồm Sign in.

### Store Owner

67 UC có quyền tham gia.

| UC | Tên trong bản Fix | Quyền / phạm vi |
|---|---|---|
| UC-01 | View replenishment request list | View |
| UC-02 | View replenishment request details | View |
| UC-04 | Approve or reject replenishment request | Approve |
| UC-05 | View purchase order list | View |
| UC-06 | View purchase order details | View |
| UC-08 | View goods receipt list | View |
| UC-09 | View goods receipt details | View |
| UC-11 | View product list | View |
| UC-12 | View product details | View |
| UC-13 | Maintain Product and Packaging | Perform |
| UC-14 | View lot list | View |
| UC-15 | View lot details | View |
| UC-16 | Maintain Product Lot | Create / Update |
| UC-17 | View supplier list | View |
| UC-18 | View supplier details | View |
| UC-19 | Maintain Supplier | Activate / Deactivate |
| UC-20 | View Customer List | View |
| UC-21 | View Customer Details | View |
| UC-23 | View Selling Price List | View |
| UC-24 | View Selling Price Details | View |
| UC-25 | Maintain Selling Price | Perform |
| UC-27 | View warehouse and location list | View |
| UC-28 | View storage location details | View |
| UC-29 | Maintain Storage Location | Perform |
| UC-30 | View stock by lot, location, and quality status | View |
| UC-31 | View inventory balance details | View |
| UC-34 | View location movement list | View |
| UC-35 | View location movement details | View |
| UC-38 | View warehouse transfer list | View |
| UC-39 | View warehouse transfer details | View |
| UC-41 | Review Transfer Request | Approve |
| UC-44 | Review Transfer Difference Resolution | Approve |
| UC-45 | View Sales Order List | View |
| UC-46 | View Sales Order Details | View |
| UC-49 | View Outbound Delivery List | View |
| UC-50 | View Outbound Delivery Details | View |
| UC-52 | View Picking Transfer Order List | View |
| UC-53 | View Picking Transfer Order Details | View |
| UC-56 | View goods issue list | View |
| UC-57 | View goods issue details | View |
| UC-59 | View Internal Invoice List | View |
| UC-60 | View Internal Invoice Details | View |
| UC-62 | Issue Internal Invoice and Produce PDF | Export / Print issued only |
| UC-63 | View defective goods list | View |
| UC-64 | View defective goods details | View |
| UC-66 | Approve or reject defective goods disposition | Approve |
| UC-68 | View customer return list | View |
| UC-69 | View customer return details | View |
| UC-71 | Review Customer Return Request | Approve |
| UC-74 | View Refund Request List | View |
| UC-75 | View Refund Request Details | View |
| UC-77 | Review Customer Return Refund Request | Approve |
| UC-79 | View supplier return request list | View |
| UC-80 | View supplier return request details | View |
| UC-83 | Review Supplier Return Closure | Approve |
| UC-84 | View stocktake list | View |
| UC-85 | View stocktake details | View |
| UC-86 | Create Stocktake Session | Perform |
| UC-89 | View inventory adjustment request list | View |
| UC-90 | View inventory adjustment request details | View |
| UC-92 | Approve Inventory Adjustment | Approve |
| UC-93 | Clear Stocktake Difference | Perform |
| UC-94 | Sign in to the system | Use |
| UC-99 | View Operational Reports | All report groups |
| UC-100 | View stock movement log | View |
| UC-101 | View stock movement details | View |
| UC-102 | Trace a product lot through source documents | View |

### Accountant

35 UC có quyền tham gia.

| UC | Tên trong bản Fix | Quyền / phạm vi |
|---|---|---|
| UC-01 | View replenishment request list | View |
| UC-02 | View replenishment request details | View |
| UC-03 | Create replenishment request | Perform |
| UC-05 | View purchase order list | View |
| UC-06 | View purchase order details | View |
| UC-07 | Manage Purchase Order and Supplier Confirmation | Perform |
| UC-08 | View goods receipt list | View |
| UC-09 | View goods receipt details | View |
| UC-11 | View product list | View |
| UC-12 | View product details | View |
| UC-17 | View supplier list | View |
| UC-18 | View supplier details | View |
| UC-19 | Maintain Supplier | Create / Update |
| UC-20 | View Customer List | View |
| UC-21 | View Customer Details | View |
| UC-23 | View Selling Price List | View |
| UC-24 | View Selling Price Details | View |
| UC-30 | View stock by lot, location, and quality status | View |
| UC-59 | View Internal Invoice List | View |
| UC-60 | View Internal Invoice Details | View |
| UC-61 | Create Internal Invoice | Perform |
| UC-62 | Issue Internal Invoice and Produce PDF | Issue / Export / Print |
| UC-68 | View customer return list | View |
| UC-69 | View customer return details | View |
| UC-74 | View Refund Request List | View |
| UC-75 | View Refund Request Details | View |
| UC-76 | Create Customer Return Refund Request | Perform |
| UC-78 | Record Refund Completion | Perform |
| UC-79 | View supplier return request list | View |
| UC-80 | View supplier return request details | View |
| UC-94 | Sign in to the system | Use |
| UC-99 | View Operational Reports | Movement; purchase/receipt |
| UC-100 | View stock movement log | Purchase / supplier scope |
| UC-101 | View stock movement details | Purchase / supplier scope |
| UC-102 | Trace a product lot through source documents | Purchase / supplier scope |

### Inventory Staff

60 UC có quyền tham gia.

| UC | Tên trong bản Fix | Quyền / phạm vi |
|---|---|---|
| UC-05 | View purchase order list | Receiving scope only |
| UC-06 | View purchase order details | Receiving scope only |
| UC-08 | View goods receipt list | View |
| UC-09 | View goods receipt details | View |
| UC-10 | Create goods receipt from purchase order | Perform |
| UC-11 | View product list | View |
| UC-12 | View product details | View |
| UC-14 | View lot list | View |
| UC-15 | View lot details | View |
| UC-16 | Maintain Product Lot | Create only |
| UC-26 | Inspect and Post Goods Receipt | Perform |
| UC-27 | View warehouse and location list | View |
| UC-28 | View storage location details | View |
| UC-30 | View stock by lot, location, and quality status | View |
| UC-31 | View inventory balance details | View |
| UC-32 | Create Put-away Transfer Order | Perform |
| UC-33 | Confirm Put-away Transfer Order | Perform |
| UC-34 | View location movement list | View |
| UC-35 | View location movement details | View |
| UC-36 | Create location movement | Perform |
| UC-37 | Confirm actual location movement | Perform |
| UC-38 | View warehouse transfer list | View |
| UC-39 | View warehouse transfer details | View |
| UC-40 | Create Transfer Request | Perform |
| UC-42 | Create Warehouse Transfer Order | Perform |
| UC-43 | Confirm Warehouse Transfer Order | Perform |
| UC-49 | View Outbound Delivery List | View |
| UC-50 | View Outbound Delivery Details | View |
| UC-52 | View Picking Transfer Order List | View |
| UC-53 | View Picking Transfer Order Details | View |
| UC-54 | Create Picking Transfer Order | Perform |
| UC-55 | Confirm Picking Transfer Order | Perform |
| UC-56 | View goods issue list | View |
| UC-57 | View goods issue details | View |
| UC-58 | Post Goods Issue | Perform |
| UC-63 | View defective goods list | View |
| UC-64 | View defective goods details | View |
| UC-65 | Inspect Defective Goods and Submit Disposition | Perform |
| UC-67 | Record approved defective goods disposition | Perform |
| UC-68 | View customer return list | View |
| UC-69 | View customer return details | View |
| UC-70 | Create Customer Return Request | Perform |
| UC-72 | Inspect Customer Return | Perform |
| UC-73 | Confirm Customer Return Receipt | Perform |
| UC-79 | View supplier return request list | View |
| UC-80 | View supplier return request details | View |
| UC-81 | Create Supplier Return Request | Perform |
| UC-82 | Confirm Supplier Return Dispatch | Perform |
| UC-84 | View stocktake list | View |
| UC-85 | View stocktake details | View |
| UC-87 | Perform Stocktake Count and Record Results | Perform |
| UC-88 | Reconcile Stocktake | Perform |
| UC-89 | View inventory adjustment request list | View |
| UC-90 | View inventory adjustment request details | View |
| UC-91 | Create Inventory Adjustment Request | Perform |
| UC-94 | Sign in to the system | Use |
| UC-99 | View Operational Reports | Movement; stock; transfer; stocktake |
| UC-100 | View stock movement log | View |
| UC-101 | View stock movement details | View |
| UC-102 | Trace a product lot through source documents | View |

### Sales Staff

18 UC có quyền tham gia.

| UC | Tên trong bản Fix | Quyền / phạm vi |
|---|---|---|
| UC-11 | View product list | View |
| UC-12 | View product details | View |
| UC-20 | View Customer List | View |
| UC-21 | View Customer Details | View |
| UC-22 | Maintain Customer | Perform |
| UC-23 | View Selling Price List | View |
| UC-24 | View Selling Price Details | View |
| UC-30 | View stock by lot, location, and quality status | Usable stock only |
| UC-45 | View Sales Order List | View |
| UC-46 | View Sales Order Details | View |
| UC-47 | Create Sales Order | Perform |
| UC-48 | Update or Cancel Sales Order | Perform |
| UC-49 | View Outbound Delivery List | View |
| UC-50 | View Outbound Delivery Details | View |
| UC-51 | Create Outbound Delivery | Perform |
| UC-68 | View customer return list | Related sales records only |
| UC-69 | View customer return details | Related sales records only |
| UC-94 | Sign in to the system | Use |

### Administrator

5 UC có quyền tham gia.

| UC | Tên trong bản Fix | Quyền / phạm vi |
|---|---|---|
| UC-94 | Sign in to the system | Use |
| UC-95 | View account list | View |
| UC-96 | View account details | View |
| UC-97 | Maintain Staff Account | Perform |
| UC-98 | Assign roles and operation permissions | Perform |

## Phụ lục B Nguồn đối chiếu

- [WMSD_Report1.docx](<D:/Ky_9/SEP490/dóc/WMSD_Report1.docx>)
- [WMSD_Report1_Fix.docx](<D:/Ky_9/SEP490/dóc/WMSD_Report1_Fix.docx>)
- [WMSD_Report-3.docx](<D:/Ky_9/SEP490/dóc/WMSD_Report-3.docx>)
- [WMSD_Report3_Fix.docx](<D:/Ky_9/SEP490/dóc/WMSD_Report3_Fix.docx>)
- [WMSD_Bangach-Bản sao của UC SO.drawio.png](<D:/Ky_9/SEP490/dóc/WMSD_Bangach-Bản sao của UC SO.drawio.png>)
- [WMSD_Bangach-Bản sao của UC SS.drawio.png](<D:/Ky_9/SEP490/dóc/WMSD_Bangach-Bản sao của UC SS.drawio.png>)
- [WMSD_Bangach-Bản sao của UC_IS.drawio (1).png](<D:/Ky_9/SEP490/dóc/WMSD_Bangach-Bản sao của UC_IS.drawio (1).png>)
- [WMSD_Bangach-Bản sao của UC Accountants.drawio.png](<D:/Ky_9/SEP490/dóc/WMSD_Bangach-Bản sao của UC Accountants.drawio.png>)
- [WMSD_Bangach-Bản sao của UC Admin.drawio.png](<D:/Ky_9/SEP490/dóc/WMSD_Bangach-Bản sao của UC Admin.drawio.png>)
