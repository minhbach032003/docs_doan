# ĐẶC TẢ NGHIỆP VỤ TO-BE CHI TIẾT — WMSD

**Đơn vị áp dụng:** Cửa hàng gạch ốp lát Tân Thương  
**Phiên bản:** Bản dự thảo nghiệp vụ chi tiết, ngày 18/10/2026  
**Phạm vi:** Bảy quy trình BF-01 đến BF-07, dùng làm cơ sở đồng bộ Report 1, Report 3, sơ đồ quy trình và slide.

> Đây là đề xuất To-be dựa trên review1, Report 1, Report 3 và các hướng dẫn phần mềm tham khảo. Chưa coi các giả định về số kho vật lý, số nhân viên, chính sách đổi trả hoặc thời gian kiểm kê là sự thật đã được cửa hàng xác nhận.

## 1. Mục tiêu và giới hạn

WMSD quản lý sự kiện vật lý của hàng gạch: nhận, kiểm, lưu vị trí, di chuyển, soạn, xuất, nhận trả, cách ly, điều chuyển và kiểm kê. Hàng được truy vết theo sản phẩm, lô, tone, calibre thực tế, đơn vị tính, vị trí và tình trạng chất lượng. Chứng từ bán hàng, thu tiền, công nợ, kế toán, hóa đơn thuế và nghiệp vụ thanh toán nhà cung cấp thuộc MISA/phần mềm kế toán; WMSD chỉ lưu mã tham chiếu cần thiết để đối chiếu. Baseline không giả định có kết nối API trực tiếp với MISA.

Phạm vi cửa hàng gồm một đơn vị kinh doanh với một hoặc nhiều kho vật lý do cửa hàng quản lý. “Kho” là nơi tồn có thể kiểm kê độc lập; “vị trí” là kệ/ô/khu nằm trong kho. Khu nhận hàng, staging, cách ly có thể là vị trí hoặc trạng thái riêng bên trong một kho; chỉ cấu hình thành kho riêng khi thực tế vận hành và cách ghi sổ của cửa hàng xác nhận.

## 2. Actors và trách nhiệm

| Actor | Trách nhiệm trong 7 BF |
|---|---|
| **Sales Staff** | Ghi nhu cầu xuất theo đơn bán bên ngoài WMSD; xác nhận hàng thiếu, phương án đáp ứng và giao từng phần với khách; tiếp nhận đề nghị khách trả; không thẩm định chất lượng gạch. |
| **Warehouse Staff** | Kiểm tồn vật lý, lập đề nghị bổ sung từ kho/kiểm kê, nhận và phân loại hàng, chuyển vị trí, soạn và bàn giao, kiểm hàng trả, cách ly và kiểm kê. Chỉ thao tác tại kho được giao. |
| **Store Owner** | Duyệt đề nghị bổ sung, điều chuyển giữa kho, xử lý chất lượng, nhận trả, xử lý chênh lệch, phiên kiểm kê và các điều chỉnh theo quyền được giao. Không duyệt việc đổi kệ thông thường. |
| **Accountant** | Lập đơn mua hàng sau khi được duyệt; ghi nhận phản hồi/thỏa thuận của nhà cung cấp; đối chiếu PO, phiếu kho và chứng từ; ghi tham chiếu chứng từ/hóa đơn/hoàn tiền được xử lý bên ngoài. Không tự quyết định nhu cầu kho. |
| **Administrator** | Quản lý tài khoản, vai trò và cấu hình kỹ thuật. Không mặc nhiên có quyền duyệt hoặc ghi nhận giao dịch kho. |
| **Customer, Supplier, Carrier** | Bên ngoài hệ thống; trao đổi với nhân viên và cung cấp/xác nhận chứng từ. Không phải tài khoản WMSD nếu chưa có yêu cầu được duyệt. |

Quyền được kiểm tra theo người dùng cụ thể, thao tác, trạng thái hồ sơ và phạm vi kho. Người tạo một đề nghị không được tự duyệt cùng đề nghị đó, kể cả khi tài khoản được gán nhiều role. Việc người kho xác nhận một thao tác vật lý không phải phê duyệt kinh doanh. Điều chuyển liên kho cần ghi riêng người giao và người nhận; cách phân công khi cửa hàng ít nhân sự cần xác nhận lúc khảo sát.

## 3. Thuật ngữ và trạng thái tồn dùng chung

- **Tồn theo sổ WMS:** tổng lượng thuộc quyền quản lý của cửa hàng theo vị trí và tình trạng, cộng riêng lượng đang chuyển nếu báo cáo cần tổng toàn cửa hàng.
- **Tồn khả dụng:** lượng đạt chất lượng, ở vị trí được phép lấy, trừ lượng đã giữ cho yêu cầu xuất còn hiệu lực. Không tính hàng giữ hộ, chờ kiểm, hỏng, đang chuyển hoặc trong phạm vi kiểm kê đang khóa.
- **Đã giữ:** còn nằm trong kho và thuộc tổng tồn, nhưng không được phân bổ lại cho yêu cầu khác.
- **Đang soạn/staging:** đã lấy khỏi vị trí lưu nhưng chưa PGI; vẫn thuộc tổng tồn và gắn với yêu cầu xuất.
- **Đang chuyển:** đã rời kho nguồn nhưng chưa được kho đích xác nhận; không đồng thời tính là on-hand ở cả hai kho.
- **Cách ly:** hàng chưa được phép bán hoặc xuất bình thường. Cách ly tự nó không làm thay đổi tổng lượng sở hữu.
- **Giữ hộ:** hàng đang nằm trong khu vực cửa hàng nhưng chưa thuộc tồn sở hữu của cửa hàng, ví dụ hàng NCC chưa được chấp nhận hoặc hàng khách mang đến chờ quyết định.
- **Chất lượng** (đạt, chờ kiểm, hỏng/cách ly...) là thuộc tính khác với **tình trạng vận chuyển** (đang chuyển, đã nhận, staging...). Một lượng có thể đồng thời đang chuyển và được báo hỏng.

Đơn vị thùng/viên/m² dùng hệ số theo từng sản phẩm và phiên bản đóng gói. Lịch sử phiếu đã ghi nhận giữ hệ số lúc lập phiếu; không đổi cấu hình hiện tại để viết lại số lượng cũ. Lot/tone/calibre không được gộp chỉ vì cùng tên/mã bán hàng nếu thực tế không tương thích.

## 4. BF-01 — Đề nghị bổ sung, đặt hàng và nhập kho

### 4.1 Mục đích và điều kiện bắt đầu

Đảm bảo cửa hàng chỉ đề nghị mua khi nhu cầu chưa được đáp ứng bằng tồn khả dụng hoặc nguồn hàng đang về phù hợp; hàng nhận được kiểm đếm và nhập theo lượng, tình trạng, lô và vị trí thực tế.

Quy trình bắt đầu từ một trong hai nhóm tín hiệu:

1. **Thiếu cho đơn bán:** Sales Staff nhận thấy tồn khả dụng tại kho dự kiến không đủ cho lượng khách đặt. Sales lập đề nghị gắn mã đơn/dòng hàng tham chiếu; WMSD kiểm tra nguồn kho khác và lượng đang về trước khi đề nghị mua.
2. **Thiếu theo tồn kho:** Warehouse Staff kiểm kho thấy lượng khả dụng dưới định mức đã cấu hình; hoặc phát hiện thiếu sau kiểm kê/xử lý hàng lỗi. Warehouse lập đề nghị bù với số liệu và lý do.

Tín hiệu thiếu chỉ khởi động **đề nghị bổ sung**, không tự động đặt đơn mua. Định mức, mức ưu tiên kho và thời gian giao là cấu hình hữu hạn có chủ sở hữu; không phải công cụ tự dự báo hoặc tự phát hành PO.

### 4.2 Luồng chính

| Bước | Người thực hiện | Thao tác và điều kiện | Trạng thái/chứng từ sau bước |
|---|---|---|---|
| 1. Ghi nhận tín hiệu | Sales Staff hoặc Warehouse Staff | Sales chọn mã đơn/dòng, sản phẩm, số lượng thiếu, kho cần hàng và ngày cần. Warehouse chọn kho, sản phẩm, mức tồn thực tế/khả dụng và lý do (dưới định mức, sau kiểm kê, sau hàng lỗi). | Tạo bản nháp Replenishment Request; chưa tạo PO, chưa đổi tồn. |
| 2. Đối chiếu nguồn | WMSD; người đề xuất xem kết quả | Hệ thống tính tồn khả dụng theo lot/tone/calibre; trừ lượng giữ; hiển thị PO còn giao, điều chuyển đang về, hàng chờ kiểm và yêu cầu khác đã giữ. Không coi nguồn chưa chắc chắn/không tương thích là lượng sẵn sàng. | Bản nháp có bảng nhu cầu, nguồn đã có và phần thiếu ròng. |
| 3. Hoàn tất đề nghị | Người đề xuất | Chọn phần còn thiếu cần mua, NCC gợi ý nếu đã có hồ sơ, ngày cần, lý do và tài liệu hỗ trợ. Với nhu cầu từ đơn bán, không tự thay tone/calibre. | Request chuyển “Chờ Owner duyệt”. |
| 4. Quyết định nhu cầu | Store Owner | So lượng thiếu ròng, nguồn khác, tính cấp thiết và đề xuất. Chọn duyệt, từ chối, hoặc trả về sửa; ghi user, thời gian, lượng và lý do. Không tự sửa nội dung request của người đề xuất. | Duyệt: “Đã duyệt”. Từ chối: “Đã từ chối”. Trả về: “Cần bổ sung”. Không đổi tồn. |
| 5. Lập PO | Accountant | Chỉ từ request đã duyệt. Lập mã PO, NCC, dòng hàng/số lượng/đơn vị, lịch giao dự kiến; lưu tham chiếu request. Gửi NCC qua kênh ngoài WMSD nếu chưa có tích hợp. | PO “Chờ NCC xác nhận”; không đổi tồn. |
| 6. Ghi nhận NCC xác nhận | Accountant | Ghi lượng NCC nhận giao và ngày giao dự kiến theo từng dòng. Nếu NCC giao một phần hoặc từ chối dòng nào, cập nhật phản hồi và đề xuất sửa/cancel phần chưa nhận. Sửa nội dung vượt phần đã duyệt phải quay lại Owner duyệt phần thay đổi. | PO “Đã xác nhận”, “Xác nhận một phần” hoặc “Cần điều chỉnh”. |
| 7. Tiếp nhận từng chuyến | Warehouse Staff | Mỗi lần xe đến tạo receipt tham chiếu PO và dòng PO. Đếm bao/thùng/viên thực giao; đối chiếu mã, lot, tone, calibre, đóng gói, tình trạng vỡ và chứng từ đi kèm. Ghi riêng lượng chưa kết luận. | Goods Receipt “Đang kiểm”; chưa tính toàn bộ thành tồn khả dụng. |
| 8. Phân loại kết quả | Warehouse Staff | Chia lượng theo từng dòng: đạt và cửa hàng chấp nhận quản lý; đang chờ kiểm/giải quyết; hàng lỗi được cửa hàng nhận giữ; hàng từ chối ngay và bàn giao NCC. Chụp/đính kèm bằng chứng sai mã, thiếu, thừa, sai lot hoặc hỏng. | Có biên bản sai lệch khi phát sinh; mỗi phân loại có quantity/status riêng. |
| 9. Ghi nhận nhập | Warehouse Staff | Post phiếu nhập cho phần cửa hàng nhận sở hữu; giữ status “chờ kiểm” nếu chưa được bán. Hàng NCC lấy lại ngay không nhập vào tồn rồi xuất giả tạo. Hàng lỗi chuyển BF-02. | Phiếu nhập ghi đúng lượng; tồn tăng đúng status một lần. |
| 10. Put-away | Warehouse Staff | Chọn/gợi ý vị trí phù hợp; di chuyển vật lý; xác nhận lượng thực vào từng bin. Hàng đã nhập mà chưa xếp vẫn ở vị trí nhận/staging, chưa khả dụng lấy từ bin khác. | Vị trí tồn cập nhật; put-away không tăng tổng tồn lần hai. |
| 11. Đối chiếu và theo dõi còn thiếu | Accountant và WMSD | So lượng PO với các receipt đã post, lượng còn NCC hứa giao và lượng đã chốt hủy. Nếu còn giao, để mở; nếu NCC không giao tiếp, xin Owner chốt phần dư và lý do. Đối chiếu chứng từ tài chính thực hiện ngoài WMSD, lưu mã tham chiếu. | PO “Đang giao”, “Nhận một phần”, “Đã đóng” hoặc “Đã hủy phần còn lại”. |

### 4.3 Nhánh ngoại lệ và kết thúc

- **Đơn bán thiếu nhưng kho khác có hàng tương thích:** dừng đề nghị mua phần có thể đáp ứng; tạo gợi ý xuất trực tiếp hoặc điều chuyển theo BF-03. Nếu kho phụ xuất thẳng cho khách, việc xuất thực hiện theo BF-05 tại kho phụ.
- **Định mức bị vi phạm nhưng hàng đang về phù hợp:** request vẫn ghi lý do, nhưng hiển thị nguồn đang về để Owner quyết định có cần mua thêm hay không. Không đặt lặp chỉ vì tồn hiện tại thấp.
- **NCC giao thiếu:** receipt chỉ ghi thực giao; phần thiếu tiếp tục mở theo PO hoặc được chốt hủy có lý do. Không cộng số đặt hàng vào tồn.
- **NCC giao thừa:** tách lượng thừa; chỉ nhập vào tồn sở hữu khi có chấp nhận theo thẩm quyền. Nếu chưa chấp nhận, theo dõi giữ hộ và không cho bán.
- **Sai tone/calibre/lot:** không tự thay thế; giữ riêng, xin quyết định nhận/từ chối. Khi khách cần một tone cụ thể, Sales xác nhận phương án với khách ngoài WMSD.
- **Tất cả hàng bị từ chối:** vẫn lưu receipt/biên bản thực tế và kết quả trả đi; không tạo tồn cửa hàng giả.
- **Chứng từ nguồn cũ trước khi triển khai WMSD:** nhập mã tham chiếu đã xác minh; không tạo PO/receipt lịch sử giả chỉ để qua kiểm tra hệ thống.

### 4.4 Chứng từ, quyền và kết quả tồn

Chứng từ gồm Replenishment Request, PO, phản hồi NCC, từng Goods Receipt, phiếu nhập, nhiệm vụ put-away và biên bản sai lệch. Sales/Warehouse tạo request; Owner duyệt; Accountant lập PO; Warehouse kiểm và post receipt. Người tạo request không tự duyệt. Request, duyệt và PO không tăng tồn. Receipt chỉ tăng đúng lượng thuộc tồn của cửa hàng; hàng chờ kiểm/hỏng/giữ hộ giữ status riêng; put-away chỉ đổi vị trí và khả năng lấy hàng.

**Điều kiện đóng BF-01:** mọi lần giao đã có receipt hoặc biên bản; lượng PO còn thiếu đã được giao tiếp, theo dõi mở hoặc được Owner chốt hủy với lý do; lượng cửa hàng nhận đã được phân loại và theo dõi vị trí/trạng thái. Việc đóng PO kho không đồng nghĩa đã thanh toán hay hạch toán NCC.

## 5. BF-02 — Phát hiện, cách ly và xử lý hàng lỗi

### 5.1 Mục đích, trigger và vai trò

Trigger khi phát hiện gạch nứt, mẻ, sai quy cách, sai tone/calibre, hư bao bì ảnh hưởng chất lượng hoặc có dấu hiệu không thể xuất bình thường. Phát hiện có thể đến từ receipt BF-01, soạn hàng BF-05, điều chuyển BF-03, hàng trả BF-06 hoặc kiểm tra tại kho.

Warehouse Staff lập hồ sơ và cách ly; Store Owner duyệt cách xử lý; Accountant ghi chứng từ/tham chiếu NCC khi cần. Sales chỉ được thông báo ảnh hưởng đơn khách, không kết luận chất lượng.

### 5.2 Luồng chính

| Bước | Người thực hiện | Thao tác và điều kiện | Trạng thái/chứng từ sau bước |
|---|---|---|---|
| 1. Ghi nhận lỗi | Warehouse Staff | Chọn nguồn phát hiện, mã sản phẩm, lot/tone/calibre, kho/bin, lượng, thời điểm, mô tả và chứng cứ. Nếu lỗi thấy khi soạn, gắn issue request/picking task. | Defective Goods Case “Mới ghi nhận”. |
| 2. Cách ly tức thì | Warehouse Staff/WMSD | Chặn phân bổ/xuất số lượng nghi vấn ngay; chuyển vật lý tới vị trí cách ly nếu an toàn. Không chờ Owner duyệt mới chặn hàng có dấu hiệu lỗi. Nếu đã giữ cho đơn, báo lại lượng thiếu. | Quantity chuyển “Cách ly/Chờ kiểm”; tổng lượng sở hữu chưa tự giảm. |
| 3. Xác minh tình trạng | Warehouse Staff | Đếm lại, chụp ảnh, kiểm lot/tone/calibre và xác định hàng thuộc sở hữu cửa hàng hay đang giữ hộ. Không ghi hàng khách/NCC gửi thành tồn cửa hàng. | Phiếu kiểm tra, quantity và trách nhiệm sở hữu được xác nhận hoặc còn chờ. |
| 4. Đề xuất | Warehouse Staff | Chọn phương án theo tình trạng: kiểm lại rồi trở về đạt; tiếp tục giữ cách ly; trả NCC; hủy; hoặc chuyển loại được phép quản lý riêng. Ghi lượng cụ thể và chứng cứ. | Disposition Request “Chờ duyệt”. |
| 5. Duyệt phương án | Store Owner | Xem bằng chứng, nguyên nhân, lượng và tác động tồn. Duyệt hoặc trả về bổ sung; ghi người, thời gian, hành động và phiên bản lượng. | “Đã duyệt” hoặc “Cần bổ sung”; chưa tự post hủy/xuất trả. |
| 6. Thực hiện | Warehouse Staff | Phương án được duyệt mới thực hiện: kiểm lại/đổi quality; trả NCC nối BF-07; hủy thực tế có biên bản; các loại nghiệp vụ giữ chứng từ riêng. | Có movement/phiếu liên kết case; thực hiện một lần. |
| 7. Kiểm tra kết quả | Warehouse Staff; Owner khi cần | Đối chiếu lượng ban đầu với lượng đã tái phân loại, trả, hủy hoặc vẫn cách ly. Hồ sơ chưa xử lý hết tiếp tục mở. | Đóng case khi toàn bộ lượng có kết quả hoặc chuyển sang case liên kết còn mở. |

### 5.3 Nhánh ngoại lệ, chứng từ và tồn

- Hàng đạt sau kiểm tra: chuyển về quality “Đạt” bằng movement có log; nếu đổi bin, cập nhật bin thực tế.
- Hàng chưa thống nhất: tiếp tục cách ly; không bán hoặc chuyển liên kho.
- Hàng cửa hàng sở hữu được duyệt trả NCC: nối BF-07. BF-02 không ghi giảm khi BF-07 sẽ thực hiện xuất trả.
- Hàng được duyệt hủy: ghi nhận chứng cứ đã hủy và xuất giảm đúng lượng thực hủy. Nếu mới duyệt nhưng chưa hủy, chưa giảm.
- Hàng lỗi vốn đã bị từ chối ở cửa kho: theo custody/receipt exception; không tạo hàng tồn rồi xóa để làm đẹp số liệu.

**Chứng từ:** defective goods case, kết quả kiểm tra, disposition request/approval, phiếu chuyển vị trí/cách ly, biên bản hủy, phiếu xuất trả NCC nếu liên quan. **Điều kiện đóng:** từng đơn vị/lượng có vị trí, trạng thái và hành động cuối có thể truy ra. Cách ly và reclassify không đổi tổng lượng; hủy/xuất mới giảm theo đúng nghiệp vụ.

## 6. BF-03 — Chuyển vị trí và điều chuyển giữa kho

### 6.1 Phân loại trước khi thực hiện

Khi có nhu cầu di chuyển, đầu tiên chọn đúng loại:

- **Bin-to-bin cùng kho:** đổi vị trí trong một kho vật lý. Warehouse Staff thực hiện, không cần Owner duyệt.
- **Kho-to-kho trong cùng cửa hàng:** thay đổi địa điểm tồn vật lý. Cần Transfer Request (TR) được Owner duyệt, phiếu xuất ở kho đi, ghi lượng đang chuyển và phiếu nhập ở kho đến.
- **Xuất trực tiếp từ kho khác cho đơn bán:** không phải điều chuyển. Sales xác nhận nguồn phục vụ; Warehouse ở kho xuất làm BF-05.

### 6.2 Nhánh A — Chuyển vị trí trong kho

| Bước | Người thực hiện | Thao tác và điều kiện | Kết quả |
|---|---|---|---|
| 1. Chọn nguồn và đích | Warehouse Staff | Chọn bin nguồn/đích, sản phẩm, lot, tone, calibre, trạng thái và quantity thực tế định chuyển. Nguồn phải có lượng chưa bị giữ hoặc yêu cầu phải mang reservation theo. | Location Movement “Đang thực hiện”. |
| 2. Kiểm tra hợp lệ | WMSD | Kiểm tra cùng warehouse, bin hoạt động, quality được phép di chuyển, lượng không vượt nguồn, vị trí không bị khóa kiểm kê. | Hợp lệ mới cho xác nhận. |
| 3. Di chuyển thực tế | Warehouse Staff | Chuyển gạch và xác nhận số lượng đã đến vị trí đích. Chênh lệch được ghi nhận, không tự sửa lượng nguồn cho khớp. | Bằng chứng/quantity thực tế. |
| 4. Post movement | WMSD | Atomically giảm bin nguồn và tăng bin đích; bảo toàn product/lot/tone/calibre/status/reservation. | Movement “Hoàn tất”; tổng kho không đổi. |

### 6.3 Nhánh B — Điều chuyển giữa kho

| Bước | Người thực hiện | Thao tác và điều kiện | Trạng thái/chứng từ |
|---|---|---|---|
| 1. Phát hiện thiếu và chọn nguồn | Sales/Warehouse/WMSD | Sales ghi yêu cầu xuất còn thiếu hoặc Warehouse cân đối tồn. WMSD kiểm tra kho cấu hình có nguồn khả dụng đúng sản phẩm/lot/tone/calibre không. | Kết quả gợi ý nguồn; chưa đổi tồn. |
| 2. Quyết định phương án | Sales Staff | Chọn (a) xuất thẳng từ kho phụ nếu có thể giao khách, hoặc (b) yêu cầu chuyển về kho cần hàng. Xác nhận tương thích lot/tone; không tự thay sản phẩm. | Gợi ý được chấp nhận hoặc từ chối có lý do. |
| 3. Tạo TR | Warehouse Staff | Chọn kho nguồn, kho đích, item/lot, quantity, reason, expected date, liên kết yêu cầu thiếu và chứng từ. | TR “Chờ Owner duyệt”; chưa đổi tồn. |
| 4. Duyệt TR | Store Owner | Kiểm nhu cầu, nguồn khả dụng, lượng, điểm đến và người thực hiện. Duyệt hoặc từ chối/trả về với lý do. Người tạo không tự duyệt. | TR đã duyệt/từ chối; duyệt không làm đổi tồn. |
| 5. Lập phiếu xuất và chuẩn bị | Warehouse kho nguồn | Từ TR đã duyệt, xác nhận hàng thực tế, lot, tone, calibre, chất lượng và vị trí. Ghi lượng thực soạn. Không lập thêm một Transfer Order approval mới. | Outbound transfer draft. |
| 6. Bàn giao khỏi nguồn | Warehouse kho nguồn | Đếm khi xe/nhân viên rời kho; lập phiếu xuất điều chuyển và biên bản bàn giao, user/time/transport ref. | Post thực xuất: kho nguồn giảm; đúng lượng tăng vào In Transit. |
| 7. Nhận ở kho đích | Warehouse kho đích | Người nhận kiểm độc lập lượng giao, lot/tone/calibre/tình trạng. Nhập từng lượng chấp nhận vào kho đích/status phù hợp; put-away sau khi nhận. | Phiếu nhập điều chuyển; phần nhận chuyển khỏi In Transit. |
| 8. Đối chiếu | WMSD/Warehouse | So requested, dispatched, handed over, received accepted/damaged/rejected. Nếu khớp, hoàn tất. | TR “Hoàn thành” khi không còn lượng chưa có kết quả. |
| 9. Xử lý chênh lệch | Warehouse đề xuất; Owner duyệt | Lập case thiếu/thừa/sai lô/hỏng kèm ảnh, biên bản và lượng. Owner duyệt phương án; Warehouse thực hiện đúng phiên bản được duyệt. | Transfer difference “Đang xử lý”; chưa đóng trước khi cân bằng. |

### 6.4 Tác động tồn và trường hợp sai lệch

Ví dụ 100 thùng rời A, B nhận 98 trong đó 95 đạt và 3 vỡ. Ghi: A −100; In Transit −98; B +95 đạt, +3 cách ly; còn 2 đang chuyển/chưa rõ. Owner duyệt cách xử lý 2 thùng. Không giữ cả 98 ở In Transit sau khi B đã nhận, không coi 3 vỡ như hàng mất, không trừ thêm khi đóng hồ sơ.

Nếu mất được xác minh: ghi giảm phần đang chuyển bằng quyết định/movement có chứng cứ một lần. Nếu hàng quay về: tạo sự kiện nhận lại, kiểm tra rồi nhập kho. Nếu NCC/carrier nhận xử lý: ghi reference, không tự tăng/giảm tài chính. Giữ liên kết allocation cho đơn bán xuyên từ kho nguồn sang In Transit đến kho đích; hàng đó không trở thành rảnh trong lúc đang chuyển.

**Điều kiện đóng:** mọi lượng xuất đã được nhận, đang chuyển có người chịu trách nhiệm, hoặc có quyết định xử lý và chứng từ phù hợp. TR được duyệt không tự tạo phiếu xuất; phiếu nhập ở đích không được xác nhận bởi thao tác của kho nguồn.

## 7. BF-04 — Kiểm kê và điều chỉnh

### 7.1 Mục đích và phương án vận hành

Đếm thực tế theo phạm vi cụ thể, so với số liệu hệ thống tại một mốc, giải trình chênh lệch và chỉ điều chỉnh sau duyệt. Đề xuất baseline MVP: kiểm kê theo khu/vị trí có thể tạm khóa giao dịch tồn trong phạm vi đang đếm cho tới khi phiên kết thúc. Kho ngoài phạm vi vẫn hoạt động.

Nếu cửa hàng không thể khóa vị trí khi đếm, cần dùng phương án khác: snapshot + ledger các phát sinh sau cutoff + thời điểm đếm thực của từng dòng để tính tồn kỳ vọng. Không kết hợp nửa khóa/nửa đối soát mà không định nghĩa cách tính.

### 7.2 Luồng chính

| Bước | Người thực hiện | Thao tác và điều kiện | Trạng thái/chứng từ |
|---|---|---|---|
| 1. Lập phiên | Store Owner | Chọn kho, khu/vị trí, nhóm hàng/lot, ngày giờ, người đếm và phạm vi. Tránh phạm vi chồng lấn phiên khác. | Stocktake “Đã lập”; chưa chụp snapshot. |
| 2. Chuẩn bị phạm vi | Warehouse Staff | Xử lý/đánh dấu receipt, delivery, transfer đang dở trong phạm vi. Xác định hàng staging, cách ly, giữ hộ, đang chuyển. | Exception list trước kiểm kê. |
| 3. Kích hoạt cutoff | WMSD/Warehouse Staff | Kích hoạt phiên; WMSD lưu snapshot immutable theo bin/item/lot/status và thời gian; khóa giao dịch thay số lượng/vị trí trong phạm vi MVP; xuất danh sách kiểm kê. Có thể ẩn tồn sổ trên phiếu đếm. | Stocktake “Đang đếm”; snapshot không sửa được. |
| 4. Đếm thực tế | Warehouse Staff | Đi theo phạm vi vị trí; ghi thùng, viên, bao bì, tình trạng, người đếm và thời gian. Chưa đếm là null/chưa hoàn tất, không được coi bằng 0. Hàng ngoài danh sách lập dòng phát hiện mới. | Count attempt lần 1. |
| 5. Đếm lại nếu cần | Warehouse Staff khác hoặc người được phân công | Đếm lại item/lot/bin có variance, không ghi đè lần 1. Ghi lý do yêu cầu recount và người đếm lại. | Count attempt tiếp theo; giữ lịch sử. |
| 6. Đối chiếu | WMSD | So actual với snapshot theo item/lot/bin/status; phân biệt thiếu tổng lượng, thừa, sai bin, sai quality, lot chưa đăng ký và dòng chưa đếm. | Stocktake “Cần xử lý” hoặc “Không chênh”. |
| 7. Giải trình | Warehouse Staff | Tìm chứng từ nhập/xuất/chuyển, sai vị trí, vỡ, nhầm đơn vị, giao dịch chưa post; ghi nguyên nhân và bằng chứng. Nếu chỉ sai vị trí, đề xuất movement; nếu sai quality, đề xuất reclassify. | Variance explanation. |
| 8. Đề nghị điều chỉnh | Warehouse Staff | Chỉ với delta số lượng đã xác minh; chỉ rõ balance trước, delta ký dấu (+/−), balance sau dự kiến, bin/lot/status, nguyên nhân và chứng cứ. | Adjustment Request “Chờ Owner”. |
| 9. Duyệt | Store Owner | Xem snapshot, lần đếm, movement liên quan, lý do và phiên bản request. Duyệt, từ chối hoặc trả bổ sung theo quyền; lưu quyết định. | Chưa duyệt thì không đổi tồn. |
| 10. Clear Difference | Store Owner (theo UC-93 hiện có) | Mở đúng request đã duyệt, kiểm tra chưa post và phiên bản còn mới. Xác nhận post. | Phiếu điều chỉnh + ledger movement; idempotent. |
| 11. Kết thúc phiên | WMSD/Store Owner | Nếu không chênh hoặc mọi chênh đã post/giải quyết, đóng phiên và mở khóa phạm vi. Lưu toàn bộ phiếu, snapshot, lần đếm, giải trình và quyết định. | Stocktake “Hoàn thành”. |

### 7.3 Quy tắc chênh lệch

- Nếu đếm tổng 50 thùng gồm 48 đạt và 2 vỡ, tổng vật lý vẫn là 50; xử lý chất lượng 2 thùng, không ghi thiếu 2 rồi lại hủy 2.
- Nếu snapshot 50, thực đếm 48 trong khu đã khóa: đề nghị −2; cho tới khi Owner duyệt và Clear Difference, balance vẫn theo 50.
- Nếu không thấy hàng ở vị trí cũ nhưng tìm thấy tại vị trí khác cùng kho: ưu tiên movement vị trí, không điều chỉnh tổng kho.
- Nếu có dòng chưa đếm, phiên không được kết thúc như không chênh.
- Điều chỉnh approved phải gắn phiên bản variance; không post hai lần; không dùng số đếm cũ ghi đè toàn bộ tồn hiện tại.

**Điều kiện đóng:** mọi dòng trong phạm vi có kết quả đếm; mọi variance đã được giải trình, điều chỉnh theo quyền hoặc chuyển thành case xử lý rõ; snapshot và audit history được giữ nguyên.

## 8. BF-05 — Yêu cầu xuất, soạn và bàn giao hàng

### 8.1 Điều kiện bắt đầu và dữ liệu yêu cầu

Sales Staff tạo Warehouse Issue Request từ đơn bán đã xử lý ở MISA/hệ thống ngoài, với mã nguồn, dòng nguồn, khách/người nhận, sản phẩm, quantity, đơn vị, yêu cầu lot/tone/calibre nếu có, kho dự kiến, ngày cần, nơi nhận và đợt giao. Tạo request không tạo giao dịch bán, hóa đơn, thanh toán hoặc trừ tồn.

Một yêu cầu có thể giao nhiều đợt; mỗi đợt có Outbound Delivery riêng và gắn một kho xuất. Nếu nhiều kho cùng đáp ứng, mỗi kho có một đợt/phần quantity riêng, cùng tham chiếu dòng yêu cầu nguồn.

### 8.2 Luồng chính

| Bước | Người thực hiện | Thao tác và điều kiện | Trạng thái/chứng từ |
|---|---|---|---|
| 1. Tạo yêu cầu xuất | Sales Staff | Nhập source order/line, product, quantity, unit, customer/receiver, requested date/location và lot/tone preferences. Hệ thống chống tạo trùng theo source+line+delivery batch. | Issue Request “Mới”. |
| 2. Xác thực | WMSD | Kiểm nguồn hợp lệ, lượng đã xuất/còn lại/đã giữ, tồn usable theo lot/bin và đơn vị sản phẩm. Từ chối quantity vượt outstanding. | Request hợp lệ/chờ bổ sung/lỗi cần Sales sửa. |
| 3. Tìm nguồn và phân bổ | WMSD; Sales xác nhận nguồn phù hợp | Gợi ý bin/lot tương thích theo hàng khả dụng; trong tập hợp tương thích ưu tiên FIFO theo ngày nhập nếu không có yêu cầu khác. Sales xác nhận thay lot/tone khi khách có yêu cầu cụ thể. | Quantity được reserve; chưa trừ tổng tồn. |
| 4. Thiếu nguồn | Sales Staff/WMSD | Xem khả dụng ở kho khác. Chọn xuất trực tiếp từ kho đó (đi BF-05 ở kho phụ), yêu cầu chuyển theo BF-03, hoặc tạo đề nghị bổ sung BF-01. Sales báo khách về phần giao từng phần/chờ theo thỏa thuận ngoài WMS. | Request “Chờ nguồn” hoặc “Phân bổ một phần”. |
| 5. Lập đợt giao/nhiệm vụ soạn | Sales hoặc Warehouse theo phân quyền đã chốt | Chọn kho, quantity và ngày đợt; WMSD tạo picking task theo bin/lot. Không kéo quantity vượt phần đã phân bổ. | Outbound Delivery “Chờ soạn”. |
| 6. Soạn thực tế | Warehouse Staff | Tới bin, xác minh product/lot/tone/calibre, lấy và đếm thực tế, ghi người/time. Nếu nhiều thùng/viên lẻ, ghi đúng unit và conversion. | Picking “Đang thực hiện”. |
| 7. Xử lý thiếu/hỏng | Warehouse Staff | Nếu thiếu, nhầm lô, gạch vỡ hoặc lệch số, ghi variance và ảnh; chặn quantity ảnh hưởng; chuyển case hàng lỗi BF-02 nếu cần; cập nhật đề xuất thay nguồn/phần giao. Không tự sửa tồn để đủ đơn. | Picking exception; request trở lại “Chờ xử lý nguồn”. |
| 8. Xác nhận soạn và staging | Warehouse Staff | Kiểm đếm lần cuối, đóng kiện/ghi nhãn, chuyển tới staging và xác nhận lượng đã soạn. Nếu giao không đủ, lưu rõ phần đã soạn và phần còn lại. | Picking “Đã xác nhận”; staging quantity được giữ, tổng kho chưa giảm. |
| 9. Bàn giao và PGI | Warehouse Staff | Đối chiếu phiếu với hàng thực giao, ghi người nhận/vận chuyển, thời gian và chứng cứ. Chỉ khi hàng thực rời quyền kiểm soát kho mới post Goods Issue cho lượng thực giao. | PGI post một lần; tổng kho giảm đúng actual dispatched. |
| 10. Hoàn tất đợt và cập nhật nguồn | WMSD; Sales xem trạng thái | Cập nhật lượng xuất, còn lại, reservation, mã phiếu để Accountant/Sales đối chiếu với nguồn MISA. Hệ thống có thể gửi thông báo sau commit nếu cấu hình SMTP. | Delivery “Đã giao cho carrier/đã xuất kho”; request đóng khi đủ hoặc phần dư được xử lý. |

### 8.3 Ngoại lệ và tác động tồn

- **Bàn giao thất bại trước PGI:** chưa giảm tổng kho; hàng ở staging vẫn được giữ cho request hoặc hoàn vị trí bằng movement.
- **Đã PGI nhưng khách chưa nhận:** trạng thái “đã rời kho/chưa xác nhận giao cuối” theo bằng chứng carrier. Không đánh đồng PGI với xác nhận khách nhận.
- **Xuất một phần:** post phần đã giao; phần còn lại tiếp tục outstanding và reservation theo quyết định giao tiếp/chờ/hủy.
- **Nhấn post lại/timeout:** hệ thống trả trạng thái kết quả đã post; không tạo movement thứ hai.
- **Trả hàng sau khi đã xuất:** xử lý BF-06 với tham chiếu issue gốc; không xóa PGI.

**Chứng từ:** Issue Request, Outbound Delivery, Picking Task, exception report, phiếu xuất/Goods Issue, biên bản bàn giao, mã đơn tham chiếu ngoài WMSD. Bàn giao cho carrier làm đóng bước kho; xác nhận giao tới công trình là dữ liệu ngoài WMS nếu không triển khai tracking.

## 9. BF-06 — Tiếp nhận trả hàng từ khách và phân loại

### 9.1 Mục đích và nguyên tắc

Quản lý phần hàng vật lý khách đem trả, truy xuất đơn/phiếu xuất nguồn, kiểm số lượng và chất lượng, rồi tách hàng đạt, lỗi, giữ hộ hoặc từ chối. Sales Staff tiếp nhận điều kiện thương mại và nguồn chứng từ; Warehouse Staff thẩm định thực tế; Store Owner quyết định cửa hàng chấp nhận nhận lại. WMSD không tự tính/chi hoàn tiền và không sửa chứng từ bán hàng gốc.

### 9.2 Luồng chính

| Bước | Người thực hiện | Thao tác và điều kiện | Trạng thái/chứng từ |
|---|---|---|---|
| 1. Lập return request | Sales Staff | Chọn mã đơn/phiếu xuất nguồn, dòng sản phẩm, số lượng đề nghị, lý do, ngày và thông tin khách. Nếu đơn cũ chưa có WMSD issue, yêu cầu nguồn ngoài đã xác minh. | Customer Return Request “Mới”. |
| 2. Xác thực nguồn | WMSD/Sales Staff | Đối chiếu quantity đã xuất, đã nhận trả, đang chờ; đảm bảo đề nghị không trùng/vượt phần hợp lệ. Sai source/quantity thì yêu cầu sửa hoặc từ chối kèm lý do. | “Chờ hàng về” hoặc “Không hợp lệ”. Chưa đổi tồn. |
| 3. Tiếp nhận vật lý | Warehouse Staff | Khi khách giao hàng, đếm thực tế và so sản phẩm, lot/tone/calibre/bao bì. Lập biên bản custody cho lượng đang giữ chờ kiểm/Owner. Tách lượng khách vẫn sở hữu nếu cửa hàng chưa nhận trách nhiệm. | Return Receipt “Chờ kiểm/giữ hộ”; chưa khả dụng. |
| 4. Kiểm chất lượng | Warehouse Staff | Kiểm từng quantity; chia: đạt nguyên trạng; cần xem xét/hỏng; thiếu/sai lot; thùng mở hoặc không đủ đơn vị bán. Ảnh/chứng cứ gắn với từng dòng. Sales không thực hiện kết luận kỹ thuật. | Inspection result theo từng lượng. |
| 5. Owner quyết định nhận trả | Store Owner | Dựa vào nguồn, số lượng thực nhận, kiểm tra và điều kiện trả đã thỏa thuận. Quyết định nhận đủ/một phần/từ chối phần nào; ghi lý do và user/time. | Decision version; chưa post tới khi khớp lượng đã quyết định. |
| 6. Nhập lượng đạt được nhận | Warehouse Staff | Lập phiếu nhập trả gắn issue nguồn; nhập đúng lot, quality và bin. Chỉ đưa thành usable sau khi quality đạt và put-away hoàn tất. | Phiếu nhập; usable quantity chỉ tăng đúng lượng đủ điều kiện. |
| 7. Cách ly lượng lỗi được nhận | Warehouse Staff | Lập receipt line riêng chất lượng cách ly; nối BF-02 hoặc BF-07 nếu chờ trả NCC. | Tồn sở hữu tăng ở cách ly nếu cửa hàng đã chấp nhận nhận; chưa usable. |
| 8. Bàn giao phần từ chối | Sales/Warehouse Staff | Với lượng không nhận trả, thông báo khách; giữ ở custody cho tới khi giao lại thực tế; lập xác nhận bàn giao. | Custody giảm khi khách nhận lại; không cộng/trừ tồn sở hữu. |
| 9. Đối chiếu và hoàn tất kho | WMSD/Warehouse Staff | Reconcile lượng khách mang đến = lượng nhận đạt + lượng nhận cách ly + lượng từ chối trả lại + chênh lệch được giải trình. Lưu kết quả và reference chứng từ ngoài. | Return Request đóng phần kho hoặc mở chờ xử lý. |
| 10. Chuyển thông tin cho kế toán | Accountant | Nhận phiếu nhập, biên bản và mã nguồn để xử lý chứng từ/hóa đơn/hoàn tiền theo quy định và thỏa thuận bên ngoài WMSD; ghi mã tham chiếu khi có. | Trạng thái tài chính theo dõi riêng; không đổi tồn lần nữa. |

### 9.3 Ví dụ tách lượng và đóng hồ sơ

Khách mang 10 thùng cùng dòng hàng: kiểm thấy 7 thùng đạt và Owner đồng ý nhận, 2 thùng vỡ được nhận để xử lý khiếu nại, 1 thùng sai nguồn bị từ chối. Kết quả WMS: +7 usable sau put-away; +2 cách ly nếu cửa hàng nhận sở hữu; 1 thùng custody cho tới khi giao lại khách. Không ghi cả 10 thành hàng bán được.

Nếu chưa có căn cứ xác minh chứng từ gốc, hàng có thể được đếm và giữ hộ nhưng chưa được tự ghi tăng tồn sở hữu. Nếu đã nhận lại một phần, phiếu nhập chỉ gồm lượng thực được quyết định nhận; phần bị từ chối vẫn phải có kết quả bàn giao. Phần kế toán/hóa đơn không bắt buộc đóng cùng thời điểm với phần kho.

**Chứng từ:** Return Request, nguồn sale/issue, biên bản nhận/custody, phiếu kiểm tra và ảnh, quyết định Owner, phiếu nhập trả, chứng từ bàn giao khách, mã tham chiếu xử lý ngoài WMSD. Chứng từ gốc vẫn giữ nguyên; xử lý điều chỉnh hóa đơn do Accountant theo trường hợp thực tế.

## 10. BF-07 — Trả hàng cho nhà cung cấp

### 10.1 Trigger và điều kiện đầu vào

Khởi động khi hàng mua đã được cửa hàng nhận nhưng phát hiện sai hàng, sai lot/tone/calibre, lỗi chất lượng hoặc NCC đồng ý nhận lại; có thể bắt đầu từ BF-01, BF-02 hoặc hàng thay thế/trả về từ BF-06. Request cần NCC, PO/receipt nguồn, sản phẩm/lot/bin, lượng, lý do, trạng thái ownership, bằng chứng và tình trạng cách ly.

Tách hai trường hợp: (a) hàng đã vào tồn sở hữu, khi thực xuất trả làm giảm tồn một lần; (b) hàng bị từ chối ngay khi nhận và chỉ đang giữ hộ NCC, khi giao trả chỉ đóng custody, không trừ tồn sở hữu.

### 10.2 Luồng chính

| Bước | Người thực hiện | Thao tác và điều kiện | Trạng thái/chứng từ |
|---|---|---|---|
| 1. Tạo request | Warehouse Staff | Chọn nguồn receipt/PO, lot, vị trí, quantity, lý do, evidence và ownership. Không được đề nghị vượt lượng đang có/được giữ. | Supplier Return Request “Mới”. |
| 2. Cách ly/reserve | Warehouse Staff/WMSD | Chặn quantity khỏi bán/điều chuyển bình thường. Ghi rõ lượng thuộc tồn sở hữu hay custody của NCC. Nếu chưa đủ evidence, không xuất. | “Chờ NCC/Owner”; khả dụng giảm với hàng sở hữu được reserve, tổng chưa đổi. |
| 3. Đối chiếu chứng từ | Accountant | Kiểm PO, receipt, tình trạng hàng, chứng từ nhà cung cấp và phần đã xử lý. Yêu cầu sửa lượng hoặc bổ sung chứng cứ khi không khớp. | Request đủ cơ sở trao đổi. |
| 4. Ghi thỏa thuận NCC | Accountant | Liên hệ NCC ngoài hệ thống; ghi lượng NCC nhận, lịch lấy/giao, phương thức và mã tham chiếu/biên bản. Phản hồi không đồng ý hoặc đề xuất phương án khác cũng được lưu. | “NCC đồng ý”, “NCC từ chối” hoặc “Đề nghị thay đổi”. Chưa đổi tồn. |
| 5. Duyệt xuất trả | Store Owner | Xem lượng có thể xuất, thỏa thuận NCC, ownership, chứng cứ, ảnh hưởng tồn và phương án. Owner duyệt lượng tối đa/lot cụ thể hoặc trả về/từ chối. Nếu BF-02 đã có quyết định trả NCC cùng lượng, tham chiếu lại đúng quyết định để tránh duyệt trùng; khác quantity cần quyết định mới. | Approved Return Dispatch; chưa giảm tồn. |
| 6. Soạn và kiểm | Warehouse Staff | Lấy đúng lot/quality/vị trí đã duyệt, đếm thùng/viên, kiểm kiện và đối chiếu nhãn. Sai quantity thì recount; không tự thay lot. | Danh sách chuẩn bị hàng trả. |
| 7. Xuất và bàn giao | Warehouse Staff | Lập phiếu xuất trả; ghi người giao, carrier/NCC nhận, giờ và bằng chứng bàn giao. Chỉ post actual dispatched. | Hàng ownership: tồn giảm đúng actual một lần. Hàng custody: custody giảm, tồn sở hữu giữ nguyên. |
| 8. Ghi NCC xác nhận nhận | Accountant | Sau khi NCC nhận thực tế, ghi quantity acknowledged, thời điểm, chứng từ/bằng chứng. Không chỉnh phiếu xuất theo số NCC xác nhận. | Acknowledgement riêng với dispatch. |
| 9. Đối chiếu | WMSD, Warehouse, Accountant | So approved, picked, dispatched và acknowledged. Khớp thì chuyển chờ Owner đóng; lệch thì giữ hồ sơ mở và lập discrepancy. | Return “Đã đối chiếu” hoặc “Đang sai lệch”. |
| 10. Xử lý sai lệch và đóng | Store Owner; Warehouse/Accountant thực hiện phần được giao | Owner duyệt phương án: nhận lại hàng, bổ sung chứng từ, chấp nhận ghi nhận sai lệch theo căn cứ nội bộ hoặc mở khiếu nại NCC. Hàng quay về phải được nhận/kiểm như một receipt mới. Owner đóng khi mọi quantity có trạng thái cuối và reference. | Case đóng hoặc tiếp tục mở; đóng không post giảm tồn thêm. |

### 10.3 Ngoại lệ

- NCC từ chối nhận: giữ hàng ở cách ly; Owner quyết định thương lượng, xử lý theo chất lượng hoặc phương án khác. Không tự trả lại usable.
- NCC nhận một phần: xuất đúng lượng được duyệt/chuẩn bị; phần còn lại request mở.
- Hàng hỏng trên đường trả: giữ dispatch và acknowledgement khác nhau; mở sai lệch, không sửa quantity gốc.
- Hàng được thay thế: receipt mới theo BF-01, liên kết return cũ; không cộng tồn khi NCC mới hứa đổi.
- Hàng nguồn bị từ chối lúc nhận: không có stock outbound của cửa hàng; chỉ giảm custody khi đã bàn giao cho NCC.
- Nhiều loại quality trong một lô trả: tách dòng theo bin/status và lượng; không gộp chứng từ làm mất dấu hàng lỗi.

**Chứng từ:** Supplier Return Request, source PO/receipt, biên bản NCC, Owner approval, picking/phiếu xuất trả, handover evidence, supplier acknowledgement, discrepancy resolution và tham chiếu chứng từ tài chính bên ngoài. Accountant đối chiếu giảm trừ/công nợ trong phần mềm kế toán; WMSD không thanh toán hoặc tự ghi nợ NCC.

## 11. Ranh giới phê duyệt và sự kiện cập nhật tồn

| Sự kiện | Ai có quyền | Tác động tồn |
|---|---|---|
| Tạo/duyệt đề nghị bổ sung, tạo PO | Sales/Warehouse tạo; Owner duyệt; Accountant lập PO | Không đổi tồn. |
| Receipt đã xác minh ownership và post | Warehouse Staff | Tăng đúng status/lot/bin; không tự đưa hàng chờ kiểm vào usable. |
| Put-away | Warehouse Staff | Chuyển vị trí, không tăng tổng lần hai. |
| Di chuyển bin nội bộ | Warehouse Staff | Nguồn −n, đích +n cùng kho; tổng giữ nguyên. |
| Duyệt TR | Store Owner | Không đổi tồn. |
| Phiếu xuất điều chuyển | Warehouse kho nguồn | Nguồn giảm, In Transit tăng đúng lượng thực rời nguồn. |
| Phiếu nhập điều chuyển | Warehouse kho đích | In Transit giảm, kho đích tăng theo quantity/status thực nhận. |
| Tạo yêu cầu/picking/staging | Sales/Warehouse | Reserve làm giảm khả dụng; staging chuyển vị trí; chưa giảm tổng kho. |
| PGI sau bàn giao thật | Warehouse Staff | Giảm lượng thực xuất một lần. |
| Tiếp nhận hàng khách trả chờ quyết định | Warehouse Staff | Ghi custody; không làm tăng tồn sở hữu hoặc usable. |
| Phiếu nhập trả được duyệt | Warehouse Staff | Tăng theo ownership, quality, lot và vị trí; chỉ usable khi đủ điều kiện. |
| Tạo/duyệt trả NCC | Warehouse/Owner | Reserve hoặc cách ly; chưa giảm tổng kho. |
| Xuất hàng sở hữu cho NCC | Warehouse Staff | Giảm actual dispatch một lần. Giao lại custody NCC chỉ giảm custody. |
| Snapshot/đếm/đếm lại | Owner/Warehouse | Không tự sửa tồn. |
| Owner Clear Difference | Store Owner (theo UC-93 hiện hành) | Post delta đã duyệt một lần; log trước/sau và phiên bản. |
| Cách ly/hàng lỗi | Warehouse cách ly; Owner duyệt phương án | Chuyển quality không giảm tổng; chỉ xuất/hủy thực tế mới giảm. |

## 12. Danh sách điều kiện và chứng từ tối thiểu mỗi hồ sơ

Mỗi giao dịch ghi mã hồ sơ duy nhất, loại nghiệp vụ, trạng thái, người tạo, người duyệt (nếu có), người thực hiện, ngày giờ, kho/vị trí, sản phẩm, đơn vị và hệ số quy đổi, lot/tone/calibre, quantity theo từng trạng thái, reason, evidence, source document/line và lịch sử thay đổi. Post phải gắn movement ledger có quantity trước/sau, correlation/idempotency key và actor/time.

Trường thông tin nào chưa được Report 1/Report 3 hoặc khảo sát xác nhận thì ghi là “đề xuất” hoặc “cần xác nhận”; không biến ngày giao, mức tối thiểu, kỳ kiểm kê, phí trả hàng, loại phương tiện, quy tắc ưu tiên kho hay số người thành dữ kiện đã biết.

## 13. Việc cần khảo sát để chốt bản cuối

1. Số kho vật lý thực tế, địa chỉ và kho nào có thể giao trực tiếp cho khách.
2. Ai lập nhu cầu Sales/Warehouse, ai duyệt thay khi Owner vắng và ai nhận độc lập khi điều chuyển.
3. MISA eShop đang lưu product, lot, vị trí và phiếu nhập/xuất tới mức nào; cách nhóm đối chiếu tồn WMSD/MISA.
4. Product master có đủ conversion thùng/viên/m², độ mở thùng, cách ghi tone/calibre và yêu cầu khách chọn cùng lô không.
5. Chính sách thực nhận/trả gạch nguyên thùng, thùng lẻ, gạch đã thi công, bao bì rách và trường hợp hàng sai tone.
6. Quyền sở hữu hàng NCC chưa chấp nhận và hàng khách mang trả trước khi quyết định được lập như thế nào tại cửa hàng.
7. Có thể khóa từng khu trong phiên kiểm kê không; nếu không, dùng snapshot cùng ledger các phát sinh sau cutoff.
8. Mức tồn tối thiểu, kho ưu tiên và điều kiện giao từng phần là gì; ai chịu trách nhiệm cập nhật tham số.

## 14. Hướng dẫn đồng bộ tài liệu và sơ đồ

| Tài liệu | Cập nhật cần thực hiện |
|---|---|
| Report 1 | Giữ As-is theo kết quả khảo sát; sửa phần Proposed Solution, scope, features và limitations để khớp bảy BF. Đưa BF-02 vào bộ hình To-be. |
| Report 3 | Thay trigger, steps, decisions, end state của BF-01–07; đồng bộ context, actor list, UC catalogue/diagrams, permission matrix, data rules, screen list/API/jobs. |
| Use case specifications | Với từng UC, ghi rõ actor, precondition, input, validation, normal/alternative flow, postcondition và thời điểm duy nhất có tác động tồn. |
| Business rules | Đồng nhất một bộ quy tắc về tương thích lot/tone/calibre, phân quyền, reservation, in-transit, partial receipt/issue, snapshot và chống post trùng. Sửa tất cả tham chiếu UC cũ/sai. |
| Slide | Dùng cùng tên, mã, actor, quyết định và kết quả như Report 1/3. Slide được rút gọn bằng subprocess có mã, không tự vẽ workflow khác. |
| Context diagram | Chỉ vẽ dữ liệu qua biên phần mềm. Không thể hiện hàng vật lý như API. Không vẽ integration MISA trực tiếp nếu scope chưa có. |

## 15. Căn cứ thiết kế

- Review1 yêu cầu nguồn nhu cầu mua đến từ Sales thiếu đơn hoặc kho/kiểm kê; tách chuyển vị trí với điều chuyển liên kho; có phiếu xuất/nhập ở hai đầu; nêu nhánh thiếu/hỏng khi soạn; phân biệt hàng trả đạt và hỏng; chụp snapshot và duyệt điều chỉnh.
- Report 1 ghi nhận một cửa hàng Tân Thương đang dùng MISA eShop, còn thao tác kho một phần thủ công; trọng tâm là lô, tone, calibre, location, partial receipt, return và count variance.
- Report 3 có 7 BF nhưng vẫn giữ một số actor/flow chưa khớp review1. Các mã BF được giữ để việc đối chiếu bớt xáo trộn.
- SAP Global Bike WM I–IV được dùng làm tham khảo cho receipt/put-away, chuyển kho hai đầu, picking/PGI và inventory count/recount. Các phòng ban, hệ thống tài chính và số kho trong case SAP không được áp trực tiếp sang Tân Thương.
- Hướng dẫn MISA eShop/SME được dùng để tham khảo cấu trúc chứng từ mua/nhập, chuyển kho, bán/xuất, trả hàng và kiểm kê. Tính năng/cấu hình trên tài khoản của cửa hàng cần được xác nhận; các bước thanh toán/kế toán nằm ngoài WMSD.

**Kết luận quy trình mua hàng:** Sales Staff phát hiện thiếu hàng gắn với đơn bán **hoặc** Warehouse Staff phát hiện thiếu theo tồn kho/kiểm kê đều có thể tạo đề nghị. Sau đó WMSD đối chiếu tồn, lượng đã giữ, PO và điều chuyển đang về; Owner duyệt nhu cầu; Accountant lập PO; Warehouse nhận, kiểm và nhập hàng theo kết quả thực tế. Tín hiệu thiếu không đồng nghĩa đặt mua tự động.
