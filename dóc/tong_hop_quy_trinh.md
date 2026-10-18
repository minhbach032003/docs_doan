# TỔNG HỢP SÁU QUY TRÌNH QUẢN LÝ KHO GẠCH

## Phạm vi và quy tắc dùng chung

Tài liệu tập trung vào sáu quy trình làm thay đổi hoặc xác minh tồn kho: (1) mua và nhập hàng từ nhà cung cấp, (2) bán hàng cho khách, (3) chuyển kho nội bộ, (4) kiểm kho, (5) nhập hàng khách trả, và (6) trả hàng cho nhà cung cấp. Báo giá, hóa đơn và công nợ chỉ được nêu tại điểm liên quan đến nghiệp vụ kho.

- **Đơn mua nhà cung cấp**: cửa hàng đặt hàng để nhập kho. **Đơn mua của khách**: khách tạo yêu cầu mua hàng từ cửa hàng; đây là điểm bắt đầu của luồng xuất kho bán hàng.
- Tồn được truy vết theo **mã hàng/biến thể, lô, màu, cỡ, kho và vị trí**. Mỗi lần nhập, xuất, chuyển vị trí hoặc điều chỉnh phải có chứng từ và lịch sử biến động.
- **Tồn thực tế** là hàng vật lý đã ghi nhận tại kho, gồm hàng bán được và hàng đang cách ly. **Tồn khả dụng = tồn bán được − tồn đã giữ cho đơn bán − tồn đã giữ cho chuyển/trả nhà cung cấp**. Hàng nhà cung cấp xác nhận nhưng chưa nhận được là *hàng sắp nhập*; hàng đã xuất khỏi kho nguồn nhưng chưa nhập kho đích là *hàng đang chuyển*. Hai loại này không được cộng vào tồn khả dụng.
- Giá vốn dùng **bình quân gia quyền liên hoàn theo mã hàng/biến thể**. Sau mỗi lần nhập kho có giá trị, cập nhật đơn giá bình quân: `(giá trị tồn trước nhập + giá trị nhập) / (số lượng tồn trước nhập + số lượng nhập)`. Khi xuất bán, ghi giá vốn theo đơn giá bình quân tại thời điểm xác nhận xuất kho. Lô dùng để truy vết số lượng, không tạo giá vốn riêng cho từng lô.
- Hệ thống quản lý chứng từ và biến động kho, **không quản lý đơn vị vận chuyển, xe, tài xế, tuyến đường hoặc xác nhận giao hàng**. Chuyển kho nội bộ chỉ theo dõi hàng từ kho nguồn sang kho đích, không theo dõi phương tiện vận chuyển.
- Một đơn bán có thể có nhiều phiếu xuất kho. **Đơn bán hoàn thành khi đã xuất đủ số lượng và kế toán xác nhận hóa đơn**; thanh toán và công nợ được theo dõi riêng.
- Các chứng từ ở trạng thái nháp, chờ duyệt hoặc bị từ chối **không làm thay đổi tồn**. Biến động tồn chỉ phát sinh một lần khi phiếu nhập, phiếu xuất hoặc phiếu điều chỉnh được xác nhận. Không sửa/xóa trực tiếp chứng từ đã xác nhận; dùng chứng từ đảo hoặc điều chỉnh có liên kết và lý do.

Trong mỗi quy trình dưới đây, **luồng thay thế** là cách hợp lệ khác để hoàn tất nghiệp vụ; **trường hợp không đạt** là tình huống nghiệp vụ bị từ chối, thiếu hoặc sai hàng; **ngoại lệ** là lỗi dữ liệu, xung đột tồn hoặc lỗi hệ thống cần chặn ghi nhận trùng/sai. Tất cả các nhánh đều nêu trạng thái và tác động tồn kho.

---

## 1. Quy trình mua và nhập hàng từ nhà cung cấp

**Điểm bắt đầu:** cửa hàng cần bổ sung hàng do mức tồn, nhu cầu của khách hoặc kế hoạch kinh doanh. **Người thực hiện:** chủ cửa hàng/nhân viên mua hàng và thủ kho; kế toán xử lý hóa đơn nhà cung cấp.

**Đầu vào:** nhu cầu mua, nhà cung cấp, mã hàng, số lượng, giá mua, kho nhận. **Đầu ra:** đơn mua, biên bản kiểm nhận, phiếu nhập kho, vị trí hàng và lịch sử giá vốn. Trạng thái đơn mua: `NHÁP → CHỜ_NCC_XÁC_NHẬN → ĐÃ_XÁC_NHẬN → NHẬN_MỘT_PHẦN/ĐÃ_NHẬN_ĐỦ`; có thể kết thúc bằng `ĐÃ_HỦY` khi chưa nhận hết.

### Luồng chuẩn

1. Nhân viên mua hàng kiểm tra tồn khả dụng, hàng sắp nhập và nhu cầu để lập số lượng cần mua; tạo đơn mua nhà cung cấp với giá và ngày nhận dự kiến.
2. Nhà cung cấp xác nhận mã hàng, số lượng và ngày nhận. Nếu thay đổi, người có quyền sửa và gửi lại đơn trước khi xác nhận cuối cùng.
3. Khi hàng đến, thủ kho mở lượt kiểm nhận gắn với đơn mua; đối chiếu chứng từ, kiểm số thùng/đơn vị, mã hàng, lô, màu, cỡ, ngày sản xuất và tình trạng. Ghi số lượng thực nhận, đạt, lỗi và thiếu riêng cho từng dòng.
4. Lập phiếu nhập cho **số lượng đạt được chấp nhận**. Phiếu phải có kho, lô, giá nhập, người xác nhận và tham chiếu đơn mua. Hàng lỗi/sai chờ xử lý ở khu vực cách ly, không vào tồn bán được.
5. Thủ kho chọn vị trí, thực hiện put-away và xác nhận số lượng tại vị trí thực tế. Khi phiếu nhập được xác nhận, tồn kho tăng đúng một lần; hàng chỉ chuyển sang *bán được* sau khi kiểm nhận đạt và cất hàng hoàn tất.
6. Hệ thống cập nhật đơn giá bình quân từ lượng và giá trị nhập đạt, cập nhật số lượng đã nhận/còn thiếu trên đơn mua. Kế toán đối chiếu hóa đơn nhà cung cấp, theo dõi công nợ riêng với trạng thái nhập kho.

```text
Nhu cầu nhập → Đơn mua nhà cung cấp → Nhà cung cấp xác nhận
→ Kiểm nhận → Phiếu nhập kho → Put-away
→ Tăng tồn theo lô/vị trí → Cập nhật giá vốn bình quân
```

**Kết quả:** có chứng từ nhập và tồn tại vị trí thực tế; số lượng đã nhận, số lượng còn thiếu và chênh lệch được truy vết về đơn mua.

### Luồng thay thế (alternative)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| A1 | Nhà cung cấp giao nhiều đợt: mỗi đợt lập lượt kiểm nhận và phiếu nhập riêng. | Đơn ở `NHẬN_MỘT_PHẦN` cho đến khi nhận đủ hoặc đóng phần còn lại; chỉ lượng từng đợt đã xác nhận mới tăng tồn. |
| A2 | Giao thừa và cửa hàng muốn nhận: người có quyền điều chỉnh đơn mua hoặc phê duyệt nhận vượt trước khi lập phiếu nhập cho phần thừa. | Chưa phê duyệt thì phần thừa ở khu vực chờ xử lý, không bán được. |
| A3 | Hóa đơn nhà cung cấp đến sau hàng: kho vẫn hoàn tất kiểm nhận/put-away khi đã có giá mua hợp lệ; kế toán đối chiếu hóa đơn sau. | Trạng thái kho và trạng thái hóa đơn được theo dõi riêng. |

### Trường hợp không đạt (unhappy case)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| U1 | Giao thiếu: ghi số thiếu và yêu cầu nhà cung cấp giao tiếp hoặc đóng phần còn lại sau phê duyệt. | Không tăng tồn cho số chưa nhận; đơn còn mở hoặc đóng có lý do. |
| U2 | Sai mã/lô/màu/cỡ hoặc hàng hỏng: lập biên bản, cách ly, yêu cầu đổi/trả hoặc giảm nhận. | Không vào tồn bán được; nếu đã nhập rồi mới phát hiện thì dùng quy trình 6. |
| U3 | Nhà cung cấp từ chối hoặc hủy phần chưa giao: cập nhật quyết định mua từ nguồn khác/hủy phần còn lại. | Xóa kỳ vọng hàng sắp nhập tương ứng, không tác động tồn thực tế. |

### Ngoại lệ (exception)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| E1 | Thiếu giá nhập, lô hoặc vị trí bắt buộc: giữ phiếu ở `CHỜ_BỔ_SUNG`, không xác nhận nhập có giá trị cho đến khi dữ liệu hợp lệ. | Không tăng tồn bán được, không cập nhật bình quân. |
| E2 | Xác nhận phiếu nhập bị gửi lặp: kiểm mã phiếu/giao dịch, trả kết quả lần đầu thay vì ghi biến động lần hai. | Tồn và giá vốn chỉ cập nhật một lần. |
| E3 | Vị trí bị khóa/không đủ sức chứa hoặc có kiểm kho đang mở: chọn vị trí hợp lệ khác hoặc chờ mở khóa; lưu hàng ở khu vực chờ nhận. | Không tự gán vào vị trí sai; chưa cho bán phần chưa hoàn tất put-away. |

---

## 2. Quy trình bán hàng cho khách

**Điểm bắt đầu:** khách tạo **đơn mua của khách** với mã hàng, số lượng, ngày cần nhận và yêu cầu liên quan. **Người thực hiện:** nhân viên kinh doanh, thủ kho và kế toán.

**Đầu vào:** đơn mua của khách, tồn khả dụng, giá bán được chấp nhận. **Đầu ra:** đơn bán, giữ hàng, nhiệm vụ picking, một hoặc nhiều phiếu xuất và trạng thái hóa đơn. Trạng thái đơn bán: `CHỜ_XÁC_NHẬN → ĐÃ_XÁC_NHẬN → ĐANG_XUẤT/ĐÃ_XUẤT_ĐỦ → ĐÃ_HOÀN_THÀNH`; có thể `ĐÃ_HỦY` trước khi xuất.

### Luồng chuẩn

1. Khách tạo đơn mua; nhân viên kinh doanh xác minh khách, mặt hàng, số lượng và giá, rồi kiểm tra tồn khả dụng theo mã hàng/lô phù hợp.
2. Khi khách chấp nhận điều kiện bán, nhân viên xác nhận đơn bán từ đơn mua. Hệ thống giữ số lượng đã cam kết, chống giữ trùng cùng một tồn. Việc tạo/giữ đơn chưa làm giảm tồn thực tế hay ghi giá vốn.
3. Với mỗi đợt xuất, kho lập nhiệm vụ picking theo đơn bán và vị trí. Ưu tiên một lô đủ số lượng; nếu nhiều lô, hiển thị lô/số lượng và yêu cầu xác nhận cảnh báo trước khi lấy.
4. Thủ kho đếm lại hàng đã lấy, đối chiếu với nhiệm vụ và xác nhận phiếu xuất. Hệ thống kiểm tra lại tồn và lượng đã xuất của đơn ngay trước khi ghi nhận; giảm tồn tại đúng lô/vị trí và giảm lượng giữ tương ứng.
5. Mỗi phiếu xuất ghi giá vốn bằng lượng xuất nhân với đơn giá bình quân tại thời điểm xác nhận. Đơn bán ở `ĐANG_XUẤT` cho đến khi tổng phiếu xuất hợp lệ bằng số lượng đã chốt.
6. Kế toán đối chiếu đơn bán, các phiếu xuất và hóa đơn; nếu khớp, xác nhận hóa đơn. Chỉ khi **xuất đủ và hóa đơn được kế toán xác nhận** thì đơn bán chuyển `ĐÃ_HOÀN_THÀNH`. Thanh toán/công nợ tiếp tục theo dõi riêng.

```text
Khách tạo đơn mua → Kiểm tra tồn khả dụng → Xác nhận đơn bán
→ Giữ hàng → Picking theo lô → Phiếu xuất kho (có thể nhiều lần)
→ Xuất đủ → Kế toán xác nhận hóa đơn → Đơn bán hoàn thành
```

**Kết quả:** số lượng xuất và giá vốn được ghi nhận tại từng phiếu xuất; có thể truy vết lịch sử hàng đã bán cho khách theo lô. Hệ thống không yêu cầu xác nhận giao hàng.

### Luồng thay thế (alternative)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| A1 | Xuất nhiều đợt: tạo nhiều nhiệm vụ và phiếu xuất cho cùng đơn; mỗi đợt chỉ lấy phần còn lại. | Đơn `ĐANG_XUẤT` cho đến khi đủ; mỗi phiếu chỉ giảm tồn một lần. |
| A2 | Khách đổi số lượng/mặt hàng trước khi xuất: cập nhật đơn bán theo quyền hạn, tính lại lượng giữ và giá. | Phần giảm được nhả giữ; phần tăng chỉ giữ khi đủ tồn khả dụng. |
| A3 | Không có lô đơn lẻ đủ: đề xuất nhiều lô, ghi rõ chênh lệch màu/lô và yêu cầu người có quyền xác nhận. | Chỉ xuất các lô đã xác nhận; lịch sử từng lô được lưu. |

### Trường hợp không đạt (unhappy case)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| U1 | Thiếu tồn khi nhận đơn: đề nghị chờ nhập, giảm số lượng, đổi sản phẩm hoặc hủy theo ý khách. | Không giữ quá tồn khả dụng; đơn chờ xử lý hoặc bị hủy. |
| U2 | Picking thiếu/hỏng/sai lô: ghi chênh lệch, chọn lô khác hoặc giảm đợt xuất; hàng hỏng xử lý riêng. | Không xác nhận phiếu xuất sai; tồn chỉ giảm theo lượng thực xuất được duyệt. |
| U3 | Kế toán thấy hóa đơn lệch số lượng/giá hoặc thiếu chứng từ: từ chối xác nhận, yêu cầu sửa hóa đơn/đơn theo quy định. | Đơn ở `ĐÃ_XUẤT_ĐỦ_CHỜ_HÓA_ĐƠN`, tồn đã xuất không tự phục hồi. |
| U4 | Khách hủy sau khi đã xuất một phần: dừng các đợt sau, nhả lượng giữ chưa xuất; phần đã xuất xử lý bằng quy trình khách trả nếu hàng được nhận lại. | Không xóa hoặc đảo ngầm phiếu xuất cũ. |

### Ngoại lệ (exception)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| E1 | Hai đơn cùng giữ/xuất lượng tồn cuối: kiểm tra và khóa giao dịch tại thời điểm giữ/xác nhận xuất. Giao dịch đến sau phải tính lại tồn. | Không cho tồn khả dụng âm. |
| E2 | Xác nhận phiếu xuất lặp hoặc mất kết nối sau khi bấm xác nhận: tra mã giao dịch trước khi thử lại. | Không trừ tồn hay ghi giá vốn hai lần. |
| E3 | Dịch vụ hóa đơn tạm lỗi: giữ kết quả kho đã xác nhận; kế toán xác nhận lại khi có hóa đơn hợp lệ. | Đơn chưa hoàn thành; không đảo phiếu xuất vì lỗi hóa đơn. |

---

## 3. Quy trình chuyển kho nội bộ

**Điểm bắt đầu:** cần điều chuyển hàng giữa hai kho do phân bổ tồn hoặc nhu cầu bán. Chuyển hàng giữa hai vị trí trong cùng một kho cũng được ghi nhận để bảo đảm đúng vị trí. **Người thực hiện:** người yêu cầu, thủ kho nguồn và thủ kho đích.

**Đầu vào:** kho/vị trí nguồn, kho/vị trí đích, mã hàng/lô, số lượng, lý do. **Đầu ra:** yêu cầu chuyển, phiếu xuất nguồn, phiếu nhập đích và đối soát. Trạng thái: `CHỜ_DUYỆT → ĐÃ_DUYỆT → ĐÃ_XUẤT_NGUỒN → NHẬN_MỘT_PHẦN/ĐÃ_NHẬN_ĐỦ → ĐÃ_ĐÓNG`.

### Luồng chuẩn

1. Người yêu cầu chọn kho/vị trí nguồn và đích, mã hàng, lô, số lượng, lý do. Hệ thống kiểm tra hai kho khác nhau đối với chuyển kho và tồn khả dụng của từng lô ở kho nguồn.
2. Người có quyền duyệt yêu cầu; hệ thống giữ lượng cần chuyển để đơn bán mới không dùng trùng. Thủ kho nguồn picking và đối chiếu mã hàng, lô, vị trí, số lượng.
3. Xác nhận phiếu xuất chuyển kho: giảm tồn kho nguồn và lượng giữ; tăng lượng **đang chuyển** theo yêu cầu/lô. Đây chưa phải tồn kho đích.
4. Thủ kho đích kiểm đếm thực nhận với phiếu xuất nguồn, ghi nhận lượng đạt và chênh lệch. Lập phiếu nhập chuyển kho cho lượng đạt, chọn vị trí và xác nhận put-away.
5. Khi phiếu nhập đích được xác nhận, giảm lượng đang chuyển và tăng tồn đích đúng một lần. Đóng yêu cầu khi tổng đã nhận cộng phần chênh lệch được xử lý bằng tổng đã xuất nguồn.

```text
Yêu cầu chuyển kho → Duyệt → Xuất tại kho nguồn
→ Đang chuyển/chờ nhập → Nhận tại kho đích → Put-away
→ Đối soát và đóng yêu cầu
```

**Quy tắc giá vốn:** chuyển kho nội bộ không phải mua hay bán, nên không tạo giá vốn mới và không đổi đơn giá bình quân của mã hàng. Với chuyển vị trí trong cùng kho, chỉ đổi vị trí lưu trữ; tổng tồn của kho không đổi.

### Luồng thay thế (alternative)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| A1 | Chuyển nhiều đợt: mỗi đợt có cặp phiếu xuất nguồn/nhập đích, cùng liên kết yêu cầu. | Theo dõi đã xuất, đang chuyển, đã nhận và còn phải chuyển riêng. |
| A2 | Chuyển giữa các vị trí trong cùng kho: xác nhận chuyển vị trí từ bin nguồn sang bin đích, không dùng trạng thái giữa hai kho. | Giảm vị trí nguồn, tăng vị trí đích trong cùng giao dịch; tổng tồn kho không đổi. |
| A3 | Kho đích nhận một phần hợp lệ: nhập phần đạt, phần còn thiếu giữ ở trạng thái chờ đối soát. | Chỉ phần đã nhận tăng tồn đích; phần thiếu còn trong số lượng đang chuyển. |

### Trường hợp không đạt (unhappy case)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| U1 | Kho nguồn không đủ hàng lúc duyệt hoặc picking: giảm số lượng chuyển theo phê duyệt, chờ bổ sung hoặc từ chối yêu cầu. | Không xuất vượt tồn khả dụng; nhả phần giữ không thực hiện. |
| U2 | Kho đích nhận thiếu, thừa, sai lô hoặc hỏng: lập biên bản chênh lệch; nhập phần đúng, cách ly phần sai/hỏng, điều tra phần thiếu. | Không tự cộng lượng thiếu vào tồn đích hoặc tự xóa lượng đang chuyển. |
| U3 | Hủy yêu cầu sau khi nguồn đã xuất: không hủy ngầm phiếu xuất; thực hiện nhập lại kho nguồn hoặc chứng từ chuyển trả có tham chiếu. | Lịch sử và số dư đang chuyển vẫn đối soát được. |

### Ngoại lệ (exception)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| E1 | Kho/vị trí đích bị khóa, ngừng hoạt động hoặc không đủ sức chứa: không xác nhận nhập vào vị trí đó; chọn vị trí hợp lệ hoặc giữ hàng chờ put-away. | Chưa tăng tồn tại vị trí đích không hợp lệ. |
| E2 | Hai thủ kho cùng xác nhận nhận một lượng đang chuyển: kiểm tra số lượng còn chờ và mã giao dịch trước khi ghi nhận. | Tổng nhập đích không vượt tổng xuất nguồn. |
| E3 | Mất kết nối giữa phiếu xuất và phiếu nhập: giữ phiếu xuất đã xác nhận, cho tra cứu và tiếp tục nhận theo cùng mã yêu cầu. | Không xuất lại ở kho nguồn; lượng đang chuyển vẫn hiển thị. |

---

## 4. Quy trình kiểm kho

**Điểm bắt đầu:** kiểm kê định kỳ, kiểm kê theo khu vực/vị trí hoặc kiểm tra đột xuất. **Người thực hiện:** thủ kho kiểm đếm; chủ cửa hàng/người có quyền phê duyệt chênh lệch.

**Đầu vào:** phạm vi kho/vị trí, thời điểm chốt sổ và người kiểm. **Đầu ra:** phiếu kiểm, kết quả đếm, phiếu điều chỉnh hoặc biên bản không chênh lệch. Trạng thái: `ĐÃ_TẠO → ĐANG_ĐẾM → CHỜ_DUYỆT_CHÊNH_LỆCH → ĐÃ_ĐÓNG`.

### Luồng chuẩn

1. Người phụ trách tạo phiếu kiểm với kho, khu vực/vị trí, mã hàng/lô và thời điểm bắt đầu. Hệ thống lưu **snapshot** số lượng sổ sách; khóa hoặc kiểm soát các biến động kho trong phạm vi kiểm.
2. Người kiểm đếm ghi lượng thực tế theo mã hàng, lô, màu/cỡ và vị trí, kể cả vị trí trống hoặc hàng đặt sai vị trí. Người kiểm không tự sửa số liệu sổ sách.
3. Hệ thống tính chênh lệch `thực đếm − snapshot`. Nếu lệch, thực hiện kiểm đếm lại độc lập và đối chiếu phiếu nhập/xuất/chuyển đang mở, hàng cách ly và vị trí khác.
4. Người có quyền duyệt kết quả cuối cùng. Thiếu/thừa thật tạo phiếu điều chỉnh tồn; hàng đúng tổng lượng nhưng sai vị trí tạo chứng từ chuyển vị trí. Điều chỉnh giảm ghi giá trị theo bình quân hiện hành; điều chỉnh tăng cần giá trị được phê duyệt để cập nhật bình quân.
5. Sau khi các chênh lệch đã xử lý và đối chiếu số dư, đóng phiếu kiểm, lưu snapshot/kết quả/lý do/người duyệt và mở khóa phạm vi.

```text
Phiếu kiểm kho → Chốt số liệu/kiểm soát biến động → Kiểm đếm
→ So sánh → Kiểm đếm lại nếu lệch → Duyệt điều chỉnh
→ Cập nhật tồn và giá trị → Đóng kiểm kho
```

**Kết quả:** có số lượng sổ sách, số lượng thực tế, chênh lệch, lý do và người phê duyệt. Chênh lệch chỉ làm thay đổi tồn sau khi phiếu điều chỉnh được duyệt.

### Luồng thay thế (alternative)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| A1 | Kiểm kê luân phiên một khu vực hoặc một nhóm mã hàng thay vì toàn kho. | Chỉ khóa/chốt phạm vi đã chọn; hoạt động ngoài phạm vi tiếp tục bình thường. |
| A2 | Không có chênh lệch: người có quyền xác nhận kết quả và đóng phiếu. | Không có phiếu điều chỉnh; mở khóa phạm vi. |
| A3 | Tổng lượng đúng nhưng hàng ở sai bin: lập chứng từ chuyển vị trí sau khi xác minh. | Chỉ đổi vị trí, không đổi tổng tồn hoặc giá trị. |

### Trường hợp không đạt (unhappy case)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| U1 | Đếm lại vẫn thiếu/thừa: lập biên bản nguyên nhân, phê duyệt mức điều chỉnh theo quyền hạn. | Trước khi duyệt, tồn sổ sách giữ nguyên; sau duyệt mới ghi chênh lệch. |
| U2 | Người duyệt từ chối kết quả do chứng cứ không đủ: yêu cầu đếm lại hoặc điều tra bổ sung. | Phiếu còn mở, chưa điều chỉnh, phạm vi tiếp tục được kiểm soát. |
| U3 | Phát hiện hàng hỏng hoặc không rõ lô: cách ly và xác minh nhận dạng, không gộp vào hàng bán được. | Chỉ điều chỉnh sau khi phân loại và duyệt. |

### Ngoại lệ (exception)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| E1 | Có giao dịch nhập/xuất/chuyển phát sinh sau snapshot trong phạm vi bị khóa: chặn giao dịch hoặc tái lập snapshot và kiểm lại nếu có thao tác được phép. | Không so sánh kết quả đếm với số liệu cũ sai thời điểm. |
| E2 | Chốt kiểm hai lần hoặc xác nhận lại phiếu điều chỉnh: kiểm mã phiếu và trạng thái đã ghi nhận. | Không điều chỉnh tồn lặp. |
| E3 | Mất dữ liệu đếm hoặc không xác định được lô/vị trí: giữ phiếu mở, yêu cầu nhập lại/kiểm lại có nhật ký. | Không tự tạo chênh lệch từ dữ liệu thiếu. |

---

## 5. Quy trình nhập hàng trả lại từ khách hàng

**Điểm bắt đầu:** khách yêu cầu trả hàng đã xuất theo đơn bán. **Người thực hiện:** nhân viên kinh doanh tiếp nhận; thủ kho kiểm hàng và nhập lại; kế toán xử lý hóa đơn/hoàn tiền/công nợ khi cần.

**Đầu vào:** đơn bán và phiếu xuất gốc, mã hàng/lô, lượng đề nghị trả, lý do. **Đầu ra:** yêu cầu trả, kết quả kiểm nhận, phiếu nhập trả hoặc hồ sơ hàng hỏng. Trạng thái: `CHỜ_XÉT_DUYỆT → ĐƯỢC_CHẤP_NHẬN → CHỜ_HÀNG_VỀ → ĐANG_KIỂM_NHẬN → ĐÃ_XỬ_LÝ`; có thể `TỪ_CHỐI`.

### Luồng chuẩn

1. Nhân viên kinh doanh ghi yêu cầu trả với lý do, mã hàng, lô, lượng và chứng từ bán gốc; kiểm điều kiện nhận trả và `lượng đề nghị ≤ lượng đã xuất − lượng đã trả trước`.
2. Người có quyền chấp nhận yêu cầu; đây mới là chấp nhận **kiểm hàng**, chưa tự động chấp nhận hoàn tiền hoặc tăng tồn. Khi hàng về, thủ kho lập biên bản thực nhận và đối chiếu sản phẩm, lô, màu/cỡ, số lượng, tình trạng với phiếu xuất gốc.
3. Phân loại lượng thực nhận: **đạt để bán lại**, **cần cách ly/đánh giá thêm**, **hỏng không bán được**. Ghi ảnh/ghi chú nếu cần. Không trộn các loại trong cùng một dòng nhập bán được.
4. Với hàng đạt, lập phiếu nhập trả liên kết phiếu xuất gốc, ghi đúng lô ban đầu và giá trị hoàn nhập được kế toán xác nhận; put-away vào vị trí phù hợp. Khi xác nhận phiếu nhập, tăng tồn bán được và cập nhật đơn giá bình quân theo giá trị thực nhập.
5. Hàng hỏng/cần đánh giá nằm ở khu vực cách ly, có hồ sơ hàng hỏng hoặc quyết định xử lý riêng. Kế toán đối chiếu lượng được chấp nhận để xử lý hóa đơn, hoàn tiền hoặc giảm công nợ; đóng yêu cầu khi số lượng và tài chính đã được đối soát.

```text
Yêu cầu trả của khách → Đối chiếu đơn bán/phiếu xuất gốc → Kiểm nhận
├─ Hàng đạt → Phiếu nhập trả → Đúng lô gốc → Put-away → Tăng tồn bán được
└─ Hàng hỏng → Cách ly/hồ sơ hàng hỏng → Không tăng tồn bán được
```

**Kết quả:** hàng đạt quay lại kho đúng lô; hàng hỏng được theo dõi riêng; số lượng, giá trị và công nợ được đối chiếu với giao dịch gốc.

### Luồng thay thế (alternative)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| A1 | Khách chỉ trả một phần hoặc trả nhiều đợt: mỗi đợt kiểm nhận và lập phiếu nhập riêng, tất cả liên kết phiếu xuất gốc. | Tổng lượng nhập trả không vượt lượng đã xuất; đơn bán gốc và lịch sử xuất vẫn còn. |
| A2 | Đổi sang sản phẩm khác: hoàn tất nhập trả cho hàng cũ, rồi tạo đơn mua/đơn bán mới cho hàng đổi. | Không bù trừ số lượng giữa hai mã hàng trong một phiếu kho. |
| A3 | Hàng tạm chưa đánh giá xong: ghi nhận vật lý ở khu vực cách ly và kiểm tra sau. | Chưa tăng tồn bán được hoặc cập nhật bình quân cho phần này. |

### Trường hợp không đạt (unhappy case)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| U1 | Không có chứng từ bán hợp lệ, quá điều kiện trả hoặc lượng yêu cầu vượt lượng có thể trả: từ chối hoặc yêu cầu xác minh. | Không lập phiếu nhập bán được, không hoàn tiền tự động. |
| U2 | Sai mã/lô/màu/cỡ hoặc số lượng thực tế ít hơn khai báo: ghi lượng thực nhận, cách ly phần không khớp, thương lượng lại với khách. | Chỉ phần đạt đã duyệt mới nhập; phần thiếu không tăng tồn. |
| U3 | Hàng vỡ/hỏng không bán lại được: lập hồ sơ tổn thất và quyết định có nhận/hoàn tiền hay không. | Không cộng vào tồn bán được; giá trị thu hồi nếu có theo quyết định riêng. |

### Ngoại lệ (exception)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| E1 | Hai yêu cầu cùng tham chiếu một lượng đã xuất: khóa/kiểm tra lại tổng lượng đã trả khi xác nhận phiếu nhập. | Không nhập trả vượt lượng bán gốc. |
| E2 | Không truy được giá vốn ở phiếu xuất gốc hoặc lô gốc không hợp lệ: giữ hàng cách ly, yêu cầu kế toán/kho xác minh giá trị và lô trước khi nhập bán được. | Không tự gán giá vốn bằng 0 hoặc tạo lô sai. |
| E3 | Phiếu nhập đã xác nhận nhưng xử lý hóa đơn/hoàn tiền lỗi: giữ nguyên nhập kho, đánh dấu tài chính chờ xử lý và cho đối soát lại. | Không tạo phiếu nhập trùng hoặc đảo tồn vì lỗi kế toán. |

---

## 6. Quy trình trả lại hàng cho nhà cung cấp

**Điểm bắt đầu:** phát hiện hàng nhập sai, thừa, lỗi hoặc hỏng thuộc diện được nhà cung cấp chấp nhận trả. **Người thực hiện:** người phụ trách mua hàng làm việc với nhà cung cấp; thủ kho kiểm và xuất hàng trả; kế toán điều chỉnh chứng từ/công nợ.

**Đầu vào:** đơn mua và phiếu nhập gốc, mã hàng/lô, lượng muốn trả, lý do và bằng chứng. **Đầu ra:** yêu cầu trả nhà cung cấp, phiếu xuất trả, kết quả đối soát và chứng từ tài chính. Trạng thái: `CHỜ_NCC_XÁC_NHẬN → ĐƯỢC_CHẤP_NHẬN → CHỜ_XUẤT_TRẢ → ĐÃ_XUẤT_TRẢ → ĐÃ_ĐỐI_SOÁT`; có thể `TỪ_CHỐI`.

### Luồng chuẩn

1. Người phụ trách mua hàng tạo yêu cầu trả, liên kết đơn mua và phiếu nhập gốc, ghi mã hàng/lô, số lượng, lỗi và bằng chứng; kiểm `lượng trả ≤ lượng còn thực có từ lô nhập liên quan`.
2. Nhà cung cấp xác nhận lượng và phương án: hoàn tiền, giảm công nợ, đổi hàng hoặc chỉ nhận một phần. Chỉ phần được duyệt mới chuyển sang chờ xuất trả.
3. Kho giữ/cách ly đúng lô và số lượng đã duyệt, không cho đơn bán hoặc chuyển kho sử dụng trùng. Thủ kho picking, kiểm đếm và lập phiếu xuất trả có tham chiếu yêu cầu và phiếu nhập gốc.
4. Khi xác nhận phiếu xuất trả, giảm tồn thực tế tại lô/vị trí và giải phóng lượng giữ cho trả. Ghi giá trị xuất theo bình quân hiện hành; không sửa lại phiếu nhập hay phiếu bán cũ.
5. Đối chiếu số lượng nhà cung cấp thực chấp nhận và chứng từ điều chỉnh. Kế toán ghi giảm công nợ/hoàn tiền; nếu giá trị chứng từ khác giá trị xuất kho, xử lý chênh lệch kế toán. Đóng yêu cầu khi lượng xuất và kết quả đối soát đã rõ.

```text
Phát hiện hàng cần trả → Yêu cầu trả NCC → NCC xác nhận
→ Cách ly/giữ hàng → Phiếu xuất trả NCC → Giảm tồn
→ Đối chiếu số lượng và chứng từ → Đóng yêu cầu
```

**Kết quả:** kho giảm đúng số lượng/lô đã trả và có thể truy vết từ phiếu xuất trả về lần nhập gốc. Hệ thống không theo dõi xe hoặc hành trình trả hàng.

### Luồng thay thế (alternative)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| A1 | Nhà cung cấp chỉ chấp nhận một phần: xuất phần được duyệt; phần còn lại tiếp tục cách ly hoặc đưa về tồn bán được sau khi kiểm tra và phê duyệt. | Chỉ lượng thực xuất làm giảm tồn; lượng còn lại có trạng thái rõ ràng. |
| A2 | Nhà cung cấp đổi hàng thay vì hoàn tiền: hoàn tất phiếu xuất trả; hàng thay thế được kiểm nhận bằng phiếu nhập mới liên kết yêu cầu đổi. | Không cộng hàng thay thế trước khi thực nhận; giá vốn bình quân cập nhật theo giá trị nhập thay thế được duyệt. |
| A3 | Hàng lỗi phát hiện ngay lúc nhận và chưa nhập bán được: từ chối nhận ở quy trình 1, không tạo phiếu xuất trả từ tồn kho. | Không phát sinh tăng/giảm tồn bán được giả. |

### Trường hợp không đạt (unhappy case)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| U1 | Nhà cung cấp từ chối trả trước khi xuất: hủy yêu cầu trả hoặc thương lượng tiếp; kiểm tra chất lượng trước khi nhả giữ. | Không giảm tồn; hàng lỗi vẫn cách ly nếu chưa đạt để bán. |
| U2 | Lô cần trả đã bán/chuyển đi hoặc không đủ lượng: giảm lượng đề nghị, truy vết nguyên nhân và xin duyệt lại. | Không xuất âm hoặc lấy lô khác một cách ngầm định. |
| U3 | Nhà cung cấp tranh chấp lượng sau khi kho đã xuất: mở đối soát/khiếu nại; chỉ nhập lại kho nếu hàng thực sự quay về và qua kiểm nhận. | Phiếu xuất cũ giữ nguyên; không tăng tồn ảo. |

### Ngoại lệ (exception)

| Mã | Tình huống và cách xử lý | Trạng thái/tồn kho |
|---|---|---|
| E1 | Phiếu xuất trả được xác nhận lặp hoặc vượt lượng duyệt: kiểm mã giao dịch, số còn được trả và tồn hiện hành trước khi ghi. | Chỉ trừ tồn một lần, không vượt số đã duyệt. |
| E2 | Lô/vị trí bị khóa do kiểm kho hoặc một giao dịch khác vừa lấy hàng: chờ mở khóa hoặc chọn lại lượng/lô sau khi được duyệt. | Không trừ tồn tại vị trí không hợp lệ. |
| E3 | Kho đã xuất trả nhưng chứng từ giảm công nợ/hoàn tiền chưa xử lý được: ghi trạng thái tài chính chờ đối soát. | Không đảo phiếu xuất và không tạo xuất trả trùng vì lỗi kế toán. |

---

## Dữ liệu và báo cáo dùng chung

- **Dữ liệu nền:** sản phẩm/biến thể, đơn vị tính, quy cách đóng gói, lô, màu, cỡ, nhà cung cấp, khách hàng, kho, khu vực và vị trí.
- **Chứng từ kho:** phiếu nhập nhà cung cấp, phiếu xuất bán, phiếu xuất/nhập chuyển kho, phiếu kiểm kho và điều chỉnh, phiếu nhập hàng khách trả, phiếu xuất trả nhà cung cấp. Mỗi chứng từ có trạng thái, người tạo, người xác nhận, thời gian và liên kết chứng từ gốc.
- **Báo cáo:** nhập–xuất–tồn theo mã hàng/lô/kho/vị trí; tồn thực tế/đã giữ/khả dụng/đang chuyển; lịch sử biến động; hàng hỏng; chênh lệch kiểm kho; hàng trả hai chiều; giá trị tồn và giá vốn bình quân.

## Nguồn tham khảo và cách áp dụng

1. `tham_khao/Tổng hợp quy trình.pdf`: bối cảnh cửa hàng gạch, dữ liệu lô/màu, nhập–xuất, hàng khách trả và công thức bình quân gia quyền. Các bước quản lý vận chuyển trong tài liệu nguồn được loại khỏi phạm vi hiện tại.
2. `tham_khao/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_I_en_v4.1.pdf`: đơn mua nhà cung cấp, nhận hàng và put-away.
3. `tham_khao/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_II_en_v4.1.pdf`: chuyển kho nội bộ bằng xuất kho nguồn, nhập kho đích và put-away.
4. `tham_khao/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_III_en_v4.1.pdf`: đơn bán, picking và xuất kho. Luồng hiện tại thay bước giao hàng bằng xác nhận phiếu xuất; điều kiện hoàn thành đơn bán theo yêu cầu của dự án là kế toán xác nhận hóa đơn.
5. `tham_khao/Intro_S4HANA_Using_Global_Bike_Case_Study_WM_IV_en_v4.1.pdf`: kiểm đếm, kiểm đếm lại và xử lý chênh lệch tồn.

Quy trình trả nhà cung cấp được đề xuất để hoàn thiện sáu luồng kho của dự án; bộ tài liệu tham khảo trên không có một tình huống trả nhà cung cấp riêng.
