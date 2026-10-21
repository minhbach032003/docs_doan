# Nhật ký đồng bộ WMSD — 21/10/2026

## 1. Phạm vi và căn cứ hiện hành

- Yêu cầu lần này: đồng bộ toàn bộ bảy file đã chỉ định theo quy trình mới và bổ sung các luồng ngoài happy case. Sửa trực tiếp theo chỉ dẫn mới nhất; không dùng AGY, không stage/commit, không gửi email hoặc yêu cầu review ra ngoài.
- Căn cứ: quyết định D1–D8 trong nhật ký 20/10 bên dưới, khảo sát một phản hồi lúc 09:04:25 ngày 20/10/2026 (GMT+7), và hai bản Đề xuất quy trình 2. Không tự thay đổi các quyết định đã chốt hoặc bịa thời hạn nhận trả/hệ số SKU/danh sách kho.
- Git trước sửa sạch. Chỉ bảy file được yêu cầu và nhật ký này thay đổi; tài liệu nguồn cũ/CSV, Word, hình và draw.io giữ nguyên. Bản chụp trước sửa và script kiểm tra ở thư mục tạm của phiên, ngoài repository.

## 2. Nội dung đã đồng bộ

| File | Thay đổi |
|---|---|
| [Report 1 text](docs/01_bao_cao/WMSD_Report1_Fix.docx.txt) | Đồng bộ mục tiêu, bối cảnh As-is, giải pháp, đủ 7 BF, 9 FE và giới hạn LI. Tách dữ kiện khảo sát khỏi To-be; bỏ cam kết SO/giá/hóa đơn/hoàn tiền trong WMS. Giữ thông tin dự án/stakeholders và lịch sử chỉnh sửa. Bỏ số trang Word cũ khỏi mục lục text. |
| [Report 3 text](docs/01_bao_cao/WMSD_Report3_Fix.docx.txt) | Viết lại các phần baseline cũ và gom boilerplate lặp; đồng bộ context/mainflow/model/rules, catalogue, associations, quyền, đặc tả, màn hình/API/job, NFR và appendix. Giữ 108 ID: 95 active, 13 retired; đủ 108 đặc tả và 108 dòng quyền. 49 UC có hợp đồng thao tác cụ thể; UC xem/trace giữ input/display phù hợp và không post. UC-72 là custody/inspection trước Owner; UC-73 chỉ nhận phần đủ điều kiện đúng version/quantity. |
| [Quy trình VI](docs/02_nghiep_vu/de_xuat_quy_trinh_2_VI.md), [EN](docs/02_nghiep_vu/de_xuat_quy_trinh_2_EN.md) | Thêm 35 nhánh A/E ở ngay từng BF với điều kiện, người xử lý, điểm tiếp tục, tác động tồn và UC; thêm EX-01–05 dùng chung. Cập nhật phạm vi đồng bộ, trạng thái checklist, source version/correlation và tham chiếu database. |
| [Thiết kế database VI](docs/03_thiet_ke/de_xuat_database_design_VI.md), [EN](docs/03_thiet_ke/de_xuat_database_design_EN.md) | Chuyển căn cứ sang baseline 21/10 và D1–D8; xác nhận từ 3 kho nhưng chưa biết danh sách. Đồng bộ T-SQL/schema wmsd, MongoDB runtime, assessment D6, packaging, external source/correlation, enforcement R-13–15, 26 case nghiệm thu và trace nhánh ngoại lệ. Không gán kết quả PostgreSQL cũ cho T-SQL hiện tại. |
| [SQL tham chiếu](docs/03_thiet_ke/WMSD_SQL_schema.sql) | Thêm CHECK cố định 5 role; inspection packaging enum độc lập quality; lý do assessment không trống và index tìm assessment theo dòng/version; source_version nullable, correlation_id UNIQUE không trống; bổ sung nghĩa vụ service theo các ngoại lệ. Vẫn 64 bảng, 2 view; không thêm engine runtime hoặc stored procedure giả. |
| [Nhật ký này](change_logs.md) | Bổ sung bản ghi 21/10; giữ toàn bộ nhật ký 20/10 nguyên văn phía dưới dưới nhãn lịch sử. |

Màn hình Report 3: SC-01–24 tiếp tục active, SC-25–27 retired; thêm SC-28 External Document References. Tổng 28 ID màn hình, 25 active/3 retired. UC-103 dùng SC-10/16; UC-104 tại SC-13; UC-105 tại SC-14; UC-106/107 tại SC-19; UC-108 tại SC-28. API-02 mô tả hợp đồng lưu chứng cứ riêng tư, chưa chọn nhà cung cấp; JOB-01 chỉ xử lý thông báo kho sau commit, không có job tự tạo kiểm kê/PO.

## 3. Phủ luồng ngoài happy case

| BF | Số nhánh mỗi ngôn ngữ | Các tình huống bổ sung |
|---|---:|---|
| BF-01 | 6 | Nhu cầu đã có nguồn; từ chối/trả sửa; giao phần/chốt thiếu; thừa/sai; không nhận lượng nào; thùng mở/rách và hàng thay thế. |
| BF-02 | 4 | Lỗi trên hàng đã giữ/soạn; chưa rõ chủ/cause; duyệt phần/từ chối; chưa thực hủy/trả và chống trừ lặp. |
| BF-03 | 5 | Nội kho; xuất trực tiếp kho khác; thiếu nguồn/người nhận độc lập; nhận phần/hỏng; thừa/sai lô/thất lạc đã xác minh. |
| BF-04 | 5 | Task dở/khóa chồng; chưa đếm/0/hàng mới; quality khác mất lượng; không lệch/trả sửa; lỗi mạng khi clearing. |
| BF-05 | 5 | Nguồn chưa rõ/trùng/tranh hàng; giao phần/đổi lô; soạn lệch; hủy trước PGI/unpick; hủy/trả sau PGI. |
| BF-06 | 5 | Lịch sử ngoài WMS; D6 chưa rõ/bị loại; trả hỗn hợp; đổi assessment/vượt nguồn; rút yêu cầu/chậm giao trả custody. |
| BF-07 | 5 | NCC chưa đồng ý/đồng ý phần; tái dùng quyết định BF-02; soạn thiếu/custody; ACK lệch; đổi hàng/bồi thường ngoài WMS. |

EX-01–05: phân quyền/tách người; version/cạnh tranh nguồn; chưa rõ commit/retry; khóa kiểm kê; chứng cứ/in/email lỗi. Nhánh quy định rõ rollback/giữ trạng thái/chờ hoặc tiếp tục, không tự tạo quyền hay tăng/trừ tồn bằng đổi trạng thái.

## 4. Kiểm tra của lượt 21/10

| Kiểm tra | Kết quả và giới hạn |
|---|---|
| Catalogue ↔ đặc tả ↔ quyền | 108 ID duy nhất, tên/trạng thái khớp; 95 active/13 retired; mọi retired không có quyền hoặc bước thực thi. |
| Màn hình | 28 ID, 25 active/3 retired; mọi active UC có màn hình, không màn hình active nào gắn UC retired. |
| VI–EN và SRS | Cùng 35 mã nhánh theo thứ tự, 5 lỗi chung, 30 BR; BR tiếng Anh trong SRS trùng bộ quy trình. Hai bản quy trình cùng 27 bảng với số dòng tương ứng; hai bản database cùng 13 bảng và 26 case T01–T26. |
| Liên kết nội bộ | Các liên kết file trong 4 bản quy trình/database không có đích bị thiếu; kiểm range UC trong SRS không có range đảo/vượt 108. |
| Cú pháp SQL Server | Microsoft ScriptDom 180.140.0, TSql160Parser: 0 lỗi, 6 batch; đếm 64 bảng/2 view. Đây là parse, chưa thực thi trên SQL Server. |
| Biểu thức CHECK | 750 phép kiểm trên SQLite in-memory dùng nguyên biểu thức CHECK/enum từ DDL và hàm LEN tương thích. Gồm 720 tổ hợp D6, 9 thiếu bằng chứng thời hạn, 2 lý do trống, 1 enum D6 sai; 18 kiểm bổ sung về role/packaging/source-version/correlation và unique nguồn. Không thay thế hành vi collation, FK, service hay concurrency SQL Server. |
| Diff / phạm vi | Đọc diff các thay đổi, rà các phần nguồn/role/stock effect và whitespace; git diff --check đạt. Không stage hoặc commit; không sửa file ngoài 8 file nêu trên. |

## 5. Giới hạn còn lại

- Chỉ cập nhật các bản text/Markdown/DDL được chỉ định. Word .docx, hình nhúng, PNG và draw.io không được sửa trong lượt này; sơ đồ Mermaid/context/ER và nội dung text hiện hành không làm ảnh cũ tự đổi. Khi dựng Word/PDF mới phải thay hình cũ theo bộ này.
- Chưa có SQL Server engine hoặc backend runtime để chạy migration, phân quyền, transaction/concurrency và end-to-end. Các nhánh/26 case là tiêu chí nghiệm thu, không tuyên bố hệ thống đã vượt qua chúng.
- Chưa xác minh danh sách/địa chỉ/số kho chính xác (đã biết từ 3), người từng kho, actual calibre, hệ số từng SKU, thời hạn trả và lịch đối chiếu MISA. Không tự đặt giá trị mặc định.
- Các tham khảo sản phẩm/thuế/SAP từ bản trước là lịch sử; lượt này không tái xác minh nguồn web hay đưa hướng dẫn pháp lý mới.

---

> **Nhật ký lịch sử 20/10/2026:** phạm vi và giới hạn dưới đây mô tả lượt trước. Phần “Report 3 chưa viết lại toàn bộ”, “không sửa Report 1” và “chưa cập nhật thiết kế database” đã được thay bằng kết quả lượt 21/10 phía trên; không còn là trạng thái hiện tại của bộ text.

# Nhật ký cập nhật quy trình WMSD — 20/10/2026

## 1. Căn cứ và phạm vi

- [Khảo sát Tân Thương](docs/05_khao_sat/khao_sat_kho_gach.csv): 1 phản hồi lúc 09:04:25 ngày 20/10/2026 (GMT+7), 26 câu hỏi.
- [Đề xuất sau review1](docs/02_nghiep_vu/De_xuat_7_quy_trinh_sau_review1.md): nguồn kế thừa; giữ nguyên file gốc.
- Quyết định D1–D8 của người dùng trong chat: đã cho phép cập nhật hai bản đề xuất mới, bảng UC của Report 3 dạng text, sơ đồ mainflow và SQL tham chiếu.
- Không sử dụng AGY; không tạo commit; không gửi email hoặc yêu cầu review ra ngoài.

## 2. Quyết định áp dụng

| Mã | Nội dung đã chốt | Tác động |
|---|---|---|
| D1 | Giữ giảm tồn vật lý tại bàn giao/PGI | Lập yêu cầu chỉ giữ hàng/giảm khả dụng. Ghi rõ khác câu 17 của khảo sát và cần đối chiếu đơn MISA chưa thực giao. |
| D2 | Giữ các bộ phận tự nhập/xác nhận như bản cũ | Không thêm nhập hộ hoặc tài khoản dùng chung, dù khảo sát chọn kế toán/một người nhập chung. |
| D3 | Giữ đúng 5 application role | Store Owner, Sales Staff, Warehouse Staff, Accountant, Administrator. Warehouse Staff là tên thống nhất của Inventory Staff, không phải role mới. Không thêm mua hàng/giao hàng hoặc cơ chế ủy quyền động. |
| D4 | Có chuyển hàng giữa các kho | Giải quyết mâu thuẫn chọn có/không ở câu 13 bằng xác nhận người dùng; không sửa CSV. Giữ BF-03B và xác nhận độc lập hai đầu. |
| D5 | Giữ khóa phạm vi kiểm kê | Bổ sung lịch kiểm hằng tháng. Không chọn vừa đếm vừa nhập/xuất; không thêm job tự tạo phiên. |
| D6 | Bổ sung điều kiện khách trả | Nguyên thùng/viên lẻ chưa dùng xét từng trường hợp; không nhận đã thi công, hỏng do khách, quá hạn đã xác minh. Chưa rõ điều kiện/thời hạn thì chờ, không tự đặt số ngày. |
| D7 | Cập nhật dữ kiện có căn cứ | Từ 3 kho trở lên theo khảo sát; đã chia khu/kệ và đánh mã; ghi lô/màu/kích thước; thùng/viên/m², thùng mở, bao bì rách; dùng điện thoại; phối hợp kiểm nhận/liên hệ NCC. Không suy diễn calibre, địa chỉ, hệ số hay quyền mới. |
| D8 | Giữ các kiểm soát còn lại dưới nhãn To-be | Custody, staging/put-away, FIFO tương thích, chống post trùng, không tự duyệt, duyệt TR, không live MISA tiếp tục là thiết kế đề xuất. |

## 3. File được tạo/cập nhật

| File | Nội dung |
|---|---|
| [de_xuat_quy_trinh_2_VI.md](docs/02_nghiep_vu/de_xuat_quy_trinh_2_VI.md) | Tạo bản Việt đầy đủ từ nguồn cũ, giữ cấu trúc thuật ngữ và 16 mục. Thêm nguồn khảo sát, bảng D1–D8, phân biệt As-is/To-be, dữ kiện đã rõ/chưa rõ, BR-29/30 và tình huống nghiệm thu mới. |
| [de_xuat_quy_trinh_2_EN.md](docs/02_nghiep_vu/de_xuat_quy_trinh_2_EN.md) | Tạo bản Anh tương ứng đầy đủ: thuật ngữ, 7 quy trình, UC, quyền, context, 30 BR, Mermaid, nghiệm thu, nguồn, chứng từ/trạng thái và quy ước lane. |
| [WMSD_Report3_Fix.docx.txt](docs/01_bao_cao/WMSD_Report3_Fix.docx.txt) | Cập nhật 4.1 actors, 4.2 catalogue và 4.4 permission matrix; sửa tên Warehouse Staff và ghi chú trạng thái sơ đồ cũ tại 4.3. Nội dung trước mục 4.1 và từ mục 5 trở đi được giữ nguyên. |
| [WMSD_Mainflows_VI_EN.drawio](docs/04_so_do/WMSD_Mainflows_VI_EN.drawio) | Cập nhật phiên bản/nguồn đề xuất trên 16 trang, nhãn/ghi chú liên quan khảo sát và D1–D8; giữ IDs, lanes, edges và hình học các bước hiện có. |
| [WMSD_Mainflow_BF03B_VI.png](docs/04_so_do/WMSD_Mainflow_BF03B_VI.png) và [WMSD_Mainflow_BF03B_EN.png](docs/04_so_do/WMSD_Mainflow_BF03B_EN.png) | Xuất lại hai ảnh đã được tài liệu tham chiếu từ trang 4 và 12 của draw.io cập nhật, tránh ảnh cũ lệch nhãn/ghi chú. |
| [WMSD_SQL_schema.sql](docs/03_thiet_ke/WMSD_SQL_schema.sql) | Bổ sung bảng đánh giá điều kiện khách trả theo dòng/phiên bản, CHECK và index; bổ sung các nghĩa vụ kiểm soát tại tầng ứng dụng. Bảo toàn toàn bộ dòng SQL có trước lượt này. |
| [change_logs.md](change_logs.md) | Nhật ký này: phạm vi, quyết định, thay đổi, kiểm tra và giới hạn. |

## 4. Thay đổi theo quy trình

| Quy trình | Thay đổi / phần giữ nguyên |
|---|---|
| BF-01 | Ghi chủ/kế toán có thể cùng kiểm và lưu người tham gia trong bằng chứng. Warehouse vẫn xác nhận/post GR. Bao bì rách không tự là gạch hỏng; thùng mở ghi viên thực tế. Luồng RR → Owner → Accountant PO → Warehouse nhận/put-away giữ nguyên. |
| BF-02 | Giữ nguyên luồng, quyền và tác động tồn. Không thêm quyền tự động cho người được ủy quyền trong thực tế. |
| BF-03A | Giữ nguyên di chuyển nội kho không Owner approval, bảo toàn tổng/lô/chất lượng/reservation. |
| BF-03B | Ghi có điều chuyển theo D4 và từ 3 kho theo khảo sát; danh sách kho cụ thể chưa có. Giữ TR duyệt, TD/MWTR riêng, người nhận độc lập và xử lý chênh lệch. |
| BF-04 | Thêm lịch hằng tháng, giữ khóa phạm vi đến khi hoàn tất xử lý. Phương án reconcile giao dịch sau cutoff được ghi là phương án chưa chọn. |
| BF-05 | Ghi các kênh yêu cầu thực tế nhưng Sales chuẩn hóa thành WIR có nguồn xác minh; không tích hợp tự động các kênh. Giữ PGI, reservation, partial delivery và từng bộ phận tự nhập. |
| BF-06 | Thêm điều kiện D6, phân loại theo từng lượng, phiên bản đánh giá/bằng chứng và kiểm điều kiện trước khi duyệt/post. Chưa rõ → custody/chờ xác minh; bị loại → không GR-CR, bàn giao lại nếu đã giữ hàng. Lỗi do NCC không bị đánh đồng hỏng do khách. Mermaid thể hiện riêng nhánh chưa rõ. Hoàn tiền tiếp tục ngoài WMS. |
| BF-07 | Ghi chủ/nhân viên mua hàng có thể liên hệ NCC ngoài phần mềm; Accountant vẫn nhập thỏa thuận/ACK, không thêm role. Giữ chấp thuận NCC trước xuất, duyệt nội bộ, thực xuất và đối chiếu. |

## 5. Catalogue UC và quyền

**108 mã để truy vết = 95 UC active + 13 UC retired.** Không đánh lại số UC.

| Nhóm | Cập nhật |
|---|---|
| UC-03/04/07 | Sales/Warehouse đề xuất, Owner duyệt khác người đề xuất, Accountant lập PO theo dòng đã duyệt. |
| UC-13/26/30/31 | Quy đổi/bao bì, cùng kiểm nhận không đồng nghĩa quyền post, phân biệt tồn vật lý/khả dụng/giữ hộ/đang chuyển. |
| UC-32/33, UC-52–55 | Đặt tên put-away/picking task; không gọi là tầng phê duyệt mới. |
| UC-40/41/43/44 | TR → duyệt → xuất nguồn; UC-43 đổi thành Record Transfer Dispatch, UC-104 nhận đích. |
| UC-45–48/51/58 | Sales Order đổi thành Warehouse Issue Request có nguồn ngoài; kế hoạch giao theo outstanding; PGI theo bàn giao thực tế. |
| UC-65–67 | Cách ly ngay, duyệt và thực hiện đúng lượng; không trừ lặp khi chuyển BF-07. |
| UC-70–73 | Sales tạo; Warehouse kiểm/đánh giá D6; Owner duyệt sau kiểm; chỉ post lượng đủ điều kiện đúng phiên bản. |
| UC-81–83 | Kho đề nghị/thực xuất, NCC đồng ý + Owner duyệt trước xuất; ACK về sau, đóng không trừ lại. |
| UC-86–93 | Kiểm theo tháng/mục tiêu; snapshot và FROZEN; phiếu đếm/recount; Warehouse đề xuất delta; Owner duyệt và Clear Difference riêng. UC-92 đổi tên Review Inventory Adjustment để thể hiện duyệt/từ chối/trả về. |
| UC-98–102 | Năm role, scope kho, nhật ký, báo cáo và trace theo phạm vi kho; không nhập hộ/ủy quyền động. |
| UC retired | UC-23–25 giá bán; UC-42 TO liên kho dư; UC-59–62 hóa đơn nội bộ; UC-74–78 workflow hoàn tiền. Giữ mã/lý do, không có quyền active. |
| UC-103 mới | View and Select Shortage Fulfilment Options — Sales/Warehouse; hỗ trợ BF-01/03/05. |
| UC-104 mới | Inspect and Post Transfer Receipt — Warehouse kho đích độc lập. |
| UC-105 mới | Export or Print Stocktake Count Sheet — Warehouse/Owner; giữ riêng, chưa gộp vào UC-87. |
| UC-106 mới | Approve Supplier Return and Variance Resolution — Owner; phân biệt quyết định trước xuất và xử lý sai lệch. |
| UC-107 mới | Record Supplier Agreement and Receipt Acknowledgement — Accountant; hai mốc độc lập. |
| UC-108 mới | Record External Document References — Accountant; nguồn lịch sử/hóa đơn/hoàn tiền/đối chiếu bên ngoài. |

Bảng quyền được đồng bộ cho đủ 108 mã; cả 13 retired đều không còn quyền thực hiện. Quyền xem không tự cấp quyền nhập, duyệt hoặc post. Bản đề xuất giữ ma trận nghiệp vụ tổng hợp, Report 3 giữ ma trận từng UC.

## 6. SQL: đánh giá phù hợp và bổ sung

### 6.1 Cấu trúc có sẵn phù hợp, giữ nguyên

- `app_role` có đúng OWNER, SALES, WAREHOUSE, ACCOUNTANT, ADMIN.
- `warehouse`, `location`, `user_warehouse` đã hỗ trợ nhiều kho, mã vị trí và phạm vi người dùng; không cần seed ba kho giả.
- `product_uom_version`, `document_line` đã lưu hệ số/đơn vị và snapshot để theo dõi thùng/viên/m².
- `transfer_dispatch`, `transfer_receipt`, `stock_account` đã tách xuất, nhận và transit.
- `reservation`, `posting_batch`, `stock_movement`, `available_stock` đã biểu diễn giữ hàng và ghi nhận thực xuất.
- `stocktake.mode = 'FROZEN'`, `location_lock`, snapshot/count/adjustment phù hợp D5.
- `evidence`, `document.note`, `audit_event`, `external_reference` dùng để ghi phối hợp kiểm nhận, người liên hệ NCC và kết quả bên ngoài; không cần role mới.

### 6.2 Khoảng trống và cách bổ sung

Trước cập nhật, `customer_return_line` chỉ có nguồn và lý do, chưa biểu diễn có cấu trúc các điều kiện D6. Thêm `customer_return_assessment`:

| Dữ liệu | Ý nghĩa |
|---|---|
| `return_line_id`, `assessment_no`, `document_version` | Lượng/dòng được đánh giá, lần đánh giá và phiên bản hồ sơ. Tách dòng khi điều kiện từng lượng khác nhau. |
| `packaging_condition` | SEALED / OPENED / TORN / UNKNOWN; không đồng nghĩa quality. |
| `installation_status` | UNUSED / INSTALLED / UNKNOWN. |
| `damage_cause` | NONE / CUSTOMER / SUPPLIER / OTHER / UNKNOWN. |
| `deadline_status`, `deadline_reference` | WITHIN / EXCEEDED / NOT_APPLICABLE / UNKNOWN; trạng thái đã xác minh phải có căn cứ, kể cả không áp dụng thời hạn. Không có số ngày mặc định. |
| `eligibility_status` | PENDING / CASE_REVIEW / INELIGIBLE. CASE_REVIEW chỉ có nghĩa đủ căn cứ để xét, chưa phải Owner đã chấp nhận. |
| `assessment_reason`, `assessed_by`, `assessed_at`, `approval_id` | Lý do, người/thời điểm đánh giá và liên kết quyết định. |

- `ck_return_deadline_evidence`: chặn trạng thái thời hạn đã xác minh nhưng thiếu/trống tham chiếu.
- `ck_return_eligibility`: đã thi công/hỏng do khách/quá hạn không thể là CASE_REVIEW; điều kiện chưa rõ phải PENDING nếu chưa có căn cứ loại; biết chắc điều kiện loại phải INELIGIBLE.
- Unique `(return_line_id, assessment_no)` và index theo trạng thái/dòng.
- Tầng ứng dụng phải chọn đánh giá mới nhất đúng phiên bản, kiểm kết quả inspection và approval đúng hồ sơ/dòng/lượng trước GR-CR; thay điều kiện phải đánh giá/duyệt lại. DDL không tự thực hiện các kiểm tra liên bảng này.

**Bảo toàn thay đổi có sẵn:** trước lượt này SQL đã được sửa từ PostgreSQL sang SQL Server/T-SQL, gồm `wmsd.*`, `IDENTITY`, `bit`, `datetimeoffset`, filtered indexes và `GO`. Toàn bộ các dòng đang có được giữ theo đúng thứ tự; lần này chỉ chèn bổ sung. Diff với Git HEAD lớn hơn phần thay đổi của lượt này vì bao gồm chuyển đổi cú pháp có trước.

SQL tiếp tục là **DDL tham chiếu để review**, không phải schema runtime MongoDB, không phải migration đã triển khai và chưa có posting/authorization service.

## 7. Kiểm tra đã thực hiện

| Kiểm tra | Kết quả và giới hạn |
|---|---|
| Giữ nguyên tài liệu gốc | Không sửa `De_xuat_7_quy_trinh_sau_review1.md` hoặc CSV. |
| Bảo toàn phần Việt không thay đổi | So sánh nguyên văn mục 3, 6, 7, 13, 14, 15 với nguồn cũ: trùng khớp. Các mục còn lại sửa tại phần có tác động hoặc thêm dữ kiện. |
| Tương ứng Việt–Anh | Đủ 16 mục đánh số, 19 bảng có cùng số dòng tương ứng, 7 BF chi tiết và 7 Mermaid mainflow mỗi bản; cùng các mã BR/UC. Đã đọc đối chiếu nội dung, không chỉ đếm mục. |
| Catalogue / permission | 108 mã duy nhất; 95 active, 13 retired; đủ 108 dòng quyền; mọi retired đều không có quyền. |
| Phạm vi Report 3 | Nội dung trước 4.1 và từ mục 5 trở đi trùng bản trước sửa. 4.3 chỉ đổi tên role và ghi chú sơ đồ cũ cần đồng bộ. |
| Draw.io | `validate.py --score`: 0 lỗi, 0 cảnh báo; 16 trang. IDs/lane/edge và geometry bước không đổi; chỉ tăng vùng note/page ở trang cần ghi chú dài. |
| Bản vẽ xuất | Draw.io Desktop 32.5.5 xuất thành công PDF kiểm tra đủ 16 trang và ảnh PNG; đã xem toàn bộ bố cục qua contact sheet và BF-06 Việt/Anh ở kích thước đọc được. Hai PNG BF-03B đã xuất lại. |
| Cú pháp SQL | Microsoft ScriptDom 180.140.0, parser `TSql160Parser`: 0 lỗi, 6 batch. Đây là parse cú pháp SQL Server, không phải chạy DDL trên SQL Server. |
| Điều kiện trả hàng | 20 tình huống thử các CHECK mới trong SQLite in-memory, giữ biểu thức CHECK và cung cấp hàm LEN tương thích: nguyên thùng, lẻ, bao bì rách, lỗi NCC, đã thi công, hỏng do khách, quá hạn, thiếu căn cứ và chờ xác minh đều cho kết quả mong đợi. Không thay thế kiểm thử SQL Server hoặc service thật. |
| Bảo toàn SQL trước sửa | So sánh với bản chụp đầu lượt: chỉ có insert, không delete/replace các dòng SQL cũ. |
| Git | `git diff --check` không báo lỗi whitespace. Không stage hoặc commit. |

Các script kiểm tra, bản chụp trước sửa, parser tải về và ảnh/PDF xem trước nằm trong thư mục tạm của phiên, không thêm vào repository.

## 8. Phần còn ngoài phạm vi / chưa xác minh

1. **Report 3 chưa được viết lại toàn bộ.** Người dùng yêu cầu cập nhật bảng UC trong bản `.docx.txt`; catalogue, actor và permission đã đồng bộ. Các mainflow bằng chữ, đặc tả UC chi tiết ở phần II, screen, entity/rule và hình nhúng cũ vẫn còn nội dung baseline. Ghi chú ngay trong mục 4.2/4.3 chỉ rõ các phần cũ không được dùng để khôi phục quyền/phạm vi đã retired. Cần một lượt đồng bộ toàn SRS trước khi gọi cả report là bản cuối. Không sửa Word `.docx` hay Report 1.
2. Không có SQL Server engine được dùng để chạy DDL hoặc test dịch vụ thực tế; chỉ kiểm cú pháp và biểu thức điều kiện như mục 7. Không chạy trên database có dữ liệu.
3. Không tự cập nhật ERD database draw.io hoặc tài liệu thiết kế database khác: người dùng chỉ chỉ định SQL và mainflow, và ERD đang là file chưa theo dõi có trước lượt này.
4. Chưa xác minh số kho chính xác/danh sách/địa chỉ, số người từng kho, actual calibre, hệ số từng SKU, thời hạn nhận trả và lịch đối chiếu MISA. Giữ các mục này ở trạng thái cần xác minh.
5. Các liên kết SAP/MISA và hướng dẫn hóa đơn được kế thừa từ đề xuất gốc; lượt này không tái xác minh toàn bộ nguồn trực tuyến hoặc quy định thuế. Không coi đó là tư vấn pháp lý được cập nhật.
6. Các file có sẵn chưa theo dõi `docs/03_thiet_ke/WMSD_database_design.drawio`, `docs/03_thiet_ke/debug.log` và CSV khảo sát được giữ nguyên. Không thu dọn hoặc gán chúng là sản phẩm của lượt này.
