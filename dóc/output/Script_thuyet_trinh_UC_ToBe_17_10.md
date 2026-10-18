# SCRIPT THUYẾT TRÌNH WMSD — USE CASE VÀ TO-BE BUSINESS FLOW

Nguồn: 5 trang “Bản sao của UC Accountants”, “Bản sao của UC Admin”, “Bản sao của UC SS”, “Bản sao của UC_IS”, “Bản sao của UC SO” trong `WMSD_Bangach17_10.drawio`; trang “To-be” trong `Business_Process.drawio`.

Thứ tự: Accountant → Admin → Sales Staff → Inventory Staff → Store Owner → To-be Business Flow. Hai vai trò Inventory Staff và Store Owner trình bày theo các cụm chức năng từ dưới lên. Trong từng cụm, giới thiệu mục đích trước rồi giải thích các thao tác liên quan, không đọc từng hình oval theo tọa độ.

Thời lượng gợi ý: khoảng 15–18 phút, tùy tốc độ nói và thời gian chỉ sơ đồ. Nội dung trong ngoặc vuông là chỉ dẫn thao tác, không đọc thành lời.

## 1. Mở đầu

“Em xin trình bày phần Use Case và quy trình nghiệp vụ To-be của hệ thống WMSD, hệ thống hỗ trợ quản lý kho và các nghiệp vụ liên quan tại cửa hàng gạch.

Trước hết, em sẽ trình bày phạm vi chức năng của năm vai trò theo thứ tự: kế toán, quản trị viên, nhân viên bán hàng, nhân viên kho và chủ cửa hàng. Sau đó, em sử dụng quy trình mua hàng và nhận hàng để minh họa cách các vai trò phối hợp với nhau.

Ở phần Use Case, em sẽ đi theo từng nhóm nghiệp vụ để làm rõ mỗi vai trò có thể xem thông tin gì, thực hiện thao tác gì và tham gia vào khâu nào của quy trình.”

## 2. Accountant — Kế toán

[Mở trang “Bản sao của UC Accountants”. Đi từ các nhóm phía trên xuống dưới.]

“Đầu tiên là Accountant, tức kế toán. Vai trò này tham gia vào việc theo dõi mua hàng, quản lý chứng từ và đối chiếu thông tin giữa các nghiệp vụ.

Ở nhóm phía trên, kế toán có thể xem danh sách và chi tiết sản phẩm, xem phiếu nhập, cũng như tra cứu thông tin nhà cung cấp. Với nhà cung cấp, kế toán còn có thể tạo mới và cập nhật thông tin. Ngoài ra, chức năng Record Supplier Confirmation cho phép ghi nhận xác nhận từ nhà cung cấp để phục vụ việc theo dõi đơn mua.

Tiếp theo là nhóm bổ sung hàng và tồn kho. Kế toán có thể xem danh sách, chi tiết và tạo yêu cầu bổ sung hàng, đồng thời xem tồn kho để có thông tin phục vụ việc lập yêu cầu. Kế toán cũng được tra cứu danh sách và chi tiết hàng trả, cùng các yêu cầu trả hàng cho nhà cung cấp.”

[Chỉ cụm View Purchase Order List và các chức năng xung quanh.]

“Đối với đơn mua hàng, kế toán có thể xem danh sách, xem chi tiết, tạo và cập nhật đơn mua. Khi có phần hàng chưa được nhận cần ngừng theo dõi tiếp, hệ thống có chức năng hủy số lượng chưa nhận. Điểm cần phân biệt ở đây là xử lý phần số lượng còn lại của đơn, vì đơn có thể đã được nhận một phần trước đó.

Ở nhóm tiếp theo, kế toán được xem thông tin khách hàng và bảng giá bán. Với hóa đơn nội bộ, kế toán có thể xem danh sách, xem chi tiết, tạo hóa đơn, phát hành hóa đơn và xuất PDF.

Khi có nghiệp vụ hoàn tiền do khách trả hàng, kế toán có thể xem yêu cầu hoàn tiền, tạo yêu cầu hoàn tiền và ghi nhận việc hoàn tiền đã hoàn tất. Phần xem xét yêu cầu hoàn tiền sẽ được trình bày ở vai trò chủ cửa hàng.

Cuối cùng, kế toán có thể theo dõi nhật ký biến động tồn kho, xem chi tiết từng biến động, truy vết lô sản phẩm thông qua chứng từ nguồn và xem báo cáo hoạt động. Các chức năng này giúp kế toán đối chiếu số liệu và tìm lại căn cứ của các nghiệp vụ đã phát sinh.

Như vậy, trọng tâm của kế toán là kết nối dữ liệu mua hàng, chứng từ và hoàn tiền với thông tin thực tế từ kho.”

## 3. Admin — Quản trị viên

[Mở trang “Bản sao của UC Admin”. Chỉ chức năng phân quyền, sau đó cụm quản lý tài khoản.]

“Tiếp theo là Admin, tức quản trị viên hệ thống.

Vai trò này có hai nhóm chức năng chính. Nhóm thứ nhất là gán vai trò và quyền thao tác cho người dùng, giúp mỗi nhân viên được sử dụng những chức năng phù hợp với nhiệm vụ của mình.

Nhóm thứ hai là quản lý tài khoản nhân viên. Admin có thể xem danh sách và chi tiết tài khoản, tạo tài khoản mới, cập nhật thông tin, cũng như kích hoạt hoặc vô hiệu hóa tài khoản.

Ví dụ, khi một nhân viên mới bắt đầu làm việc, Admin tạo tài khoản và gán vai trò tương ứng. Khi cần ngừng quyền truy cập của tài khoản đó, Admin sử dụng chức năng vô hiệu hóa.

Trong sơ đồ này, phạm vi của Admin tập trung vào tài khoản và quyền truy cập hệ thống.”

## 4. Sales Staff — Nhân viên bán hàng

[Mở trang “Bản sao của UC SS”. Đi từ trên xuống.]

“Vai trò thứ ba là Sales Staff, tức nhân viên bán hàng.

Trước khi lập đơn, nhân viên có thể xem danh sách, chi tiết sản phẩm và kiểm tra tồn kho. Tiếp theo, nhân viên được xem danh sách và chi tiết khách hàng, tạo khách hàng mới hoặc cập nhật thông tin khách hàng hiện có.

Nhân viên bán hàng cũng được tra cứu bảng giá và chi tiết giá bán. Đây là thông tin phục vụ việc tư vấn và lập đơn cho khách.”

[Chỉ cụm Sales Order.]

“Ở nhóm đơn bán hàng, nhân viên có thể xem danh sách, xem chi tiết, tạo và cập nhật đơn bán. Nếu phần số lượng còn lại của đơn không tiếp tục thực hiện, nhân viên có thể sử dụng chức năng Cancel Outstanding Sales Order Quantities để hủy phần số lượng đó.

Sau nhóm đơn bán là nhóm giao hàng. Nhân viên bán hàng có thể xem danh sách, chi tiết và tạo Outbound Delivery, tức hồ sơ giao hàng đầu ra. Các thao tác chuẩn bị hàng và ghi nhận xuất kho sẽ được trình bày tiếp ở vai trò nhân viên kho.

Cuối cùng, nhân viên bán hàng có thể xem danh sách và chi tiết khách trả hàng để theo dõi các phát sinh sau bán.

Như vậy, vai trò này phụ trách thông tin khách hàng, đơn bán và việc tạo hồ sơ giao hàng, đồng thời có quyền tra cứu sản phẩm, giá bán và tồn kho để phục vụ công việc.”

## 5. Inventory Staff — Nhân viên kho, trình bày từ dưới lên

[Mở trang “Bản sao của UC_IS”. Bắt đầu ở cụm Customer Return dưới cùng, sau đó dịch màn hình dần lên.]

“Tiếp theo là Inventory Staff, tức nhân viên kho. Với sơ đồ này, em xin trình bày từ dưới lên, bắt đầu ở nghiệp vụ nhận hàng khách trả và kết thúc ở thông tin sản phẩm, lô hàng.”

### 5.1. Khách trả hàng

[Chỉ View customer return list và các chức năng bên phải.]

“Ở dưới cùng là nhóm khách trả hàng. Nhân viên kho có thể xem danh sách, xem chi tiết, tạo yêu cầu trả hàng, kiểm tra hàng trả và xác nhận nhận lại hàng.

Nhóm chức năng này thể hiện phần xử lý hàng hóa thực tế của nhân viên kho. Việc xem xét yêu cầu trả hàng và xử lý hoàn tiền được phân chia cho các vai trò liên quan.”

### 5.2. Xuất kho, lấy hàng và hồ sơ giao hàng

[Di chuyển lên lần lượt: Goods Issue → Picking Transfer Order → Outbound Delivery.]

“Đi lên là nhóm xuất kho. Nhân viên có thể xem danh sách, chi tiết phiếu xuất và thực hiện Post Goods Issue để ghi nhận xuất kho.

Liền kề là nhóm Picking Transfer Order, tức lệnh di chuyển hàng phục vụ lấy hàng. Nhân viên kho có thể xem danh sách, chi tiết, tạo và xác nhận lệnh lấy hàng.

Ở phía trên nữa, nhân viên kho được xem danh sách và chi tiết Outbound Delivery để nắm thông tin giao hàng cần thực hiện. Nhìn theo trình tự nghiệp vụ, hồ sơ giao hàng cung cấp thông tin cho việc chuẩn bị hàng, sau đó nhân viên kho thực hiện lấy hàng và ghi nhận xuất kho.”

### 5.3. Điều chỉnh tồn, kiểm kê và cất hàng

[Đi lên cụm Adjustment Request, Stocktake và hai chức năng Put-away ở bên trái.]

“Tiếp theo là yêu cầu điều chỉnh tồn kho. Nhân viên kho có thể xem danh sách, xem chi tiết và tạo yêu cầu điều chỉnh tồn.

Ở nhóm kiểm kê, nhân viên được xem các phiên kiểm kê, thực hiện đếm thực tế, ghi nhận kết quả và đối chiếu kiểm kê. Khi có chênh lệch cần xử lý bằng điều chỉnh tồn, nhân viên lập yêu cầu để chủ cửa hàng xem xét phê duyệt.

Bên cạnh nhóm này là hai chức năng tạo và xác nhận Put-away Transfer Order, tức lệnh di chuyển để cất hàng vào vị trí lưu trữ. Nhóm này hỗ trợ việc đưa hàng nhận vào vị trí trong kho.”

### 5.4. Chuyển kho và di chuyển vị trí

[Đi lên Warehouse Transfer, rồi Location Move.]

“Với chuyển hàng giữa các kho, nhân viên được xem danh sách và chi tiết, tạo yêu cầu chuyển, tạo lệnh chuyển kho và xác nhận lệnh chuyển kho.

Còn với di chuyển vị trí trong kho, nhân viên có thể xem danh sách và chi tiết, tạo bản ghi di chuyển và xác nhận việc di chuyển thực tế.

Hai nhóm này giúp thể hiện rõ việc chuyển hàng giữa các kho và việc thay đổi vị trí lưu trữ của hàng.”

### 5.5. Tồn kho, truy vết và hàng lỗi

[Đi lên cụm View Stock và các chức năng mở rộng bên phải.]

“Ở nhóm tồn kho, nhân viên có thể xem tồn và chi tiết số dư tồn kho. Nhân viên cũng có thể xem nhật ký biến động, xem chi tiết biến động và truy vết lô hàng thông qua chứng từ nguồn để tìm nguyên nhân của sự thay đổi số lượng.

Với hàng lỗi, nhân viên kho được xem danh sách, chi tiết, kiểm tra hàng lỗi và gửi phương án xử lý. Sau khi phương án được phê duyệt, nhân viên ghi nhận việc xử lý đã được duyệt.

Ngay phía trên, nhân viên có thể tra cứu danh sách kho, vị trí và chi tiết vị trí để phục vụ các thao tác lưu trữ hàng hóa.”

### 5.6. Nhập hàng, trả nhà cung cấp và lô hàng

[Tiếp tục đi lên: Receipt → Purchase Order → Supplier Return → Lot → Product.]

“Đối với nhập hàng, nhân viên kho có thể xem danh sách và chi tiết phiếu nhập, tạo phiếu nhập từ đơn mua hàng, kiểm tra và ghi nhận nhập kho. Nhân viên cũng được xem danh sách và chi tiết đơn mua để có căn cứ kiểm tra khi nhận hàng.

Tiếp theo là trả hàng cho nhà cung cấp. Nhân viên kho có thể xem danh sách, chi tiết, tạo yêu cầu trả hàng và xác nhận việc xuất gửi hàng trả cho nhà cung cấp.

Ở phần trên cùng, nhân viên có thể xem danh sách, chi tiết lô hàng và tạo lô sản phẩm; đồng thời tra cứu danh sách, chi tiết sản phẩm.

Qua các nhóm vừa trình bày, nhân viên kho là người trực tiếp ghi nhận các thao tác với hàng hóa: nhận hàng, cất hàng, di chuyển, kiểm kê, xuất hàng và nhận hàng trả.”

## 6. Store Owner — Chủ cửa hàng, trình bày từ dưới lên

[Mở trang “Bản sao của UC SO”. Bắt đầu từ View location movement list ở dưới cùng.]

“Vai trò cuối cùng là Store Owner, tức chủ cửa hàng. Em tiếp tục trình bày sơ đồ từ dưới lên. Trọng tâm của vai trò này là theo dõi hoạt động, xem xét các yêu cầu và quản lý các dữ liệu quan trọng của cửa hàng.”

### 6.1. Di chuyển vị trí, hóa đơn và tồn kho

[Đi từ Location Movement lên Internal Invoice, Stock Movement và Stock.]

“Ở dưới cùng, chủ cửa hàng có thể xem danh sách và chi tiết các lần di chuyển vị trí hàng hóa.

Tiếp theo là hóa đơn nội bộ. Chủ cửa hàng có thể xem danh sách, xem chi tiết, phát hành hóa đơn và xuất PDF.

Với tồn kho, chủ cửa hàng có thể xem số dư và chi tiết tồn, theo dõi nhật ký biến động, xem từng biến động và truy vết lô sản phẩm qua chứng từ nguồn. Các chức năng này cung cấp thông tin để kiểm tra hàng đang ở đâu và số lượng đã thay đổi như thế nào.”

### 6.2. Theo dõi mua hàng, nhập hàng và bán hàng

[Đi lên: Goods Receipt → Purchase Order → Goods Issue → Picking Transfer → Outbound Delivery và Sales Order.]

“Ở nhóm nhập hàng và mua hàng, chủ cửa hàng được xem danh sách và chi tiết phiếu nhập, cùng danh sách và chi tiết đơn mua.

Tiếp tục đi lên là các chứng từ đầu ra. Chủ cửa hàng có thể xem phiếu xuất, lệnh lấy hàng, hồ sơ giao hàng và đơn bán hàng, bao gồm cả danh sách và chi tiết.

Nhờ đó, chủ cửa hàng có thể theo dõi thông tin từ khâu mua và nhận hàng đến khâu chuẩn bị hàng và giao hàng cho khách.”

### 6.3. Hoàn tiền, khách trả hàng, giá bán và hàng lỗi

[Đi lên lần lượt các cụm Refund Request, Customer Return, Selling Price và Defective Goods.]

“Đối với hoàn tiền, chủ cửa hàng có thể xem danh sách, xem chi tiết và xem xét yêu cầu hoàn tiền do khách trả hàng. Ở nhóm khách trả hàng, chủ cửa hàng cũng được xem thông tin và xem xét yêu cầu trả hàng.

Đi lên là quản lý giá bán. Chủ cửa hàng có thể xem danh sách, chi tiết, tạo mới và cập nhật giá bán. Đây là điểm khác biệt với nhân viên bán hàng, vì nhân viên bán hàng sử dụng thông tin giá để lập đơn, còn chủ cửa hàng có các thao tác quản lý giá.

Với hàng lỗi, chủ cửa hàng có thể xem danh sách, chi tiết và phê duyệt hoặc từ chối phương án xử lý. Nhân viên kho sẽ ghi nhận việc xử lý theo phương án đã được phê duyệt.”

### 6.4. Điều chỉnh tồn, khách hàng và kiểm kê

[Đi lên Adjustment Request → Customer → Stocktake.]

“Ở nhóm điều chỉnh tồn kho, chủ cửa hàng có thể xem danh sách, chi tiết yêu cầu, xử lý chênh lệch kiểm kê và phê duyệt điều chỉnh tồn kho.

Chủ cửa hàng cũng được xem danh sách và chi tiết khách hàng.

Tiếp theo là kiểm kê. Chủ cửa hàng có thể xem danh sách, chi tiết và tạo phiên kiểm kê. Như vậy, chủ cửa hàng khởi tạo phiên và kiểm soát việc xử lý chênh lệch, còn nhân viên kho thực hiện đếm, ghi nhận và đối chiếu kết quả.”

### 6.5. Chuyển kho, bổ sung hàng, vị trí lưu trữ và báo cáo

[Đi lên Warehouse Transfer, Replenishment Request, Warehouse and Location, Operational Reports.]

“Với chuyển kho, chủ cửa hàng có thể xem danh sách, chi tiết, xem xét yêu cầu chuyển và xem xét phương án xử lý chênh lệch khi chuyển kho.

Đối với bổ sung hàng, chủ cửa hàng có thể xem danh sách, chi tiết và phê duyệt hoặc từ chối yêu cầu bổ sung hàng.

Chủ cửa hàng còn có thể xem danh sách kho và vị trí; xem chi tiết, tạo, cập nhật và vô hiệu hóa vị trí lưu trữ. Bên cạnh đó là chức năng xem báo cáo hoạt động để theo dõi tình hình vận hành.”

### 6.6. Trả nhà cung cấp, nhà cung cấp, sản phẩm và lô hàng

[Kết thúc ở các cụm phía trên: Supplier Return, Supplier, Product và Lot.]

“Ở nhóm trả hàng nhà cung cấp, chủ cửa hàng có thể xem danh sách, chi tiết và xem xét việc đóng nghiệp vụ trả hàng.

Với nhà cung cấp, chủ cửa hàng được xem danh sách, chi tiết và kích hoạt hoặc vô hiệu hóa nhà cung cấp.

Đối với sản phẩm, chủ cửa hàng có thể xem danh sách, chi tiết, tạo mới, cập nhật sản phẩm cùng quy cách đóng gói và vô hiệu hóa sản phẩm. Với lô hàng, chủ cửa hàng có thể xem danh sách, chi tiết, tạo và cập nhật lô sản phẩm.

Như vậy, chủ cửa hàng có phạm vi theo dõi rộng, đồng thời đảm nhiệm các quyết định phê duyệt và các thao tác quản lý dữ liệu được thể hiện trong sơ đồ.”

## 7. Chuyển sang To-be Business Flow

[Mở trang “To-be” trong Business_Process.drawio.]

“Phần Use Case vừa rồi mô tả phạm vi chức năng của từng vai trò. Tiếp theo, em trình bày quy trình To-be để làm rõ cách các vai trò phối hợp khi mua hàng và nhận hàng.

Sơ đồ này có ba làn trách nhiệm: Inventory Staff, Accountant và Owner. Quy trình bắt đầu từ yêu cầu mua hàng, đi qua bước đặt hàng và nhận hàng, sau đó đối chiếu để đóng đơn mua.

Em sẽ trình bày theo các nhánh quyết định trên sơ đồ, vì các bước đánh số trong đây có cả nhánh thay thế và vòng lặp.”

### 7.1. Lập và duyệt yêu cầu mua — Bước 1 đến 3

[Chỉ bước 1 ở làn Accountant, bước 2 và hình thoi phê duyệt ở làn Owner.]

“Đầu tiên, kế toán tạo yêu cầu mua hàng ở bước 1. Chủ cửa hàng xem xét yêu cầu ở bước 2.

Nếu yêu cầu chưa được phê duyệt, kế toán chỉnh sửa ở bước 3 rồi gửi lại để chủ cửa hàng xem xét. Vòng lặp này tiếp tục cho đến khi yêu cầu được chấp thuận. Khi đã được duyệt, quy trình chuyển sang tạo và phát hành đơn mua.”

### 7.2. Phát hành đơn mua và xử lý phản hồi — Bước 4 đến 9

[Chỉ bước 4, bước 5 và nhánh Can the PO be fulfilled as issued?]

“Tại bước 4, kế toán tạo và phát hành Purchase Order, gọi tắt là PO. Sau đó, kế toán ghi nhận phản hồi về khả năng thực hiện đơn ở bước 5.

Nếu nhà cung cấp có thể thực hiện đúng PO đã phát hành, quy trình chuyển sang nhận hàng.

Nếu không, kế toán xem xét các dòng hàng bị ảnh hưởng và những thay đổi được đề xuất ở bước 6. Lúc này có hai trường hợp.

Nếu không thể thực hiện bất kỳ phần nào của đơn, kế toán hủy PO ở bước 7 và nhánh này kết thúc.

Nếu vẫn có thể thực hiện một phần, kế toán cập nhật PO ở bước 8, phát hành lại PO đã sửa ở bước 9, rồi quay lại bước ghi nhận phản hồi. Như vậy, đơn mua được điều chỉnh và xác nhận lại trước khi chuyển sang nhận hàng.”

### 7.3. Nhận hàng và xử lý sai lệch — Bước 10 đến 14

[Chỉ bước 10 ở làn Inventory Staff và hình thoi Any Receipt Discrepancies?]

“Khi hàng đến, nhân viên kho nhận hàng, kiểm đếm và kiểm tra đối chiếu với PO ở bước 10.

Nếu không có sai lệch, nhân viên kho chuyển sang bước 13 để tạo và xác nhận phiếu nhập cho phần hàng được chấp nhận.

Nếu có sai lệch, nhân viên kho ghi nhận sai lệch ở bước 11. Sau đó, kế toán xem xét và ghi nhận kết quả xử lý ở bước 12.

Sau khi xử lý, quy trình kiểm tra còn phần hàng nào được chấp nhận hay không. Nếu có, nhân viên kho tạo và xác nhận phiếu nhập cho phần đó ở bước 13, sau đó gán vị trí lưu trữ và xác nhận cất hàng ở bước 14.

Nếu không có hàng nào được chấp nhận, quy trình bỏ qua việc nhập và cất hàng, chuyển sang đối chiếu PO ở bước 15.

Điểm cần nhấn mạnh là phiếu nhập được lập cho phần hàng được chấp nhận, còn sai lệch được ghi nhận và xử lý riêng.”

### 7.4. Đối chiếu số lượng còn lại — Bước 15 và 16

[Chỉ bước 15 và hai hình thoi Any Outstanding Quantity?, Further Delivery Agreed?]

“Tại bước 15, kế toán đối chiếu đơn mua với các phiếu nhập đã xác nhận để xác định còn số lượng chưa nhận hay không.

Nếu không còn số lượng chưa nhận, quy trình chuyển sang đối chiếu hóa đơn.

Nếu vẫn còn, cần kiểm tra có thống nhất giao bổ sung hay không. Nếu có, quy trình quay lại bước 10 để tiếp tục nhận và kiểm tra đợt hàng tiếp theo.

Nếu không tiếp tục giao bổ sung, phần số lượng còn lại được phê duyệt đóng ở bước 16, nằm tại vùng làn chủ cửa hàng trên sơ đồ. Sau đó, quy trình tiếp tục sang đối chiếu hóa đơn.

Nhánh này thể hiện việc một PO có thể được nhận qua nhiều đợt, hoặc kết thúc khi phần số lượng chưa nhận đã được xử lý.”

### 7.5. Đối chiếu hóa đơn và đóng đơn — Bước 17, 18

[Chỉ bước 17 và bước 18 ở cuối làn Accountant.]

“Ở bước 17, kế toán đối chiếu hóa đơn với PO và các phiếu nhập. Sau đó, kế toán đóng đơn mua ở bước 18, hoàn tất quy trình.

Qua quy trình này, có thể thấy ba vai trò phối hợp rõ ràng: kế toán lập và theo dõi đơn mua, ghi nhận phản hồi và đối chiếu chứng từ; nhân viên kho nhận, kiểm tra và cất hàng; chủ cửa hàng tham gia các điểm xem xét, phê duyệt được thể hiện trên sơ đồ.”

## 8. Kết thúc

“Phần trình bày của em đã làm rõ phạm vi chức năng của năm vai trò và cách phối hợp trong quy trình mua hàng, nhận hàng.

Các chức năng được phân chia theo công việc: Admin quản lý tài khoản và quyền; Sales Staff xử lý thông tin bán hàng; Inventory Staff ghi nhận nghiệp vụ hàng hóa; Accountant theo dõi đơn mua và chứng từ; Store Owner theo dõi hoạt động và xử lý các quyết định thuộc thẩm quyền.

Quy trình To-be cũng thể hiện các tình huống phát sinh như phải sửa PO, nhận hàng có sai lệch, giao hàng nhiều đợt hoặc đóng phần số lượng còn lại. Em xin kết thúc phần trình bày tại đây.”

## 9. Thẻ nhắc thứ tự khi trình chiếu

- **Accountant:** Sản phẩm, phiếu nhập, nhà cung cấp → xác nhận nhà cung cấp → bổ sung hàng, tồn kho, hàng trả → đơn mua → khách hàng, giá bán → hóa đơn, hoàn tiền → nhật ký, truy vết, báo cáo.
- **Admin:** Phân quyền → danh sách và chi tiết tài khoản → tạo, cập nhật, kích hoạt/vô hiệu hóa.
- **Sales Staff:** Sản phẩm → tồn kho → khách hàng → giá bán → đơn bán → giao hàng → tra cứu khách trả hàng.
- **Inventory Staff, dưới lên:** Khách trả → xuất kho → lấy hàng → hồ sơ giao hàng → điều chỉnh tồn → kiểm kê và put-away → chuyển kho → di chuyển vị trí → tồn kho, hàng lỗi, nhật ký → kho/vị trí → phiếu nhập → đơn mua → trả nhà cung cấp → lô → sản phẩm.
- **Store Owner, dưới lên:** Di chuyển vị trí → hóa đơn → tồn và nhật ký → phiếu nhập → đơn mua → xuất kho → lấy hàng → giao hàng, đơn bán → hoàn tiền → khách trả → giá bán, hàng lỗi → điều chỉnh tồn → khách hàng → kiểm kê → chuyển kho → bổ sung hàng, kho/vị trí, báo cáo → trả nhà cung cấp → nhà cung cấp → sản phẩm, lô.
- **To-be:** Yêu cầu mua và duyệt → PO và phản hồi → nhận hàng và sai lệch → nhập, cất hàng → đối chiếu phần còn lại → đối chiếu hóa đơn → đóng PO.

## 10. Ghi chú chuẩn bị — không đọc trong bài

- Script bám vào các trang bản sao của file ngày 17/10, không dùng các trang UC gốc hoặc những ảnh xuất cũ làm nguồn.
- Trang To-be được yêu cầu chỉ có quy trình **Purchasing and receiving goods**. Không ghép các business flow bán hàng hoặc chuyển kho từ trang khác vào phần này.
- UC dùng tên “replenishment request”, còn To-be dùng “purchase request”. Khi trình bày, giữ cách gọi theo từng sơ đồ; nếu muốn khẳng định chúng là cùng một loại yêu cầu, cần thống nhất thuật ngữ trong tài liệu dự án.
- Bước 16 của To-be nằm trực quan trong vùng Owner, nhưng phần tử XML đang được đặt dưới nhóm Accountant. Lời thoại dựa trên vị trí hiển thị; nên thống nhất lại nhóm chứa nếu chỉnh sơ đồ về sau.
- Có một số liên kết cần rà lại nếu được hỏi sâu về UML: “View replenishment request details” ở UC Accountant đang nối tới “View Receipt List”; “Confirm Picking Transfer Order” ở UC Inventory Staff đang nối tới “View goods issue list”. Script giới thiệu đúng chức năng, không dùng những đường nối này để khẳng định thứ tự xử lý.
- Không diễn giải mũi tên `extend` thành “bước tiếp theo” của quy trình. Use Case mô tả chức năng và quan hệ giữa chức năng; thứ tự nghiệp vụ được trình bày bằng Business Flow.
- “Internal Invoice” trong bài là **hóa đơn nội bộ**; không tự gọi là hóa đơn điện tử hoặc hóa đơn thuế. Phần To-be có đối chiếu hóa đơn nhưng không mô tả một bước thanh toán nhà cung cấp riêng.
