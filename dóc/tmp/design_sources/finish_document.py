import json,re,pathlib,shutil,html,base64
p=pathlib.Path('tmp/design_sources');out=pathlib.Path('output');f=out/'WMSD_Thiet_ke_he_thong_chi_tiet.md'
ucs=json.loads((p/'ucs.json').read_text(encoding='utf-8'));perms=json.loads((p/'permissions.json').read_text(encoding='utf-8'))
def flow(n):
 if n<=10:return 'F04–F05'
 if n<=25:return 'F02'
 if n==26:return 'F05'
 if n<=31:return 'F02–F03'
 if n<=33:return 'F05'
 if n<=37:return 'F06'
 if n<=44:return 'F07'
 if n<=62:return 'F09'
 if n<=67:return 'F08'
 if n<=78:return 'F10'
 if n<=83:return 'F11'
 if n<=93:return 'F12'
 if n<=98:return 'F01'
 return 'F13'
translation={'View':'xem','Perform':'thực hiện','Approve':'duyệt','Receiving scope only':'chỉ phạm vi nhận hàng','Create / Update':'tạo / cập nhật','Create only':'chỉ tạo','Activate / Deactivate':'kích hoạt / ngừng','Usable stock only':'chỉ tồn dùng được','Issue / Export / Print':'phát hành / xuất / in','Export / Print issued only':'chỉ xuất / in bản đã phát hành','All report groups':'tất cả nhóm báo cáo','Movement; purchase/receipt':'luân chuyển; mua/nhận','Movement; stock; transfer; stocktake':'luân chuyển; tồn; chuyển kho; kiểm kê','Purchase / supplier scope':'phạm vi mua/NCC','Related sales only':'chỉ giao dịch bán liên quan'}
roles=['Owner','Kế toán','Kho','Bán hàng','Admin']
append='\n\n## Phụ lục A Truy vết đầy đủ 102 use case\n\nTên UC được giữ bằng tiếng Anh để đối chiếu trực tiếp R3. Owner là Store Owner; Kho là Inventory Staff. Quyền ghi dưới đây lấy từ ma trận R3 I.4.4, đối chiếu bộ D-UC đã chọn. Các giới hạn chi tiết của mục 2 vẫn áp dụng, kể cả khi một ô viết ngắn là “thực hiện”. F03 áp dụng thêm cho mọi UC xem danh sách/chi tiết.\n\n| UC và tên nguồn | FE và màn hình | Luồng thiết kế | Quyền theo vai trò |\n|---|---|---|---|\n'
assert len(ucs)==len(perms)==102
for i,(u,row) in enumerate(zip(ucs,perms),1):
 assert row[0]==u['id']
 match=re.search(r'Feature: (FE-\d+); Screen: (SC-\d+)',u['text']);assert match,(i,u)
 rights='; '.join(roles[j]+': '+translation.get(v,v) for j,v in enumerate(row[2:]) if v!='—')
 append+=f'| {u["id"]} {row[1]} | {match[1]} / {match[2]} | {flow(i)} | {rights} |\n'
append+='\n## Phụ lục B Phần bổ sung từ sơ đồ được chọn\n\n| Mã thiết kế | Nội dung | Nguồn và liên hệ UC |\n|---|---|---|\n| D35-01 | Sửa đề nghị và quay lại Owner review | Purchasing v3 To-be; bổ sung vòng xử lý UC-03/04 |\n| D35-02 | NCC không đáp ứng thì sửa/hủy phần chưa nhận và xác nhận lại | Purchasing v3 To-be; UC-07 |\n| D35-03 | Đối chiếu GR, thống nhất thay thế/giao sau/điều chỉnh lượng | Purchasing v3 To-be; UC-07/26 và F04 |\n| D35-04 | Owner duyệt đóng số lượng còn thiếu khi không giao tiếp | Purchasing v3 To-be; chưa có UC riêng trong danh mục 102 UC |\n| D35-05 | Đối chiếu chứng từ mua trước khi Accountant đóng PO | Purchasing v3 To-be; cần bổ sung đặc tả thao tác FE-01 |\n| D37-01 | Upload evidence tới Cloudinary và lưu kết quả | Trung Context Diagram; hỗ trợ UC có bằng chứng, hợp đồng kỹ thuật [TK] |\n\n## Phụ lục C Danh mục tham chiếu kiểm soát\n\nR1: I.2 Project Purpose; IV Proposed Solution; V.1 Major Features; V.2 Limitations & Exclusions.\n\nR3: I.2 Main Business Flow; I.3.1 ERD và I.3.2 Entity Descriptions; I.3.3 DR-01–14; I.4.2 danh mục UC; I.4.4 Permission Matrix; II toàn bộ UC-01–102; III SC-01–27, API-01 và JOB-01; IV Quality Attributes; V Business Rules và MSG-01–07.\n\nDraw.io: trang 14 Bản sao của UC Accountants; 16 Bản sao của UC Admin; 18 Bản sao của UC SO; 20 Bản sao của UC SS; 22 Bản sao của UC_IS; 35 Purchasing and Receiving_v3 phần To-be; 36 Chuyển kho nội bộ phần TO BE; 37 Trung Context Diagram. Những trang BF cũ hơn chỉ dùng khi không xung đột bộ UC được chọn.\n'
s=f.read_text(encoding='utf-8');s=s.split('\n\n## Phụ lục A')[0]+append;f.write_text(s,encoding='utf-8')
shutil.copyfile(p/'erd_image24.png',out/'WMSD_ERD_tu_Report3.png')
print(json.dumps({'words':len(s.split()),'characters':len(s),'UC_rows':len(perms),'headings':len(re.findall(r'^#{1,3} ',s,re.M))}))
