---@diagnostic disable: undefined-global
-- ����� Lesenka

-- ���� � ������������ ����� ��� �������, ������� ���������� ��������� � Telegram.
SEND_TELEGRAM_EXE_PATH = 'message.ps1'

dofile(getScriptPath() .. "\\dll_New_Planka_Sale.lua")	--����������� �����, ��� ������� �������� �������

IdUser = getInfoParam("USERID")
Client_code  = getItem("money_limits",1).client_code							-- ����� �����. ���� "4L06E", ����� "213288/000", ��� "10K2SQ"


if IdUser == "392295" then
	Firma = "MC0002500000"														-- ����� �� ��������� �����
	MyAccount = "L01-00000F00"													-- �������� ����
	TegBrocker = "����"
	SaleLevelExport = getScriptPath().."\\Export\\Sber\\Planka_Sber.csv"
	Path_time_log_txt = getScriptPath().."\\Export\\Sber\\log.txt"
	Teg = "EQTV" -- ��� �������
elseif IdUser == "3325" then
	Firma = "MC0000500000"														
	MyAccount = "L01-00000F00"
	TegBrocker = "�����"
	SaleLevelExport = getScriptPath().."\\Export\\Alpha\\Planka_Alpha.csv"
	Path_time_log_txt = getScriptPath().."\\Export\\Alpha\\log.txt"
	Teg = "EQTV" -- ��� �������
elseif IdUser == "147526" then
	Firma = "MC0003300000"														
	MyAccount = "L01-00000F00"
	TegBrocker = "���"
	SaleLevelExport = getScriptPath().."\\Export\\VTB\\Planka_VTB.csv"	
	Path_time_log_txt = getScriptPath().."\\Export\\VTB\\log.txt"
	Teg = "EQTV" -- ��� �������
else
	message("��� ������ ��������� �� ��������� USERID")
end	

is_run = true
WriteTable = 1  -- 1. �������������� ���������� ������ ����� ������� �������. 0. ������� �� �������������
Count = 0
Avtomat_buy = 0
tickers_updated = {}
buffers_by_ticker = {}
signalCounter1 = 0 -- ������� ������� 1 ��� ���������� �������� �������������
signalCounter2 = 0 -- ������� ������� 2 ��� ���������� �������� �������������
lastLogTime = os.time() -- ��� ����� ��� � ������
-- ������ .ps ����� ��� ������ ��� �������� ����������������� ����
os.execute('start cmd /k powershell -NoExit -ExecutionPolicy Bypass -File "D:\\YandexDisk\\DropBox\\����������\\��������\\������\\New_Planka\\run_script.ps1" -logFilePath "' .. Path_time_log_txt .. '"')






function OnInit()	

	MyAssetID = AllocTable()	
	 AddColumn (MyAssetID, 1, "�����", true, QTABLE_STRING_TYPE,10)
	 AddColumn (MyAssetID, 2, "�����", true, QTABLE_STRING_TYPE,10)
	 AddColumn (MyAssetID, 3, "������", true, QTABLE_STRING_TYPE,10)
	 AddColumn (MyAssetID, 4, "����� <", true, QTABLE_STRING_TYPE,14)	 
	 AddColumn (MyAssetID, 5, "������� �", true, QTABLE_STRING_TYPE,14)
	 AddColumn (MyAssetID, 6, "�������", true, QTABLE_STRING_TYPE,12)
	 AddColumn (MyAssetID, 7, "� �������", true, QTABLE_STRING_TYPE,14)	 
	 AddColumn (MyAssetID, 8, "�� ������", true, QTABLE_STRING_TYPE,14)
	 AddColumn (MyAssetID, 9, "����� (��)", true, QTABLE_STRING_TYPE,14)
	 AddColumn (MyAssetID, 10, "����� (���)", true, QTABLE_STRING_TYPE,1)
	 AddColumn (MyAssetID, 11, "V 5 ���", true, QTABLE_STRING_TYPE,1)
	 AddColumn (MyAssetID, 12, "V (- 5�)", true, QTABLE_STRING_TYPE,1)
 	 AddColumn (MyAssetID, 13, "����� 5 ���", true, QTABLE_STRING_TYPE,17)
	 AddColumn (MyAssetID, 14, "S1", true, QTABLE_STRING_TYPE,1)	
	 AddColumn (MyAssetID, 15, "S2", true, QTABLE_STRING_TYPE,1)
	 AddColumn (MyAssetID, 16, "S3", true, QTABLE_STRING_TYPE,1)
	 
	 AddColumn (MyAssetID, 17, "���������", true, QTABLE_STRING_TYPE,15)
	 AddColumn (MyAssetID, 18, "-10%", true, QTABLE_STRING_TYPE,7)
	 AddColumn (MyAssetID, 19, "-6%", true, QTABLE_STRING_TYPE,7)
	 AddColumn (MyAssetID, 20, "-3%", true, QTABLE_STRING_TYPE,7)
	 AddColumn (MyAssetID, 21, "�������!!!", true, QTABLE_STRING_TYPE,15)
	 AddColumn (MyAssetID, 22, "", true, QTABLE_STRING_TYPE,1)
	 AddColumn (MyAssetID, 23, "v1", true, QTABLE_STRING_TYPE,10)
	 AddColumn (MyAssetID, 24, "v2", true, QTABLE_STRING_TYPE,10)
	 AddColumn (MyAssetID, 25, "v5", true, QTABLE_STRING_TYPE,10)
	 AddColumn (MyAssetID, 26, "v30", true, QTABLE_STRING_TYPE,10)
	 AddColumn (MyAssetID, 27, "v60", true, QTABLE_STRING_TYPE,10)
	 AddColumn (MyAssetID, 28, "v300", true, QTABLE_STRING_TYPE,10)
	 
	CreateWindow(MyAssetID)	
	
	if TegBrocker == "None" then 
		SetWindowPos(MyAssetID,1520,0,1020,1254)										-- ����� �������. ������ �����*������ ������*������*������ �������
	else
		SetWindowPos(MyAssetID,981,0,1550,510)										-- ����� �������. ������ �����*������ ������*������*������ �������
	end 	
	SetWindowCaption(MyAssetID, "��� �����")


	-- ���������� ���������� ������ ������������	
	KomCentrID = AllocTable()													-- ������� � ��������� � ���������� ���������� ������. 
	AddColumn (KomCentrID, 1, "��������/��������", true, QTABLE_STRING_TYPE,31)	-- ��������
	AddColumn (KomCentrID, 2, "���������", true, QTABLE_STRING_TYPE,15)			-- �������� ���������
	CreateWindow(KomCentrID)
	if TegBrocker == "None" then 
		SetWindowPos(KomCentrID,681,0,286,510)										-- ����� �������. ������ �����*������ ������*������*������ �������
	else
		SetWindowPos(KomCentrID,691,0,290,510)										-- ����� �������. ������ �����*������ ������*������*������ �������
	end 
	SetWindowCaption(KomCentrID, "��������� ����� ������")							-- �������� �������
	
	InsertRow(KomCentrID,1)
	SetCell(KomCentrID, 1, 1, "�������� �����")	
	SetColor(KomCentrID,1,QTABLE_NO_INDEX,RGB(100, 150, 100),RGB(255,255,255),RGB(110, 160, 110),RGB(255,255,255))
	InsertRow(KomCentrID,2)			
	SetCell(KomCentrID,2, 1, "--------------------------------")	
	InsertRow(KomCentrID,3)	
	SetCell(KomCentrID, 3, 1, "���������")	
	SetColor(KomCentrID,3,QTABLE_NO_INDEX,RGB(175,218,252),RGB(1,1,1),RGB(220,220,220),QTABLE_DEFAULT_COLOR)
	InsertRow(KomCentrID,4)	
	SetCell(KomCentrID,4, 1, "--------------------------------")
	InsertRow(KomCentrID,5)	
	SetCell(KomCentrID,5, 1, "--------------------------------")	
	InsertRow(KomCentrID,6)
	SetCell(KomCentrID, 6, 1, "�������� ����������")
	SetColor(KomCentrID,6,QTABLE_NO_INDEX,RGB(240,255,240),RGB(1,1,1),RGB(220,220,220),QTABLE_DEFAULT_COLOR)
	InsertRow(KomCentrID,7)
	SetCell(KomCentrID,7, 1, "������� ���� Excel")
	InsertRow(KomCentrID,8)	
	SetCell(KomCentrID,8, 1, "������� ������� ������")
	InsertRow(KomCentrID,9)
	SetCell(KomCentrID,9, 1, "--------------------------------")
	InsertRow(KomCentrID,10)	
	SetCell(KomCentrID,10, 1, "�������� ������������")
	SetCell(KomCentrID,10, 2, "���������")
	SetColor(KomCentrID,10,QTABLE_NO_INDEX,RGB(255, 102, 102),RGB(255,255,255),RGB(255, 102, 102),RGB(255,255,255))
	InsertRow(KomCentrID,11)
	SetCell(KomCentrID,11, 1, "--------------------------------")
	InsertRow(KomCentrID,12)
	SetCell(KomCentrID,12, 1, "������ -15% (�������)")
	SetCell(KomCentrID,12, 2, tostring(Avtomat_buy))
	InsertRow(KomCentrID,13)
	SetCell(KomCentrID,13, 1, "�������")
	SetColor(KomCentrID,13,1,RGB(255, 255, 204),RGB(0,0,0),RGB(255, 255, 204),RGB(0,0,0))
	
	
end 


function main()															--������� �������� � ��������� ������
	while is_run do														--������ ����������� ����
		Body()															--���� ���������: ����� �������� ������� � ���� �������� ��������� �����
	end
end

function OnStop()											--����������� ��� ��������� ��������� �� ���� "��������� �������"
   	stop =  DestroyTable(KomCentrID)
	DestroyTable(MyAssetID)	
	DestroyTable(PlankaMinusID)
	DestroyTable(My_lot_for_saleID)
	is_run = false											--��������� �����	
end

function OnTrade(trade)	
	-- Automat = 0		
	-- message("������!!! ����������: ".. tostring(trade.sec_code)..". ����:  ".. tostring(trade.price)..". ���������� � ������: ".. tostring(trade.order_qty)..". ����������: ".. tostring(trade.qty))
	-- setPrice(trade.trade_num, trade.datetime, trade.sec_code, trade.price, trade.qty, trade.value, trade.flags)		
	-- Automat = 1	
end

