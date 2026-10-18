# Thiết kế hệ thống WMSD

Phiên bản 1.0 • Ngày 16 tháng 10 năm 2026

Tài liệu dành cho nhóm phân tích, phát triển và kiểm thử hệ thống quản lý kho của cửa hàng điện nước gạch ốp lát Tân Thương. Nội dung mô tả phạm vi, trách nhiệm, dữ liệu, luồng xử lý, quy tắc kiểm soát và thiết kế triển khai cho toàn bộ chín nhóm chức năng. Nguyên tắc xuyên suốt là quản lý hàng theo sản phẩm, lô, tone, calibre, vị trí và chất lượng; mọi thay đổi tồn phải có chứng từ nguồn, đúng quyền và không được ghi nhận hai lần.

## 1 Cơ sở thiết kế và phạm vi

### 1.1 Nguồn và thứ tự áp dụng

| Mã | Nguồn | Phạm vi sử dụng |
|---|---|---|
| R1 | WMSD_Report1_Fix.docx trên Google Docs, bản sửa 15/10/2026 | Bối cảnh cửa hàng, FE-01 đến FE-09, LI-01 đến LI-10 |
| R3 | WMSD_Report3_Fix.docx trên Google Docs, bản sửa 15/10/2026 | 102 UC, 27 màn hình, ma trận quyền, DR/GB, yêu cầu phi chức năng |
| D | WMSD_Bangach (1).drawio, 37 trang | Sơ đồ nghiệp vụ và use case mới |
| D-UC | Các trang 14, 16, 18, 20, 22 mang tên Bản sao của UC… | Bộ UC đầy đủ của Accountant, Admin, Store Owner, Sales Staff, Inventory Staff |
| D-P35 | Trang 35 Purchasing and Receiving_v3, phần To-be | Chu trình mua hàng, nhận nhiều đợt, xử lý sai lệch và đóng phần còn thiếu |
| D-P36 | Trang 36 Chuyển kho nội bộ, phần TO BE | Transfer Request → duyệt → Transfer Order → xác nhận |
| R3-ERD | Hình dưới mục I.3.1 Entity Relationship Diagram của Report 3 | ERD chuẩn theo yêu cầu riêng của người sử dụng |

Liên kết nguồn R1: https://docs.google.com/document/d/1kb36v5HuFrM75NFCTXvnJcsg6QnPjYkb/edit

Liên kết nguồn R3: https://docs.google.com/document/d/1HvhlCmYjfXj7766ZVNUBAU4J063Lmr71/edit

Quyết định áp dụng ngày 16/10/2026: ưu tiên D-UC và D-P35 khi khác báo cáo; riêng ERD dùng hình trong R3. Các trang BF “Mới” dùng bổ trợ khi không mâu thuẫn bộ UC đã chọn. Sơ đồ AS IS mô tả thực tế hiện tại, không tự động trở thành chức năng của hệ thống mới. Ký hiệu [TK] đánh dấu quyết định thiết kế kỹ thuật hoặc cách chuẩn hóa để triển khai; không phải yêu cầu đã được khách hàng phê duyệt. Ký hiệu [CXC] đánh dấu tham số hoặc quyết định nghiệp vụ cần xác nhận trước nghiệm thu. Các mã F, BR, API, TC trong tài liệu này là mã thiết kế, không thay thế mã UC/FE trong nguồn.

### 1.2 Phạm vi chức năng

| Nhóm | Chức năng | UC |
|---|---|---|
| FE-01 | Đề nghị bổ sung, PO, xác nhận NCC, nhận nhiều đợt | 01–10 |
| FE-02 | Sản phẩm, quy cách, lô, NCC, khách hàng, giá bán nhập tay | 11–25 |
| FE-03 | Kiểm đếm, kiểm tra chất lượng và ghi nhận nhận hàng | 26 |
| FE-04 | Vị trí, số dư tồn, put-away và di chuyển nội bộ kho | 27–37 |
| FE-05 | Yêu cầu chuyển kho, TO, bàn giao, nhận và xử lý chênh lệch | 38–44 |
| FE-06 | SO, Outbound Delivery, picking TO, PGI, hóa đơn nội bộ | 45–62 |
| FE-07 | Hàng lỗi, trả khách, hoàn tiền ngoài hệ thống, trả NCC | 63–83 |
| FE-08 | Kiểm kê, đối chiếu, duyệt điều chỉnh và Clear Difference | 84–93 |
| FE-09 | Đăng nhập, tài khoản, quyền, báo cáo, nhật ký và truy vết | 94–102 |

Hệ thống phục vụ một cửa hàng với các kho và vị trí được cấu hình cho cửa hàng đó. Chuyển giữa các kho này thuộc phạm vi; quản lý chuỗi nhiều cửa hàng không thuộc phạm vi. Khách hàng, nhà cung cấp và người vận chuyển là đối tượng nghiệp vụ bên ngoài, không phải vai trò đăng nhập bổ sung.

Không triển khai thu tiền bán hàng, đặt cọc, công nợ phải thu/phải trả, sổ cái, kế toán đầy đủ, hóa đơn điện tử pháp định hoặc đồng bộ trực tiếp MISA. Hóa đơn nội bộ và hồ sơ chứng minh hoàn tiền đã thực hiện bên ngoài vẫn thuộc phạm vi. Không có báo giá, khuyến mãi, loyalty, CRM đầy đủ, thương mại điện tử, dự báo nhu cầu, tự động đề xuất giá, tối ưu tuyến xe, GPS, HRM hay trình biên tập chính sách nghiệp vụ. Giá bán cuối cùng được nhập; margin nếu có được tính bên ngoài. Nguồn: R1 V.2; R3 I.1, V.3.

### 1.3 Các khác biệt đã xử lý

| Điểm khác biệt | Cách áp dụng trong thiết kế |
|---|---|
| BF04 ghi Inventory Staff post adjustment; D-UC SO có Clear Stocktake Difference | Chủ cửa hàng duyệt UC-92 và thực hiện riêng UC-93; nhân viên kho chỉ kiểm đếm, đối chiếu, đề nghị |
| BF06a giao Sales Staff lập trả hàng và duyệt sau kiểm tra | D-UC và UC-70–73: Inventory Staff lập; Store Owner duyệt nhận để kiểm tra trước; Inventory Staff kiểm tra và nhập trả |
| BF06b giao Accountant lập trả NCC, Owner duyệt trước xuất | D-UC và UC-81–83: Inventory Staff lập và xuất; ghi chấp thuận bên ngoài của NCC; Owner duyệt đóng sau đối chiếu |
| BF05 chỉ có yêu cầu xuất và xuất hàng | Bộ UC đầy đủ tách SO, OD, picking, PGI và hóa đơn; picking không giảm tổng tồn |
| R1 có nhánh sửa đề nghị rồi kết thúc; D-P35 To-be có vòng duyệt lại | Dùng vòng sửa → trình duyệt lại của D-P35 |
| D-P35 bổ sung Owner duyệt đóng số lượng PO còn thiếu | Thiết kế thao tác riêng cho Owner trong FE-01; đây là phần mở rộng từ sơ đồ, chưa có UC riêng trong 102 UC |
| Một số tham chiếu UC ở R3 I.3 và DR còn số cũ hoặc dải lỗi | Giữ nội dung nghiệp vụ; truy vết bằng danh mục UC-01–102 và tên thao tác hiện hành |
| R3 mô tả ERD 15 thực thể nhưng hình thực tế có 14 hộp | Giữ hình ERD trong tài liệu làm chuẩn; tách thực thể bổ sung từ phần chữ và UC ở mục 8 |
| Context trang 37 có Cloudinary; danh mục API R3 chỉ có SMTP | Ghi Cloudinary là tích hợp lưu bằng chứng theo sơ đồ; hợp đồng API chi tiết là [TK] |

## 2 Vai trò và quyền thao tác

### 2.1 Trách nhiệm chính

| Vai trò | Trách nhiệm | Giới hạn bắt buộc |
|---|---|---|
| Store Owner | Duyệt bổ sung hàng, chuyển kho, xử lý sai lệch và hàng lỗi; duyệt trả khách, hoàn tiền; duyệt đóng trả NCC; tạo kiểm kê, duyệt và clear; quản lý sản phẩm, vị trí, giá | Không mặc nhiên có quyền thực hiện các thao tác của kế toán hoặc nhân viên kho |
| Accountant | Lập đề nghị mua, quản lý PO và phản hồi NCC; lập/phát hành hóa đơn nội bộ; đề nghị hoàn tiền và ghi bằng chứng hoàn tiền | Không phê duyệt yêu cầu của mình; không post tồn bằng quyền kế toán |
| Inventory Staff | Nhận và kiểm hàng; put-away; picking, PGI; chuyển vị trí/kho; hàng lỗi; trả hàng; kiểm đếm và đối chiếu | Chỉ kho được phân công; không duyệt hoặc clear điều chỉnh kiểm kê |
| Sales Staff | Quản lý khách hàng, lập/sửa/hủy phần chưa hoàn tất của SO, tạo OD; xem hàng có thể bán | Không thấy giá vốn và toàn bộ hồ sơ cách ly; không lập/xử lý trả hàng bằng quyền xem |
| Administrator | Quản lý tài khoản, gán năm vai trò và tập quyền được định nghĩa | Không có quyền nghiệp vụ chỉ vì là Admin; không tạo chính sách hay luồng duyệt tùy ý |

Quyền phải kiểm tra ở máy chủ cho từng thao tác, bản ghi và phạm vi kho. Bộ lọc danh sách, đường dẫn chi tiết, xuất báo cáo, PDF và tải bằng chứng dùng cùng một phạm vi. Ẩn nút trên giao diện chỉ là hỗ trợ sử dụng. Nguồn: R3 I.4.4, UC-94–102, GB-01, GB-NEW-01/02.

### 2.2 Các quyền gộp cần tách khi lập trình

- UC-16 Maintain Product Lot: Owner được tạo/cập nhật thông tin lô; Inventory Staff chỉ được tạo. Thay đổi chất lượng tồn phải đi qua kiểm tra hoặc disposition, không qua sửa master lô.
- UC-19 Maintain Supplier: Accountant tạo/cập nhật danh tính và liên hệ; Owner kích hoạt/ngừng hoạt động. Không suy ra cả hai đều làm mọi hành động.
- UC-62: Accountant được phát hành, xuất và in; Owner chỉ xuất/in hóa đơn đã phát hành. Quyền xem hoặc xuất PDF không cho phép phát hành.
- UC-99: Owner xem cả năm nhóm; Accountant chỉ báo cáo luân chuyển và mua/nhận; Inventory Staff xem luân chuyển, tồn theo lô/vị trí, chuyển kho, kiểm kê trong kho được phân công.
- UC-05/06: nhân viên kho chỉ xem nội dung phục vụ nhận hàng, không được xem giá mua hoặc sửa PO.
- UC-68/69: Sales Staff chỉ xem trả hàng liên quan đến giao dịch bán được phép xem; không được duyệt, kiểm tra hoặc ghi nhận trả.
- UC-100–102: Accountant chỉ phạm vi mua hàng/nhà cung cấp; không mở toàn bộ chứng từ qua đường dẫn truy vết.

Ma trận đầy đủ 102 UC nằm ở Phụ lục A. Với thao tác mới từ D-P35, Owner duyệt đóng phần dư PO, Accountant đối chiếu và đóng PO; quyền này được quản lý riêng, không mở rộng quyền sửa PO cho Owner.

## 3 Mô hình hàng tồn và các bất biến

### 3.1 Nhận dạng và đơn vị

Khóa nghiệp vụ của số dư là tổ hợp warehouse, location, product, lot và quality status. Tone và actual calibre phải thuộc nhận dạng lô; hai lô có đặc tính khác không được gộp chỉ vì cùng mã sản phẩm. Tồn cần phân biệt trạng thái chất lượng với vị trí vật lý và trạng thái chứng từ.

| Khái niệm | Ý nghĩa |
|---|---|
| On hand | Hàng đã được ghi nhận thuộc tồn tại các vị trí trong kho, gồm cả phần không dùng được |
| Usable | Đã được chấp nhận và đủ điều kiện chất lượng, đã đặt đúng vị trí theo luồng |
| Available [TK] | Phần usable chưa bị giữ cho picking, chuyển kho hoặc trả NCC |
| Receiving/interim | Vị trí tạm nhận; ghi tăng một lần ở GR, chưa mặc nhiên có thể bán |
| Staging | Hàng đã picking và chờ PGI; vẫn thuộc tổng tồn kho |
| Quarantine/pending/damaged | Các phần không được bán, phải có trạng thái và hồ sơ riêng |
| In Transit | Hàng chuyển kho đã rời kho nguồn nhưng chưa được ghi nhận hoàn tất ở kho đích |
| Hàng giữ hộ/chưa nhận sở hữu [TK] | Hàng vật lý đang ở cửa hàng nhưng bị từ chối ngay khi nhận, chưa từng tăng tồn sở hữu |

Các tên enum chuẩn hóa ở trên là [TK]; không coi in transit là chất lượng hàng. Một kiện hàng có thể đang vận chuyển và đồng thời bị hư hỏng. [TK] dùng trạng thái vận chuyển riêng hoặc vị trí vận chuyển ảo, không trộn vào tập chất lượng của lô.

Đối với gạch, đặt k là số viên/thùng và a là diện tích/viên theo cấu hình sản phẩm: số viên = số thùng × k + số viên lẻ; diện tích = số viên × a. Ví dụ minh họa: 4 viên/thùng, 0,36 m²/viên thì 3 thùng + 2 viên = 14 viên = 5,04 m². Không áp công thức diện tích cho thiết bị điện nước hoặc vệ sinh nếu sản phẩm không dùng đơn vị đó. Lưu cả số lượng nhập, đơn vị nhập, hệ số và số lượng chuẩn tại thời điểm giao dịch. Thay quy cách sau này không được tính lại lịch sử. Độ chính xác, quy tắc làm tròn và việc cho phép số viên lẻ là [CXC]. Nguồn: DR-01/02; GB-03; UC-13, 16, 26.

### 3.2 Điểm phát sinh tác động tồn

| Thao tác | Tác động vào số dư | Tác động tổng |
|---|---|---|
| Lập/duyệt đề nghị, lập PO hoặc GR nháp | Không có | 0 |
| UC-26 post nhận hàng | Tăng lượng đã nhận sở hữu ở interim theo từng chất lượng | + lượng nhận sở hữu |
| UC-33 put-away | Giảm interim, tăng vị trí đích cùng lượng | 0 |
| UC-37 chuyển vị trí | Giảm vị trí nguồn, tăng vị trí đích | 0 |
| UC-43 xuất chuyển kho | Giảm kho nguồn, tăng In Transit | 0 trên toàn hệ thống nếu tính In Transit |
| UC-43 nhận chuyển kho | Giảm In Transit, tăng kho đích theo lượng thực nhận hợp lệ | 0 nếu không mất mát |
| UC-55 xác nhận picking | Giảm bin nguồn, tăng staging | 0 |
| UC-58 PGI | Giảm staging theo lượng thực xuất | − thực xuất |
| UC-65 cách ly hàng đang có | Chuyển usable sang trạng thái/vị trí cách ly | 0; available giảm |
| UC-67 xử lý đã duyệt | Chuyển trạng thái hoặc giảm tồn theo disposition được duyệt | Tùy disposition, không tự động giảm mọi trường hợp |
| UC-73 nhập trả khách | Tăng một lần phần được chấp nhận nhận lại, đúng chất lượng/vị trí | + phần nhận lại |
| UC-82 xuất trả NCC | Giảm phần đã thuộc tồn sở hữu; hàng chưa từng nhập chỉ giảm theo dõi giữ hộ | − phần sở hữu thực xuất |
| UC-92 duyệt kiểm kê | Không có | 0 |
| UC-93 Clear Difference | Cộng chênh lệch có dấu vào số dư hiện tại | ± chênh lệch được duyệt |
| Hóa đơn, PDF, hoàn tiền, email, đóng trả NCC | Không có | 0 |

Đối với GR, accepted dùng được, pending, damaged và rejected phải phân loại riêng. Quyền sở hữu đối với phần pending/damaged cần được ghi rõ theo kết quả nhận thực tế; không coi mọi hàng đến là tồn sở hữu. Hàng rejected chưa nhập tồn không tạo bút toán giảm khi trả NCC. [TK] trường ownershipRecorded và sourceReceiptPostingId làm căn cứ chống trừ hai lần.

### 3.3 Công thức đối chiếu

- Tồn cuối cùng phạm vi = tồn đầu + nhận ngoài + nhập trả khách − PGI − xuất trả NCC sở hữu − tiêu hủy được duyệt + điều chỉnh có dấu + chuyển vào − chuyển ra. Chuyển vị trí nội kho triệt tiêu khi cộng toàn kho.
- Tồn sở hữu toàn cửa hàng = tổng on hand ở các kho + In Transit. Không cộng thêm reservation vì đó là quyền giữ hàng, không phải hàng mới.
- Available [TK] = usable tại vị trí được cấp phát − lượng giữ còn hiệu lực. Phần staging đã gắn OD không được hiển thị là hàng rảnh cho đơn khác.
- Q_PO_remaining [TK] = Q_confirmed − Q_fulfilled_by_accepted_receipts − Q_closed_approved. Theo dõi riêng Q_ordered, Q_delivered và Q_rejected; hàng hỏng/từ chối không tự động xóa nghĩa vụ giao bù. Cách tính accepted trong trường hợp sở hữu hàng lỗi cần chốt ở CXC-04.
- Q_SO_outstanding = Q_ordered − Q_issued − Q_cancelled. Q_OD_creatable = Q_SO_outstanding − Q_open_delivery_allocated, trong đó allocation chỉ tính phần chưa PGI và chưa hủy.
- Q_invoice_eligible = Q_posted_issue − Q_invoiced − Q_reserved_by_other_drafts [TK]. Khi chuyển nháp sang issued phải chuyển lượng giữ sang billed, không trừ cả hai lần.
- Q_return_eligible = Q_actual_issued − Q_prior_accepted_returns − Q_active_return_claims [TK]. Kiểm tra lại ở lúc tạo, kiểm tra và post trả.

Mọi số lượng trong công thức phải cùng sản phẩm, lô, chứng từ/dòng nguồn và đơn vị chuẩn. Không lấy số dư tổng sản phẩm để thay số dư lô/vị trí. Không gộp quá trình bán, chuyển kho và trả NCC thành một loại xuất không phân biệt nguồn.

## 4 Luồng nền và quản trị dữ liệu

### 4.1 F01 Đăng nhập và quản trị quyền

Nguồn: UC-94–98, SC-01/02, D-UC Admin.

1. Người dùng nhập username/password. Máy chủ xác thực tài khoản đang active; trả lỗi không tiết lộ tài khoản có tồn tại hay không [TK].
2. Tải vai trò, quyền thao tác và phạm vi kho. Mở vùng làm việc được phép; không có quyền thì không trả dữ liệu nhạy cảm.
3. Admin tạo/cập nhật/kích hoạt/ngừng tài khoản qua UC-97; username duy nhất. Gán vai trò/quyền qua UC-98 là thao tác riêng.
4. Chỉ cho chọn năm vai trò và quyền thuộc danh mục cho vai trò đó. Một quyền thuộc chức năng kiểm kê không được cấu hình thành quyền thực hiện hoàn tiền.
5. [TK] Thay đổi quyền hoặc ngừng tài khoản làm hết hiệu lực quyền của phiên cũ qua permissionVersion; mỗi lệnh ghi kiểm tra lại tài khoản/quyền hiện hành. Lưu người đổi, trước/sau và thời gian.

Ngoại lệ: sai mật khẩu, inactive, phiên hết hạn, quyền bị thu hồi hoặc kho ngoài phân công đều không tạo giao dịch. Không có thao tác Admin sửa trực tiếp số dư để “khắc phục lỗi”. Chính sách hết hạn phiên, giới hạn thử đăng nhập và khôi phục tài khoản là cấu hình kỹ thuật cần chốt, không tự thêm UC nghiệp vụ.

### 4.2 F02 Dữ liệu chủ và giá bán

Nguồn: UC-11–25, 27–29; SC-03/04/05/09/24/25.

1. Owner tạo sản phẩm với mã, tên, loại, nhãn hiệu/vật liệu/kích thước khi phù hợp, đơn vị và hệ số đóng gói dương. Mã sản phẩm duy nhất.
2. Owner hoặc Inventory Staff tạo lô, chọn đúng sản phẩm, lot no, tone và calibre. Chỉ Owner sửa thông tin lô; không ghi đè thuộc tính đã chụp trên giao dịch.
3. Accountant tạo/sửa NCC; Owner thay trạng thái hoạt động. Sales Staff duy trì khách hàng. Giao dịch cũ giữ snapshot thông tin khi lập/phát hành.
4. Owner duy trì vị trí theo kho, khu, dãy, kệ và mã vị trí. Mã vị trí duy nhất trong kho; không vô hiệu hóa nếu còn tồn bất kỳ chất lượng nào hoặc còn di chuyển mở.
5. Owner nhập giá bán cuối cùng theo sản phẩm, đơn vị, ngày hiệu lực; nhập margin tham khảo đã tính bên ngoài nếu cần. Giá không âm, thời gian hợp lệ, giữ lịch sử.
6. Khi lập SO, hiển thị giá tham khảo và cảnh báo áp dụng. Không tự biến cảnh báo thành lệnh cấm hoặc yêu cầu Owner duyệt SO. Không tự tính giá từ margin.

Ngoại lệ: mã trùng, hệ số không dương, tham chiếu inactive, ngừng sản phẩm đang được chứng từ hoạt động sử dụng hoặc ngừng vị trí còn hàng đều phải chặn. Quy tắc giá trùng khoảng hiệu lực và giá chênh bao nhiêu thì cảnh báo chưa được nguồn định lượng [CXC-02].

### 4.3 F03 Danh sách và chi tiết

Áp dụng toàn bộ UC xem, tra cứu và báo cáo. Người dùng mở màn hình → máy chủ kiểm tra quyền/phạm vi → nhập bộ lọc tùy chọn → kiểm tra khoảng ngày và tham chiếu → phân trang kết quả → mở chi tiết trong cùng phạm vi. Không bắt buộc mọi bộ lọc. Không tìm thấy thì trả danh sách rỗng và MSG-01, không dùng dữ liệu minh họa của mockup làm dữ liệu thật. Bản ghi lịch sử inactive vẫn được xem nếu người dùng có quyền. Từ chi tiết sang thao tác ghi phải kiểm tra quyền và trạng thái lại.

## 5 Luồng mua hàng và kho

### 5.1 F04 Bổ sung hàng và PO nhiều đợt

Nguồn chính: D-P35 To-be; UC-01–10; R1 IV; SC-06/07/08.

Điều kiện: dữ liệu sản phẩm, NCC và kho nhận hợp lệ; Accountant có quyền lập đề nghị/PO. Thông tin tồn và hàng đang về là tham khảo quyết định mua, không tạo đề nghị tự động.

1. Nhân viên kho xem tồn, hàng đang về và nhu cầu; Accountant lập replenishment request gồm sản phẩm, số lượng dương và lý do.
2. Owner xem nhu cầu, số dư tham khảo và duyệt. Nếu không duyệt, lưu lý do, Accountant sửa phiên bản và trình lại theo D-P35. Chưa duyệt thì không được tạo PO.
3. Accountant tạo PO gắn đề nghị được duyệt và NCC; ghi số lượng đặt, đơn vị, thông tin giao và chứng từ cần thiết.
4. NCC xác nhận bên ngoài; Accountant ghi lượng xác nhận, ngày giao dự kiến và bằng chứng liên hệ. NCC không đăng nhập WMSD.
5. NCC không đáp ứng: Accountant sửa/hủy dòng chưa nhận; theo D-P35 quay lại gửi PO/xác nhận. Phần đã nhận không được xóa hoặc sửa để che lịch sử.
6. Mỗi chuyến giao tạo một GR riêng; Inventory Staff kiểm đếm/kiểm tra theo F05. Có phần đạt thì ghi nhận phần đó và put-away; đồng thời giữ hồ sơ phần lệch/lỗi.
7. Nếu có sai lệch, Accountant liên hệ NCC. Ghi phương án đã thống nhất: thay hàng, giao bù/giao sau hoặc điều chỉnh số lượng. Việc thống nhất chưa làm thay đổi tồn.
8. Đối chiếu PO với các GR đã xác nhận. Còn thiếu và NCC đồng ý giao tiếp thì giữ PO mở, vòng về nhận chuyến tiếp theo.
9. Nếu không giao tiếp, Owner duyệt đóng số lượng còn thiếu với lý do, phiên bản PO và dòng/số lượng cụ thể. Không tăng giả Q_received để đưa số dư thiếu về 0.
10. Accountant đối chiếu chứng từ/hóa đơn mua bên ngoài với PO và GR, ghi kết quả rồi đóng PO. Đây là đối chiếu chứng từ, không phải ghi công nợ hoặc thanh toán NCC trong WMSD.

Kết thúc: PO hoàn tất nhận hoặc phần thiếu được Owner duyệt đóng; GR/sai lệch/chứng từ liên quan có kết quả rõ. Yêu cầu đang bị từ chối không đi tiếp. [TK] Không cho đóng PO khi còn GR nháp đang xử lý hoặc sai lệch chưa có phương án.

Nhánh ngoại lệ: phát hiện giao trùng → kiểm tra delivery reference, không tự tạo lần nhận thứ hai; thay đổi số dư PO đồng thời → tải lại và xác nhận; nhận thừa/sai hàng/sai lô → ghi lượng thực tế nhưng không tự coi thừa là accepted trong PO; hàng thay thế đến sau tạo lần nhận mới gắn hồ sơ sai lệch. Quyền duyệt đóng dư và trạng thái đối chiếu mua là bổ sung từ D-P35, cần cập nhật SRS tương ứng, không tự gán số UC-103.

### 5.2 F05 Kiểm nhận và put-away

Nguồn: UC-10, 26, 32, 33; D-UC Inventory Staff; DR-02/04; GB-04.

1. Chọn PO và chuyến giao; tạo GR nháp. Tải các dòng, xác nhận và số còn thiếu hiện tại; chưa tăng tồn.
2. Ghi số thực nhận, đơn vị, lô, tone, calibre, bao bì/tình trạng. Chia mỗi dòng thành các phần accepted, pending, damaged và rejected; ghi nguyên nhân, ảnh/chứng từ nếu có lệch.
3. Đối chiếu tổng các phần phân loại bằng lượng thực nhận. Nếu cùng sản phẩm nhưng khác lô hoặc chất lượng, tách dòng. Không biến lượng thiếu so với PO thành hàng thực nhận.
4. Inventory Staff xác nhận UC-26. Máy chủ kiểm tra PO/version, quyền kho, conversion và từng lượng hợp lệ; post một lần vào interim cùng trạng thái thích hợp; cập nhật số lượng PO; ghi stock movement.
5. Tạo put-away TO cho phần đã post, chỉ định bin đích, lô, chất lượng và số lượng còn cần xếp. Tạo TO không tăng tồn lần hai.
6. Nhân viên chuyển hàng vật lý, xác nhận UC-33 theo lượng thực đặt. Trừ interim và cộng bin đích bằng cùng lượng. Chỉ phần accepted đủ điều kiện sau đặt vị trí mới được phát hành cho sử dụng/bán.
7. Pending, damaged hoặc rejected được cách ly và chuyển hồ sơ xử lý thích hợp. Không “làm sạch” chất lượng bằng cách di chuyển vào bin usable.

Ngoại lệ: không có phần đạt vẫn lưu sai lệch và trao đổi NCC; không xóa GR để mất bằng chứng. Chưa có bin hợp lệ thì giữ interim và tác vụ put-away mở. Không đủ lượng interim do thao tác khác thì chặn xác nhận. Nhấn xác nhận lại trả kết quả cũ, không ghi stock movement mới. [TK] Khi hỗ trợ put-away nhiều lần, mỗi lần là một execution riêng, tổng xác nhận không vượt nguồn còn lại.

### 5.3 F06 Di chuyển vị trí trong cùng kho

Nguồn: UC-34–37, SC-12, DR-05/06.

Điều kiện: nguồn và đích active, khác nhau, cùng kho; nguồn có đúng lô/trạng thái và đủ lượng hợp lệ. Inventory Staff tạo movement dự kiến → hệ thống kiểm tra → nhân viên di chuyển thực tế → nhập actual quantity → xác nhận UC-37. Ghi giảm nguồn và tăng đích trong một giao dịch, lưu lượng trước/sau cả hai phía, tổng kho giữ nguyên.

Không đủ nguồn hoặc đích inactive thì không post bên nào. Kho đích khác kho nguồn phải dùng F07. Không tự đổi quality status trong luồng này; di chuyển hàng cách ly phải là bước được phép của quy trình hàng lỗi/trả hàng. Chứng từ nháp không được thể hiện như tồn đã chuyển.

### 5.4 F07 Chuyển kho và xử lý chênh lệch

Nguồn: D-P36 TO BE; UC-38–44; SC-13; DR-07; GB-07.

1. Inventory Staff lập Transfer Request với kho nguồn/đích, sản phẩm/lô, lượng, lý do và thời gian dự kiến.
2. Owner duyệt nhu cầu. Từ chối thì lưu lý do và kết thúc yêu cầu; không thay tồn.
3. Tạo Warehouse Transfer Order từ TR đã duyệt, chọn vị trí và lượng nguồn còn đủ điều kiện. Tạo TO chưa post tồn.
4. Trong UC-43, xác nhận thực xuất nguồn: kiểm tra lượng thực, lô, chất lượng, người giao, thời điểm và bằng chứng; giảm nguồn, tăng In Transit một lần.
5. Ghi checkpoint bàn giao/vận chuyển: người nhận, lượng bàn giao, thời điểm, tình trạng và bằng chứng. Không giảm nguồn thêm lần nữa ở checkpoint này.
6. Kho đích kiểm đếm, kiểm tra và ghi lượng thực nhận từng lô/chất lượng. Giảm phần In Transit tương ứng và ghi nhận phần thực nhận hợp lệ tại đích; phần chưa nhận vẫn được truy vết.
7. Khớp toàn bộ thì xác nhận vị trí đích, hoàn tất. Có thiếu/thừa/sai lô/hỏng thì ghi difference, nguyên nhân, bằng chứng và đề xuất resolution; giữ TO mở.
8. Owner xem và duyệt/từ chối UC-44. Duyệt chỉ cho phép thực hiện phương án, chưa post số dư. Nếu từ chối, Inventory Staff sửa đề xuất; không tự ghi mất hàng hoặc đóng TO.
9. Inventory Staff thực hiện phương án đã duyệt trong UC-43, cập nhật tồn/In Transit đúng phần được giải quyết; lưu liên kết approval và execution. Chỉ đóng khi mọi lượng đã xuất có kết quả đối chiếu.

Ví dụ: xuất 100, bàn giao 100, đích nhận 95 gồm 92 tốt và 3 hỏng. Kho nguồn giảm 100; đích ghi 92 tốt và 3 cách ly; còn 5 In Transit/chênh lệch chưa giải quyết. Không tự nhận đủ 100 hoặc tự loại bỏ 5. Quyết định được duyệt xử lý 5 thiếu mới giải phóng phần treo tương ứng. Hư hỏng 3 không được cấp cho bán.

Ngoại lệ: chưa duyệt TR, xuất quá nguồn, nhận vượt lượng còn đi đường, lô khác hoặc chứng từ stale đều bị chặn hoặc đưa vào hồ sơ lệch. Lượng thừa thực tế phải ghi bằng chứng; không tự sinh tồn sở hữu không có nguồn. [TK] Tách quyền nguồn/đích theo assigned warehouse trong từng checkpoint, không cấp quyền thao tác toàn bộ hai kho chỉ vì được xem TO.

### 5.5 F08 Cách ly và xử lý hàng lỗi

Nguồn: UC-63–67; SC-11; BF02; GB-04.

1. Inventory Staff phát hiện hỏng, ghi sản phẩm/lô/vị trí, lượng, nguyên nhân, chứng từ gốc và bằng chứng.
2. Cách ly lượng ảnh hưởng khỏi usable; nếu là hàng đã có trong tồn, chỉ đổi chất lượng/vị trí, chưa tiêu hủy. Nếu chưa ghi nhận sở hữu, giữ hồ sơ vật lý riêng.
3. Đề xuất disposition và lượng: phục hồi/chấp nhận lại khi đủ điều kiện, tiếp tục giữ cách ly, trả NCC hoặc loại bỏ nếu được cho phép. Danh mục kết quả chi tiết là [CXC-05].
4. Owner duyệt/từ chối UC-66, ghi lý do khi từ chối. Bị từ chối thì sửa đề xuất, tiếp tục giữ cách ly.
5. Inventory Staff thực hiện UC-67 trên đúng phiên bản đã duyệt, nhập actual handled quantity và trạng thái cuối. Không vượt lượng duyệt hoặc lượng đang cách ly.
6. Post tác động theo phương án; chuyển chất lượng không giảm tổng tồn, loại bỏ giảm tồn một lần; trả NCC đi qua F11, không giảm ở cả disposition lẫn dispatch.

Kết thúc khi lượng liên quan đã có kết quả và history. Approval, đơn thuần mở hồ sơ hoặc đính kèm ảnh không được làm thay đổi số dư. Trường hợp phục hồi usable phải có quyết định và kiểm tra thích hợp; không sửa trực tiếp lô để bỏ trạng thái lỗi.

## 6 Luồng bán hàng và trả hàng

### 6.1 F09 SO đến PGI và hóa đơn nội bộ

Nguồn: D-UC Sales Staff, Inventory Staff, Accountant, Store Owner; UC-45–62; SC-16/17/22/23/26; GB-NEW-03/04.

1. Sales Staff chọn khách hàng, sản phẩm, đơn vị, lượng dương, đơn giá và ngày dự kiến. Hệ thống hiển thị khả dụng và cảnh báo giá, tính thành tiền từ số lượng và giá nhập. Lưu SO; không thu tiền, không tạo công nợ, không thêm bước Owner duyệt SO.
2. Sales Staff tạo Outbound Delivery từ phần SO chưa hoàn tất, chọn kho và lượng giao. Kiểm tra phần đã cấp cho các OD đang mở; không vượt outstanding và không trừ kho ở bước này.
3. Inventory Staff mở OD thuộc kho được phân công, lập picking TO, chọn bin/lô usable và lượng. Không gộp tone/calibre khác nhau thành một dòng không thể truy vết.
4. Thực hiện lấy hàng và ghi lượng thực lấy. Thiếu/hỏng/sai lô thì ghi trong UC-55, chọn lại phần hợp lệ hoặc giảm lượng; không tự ép đủ yêu cầu. Xác nhận picking chuyển nguồn → staging; tổng kho không đổi.
5. Kiểm tra lượng tại staging, đóng gói/bàn giao và bằng chứng. Thực hiện PGI ở UC-58 trên lượng thực xuất không vượt phần picked còn chưa xuất hoặc outstanding của OD/SO.
6. PGI giảm staging một lần, cập nhật issued/delivered và outstanding; lưu Goods Issue, movement và quan hệ từng dòng SO → OD → picking → issue.
7. Accountant chọn phần issue đã post và chưa được lập hóa đơn, lấy khách hàng/sản phẩm/giá đã chụp của SO; lập nháp hóa đơn nội bộ. Kiểm soát các nháp đồng thời để không lập trùng cùng lượng.
8. Accountant phát hành UC-62: cấp số duy nhất, đóng băng khách hàng, sản phẩm, số lượng, đơn giá, thành tiền và nguồn. Tạo yêu cầu PDF/in, sự kiện email trong cùng kết quả nghiệp vụ bền vững.
9. Owner/Accountant được xuất/in hóa đơn đã phát hành theo quyền. Xuất lại PDF lấy snapshot cũ, không cấp số mới, không phát sinh thêm lần issue hóa đơn hoặc trừ tồn.
10. Worker gửi thông báo trạng thái qua SMTP sau commit. Email/PDF lỗi được retry độc lập, không rollback PGI hoặc hóa đơn đã phát hành.

Nhánh sửa/hủy SO: Sales Staff chỉ sửa phần chưa được hoàn tất và chưa bị chứng từ phụ thuộc ràng buộc. Không sửa lượng đã xuất hoặc giá hóa đơn đã phát hành. [TK] Nếu phần chưa xuất đã phân vào OD/picking, phải giải phóng allocation và xử lý hàng staging có chứng từ trước khi cho hủy; nguồn chưa có UC hủy OD/picking riêng nên không mở nút hủy tự do cho dữ liệu này (CXC-07).

Nhánh giao thiếu: chỉ PGI số thực giao, giữ outstanding còn lại, được tạo OD tiếp theo nếu hợp lệ. Không xem giảm quantity trên SO là cách xử lý lịch sử giao thiếu. Nhánh xuất sai đã post: không xóa Goods Issue; nguồn chưa xác định quy trình đảo PGI nên phải xử lý qua quy trình được chốt, không tự thêm API đảo tồn (CXC-08).

Hậu điều kiện: mỗi lần trừ tồn có Goods Issue; mỗi lượng billed có source issue; hóa đơn immutable; SO/OD thể hiện phần còn lại; không có payment/debt ledger. [TK] Việc tính số tiền sử dụng Decimal128 và quy tắc làm tròn thống nhất; không tự thêm VAT, chiết khấu hay điều kiện thanh toán chưa có trong phạm vi.

### 6.2 F10 Khách trả hàng và hoàn tiền bên ngoài

Nguồn: UC-68–78; SC-18/27; R1 Proposed customer return; D-UC Inventory Staff, Owner, Accountant.

**Phần nhận hàng trả**

1. Inventory Staff tìm SO, Goods Issue thực xuất và hóa đơn nếu đã có; ghi yêu cầu trả với sản phẩm/lô, lượng và lý do. Kiểm tra số đã xuất, các lần trả trước và yêu cầu đang mở.
2. Không có nguồn, vượt lượng hoặc không đủ điều kiện trả thì không nhận yêu cầu hợp lệ; lưu lý do theo luồng. Điều kiện thời hạn/bao bì cụ thể chưa có giá trị định lượng [CXC-03].
3. Owner duyệt UC-71 để cho phép nhận và kiểm tra. Duyệt này không đồng nghĩa chấp nhận mọi hàng trả, không tăng tồn và không duyệt hoàn tiền. Từ chối thì đóng yêu cầu, không đổi tồn.
4. Inventory Staff nhận vật lý, kiểm đếm, đối chiếu sản phẩm/lô/tone/calibre và phân loại trong UC-72. Lưu actual returned, phần được nhận lại và phần không phù hợp cùng bằng chứng.
5. Tách dòng usable, usable có điều kiện, pending/quarantine, damaged/write-off hoặc chờ trả NCC theo kết quả được phép. “Có điều kiện” chưa tự động sellable; điều kiện giải phóng phải rõ.
6. UC-73 xác nhận phần được chấp nhận nhận lại, chỉ định bin và chất lượng; post nhập trả một lần. Phần hỏng nhận vào sở hữu vẫn là tồn không dùng được; phần từ chối không được cộng vào usable.
7. Thực hiện placement/put-away cho phần đủ điều kiện; chỉ giải phóng sử dụng khi hoàn tất. Nhánh hỏng sang F08, nhánh chờ NCC sang F11. Đối chiếu toàn bộ phần trả với nguồn trước khi đóng phần kho.

**Phần hoàn tiền**

8. Accountant chọn return đã được chấp nhận và post, liên kết sale/invoice và bằng chứng thanh toán gốc bên ngoài. Lập refund request với số tiền, lý do và bằng chứng.
9. Tính eligibility trên giá trị phần trả được chấp nhận và lượng tiền thanh toán gốc được chứng minh; trừ các refund trước hoặc đang chờ. Có thể đã đóng trả hàng kho nhưng chưa đủ điều kiện hoàn tiền.
10. Owner duyệt đúng phiên bản và số tiền UC-77, hoặc từ chối có lý do. Duyệt chưa chuyển tiền.
11. Hoàn tiền thực tế thực hiện bên ngoài. Accountant dùng UC-78 ghi actual amount, thời gian, tham chiếu giao dịch và chứng minh hoàn tiền; kiểm tra không vượt approved/eligible và không trùng.
12. Lưu trạng thái completed một lần. Hóa đơn gốc giữ nguyên; không sửa giảm tổng tiền hóa đơn, không gọi ngân hàng, không sinh sổ thu chi hoặc công nợ.

[TK] Công thức kiểm soát theo cùng giao dịch gốc: cap = min(giá trị trả đã chấp nhận lũy kế, tiền gốc có bằng chứng); remaining = cap − refund completed − refund pending/approved khác. Khi hoàn tất request hiện tại, không trừ chính phần approved của nó hai lần. Cần kiểm tra cả cap toàn sale/payment lẫn phần return để một chứng từ thanh toán không dùng lặp trên nhiều yêu cầu. Cách định giá phần hỏng và refund hoàn tất thiếu số duyệt cần chốt (CXC-06); không tự áp hoàn 100% hoặc tạo phí khấu trừ.

Ngoại lệ: thiếu bằng chứng thanh toán gốc → chặn submit refund; chưa duyệt → chặn completion; ảnh tải lỗi → chưa coi bằng chứng tồn tại; hai kế toán cùng ghi → chỉ một completion hợp lệ; mã giao dịch bị dùng lại → kiểm tra/chặn trùng theo nguồn chứng minh. Hàng đã nhận trả không được nhập lại lần nữa khi refund completed.

### 6.3 F11 Trả nhà cung cấp

Nguồn: UC-79–83; SC-19; R1 Proposed supplier return; DR-12; D-UC Inventory Staff và Owner.

1. Inventory Staff lập supplier return gắn NCC, PO/GR gốc, sản phẩm, lô, vị trí, lượng, lý do và bằng chứng. Xác định rõ phần đã ghi sở hữu và phần chưa từng nhập tồn.
2. Cách ly/giữ phần chọn khỏi usable để sales/chuyển kho không dùng. Không giảm tổng tồn chỉ vì lập yêu cầu.
3. Liên hệ NCC bên ngoài, ghi số lượng NCC chấp nhận và kế hoạch trả. NCC từ chối thì hủy theo kết quả, giải phóng phần giữ sau kiểm tra chất lượng; hàng hỏng vẫn cách ly. NCC nhận ít hơn thì giảm phần xuất dự kiến, lưu cách xử lý phần còn lại.
4. Inventory Staff lấy và đếm đúng lô/vị trí. Không khớp thì kiểm tra lại và đếm lại; không post đến khi lượng thực và chấp thuận phù hợp.
5. UC-82 ghi thực xuất, người bàn giao, thời điểm, bằng chứng. Trừ một lần phần thuộc tồn sở hữu, giải phóng giữ tương ứng; phần rejected tại GR chưa vào tồn chỉ cập nhật theo dõi vật lý/giữ hộ.
6. Ghi NCC xác nhận nhận thực tế. Đối chiếu dispatched và acknowledged từng lô. Thiếu/hỏng/sai lô phải để hồ sơ mở, bổ sung bằng chứng và phương án thống nhất.
7. Hàng thực sự gửi trả lại cửa hàng chỉ được ghi tăng khi đã về và kiểm tra lại qua nghiệp vụ thích hợp, không tăng chỉ vì NCC chưa xác nhận.
8. Owner xem số xuất, số NCC nhận và các phần đã xử lý; UC-83 duyệt đóng chỉ khi toàn bộ lượng có kết quả. Đóng không trừ tồn thêm lần nữa.

Không triển khai đối trừ công nợ, thanh toán NCC hoặc bút toán kế toán mua. Chứng từ điều chỉnh do NCC gửi được giữ như bằng chứng đối chiếu nếu cần. [TK] Supplier-return state tách dispatch completion và closure, vì NCC có thể xác nhận sau ngày xuất.

## 7 Kiểm kê và vận hành hỗ trợ

### 7.1 F12 Kiểm kê và Clear Difference

Nguồn: UC-84–93; D-UC Owner/Inventory Staff; R3 BF-04 đã cập nhật, GB-08/09 và GB-NEW-06/07.

1. Owner lập session, kho/khu/vị trí/lô thuộc phạm vi, thời gian và người đếm ở UC-86. Chưa tạo số liệu đếm giả và chưa đổi tồn.
2. Inventory Staff được phân công bắt đầu UC-87; tạo snapshot bất biến tại cutoff theo warehouse/location/product/lot/quality. Bắt đầu lại dùng snapshot đã có.
3. Đếm vật lý, nhập số lượng và conversion. Giá trị 0 là xác nhận đã đếm không thấy hàng; ô trống là chưa đếm. Mỗi attempt giữ counter, thời gian, số lần, ghi chú và bằng chứng.
4. Nếu cần đếm lại, thêm attempt; không ghi đè lần trước. Chọn rõ attempt dùng để đối chiếu từng dòng.
5. UC-88 chuẩn hóa đơn vị và đối chiếu cùng thời điểm, nhận diện các dịch chuyển phát sinh sau cutoff. Snapshot không khóa mọi giao dịch kho; các phát sinh phải được giữ và giải thích.
6. Còn dòng chưa đếm hoặc chưa xác định được timing movement thì giữ session mở. Khi thay attempt được chọn, kết quả reconciliation cũ hết hiệu lực.
7. Không còn lệch: đóng session, không sinh adjustment hoặc stock movement.
8. Có lệch thực: Inventory Staff tạo UC-91 với delta có dấu, snapshot/count/reconciliation version, lô/vị trí/chất lượng, lý do và evidence. Chặn delta 0 hoặc yêu cầu trùng cùng variance.
9. Owner kiểm tra UC-92 và duyệt đúng phiên bản. Chưa đủ bằng chứng thì chưa duyệt và giữ unresolved; không tự thêm chu trình reject/rework kiểm kê như quy định bắt buộc. Approval không đổi tồn.
10. Owner thực hiện riêng UC-93 Clear Difference. Kiểm tra approval, version và unposted; cộng delta vào số dư hiện tại, ghi before/after và movement atomically. Chỉ đóng session khi hết mọi chênh lệch chưa xử lý.

**Cách đối chiếu thời gian [TK]**

Đặt B0 là book quantity lúc cutoff, Ct là count của attempt được chọn tại thời điểm t, Mt là tổng movement có dấu sau cutoff đến t đã thực sự tác động đến phần hàng được đếm. Khi timing đã xác nhận: delta = Ct − (B0 + Mt). Lúc clear ở thời điểm p: B_after = B_current(p) + delta. Không dùng B_after = Ct.

Ví dụ minh họa: B0 = 100; trước lúc đếm có xuất 10, Ct = 88 → delta = 88 − 90 = −2. Sau đếm nhập thêm 20, book hiện tại 110 → clear ra 108. Ghi đè 88 sẽ làm mất 20 hàng nhập sau đếm. Nếu kiểm đếm kéo dài, mỗi dòng phải giữ thời điểm/count interval và movement liên quan; không dùng một Mt chung khi các dòng được đếm ở thời điểm khác nhau.

Ngoại lệ: stock update đồng thời → thử lại sau đọc phiên bản mới; negative balance sau delta → chặn và yêu cầu đối chiếu; count/version đã đổi → approval cũ không được dùng; Inventory Staff gọi thẳng clear → từ chối dù request đã approved; nhấn clear lặp → trả posting cũ. Hàng không có trong snapshot nhưng được đếm thấy cần dòng đối chiếu có book 0 và evidence, không bỏ qua vì không nằm trong danh sách ban đầu [TK].

### 7.2 F13 Báo cáo và truy vết

Nguồn: UC-99–102, SC-20/21; R3 IV.

Năm nhóm báo cáo: luân chuyển/tổng hợp nhập xuất tồn; tồn theo lô/vị trí; mua/nhận; chuyển kho; kiểm kê. Người dùng chọn nhóm và bộ lọc được phép, khoảng thời gian và kho; máy chủ kiểm tra scope, tính từ chứng từ/movement đã commit; hiển thị hoặc xuất kết quả cùng thời điểm dữ liệu. Không đưa các chứng từ nháp vào tổng lượng đã post.

| Nhóm | Nội dung cần thể hiện |
|---|---|
| Luân chuyển | Tồn đầu, các loại nhận/xuất/chuyển/điều chỉnh, tồn cuối; nguồn, operator và thời điểm |
| Tồn lô/vị trí | Sản phẩm, lot/tone/calibre, kho/bin, quality, physical/usable; tách In Transit |
| Mua và nhận | Ordered, confirmed, actual delivered, accepted, rejected, outstanding, phần đóng được duyệt; các GR |
| Chuyển kho | Request/TO, nguồn/đích, dispatch/handover/receipt, In Transit còn lại, discrepancy và approval |
| Kiểm kê | Scope/cutoff, snapshot, attempts, attempt được chọn, intervening movements, delta, approval/clear |

Truy vết lô bắt đầu từ product/lot → các GR → put-away/di chuyển → issue/chuyển kho → trả/hàng lỗi → điều chỉnh. Mỗi nhánh vẫn phải lọc quyền; Accountant không được mở phần bán chỉ vì lần theo cùng lô. Tổng báo cáo phải đối chiếu với ledger cùng phạm vi và cùng thời điểm chốt dữ liệu; không cộng cả movement đôi nội bộ thành doanh số xuất/nhập ngoài.

### 7.3 F14 Thông báo và tài liệu bằng chứng

Nguồn: R3 API-01/JOB-01, UC-62/78; D trang 37 Trung Context Diagram.

1. Sau một thay đổi trạng thái order/invoice thành công, ghi event có business document, phiên bản, loại sự kiện và đích nhận theo cấu hình được duyệt.
2. Worker nhận sự kiện chưa gửi, kết xuất nội dung từ dữ liệu snapshot hợp lệ, gửi SMTP bằng credentials phía máy chủ; ghi thời điểm và kết quả.
3. Thất bại lưu lastError/attemptCount/nextAttemptAt; retry có giới hạn cấu hình. Thành công đã biết không gửi lặp. Không chạy lại nghiệp vụ tạo event để “gửi lại email”.
4. Nếu timeout sau khi SMTP có thể đã nhận thư, kết quả giao thư là chưa chắc chắn. [TK] Dùng Message-ID ổn định, trạng thái deliveryUnknown và đối soát; SMTP thuần không đảm bảo tuyệt đối thư chỉ xuất hiện một lần trong mailbox.
5. Cloudinary được dùng theo sơ đồ cho upload evidence và trả asset URL/status. [TK] Backend kiểm tra quyền bản ghi trước khi cho tải lên, lưu asset identifier, loại tệp, người tải và liên kết chứng từ; quyền truy cập tệp phải tương ứng quyền hồ sơ.
6. Upload lỗi không đánh dấu evidence thành công. Chứng từ cần evidence bắt buộc không được hoàn tất chỉ vì đã nhập một URL. PDF hóa đơn lấy từ issued snapshot và trả qua tải được xác thực.

Không tự gửi PO cho NCC bằng SMTP: nguồn chỉ xác định order/invoice status notification và các hành động liên hệ NCC ngoài hệ thống. Danh sách status kích hoạt, người nhận, mẫu email, cơ chế retry và giới hạn file là [CXC-09].

## 8 ERD và thiết kế dữ liệu

### 8.1 ERD chuẩn từ Report 3

Hình dưới được trích trực tiếp từ bản Report 3 trực tuyến do người sử dụng cung cấp, tại mục I.3.1. Giữ nguyên tên hộp và quan hệ như trong hình; không thay bằng ERD của draw.io.

![ERD gốc trong Report 3](WMSD_ERD_tu_Report3.png)

Hình gồm 14 thực thể: Replenishment Request, Purchase Order, Supplier, Goods Receipt, Product, Transfer Order, Transfer Request, Inventory Balance, Warehouse, Stocktake, Goods Issue, Customer Return, Supplier Return và Inventory Adjustment. Hình không ghi đầy đủ thuộc tính, PK/FK hoặc bội số; vì vậy bảng quan hệ phía dưới là diễn giải triển khai [TK], không phải bội số nguyên văn từ hình.

Phần chữ R3 I.3.2 lại liệt kê 15 thực thể, có Lot, Location, Defective Goods Case, Warehouse Transfer và Goods Return gộp, trong khi hình tách Transfer Request/Order và hai loại Return. Thiết kế giữ 14 thực thể của hình ở lớp khái niệm; bổ sung cấu trúc phục vụ lô, vị trí, hàng lỗi và các UC mới ở lớp triển khai. Không bỏ truy vết lô/vị trí chỉ vì hình chưa vẽ chúng.

| Quan hệ trong hình | Diễn giải triển khai và ràng buộc [TK] |
|---|---|
| Replenishment Request — fulfilled by — Purchase Order | PO phải gắn đề nghị được duyệt; số PO tối đa/đề nghị chưa được hình xác định, cần CXC-01 |
| PO — received through — GR | Một PO có nhiều GR; mỗi GR nhà cung cấp tham chiếu một PO; mỗi dòng GR tham chiếu dòng PO |
| Supplier — receives — PO | Diễn giải nghiệp vụ: NCC nhận đơn đặt từ cửa hàng; mỗi PO chọn một NCC, NCC có nhiều PO |
| GR — receives — Product | Quan hệ nhiều sản phẩm trong một GR được triển khai bằng lines; sản phẩm có thể có nhiều lần nhận |
| Product — tracked in — Inventory Balance | Mỗi balance nhận dạng thêm lot/location/quality theo yêu cầu chữ; không chỉ một balance mỗi sản phẩm |
| Inventory Balance — holds — Warehouse | Balance thuộc kho, location thuộc đúng kho đó; kho có nhiều balance |
| Transfer Order — executed by — Transfer Request | Giữ nhãn nguyên hình; về luồng UC-40–43, TO được tạo từ TR đã duyệt để thực thi yêu cầu |
| Transfer Request — source/destination — Warehouse | Mỗi TR có nguồn và đích khác nhau thuộc cửa hàng |
| Warehouse — scopes — Stocktake | Session thuộc phạm vi kho/vị trí được định nghĩa; snapshot giữ phạm vi tại cutoff |
| Stocktake — reconciled through — Inventory Adjustment | Không lệch thì không có adjustment; có lệch có thể có nhiều dòng/yêu cầu, không trùng variance |
| Product — issues — Goods Issue | Issue lines giữ product/lot/location và source OD/picking; chỉ actual issue làm giảm tồn |
| Goods Issue — original issue for — Customer Return | Return lines tham chiếu đúng issue line, kiểm tra cộng dồn theo lượng đã xuất |
| Supplier — receives — Supplier Return | Supplier Return gắn NCC và nguồn GR/PO theo UC-81 dù hình chưa nối đủ các đường nguồn |

### 8.2 Kiến trúc dữ liệu MongoDB

R3 chỉ định MongoDB, ObjectId, UTC Date, Boolean và Decimal128. Tên collection/field, index và lựa chọn nhúng dưới đây là [TK]. Không chuyển ERD thành schema SQL có khóa ngoại giả định. Máy chủ kiểm tra ObjectId tham chiếu, trạng thái và phạm vi; MongoDB reference không tự bảo đảm toàn vẹn như ràng buộc FK.

Quy ước chung: _id, documentNo khi có mã chứng từ, status, version:Int64, createdAt/By, updatedAt/By; sourceRefs trỏ chứng từ và lineId; evidenceIds chỉ lưu tham chiếu có kiểm soát. Số lượng và tiền dùng Decimal128; timestamp lưu UTC, giao diện hiển thị Asia/Ho_Chi_Minh. Snapshot giữ nội dung khi phát sinh, không tải tên/giá/conversion mới để thay lịch sử. Dòng chứng từ có lineId ổn định, không dùng thứ tự mảng làm khóa nguồn.

| Thực thể ERD | Collection và dữ liệu thiết yếu [TK] |
|---|---|
| Replenishment Request | replenishment_requests: lines(productId, quantity, unit, reason, referenceStock), submittedVersion, decision, decisionBy/At |
| Purchase Order | purchase_orders: requestId, supplierId, warehouseId, lines(ordered, confirmed, accepted, closedQty), confirmationHistory, expectedDates, closureApproval, reconciliationRefs |
| Supplier | suppliers: code, name, contact, address, active, audit; không chứa sổ công nợ |
| Goods Receipt | goods_receipts: poId, deliveryReference, warehouseId, lines(sourcePOLineId, productId, lotId, actual, classifications, ownershipRecorded), inspection, postingId |
| Product | products: code, name, category, brand/material/dimensions khi phù hợp, baseUnit, packagingVersions, active |
| Transfer Request | transfer_requests: sourceWarehouseId, destinationWarehouseId, lines, reason, expectedAt, approval, approvedVersion |
| Transfer Order | transfer_orders: type, sourceRef, lines(sourceBin, targetBin, lotId, quality, plannedQty), executionIds, status; type phân biệt put-away/picking/warehouse transfer |
| Inventory Balance | inventory_balances: warehouseId, locationId, productId, lotId, qualityStatus, quantity, reservedQty, version, lastMovementId |
| Warehouse | warehouses: code, name, active; nhân viên được gán phạm vi bằng cấu trúc quyền, không thêm vai trò kho mới |
| Stocktake | stocktakes: scope, assignees, plannedAt, cutoffAt, snapshotVersion, reconciliationVersion, status; attempt/snapshot lớn lưu collection riêng |
| Goods Issue | goods_issues: purpose, sourceOD/sourceSupplierReturn, lines(pickedRef, sourceLineId, lot, bin, actualQty), dispatchEvidence, postingId |
| Customer Return | customer_returns: sale/issue/invoice refs, requestedLines, review, inspectionLines, accepted/classifiedQty, receiptPostingIds, status |
| Supplier Return | supplier_returns: supplierId, po/gr refs, lines, isolatedQty, supplierAcceptedQty, dispatchedQty, acknowledgedQty, discrepancy, closureDecision |
| Inventory Adjustment | inventory_adjustments: stocktakeId, varianceKey, snapshot/count/reconciliation versions, signedDelta, reason/evidence, approvedVersion, postedBy/At, postingId |

Warehouse Transfer là nghiệp vụ phối hợp TR/TO, executions và In Transit; không nhất thiết thêm một collection trùng toàn bộ TO. Goods Return gộp trong phần chữ được biểu diễn bằng hai collection đúng hai hộp ERD. Goods Issue với purpose supplier return chỉ là tái sử dụng hạ tầng ghi giảm [TK], không tạo luồng bán cho trả NCC.

### 8.3 Cấu trúc bổ sung từ yêu cầu chữ và UC

| Cấu trúc | Nội dung và lý do bổ sung |
|---|---|
| lots | productId, lotNo, tone, actualCalibre, productionDate, master version; UC-14–16, DR-01 |
| locations | warehouseId, code, area/aisle/rack, type, active, capacity nếu có; UC-27–29 |
| defective_cases | nguồn, lot/location, quantity, reason/evidence, proposalVersion, approval, execution; UC-63–67 |
| customers | thông tin liên hệ và mã khách; UC-20–22 |
| selling_prices | productId, unit, finalPrice, effective dates, optional externalMargin, history; UC-23–25 |
| sales_orders | customer snapshot, line quantities/prices, issued/cancelled/allocation, version; UC-45–48 |
| outbound_deliveries | saleId, sourceLineId, warehouse, planned/picked/issued và allocation; UC-49–51 |
| internal_invoices | source issue line allocations, draft/issued, unique invoiceNo, immutable snapshot, pdfRef, issue event; UC-59–62 |
| refund_requests | accepted return/source sale/payment evidence refs, requested/approved/completed amounts, decisionVersion, completionKey; UC-74–78 |
| stock_movements | postingId, movementType, source document/line, balanceKey, delta, before/after, actor/UTC, reason; UC-100–102 |
| transfer_executions và transit_balances | checkpoint, actual quantities, dispatcher/receiver, evidence, unresolved delta; UC-43 |
| stocktake_snapshots, count_attempts | immutable B0, cutoff; mỗi attempt với line/countTime/unit/conversion; UC-87 |
| reservations và allocations | giữ quyền sử dụng số lượng vật lý, OD quantity, invoice quantity hoặc refund cap; cơ chế [TK] để thực hiện các giới hạn của UC |
| accounts, role_permissions | active, credential hash, role, warehouse scope, permissionVersion; UC-94–98 |
| approvals, audit_events | quyết định gắn documentVersion; audit cả thay master/quyền và trạng thái không tác động tồn |
| evidence_assets | storage provider/id, document access scope, content type, size, upload state, uploader; D trang 37 |
| outbox_events và operation_receipts | gửi email sau commit, chống lặp event và chống thực hiện lặp command; yêu cầu reliability R3 IV |

Đây là cấu trúc triển khai để bao phủ UC, không phải tuyên bố ERD gốc đã có đủ các thực thể này. Không thêm bảng thu tiền, công nợ hoặc thanh toán NCC.

### 8.4 Index và toàn vẹn [TK]

- Unique: product code; supplier/customer code theo quy tắc cấp mã; username chuẩn hóa; warehouse code; (warehouseId, locationCode).
- Unique balance: (warehouseId, locationId, productId, lotId, qualityStatus). Unique lot identity cần chốt phạm vi lotNo/tone/calibre, tránh mặc định lotNo duy nhất toàn cửa hàng.
- Unique posting: (documentType, documentId, executionId, postingKind). Một execution chuyển kho có nhiều chân ledger nhưng chỉ một kết quả nghiệp vụ; ledger thêm legId để phân biệt.
- Unique invoiceNo khi issued, không bắt các draft chưa có số cùng một giá trị null. Unique event: (documentId, version, eventType, recipientKey).
- Unique adjustment coverage: (stocktakeId, balanceKey, reconciliationVersion) cho yêu cầu đang hiệu lực/đã post; yêu cầu vô hiệu giữ lịch sử nhưng không chiếm hai lần variance.
- Index tìm kiếm: (warehouseId, status, createdAt), (supplierId, createdAt), (sourceRef.documentId, sourceRef.lineId), (lotId, postedAt, _id), (nextAttemptAt, status) cho outbox.
- Không dùng unique invoice sourceLineId đơn thuần nếu nghiệp vụ chia một issue line thành nhiều hóa đơn theo số lượng; cần allocation counter cập nhật atomically. Tương tự với trả một phần nhiều lần.
- Mảng lịch sử, count attempts và ledger có thể tăng lớn nên lưu riêng; document lines có kích thước giới hạn theo cấu hình triển khai. Không gắn mảng movement vô hạn vào Product.

### 8.5 Bắt buộc và chỉ đọc theo giai đoạn

| Giai đoạn | Dữ liệu bắt buộc | Dữ liệu do hệ thống cấp |
|---|---|---|
| Submit request | Ít nhất một dòng, quantity dương, reason, tham chiếu hợp lệ | Creator, submittedAt, version |
| Review | Record/version đang chờ, decision, reason khi từ chối | Approver, approvedAt, approvedVersion |
| Inspection | Actual quantity, lot/đặc tính, từng quality quantity, điều kiện/evidence theo tình huống | Tổng phân loại, chênh so nguồn |
| Post kho | Source line, actual quantity, kho/bin, chất lượng, approved ref khi cần | PostingId, before/after, movement, postedAt |
| Count | Quantity kể cả 0, attempt, thời điểm thực đếm | Snapshot/cutoff bất biến, attempt identifier |
| Clear | Approved adjustment hiện hành, đúng scope | Delta từ hồ sơ đã duyệt, không nhập lại delta tùy ý |
| Issue invoice | Posted unbilled issue, customer/price snapshot | Số hóa đơn duy nhất, issuedAt, snapshot hash [TK] |
| Refund completion | Approved request, amount/date, external reference và proof | CompletionKey, recorder, duplicate check |

Các trường balance, outstanding, số đã billed/refunded, người duyệt và audit không lấy từ client như sự thật; máy chủ tính/ghi từ nguồn đã lưu. Trường filter không được tự lưu vào chứng từ. Giới hạn chiều dài và enum cụ thể trong phần field description R3 là baseline kỹ thuật, cần thống nhất khi chốt hợp đồng API.

## 9 Trạng thái chứng từ

Tên mã trạng thái dưới đây là [TK], diễn đạt các giai đoạn trong nguồn. Không cho client tự PATCH status để đi tắt quy trình. Mỗi transition phải gắn hành động, quyền, tiền điều kiện và side effect đã quy định ở F01–F14.

| Đối tượng | Chuyển trạng thái chủ đạo | Điều kiện và tác động |
|---|---|---|
| Replenishment | Draft → Submitted → Approved hoặc Rejected; Rejected → Revised → Submitted | Accountant lập/sửa/trình, Owner quyết định; vòng trình lại theo D-P35; không tác động tồn |
| PO | Draft → AwaitingConfirmation → Confirmed → PartiallyReceived → Received → Reconciled → Closed | Accountant quản lý; mỗi GR cập nhật lũy kế; đường thiếu không giao tiếp đi qua RemainingClosurePending/Approved |
| GR | Draft → Inspected → Posted; các phần Pending/Rejected giữ trên line | UC-26 thực hiện kiểm tra và post; Posted là bất biến; chưa put-away vẫn là hàng ở interim |
| Put-away hoặc bin movement | Draft → Ready → PartiallyConfirmed → Confirmed | Các mã partial chỉ dùng nếu chia execution được chốt; mỗi confirm chuyển hai phía cân bằng |
| Transfer Request | Draft → Submitted → Approved/Rejected | Owner duyệt, rejected kết thúc không xuất |
| Warehouse TO | Ready → Dispatched → InTransit → Received hoặc DifferencePending → Resolved → Closed | Checkpoint riêng; discrepancy giữ mở; đóng khi transit/variance đã được giải thích |
| SO | Open → PartiallyIssued → Fulfilled; Cancelled/ClosedRemainder cho phần được hủy | Không đi từ fulfilled về draft; trạng thái billing được tính riêng, không sửa lịch sử PGI |
| OD và picking | OD Open → Picking → Staged → PartiallyIssued/Issued | Picking TO có Draft/Confirmed; PGI là transition riêng |
| Goods Issue | Prepared → Posted | Chỉ post lượng thực xuất đủ điều kiện một lần |
| Invoice | Draft → Issued | Issued không sửa; PDF Pending/Ready/Failed là trạng thái tài liệu phụ, không quay invoice về Draft |
| Defective case | Isolated → Proposed → Approved hoặc Rejected → Handled | Rejected có thể sửa proposal; approved version ràng buộc execution; xử lý một phần giữ remainder |
| Customer return | Requested → InspectionApproved/Rejected → Inspected → ReceiptPosted → Closed | Quy trình stock return độc lập refund; không lấy refund pending làm lý do nhập lại hàng |
| Refund | Draft → Submitted → Approved/Rejected → Completed | Accountant lập/ghi hoàn tất, Owner duyệt; không có trạng thái ngân hàng xử lý do WMSD thực hiện |
| Supplier return | Prepared/Isolated → SupplierAccepted → Dispatched → Acknowledged hoặc DifferencePending → ClosurePending → Closed | Chỉ Owner đóng; external acceptance không phải Owner approval của sơ đồ BF cũ |
| Stocktake | Planned → Counting → ReconciledNoDifference → Closed; hoặc ReconciledWithDifference → AwaitingClear → Closed | Không có movement nếu không lệch; snapshot từ lúc activate counting |
| Adjustment | PendingApproval → Approved → Posted/Cleared | Chưa đủ điều kiện thì giữ unresolved; không tự thêm nghiệp vụ reject vào UC-92 |
| Email | Pending → Sending → Sent/Failed/DeliveryUnknown | Retry bounded, không làm lại nghiệp vụ gốc |

Trạng thái header phải phản ánh các dòng. Ví dụ PO có một dòng còn thiếu không được Closed chỉ vì dòng khác đủ. Việc “kết thúc một lần chạy luồng” không có nghĩa chứng từ đã Closed; transfer bị từ chối resolution vẫn unresolved.

## 10 Kiến trúc ứng dụng và giao dịch

### 10.1 Phân tách thành phần [TK]

Triển khai ứng dụng web responsive và một backend chia module, dùng chung MongoDB và cơ chế post tồn. Không cần tự mở rộng thành nhiều microservice cho phạm vi một cửa hàng. Nguồn chưa chốt framework/ngôn ngữ, vì vậy thiết kế không gắn React, Java, .NET hay Node.js như yêu cầu bắt buộc.

Luồng tổng thể: trình duyệt → lớp xác thực và kiểm tra quyền → application command/query → module nghiệp vụ → transaction/posting service → MongoDB. Worker đọc outbox để gửi SMTP và xử lý tài liệu. Evidence adapter giao tiếp Cloudinary theo context diagram; PDF renderer lấy issued snapshot.

| Module | Trách nhiệm và ranh giới |
|---|---|
| Identity and Authorization | Tài khoản, session, role/operation, warehouse scope, field projection |
| Master Data | Sản phẩm, lô, quy cách, vị trí, NCC, khách và giá; không sửa số dư |
| Procurement and Receiving | Request/PO/GR, supplier confirmation, inspection và PO reconciliation |
| Inventory Execution | Put-away, location movement, TR/TO, transit, picking và posting dùng chung |
| Sales and Invoicing | SO/OD, điều phối PGI, draft/issued invoice, quantity allocation |
| Quality and Returns | Defect, hai loại return và refund evidence; không thực hiện thanh toán |
| Stocktake | Snapshot, attempt, reconciliation, approval và clear |
| Reporting and Audit | Truy vấn từ dữ liệu đã commit, kiểm tra scope theo từng nhóm báo cáo |
| Integration Worker | SMTP, PDF và bằng chứng; failure không lặp side effect nghiệp vụ |

### 10.2 Hợp đồng xử lý lệnh ghi [TK]

1. Nhận command cùng recordId, expectedVersion, idempotencyKey và các dòng dữ liệu thực nhập; xác thực tài khoản đang active.
2. Kiểm tra quyền hành động, scope kho/bản ghi và trường được phép. Không lấy actorId/approverId từ client làm danh tính.
3. Nếu key đã hoàn tất với cùng payloadHash, trả lại kết quả cũ. Cùng key nhưng payload khác trả conflict. Khóa side effect theo document/execution ngăn key mới ghi lại một lần post đã hoàn tất.
4. Đọc chứng từ/nguồn/số dư hiện hành; kiểm tra trạng thái, version, approval version, conversion, quantity, allocation và evidence cần thiết.
5. Trong transaction ngắn, cập nhật có điều kiện version và balance, ghi mọi chân stock movement, cập nhật chứng từ nguồn/đích, operation receipt và outbox event liên quan.
6. Commit tất cả hoặc rollback tất cả. Không giữ transaction trong lúc nhân viên kiểm hàng, upload file hoặc gọi SMTP.
7. Trả kết quả đã commit. Nếu mất kết nối khi chưa biết commit thành công hay không, tra theo idempotencyKey rồi mới thử lại; không tạo chứng từ khác để thay thế mù.

MongoDB hỗ trợ transaction nhiều document trên replica set hoặc sharded cluster; cơ chế atomic một document không đủ để tự bảo đảm balance, ledger và chứng từ ở các document khác nhau đồng thời nhất quán. Thiết kế chọn môi trường hỗ trợ transaction và unique index để kiểm soát posting. Nguồn kỹ thuật: https://www.mongodb.com/docs/v8.0/core/write-operations-atomicity/ . Đây là quyết định triển khai đáp ứng yêu cầu R3 IV, không mở rộng nghiệp vụ.

### 10.3 Cạnh tranh đồng thời và phục hồi

| Tình huống | Kiểm soát [TK] |
|---|---|
| Hai người cùng lấy 8 trong số 10 | Cập nhật có điều kiện quantity/reservation và version trong transaction; chỉ lệnh còn đủ nguồn được nhận |
| Hai GR cùng dùng phần thiếu PO | Kiểm tra/cập nhật counter PO trong cùng transaction với GR; không chỉ dựa số hiển thị cũ |
| Hai OD cùng lấy phần SO còn lại | Giữ allocation trên source line; tổng open + issued + cancelled không vượt ordered |
| Hai hóa đơn cùng dùng issue | Counter/claims billed và draft allocations; phát hành revalidate; unique invoiceNo |
| Hai refund dùng một payment proof | Giới hạn chung theo source payment/sale và return; claim số tiền khi submitted, chuyển trạng thái khi completed |
| Clear sau khi có nhập/xuất mới | Áp delta đã duyệt lên current balance; kiểm tra version và count version, không gán old count |
| Retry sau timeout | operation receipt + semantic posting key; không chỉ disable nút UI |
| Lỗi giữa cập nhật nguồn và đích | Rollback toàn transaction; không để một chân movement đã ghi một chân chưa ghi |
| Email/PDF thất bại sau issue | Giữ invoice Issued; retry tác vụ tài liệu, không issue lại |

Không sửa/xóa ledger đã post để sửa sai. Quy trình đảo chứng từ chưa nằm trong UC hiện tại phải được xác định trước khi triển khai; không thêm “admin sửa tồn” như lối phục hồi. Backup/restore phải khôi phục đồng bộ balance, document, ledger, operation receipts và outbox để retry không nhân đôi nghiệp vụ.

## 11 Hợp đồng API đề xuất

Toàn bộ đường dẫn ở mục này là [TK], dùng để chia việc backend/frontend, không phải API đang tồn tại. Endpoint bên ngoài chính thức của R3 là SMTP; đây là các API nội bộ ứng dụng. GET chỉ đọc, không post hoặc tự chuyển trạng thái.

### 11.1 Quy ước

Prefix /api/v1. ID là ObjectId chuỗi hợp lệ. Decimal truyền dưới dạng chuỗi thập phân để tránh sai số số thực nhị phân. Command có expectedVersion, idempotencyKey; line reference luôn có sourceDocumentId và sourceLineId. Phản hồi thành công gồm id, status, version, postingId khi có và warnings. Lỗi gồm code, message, fieldErrors, correlationId; không trả dữ liệu ngoài scope để giải thích lỗi.

| Nhóm | API chủ đạo | Quyền và UC |
|---|---|---|
| Access | POST /sessions; GET /accounts; POST/PATCH /accounts; POST /accounts/{id}/role-permissions | Đăng nhập 94; Admin 95–98 |
| Master | GET/POST/PATCH /products, /lots, /suppliers, /customers, /selling-prices, /locations; POST /{resource}/{id}/activation | Tách create/update/activate đúng UC-13/16/19/22/25/29 |
| Replenishment | GET/POST /replenishment-requests; POST /{id}/submit, /{id}/review | Accountant 03; Owner 04; [TK] revise giữ version |
| PO | GET/POST /purchase-orders; PATCH /{id}/unreceived-lines; POST /{id}/supplier-confirmations | Accountant 07; quyền đọc 05/06 |
| PO closure từ D-P35 | POST /purchase-orders/{id}/remaining-closure-review; /{id}/reconcile; /{id}/close | Owner review, Accountant reconcile/close; chưa có UC riêng |
| GR | GET/POST /goods-receipts; POST /{id}/inspect-and-post | Inventory Staff 10/26 |
| Put-away | POST /putaway-orders; POST /{id}/confirm | Inventory Staff 32/33 |
| Bin movement | GET/POST /location-movements; POST /{id}/confirm | Inventory Staff 36/37 |
| Transfer | POST /transfer-requests; /{id}/review; POST /warehouse-transfer-orders; /{id}/executions | Inventory Staff 40/42/43; Owner 41 |
| Transfer difference | POST /warehouse-transfer-orders/{id}/resolutions; /{id}/resolution-review; /{id}/resolution-executions | Staff đề xuất/thực hiện 43; Owner duyệt 44 |
| Sales | GET/POST /sales-orders; PATCH /{id}/unfulfilled-lines; POST /{id}/cancel-remainder | Sales Staff 47/48 |
| Outbound | GET/POST /outbound-deliveries; GET/POST /picking-orders; POST /picking-orders/{id}/confirm | Sales Staff 51; Inventory Staff 54/55 |
| PGI | GET /goods-issues; POST /outbound-deliveries/{id}/goods-issues | Inventory Staff 58; input gồm picked source và actual |
| Invoice | GET/POST /internal-invoices; POST /{id}/issue; GET /{id}/pdf | Accountant 61/62; Owner chỉ GET issued PDF |
| Defect | GET/POST /defective-cases; POST /{id}/proposals; /{id}/review; /{id}/execute | Inventory Staff 65/67; Owner 66 |
| Customer return | GET/POST /customer-returns; /{id}/review; /{id}/inspection; /{id}/confirm-receipt | Inventory Staff 70/72/73; Owner 71 |
| Refund | GET/POST /refund-requests; /{id}/review; /{id}/record-completion | Accountant 76/78; Owner 77 |
| Supplier return | GET/POST /supplier-returns; /{id}/supplier-acceptance; /{id}/dispatch; /{id}/acknowledgement; /{id}/closure-review | Inventory Staff 81/82; Owner 83 |
| Stocktake | GET/POST /stocktakes; /{id}/activate; /{id}/count-attempts; /{id}/reconcile | Owner 86; Inventory Staff 87/88 |
| Adjustment | GET/POST /inventory-adjustments; /{id}/approve; /{id}/clear | Inventory Staff 91; Owner 92/93 |
| Read models | GET /inventory-balances, /stock-movements, /lots/{id}/trace, /reports/{type} | Theo 30/31/99–102 và scope trường |
| Evidence | POST /evidence/upload-intents; POST /evidence/{id}/complete; GET /evidence/{id}/download | Quyền theo chứng từ cha; storage adapter theo D-P37 |

Các sub-endpoint checkpoint của UC-43 và UC-82 là tổ chức kỹ thuật bên trong một UC, không phải tách thành các UC nghiệp vụ mới. Không có endpoint chung nhận một status tùy ý rồi ghi đè.

### 11.2 Ví dụ command quan trọng [TK]

Command PGI gồm deliveryId, expectedVersion, idempotencyKey, lines với deliveryLineId, pickingExecutionLineId, lotId, stagingLocationId, actualQuantity, inputUnit, handoverEvidenceIds. Máy chủ lấy giá, người thực hiện, available staged và outstanding từ bản ghi; client không gửi balanceAfter để ghi trực tiếp.

Command Clear Difference gồm adjustmentId, expectedVersion, approvedVersion và idempotencyKey. Máy chủ tự lấy signedDelta, balanceKey, snapshot/count/reconciliation versions và approvedBy. Không nhận ô “số tồn mới” do người dùng nhập như giá trị có thẩm quyền.

Command Refund Completion gồm refundRequestId, approvedVersion, actualAmount, completedAt, externalReference, evidenceIds và idempotencyKey. Máy chủ kiểm tra cap và approval; không có bank account execution payload hoặc payment gateway call.

### 11.3 Mã lỗi

| Mã nguồn | Ý nghĩa tiếng Việt | Hành vi API [TK] |
|---|---|---|
| MSG-01 | Không có kết quả phù hợp | 200 với danh sách rỗng |
| MSG-02 | Thiếu trường bắt buộc | 422, trỏ trường thiếu, không commit |
| MSG-03 | Số lượng không hợp lệ/vượt lượng được phép | 422 hoặc 409 nếu số dư vừa thay đổi |
| MSG-04 | Không có quyền thao tác hoặc kho | 403; 404 khi cần tránh lộ bản ghi ngoài scope |
| MSG-05 | Bản ghi đã thay đổi, cần tải lại | 409, trả version mới chỉ khi có quyền đọc |
| MSG-06 | Đã thực hiện, không ghi lặp | Trả kết quả cũ cho retry hợp lệ; 409 nếu key/payload mâu thuẫn |
| MSG-07 | Chứng từ đã lưu nhưng email thất bại | Business success + notification warning, không rollback |

## 12 Danh mục quy tắc nghiệp vụ

Các quy tắc dưới đây tổng hợp nguồn và dùng làm checklist triển khai. Dấu [TK] chỉ cơ chế cụ thể hóa; không thay đổi quyền hoặc bổ sung chính sách kinh doanh chưa xác định.

| Mã | Quy tắc và nơi chặn | Truy vết |
|---|---|---|
| BR-01 | Mọi read/write kiểm tra quyền hành động, record và warehouse | GB-01, GB-NEW-01/02 |
| BR-02 | Tài khoản inactive không đăng nhập hoặc thực hiện lệnh mới | UC-94/97 |
| BR-03 | Chỉ năm vai trò; Admin không mặc nhiên làm nghiệp vụ | UC-98 |
| BR-04 | Quyền xem không bao hàm quyền ghi, duyệt, post, export | I.4.4, GB-AUTH |
| BR-05 | Master inactive không dùng cho giao dịch mới; lịch sử còn nguyên | DR-14, GB-02 |
| BR-06 | Không ngừng vị trí còn tồn ở bất kỳ quality hoặc còn movement mở | DR-05, UC-29 |
| BR-07 | Không gộp khác tone/calibre; balance theo lot/location/status | DR-01, UC-16/30 |
| BR-08 | Conversion theo sản phẩm, dương, snapshot không hồi tố | DR-02, GB-03 |
| BR-09 | Không tự tính giá từ margin hay thêm ngưỡng duyệt giá | UC-25/47, LI-08 |
| BR-10 | Chỉ PO từ đề nghị approved; sửa bị từ chối phải trình lại theo P35 | UC-03/04/07, D-P35 |
| BR-11 | PO chỉ sửa/hủy phần chưa nhận, giữ receipt history | DR-03, GB-05 |
| BR-12 | Mỗi chuyến giao có GR riêng; tạo GR không tăng tồn | UC-10 |
| BR-13 | Tổng phân loại kiểm hàng phải khớp lượng thực nhận từng dòng | UC-26 |
| BR-14 | Hàng chưa accepted không được đưa vào usable | DR-04, GB-04 |
| BR-15 | GR post ở interim một lần; put-away chỉ di chuyển, không nhập lần hai | UC-26/32/33 |
| BR-16 | Put-away giữ quality; chỉ phần đủ điều kiện được giải phóng | UC-33 |
| BR-17 | Chuyển bin cùng kho có hai chân cân bằng, tổng kho không đổi | DR-06, GB-06 |
| BR-18 | TR phải được Owner duyệt trước TO | UC-40–42, D-P36 |
| BR-19 | Dispatch, handover, receipt chuyển kho là ba checkpoint riêng | DR-07, GB-07 |
| BR-20 | Dispatch ghi In Transit; nhận chỉ giải phóng lượng đã đối chiếu | UC-43 |
| BR-21 | Chênh chuyển kho chưa xử lý thì không đóng; approval không tự post | UC-43/44 |
| BR-22 | SO không bắt buộc Owner duyệt; không thu tiền/công nợ | UC-47, LI-02 |
| BR-23 | OD không vượt phần còn lại, tính cả allocation đang mở | UC-51, SC-16 |
| BR-24 | Picking chỉ lấy lot/bin usable; staging vẫn nằm trong tổng kho | UC-54/55, GB-NEW-03 |
| BR-25 | PGI chỉ trừ actual dispatched, không vượt staged/outstanding | UC-58, GB-10 |
| BR-26 | SO sửa/hủy không làm mất chứng từ đã xuất hoặc hóa đơn | UC-48 |
| BR-27 | Chỉ issue đã post và chưa billed đủ điều kiện lập invoice | UC-61 |
| BR-28 | Invoice issued bất biến, số duy nhất, PDF từ snapshot | UC-62, GB-NEW-04 |
| BR-29 | Owner không issue invoice; chỉ export/print bản issued | UC-62 operation scope |
| BR-30 | Cách ly hàng lỗi ngay; không chờ duyệt rồi mới loại khỏi usable | UC-65 |
| BR-31 | Disposition phải approved, actual không vượt approved/cách ly | UC-66/67 |
| BR-32 | Không trừ tồn tại disposition trả NCC rồi trừ lại lúc dispatch | UC-67/82, DR-12; cụ thể hóa [TK] |
| BR-33 | Return khách gắn actual issue, cộng dồn không vượt lượng xuất | UC-70 |
| BR-34 | Owner duyệt nhận để kiểm tra trước inspection; không phải refund approval | UC-71/72 |
| BR-35 | Chỉ xác nhận phần nhận lại sau phân loại, không tự làm mọi hàng trả sellable | UC-73, GB-11 |
| BR-36 | Refund cần accepted posted return và payment proof gốc | UC-76 |
| BR-37 | Refund cap trừ cả prior/pending; Owner duyệt, Accountant ghi completion | UC-76–78, GB-NEW-05 |
| BR-38 | Refund không chuyển tiền và không sửa hóa đơn đã issue | UC-78 |
| BR-39 | Trả NCC phải ghi external acceptance trước dispatch | UC-81/82 |
| BR-40 | Hàng không từng nhập sở hữu không bị trừ tồn khi trả NCC | DR-12, GB-12 |
| BR-41 | NCC nhận thiếu thì giữ mở; chỉ hàng thực về và kiểm lại mới được tăng | R1 supplier return, UC-82 |
| BR-42 | Owner chỉ duyệt đóng trả NCC sau đối chiếu, không trừ thêm tồn | UC-83 |
| BR-43 | Snapshot tạo khi activate count, bất biến; không khóa toàn kho mặc định | UC-86/87, GB-08 |
| BR-44 | Trống khác 0; recount thêm attempt, không ghi đè | UC-87, GB-NEW-07 |
| BR-45 | Reconcile movement sau cutoff trước khi xác định delta | UC-88 |
| BR-46 | Không lệch thì đóng không adjustment; lệch phải có đề nghị rõ version | UC-88/91 |
| BR-47 | UC-92 approved không đổi tồn; chỉ Owner UC-93 mới clear | UC-92/93, GB-NEW-06 |
| BR-48 | Clear cộng delta lên current balance, giữ later movements | UC-93 |
| BR-49 | Không duplicate adjustment cho cùng variance; post at most once | UC-91/93, GB-09 |
| BR-50 | Mọi posting có source, user, time, before/after và reason | DR-13, GB-13 |
| BR-51 | Retry không lặp tác động; cập nhật liên quan atomic | R3 IV.2.4 |
| BR-52 | SMTP sau commit; lỗi mail không đảo chứng từ | API-01/JOB-01 |
| BR-53 | Không cấu hình chính sách, approval chain hoặc workflow tùy ý | GB-POLICY, LI-10 |
| BR-54 | Không còn giao PO thì Owner duyệt đóng phần thiếu, không tăng giả received | D-P35 |
| BR-55 | Đối chiếu chứng từ mua trước close, không mở module trả tiền NCC | D-P35, R1 LI-02 |
| BR-56 | Không tự coi quantity thực nhận vượt nguồn là quantity đủ điều kiện | UC-26/43/73; ràng buộc nguồn [TK] |
| BR-57 | Báo cáo, truy vết, export và evidence cùng data scope | UC-99–102, GB-AUTH |
| BR-58 | Tồn khả dụng không âm; không lấy balance tổng để vượt lot/bin | DR-10; reservation [TK] |

## 13 Màn hình và thiết kế tương tác

Tất cả màn hình dùng cùng cấu trúc: bộ lọc → danh sách → chi tiết → các hành động có quyền. Chi tiết gồm nguồn chứng từ, dòng hàng, trạng thái/quantity, lịch sử thao tác và bằng chứng. Khu vực duyệt hiển thị đúng phiên bản được duyệt; khu vực post hiển thị lượng thực và tác động dự kiến trước khi xác nhận. Không gộp nút Approve với Post/Clear.

| Màn hình | Nội dung và nhóm thao tác |
|---|---|
| SC-01 | Đăng nhập |
| SC-02 | Tài khoản và quyền; tách duy trì tài khoản với gán role/operation |
| SC-03 | Sản phẩm và quy cách đơn vị |
| SC-04 | Lô sản phẩm, tone/calibre |
| SC-05 | NCC; tách sửa thông tin và đổi active |
| SC-06 | Đề nghị bổ sung và quyết định Owner |
| SC-07 | PO, supplier confirmation, receipt history, outstanding, closure theo D-P35 |
| SC-08 | GR, inspection, phân loại và put-away |
| SC-09 | Kho/vị trí, trạng thái, tồn tại bin |
| SC-10 | Tồn theo lô/vị trí/chất lượng, field projection theo vai trò |
| SC-11 | Hàng lỗi, cách ly, đề xuất/duyệt/thực hiện disposition |
| SC-12 | Movement vị trí và xác nhận actual |
| SC-13 | TR/TO, checkpoint, In Transit, difference và resolution |
| SC-14 | Session kiểm kê, snapshot, count/recount và reconciliation |
| SC-15 | Adjustment request, approval và Clear Difference riêng |
| SC-16 | SO, giá nhập, cảnh báo, issued/outstanding và phần được sửa/hủy |
| SC-17 | Goods Issue và xác nhận PGI |
| SC-18 | Trả khách: yêu cầu, review, inspection, receipt |
| SC-19 | Trả NCC: acceptance, dispatch, acknowledgement, closure |
| SC-20 | Năm nhóm báo cáo theo quyền |
| SC-21 | Movement log, chi tiết và lot trace |
| SC-22 | OD từ số lượng SO còn lại |
| SC-23 | Picking TO và staging confirmation |
| SC-24 | Khách hàng |
| SC-25 | Giá bán nhập tay và lịch sử hiệu lực |
| SC-26 | Hóa đơn nội bộ, issue, PDF/in |
| SC-27 | Refund request, payment proof, approval và external completion |

Luồng chuyển màn hình chính: SC-06 → SC-07 → SC-08 → SC-10; SC-16 → SC-22 → SC-23 → SC-17 → SC-26; SC-18 → SC-27; SC-14 → SC-15 → SC-21. Mở liên kết chỉ đưa đến màn hình, không tự thực hiện bước nghiệp vụ. Trên thiết bị nhỏ, bảng dài cuộn ngang hoặc mở detail từng dòng, không ẩn số thực nhận/accepted/remaining để rút gọn.

## 14 Bảo mật và vận hành

R3 yêu cầu credential không lưu/log đọc trực tiếp, kiểm tra quyền phía server, tính nhất quán, chống lặp và truy vết. Các biện pháp cụ thể dưới đây là [TK] để thực hiện các yêu cầu đó.

- Mật khẩu băm có salt bằng thư viện phù hợp; session token không ghi log; bảo vệ kênh truyền bằng TLS. Nếu dùng cookie session, đặt HttpOnly/Secure và bảo vệ CSRF.
- Whitelist input theo command, chống mass assignment: client không sửa role, approvedBy, approvedVersion, postedAt, balance hoặc issued snapshot qua endpoint cập nhật thông thường.
- Phân quyền theo object/warehouse cả ở API file download; không để public URL bằng chứng trở thành đường vòng truy cập hồ sơ. Cloudinary asset cần cấu hình access phù hợp, không mặc định mọi ảnh là công khai.
- Ghi audit đối với đổi quyền, master, approval, posting, invoice issue và refund completion; không log mật khẩu, SMTP secret hoặc toàn bộ chứng từ nhạy cảm vào log chung.
- Hạn chế truy cập MongoDB/storage/SMTP theo môi trường; secret phía máy chủ, tách development và production. Quyền triển khai không thay thế quyền người dùng nghiệp vụ.
- Backup gồm DB, liên kết/asset bằng chứng, PDF và cấu hình cần phục hồi; diễn tập restore và đối chiếu stock ledger. RPO/RTO, retention, thời gian giữ audit và dung lượng là CXC-10.
- Quan sát lỗi transaction, posting retry/conflict, balance bất thường, In Transit lâu chưa xử lý, PO outstanding, outbox failed và PDF failed. Không tự sửa chênh từ một job giám sát.
- Không phát biểu SLA số giây, số user đồng thời hoặc availability như đã cam kết. R3 chưa có số; cần đo trên bộ dữ liệu và tải được duyệt.

## 15 Kịch bản kiểm thử và nghiệm thu

Các dữ liệu số dưới đây là ví dụ kiểm thử, không phải dữ liệu vận hành của cửa hàng. Mỗi test phải kiểm tra đồng thời response, trạng thái chứng từ, balance, ledger, source reference và quyền đọc lại; chỉ kiểm tra giao diện báo thành công là chưa đủ.

| Mã | Kịch bản | Kết quả bắt buộc |
|---|---|---|
| TC-01 | Accountant gọi approve request | Bị chặn; approval/stock không đổi (BR-01/10) |
| TC-02 | Staff kho A mở hoặc post chứng từ kho B | Không lộ dữ liệu/không post; download evidence cũng chặn |
| TC-03 | Admin gọi PGI/clear/refund review | Bị từ chối bằng quyền Admin |
| TC-04 | Inventory Staff sửa lô đã có; Accountant deactivate NCC | Bị chặn đúng sub-operation; create lô/update NCC hợp lệ vẫn được |
| TC-05 | Quy cách 4 viên/thùng, 0,36 m²/viên; đổi quy cách sau GR | 3 thùng 2 viên = 14 viên = 5,04 m²; GR lịch sử giữ số cũ |
| TC-06 | PO confirmed 100; đợt 1 thực nhận 60, accepted 55, rejected 5; đợt 2 accepted 45 | Fulfilled 100, rejected tách riêng; 5 rejected không tự làm hết nghĩa vụ trước đợt 2 |
| TC-07 | Đề nghị bị từ chối rồi sửa và trình lại | Không có PO trước approval mới; giữ cả hai phiên bản |
| TC-08 | PO còn thiếu 10, NCC không giao tiếp | Owner duyệt đóng 10; received không tăng giả; Accountant đối chiếu rồi close |
| TC-09 | GR draft và confirm lặp | Draft không tăng; chỉ một receipt posting, một tác động tồn |
| TC-10 | Actual 10, phân loại tổng 11 | Chặn inspection posting, không ghi bất kỳ chân tồn nào |
| TC-11 | GR accepted 10 ở interim, put-away 10 | Kho chỉ tăng 10 tổng; interim về 0, bin đích +10 |
| TC-12 | Move 7 giữa hai bin cùng kho; lỗi sau bước trừ nguồn | Rollback cả hai; khi thành công tổng không đổi |
| TC-13 | Chuyển kho 100, nhận 95 gồm 3 hỏng | Nguồn −100; đích +92 tốt/+3 hỏng; 5 treo; không close trước resolution |
| TC-14 | Owner duyệt difference nhưng staff chưa execute | Không có tự động post từ review |
| TC-15 | Retry dispatch/handover/receipt cùng execution | Không nhân đôi nguồn, transit hoặc đích |
| TC-16 | Tồn 10, hai picking TO đồng thời mỗi cái 8 | Chỉ giữ/xác nhận đủ lượng cho một bên; không âm nguồn |
| TC-17 | Pick 10 vào staging rồi PGI 8 | Picking tổng 0; PGI tổng −8; staging còn 2 gắn OD |
| TC-18 | PGI vượt picked hoặc SO outstanding | Chặn; chứng từ/ledger giữ nguyên |
| TC-19 | Hai OD cùng phân bổ phần SO còn 10, mỗi OD 8 | Không cho tổng allocation 16 |
| TC-20 | Hai invoice draft cùng claim issue quantity | Không billed vượt issue; issue lại không cấp số/stock effect mới |
| TC-21 | Owner export invoice; Owner thử issue | Export issued được; issue bị từ chối |
| TC-22 | Issue invoice xong SMTP/PDF lỗi | Invoice vẫn issued, stock không đổi thêm; tác vụ retry không reissue |
| TC-23 | Hàng usable 12 bị phát hiện hỏng 4 | Tổng 12, usable giảm 4; không được chọn 4 cho picking |
| TC-24 | Execute defect vượt approved hoặc chưa approved | Chặn; trả NCC không giảm ở cả defect và dispatch |
| TC-25 | Issue 10, đã trả 4; yêu cầu mới 7 | Chặn over-return; hai request đồng thời cũng không vượt nguồn |
| TC-26 | Nhập trả trước Owner review hoặc trước inspection | Chặn; không tăng usable |
| TC-27 | Return 5 gồm 3 tốt và 2 hỏng | Nhập đúng phân loại; chỉ phần tốt đặt vị trí đủ điều kiện được bán |
| TC-28 | Return accepted nhưng thiếu payment proof | Kho trả vẫn tồn tại; refund submit bị chặn |
| TC-29 | Cap refund 100, completed 40, pending khác 30, request mới 40 | Chặn vì còn tối đa 30; không dùng lại cùng cap |
| TC-30 | Accountant ghi completion lặp hoặc vượt approved | Một completion hợp lệ; invoice gốc không đổi, không giao dịch ngân hàng |
| TC-31 | Trả NCC 5 hàng bị từ chối tại GR chưa vào tồn | Không trừ số dư sở hữu; giảm đúng theo dõi vật lý |
| TC-32 | Trả NCC dispatched 10, acknowledged 8 | Giữ mở; Owner không được close khi 2 chưa có kết quả |
| TC-33 | Stocktake start hai lần và recount ba lần | Một snapshot/cutoff; ba attempt còn đủ, chọn rõ lần đối chiếu |
| TC-34 | Count bỏ trống so với count 0 | Trống chặn submit; 0 là kết quả đếm hợp lệ |
| TC-35 | B0 100, xuất 10, đếm 88, sau đó nhập 20 | Delta −2; clear số hiện tại 110 thành 108 |
| TC-36 | Đối chiếu không lệch | Đóng session, không adjustment/movement |
| TC-37 | Owner approve rồi Inventory Staff gọi clear | Stock chưa đổi lúc approve; Staff clear bị chặn |
| TC-38 | Count version đổi sau approval; hoặc clear hai lần | Stale bị chặn; retry không áp delta thêm |
| TC-39 | Xuất báo cáo/truy vết và cộng ledger | Tồn đầu + các movement đúng scope = tồn cuối; không double count nội kho |
| TC-40 | Thu hồi quyền khi session đang mở | Lệnh tiếp theo bị chặn theo quyền mới |
| TC-41 | Upload evidence thất bại nhưng gọi hoàn tất | Không coi evidence là hợp lệ; không gửi URL giả vào hồ sơ |
| TC-42 | Mất mạng ngay sau commit posting | Retry cùng key trả kết quả đã có; balance và ledger chỉ thay đổi một lần |

Tiêu chí hoàn tất triển khai: 102 UC được ánh xạ đầy đủ; tất cả thao tác ghi có negative permission test, stale/retry test và đối chiếu stock effect; các nhánh exception trong F04–F12 được nghiệm thu; các mục CXC ảnh hưởng dữ liệu hoặc chính sách được chốt trước chạy thật. Các test trên là kế hoạch nghiệm thu của thiết kế, không phải tuyên bố phần mềm đã được kiểm thử.

## 16 Các quyết định cần chốt trước triển khai

| Mã | Nội dung chưa được xác định đủ | Cách xử lý trong thiết kế hiện tại |
|---|---|---|
| CXC-01 | Bội số của hình ERD; một request có thể sinh bao nhiêu PO/TO | Giữ tham chiếu rõ; không khẳng định bội số hình không ghi; schema cần chốt giới hạn |
| CXC-02 | Làm tròn quantity/tiền, fractional pieces, giá trùng hiệu lực, ngưỡng cảnh báo | Snapshot conversion/price; không tự áp số hoặc công thức margin |
| CXC-03 | Thời hạn/điều kiện khách được trả hàng | Luồng có kiểm tra và Owner review; chưa tự đặt 7/30 ngày hoặc phí |
| CXC-04 | Quyền sở hữu hàng pending/damaged, lượng nào làm giảm outstanding PO, nhận thừa | Lưu tách physical/accepted/rejected/owned và bằng chứng; không tự coi mọi hàng đến đã hoàn tất PO |
| CXC-05 | Danh mục disposition và điều kiện hàng usable có điều kiện | Cách ly cho đến khi được xử lý hợp lệ; không tự duyệt bán lại |
| CXC-06 | Định giá hoàn tiền phần hỏng, hoàn tất ít hơn số duyệt, bằng chứng thanh toán dùng chung | Giữ cap và proof theo giao dịch; chưa tạo chính sách khấu trừ hoặc nhiều đợt hoàn tùy ý |
| CXC-07 | Hủy/sửa OD hoặc picking đã tạo, hàng staging khi SO hủy | Chặn thay đổi làm mồ côi dependent documents; cần quy trình có chứng từ để giải phóng |
| CXC-08 | Đảo PGI/GR, sửa invoice issued, correction sau post, dữ liệu tồn đầu | Không cho sửa trực tiếp lịch sử; cần quyết định riêng về correction/migration được phê duyệt |
| CXC-09 | Email trigger/recipient/template/retry, giới hạn file, Cloudinary access mode và PDF storage | Tách adapter/outbox; không thêm recipient hoặc công khai evidence mặc định |
| CXC-10 | SLA, tải dữ liệu, backup/RPO/RTO, retention, session timeout và bảo mật vận hành | Không ghi số cam kết giả; chốt bộ dữ liệu và chỉ tiêu để đo |
| CXC-11 | Bổ sung quyền/UC thao tác đóng phần thiếu PO và đối chiếu mua từ D-P35 | Đã thiết kế như thao tác riêng; cần đồng bộ danh mục SRS, không âm thầm gán vào quyền Owner sửa PO |
| CXC-12 | Quy tắc chọn lot FIFO hoặc đồng tone cho một đơn, capacity bin, multi-execution | Chọn lot đủ điều kiện bằng tay; không tự thêm FIFO, tối ưu hoặc giới hạn chưa có |

Các mục này không làm mất các luồng đã xác định; chúng là điểm kiểm soát để triển khai chi tiết không tự tạo chính sách kinh doanh. Những lựa chọn đã chốt gồm bộ UC đầy đủ, Purchasing v3 và ERD trong Report 3.


## Phụ lục A Truy vết đầy đủ 102 use case

Tên UC được giữ bằng tiếng Anh để đối chiếu trực tiếp R3. Owner là Store Owner; Kho là Inventory Staff. Quyền ghi dưới đây lấy từ ma trận R3 I.4.4, đối chiếu bộ D-UC đã chọn. Các giới hạn chi tiết của mục 2 vẫn áp dụng, kể cả khi một ô viết ngắn là “thực hiện”. F03 áp dụng thêm cho mọi UC xem danh sách/chi tiết.

| UC và tên nguồn | FE và màn hình | Luồng thiết kế | Quyền theo vai trò |
|---|---|---|---|
| UC-01 View replenishment request list | FE-01 / SC-06 | F04–F05 | Owner: xem; Kế toán: xem |
| UC-02 View replenishment request details | FE-01 / SC-06 | F04–F05 | Owner: xem; Kế toán: xem |
| UC-03 Create replenishment request | FE-01 / SC-06 | F04–F05 | Kế toán: thực hiện |
| UC-04 Approve or reject replenishment request | FE-01 / SC-06 | F04–F05 | Owner: duyệt |
| UC-05 View purchase order list | FE-01 / SC-07 | F04–F05 | Owner: xem; Kế toán: xem; Kho: chỉ phạm vi nhận hàng |
| UC-06 View purchase order details | FE-01 / SC-07 | F04–F05 | Owner: xem; Kế toán: xem; Kho: chỉ phạm vi nhận hàng |
| UC-07 Manage Purchase Order and Supplier Confirmation | FE-01 / SC-07 | F04–F05 | Kế toán: thực hiện |
| UC-08 View goods receipt list | FE-01 / SC-08 | F04–F05 | Owner: xem; Kế toán: xem; Kho: xem |
| UC-09 View goods receipt details | FE-01 / SC-08 | F04–F05 | Owner: xem; Kế toán: xem; Kho: xem |
| UC-10 Create goods receipt from purchase order | FE-01 / SC-08 | F04–F05 | Kho: thực hiện |
| UC-11 View product list | FE-02 / SC-03 | F02 | Owner: xem; Kế toán: xem; Kho: xem; Bán hàng: xem |
| UC-12 View product details | FE-02 / SC-03 | F02 | Owner: xem; Kế toán: xem; Kho: xem; Bán hàng: xem |
| UC-13 Maintain Product and Packaging | FE-02 / SC-03 | F02 | Owner: thực hiện |
| UC-14 View lot list | FE-02 / SC-04 | F02 | Owner: xem; Kho: xem |
| UC-15 View lot details | FE-02 / SC-04 | F02 | Owner: xem; Kho: xem |
| UC-16 Maintain Product Lot | FE-02 / SC-04 | F02 | Owner: tạo / cập nhật; Kho: chỉ tạo |
| UC-17 View supplier list | FE-02 / SC-05 | F02 | Owner: xem; Kế toán: xem |
| UC-18 View supplier details | FE-02 / SC-05 | F02 | Owner: xem; Kế toán: xem |
| UC-19 Maintain Supplier | FE-02 / SC-05 | F02 | Owner: kích hoạt / ngừng; Kế toán: tạo / cập nhật |
| UC-20 View Customer List | FE-02 / SC-24 | F02 | Owner: xem; Kế toán: xem; Bán hàng: xem |
| UC-21 View Customer Details | FE-02 / SC-24 | F02 | Owner: xem; Kế toán: xem; Bán hàng: xem |
| UC-22 Maintain Customer | FE-02 / SC-24 | F02 | Bán hàng: thực hiện |
| UC-23 View Selling Price List | FE-02 / SC-25 | F02 | Owner: xem; Kế toán: xem; Bán hàng: xem |
| UC-24 View Selling Price Details | FE-02 / SC-25 | F02 | Owner: xem; Kế toán: xem; Bán hàng: xem |
| UC-25 Maintain Selling Price | FE-02 / SC-25 | F02 | Owner: thực hiện |
| UC-26 Inspect and Post Goods Receipt | FE-03 / SC-08 | F05 | Kho: thực hiện |
| UC-27 View warehouse and location list | FE-04 / SC-09 | F02–F03 | Owner: xem; Kho: xem |
| UC-28 View storage location details | FE-04 / SC-09 | F02–F03 | Owner: xem; Kho: xem |
| UC-29 Maintain Storage Location | FE-04 / SC-09 | F02–F03 | Owner: thực hiện |
| UC-30 View stock by lot, location, and quality status | FE-04 / SC-10 | F02–F03 | Owner: xem; Kế toán: xem; Kho: xem; Bán hàng: chỉ tồn dùng được |
| UC-31 View inventory balance details | FE-04 / SC-10 | F02–F03 | Owner: xem; Kho: xem |
| UC-32 Create Put-away Transfer Order | FE-04 / SC-08 | F05 | Kho: thực hiện |
| UC-33 Confirm Put-away Transfer Order | FE-04 / SC-08 | F05 | Kho: thực hiện |
| UC-34 View location movement list | FE-04 / SC-12 | F06 | Owner: xem; Kho: xem |
| UC-35 View location movement details | FE-04 / SC-12 | F06 | Owner: xem; Kho: xem |
| UC-36 Create location movement | FE-04 / SC-12 | F06 | Kho: thực hiện |
| UC-37 Confirm actual location movement | FE-04 / SC-12 | F06 | Kho: thực hiện |
| UC-38 View warehouse transfer list | FE-05 / SC-13 | F07 | Owner: xem; Kho: xem |
| UC-39 View warehouse transfer details | FE-05 / SC-13 | F07 | Owner: xem; Kho: xem |
| UC-40 Create Transfer Request | FE-05 / SC-13 | F07 | Kho: thực hiện |
| UC-41 Review Transfer Request | FE-05 / SC-13 | F07 | Owner: duyệt |
| UC-42 Create Warehouse Transfer Order | FE-05 / SC-13 | F07 | Kho: thực hiện |
| UC-43 Confirm Warehouse Transfer Order | FE-05 / SC-13 | F07 | Kho: thực hiện |
| UC-44 Review Transfer Difference Resolution | FE-05 / SC-13 | F07 | Owner: duyệt |
| UC-45 View Sales Order List | FE-06 / SC-16 | F09 | Owner: xem; Bán hàng: xem |
| UC-46 View Sales Order Details | FE-06 / SC-16 | F09 | Owner: xem; Bán hàng: xem |
| UC-47 Create Sales Order | FE-06 / SC-16 | F09 | Bán hàng: thực hiện |
| UC-48 Update or Cancel Sales Order | FE-06 / SC-16 | F09 | Bán hàng: thực hiện |
| UC-49 View Outbound Delivery List | FE-06 / SC-22 | F09 | Owner: xem; Kho: xem; Bán hàng: xem |
| UC-50 View Outbound Delivery Details | FE-06 / SC-22 | F09 | Owner: xem; Kho: xem; Bán hàng: xem |
| UC-51 Create Outbound Delivery | FE-06 / SC-22 | F09 | Bán hàng: thực hiện |
| UC-52 View Picking Transfer Order List | FE-06 / SC-23 | F09 | Owner: xem; Kho: xem |
| UC-53 View Picking Transfer Order Details | FE-06 / SC-23 | F09 | Owner: xem; Kho: xem |
| UC-54 Create Picking Transfer Order | FE-06 / SC-23 | F09 | Kho: thực hiện |
| UC-55 Confirm Picking Transfer Order | FE-06 / SC-23 | F09 | Kho: thực hiện |
| UC-56 View goods issue list | FE-06 / SC-17 | F09 | Owner: xem; Kho: xem |
| UC-57 View goods issue details | FE-06 / SC-17 | F09 | Owner: xem; Kho: xem |
| UC-58 Post Goods Issue | FE-06 / SC-17 | F09 | Kho: thực hiện |
| UC-59 View Internal Invoice List | FE-06 / SC-26 | F09 | Owner: xem; Kế toán: xem |
| UC-60 View Internal Invoice Details | FE-06 / SC-26 | F09 | Owner: xem; Kế toán: xem |
| UC-61 Create Internal Invoice | FE-06 / SC-26 | F09 | Kế toán: thực hiện |
| UC-62 Issue Internal Invoice and Produce PDF | FE-06 / SC-26 | F09 | Owner: chỉ xuất / in bản đã phát hành; Kế toán: phát hành / xuất / in |
| UC-63 View defective goods list | FE-07 / SC-11 | F08 | Owner: xem; Kho: xem |
| UC-64 View defective goods details | FE-07 / SC-11 | F08 | Owner: xem; Kho: xem |
| UC-65 Inspect Defective Goods and Submit Disposition | FE-07 / SC-11 | F08 | Kho: thực hiện |
| UC-66 Approve or reject defective goods disposition | FE-07 / SC-11 | F08 | Owner: duyệt |
| UC-67 Record approved defective goods disposition | FE-07 / SC-11 | F08 | Kho: thực hiện |
| UC-68 View customer return list | FE-07 / SC-18 | F10 | Owner: xem; Kế toán: xem; Kho: xem; Bán hàng: Related sales records only |
| UC-69 View customer return details | FE-07 / SC-18 | F10 | Owner: xem; Kế toán: xem; Kho: xem; Bán hàng: Related sales records only |
| UC-70 Create Customer Return Request | FE-07 / SC-18 | F10 | Kho: thực hiện |
| UC-71 Review Customer Return Request | FE-07 / SC-18 | F10 | Owner: duyệt |
| UC-72 Inspect Customer Return | FE-07 / SC-18 | F10 | Kho: thực hiện |
| UC-73 Confirm Customer Return Receipt | FE-07 / SC-18 | F10 | Kho: thực hiện |
| UC-74 View Refund Request List | FE-07 / SC-27 | F10 | Owner: xem; Kế toán: xem |
| UC-75 View Refund Request Details | FE-07 / SC-27 | F10 | Owner: xem; Kế toán: xem |
| UC-76 Create Customer Return Refund Request | FE-07 / SC-27 | F10 | Kế toán: thực hiện |
| UC-77 Review Customer Return Refund Request | FE-07 / SC-27 | F10 | Owner: duyệt |
| UC-78 Record Refund Completion | FE-07 / SC-27 | F10 | Kế toán: thực hiện |
| UC-79 View supplier return request list | FE-07 / SC-19 | F11 | Owner: xem; Kế toán: xem; Kho: xem |
| UC-80 View supplier return request details | FE-07 / SC-19 | F11 | Owner: xem; Kế toán: xem; Kho: xem |
| UC-81 Create Supplier Return Request | FE-07 / SC-19 | F11 | Kho: thực hiện |
| UC-82 Confirm Supplier Return Dispatch | FE-07 / SC-19 | F11 | Kho: thực hiện |
| UC-83 Review Supplier Return Closure | FE-07 / SC-19 | F11 | Owner: duyệt |
| UC-84 View stocktake list | FE-08 / SC-14 | F12 | Owner: xem; Kho: xem |
| UC-85 View stocktake details | FE-08 / SC-14 | F12 | Owner: xem; Kho: xem |
| UC-86 Create Stocktake Session | FE-08 / SC-14 | F12 | Owner: thực hiện |
| UC-87 Perform Stocktake Count and Record Results | FE-08 / SC-14 | F12 | Kho: thực hiện |
| UC-88 Reconcile Stocktake | FE-08 / SC-14 | F12 | Kho: thực hiện |
| UC-89 View inventory adjustment request list | FE-08 / SC-15 | F12 | Owner: xem; Kho: xem |
| UC-90 View inventory adjustment request details | FE-08 / SC-15 | F12 | Owner: xem; Kho: xem |
| UC-91 Create Inventory Adjustment Request | FE-08 / SC-15 | F12 | Kho: thực hiện |
| UC-92 Approve Inventory Adjustment | FE-08 / SC-15 | F12 | Owner: duyệt |
| UC-93 Clear Stocktake Difference | FE-08 / SC-15 | F12 | Owner: thực hiện |
| UC-94 Sign in to the system | FE-09 / SC-01 | F01 | Owner: Use; Kế toán: Use; Kho: Use; Bán hàng: Use; Admin: Use |
| UC-95 View account list | FE-09 / SC-02 | F01 | Admin: xem |
| UC-96 View account details | FE-09 / SC-02 | F01 | Admin: xem |
| UC-97 Maintain Staff Account | FE-09 / SC-02 | F01 | Admin: thực hiện |
| UC-98 Assign roles and operation permissions | FE-09 / SC-02 | F01 | Admin: thực hiện |
| UC-99 View Operational Reports | FE-09 / SC-20 | F13 | Owner: tất cả nhóm báo cáo; Kế toán: luân chuyển; mua/nhận; Kho: luân chuyển; tồn; chuyển kho; kiểm kê |
| UC-100 View stock movement log | FE-09 / SC-21 | F13 | Owner: xem; Kế toán: phạm vi mua/NCC; Kho: xem |
| UC-101 View stock movement details | FE-09 / SC-21 | F13 | Owner: xem; Kế toán: phạm vi mua/NCC; Kho: xem |
| UC-102 Trace a product lot through source documents | FE-09 / SC-21 | F13 | Owner: xem; Kế toán: phạm vi mua/NCC; Kho: xem |

## Phụ lục B Phần bổ sung từ sơ đồ được chọn

| Mã thiết kế | Nội dung | Nguồn và liên hệ UC |
|---|---|---|
| D35-01 | Sửa đề nghị và quay lại Owner review | Purchasing v3 To-be; bổ sung vòng xử lý UC-03/04 |
| D35-02 | NCC không đáp ứng thì sửa/hủy phần chưa nhận và xác nhận lại | Purchasing v3 To-be; UC-07 |
| D35-03 | Đối chiếu GR, thống nhất thay thế/giao sau/điều chỉnh lượng | Purchasing v3 To-be; UC-07/26 và F04 |
| D35-04 | Owner duyệt đóng số lượng còn thiếu khi không giao tiếp | Purchasing v3 To-be; chưa có UC riêng trong danh mục 102 UC |
| D35-05 | Đối chiếu chứng từ mua trước khi Accountant đóng PO | Purchasing v3 To-be; cần bổ sung đặc tả thao tác FE-01 |
| D37-01 | Upload evidence tới Cloudinary và lưu kết quả | Trung Context Diagram; hỗ trợ UC có bằng chứng, hợp đồng kỹ thuật [TK] |

## Phụ lục C Danh mục tham chiếu kiểm soát

R1: I.2 Project Purpose; IV Proposed Solution; V.1 Major Features; V.2 Limitations & Exclusions.

R3: I.2 Main Business Flow; I.3.1 ERD và I.3.2 Entity Descriptions; I.3.3 DR-01–14; I.4.2 danh mục UC; I.4.4 Permission Matrix; II toàn bộ UC-01–102; III SC-01–27, API-01 và JOB-01; IV Quality Attributes; V Business Rules và MSG-01–07.

Draw.io: trang 14 Bản sao của UC Accountants; 16 Bản sao của UC Admin; 18 Bản sao của UC SO; 20 Bản sao của UC SS; 22 Bản sao của UC_IS; 35 Purchasing and Receiving_v3 phần To-be; 36 Chuyển kho nội bộ phần TO BE; 37 Trung Context Diagram. Những trang BF cũ hơn chỉ dùng khi không xung đột bộ UC được chọn.
