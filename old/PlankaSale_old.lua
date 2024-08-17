---@diagnostic disable: undefined-global, lowercase-global, trailing-space

-- ������ ������, ����������� ������ ��������� ������ �� ������� �� �����
-- �) ��� ���������� ������ �� ������
-- �) 
-- ��������� ������� ����� ��������� ����. � ���� ������ ����� � ���������� ����� �� ������, ��� ���������� ������� ������������ ������ �� ������� �� ���� �� 10% ���� ������ (�� �����). 
-- ���� � ���, ��� ����� �������� ����������, �� ������ ��������� � ����� ������.

-- ����������:
-- ��� ������� ������� ����������� ��������� ����, ���� ����� ������ ����� � ����� �� ������ � �����.
-- ��� �������� 

-- ���� ��� �������� ���������� ��������� ����� �������

is_run = true

IdUser = getInfoParam("USERID")
Client_code  = getItem("money_limits",1).client_code							-- ����� �����. ���� "4L06E", ����� "213288/000", ��� "10K2SQ"

if IdUser == "392295" then -- ����
	Firma = "MC0002500000"														-- ����� �� ��������� �����
	MyAccount = "L01-00000F00"													-- �������� ����
	TegBrocker = "����"
	Teg = "UCAF" -- ��� �������
elseif IdUser == "3325" then -- �����
	Firma = "MC0000500000"
	MyAccount = "L01-00000F00"
	TegBrocker = "�����"
	Teg = "EQTV" -- ��� �������
elseif IdUser == "147526" then -- ���
	Firma = "MC0003300000"
	MyAccount = "L01-00000F00"
	TegBrocker = "���"
	Teg = "EQTV" -- ��� �������
else
	message("��� ������ ��������� �� ��������� USERID")
end

--===============��������� ������ ====================
Stock_For_Sale = "AMEZ" -- ����������, ������� �������
Class_For_Sale = "TQBR" -- �����
Vol_For_Sale = 10000 --�����. ���� ����� �� ������ ������ �����, ���������.
--====================================================
Kol_For_Sale = 0 -- ���������� ����� ��� ������. ���� ����, ����� ������� ��� (�� ���������). ���� ������ ����, ������� ��, ��� �����������.
--====================================================

PlankaMax = tonumber(getParamEx(Class_For_Sale, Stock_For_Sale, "PRICEMAX").param_value) -- ����������� ��������� ����
Lot = math.ceil(getParamEx(Class_For_Sale,Stock_For_Sale,"LOTSIZE").param_value)
BidDEPTH = tonumber(getParamEx(Class_For_Sale, Stock_For_Sale, "BIDDEPTH").param_value) -- ���������� ����� �� ������ BID
Bid = tonumber(getParamEx(Class_For_Sale, Stock_For_Sale, "BID").param_value) -- ������ BID.

Price_For_Sale = PlankaMax -- ���� ��� ������. �� ���� "�� �����"

local n = getNumberOf("depo_limits")	
local order={}
for i=0,n-1 do
    order = getItem("depo_limits", i)        
    local secCode = order["sec_code"]		
    local kol = tonumber(order["currentbal"])        
    local t1 = order["limit_kind"] -- ���� ��������
    if t1 == 1 and secCode == Stock_For_Sale then
        StockAmount  = kol/Lot
    end
end 

if Kol_For_Sale == 0 then 
    Kol_For_Sale = StockAmount  
end

message("===============================")
message("����� : "..Stock_For_Sale.." ("..Class_For_Sale..")")
message("������������ ���� (������): "..tostring(PlankaMax))
message("������� ����� �� ������ BID: "..tostring(BidDEPTH))
message("�������� ��� ���������� ������ ��: "..tostring(Vol_For_Sale).." �����")
message("��������: "..tostring(Kol_For_Sale).." �����")
message("�������: "..tostring(StockAmount).." �����")
message("�� ����: "..tostring(Price_For_Sale))
message("===============================")

--Stock_For_Sale.." : "..Class_For_Sale.." : "..Vol_For_Sale.." : "..Kol_For_Sale.." : ")

function Body() 
    sleep(1)
    if is_run then
        BidDEPTH = tonumber(getParamEx(Class_For_Sale, Stock_For_Sale, "BIDDEPTH").param_value) -- ���������� ����� �� ������ BID
        if Bid == PlankaMax then
            if BidDEPTH <= Vol_For_Sale then
                message("��������!!!  ����� - "..tostring(BidDEPTH))            
                NewOrder("S", Stock_For_Sale, Class_For_Sale, tonumber(Kol_For_Sale), Price_For_Sale, "115")           
                is_run = false
            end
        else
            message("�������� ������ �� ������, ������ ������� ���� ����. ���� �� ������ = "..tostring(PlankaMax).." � ������� ����  = ".. tostring(BidDEPTH))
            is_run = false
        end
    end 
end

-- ���������� ������.

function NewOrder(operation, emit,class,qty,price,tr_id) -- ���������� ������
    if tonumber(qty)>0 then
        --���� � ������ ��� ��� ������� �����, ����� ������ ������ ��� ���� ���� 100.0. �������:
        local price_num = tonumber(price)
        if price_num~=nil then
            local a, b = math.modf(price_num)   -- ����� ����� ����� � ���������� 'a' � ������� � ���������� 'b'
            if b==0 then
                price = tostring(a)
            end
        else
            print("������: ���������� ������������� price � �����")
        end
        message("operation".." : "..operation.." , ".."emit".." : "..emit.." , ".."class".." : "..class.." , ".." qty".." : "..qty.." , ".." price".." : "..price.." , ".." tr_id".." : "..tr_id)
        local transaction={															--��������� ����������� ��� ������� ������ ����
                        ["ACCOUNT"] = MyAccount,
--							[CLIENT_CODE]= Client_code,
                        ["TRANS_ID"] = tostring(tr_id),
                        ["CLASSCODE"] = class,
                        ["SECCODE"] = emit,
                        ["ACTION"] = "NEW_ORDER",						
                        ["OPERATION"] = operation,
                        ["PRICE"] = tostring(price),
                        ["QUANTITY"] = tostring(qty),
                    }
        transaction.CLIENT_CODE = Client_code
        local res = sendTransaction(transaction)								--���� ��, �� ������ ������//���� �� �� ���-��, �� ������ � ������������ ������ �����
    end
    return 1																--���������� ���������
end

-- �������� �������, ������������� � ��������� ������
function main()
    while is_run do -- ���� ������ �������
        Body() -- ����� �������� ������ �������
    end
end

-- �������, ���������� ��� ��������� ������� �������������
function OnStop()
    is_run = false -- ������ ��������� ��������� �����
end
