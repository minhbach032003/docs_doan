# Danh mục Use Case

Danh mục gồm 117 Use Case. Các UC-103–UC-117 được thêm khi tách các UC gộp; ID UC-01–UC-102 được giữ nguyên để không làm hỏng tham chiếu hiện có.

| ID | Use Case | Feature | Mô tả Use Case | Role thực hiện |
|---|---|---|---|---|
| UC-01 | View replenishment request list | FE-01 | Tìm kiếm yêu cầu theo trạng thái, ngày, người tạo và quyết định phê duyệt. | Store Owner (View); Accountant (View) |
| UC-02 | View replenishment request details | FE-01 | Hiển thị các sản phẩm cần bổ sung, tồn kho tham chiếu, số lượng yêu cầu và lịch sử phê duyệt. | Store Owner (View); Accountant (View) |
| UC-03 | Create replenishment request | FE-01 | Đề xuất bổ sung hàng sau khi kiểm tra tồn kho; ghi nhận sản phẩm, số lượng và lý do. | Accountant (Perform) |
| UC-04 | Approve or reject replenishment request | FE-01 | Xem xét yêu cầu và ghi nhận quyết định, người phê duyệt, thời điểm và lý do từ chối. | Store Owner (Approve) |
| UC-05 | View purchase order list | FE-01 | Lọc đơn hàng theo nhà cung cấp, ngày, trạng thái và số lượng còn phải nhận. | Store Owner (View); Accountant (View); Inventory Staff (Receiving scope only) |
| UC-06 | View purchase order details | FE-01 | Hiển thị các dòng hàng, xác nhận của nhà cung cấp và lịch sử nhận hàng từng phần. Hiển thị số lượng đã đặt, đã xác nhận, đã nhận, được chấp nhận và còn phải nhận, kèm chứng từ nhận hàng nguồn. Đây là chức năng chỉ đọc, không phải một Use Case riêng để xem số lượng còn phải nhận. | Store Owner (View); Accountant (View); Inventory Staff (Receiving scope only) |
| UC-07 | Create Purchase Order | FE-01 | Tạo đơn mua hàng (PO) từ yêu cầu bổ sung đã được phê duyệt, gồm các mặt hàng và số lượng đặt. | Accountant (Perform) |
| UC-08 | View goods receipt list | FE-01 | Tìm kiếm các lần giao hàng gắn với đơn mua hàng và trạng thái xử lý của chúng. | Store Owner (View); Accountant (View); Inventory Staff (View) |
| UC-09 | View goods receipt details | FE-01 | Hiển thị số lượng đã giao, được chấp nhận, đang chờ kiểm tra, bị lỗi và bị từ chối. | Store Owner (View); Accountant (View); Inventory Staff (View) |
| UC-10 | Create goods receipt from purchase order | FE-01 | Ghi nhận riêng từng lần nhà cung cấp giao hàng và liên kết mỗi lần giao với đơn mua hàng tương ứng. | Inventory Staff (Perform) |
| UC-11 | View product list | FE-02 | Tìm kiếm sản phẩm theo mã hàng, tên, kích thước và trạng thái. | Store Owner (View); Accountant (View); Inventory Staff (View); Sales Staff (View) |
| UC-12 | View product details | FE-02 | Hiển thị các thuộc tính của gạch, quy cách đóng gói và đơn vị đo lường. | Store Owner (View); Accountant (View); Inventory Staff (View); Sales Staff (View) |
| UC-13 | Create Product | FE-02 | Tạo sản phẩm mới và khai báo thuộc tính gạch, quy cách đóng gói cùng quy đổi đơn vị ban đầu. | Store Owner (Perform) |
| UC-14 | View lot list | FE-02 | Tìm kiếm lô theo sản phẩm, số lô, tông màu và kích cỡ thực tế. | Store Owner (View); Inventory Staff (View) |
| UC-15 | View lot details | FE-02 | Hiển thị ngày sản xuất, tông màu, kích cỡ thực tế và lịch sử giao dịch liên quan. | Store Owner (View); Inventory Staff (View) |
| UC-16 | Create Product Lot | FE-02 | Tạo thông tin tham chiếu cho lô sản phẩm, gồm sản phẩm, mã lô, tông màu và kích cỡ thực tế. Store Owner và Inventory Staff được tạo lô. | Store Owner (Create / Update); Inventory Staff (Create only) |
| UC-17 | View supplier list | FE-02 | Tìm kiếm nhà cung cấp theo mã, tên và tình trạng hợp tác. | Store Owner (View); Accountant (View) |
| UC-18 | View supplier details | FE-02 | Hiển thị thông tin liên hệ và các giao dịch mua hàng, nhận hàng, trả hàng liên quan. | Store Owner (View); Accountant (View) |
| UC-19 | Create Supplier | FE-02 | Tạo hồ sơ nhà cung cấp với thông tin định danh và liên hệ. Accountant được tạo hồ sơ; thao tác này không thay đổi trạng thái hoạt động của nhà cung cấp. | Store Owner (Activate / Deactivate); Accountant (Create / Update) |
| UC-20 | View Customer List | FE-02 | Tìm kiếm và xem danh sách khách hàng ở chế độ chỉ đọc. | Store Owner (View); Accountant (View); Sales Staff (View) |
| UC-21 | View Customer Details | FE-02 | Xem thông tin chi tiết khách hàng ở chế độ chỉ đọc. | Store Owner (View); Accountant (View); Sales Staff (View) |
| UC-22 | Create Customer | FE-02 | Tạo hồ sơ khách hàng với thông tin liên hệ và tham chiếu hóa đơn cần thiết. | Sales Staff (Perform) |
| UC-23 | View Selling Price List | FE-02 | Tìm kiếm và xem danh sách giá bán ở chế độ chỉ đọc. | Store Owner (View); Accountant (View); Sales Staff (View) |
| UC-24 | View Selling Price Details | FE-02 | Xem thông tin chi tiết giá bán ở chế độ chỉ đọc. | Store Owner (View); Accountant (View); Sales Staff (View) |
| UC-25 | Create Selling Price | FE-02 | Tạo bản ghi giá bán theo sản phẩm, đơn vị và ngày hiệu lực; giá được nhập trực tiếp hoặc kèm thông tin biên lợi nhuận tính bên ngoài. | Store Owner (Perform) |
| UC-26 | Inspect and Post Goods Receipt | FE-03 | Kiểm tra phiếu nhận hàng nháp và ghi sổ số lượng thực tế được chấp nhận, phân loại trong cùng một quy trình kiểm tra. | Inventory Staff (Perform) |
| UC-27 | View warehouse and location list | FE-04 | Tìm kiếm theo kho, khu vực, dãy, kệ và mã vị trí. | Store Owner (View); Inventory Staff (View) |
| UC-28 | View storage location details | FE-04 | Hiển thị sức chứa, trạng thái và số lượng theo lô tại một vị trí. | Store Owner (View); Inventory Staff (View) |
| UC-29 | Create Storage Location | FE-04 | Tạo vị trí lưu trữ trong kho, gồm mã, loại và thuộc tính vận hành; kiểm tra mã duy nhất và kho tham chiếu. | Store Owner (Perform) |
| UC-30 | View stock by lot, location, and quality status | FE-04 | Lọc tồn kho theo sản phẩm, kho, lô, tông màu, kích cỡ và trạng thái chất lượng. | Store Owner (View); Accountant (View); Inventory Staff (View); Sales Staff (Usable stock only) |
| UC-31 | View inventory balance details | FE-04 | Hiển thị số lượng vật lý, số lượng có thể sử dụng và chứng từ luân chuyển nguồn. | Store Owner (View); Inventory Staff (View) |
| UC-32 | Create Put-away Transfer Order | FE-04 | Tạo lệnh chuyển hàng vào vị trí lưu trữ (TO) từ số lượng trên phiếu nhận hàng đã ghi sổ. | Inventory Staff (Perform) |
| UC-33 | Confirm Put-away Transfer Order | FE-04 | Xác nhận việc đưa hàng đã nhận vào các vị trí lưu trữ đích. | Inventory Staff (Perform) |
| UC-34 | View location movement list | FE-04 | Tìm kiếm các lần điều chuyển trong cùng một kho theo lô và trạng thái. | Store Owner (View); Inventory Staff (View) |
| UC-35 | View location movement details | FE-04 | Hiển thị vị trí nguồn, vị trí đích và số lượng thực tế đã điều chuyển. | Store Owner (View); Inventory Staff (View) |
| UC-36 | Create location movement | FE-04 | Chỉ định lô, số lượng, vị trí nguồn và vị trí đích trong cùng một kho. | Inventory Staff (Perform) |
| UC-37 | Confirm actual location movement | FE-04 | Giảm số lượng tại vị trí nguồn và tăng số lượng tại vị trí đích mà không làm thay đổi tổng tồn kho của kho. | Inventory Staff (Perform) |
| UC-38 | View warehouse transfer list | FE-05 | Tìm kiếm lệnh điều chuyển theo kho nguồn/kho đích và trạng thái đang vận chuyển/đã nhận. | Store Owner (View); Inventory Staff (View) |
| UC-39 | View warehouse transfer details | FE-05 | Hiển thị số lượng đã xuất kho, đã bàn giao và đã nhận, cùng chênh lệch theo từng lô. | Store Owner (View); Inventory Staff (View) |
| UC-40 | Create Transfer Request | FE-05 | Tạo yêu cầu điều chuyển hàng giữa các kho (TR). | Inventory Staff (Perform) |
| UC-41 | Review Transfer Request | FE-05 | Phê duyệt hoặc từ chối yêu cầu điều chuyển giữa các kho (TR). | Store Owner (Approve) |
| UC-42 | Create Warehouse Transfer Order | FE-05 | Tạo lệnh điều chuyển (TO) cho yêu cầu điều chuyển giữa các kho (TR) đã được phê duyệt. | Inventory Staff (Perform) |
| UC-43 | Confirm Warehouse Transfer Order | FE-05 | Xác nhận số lượng thực tế điều chuyển giữa các kho và xử lý chênh lệch tại điểm kiểm soát trong cùng một quy trình. | Inventory Staff (Perform) |
| UC-44 | Review Transfer Difference Resolution | FE-05 | Phê duyệt hoặc từ chối phương án xử lý chênh lệch được gửi từ bước xác nhận lệnh điều chuyển (TO). | Store Owner (Approve) |
| UC-45 | View Sales Order List | FE-06 | Tìm kiếm và xem danh sách đơn bán hàng ở chế độ chỉ đọc. | Store Owner (View); Sales Staff (View) |
| UC-46 | View Sales Order Details | FE-06 | Xem chi tiết đơn bán hàng ở chế độ chỉ đọc. | Store Owner (View); Sales Staff (View) |
| UC-47 | Create Sales Order | FE-06 | Tạo đơn bán hàng với thông tin khách hàng, số lượng và giá bán. | Sales Staff (Perform) |
| UC-48 | Update Sales Order | FE-06 | Cập nhật số lượng hoặc giá của phần đơn bán hàng chưa thực hiện; giữ nguyên lịch sử hàng đã giao và đã lập hóa đơn. | Sales Staff (Perform) |
| UC-49 | View Outbound Delivery List | FE-06 | Tìm kiếm và xem danh sách phiếu giao hàng ở chế độ chỉ đọc. | Store Owner (View); Inventory Staff (View); Sales Staff (View) |
| UC-50 | View Outbound Delivery Details | FE-06 | Xem chi tiết phiếu giao hàng ở chế độ chỉ đọc. | Store Owner (View); Inventory Staff (View); Sales Staff (View) |
| UC-51 | Create Outbound Delivery | FE-06 | Tạo phiếu giao hàng từ số lượng còn phải giao của đơn bán hàng. | Sales Staff (Perform) |
| UC-52 | View Picking Transfer Order List | FE-06 | Tìm kiếm và xem danh sách lệnh chuyển hàng phục vụ lấy hàng ở chế độ chỉ đọc. | Store Owner (View); Inventory Staff (View) |
| UC-53 | View Picking Transfer Order Details | FE-06 | Xem chi tiết lệnh chuyển hàng phục vụ lấy hàng ở chế độ chỉ đọc. | Store Owner (View); Inventory Staff (View) |
| UC-54 | Create Picking Transfer Order | FE-06 | Tạo lệnh chuyển hàng (TO) để lấy hàng trong kho từ phiếu giao hàng. | Inventory Staff (Perform) |
| UC-55 | Confirm Picking Transfer Order | FE-06 | Xác nhận số lượng thực tế đã lấy và chuyển đến vị trí tập kết. | Inventory Staff (Perform) |
| UC-56 | View goods issue list | FE-06 | Tìm kiếm theo yêu cầu nguồn, ngày xuất kho và trạng thái. | Store Owner (View); Inventory Staff (View) |
| UC-57 | View goods issue details | FE-06 | Hiển thị lô, vị trí, số lượng đã chuẩn bị và số lượng thực tế đã xuất theo từng dòng. | Store Owner (View); Inventory Staff (View) |
| UC-58 | Post Goods Issue | FE-06 | Ghi sổ việc xuất hàng thực tế (PGI), tách biệt với bước xác nhận lấy hàng. | Inventory Staff (Perform) |
| UC-59 | View Internal Invoice List | FE-06 | Tìm kiếm và xem danh sách hóa đơn nội bộ ở chế độ chỉ đọc. | Store Owner (View); Accountant (View) |
| UC-60 | View Internal Invoice Details | FE-06 | Xem chi tiết hóa đơn nội bộ ở chế độ chỉ đọc. | Store Owner (View); Accountant (View) |
| UC-61 | Create Internal Invoice | FE-06 | Lập hóa đơn nội bộ từ phiếu xuất kho đã ghi sổ và đơn bán hàng. | Accountant (Perform) |
| UC-62 | Issue Internal Invoice and Produce PDF | FE-06 | Phát hành hóa đơn nội bộ và cung cấp bản PDF/bản in. | Store Owner (Export / Print issued only); Accountant (Issue / Export / Print) |
| UC-63 | View defective goods list | FE-07 | Lọc hàng lỗi theo sản phẩm, lô, vị trí, nguyên nhân, trạng thái và phương án xử lý đề xuất. | Store Owner (View); Inventory Staff (View) |
| UC-64 | View defective goods details | FE-07 | Hiển thị số lượng bị ảnh hưởng, bằng chứng, người ghi nhận và các thao tác xử lý liên quan. | Store Owner (View); Inventory Staff (View) |
| UC-65 | Inspect Defective Goods and Submit Disposition | FE-07 | Ghi nhận lỗi hoặc kết quả kiểm tra cách ly và gửi phương án xử lý đề xuất trong cùng một quy trình. | Inventory Staff (Perform) |
| UC-66 | Approve or reject defective goods disposition | FE-07 | Xem xét nguyên nhân và bằng chứng, sau đó phê duyệt hoặc từ chối phương án xử lý được đề xuất. | Store Owner (Approve) |
| UC-67 | Record approved defective goods disposition | FE-07 | Cập nhật số lượng và trạng thái chất lượng theo phương án xử lý đã được phê duyệt. | Inventory Staff (Perform) |
| UC-68 | View customer return list | FE-07 | Tìm kiếm hàng trả lại theo nguồn, lý do và trạng thái kiểm tra. | Store Owner (View); Accountant (View); Inventory Staff (View); Sales Staff (Related sales records only) |
| UC-69 | View customer return details | FE-07 | Hiển thị lô, số lượng, tình trạng và phương án xử lý đề xuất. | Store Owner (View); Accountant (View); Inventory Staff (View); Sales Staff (Related sales records only) |
| UC-70 | Create Customer Return Request | FE-07 | Đăng ký yêu cầu trả hàng của khách hàng, liên kết với giao dịch bán hàng và phiếu xuất kho thực tế ban đầu. | Inventory Staff (Perform) |
| UC-71 | Review Customer Return Request | FE-07 | Chấp nhận hoặc từ chối yêu cầu để chuyển sang kiểm tra hàng trả lại; đây không phải là phê duyệt hoàn tiền. | Store Owner (Approve) |
| UC-72 | Inspect Customer Return | FE-07 | Tiếp nhận, kiểm tra và phân loại hàng trả lại trong một Use Case kiểm tra. | Inventory Staff (Perform) |
| UC-73 | Confirm Customer Return Receipt | FE-07 | Ghi sổ số lượng hàng trả lại được chấp nhận và hoàn tất việc xử lý hàng trong kho. | Inventory Staff (Perform) |
| UC-74 | View Refund Request List | FE-07 | Tìm kiếm và xem danh sách yêu cầu hoàn tiền ở chế độ chỉ đọc. | Store Owner (View); Accountant (View) |
| UC-75 | View Refund Request Details | FE-07 | Xem chi tiết yêu cầu hoàn tiền ở chế độ chỉ đọc. | Store Owner (View); Accountant (View) |
| UC-76 | Create Customer Return Refund Request | FE-07 | Yêu cầu hoàn tiền được thực hiện bên ngoài ứng dụng cho hàng khách trả lại đã được chấp nhận. | Accountant (Perform) |
| UC-77 | Review Customer Return Refund Request | FE-07 | Phê duyệt hoặc từ chối đề xuất hoàn tiền. | Store Owner (Approve) |
| UC-78 | Record Refund Completion | FE-07 | Ghi nhận bằng chứng rằng khoản hoàn tiền đã được thanh toán bên ngoài ứng dụng theo phê duyệt. | Accountant (Perform) |
| UC-79 | View supplier return request list | FE-07 | Tìm kiếm theo nhà cung cấp, lô, lý do và trạng thái phê duyệt. | Store Owner (View); Accountant (View); Inventory Staff (View) |
| UC-80 | View supplier return request details | FE-07 | Hiển thị lô, vị trí, số lượng, phiếu nhận hàng nguồn, bằng chứng và quyết định phê duyệt. | Store Owner (View); Accountant (View); Inventory Staff (View) |
| UC-81 | Create Supplier Return Request | FE-07 | Lập yêu cầu trả hàng cho nhà cung cấp, liên kết với phiếu nhận hàng/đơn mua hàng ban đầu. | Inventory Staff (Perform) |
| UC-82 | Confirm Supplier Return Dispatch | FE-07 | Ghi sổ việc trả hàng thực tế cho nhà cung cấp và ghi nhận bàn giao/xác nhận đã nhận. | Inventory Staff (Perform) |
| UC-83 | Review Supplier Return Closure | FE-07 | Xem xét xác nhận của nhà cung cấp và cho phép đóng yêu cầu trả hàng. | Store Owner (Approve) |
| UC-84 | View stocktake list | FE-08 | Tìm kiếm đợt kiểm kê theo kho, phạm vi, thời điểm chốt và trạng thái. | Store Owner (View); Inventory Staff (View) |
| UC-85 | View stocktake details | FE-08 | Xem các lô/vị trí được đưa vào kiểm kê, số liệu hệ thống tại thời điểm chốt, số lượng kiểm đếm và chênh lệch. | Store Owner (View); Inventory Staff (View) |
| UC-86 | Create Stocktake Session | FE-08 | Lập kế hoạch kiểm kê và tạo phiên kiểm kê, bao gồm các bước 1 và 2 của quy trình nghiệp vụ. | Store Owner (Perform) |
| UC-87 | Perform Stocktake Count and Record Results | FE-08 | Chốt số lượng sổ sách tại thời điểm bắt đầu kiểm đếm, thực hiện kiểm đếm thực tế và ghi nhận kết quả; lần đếm và đếm lại thuộc cùng một Use Case, có lưu lịch sử từng lần. Bao gồm các bước 3 và 4. | Inventory Staff (Perform) |
| UC-88 | Reconcile Stocktake | FE-08 | So sánh kết quả kiểm đếm thực tế đã hoàn tất với số lượng sổ sách đã chốt, điều tra nguyên nhân và thực hiện quyết định về chênh lệch tại bước 5. | Inventory Staff (Perform) |
| UC-89 | View inventory adjustment request list | FE-08 | Tìm kiếm theo đợt kiểm kê, lô, vị trí, lý do chênh lệch và trạng thái phê duyệt. | Store Owner (View); Inventory Staff (View) |
| UC-90 | View inventory adjustment request details | FE-08 | Hiển thị số lượng trước/sau điều chỉnh, nguyên nhân, người tạo, bằng chứng và quyết định phê duyệt. | Store Owner (View); Inventory Staff (View) |
| UC-91 | Create Inventory Adjustment Request | FE-08 | Tạo yêu cầu ở bước 6 chỉ cho các chênh lệch kiểm kê đã đối soát và khác 0. | Inventory Staff (Perform) |
| UC-92 | Approve Inventory Adjustment | FE-08 | Xem xét và phê duyệt chênh lệch đã được ghi nhận tại bước 7; việc phê duyệt không làm giảm số lượng tồn kho. | Store Owner (Approve) |
| UC-93 | Clear Stocktake Difference | FE-08 | Thực hiện bước 8 bằng cách ghi sổ chênh lệch đã được phê duyệt và đóng đợt kiểm kê đã đối soát. | Store Owner (Perform) |
| UC-94 | Sign in to the system | FE-09 | Truy cập các chức năng được cấp quyền theo tài khoản và vai trò được phân công. | Store Owner (Use); Accountant (Use); Inventory Staff (Use); Sales Staff (Use); Administrator (Use) |
| UC-95 | View account list | FE-09 | Tìm kiếm và lọc tài khoản theo tên, vai trò và trạng thái hoạt động. | Administrator (View) |
| UC-96 | View account details | FE-09 | Hiển thị thông tin tài khoản được chọn, vai trò được phân công và trạng thái. | Administrator (View) |
| UC-97 | Create Staff Account | FE-09 | Tạo tài khoản nhân viên với thông tin định danh và liên hệ. Việc phân công vai trò được thực hiện riêng trong UC-98. | Administrator (Perform) |
| UC-98 | Assign roles and operation permissions | FE-09 | Cấu hình quyền xem, tạo, chỉnh sửa và ghi nhận giao dịch theo vai trò. | Administrator (Perform) |
| UC-99 | View Operational Reports | FE-09 | Chạy báo cáo tồn kho, mua hàng/nhận hàng, điều chuyển và kiểm kê được cấp quyền từ một không gian báo cáo. | Store Owner (All report groups); Accountant (Movement; purchase/receipt); Inventory Staff (Movement; stock; transfer; stocktake) |
| UC-100 | View stock movement log | FE-09 | Lọc các lần luân chuyển theo sản phẩm, lô, vị trí, loại giao dịch và thời gian. | Store Owner (View); Accountant (Purchase / supplier scope); Inventory Staff (View) |
| UC-101 | View stock movement details | FE-09 | Hiển thị chứng từ nguồn, số lượng trước/sau, người thao tác, thời điểm và lý do. | Store Owner (View); Accountant (Purchase / supplier scope); Inventory Staff (View) |
| UC-102 | Trace a product lot through source documents | FE-09 | Liên kết phiếu nhận hàng, các lần điều chuyển, phiếu xuất kho, hàng trả lại và các lần điều chỉnh tồn kho của một lô. | Store Owner (View); Accountant (Purchase / supplier scope); Inventory Staff (View) |
| UC-103 | Update Purchase Order | FE-01 | Cập nhật các dòng hàng và số lượng chưa nhận của PO còn hiệu lực; giữ nguyên số lượng đã nhận và lịch sử thay đổi. | Accountant (Perform) |
| UC-104 | Cancel Unreceived Purchase Order Quantity | FE-01 | Hủy toàn bộ hoặc một phần số lượng PO còn chưa nhận khi PO ở trạng thái cho phép; không xóa lịch sử các lần nhận trước đó. | Accountant (Perform) |
| UC-105 | Record Supplier Confirmation | FE-01 | Ghi nhận số lượng nhà cung cấp xác nhận và ngày giao dự kiến cho PO; lưu lịch sử xác nhận, không ghi nhận hàng vào tồn kho. | Accountant (Perform) |
| UC-106 | Update Product and Packaging | FE-02 | Cập nhật thuộc tính sản phẩm, quy cách đóng gói hoặc quy đổi đơn vị; bảo toàn ảnh chụp dữ liệu trên các giao dịch lịch sử. | Store Owner (Perform) |
| UC-107 | Deactivate Product | FE-02 | Ngừng kích hoạt sản phẩm khi không còn giao dịch đang cần sản phẩm; giữ lại tham chiếu và lịch sử giao dịch cũ. | Store Owner (Perform) |
| UC-108 | Update Product Lot | FE-02 | Cập nhật thông tin tham chiếu của lô hiện có. Chỉ Store Owner được cập nhật; Inventory Staff chỉ được tạo lô bằng UC-16. Không ghi đè lịch sử tồn kho hoặc thay đổi chất lượng lô bằng UC này. | Store Owner (Update) |
| UC-109 | Update Supplier Information | FE-02 | Cập nhật thông tin định danh hoặc liên hệ của nhà cung cấp; Accountant được thực hiện, không thay đổi trạng thái hoạt động. | Accountant (Update) |
| UC-110 | Activate or Deactivate Supplier | FE-02 | Store Owner thay đổi trạng thái hoạt động của nhà cung cấp hiện có. Nhà cung cấp ngừng hoạt động không được chọn cho chứng từ mua hàng mới; các tham chiếu lịch sử vẫn được giữ. | Store Owner (Activate / Deactivate) |
| UC-111 | Update Customer | FE-02 | Cập nhật thông tin tham chiếu cơ bản của khách hàng; không thay đổi ảnh chụp thông tin trên đơn bán hàng hoặc hóa đơn lịch sử. | Sales Staff (Update) |
| UC-112 | Update Selling Price | FE-02 | Cập nhật bản ghi giá bán hiện có theo sản phẩm, đơn vị và ngày hiệu lực; bảo toàn lịch sử giá trước đó. Ứng dụng không tự tính giá từ biên lợi nhuận. | Store Owner (Update) |
| UC-113 | Update Storage Location | FE-04 | Cập nhật mã, loại hoặc thuộc tính vận hành của vị trí lưu trữ; bảo đảm mã duy nhất và kho tham chiếu hợp lệ. | Store Owner (Update) |
| UC-114 | Deactivate Storage Location | FE-04 | Ngừng kích hoạt vị trí lưu trữ khi vị trí không còn tồn kho và không có luân chuyển đang mở; giữ lại lịch sử vị trí. | Store Owner (Deactivate) |
| UC-115 | Cancel Outstanding Sales Order Quantities | FE-06 | Hủy phần số lượng đơn bán hàng chưa thực hiện và ghi lý do; không thay đổi lịch sử hàng đã giao hoặc đã lập hóa đơn. | Sales Staff (Cancel) |
| UC-116 | Update Staff Account | FE-09 | Cập nhật thông tin định danh hoặc liên hệ của tài khoản nhân viên; không phân công vai trò trong UC này. | Administrator (Update) |
| UC-117 | Activate or Deactivate Staff Account | FE-09 | Administrator thay đổi trạng thái đăng nhập của tài khoản nhân viên hiện có; việc phân công vai trò vẫn được thực hiện riêng trong UC-98. | Administrator (Activate / Deactivate) |

