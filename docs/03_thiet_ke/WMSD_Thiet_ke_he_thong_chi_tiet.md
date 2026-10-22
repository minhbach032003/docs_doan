# Thiết kế hệ thống WMSD

Phiên bản 3.0.0 • Đồng bộ ngày 22/10/2026 • Phạm vi lưu trữ: MongoDB runtime

Tài liệu này thay thế nội dung thiết kế 1.0 ngày 16/10/2026 làm căn cứ triển khai trong repo. Nguồn hiện hành là [quy trình VI](../02_nghiep_vu/de_xuat_quy_trinh_2_VI.md), [EN](../02_nghiep_vu/de_xuat_quy_trinh_2_EN.md), [Report 1](../01_bao_cao/WMSD_Report1_Fix.docx.txt), [Report 3](../01_bao_cao/WMSD_Report3_Fix.docx.txt) và [thiết kế dữ liệu](de_xuat_database_design_VI.md). Bộ quy trình có 8 BF, 5 vai trò, 111 UC (98 active/13 retired), BR-01–33 và 31 màn hình (28 active/3 retired). Đây là thiết kế được chọn, chưa phải xác nhận mọi kiểm soát đã được cửa hàng triển khai.

Chuỗi bán hàng thống nhất: SO nhập lại từ nguồn ngoài đã xác minh → WIR liên kết → OD/soạn hàng → PGI → Warehouse xác nhận POD có ảnh → DELIVERED → Sales xác nhận đã nhận đủ tiền bên ngoài bằng PAY-CFM → COMPLETED. Tồn chỉ giảm tại PGI; tạo đơn, xác nhận khách nhận và xác nhận tiền không ghi giảm thêm.

## 1. Phạm vi và thứ tự nguồn

- Một cửa hàng, khảo sát ghi nhận từ 3 kho; chưa tự đặt tên/địa chỉ kho, số người, hệ số SKU hoặc thời hạn nhận trả.
- Quyết định nghiệp vụ trong quy trình 3.0.0 và Report 3 chi phối API, dữ liệu, quyền và nghiệm thu. SQL là mô hình quan hệ tham chiếu để review, không phải migration MongoDB hoặc backend đã chạy.
- Giá bán, thương lượng, hóa đơn, thu/chuyển tiền, công nợ, hoàn tiền và kế toán thực hiện bên ngoài. SO là bản sao phục vụ thực hiện đơn; PAY-CFM chỉ ghi nhận xác nhận đủ tiền ngoài hệ thống.
- Không live MISA, không vai trò mua hàng/giao hàng mới, không nhập hộ/ủy quyền động, không tự đặt PO hoặc tối ưu tuyến xe.
- UC-23–25, UC-42, UC-59–62, UC-74–78 là 13 mã retired: giữ lịch sử, không có quyền, màn hình hay API thực thi.
- [Sơ đồ database](WMSD_database_design.drawio) mô tả 73 bảng/2 view của [DDL](WMSD_SQL_schema.sql); [mainflow song ngữ](../04_so_do/WMSD_Mainflows_VI_EN.drawio) có 16 trang. Các workbook cũ và ảnh BF-03B được ghi rõ là lịch sử.
- Report 2 được giữ nguyên theo yêu cầu. Các bản Word/Google Docs bên ngoài repo cần phát hành từ bộ nội dung mới; chỉnh file .docx.txt không tự cập nhật các bản đó.

## 2. Vai trò, quyền và phạm vi bản ghi

| Actor | Trách nhiệm To-be |
|---|---|
| Store Owner | Duyệt bổ sung, điều chuyển liên kho, nhận trả hàng, trả NCC, xử lý hàng lỗi và chênh lệch; xem báo cáo. Không duyệt đổi kệ hàng thông thường. |
| Sales Staff | Sao chép/lập đơn bán SO trong WMSD từ đơn bán bên ngoài đã xác minh (MISA/giấy tờ); tạo và quản lý yêu cầu xuất hàng WIR liên kết với SO và đề nghị khách trả; xác nhận nhu cầu còn lại, giao từng phần, hủy phần chưa xuất và lựa chọn nguồn đáp ứng; liên hệ khách về thay lô/tone; xác nhận đã nhận đủ tiền ngoài hệ thống sau khi đơn ở trạng thái DELIVERED để chuyển SO sang COMPLETED. Không xác nhận chất lượng vật lý hoặc post tồn kho. |
| Warehouse Staff | Kiểm nhận/kiểm tra, soạn hàng, put-away, nhập/xuất (PGI), chuyển vị trí, kiểm kê, cách ly, đề xuất xử lý, và xác nhận đã giao hàng thực tế cho khách kèm ảnh chụp bắt buộc (POD) để cập nhật SO sang DELIVERED. Bị giới hạn theo kho được giao. |
| Accountant | Lập/theo dõi PO sau duyệt, ghi nhận thỏa thuận NCC, đối chiếu chứng từ kho với MISA, ghi tham chiếu xử lý hóa đơn/hoàn tiền/đối chiếu kế toán bên ngoài (UC-108). Không quyết định nhu cầu tồn thay bộ phận vận hành và không xác nhận hoàn thành đơn bán (COMPLETED) thay Sales Staff. |
| Administrator | Tài khoản, phân quyền và cấu hình kỹ thuật. Không tự có quyền duyệt nghiệp vụ, ghi tăng/giảm kho hoặc sửa nhật ký. |

Quyền được kiểm tra phía server theo role + operation/sub-operation + kho/bản ghi + trạng thái/version + danh tính thực tế. Không lấy creator/approver/confirmer từ dữ liệu client làm danh tính xác thực. Người nhiều role vẫn không được tự duyệt đề nghị; người nhận điều chuyển khác người xuất. Nếu chủ được bố trí kiểm nhận độc lập phải được phân công rõ, không mặc định kế thừa quyền Warehouse.

Quyền master giữ đúng Report 3: UC-13 Owner quản lý sản phẩm/quy cách/ngưỡng hữu hạn; UC-16 Owner create/update, Warehouse create only; UC-19 Accountant create/update, Owner activate/deactivate. Admin không tự có quyền nghiệp vụ. Quyền xem không cho phép sửa/xác nhận; cùng scope áp cho tìm kiếm, URL chi tiết, xuất báo cáo và tải bằng chứng.

Phần SO/WIR/POD/PAY-CFM: Sales tạo/sửa SO, WIR/OD và xác nhận tiền; Warehouse được giao kho xác nhận POD; Owner/Accountant chỉ xem/đối chiếu theo quyền. UC-108 của Accountant không thay thế UC-111. Ma trận đầy đủ và phụ lục A truy vết từng UC.

## 3. Hàng tồn, đơn vị và thời điểm ghi nhận

Khóa số dư gồm account vật lý hoặc dòng TD đang chuyển, lot, quality và owner. Product/tone/actual calibre là nhận dạng lô; lot chưa xác minh không được cấp như hàng đủ điều kiện. Không trộn quality với logistics: hàng DAMAGED có thể đồng thời đang chuyển.

- On-hand: tồn thuộc STORE tại location của kho, kể cả receiving, staging và quarantine.
- Transit: tồn STORE trên account của từng dòng TD, không đồng thời cộng vào kho đi hoặc khả dụng kho đích.
- Custody: hàng thuộc khách/NCC được giữ vật lý; theo dõi riêng khỏi tồn sở hữu/khả dụng. Chuyển custody thành STORE cần chứng từ chấp nhận.
- Available: GOOD, lot VERIFIED, master/location active và allocatable, không khóa kiểm kê, trừ ACTIVE reservations đúng số dư. Không trừ cùng lượng giữ hai lần.
- Gạch dùng PIECE làm đơn vị chuẩn; lưu lượng/đơn vị nhập, hệ số và phiên bản trên dòng. BOX/m² phải quy về độ hạt thực của sản phẩm; không tự tạo viên phân số, không dùng calibre thay hệ số diện tích.
- GR-P/GR-CR tăng lượng được cửa hàng nhận sở hữu; put-away/chuyển bin/picking chỉ chuyển vị trí. TD chuyển nguồn sang transit; MWTR chuyển transit sang đích. PGI/GI-SR/SCRAP giảm đúng lượng thực bàn giao/hủy. ACK/duyệt/đóng không post thêm.
- SO/WIR/POD/PAY-CFM không sinh movement. Hủy phần chưa xuất có thể giải phóng reservation nhưng không đổi tồn sở hữu.

Đối soát theo cùng chiều và thời điểm: cuối = đầu + SUM(delta ledger). Chuyển bin/chất lượng có hai vế bằng nhau; không sửa balance trực tiếp để làm khớp số đếm. Ví dụ thiết kế 4 viên/thùng, 0,36 m²/viên: 3 thùng +2 viên =14 viên =5,04 m²; đây không phải hệ số đã khảo sát của mọi SKU.

## 4. Thiết kế xử lý tám quy trình

| BF | Chuỗi và UC | Điều kiện thực hiện, ngoại lệ và tác động |
|---|---|---|
| BF-01 | RR UC-03 → Owner UC-04 → PO UC-07 → ARR/INS/GR UC-10/26 → TO UC-32/33 | Sales/Warehouse kiểm nguồn đã phủ nhu cầu trước khi đề nghị. PO theo dòng được duyệt, nhận nhiều đợt/tách quality/ownership; 0 accepted không sinh GR0. Owner chốt thiếu/vượt duyệt; hàng thay thế là receipt mới. |
| BF-02 | DC/inspection UC-65 → Owner UC-66 → execution UC-67 | Cách ly ngay, không chờ Owner. Release/regrade không giảm tổng; hủy chỉ sau thực hủy. Trả NCC chuyển BF-08, không trừ ở UC-67 rồi trừ lại UC-82. |
| BF-03 | TO-RELOCATE UC-34–37 | Hai location cùng kho, đủ nguồn, không khóa; không Owner/TR/TD/MWTR. Confirm hai vế và chuyển reservation nguyên tử. Partial giữ remainder hoặc hủy có lý do. |
| BF-04 | TR UC-40/41 → TD UC-43 → MWTR UC-104 → put-away → variance UC-44 | Source/destination khác kho, nhận độc lập; bảo toàn demand link. Thừa/sai lô không làm âm transit. Nhận thiếu/hỏng phân quality; chỉ đóng khi mọi lượng có kết quả. Xuất thẳng kho khác dùng BF-06 tại kho thực xuất. |
| BF-05 | Plan UC-86 → freeze/snapshot/count UC-87/105 → reconcile UC-88 → ADJ UC-91/92/93 | Kích hoạt khóa nguyên tử sau xử lý task dở. Blank ≠0; append recount/selected result. Không lệch thì đóng/mở khóa không ADJ0; có lệch giữ khóa qua reject/rework đến Clear Difference. |
| BF-06 | SO UC-45–48 → WIR UC-109 → OD UC-49–51 → pick UC-52–55 → PGI UC-58 → POD UC-110 → PAY-CFM UC-111 | SO cần nguồn/evidence; WIR/OD đúng dòng cha và trần tổng kể cả đã xuất. PGI khi bàn giao thực tế, chưa là DELIVERED. POD có ảnh theo GI-S; Sales xác nhận đủ tiền sau DELIVERED mới COMPLETED. |
| BF-07 | CR UC-70 → custody/inspection UC-72 → Owner UC-71 → GR-CR/handback UC-73 → EXT-REF UC-108 | Kiểm nguồn và đánh giá D6 trước Owner; INELIGIBLE/PENDING không được post. Mixed quantities tách dòng; đổi assessment cần version/duyệt lại. Finance và kết thúc kho độc lập. |
| BF-08 | SR UC-81 → agreement UC-107 → Owner UC-106 → GI-SR UC-82 → ACK UC-107 → variance/closure UC-106/83 | Nội bộ cho phép và NCC chấp thuận là hai điều kiện trước xuất. Tái dùng quyết định BF-02 đúng loại/version/dòng/lượng, không duyệt lặp. ACK sau xuất; unmatched giữ mở, closure không trừ thêm. |

37 nhánh A/E và EX-01–05 được định nghĩa đầy đủ tại mục 4 của quy trình VI/EN và truy vết trong từng đặc tả UC của Report 3. Kiểm quyền, version/nguồn, unknown commit, freeze và evidence là yêu cầu dùng chung, không tự đóng hồ sơ khi lỗi.

### 4.1. Bất biến riêng của đơn bán và xác nhận

1. Một đơn/dòng nguồn chỉ có một SO/dòng sao chép; dùng SO đó khi sửa hoặc mở lại.
2. Tổng WIR chưa hủy, kể cả phần đã xuất, ≤ SO ordered − cancelled. Tổng OD ≤ WIR allowed; PGI ≤ OD; tổng POD CONFIRMED chưa VOIDED ≤ PGI hợp lệ chưa đảo trên đúng GI-S line. Không cộng cha/con thành hai nhu cầu.
3. Giao từng phần giữ PARTIALLY_DELIVERED. Chỉ DELIVERED khi giao đủ từng dòng còn phải thực hiện và tổng nghĩa vụ này >0; full unissued cancellation trước giao là CANCELLED.
4. PAY-CFM chỉ do Sales ghi sau DELIVERED trên phiên bản hiện tại, với fullPaymentReceived=true và reference hoặc evidence hoặc note. Chưa đủ tiền/không rõ/trả trước khi chưa giao đủ không làm COMPLETED.
5. POD/PAY-CFM: DRAFT → CONFIRMED hoặc VOIDED khi đính chính có lý do. Giữ bản gốc, tăng version, tính lại SO và vô hiệu điều kiện hoàn thành cũ; khách trả thông thường vẫn giữ lịch sử giao/nhận tiền và dùng BF-07.

## 5. Mô hình MongoDB và ánh xạ DDL tham chiếu

| Mô hình quan hệ dùng để phân tích | Collection/embedding dự kiến trên MongoDB |
|---|---|
| app_user, app_role, permission, user_warehouse | users, roles, permissions; quan hệ bằng ObjectId reference/role IDs |
| warehouse, location, party, product, uom, lot | warehouses, locations, parties, products, lots; snapshot thuộc tính quan trọng vào dòng chứng từ |
| document + typed header + document_line | business_documents phân loại documentType, hoặc collection theo bounded context cùng documentId; embed header/lines nếu cùng vòng đời và giới hạn kích thước |
| sales_order + line + cancellations | sales_orders với dòng hàng và tham chiếu nguồn; cancellation_events lưu từng lần hủy có kiểm soát; unique source và version trên đơn |
| customer_delivery + line / external_payment_confirmation / business_operation | customer_deliveries, external_payment_confirmations và business_operations; tham chiếu SO/GI/ảnh, unique operation keys; không ghi ledger tồn |
| approval + approval_line | approvals, lưu version được duyệt, actor, decision và lượng được phép |
| external_reference + line | external_references, đủ trường nguồn để đối chiếu và khử trùng |
| stock_balance | stock_balances; unique compound index theo account/location + lot + quality + owner |
| stock_movement + posting_batch | stock_movements append-only và posting_batches, liên kết ObjectId, idempotency key unique |
| reservation + demand_supply_allocation | reservations và demand_supply_allocations với trạng thái, lượng và source IDs |
| stocktake + snapshot + count_attempt | stocktakes/stocktake_snapshots và count attempts append-only, lưu cutoff/version |
| customer_return_assessment | return_assessments append-only theo returnLineId, assessmentNo và documentVersion; index truy vấn đánh giá mới nhất; approval reference đúng version |
| evidence, audit_event, outbox_event | evidence_refs, audit_events append-only, outbox_events có event key unique |

Không ánh xạ máy móc 73 bảng thành 73 collection. Embed dòng hữu hạn khi cùng vòng đời và kích thước được kiểm soát; ledger, audit, count attempts và lịch sử điều chỉnh/xác nhận append-only không ghi đè. ObjectId là ID; Decimal128 cho quantity/factor; UTC Date cho sự kiện và hiển thị Asia/Saigon. Các tên collection ở trên là phương án thiết kế [TK], không tuyên bố có backend tương ứng.

### 5.1. Quan hệ và ràng buộc nguồn

- SO.header externalReferenceId là duy nhất; SO line trỏ đúng external line của chính nguồn đó. Bằng chứng phải được xác minh, không chỉ là URL nhập tùy ý.
- WIR.header salesOrderId và WIR.line salesOrderLineId phải thuộc cùng SO. OD line thuộc đúng WIR của OD; GI-S line thuộc đúng OD line.
- POD line trỏ GI-S đã post và ảnh thuộc chính POD; PAY-CFM trỏ SO/current delivered version. Chỉ đọc tổng snapshot không chặn write skew, cần shared source/SO write guard.
- Customer return line dùng GI nguồn XOR external historical line; assessment mới nhất theo dòng/version, inspection, approval và lượng được chấp nhận phải khớp trước GR-CR.
- Account vật lý XOR transit; stock balance unique theo account/lot/quality/owner, quantity không âm. DDL FK không thay kiểm nguồn/loại/product/kho ở service.

### 5.2. Index và validator dự kiến

Unique indexes cho source order/line, document number, balance dimensions, stable posting/business-operation key và payload identity, return assessment number, stocktake snapshot và count attempt. PAY-CFM active theo SO/delivered version tuân thủ hợp đồng nguồn; không lách chống trùng bằng key/correlation mới khi retry.

Collection validation kiểm required fields/type/enums/XOR, quantity và immutable conversion snapshots. Quan hệ xuyên collection, tổng lượng, role/scope, phiên bản duyệt và lịch sử bất biến được cưỡng chế trong command service/transaction. Không cung cấp DML tùy ý cho tài khoản ứng dụng.

## 6. Trạng thái và quyền sửa

| Đối tượng | Trạng thái đề xuất và cách xử lý |
|---|---|
| Đề nghị RR/TR/CR/SR/ADJ | DRAFT → SUBMITTED → APPROVED / REJECTED / REVISION_REQUIRED. Sửa nội dung đã duyệt tăng version và duyệt lại phần thay đổi. |
| Đơn bán WMSD (SO) | DRAFT → OPEN → IN_PROGRESS/PARTIALLY_DELIVERED → DELIVERED → COMPLETED. DELIVERED cần giao đủ có ảnh; COMPLETED cần thêm Sales xác nhận nhận đủ tiền ngoài hệ thống. Hủy toàn bộ trước giao là CANCELLED; hủy phần chưa xuất được lưu riêng. |
| PO / WIR / TR thực hiện | OPEN → PARTIAL → COMPLETED; chỉ hủy phần chưa thực hiện. WIR hoàn tất khi đã xuất đủ hoặc phần chưa xuất được hủy hợp lệ; không đồng nghĩa SO đã giao/hoàn thành. |
| GR / TD / MWTR / GI / SCRAP | DRAFT → POSTED. POSTED bất biến; nhãn REVERSED chỉ khi có batch đảo hợp lệ. Không xóa chứng từ đã post. |
| Xác nhận giao khách (POD) và nhận tiền (PAY-CFM) | DRAFT → CONFIRMED; nếu ghi nhầm thì VOIDED có lý do và lưu lịch sử. Trạng thái giao một phần thuộc SO, không dùng một bộ trạng thái khác cho từng phiếu POD. |
| TO | OPEN → PARTIAL → CONFIRMED; hủy phần chưa thực hiện. Mỗi lần confirm có operation key riêng. |
| Stocktake | PLANNED → FROZEN → COUNTED → RECONCILING → APPROVED → POSTED/CLOSED. Không chênh lệch đi thẳng CLOSED. |
| Defect/discrepancy | OPEN → UNDER_REVIEW → RESOLVING → CLOSED khi mọi lượng có kết quả hoặc chuyển hồ sơ còn mở có trách nhiệm rõ. |
| Tài chính trả hàng | NOT_RECORDED / PENDING_EXTERNAL / RECORDED_EXTERNAL; độc lập trạng thái hoàn tất phần kho. |

Chuyển trạng thái chỉ qua command hợp lệ; không API chung PATCH status để đi tắt. Header được tính từ line/current valid confirmations. Chứng từ POSTED không sửa/xóa trực tiếp; full reversal chỉ khi còn đủ điều kiện và không có downstream phụ thuộc, còn trường hợp khác dùng chứng từ điều chỉnh/hoàn trả có liên kết.

## 7. Kiến trúc ứng dụng và transaction

[TK] Web responsive → API xác thực/scope → command/query services theo module → repositories/validators/indexes MongoDB; outbox worker gửi SMTP và storage adapter xử lý tệp. Tách domain calculation khỏi controller; dùng chung stock-posting protocol cho mọi nghiệp vụ.

### 7.1. Command có tác động tồn

1. Xác thực user, operation/sub-operation, kho/bản ghi; không tin actor từ client.
2. Tra operation/idempotency key và payload hash; cùng key/payload trả kết quả cũ, khác payload báo conflict.
3. Trong transaction, đọc lại document/source/version/approval và cập nhật có điều kiện guard của phạm vi, location/balance và lượng nguồn theo thứ tự thống nhất.
4. Kiểm freeze, quantity/source/quality/owner/độ hạt/evidence. Ghi posting batch, mọi chân movement, balance, reservation, document progress, audit và outbox cùng commit.
5. Rollback toàn bộ khi một dòng lỗi. Không giữ transaction khi kiểm hàng thực tế, upload tệp hoặc gọi SMTP. Unknown commit phải tra operation trước retry, giữ key ổn định.

MongoDB không dùng SELECT FOR UPDATE. Conditional update theo ObjectId/version/đủ lượng và unique dimension; transaction activation/posting cùng chạm scope guard để không đua snapshot/freeze. Hai lần giữ/nhận/trả cạnh tranh phải kiểm lại trần tổng. Retry write conflict với cùng identity, không tự sinh chứng từ thay thế.

### 7.2. Command SO/WIR/POD/PAY-CFM không post tồn

Tạo/sửa SO/WIR, POD và PAY-CFM dùng business_operation; không tạo posting_batch/movement. Guard SO/source/version phải được cập nhật có điều kiện để hai POD không cùng vượt nguồn hoặc dùng điều kiện completion cũ. Commit business operation, confirmation/cancellation, SO progress/version, audit/outbox nguyên tử. Hủy remainder có thể giải phóng reservation trong cùng transaction; POD/PAY-CFM không đổi reservation.

Lưu photo/evidence trước transaction xác nhận; upload không thành công chưa đủ điều kiện confirm. Khi VOIDED, giữ identity/bằng chứng gốc và lý do, tính lại nghĩa vụ/tiến độ, không tái dùng PAY-CFM của delivered version cũ.

### 7.3. Kiểm kê FROZEN và phục hồi

Plan chưa chụp snapshot. Activate kiểm overlap và task dở, khóa scope và capture immutable snapshot trong một transaction. Count/recount append attempts; phát hiện mới nằm trong location đã khóa và có cờ riêng, không sửa snapshot ban đầu. Mọi thay đổi quantity/location/quality/ownership trong scope bị chặn trừ Clear Difference được duyệt; khu ngoài scope vẫn hoạt động.

Reject/trả đếm lại, mất mạng hoặc chưa đủ bằng chứng đều giữ phiên và khóa. Không chênh thì đóng/unlock không ADJ0; có chênh chỉ Owner UC-93 post signed delta một lần rồi mở khóa khi hết unresolved. Phương án vừa đếm vừa giao dịch không thuộc baseline D5.

## 8. Hợp đồng API nội bộ đề xuất [TK]

Prefix /api/v1; ID ObjectId string, quantity/factor dưới dạng decimal string. Command gồm expectedVersion, idempotencyKey và source/line IDs. Response gồm id/status/version/operationId và postingId chỉ khi có post tồn. Lỗi có code/message/fieldErrors/correlationId, không lộ dữ liệu ngoài scope. GET chỉ đọc.

| Module | Command/query chủ đạo | UC và quyền |
|---|---|---|
| Access | POST /sessions; GET/POST/PATCH /accounts; POST /accounts/{id}/role-permissions | UC-94–98; Admin quản trị kỹ thuật |
| Master | GET/POST/PATCH /products, /lots, /suppliers, /customers, /locations; POST /{resource}/{id}/activation | UC-11–22/27–31; tách create/update/activate theo ma trận, không selling-prices |
| RR/PO | /replenishment-requests: create/submit/review; /purchase-orders: create/unreceived-lines/supplier-confirmations/remaining-closure | UC-01–10; Sales/Warehouse RR, Owner review, Accountant PO |
| Receipt/task | /goods-receipts: draft/inspect-and-post; /warehouse-tasks: create/confirm | UC-26/32–37; Warehouse, bin move không Owner |
| Transfer | /transfer-requests: create/review; /transfer-dispatches: post; /transfer-receipts: inspect-and-post; /transfer-discrepancies: propose/review/execute | UC-38–44/104; không warehouse-transfer-order UC-42 |
| SO | GET/POST /sales-orders; PATCH /sales-orders/{id}/unissued-lines; POST /sales-orders/{id}/cancellations | UC-45–48; Sales, source unique và quantity/version guard |
| WIR | GET/POST /issue-requests; PATCH /issue-requests/{id}/unissued-lines; POST /issue-requests/{id}/cancel-remainder | UC-109; Sales, bắt buộc saved SO/line |
| OD/pick/GI | /outbound-deliveries: create; /picking-tasks: create/confirm; /goods-issues: post | UC-49–58; Sales OD, Warehouse task/PGI |
| POD | GET/POST /customer-deliveries; POST /customer-deliveries/{id}/confirm hoặc /void | UC-110; Warehouse đúng kho, stored photo/posted GI; business_operation, không stock batch |
| PAY-CFM | GET/POST /external-payment-confirmations; POST /{id}/confirm hoặc /void | UC-111; Sales sau DELIVERED hiện tại; không endpoint thu tiền |
| Defect | /defect-cases: inspect/propose; /dispositions: review/execute | UC-63–67; cách ly ngay, Owner quyết định |
| Customer return | /customer-returns: create/inspect/assess/review/confirm-receipt/handback | UC-68–73; Sales tạo, Warehouse kiểm, Owner duyệt sau kiểm |
| Supplier return | /supplier-returns: propose/agreement/review-dispatch/dispatch/acknowledgement/variance/closure | UC-79–83/106/107; đúng vai trò và hai mốc agreement/ACK |
| Stocktake | /stocktakes: plan/activate/count-sheet/count-attempts/reconcile; /inventory-adjustments: request/review/clear | UC-84–93/105; Warehouse đề nghị, Owner review/clear |
| Evidence | /evidence: upload-intent/complete/authorized-download | API-02, scope theo parent document; ảnh POD bắt buộc đúng phiếu |
| External references | /external-references: verify/link/record-outcome | UC-108; Accountant, không thay UC-111 |
| Reports/trace | GET /reports, /inventory-balances, /stock-movements, /lots/{id}/trace | UC-99–102; đúng nhóm báo cáo được cấp, không doanh thu/lợi nhuận |

Đây là hợp đồng thiết kế, không phải khẳng định endpoint đang tồn tại. Mỗi subcommand review/confirm/void kiểm permission cụ thể; xem màn hình không tự cấp quyền mutate. Không active route cho invoice, refund workflow hay UC retired.

## 9. Bằng chứng, thông báo và lỗi

API-02 là controlled private storage, chưa chốt nhà cung cấp. Backend kiểm parent scope trước upload/download; lưu asset identifier/object key, hash, MIME, uploader/time, document/line association và upload result. Photo phải là ảnh tải thành công thuộc đúng POD; không chỉ kiểm URL không rỗng. Danh sách MIME/kích thước/lưu trữ cần cấu hình/chốt, không tự đặt số cam kết.

PAY-CFM chấp nhận reference hoặc evidence hoặc nonempty note theo thiết kế; không bắt buộc ảnh cho PAY-CFM như POD. D6 và nhập/điều chuyển/supplier-return lưu bằng chứng đúng nghiệp vụ, không dùng bao bì rách làm kết luận chất lượng tự động.

JOB-01 gửi notification sau commit qua SMTP API-01 từ outbox/event key có retry/result. Không email invoice nội bộ; failure không rollback hoặc lặp post/confirm. SMTP timeout chưa rõ kết quả phải đối soát, không hứa exactly-once thư đến. Ngưỡng bổ sung đánh giá khi query/thay đổi tồn; không tự sinh PO. Owner lập phiên kiểm kê thủ công hằng tháng, không job tự tạo session.

Dùng MSG-01–17 của Report 3: permission/scope, source/quantity/version, freeze, identity, idempotency conflict, missing evidence và invalid completion. Lỗi validation giữ draft hợp lệ; lỗi toàn transaction không lưu một phần dòng; unknown commit lookup trước retry.

## 10. Quy tắc nghiệp vụ chuẩn

BR-01–33 dưới đây cùng nội dung mục 8 của quy trình VI; DR/GB trong Report 3 chỉ là alias lịch sử. Không giữ một bộ rule riêng tiếp tục cấp quyền giá bán/hóa đơn/hoàn tiền đã retired.

| Mã | Quy tắc | Truy vết |
|---|---|---|
| BR-01 | Lot identity phải phân biệt product/lot/tone/calibre; không gộp hàng khác tone để đủ lượng. | DR-01, UC-13/16/26/30/54/55/72 |
| BR-02 | Quy đổi theo sản phẩm và phiên bản đóng gói; chốt hệ số ở dòng chứng từ. Với gạch nguyên viên, không tạo số viên phân số. Dùng diện tích theo quy cách sản phẩm; calibre là thuộc tính tương thích, không tự thay hệ số m². | DR-02, GB-03 |
| BR-03 | Nhu cầu bổ sung từ Sales/Warehouse hoặc cảnh báo; chỉ Owner duyệt; ngưỡng tồn là tham số được kiểm soát, không tự phát hành PO. | UC-03/04/103, BF-01 |
| BR-04 | Không tính trùng nhu cầu đã có PO/điều chuyển/phân bổ; lượng dự kiến về chưa phải khả dụng hiện tại. | BF-01/04/06 |
| BR-05 | Người đề xuất và người duyệt khác userId cho cùng quyết định; nhiều role không vượt ràng buộc này. | GB-01, GB-NEW-01, UC-04/41/66/71/92/106 |
| BR-06 | Receipt/issue/return/adjustment chỉ post một lần, nguyên tử cùng ledger và balance. Không âm tồn khả dụng; retry trả lại kết quả cũ. | DR-09/10/13, GB-09/10/13 |
| BR-07 | Nhận hàng phân tách thực giao, nhận vào tồn, giữ hộ, từ chối; chưa kiểm hoặc chưa sẵn sàng vị trí thì không khả dụng. | DR-04, GB-04, UC-26/33/73 |
| BR-08 | PO nhận nhiều đợt; phần đã ghi nhận bất biến. Chốt thiếu hoặc sửa vượt duyệt có lý do và quyết định phù hợp. | DR-03, GB-05, UC-07/10/26 |
| BR-09 | Chuyển vị trí cùng kho không đổi tổng, lot, chất lượng; không cần Owner duyệt. Bảo toàn liên kết giữ hàng. | DR-06, GB-06, UC-36/37 |
| BR-10 | TR liên kho đã duyệt đủ để thực hiện; phải có hai phiếu và mốc dispatch/receipt riêng. | DR-07, GB-07, UC-41/43/104 |
| BR-11 | Mọi lượng đã xuất điều chuyển = đã nhận hợp lệ + đang chuyển/chưa giải quyết + lượng đã có kết quả xử lý khác có chứng từ. Không đóng nếu thiếu kết quả. Giữ liên kết phân bổ cho nhu cầu nguồn khi chuyển qua in-transit và kho đích. | UC-43/44/104 |
| BR-12 | Người kho nhận xác nhận độc lập người xuất theo phương án nhân sự đã chốt; không một confirm cập nhật cả hai đầu. | UC-43/104, permissions |
| BR-13 | Chọn nguồn theo tương thích lot/tone/calibre trước, FIFO trong tập hợp đó sau. Ghi lý do/chấp thuận khi ngoại lệ; không dùng LIFO làm mặc định nếu chưa khảo sát. | UC-54/55/103 |
| BR-14 | Tạo SO hoặc WIR không đổi tồn; giữ hàng không trừ tổng; picking chỉ đổi vị trí; PGI trừ actual dispatched một lần; cập nhật trạng thái DELIVERED và COMPLETED không làm thay đổi tồn kho. | GB-NEW-03, UC-47/109/51/55/58/110/111 |
| BR-15 | Thiếu/hỏng khi soạn phải chặn lượng ảnh hưởng, ghi bằng chứng, phân bổ lại hoặc chờ; không tự chỉnh balance. | BF-02/05/06 |
| BR-16 | Đề nghị khách trả gắn nguồn xuất có thể xác minh; tổng nhận trả không vượt lượng đã xuất chưa trả, có kiểm soát hồ sơ đang mở. | DR-11, GB-11, UC-70/73/108 |
| BR-17 | Sales kiểm điều kiện/chứng từ; Warehouse kiểm vật lý; Owner quyết định nhận trả. Đạt kỹ thuật không tự đồng nghĩa được nhận trả và ngược lại. | UC-70/71/72 |
| BR-18 | Nhận trả phân theo từng lượng: bán được, cách ly của cửa hàng, giữ hộ/từ chối. Không sửa hóa đơn hoặc phiếu xuất gốc. | UC-73/108 |
| BR-19 | Cách ly ngay khi có dấu hiệu lỗi; chỉ quyết định hợp lệ mới cho tái phân loại/hủy/trả. Không trừ tồn hai lần khi BF-02 chuyển BF-08. | UC-65/66/67/82 |
| BR-20 | Xuất trả NCC cần chấp thuận nội bộ và thỏa thuận NCC; giữ hộ bị trả không làm giảm tồn sở hữu. NCC chưa nhận đủ thì hồ sơ vẫn mở. | DR-12, GB-12, UC-82/106/107 |
| BR-21 | Snapshot bất biến tại kích hoạt; xuất danh sách kiểm kê; lưu thời gian và phạm vi. Không lấy tồn hiện tại để thay số snapshot. | DR-08, GB-08, UC-87/105 |
| BR-22 | MVP khóa thay đổi trong phạm vi đang đếm; đếm lại có lịch sử; chưa đếm không bằng 0; sai khác chất lượng và số lượng được xử lý riêng. | GB-NEW-07, UC-87/88 |
| BR-23 | Warehouse lập delta; Owner duyệt đúng phiên bản rồi Owner Clear Difference. Không đủ căn cứ → trả về; không chênh → đóng/mở khóa không post điều chỉnh 0. | DR-09, GB-09, GB-NEW-06, UC-91/92/93 |
| BR-24 | Chứng từ đã post không sửa/xóa để xóa dấu vết. Sai sót cần đảo/điều chỉnh liên kết có thẩm quyền. Master inactive giữ nguyên lịch sử. | DR-14, GB-02/13, UC-97/100–102 |
| BR-25 | Thông báo và upload không tạo lại giao dịch tồn; gửi mail thất bại không rollback PGI/receipt đã commit. | API-01, JOB-01, UC-58/26/110 |
| BR-26 | Không suy ra tình trạng đã giao khách (DELIVERED) chỉ từ PGI/bàn giao cho nhà vận chuyển, và không suy ra hoàn thành đơn bán (COMPLETED) chỉ từ đã giao hàng; không suy ra hoàn tiền từ phiếu nhập trả; không suy ra tăng tồn từ NCC đồng ý đổi hàng. | BF-06/07/08, UC-58/110/111 |
| BR-27 | Chỉ các vai trò được phép xem chứng cứ mới lấy được tệp; URL không mặc định công khai. | API-02 lưu chứng cứ, GB-NEW-02 |
| BR-28 | Có source system, source document/line, version và correlation ID để chống nhập/ghi nhận trùng giữa WMS và hồ sơ MISA trên SO, WIR, OD, GI-S, `CR` và `EXT-REF`. | UC-47/109/51/58/70/108 |
| BR-29 | Khách trả: nguyên thùng/viên lẻ chưa dùng xét từng trường hợp; không nhận đã thi công, hỏng do khách, quá thời hạn áp dụng. Chưa xác minh điều kiện/thời hạn thì chờ; không tự đặt số ngày. Đánh giá theo từng lượng, lưu phiên bản/bằng chứng; chỉ post phần đủ điều kiện được duyệt sau kiểm tra. | D6, BF-07, UC-70–73 |
| BR-30 | Bao bì rách/thùng mở không tự đồng nghĩa gạch hỏng. Ghi số viên thực tế; phân loại chất lượng sau kiểm tra. Hệ số thùng/viên/m² theo sản phẩm và phiên bản, không suy từ calibre. | D7, BF-01/05/06/07, UC-13/26/55/72/87 |
| BR-31 | SO phải có nguồn đã xác minh; WIR liên kết đúng SO và dòng hàng. Tổng cam kết WIR, kể cả phần đã xuất, không vượt lượng đặt trừ phần hủy hợp lệ. Tổng OD nằm trong lượng WIR, không cộng thêm thành nhu cầu mới. | BF-06, UC-45–48/109/51 |
| BR-32 | Warehouse xác nhận POD theo dòng GI-S đã post, có người nhận, thời điểm, lượng và ảnh hợp lệ. Tổng giao không vượt PGI hợp lệ; gửi lại không ghi trùng. Chỉ DELIVERED khi giao đủ phần còn phải thực hiện và lượng này lớn hơn 0; hủy toàn bộ chưa giao thì CANCELLED. | BF-06, UC-58/110 |
| BR-33 | Chỉ Sales xác nhận nhận đủ tiền ngoài hệ thống sau DELIVERED để chuyển SO sang COMPLETED. Chưa đủ tiền hoặc trả trước khi chưa giao đủ không làm hoàn thành đơn. POD/PAY-CFM không đổi tồn; đính chính phải giữ lịch sử và tính lại tiến độ đơn. | BF-06, UC-48/110/111/108 |

## 11. Ràng buộc dữ liệu và transaction

R-01–21 cùng thiết kế database; CHECK/FK/UNIQUE trong DDL chỉ diễn đạt phần cục bộ. Các dòng “service/transaction” là việc phải cài và kiểm trên MongoDB, chưa được chứng minh bằng việc parse DDL.

| ID | Ràng buộc | Cách cưỡng chế khi triển khai |
|---|---|---|
| R-01 | Không tồn âm, không giữ vượt lượng | Lock balance; tính ACTIVE reservation trong transaction; CHECK qty≥0 là lớp cuối |
| R-02 | Đúng kho/vị trí/lô/sản phẩm/chủ hàng | FK + kiểm subtype, location của task, product của lot và nguồn; cấm đổi dimension balance đã có lịch sử |
| R-03 | Không nhận/xuất/trả vượt nguồn | Lock dòng nguồn; cộng toàn bộ batch đã post, reservation/đề nghị mở và hủy/đảo hợp lệ |
| R-04 | MWTR đúng TD, cùng TR và đích | Kiểm receipt.dispatch, receipt_line.dispatch_line và quyền warehouse; tổng q không vượt transit còn lại |
| R-05 | Đúng version và lượng duyệt | Kiểm approval.document/version, từng line/outcome; thay đổi nội dung làm mất hiệu lực duyệt cũ |
| R-06 | Cấm tự duyệt và tách người nhận liên kho | So user thực tế với creator/requester; receiver≠dispatcher. Không tin requested_by do client gửi |
| R-07 | Không post trùng | Hai UNIQUE ở posting_batch + kiểm hash payload; operation_key là mã lần thực hiện nghiệp vụ, không key ngẫu nhiên mỗi lần bấm |
| R-08 | Không sửa/xóa lịch sử đã post | Hạn chế DML, service/stored procedure duy nhất, trigger chặn sửa/xóa ledger/snapshot/approval/posted source; audit quyền admin |
| R-09 | Không chen giao dịch vào kiểm kê | Mọi posting lock cùng các location rows rồi kiểm location_lock; activation cũng dùng protocol đó trước snapshot |
| R-10 | Không cộng custody vào STORE | Kiểm owner_party của balance; acceptance có chứng từ chuyển chủ, không chỉ sửa master party |
| R-11 | Giữ đúng đơn vị/làm tròn | Snapshot conversion; với whole_base_units, kiểm qty nguyên; dữ liệu m² yêu cầu nhập viên/thùng thực khi quy đổi không nguyên |
| R-12 | Cân đối ledger/balance, đúng batch | batch.document_id = movement.document_id; delta balance khớp movement và before/after; không UPDATE balance riêng |
| R-13 | D6 đúng dòng/lượng/version | CHECK điều kiện cục bộ + service kiểm assessment mới nhất, inspection, nguồn và approval_line; không post PENDING/INELIGIBLE |
| R-14 | Bao bì và đơn vị thực | Lưu packaging_condition và actual quantity; bao bì rách không tự đổi quality; version hệ số không sửa lịch sử |
| R-15 | Đúng phạm vi UC và vai trò | Đúng 5 role; 13 UC retired không permission active; UC-107/108 không post tồn; D2 mỗi bộ phận tự ghi |
| R-16 | SO và nguồn WIR | Nguồn SO/dòng duy nhất; FK ghép đúng chứng từ cha; Sales xác minh nguồn và lưu bằng chứng; dùng lại SO khi sửa/mở lại |
| R-17 | Trần SO→WIR→OD→GI | Kiểm tổng từng tầng, tính cả phần đã xuất; hủy có lịch sử và giải phóng phần giữ phù hợp; không cộng lượng cha/con |
| R-18 | POD có ảnh và không giao vượt PGI | Warehouse đúng kho; GI đã post hợp lệ; ảnh cùng phiếu, tải thành công; kiểm đồng thời tổng POD trên dòng GI |
| R-19 | DELIVERED/COMPLETED đúng điều kiện | Giao đủ lượng còn phải thực hiện >0 mới DELIVERED; Sales xác nhận đủ tiền ngoài trên phiên bản hiện tại mới COMPLETED; hủy toàn bộ chưa giao là CANCELLED |
| R-20 | Xác nhận không ghi tồn và không trùng | business_operation có key/hash; cùng transaction với xác nhận, tiến độ SO, audit/outbox; không tạo movement cho POD/PAY-CFM |
| R-21 | Đính chính có lưu lịch sử | VOIDED có lý do; tính lại SO và vô hiệu điều kiện hoàn thành cũ. BF-07 thông thường giữ lịch sử giao/nhận tiền gốc |

## 12. Màn hình và dữ liệu tương tác

Danh mục đồng bộ Report 3: 31 mã, 28 active; SC-25–27 retired không trong navigation. Giữ ID màn hình cũ; UC-45–48 quản lý SO ở SC-16; WIR/POD/PAY-CFM ở SC-29/30/31. Form/validation/normal/alternate outcomes chi tiết ở phần III Report 3.

| Screen | Name | State | Linked UC |
|---|---|---|---|
| SC-01 | Sign In | ACTIVE | UC-94 |
| SC-02 | Accounts and Permissions | ACTIVE | UC-95, UC-96, UC-97, UC-98 |
| SC-03 | Products and Packaging | ACTIVE | UC-11, UC-12, UC-13 |
| SC-04 | Product Lots | ACTIVE | UC-14, UC-15, UC-16 |
| SC-05 | Suppliers | ACTIVE | UC-17, UC-18, UC-19 |
| SC-06 | Replenishment Requests | ACTIVE | UC-01, UC-02, UC-03, UC-04 |
| SC-07 | Purchase Orders | ACTIVE | UC-05, UC-06, UC-07 |
| SC-08 | Goods Receipt, Inspection and Put-away | ACTIVE | UC-08, UC-09, UC-10, UC-26, UC-32, UC-33 |
| SC-09 | Warehouse Locations | ACTIVE | UC-27, UC-28, UC-29 |
| SC-10 | Inventory and Shortage Options | ACTIVE | UC-30, UC-31, UC-103 |
| SC-11 | Defective Goods and Disposition | ACTIVE | UC-63, UC-64, UC-65, UC-66, UC-67 |
| SC-12 | Location Movements | ACTIVE | UC-34, UC-35, UC-36, UC-37 |
| SC-13 | Warehouse Transfers, Dispatch and Receipt | ACTIVE | UC-38, UC-39, UC-40, UC-41, UC-43, UC-44, UC-104 |
| SC-14 | Stocktake Sessions, Count Sheet and Counts | ACTIVE | UC-84, UC-85, UC-86, UC-87, UC-88, UC-105 |
| SC-15 | Adjustment Review and Clear Difference | ACTIVE | UC-89, UC-90, UC-91, UC-92, UC-93 |
| SC-16 | Copied Sales Orders and Progress | ACTIVE | UC-45, UC-46, UC-47, UC-48, UC-103 |
| SC-17 | Goods Issue and Actual Handover | ACTIVE | UC-56, UC-57, UC-58 |
| SC-18 | Customer Return, D6 Assessment and Custody | ACTIVE | UC-68, UC-69, UC-70, UC-71, UC-72, UC-73 |
| SC-19 | Supplier Return, Agreement and Acknowledgement | ACTIVE | UC-79, UC-80, UC-81, UC-82, UC-83, UC-106, UC-107 |
| SC-20 | Operational Reports | ACTIVE | UC-99 |
| SC-21 | Stock Movement and Lot Trace | ACTIVE | UC-100, UC-101, UC-102 |
| SC-22 | Outbound Deliveries | ACTIVE | UC-49, UC-50, UC-51 |
| SC-23 | Picking Tasks | ACTIVE | UC-52, UC-53, UC-54, UC-55 |
| SC-24 | Customer Delivery References | ACTIVE | UC-20, UC-21, UC-22 |
| SC-25 | Selling Prices [RETIRED] | RETIRED | Historical only |
| SC-26 | Internal Invoices [RETIRED] | RETIRED | Historical only |
| SC-27 | Refund Requests [RETIRED] | RETIRED | Historical only |
| SC-28 | External Document References | ACTIVE | UC-108 |
| SC-29 | Linked Warehouse Issue Requests | ACTIVE | UC-109 |
| SC-30 | Customer Delivery and Photo Evidence | ACTIVE | UC-110 |
| SC-31 | External Payment Receipt Confirmation | ACTIVE | UC-111 |

SC-16 yêu cầu source unique/evidence, line quantities và cancellation history; SC-29 cần SO/line bắt buộc và tổng commitment; SC-30 cần GI-S/recipient/time/quantity/stored photo; SC-31 cần delivered version/full external receipt/reference-or-evidence-or-note. Progress/stock/approval user/time là read-only. Form tách Save, review, actual posting, confirm và print. Thiết kế responsive cho điện thoại, giữ draft khi upload lỗi; không giả định native/offline/scan tự động.

## 13. Bảo mật và vận hành

Credentials/hash, session/activation, role/sub-operation và warehouse/record/evidence scope được cưỡng chế ở backend; mọi export/direct URL dùng cùng quyền. Admin technical changes có audit; không cho sửa quá khứ để hợp thức hóa approval/post. Posted documents, movement, snapshot, attempts và confirmation history append-only qua command duy nhất.

Storage và SMTP giữ secret phía server. Backup/restore, retention, SLA, tải đại diện, RPO/RTO và giới hạn file phải chốt trước vận hành; không tự coi có chỉ tiêu đã ký. Quan sát lỗi theo correlation/document/operation/version, cảnh báo unresolved transit/return/freeze/outbox và đối soát ledger/balance.

## 14. Nghiệm thu thiết kế và kiểm thử triển khai

40 tình huống dưới đây giữ cùng ID/kết quả với thiết kế database. Chúng là acceptance criteria, không phải 40 backend test đã chạy. Khi triển khai phải xác minh luồng UI → API → service/transaction → MongoDB/evidence/outbox và kiểm cạnh tranh, wrong role/scope, rollback và retry.

| ID | Tình huống | Kết quả bắt buộc |
|---|---|---|
| T01 | PO nhận 78/100, trong đó 3 hỏng; 2 từ chối | ARR=80; owned=78; usable tối đa75 sau put-away; PO còn22 |
| T02 | Retry GR cùng key hoặc key mới cùng operation_key | Chỉ một batch; payload khác cùng key báo conflict |
| T03 | Hai người đồng thời giữ 60 và 50 trên balance100 | Không vượt100; transaction thứ hai phải kiểm lại |
| T04 | TO chuyển bin hoặc picking | Tổng sở hữu không đổi; reservation theo vị trí mới |
| T05 | TD100, MWTR95GOOD+3DAMAGED | Transit2; B98; chỉ95 đủ điều kiện sau put-away |
| T06 | MWTR thêm3 khi transit còn2 | Từ chối; sai lệch thừa ghi riêng, không âm transit |
| T07 | Người xuất tự xác nhận nhận liên kho | Từ chối dù có role WAREHOUSE ở cả hai kho |
| T08 | Khách trả10: nhận7 đạt+2 lỗi, từ chối1 | Owned+9, custody1 đến khi trả; không usable+10 |
| T09 | Trả NCC hàng giữ hộ chưa nhập sở hữu | Custody giảm; owned không đổi |
| T10 | Hai SR/disposition cùng xử lý một lượng lỗi | Tổng thực xuất/hủy không vượt lượng còn đủ điều kiện |
| T11 | Snapshot20, đếm18, Owner duyệt −2 | Post−2 một lần; không overwrite balance bằng18 ở thời điểm khác |
| T12 | Chưa đếm và đếm0 | Hai trạng thái khác nhau; không tự tạo thiếu toàn bộ từ ô trống |
| T13 | Posting đua với stocktake activation | Giao dịch được tuần tự hóa; snapshot không bỏ sót movement đã commit trước khóa |
| T14 | Đổi quy cách 4 lên5 viên/thùng | Phiếu cũ giữ4; phiếu mới dùng version mới |
| T15 | Email lỗi sau PGI | GI và tồn giữ nguyên; outbox retry, không PGI lần nữa |
| T16 | Sửa lot/tone hoặc chứng từ đã post | Bị chặn; cần chứng từ đính chính phù hợp và audit |
| T17 | Không lệch kiểm kê | Đóng và mở khóa; không tạo ADJ0 |
| T18 | Lịch sử chưa có GI trong WMS | CR tham chiếu nguồn ngoài được xác minh; không GI giả |
| T19 | Khách trả đã thi công/hỏng do khách/quá hạn đã rõ | INELIGIBLE; không GR-CR, custody đến giao trả nếu đã giữ |
| T20 | Thời hạn/điều kiện chưa xác minh | PENDING; không tự đặt 7/15/30 ngày; cần bằng chứng |
| T21 | Nguyên thùng hoặc viên lẻ chưa dùng đủ căn cứ | CASE_REVIEW; chỉ Owner quyết định sau inspection, không tự nhận |
| T22 | Đổi assessment/lượng sau Owner duyệt | Version mới và duyệt lại; post với approval cũ bị chặn |
| T23 | NCC chưa ACK hoặc ACK lệch GI | Mở BF-08; Owner UC-106 giải quyết; không trừ thêm khi đóng |
| T24 | Thùng rách, gạch nguyên và số viên thực được kiểm | Chất lượng theo kiểm, không tự DAMAGED; quantity theo viên/version |
| T25 | Lỗi mạng giữa posting và trả response | Tra batch/operation key; không post lặp, không mất audit |
| T26 | Kiểm kê theo tháng | Owner tạo phiên thủ công; D5 khóa phạm vi; không job tạo phiên |
| T27 | Nhập lại cùng đơn bán hoặc dòng nguồn lần hai | Chặn trùng SO/nguồn; phải có xác minh và bằng chứng; không tạo giao dịch tồn. |
| T28 | Thông tin chung WIR gắn SO A nhưng dòng gắn SO B; dòng OD gắn WIR khác | FK ghép chặn sai chứng từ cha; service còn kiểm sản phẩm và đơn vị. |
| T29 | Nhiều WIR/OD cùng dùng một dòng SO, có phần đã xuất | Kiểm trần riêng SO→WIR và WIR→OD; WIR đã hoàn tất không làm phát sinh lại nhu cầu. |
| T30 | Hủy phần chưa xuất nhưng đã giữ hàng hoặc gắn task | Xử lý task, giảm cam kết, giải phóng đúng lượng giữ; lưu lý do/người/thời điểm hủy. |
| T31 | POD dùng GI chưa post, đã đảo, sai đơn hoặc sai kho | Từ chối; giao khách phải dựa trên dòng phiếu xuất bán đã post còn hợp lệ. |
| T32 | POD thiếu ảnh, ảnh thuộc phiếu khác, tệp không phải ảnh hoặc tải lỗi | FK chặn thiếu/sai chứng từ ảnh; service chặn tệp không phải ảnh/chưa tải xong; không DELIVERED. |
| T33 | PGI 10; hai POD khác nhau đồng thời xác nhận 6 và 5 | Tổng xác nhận tối đa 10; kiểm đồng thời dòng nguồn chặn vượt. Hai lần 6+4 hợp lệ mới giao đủ. |
| T34 | Gửi lại POD/PAY-CFM cùng mã, sau đó đổi nội dung với mã cũ | Trả kết quả đã lưu; đổi nội dung bị từ chối; không tăng lượng giao hoặc ghi tồn lần hai. |
| T35 | Đã PGI/bàn giao vận chuyển nhưng khách chưa nhận | SO còn IN_PROGRESS; khách nhận một phần có ảnh thì PARTIALLY_DELIVERED. |
| T36 | Chưa nhận tiền, mới nhận một phần hoặc khách trả trước khi giao đủ | Không hoàn thành SO; đã giao mà chưa nhận đủ tiền thì giữ DELIVERED. |
| T37 | Warehouse/Accountant xác nhận PAY-CFM; Sales xác nhận đủ tiền trên SO DELIVERED hiện tại | Chặn sai vai trò; Sales có tham chiếu/bằng chứng/ghi chú được xác nhận và chuyển COMPLETED cùng transaction, không đổi tồn. |
| T38 | Hủy toàn bộ số đặt và khách chưa nhận hàng | SO=CANCELLED, không DELIVERED/COMPLETED. Giao một phần kết hợp hủy hợp lệ phần chưa xuất có thể đạt DELIVERED. |
| T39 | Hủy hiệu lực POD/PAY-CFM ghi nhầm hoặc dùng phiên bản đã giao cũ | Giữ bằng chứng gốc, lý do/audit; tính lại SO; điều kiện hoàn thành cũ không cho phép xác nhận mới. |
| T40 | Transaction xác nhận lỗi hoặc khách trả hàng thông thường sau đó | Không lưu một phần thao tác/trạng thái khi transaction thất bại; BF-07 giữ lịch sử giao/nhận tiền và dùng chứng từ tồn riêng. |

Kiểm bổ sung toàn bộ 37 A/E cùng EX-01–05 từ process/SRS; mỗi nhánh có command, nguồn/approval, quantity, expected state và stock effect. T27–T40 bao phủ chuỗi SO/WIR/POD/PAY mới, gồm 6+5 cạnh tranh trên PGI10, photo sai phiếu, early receipt, full cancellation và VOIDED correction.

## 15. Quyết định triển khai còn cần xác nhận

Danh sách/địa chỉ kho và headcount; cách bố trí người nhận liên kho độc lập; calibre/tone và hệ số thực của SKU; quyền sở hữu khi nhận lỗi/custody; thời hạn trả hàng và evidence deadline; thời lượng freeze/Owner availability; quy tắc thay lô; tiêu chí xác minh nguồn lịch sử; mẫu in/mã chứng từ; provider storage, file limits, email trigger/recipient, bảo mật/backup và số đo SLA.

Các điểm này giữ nhãn To-be/chưa xác minh, không biến thành số liệu thực địa. Phương án kiểm kê đã chọn là FROZEN và scope ứng dụng vẫn đúng 5 vai trò; không coi hai nội dung đó là quyết định còn mở.

## 16. Truy vết và kiểm soát phát hành

Phụ lục A được dựng từ catalogue, permission matrix, UC specifications và screen inventory của Report 3 cùng baseline. Thay UC/BR/BF/SC phải cập nhật các bản EN/VI, thiết kế dữ liệu, sơ đồ và nghiệm thu tương ứng; không đánh lại mã retired để cấp tính năng mới.

Lần đồng bộ 22/10 không sửa Report 2, không sửa dữ liệu khảo sát/biên bản/PDF nguồn, không thực thi SQL Server/MongoDB/backend. Bằng chứng kiểm tra tài liệu được ghi tại [change log](../../change_logs.md) và [kết quả hậu kiểm](../07_ra_soat/Ket_qua_dong_bo_tai_lieu_2026-10-22.md).

## Phụ lục A. Truy vết 111 use case

| UC | Tên | FE | Trạng thái | Màn hình | Vai trò được cấp |
|---|---|---|---|---|---|
| UC-01 | View replenishment request list | FE-01 | ACTIVE | SC-06. | Owner, Accountant, Warehouse, Sales |
| UC-02 | View replenishment request details | FE-01 | ACTIVE | SC-06. | Owner, Accountant, Warehouse, Sales |
| UC-03 | Create replenishment request | FE-01 | ACTIVE | SC-06. | Warehouse, Sales |
| UC-04 | Approve or reject replenishment request | FE-01 | ACTIVE | SC-06. | Owner |
| UC-05 | View purchase order list | FE-01 | ACTIVE | SC-07. | Owner, Accountant, Warehouse |
| UC-06 | View purchase order details | FE-01 | ACTIVE | SC-07. | Owner, Accountant, Warehouse |
| UC-07 | Manage Purchase Order and Supplier Confirmation | FE-01 | ACTIVE | SC-07. | Accountant |
| UC-08 | View goods receipt list | FE-01 | ACTIVE | SC-08. | Owner, Accountant, Warehouse |
| UC-09 | View goods receipt details | FE-01 | ACTIVE | SC-08. | Owner, Accountant, Warehouse |
| UC-10 | Create goods receipt from purchase order | FE-01 | ACTIVE | SC-08. | Warehouse |
| UC-11 | View product list | FE-02 | ACTIVE | SC-03. | Owner, Accountant, Warehouse, Sales |
| UC-12 | View product details | FE-02 | ACTIVE | SC-03. | Owner, Accountant, Warehouse, Sales |
| UC-13 | Maintain Product and Packaging | FE-02 | ACTIVE | SC-03. | Owner |
| UC-14 | View lot list | FE-02 | ACTIVE | SC-04. | Owner, Warehouse |
| UC-15 | View lot details | FE-02 | ACTIVE | SC-04. | Owner, Warehouse |
| UC-16 | Maintain Product Lot | FE-02 | ACTIVE | SC-04. | Owner, Warehouse |
| UC-17 | View supplier list | FE-02 | ACTIVE | SC-05. | Owner, Accountant |
| UC-18 | View supplier details | FE-02 | ACTIVE | SC-05. | Owner, Accountant |
| UC-19 | Maintain Supplier | FE-02 | ACTIVE | SC-05. | Owner, Accountant |
| UC-20 | View Customer List | FE-02 | ACTIVE | SC-24. | Owner, Accountant, Warehouse, Sales |
| UC-21 | View Customer Details | FE-02 | ACTIVE | SC-24. | Owner, Accountant, Warehouse, Sales |
| UC-22 | Maintain Customer | FE-02 | ACTIVE | SC-24. | Sales |
| UC-23 | View Selling Price List | FE-02 | RETIRED | — | — |
| UC-24 | View Selling Price Details | FE-02 | RETIRED | — | — |
| UC-25 | Maintain Selling Price | FE-02 | RETIRED | — | — |
| UC-26 | Inspect and Post Goods Receipt | FE-03 | ACTIVE | SC-08. | Warehouse |
| UC-27 | View warehouse and location list | FE-04 | ACTIVE | SC-09. | Owner, Warehouse |
| UC-28 | View storage location details | FE-04 | ACTIVE | SC-09. | Owner, Warehouse |
| UC-29 | Maintain Storage Location | FE-04 | ACTIVE | SC-09. | Owner |
| UC-30 | View stock by lot, location, and quality status | FE-04 | ACTIVE | SC-10. | Owner, Accountant, Warehouse, Sales |
| UC-31 | View inventory balance details | FE-04 | ACTIVE | SC-10. | Owner, Accountant, Warehouse, Sales |
| UC-32 | Create Put-away Task | FE-04 | ACTIVE | SC-08. | Warehouse |
| UC-33 | Confirm Put-away Task | FE-04 | ACTIVE | SC-08. | Warehouse |
| UC-34 | View location movement list | FE-04 | ACTIVE | SC-12. | Owner, Warehouse |
| UC-35 | View location movement details | FE-04 | ACTIVE | SC-12. | Owner, Warehouse |
| UC-36 | Create location movement | FE-04 | ACTIVE | SC-12. | Warehouse |
| UC-37 | Confirm actual location movement | FE-04 | ACTIVE | SC-12. | Warehouse |
| UC-38 | View warehouse transfer list | FE-05 | ACTIVE | SC-13. | Owner, Accountant, Warehouse, Sales |
| UC-39 | View warehouse transfer details | FE-05 | ACTIVE | SC-13. | Owner, Accountant, Warehouse, Sales |
| UC-40 | Create Transfer Request | FE-05 | ACTIVE | SC-13. | Warehouse |
| UC-41 | Review Transfer Request | FE-05 | ACTIVE | SC-13. | Owner |
| UC-42 | Create Warehouse Transfer Order | FE-05 | RETIRED | — | — |
| UC-43 | Record Transfer Dispatch | FE-05 | ACTIVE | SC-13. | Warehouse |
| UC-44 | Review Transfer Difference Resolution | FE-05 | ACTIVE | SC-13. | Owner |
| UC-45 | View Copied Sales Order List | FE-06 | ACTIVE | SC-16. | Owner, Accountant, Warehouse, Sales |
| UC-46 | View Copied Sales Order Details | FE-06 | ACTIVE | SC-16. | Owner, Accountant, Warehouse, Sales |
| UC-47 | Create Copied Sales Order | FE-06 | ACTIVE | SC-16. | Sales |
| UC-48 | Update or Cancel Unissued Sales Order Remainder | FE-06 | ACTIVE | SC-16. | Sales |
| UC-49 | View Outbound Delivery List | FE-06 | ACTIVE | SC-22. | Owner, Accountant, Warehouse, Sales |
| UC-50 | View Outbound Delivery Details | FE-06 | ACTIVE | SC-22. | Owner, Accountant, Warehouse, Sales |
| UC-51 | Create Outbound Delivery | FE-06 | ACTIVE | SC-22. | Sales |
| UC-52 | View Picking Task List | FE-06 | ACTIVE | SC-23. | Owner, Accountant, Warehouse, Sales |
| UC-53 | View Picking Task Details | FE-06 | ACTIVE | SC-23. | Owner, Accountant, Warehouse, Sales |
| UC-54 | Create Picking Task | FE-06 | ACTIVE | SC-23. | Warehouse |
| UC-55 | Confirm Picking Task | FE-06 | ACTIVE | SC-23. | Warehouse |
| UC-56 | View goods issue list | FE-06 | ACTIVE | SC-17. | Owner, Accountant, Warehouse, Sales |
| UC-57 | View goods issue details | FE-06 | ACTIVE | SC-17. | Owner, Accountant, Warehouse, Sales |
| UC-58 | Post Goods Issue | FE-06 | ACTIVE | SC-17. | Warehouse |
| UC-59 | View Internal Invoice List | FE-06 | RETIRED | — | — |
| UC-60 | View Internal Invoice Details | FE-06 | RETIRED | — | — |
| UC-61 | Create Internal Invoice | FE-06 | RETIRED | — | — |
| UC-62 | Issue Internal Invoice and Produce PDF | FE-06 | RETIRED | — | — |
| UC-63 | View defective goods list | FE-07 | ACTIVE | SC-11. | Owner, Warehouse |
| UC-64 | View defective goods details | FE-07 | ACTIVE | SC-11. | Owner, Warehouse |
| UC-65 | Inspect Defective Goods and Submit Disposition | FE-07 | ACTIVE | SC-11. | Warehouse |
| UC-66 | Approve or reject defective goods disposition | FE-07 | ACTIVE | SC-11. | Owner |
| UC-67 | Record approved defective goods disposition | FE-07 | ACTIVE | SC-11. | Warehouse |
| UC-68 | View customer return list | FE-07 | ACTIVE | SC-18. | Owner, Accountant, Warehouse, Sales |
| UC-69 | View customer return details | FE-07 | ACTIVE | SC-18. | Owner, Accountant, Warehouse, Sales |
| UC-70 | Create Customer Return Request | FE-07 | ACTIVE | SC-18. | Sales |
| UC-71 | Review Customer Return Request | FE-07 | ACTIVE | SC-18. | Owner |
| UC-72 | Inspect Customer Return | FE-07 | ACTIVE | SC-18. | Warehouse |
| UC-73 | Confirm Customer Return Receipt | FE-07 | ACTIVE | SC-18. | Warehouse |
| UC-74 | View Refund Request List | FE-07 | RETIRED | — | — |
| UC-75 | View Refund Request Details | FE-07 | RETIRED | — | — |
| UC-76 | Create Customer Return Refund Request | FE-07 | RETIRED | — | — |
| UC-77 | Review Customer Return Refund Request | FE-07 | RETIRED | — | — |
| UC-78 | Record Refund Completion | FE-07 | RETIRED | — | — |
| UC-79 | View supplier return request list | FE-07 | ACTIVE | SC-19. | Owner, Accountant, Warehouse |
| UC-80 | View supplier return request details | FE-07 | ACTIVE | SC-19. | Owner, Accountant, Warehouse |
| UC-81 | Create Supplier Return Request | FE-07 | ACTIVE | SC-19. | Warehouse |
| UC-82 | Confirm Supplier Return Dispatch | FE-07 | ACTIVE | SC-19. | Warehouse |
| UC-83 | Review Supplier Return Closure | FE-07 | ACTIVE | SC-19. | Owner |
| UC-84 | View stocktake list | FE-08 | ACTIVE | SC-14. | Owner, Warehouse |
| UC-85 | View stocktake details | FE-08 | ACTIVE | SC-14. | Owner, Warehouse |
| UC-86 | Create Stocktake Session | FE-08 | ACTIVE | SC-14. | Owner |
| UC-87 | Perform Stocktake Count and Record Results | FE-08 | ACTIVE | SC-14. | Warehouse |
| UC-88 | Reconcile Stocktake | FE-08 | ACTIVE | SC-14. | Warehouse |
| UC-89 | View inventory adjustment request list | FE-08 | ACTIVE | SC-15. | Owner, Warehouse |
| UC-90 | View inventory adjustment request details | FE-08 | ACTIVE | SC-15. | Owner, Warehouse |
| UC-91 | Create Inventory Adjustment Request | FE-08 | ACTIVE | SC-15. | Warehouse |
| UC-92 | Review Inventory Adjustment | FE-08 | ACTIVE | SC-15. | Owner |
| UC-93 | Clear Stocktake Difference | FE-08 | ACTIVE | SC-15. | Owner |
| UC-94 | Sign in to the system | FE-09 | ACTIVE | SC-01. | Owner, Accountant, Warehouse, Sales, Admin |
| UC-95 | View account list | FE-09 | ACTIVE | SC-02. | Admin |
| UC-96 | View account details | FE-09 | ACTIVE | SC-02. | Admin |
| UC-97 | Maintain Staff Account | FE-09 | ACTIVE | SC-02. | Admin |
| UC-98 | Assign roles and operation permissions | FE-09 | ACTIVE | SC-02. | Admin |
| UC-99 | View Operational Reports | FE-09 | ACTIVE | SC-20. | Owner, Accountant, Warehouse |
| UC-100 | View stock movement log | FE-09 | ACTIVE | SC-21. | Owner, Accountant, Warehouse |
| UC-101 | View stock movement details | FE-09 | ACTIVE | SC-21. | Owner, Accountant, Warehouse |
| UC-102 | Trace a product lot through source documents | FE-09 | ACTIVE | SC-21. | Owner, Accountant, Warehouse |
| UC-103 | View and Select Shortage Fulfilment Options | FE-06 | ACTIVE | SC-10, SC-16. | Owner, Warehouse, Sales |
| UC-104 | Inspect and Post Transfer Receipt | FE-05 | ACTIVE | SC-13. | Warehouse |
| UC-105 | Export or Print Stocktake Count Sheet | FE-08 | ACTIVE | SC-14. | Owner, Warehouse |
| UC-106 | Approve Supplier Return and Variance Resolution | FE-07 | ACTIVE | SC-19. | Owner |
| UC-107 | Record Supplier Agreement and Receipt Acknowledgement | FE-07 | ACTIVE | SC-19. | Accountant |
| UC-108 | Record External Document References | FE-09 | ACTIVE | SC-28. | Accountant |
| UC-109 | Manage Linked Warehouse Issue Request | FE-06 | ACTIVE | SC-29. | Owner, Accountant, Warehouse, Sales |
| UC-110 | Confirm Customer Delivery with Photo Evidence | FE-06 | ACTIVE | SC-30. | Owner, Accountant, Warehouse, Sales |
| UC-111 | Confirm Full External Payment Receipt | FE-06 | ACTIVE | SC-31. | Owner, Accountant, Warehouse, Sales |
