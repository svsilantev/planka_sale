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
signalCounter_Connected = 0 -- ������� �������� ��� ����������� ���������� � �����������.
lastLogTime = os.time() -- ��� ����� ��� � ������
-- ������ .ps ����� ��� ������ ��� �������� ����������������� ����
os.execute('start cmd /k powershell -NoExit -ExecutionPolicy Bypass -File "D:\\YandexDisk\\DropBox\\����������\\��������\\������\\������\\�������\\run_script.ps1" -logFilePath "' .. Path_time_log_txt .. '"')






function OnInit()	

	MyAssetID = AllocTable()	
	AddColumn (MyAssetID, 1, "�����", true, QTABLE_STRING_TYPE,8)
	AddColumn (MyAssetID, 2, "�����", true, QTABLE_STRING_TYPE,8)
	AddColumn (MyAssetID, 3, "������", true, QTABLE_STRING_TYPE,9)
	AddColumn (MyAssetID, 4, "����� <", true, QTABLE_STRING_TYPE,12)	 
	AddColumn (MyAssetID, 5, "������� �", true, QTABLE_STRING_TYPE,12)
	AddColumn (MyAssetID, 6, "�������", true, QTABLE_STRING_TYPE,12)
	AddColumn (MyAssetID, 7, "� �������", true, QTABLE_STRING_TYPE,12)	 
	AddColumn (MyAssetID, 8, "�� ������", true, QTABLE_STRING_TYPE,12)
	AddColumn (MyAssetID, 9, "����� (��)", true, QTABLE_STRING_TYPE,13)
	AddColumn (MyAssetID, 10, "My V5", true, QTABLE_STRING_TYPE,10)
	AddColumn (MyAssetID, 11, "v1", true, QTABLE_STRING_TYPE,6)
	AddColumn (MyAssetID, 12, "v5", true, QTABLE_STRING_TYPE,6)
	AddColumn (MyAssetID, 13, "v60", true, QTABLE_STRING_TYPE,6)
	AddColumn (MyAssetID, 14, "v300", true, QTABLE_STRING_TYPE,6)	
	AddColumn (MyAssetID, 15, "", true, QTABLE_STRING_TYPE,10)
	AddColumn (MyAssetID, 16, "���������", true, QTABLE_STRING_TYPE,15)	 
	AddColumn (MyAssetID, 17, "", true, QTABLE_STRING_TYPE,10)
	AddColumn (MyAssetID, 18, "", true, QTABLE_STRING_TYPE,1)
	
	AddColumn (MyAssetID, 19, "min", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 20, "-20", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 21, "-15", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 22, "-12", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 23, "-10", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 24, "-7%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 25, "-5%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 26, "-3%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 27, "-2%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 28, "-1%", true, QTABLE_STRING_TYPE,5)
	
	AddColumn (MyAssetID, 29, "+1%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 30, "+2%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 31, "+3%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 32, "+5%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 33, "+7%", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 34, "+10", true, QTABLE_STRING_TYPE,5)	
	AddColumn (MyAssetID, 35, "+12", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 36, "+15", true, QTABLE_STRING_TYPE,5)
	AddColumn (MyAssetID, 37, "+20", true, QTABLE_STRING_TYPE,5)	
	AddColumn (MyAssetID, 38, "max", true, QTABLE_STRING_TYPE,5)
	
	AddColumn (MyAssetID, 39, "������", true, QTABLE_STRING_TYPE,12)	
	AddColumn (MyAssetID, 40, "�������", true, QTABLE_STRING_TYPE,12)	
	 
	CreateWindow(MyAssetID)	
	SetWindowPos(MyAssetID,981,0,1550,310)										-- ����� �������. ������ �����*������ ������*������*������ �������
	SetWindowCaption(MyAssetID, "��� �����")


	-- ���������� ���������� ������ ������������	
	KomCentrID = AllocTable()													-- ������� � ��������� � ���������� ���������� ������. 
	AddColumn (KomCentrID, 1, "��������/��������", true, QTABLE_STRING_TYPE,31)	-- ��������
	AddColumn (KomCentrID, 2, "���������", true, QTABLE_STRING_TYPE,15)			-- �������� ���������
	CreateWindow(KomCentrID)
	SetWindowPos(KomCentrID,691,0,290,310)										-- ����� �������. ������ �����*������ ������*������*������ �������
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
	DestroyTable(Lotov_Podryad_ID)
	DestroyTable(StockID)	
	is_run = false											--��������� �����	
end

function OnTrade(trade)	
	-- Automat = 0		
	-- message("������!!! ����������: ".. tostring(trade.sec_code)..". ����:  ".. tostring(trade.price)..". ���������� � ������: ".. tostring(trade.order_qty)..". ����������: ".. tostring(trade.qty))
	-- setPrice(trade.trade_num, trade.datetime, trade.sec_code, trade.price, trade.qty, trade.value, trade.flags)		
	-- Automat = 1	
end

