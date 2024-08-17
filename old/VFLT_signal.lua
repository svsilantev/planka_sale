is_run = true

-- ���� � ������������ ����� ��� �������, ������� ���������� ��������� � Telegram.
SEND_TELEGRAM_EXE_PATH = 'message.ps1'

ChangeVFLT = math.ceil(getParamEx("MTQR","VFLT","VOLTODAY").param_value)
ChangeVFLTP = math.ceil(getParamEx("MTQR","VFLTP","VOLTODAY").param_value)

function Body() 
    sleep(1000)
    if is_run then
		local changeVFLT = math.ceil(getParamEx("MTQR","VFLT","VOLTODAY").param_value)
		local changeVFLTP = math.ceil(getParamEx("MTQR","VFLTP","VOLTODAY").param_value)
		local bidVFLT = math.ceil(getParamEx("MTQR","VFLT","BID").param_value)
		local bidVFLTP = math.ceil(getParamEx("MTQR","VFLTP","BID").param_value)
		local offerVFLT = math.ceil(getParamEx("MTQR","VFLT","OFFER").param_value)
		local offerVFLTP = math.ceil(getParamEx("MTQR","VFLTP","OFFER").param_value)

		if changeVFLT > ChangeVFLT then
			local kol = changeVFLT-ChangeVFLT
			if kol > 5 then 
				send_messages("VFLT", kol, changeVFLT, bidVFLT, offerVFLT)
			end 	
			ChangeVFLT = changeVFLT
		end 
		
		if changeVFLTP > ChangeVFLTP then
			local kol = changeVFLTP-ChangeVFLTP
			if kol > 5 then
				send_messages("VFLTP", kol, changeVFLTP, bidVFLTP, offerVFLTP)
			end 	
			ChangeVFLTP = changeVFLTP
		end 
	end
end  	

function send_messages(stock, kol, vol, bid, offer)
	local msg = stock.." ".. tostring(kol).."  �����: "..tostring(vol) .."  ���: "..tostring(bid) .."  �����: "..tostring(offer) 
    local command = 'powershell -ExecutionPolicy Bypass -File "'..SEND_TELEGRAM_EXE_PATH..'" "'..msg..'"'
	os.execute(command) -- ���������� ������� ��� �������� �����������
end

-- �������� �������, ������������� � ��������� ������
function main()
    while is_run do -- ���� ������ �������
        Body() -- ����� �������� ������ �������
    end
end

	
function OnStop()
    is_run = false -- ������ ��������� ��������� �����
end