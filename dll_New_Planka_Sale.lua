function Body()
    sleep(1000)
	tickers_updated = {}
	
    while isConnected() ~= 1 do
        signalCounter_Connected = signalCounter_Connected+1		
        message(TegBrocker..": ��� ���������� � ��������")
		if signalCounter_Connected ==1 then 
			local check_sound = GetCell(KomCentrID, 10, 2).image
			if check_sound == "��������" then
				local pathSound = getScriptPath().."\\song\\net-soedineniya-ili-abonent-nedostupen-24915.wav" -- ����, ���� ������� ���������� � ��������.
				SendMessage(TegBrocker, " ��� ���������� � ��������", pathSound)
			else
				SendMessage(TegBrocker, " ��� ���������� � ��������")
			end
		end 	
		sleep(5000)
    end
	signalCounter_Connected = 0

    if WriteTable == 1 then  -- �������������� ���������� ������
		ClearLogFile() -- ������� ����� ��������� �����
        ImportSaleLevelExcel() -- �������� ����� � ������ �� ����� ������
        WriteTable = 0
    end

	if os.time() - lastLogTime >= 60 then
		local logMessage = "��������� �������� ���������."
		WriteLog(logMessage)  -- ������ ���� ������� �� ��������� ���.
		lastLogTime = os.time()  -- ���������� ������� ���������� �����������
	end
	
    MyAssetStock()
    
    TableNotificationCallback()  -- ��������� ������� ���� �� �������.
end


--**********************************************************************
--�������������� ���������� �������
function MyAssetStock()	
    local nRow, nCol = GetTableSize(MyAssetID)
    if nRow ~= nil then	
        for i = 1, nRow do	
            -- �������� � ���������� ��� ������, ������� ���������� �������� ���������� �� ������� ����� (trading_status - ���������/�� ���������)
            local ticker = tostring(GetCell(MyAssetID, i, 1).image) -- �����
            local class = tostring(GetCell(MyAssetID, i, 2).image) -- �����
            local step = tonumber(getParamEx(class, ticker, "SEC_PRICE_STEP").param_value) -- ����������� ��� ����
            local lotsize = math.ceil(getParamEx(class, ticker, "LOTSIZE").param_value) -- ����� � ����
            local vol_today = tonumber(getParamEx(class, ticker, "VOLTODAY").param_value) or 0 -- �������������� �� ���� �����
			local vol_today_lots = vol_today/lotsize -- �������������� ����� � �����
            local my_lots = MyLots(ticker, lotsize, i) -- �������� ���������� ��������� ����� �� �����
            local plankaMax = tonumber(getParamEx(class, ticker, "PRICEMAX").param_value)  -- ���� ������ ������ (�� ��������� �� nil, ��� ��� �� ����� ������, ���� �������� �� ���������� ������)
			local plankaMin = tonumber(getParamEx(class, ticker, "PRICEMIN").param_value)  -- ���� ������ ������ (�� ��������� �� nil, ��� ��� �� ����� ������, ���� �������� �� ���������� ������). ��� ������� �� �����
            local totalLotsSell, totalLotsBuy = CollectAndSortOrders(class, ticker) -- �������� ���������� ����� � ������� �� �������
            local min_vol_bid = tonumber(GetCell(MyAssetID, i, 4).image) or 0 -- ������� �������� ����� ����� �� ������� ������, ���� �������� ����� ���������. ���� �� ������, �� 0.
            local quantityForSale = tonumber(GetCell(MyAssetID, i, 5).image) or my_lots -- ������� �������� ����� �����, ������� ����� �������. ���� �� ������, �� ������� ���, ��� ����.
            -- ���������� ���������� ������ � �������
            SetCell(MyAssetID, i, 3, tostring(plankaMax)) -- ���� ������    
            SetCell(MyAssetID, i, 6, tostring(my_lots)) -- ��� ����
            SetCell(MyAssetID, i, 7, tostring(totalLotsBuy)) -- ������ �� �������.
            
            local trading_status = tonumber(getParamEx(class, ticker, "TRADINGSTATUS").param_value)
			
            if trading_status>0 and i ~= nil then
				SetColor(MyAssetID,i, 1,RGB(0, 255, 0),RGB(0,0,0),RGB(0, 255, 0),RGB(0,0,0))
				
				local v1, v2, v5, v30, v60, v300 = GetVolume(ticker, vol_today_lots, i) -- �������� ������ � ����� �� ��������� 1,2,5,30,60,300 ������
				-- ���������� ���������� ����� �� ������� ������.
				local bid = tonumber(getParamEx(class, ticker, "BID").param_value) or 0 --���� ������� ����
				if bid == plankaMax then
					local bidDEPTH = tonumber(getParamEx(class, ticker, "BIDDEPTH").param_value) or 0 -- ����� �� ������ BID (����� � �����)
					SetCell(MyAssetID, i, 8, tostring(bidDEPTH))
				else
					SetCell(MyAssetID, i, 8, "0")
				end						
				
				-- ���������� ���������� ������ � �������
				SetCell(MyAssetID, i, 11, tostring(v1))-- ������ �� 1,2,5,30,60,300 ������
				--SetCell(MyAssetID, i, 13, tostring(v2))
				SetCell(MyAssetID, i, 12, tostring(v5))
				--SetCell(MyAssetID, i, 15, tostring(v30))
				SetCell(MyAssetID, i, 13, tostring(v60))
				SetCell(MyAssetID, i, 14, tostring(v300))
				SetCell(MyAssetID, i, 9, tostring(vol_today_lots))
				
				local check_sound = GetCell(KomCentrID, 10, 2).image -- ���� ��������� ��������� �������������

				-- �������� ������� ������. ���� ������ ��������� ���������� �����
				--==================================
				local combat_mode = tonumber(GetCell(MyAssetID, i, 16).image) or 0 -- �������� ���� ������� ������ (���������)				
				
				local signal_1 = 0
				local lot_for_planka = tonumber(GetCell(MyAssetID, i, 8).image) or 0 -- �������� ���������� ����� �� ������

				if lot_for_planka < tonumber(min_vol_bid) then
					signal_1 = 1
					message("�������� signal_1  = "..signal_1)
					signalCounter1 = signalCounter1 + 1  -- ����������� ������� �� 1
					message("signalCounter1 = "..signalCounter1)
					if signalCounter1 ==1 then -- ������ �������� 1 ���
						if check_sound =="��������" then
							local pathSound = getScriptPath().."\\song\\kosmicheskiy-signal-svyazi.wav" -- ���� ��� ������� �������. (�������� ������������ ������ �� ������.)
							SendMessage(ticker, " ������:  �������� ���� ������ �� ������. ������!!!", pathSound)
						else
							SendMessage(ticker, " ������:  �������� ���� ������ �� ������. ������!!!")
						end 
						if combat_mode >0 then
							SetColor(MyAssetID, i, 4, RGB(0, 0, 128), RGB(255, 255, 255), RGB(0, 0, 128), RGB(255, 255, 255))
						else
							SetColor(MyAssetID, i, 4, RGB(0, 255, 255), RGB(0, 0, 0), RGB(0, 255, 255), RGB(0, 0, 0))
						end
					end
				else
					signal_1 = 0 -- ����� ��� �����������
					signalCounter1 = 0 -- �������� �������, ���� ������ �� ��������
					SetColor(MyAssetID, i, 4, RGB(255, 255, 255), RGB(0, 0, 0), RGB(255, 255, 255), RGB(0, 0, 0)) -- �������� ���������.
				end 
				
				-- �������� ������������� �������
				local signal_2 = 0
				vol_5_min = tonumber(GetCell(MyAssetID, i, 10).image) or 0 -- ������� �������� � ������� ������� ������. ���� �� 5 ��� �������� ������ ���� �����, ���������� ������.
				if vol_5_min == 0 then
					message("�� ����� 5 �������� ����� � ������� '����� 5 ���' ��� ����� ".. ticker)
				end 	
				
				if v300 > vol_5_min and v5 > 0 then 
					signal_2 = 1
					message("�������� signal_2  = "..signal_2)
					signalCounter2 = signalCounter2 + 1 -- ����������� ������� �� 1
					if signalCounter2 ==1 then -- ������ �������� 1 ���
						if check_sound =="��������" then
							local pathSound = getScriptPath().."\\song\\korotkiy-zvonkiy-zvuk-uvedomleniya.wav" -- ���� ��� ������� ������� (����� �� 5 ���.)
							SendMessage(ticker, " ������:  �������� ���� ������ �� ������. ������!!!", pathSound)
						else
							SendMessage(ticker, " ������:  �������� ���� ������ �� ������. ������!!!")
						end 
						if combat_mode >0 then
							SetColor(MyAssetID, i, 25, RGB(0, 0, 128), RGB(255, 255, 255), RGB(0, 0, 128), RGB(255, 255, 255))
							SetColor(MyAssetID, i, 28, RGB(0, 0, 128), RGB(255, 255, 255), RGB(0, 0, 128), RGB(255, 255, 255))					
						else
							SetColor(MyAssetID, i, 25, RGB(0, 255, 255), RGB(0, 0, 0), RGB(0, 255, 255), RGB(0, 0, 0))
							SetColor(MyAssetID, i, 28, RGB(0, 255, 255), RGB(0, 0, 0), RGB(0, 255, 255), RGB(0, 0, 0))
						end
					end	
				else 
					signal_2 = 0 -- ����� ��� �����������
					signalCounter2 = 0 -- �������� �������, ���� ������ �� ��������
					SetColor(MyAssetID, i, 25, RGB(255, 255, 255), RGB(0, 0, 0), RGB(255, 255, 255), RGB(0, 0, 0))
					SetColor(MyAssetID, i, 28, RGB(255, 255, 255), RGB(0, 0, 0), RGB(255, 255, 255), RGB(0, 0, 0))

				end 
				
				-- ========== �������!!! ====================================
				local price_for_sell = plankaMax*0.985 -(plankaMax*0.985)%step	-- ���� � ���������������� 1.5% �� ������� ������.

				

				-- ����������� ���� ������� ��� ������� � �������� ������ "���������" (������ �����). ����� ������������ ������������ ������ ����� ������������� � ��������.
				if signal_1 > 0 and signal_2 > 0 then						
					
					--//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\				
									--quantityForSale = 1 -- ��� ������. �� ������ �����.
					--//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\				
										
					if combat_mode >0 then
					
						NewOrder("S", ticker, class, tonumber(quantityForSale), price_for_sell, "115") -- �������					
							
						if Avtomat_buy == 1 then -- ���������� ����������, ���� 1 - ����� ������� ��������������� ������ �� ������� ����. ����� �������� ����.
						
							price_buy = plankaMax*0.85-(plankaMax*0.85)%step
							
							NewOrder("B", ticker, class, tonumber(quantityForSale), price_buy, "315") -- �������
							
						end 	
						combat_mode = 0
						SetCell(MyAssetID, i, 16, tostring(combat_mode))
						SetColor(MyAssetID,i,15,RGB(204, 112, 0),RGB(0,0,0),RGB(204, 112, 0),RGB(0,0,0))
						SetColor(MyAssetID,i,16,RGB(255, 200, 0),RGB(0,0,0),RGB(255, 200, 0),RGB(0,0,0))						
						SetColor(MyAssetID,i,17,RGB(204, 112, 0),RGB(0,0,0),RGB(204, 112, 0),RGB(0,0,0))
						message("������ ����������. ������ ����� �������� (���������)")
					 
					 
						local pathSound = getScriptPath().."\\song\\zvuk-pobedyi-vyiigryisha.wav" -- ���� ����� ������������ ���� ��������
						if check_sound =="��������" then
							SendMessage(ticker, "�������! �������!!! ������!!!", pathSound)
						else
							SendMessage(ticker, "�������! �������!!! ������!!!")
						end 
					end	
					--is_run = false				
				end 				

			else
				--message("�� ����� "..ticker.." ����� �� ����. ������ : "..tostring(trading_status))
				SetColor(MyAssetID,i, 1,RGB(255, 0, 0),RGB(255,255,255),RGB(255, 0, 0),RGB(255,255,255))
			end 
		end
	end	
end


function init_buffers(ticker)
    buffers_by_ticker[ticker] = {
        buffers = {
            ['1s'] = {},
            ['2s'] = {},
            ['5s'] = {},
            ['30s'] = {},
            ['60s'] = {},
            ['300s'] = {}
        },
        max_lengths = {
            ['1s'] = 1,
            ['2s'] = 2,
            ['5s'] = 5,
            ['30s'] = 30,
            ['60s'] = 60,
            ['300s'] = 300
        },
        previous_vol_today = nil
    }
end

function update_buffers(ticker, volume)
    local ticker_data = buffers_by_ticker[ticker]
    for interval, buffer in pairs(ticker_data.buffers) do
        table.insert(buffer, volume)        
        -- ���������, �� �������� �� ������������ ������ ������
        if #buffer > ticker_data.max_lengths[interval] then
            table.remove(buffer, 1) -- ������� ����� ������ �������
        end
    end
end

function get_sums(ticker)
    local ticker_data = buffers_by_ticker[ticker]
    local sums = {}
    for interval, buffer in pairs(ticker_data.buffers) do
        local sum = 0
        for i = 1, #buffer do
            sum = sum + buffer[i]
        end
        sums[interval] = sum
    end
    return sums
end

function GetVolume(ticker, vol_today_lots, i)
    -- ��������, ��� ��� ������� ������ ���� ������ � tickers_updated
    if tickers_updated[ticker] == nil then
        tickers_updated[ticker] = false
    end
	
	local v1, v2, v5, v30, v60, v300 = 0, 0, 0, 0, 0, 0  -- ������������� ����������
    
	if tickers_updated[ticker] == false then
        -- �������������� ������ ��� ������, ���� ��� ��� �� ����������������
        if buffers_by_ticker[ticker] == nil then
            init_buffers(ticker)
        end
        local ticker_data = buffers_by_ticker[ticker]
        -- ��������� volume ������ ���� ���� ���������� �������� vol_today_lots
        if ticker_data.previous_vol_today ~= nil then
            local volume = vol_today_lots - ticker_data.previous_vol_today
            -- ��������� ������ � ����� volume
            update_buffers(ticker, volume)
            tickers_updated[ticker] = true  -- ��������, ��� ����� ��� �������
            -- �������� ����� �� ���������� �������
            local sums = get_sums(ticker)
			v1, v2, v5, v30, v60, v300 = sums['1s'], sums['2s'], sums['5s'], sums['30s'], sums['60s'], sums['300s']
        end
        -- ��������� previous_vol_today ������ ����� ����, ��� ������ ���������
        ticker_data.previous_vol_today = vol_today_lots
    end
    -- ���������� ������ �� 1, 2, 5, 30, 60 � 300 ������
    return v1, v2, v5, v30, v60, v300
end

function MyLots(ticker,lotsize,i)

	local my_lots = 0
	local n = getNumberOf("depo_limits")	
	local order = {}
	for j = 0, n - 1 do
		order = getItem("depo_limits", j)        
		local secCode = order["sec_code"]		
		local kol = tonumber(order["currentbal"])        
		local t1 = order["limit_kind"] -- ���� ��������				
		if t1 == 1 and secCode == ticker then		
			my_lots = kol / lotsize	
			break
		end
	end		
	return my_lots
end 

-- �������� �������� ������ �� ������������� ������ � ����������� � ��������� �� ������
function CollectAndSortOrders(classCode, secCode)
	local collectedOrders = {} -- ������ ��� ����� ������
	local numberOfOrders = getNumberOf("orders") -- �������� ����� ���������� ������
	local totalLotsBuy = 0 -- ���������� ��� �������� ������ ���������� ����� �� �������
	local totalLotsSell = 0 -- ���������� ��� �������� ������ ���������� ����� �� �������

	for i = 0, numberOfOrders - 1 do
		 local order = getItem("orders", i) -- �������� ������ �� �������
		 if order.class_code == classCode and order.sec_code == secCode then
			 if bit.band(order.flags, 0x4) ~= 0 and bit.band(order.flags, 0x1) ~= 0  then -- �������� �� �������
				totalLotsSell = totalLotsSell + order.qty -- ����������� ����� ���������� �����
			 elseif bit.band(order.flags, 0x4) == 0 and bit.band(order.flags, 0x1) ~= 0  then -- �������� �� �������
				totalLotsBuy = totalLotsBuy + order.qty -- ����������� ����� ���������� �����
			 else
				 --message("������ ������������")
			 end
		 end
	end

	return totalLotsSell, totalLotsBuy
end

 --**********************************************************************
-- ��������� ������� �� Excel  �����
function ImportSaleLevelExcel()
	local col = 1
	local pat = "(.*)"
	local file, err = io.open(SaleLevelExport,"r")
	
	if err ~= nil then 
		PrintDbgStr("err read file: "..err); 
		return; 
	end
	str = file:read()
	
	if str ==nil then
		str = ""
	end 
	
	for var in string.gmatch (str, ";") do col=col+1 end -- ��������� ���������� �������
	for i = 2, col do pat = pat..";(.*)" end -- ��������� ������ "pat" ���� (.*);(.*);(.*);(.*);(.*);(.*) � ����������� ��������� ������ ����� �������
	
	local i = 0
	for line in io.lines(SaleLevelExport) do   --������������ ��� ������ � �����. line  - �������� ������ ������ �� ���� ��������
		line  = line:gsub("|","")
		local _,_,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12,s13,s14,s15,s16,s17,s18,s19,s20 = string.find(line,pat) -- ��������� ������ �� ����������. � ������ ����������� �������� ������ �� ����� �� ������ ���������� �������

		if i~=0 then -- ���������� ��������
			InsertRow(MyAssetID,i)
			SetCell(MyAssetID, i, 1,  s1)			
			SetCell(MyAssetID, i, 2,  s2)
			SetColor(MyAssetID,i, 2,RGB(173, 216, 230),RGB(0,0,0),RGB(173, 216, 230),RGB(0,0,0))
			SetCell(MyAssetID, i, 4,  s3)	
			SetColor(MyAssetID,i, 4,RGB(255, 255, 153),RGB(0,0,0),RGB(255, 255, 153),RGB(0,0,0))
			SetCell(MyAssetID, i, 5,  s4)
			SetColor(MyAssetID,i, 5,RGB(255, 255, 153),RGB(0,0,0),RGB(255, 255, 153),RGB(0,0,0))
			SetCell(MyAssetID, i, 10,  s5)	
			SetColor(MyAssetID,i, 10,RGB(255, 255, 153),RGB(0,0,0),RGB(255, 255, 153),RGB(0,0,0))	

			SetColor(MyAssetID,i,15,RGB(204, 112, 0),RGB(0,0,0),RGB(204, 112, 0),RGB(0,0,0))
			SetColor(MyAssetID,i,16,RGB(255, 200, 0),RGB(0,0,0),RGB(255, 200, 0),RGB(0,0,0))						
			SetColor(MyAssetID,i,17,RGB(204, 112, 0),RGB(0,0,0),RGB(204, 112, 0),RGB(0,0,0))
			
			SetColor(MyAssetID,i,18,RGB(255, 255, 255),RGB(0,0,0),RGB(255, 255, 255),RGB(0,0,0))
			
			SetColor(MyAssetID,i,19,RGB(220, 255, 220),RGB(0,0,0),RGB(220, 255, 220),RGB(0,0,0))	
			SetColor(MyAssetID,i,20,RGB(198, 255, 198),RGB(0,0,0),RGB(198, 255, 198),RGB(0,0,0))	
			SetColor(MyAssetID,i,21,RGB(176, 255, 176),RGB(0,0,0),RGB(176, 255, 176),RGB(0,0,0))	
			SetColor(MyAssetID,i,22,RGB(154, 255, 154),RGB(0,0,0),RGB(154, 255, 154),RGB(0,0,0))
			SetColor(MyAssetID,i,23,RGB(132, 255, 132),RGB(0,0,0),RGB(132, 255, 132),RGB(0,0,0))
			SetColor(MyAssetID,i,24,RGB(110, 255, 110),RGB(0,0,0),RGB(110, 255, 110),RGB(0,0,0))	
			SetColor(MyAssetID,i,25,RGB(88, 255, 88),RGB(0,0,0),RGB(88, 255, 88),RGB(0,0,0))	
			SetColor(MyAssetID,i,26,RGB(66, 255, 66),RGB(0,0,0),RGB(66, 255, 66),RGB(0,0,0))
			SetColor(MyAssetID,i,27,RGB(44, 255, 44),RGB(0,0,0),RGB(44, 255, 44),RGB(0,0,0))
			SetColor(MyAssetID,i,28,RGB(22, 255, 22),RGB(0,0,0),RGB(22, 255, 22),RGB(0,0,0))
			
			SetColor(MyAssetID,i,29,RGB(255, 22, 22),RGB(0,0,0),RGB(255, 22, 22),RGB(0,0,0))			
			SetColor(MyAssetID,i,30,RGB(255, 44, 44),RGB(0,0,0),RGB(255, 44, 44),RGB(0,0,0))			
			SetColor(MyAssetID,i,31,RGB(255, 66, 66),RGB(0,0,0),RGB(255, 66, 66),RGB(0,0,0))			
			SetColor(MyAssetID,i,32,RGB(255, 88, 88),RGB(0,0,0),RGB(255, 88, 88),RGB(0,0,0))			
			SetColor(MyAssetID,i,33,RGB(255, 110, 110),RGB(0,0,0),RGB(255, 110, 110),RGB(0,0,0))			
			SetColor(MyAssetID,i,34,RGB(255, 132, 132),RGB(0,0,0),RGB(255, 132, 132),RGB(0,0,0))			
			SetColor(MyAssetID,i,35,RGB(255, 154, 154),RGB(0,0,0),RGB(255, 154, 154),RGB(0,0,0))			
			SetColor(MyAssetID,i,36,RGB(255, 176, 176),RGB(0,0,0),RGB(255, 176, 176),RGB(0,0,0))			
			SetColor(MyAssetID,i,37,RGB(255, 198, 198),RGB(0,0,0),RGB(255, 198, 198),RGB(0,0,0))	
			SetColor(MyAssetID,i,38,RGB(255, 220, 220),RGB(0,0,0),RGB(255, 220, 220),RGB(0,0,0))	
			
			SetColor(MyAssetID,i,39,RGB(0, 255, 0),RGB(0,0,0),RGB(0, 255, 0),RGB(0,0,0))			
			SetColor(MyAssetID,i,40,RGB(220, 20, 60),RGB(0,0,0),RGB(220, 20, 60),RGB(0,0,0))
			
		end
		i = i+1
	end
	file:close()
end

--**********************************************************************
--�������� ������� �� ������� � Excel  ����
function ExportSaleLevelExcel()

	local fileCSV1
	local fileCSV2
	fileCSV1 = io.open(SaleLevelExport, "w" )
	
	if IdUser == "3325" then --�����
		fileCSV2 = io.open(getScriptPath().."\\Export\\Alpha\\backup\\"..tostring(os.time()).."_SL.csv", "w" )
	elseif IdUser == "392295" then 	--����
		fileCSV2 = io.open(getScriptPath().."\\Export\\Sber\\backup\\"..tostring(os.time()).."_SL.csv", "w" )
	elseif IdUser == "147526" then 	-- ���
		fileCSV2 = io.open(getScriptPath().."\\Export\\VTB\\backup\\"..tostring(os.time()).."_SL.csv", "w" )
	else
		message("��� �������� �� ��������� ��� �������: ExportTickerExcel()")
	end 		
	
	local nRow,nCol = GetTableSize(MyAssetID)
	if (nRow~=nil)then	
		for i = 1, nRow,1 do
			local ticker 			= tostring(GetCell(MyAssetID, i, 1).image)
			local class 			= tostring(GetCell(MyAssetID, i, 2).image)
			local min_vol_bid 		= tostring(GetCell(MyAssetID, i, 4).image)
			local quantityForSale 	= tostring(GetCell(MyAssetID, i, 5).image)
			local vol_lotovPodryad 		= tostring(GetCell(MyAssetID, i, 10).image)

			if i == 1 then
				fileCSV1:write("�����"..";".."�����"..";".."|".."��� ������� ������ � ����� �� �����".."|"..";".."|".."������� ����� � �����".."|"..";".."|".."����� ������".."|".."\n")
				fileCSV2:write("�����"..";".."�����"..";".."|".."��� ������� ������ � ����� �� �����".."|"..";".."|".."������� ����� � �����".."|"..";".."|".."����� ������".."|".."\n")
			end 

			fileCSV1:write(ticker..";"..class..";".."|"..min_vol_bid.."|"..";".."|"..quantityForSale.."|"..";".."|"..vol_lotovPodryad.."|".."\n")
			fileCSV2:write(ticker..";"..class..";".."|"..min_vol_bid.."|"..";".."|"..quantityForSale.."|"..";".."|"..vol_lotovPodryad.."|".."\n")
		end
	end	
	message("Export ������� ��������. ��������� "..tostring(nRow).." ������������" )
	fileCSV1:close()
	fileCSV2:close()

	--message( "UpdateOK = ".. tostring(UpdateOK).. ", WriteTable "..tostring(WriteTable)..", isConnected  = ".. tostring(isConnected())..", is_run = "..tostring(is_run)..", ���� = "..test)
end 	

function SendMessage(secCode, signal, soundPath)
    local msg = "!!!������� ������ �� �����: " .. secCode .. ": " .. signal
    local command

    -- ���� ������ ���� � ��������� �����, ��������� ��� � �������
    if soundPath and soundPath ~= "" then
        command = 'powershell -ExecutionPolicy Bypass -File "'..SEND_TELEGRAM_EXE_PATH..'" -message "'..msg..'" -soundPath "'..soundPath..'"'
    else
        command = 'powershell -ExecutionPolicy Bypass -File "'..SEND_TELEGRAM_EXE_PATH..'" -message "'..msg..'"'
    end

    os.execute(command) -- ���������� ������� ��� �������� �����������
end


--============== ���������� ������ =========================
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
--=============================================================

--������ ���������  �����, ������ ������. ��� ��������� ������ �������� �, ���� ��� ������� � ������� 2 �����, ���������� ��������� � ��������
function WriteLog(message)
    local file = io.open(Path_time_log_txt, "a")  -- ��������� ���� ��� ������ (����� "a" - ��������)
    if file then
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S")  -- �������� ������� ���� � �����
        file:write(timeStamp .. " - " .. message .. "\n")  -- ���������� ��������� � ����
        file:close()  -- ��������� ����
    else
        message("�� ������� ������� ���� ��� ������ ����.")
    end
end

--������� ��������� ����� ��� ������ ����.
function ClearLogFile()
    local file = io.open(Path_time_log_txt, "w")  -- ��������� ���� � ������ ������ (����� "w" - ����������)
    if file then
        file:write("")  -- ����� ������ ������, ����� �������� ����
        file:close()  -- ��������� ����
        message("���-���� ������.")
    else
        message("�� ������� ������� ���� ��� ������� ����.")
    end
end


--�� ������������
function KillOrders(secCode, class, orderKey)

	local res=1
	for i = 0,getNumberOf("orders") - 1 do
		if tostring(getItem("orders",i).order_num) == orderKey then
			if Test == 1 then
				message("�������� ����� ������ ������")	 
			elseif Test == 0 then 
				local transaction={
					  ["TRANS_ID"]=tostring(math.ceil(1000*os.clock())),
					  ["ACTION"]="KILL_ORDER",
					  ["CLASSCODE"]=tostring(class),
					  ["SECCODE"]=secCode,
					  ["ORDER_KEY"]=orderKey
					}
				local res=sendTransaction(transaction) 
				message(tostring(res))
				message("����� ������ "..orderKey.." �� ����������� "..ShortName(secCode) )
			end	 
		end
	end		
   return res 
end





--====	������� ��� ��������� ������� �� ��������. ���� ������ ���
	
function TableNotificationCallback()
 local f_kc = function(KomCentrID,  msg,  par1, par2)				--	��������� �����
	 if (msg==QTABLE_LBUTTONDBLCLK)then
		 ProcessingTableKC(par1, par2)
	 end
 end
 SetTableNotificationCallback(KomCentrID, f_kc)

 local f_akc3 = function(StockID,  msg,  par1, par2)				--	������� ��� ������ �����	
	 if (msg==QTABLE_LBUTTONDBLCLK)then
		 ProcessingTableAKC(par1, par2)
	 end
 end
 SetTableNotificationCallback(StockID, f_akc3)
 
  local f_ast = function(MyAssetID,  msg,  par1, par2)				--	������� ��� ������ �����	
	 if (msg==QTABLE_LBUTTONDBLCLK)then
		 ProcessingTableAsset(par1, par2)
	 end
 end
 SetTableNotificationCallback(MyAssetID, f_ast)
 
 
 -- ������ ������� ��� ������������� ��������
local f_pm = function(PlankaMinusID,  msg,  par1, par2)				--������� ��� ��������� ������ �����		
	if (msg==QTABLE_LBUTTONDBLCLK)then								--��� ����������� �� �������
		ProcessingTablePlankaMinus(par1, par2)							--��������� �������
	end		
end	
SetTableNotificationCallback(PlankaMinusID, f_pm)							--������ ������� ��������� ������ 
 
local f_mlfs = function(My_lot_for_saleID,  msg,  par1, par2)				--������� ��� ��������� ������ �����		
	if (msg==QTABLE_LBUTTONDBLCLK)then								--��� ����������� �� �������
		ProcessingTable_My_lot_for_saleID(par1, par2)							--��������� �������
	end		
end	
SetTableNotificationCallback(My_lot_for_saleID, f_mlfs)							--������ ������� ��������� ������  


local f_lp = function(Lotov_Podryad_ID,  msg,  par1, par2)				--������� ��� ��������� ������ �����		
	if (msg==QTABLE_LBUTTONDBLCLK)then								--��� ����������� �� �������
		ProcessingTable_Lotov_Podryad_ID(par1, par2)							--��������� �������
	end		
end	
SetTableNotificationCallback(Lotov_Podryad_ID, f_lp)							--������ ������� ��������� ������ 

end	


function ProcessingTableAsset(line, column)	-- ��������� �����
	local command = GetCell(MyAssetID, line, column).image
	local ticker = tostring(GetCell(MyAssetID, line, 1).image)
    local class = tostring(GetCell(MyAssetID, line, 2).image)
	local step = tonumber(getParamEx(class,ticker,"SEC_PRICE_STEP").param_value) -- ���  ����
	local plankaMax = tonumber(getParamEx(class, ticker, "PRICEMAX").param_value)  -- ����������� ��������� ����
	local plankaMin = tonumber(getParamEx(class, ticker, "PRICEMIN").param_value)  -- ���������� ��������� ����
	
	local offer = tonumber(getParamEx(class, ticker, "OFFER").param_value) 
	if offer == 0 then  --���� ��� �������, ��� ������������ ���������� ������������ ���� (������� ����������� ������ �� �������!!!)
		offer = plankaMax 
		message ("������� ���. ������ ������ ����� ������������ ������")
	end
	
	local bid = tonumber(getParamEx(class, ticker, "BID").param_value) 
	if bid == 0 then   --���� ��� �����, ��� ������������ ���������� ����������� ���� (������� ����������� ������ �� �����!!!)
		bid = plankaMin 
		message ("����� ���. ���� ������ ����� ����������� ������")
	end

	local bidDEPTH = tonumber(getParamEx(class, ticker, "BIDDEPTH").param_value) -- ���������� ����� �� ������ BID
	local my_lot = tonumber(GetCell(MyAssetID, line, 6).image) or 0
	local my_lot_for_sale = tonumber(GetCell(MyAssetID, line, 5).image) or 0
	local vol_5_min = tonumber(GetCell(MyAssetID, line, 10).image) or 0

	
	if column == 2 then
		DeleteRow(MyAssetID, line)

	elseif column == 4 then
		DestroyTable(PlankaMinusID)
		PlankaMinusID = AllocTable()														-- ������������� �������, � ����� �������� ���������	
		AddColumn (PlankaMinusID, 1, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (PlankaMinusID, 2, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (PlankaMinusID, 3, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (PlankaMinusID, 4, "������� ������", true, QTABLE_STRING_TYPE,20)
		AddColumn (PlankaMinusID, 5, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (PlankaMinusID, 6, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (PlankaMinusID, 7, "", true, QTABLE_STRING_TYPE,10)		
		CreateWindow(PlankaMinusID)
		SetWindowPos(PlankaMinusID,1000,300,500,150)											-- ����� �������. ������ �����*������ ������*������*������ �������
		SetWindowCaption(PlankaMinusID, "������� ������ �� ������")										-- �������� �������		
		if plankaMin == 0 then 
			plankaMin = math.ceil(bidDEPTH/5)
		end 			
		InsertRow(PlankaMinusID, 1)
		SetCell(PlankaMinusID,1,4,ticker) 	
		InsertRow(PlankaMinusID, 2)
		SetCell(PlankaMinusID,2,4,ticker) 
		InsertRow(PlankaMinusID, 3)
		SetCell(PlankaMinusID,3,4,tostring(line)) 
		SetCell(PlankaMinusID,3,5,tostring(step)) 
		InsertRow(PlankaMinusID, 4)
		SetCell(PlankaMinusID,4,1,"�100") 
		SetCell(PlankaMinusID,4,2,"�10") 
		SetCell(PlankaMinusID,4,3,"�1") 
		SetCell(PlankaMinusID,4,4,tostring(plankaMin)) 
		SetCell(PlankaMinusID,4,5,"+1")
		SetCell(PlankaMinusID,4,6,"+10") 
		SetCell(PlankaMinusID,4,7,"+100") 
		InsertRow(PlankaMinusID, 5)	
		SetCell(PlankaMinusID,5,1, "-100%" )		
		SetCell(PlankaMinusID,5,2, "-10%" )
		SetCell(PlankaMinusID,5,3,"-1%")
		SetCell(PlankaMinusID,5,4,"1/5 ������")
		SetCell(PlankaMinusID,5,5,"+1%")
		SetCell(PlankaMinusID,5,6,"+10%")
		SetCell(PlankaMinusID,5,7,"+100%")	
		SetColor(PlankaMinusID,4,1,RGB(0,140,240),QTABLE_DEFAULT_COLOR,RGB(0,140,240),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,4,2,RGB(87,185,255),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,4,3,RGB(87,185,255),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,4,4,RGB(251,206,177),QTABLE_DEFAULT_COLOR,RGB(251,206,177),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,4,5,RGB(245,154,227),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,4,6,RGB(245,154,227),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,4,7,RGB(240,108,213),QTABLE_DEFAULT_COLOR,RGB(240,108,213),QTABLE_DEFAULT_COLOR)	
		SetColor(PlankaMinusID,5,1,RGB(0,140,230),QTABLE_DEFAULT_COLOR,RGB(0,140,240),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,5,2,RGB(87,185,245),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,5,3,RGB(87,185,245),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,5,4,RGB(251,206,167),QTABLE_DEFAULT_COLOR,RGB(251,206,177),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,5,5,RGB(245,154,217),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,5,6,RGB(245,154,217),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(PlankaMinusID,5,7,RGB(240,108,203),QTABLE_DEFAULT_COLOR,RGB(240,108,213),QTABLE_DEFAULT_COLOR)

	elseif column == 5 then
		DestroyTable(My_lot_for_saleID)
		My_lot_for_saleID = AllocTable()														-- ������������� �������, � ����� �������� ���������	
		AddColumn (My_lot_for_saleID, 1, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (My_lot_for_saleID, 2, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (My_lot_for_saleID, 3, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (My_lot_for_saleID, 4, "������� �����", true, QTABLE_STRING_TYPE,20)
		AddColumn (My_lot_for_saleID, 5, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (My_lot_for_saleID, 6, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (My_lot_for_saleID, 7, "", true, QTABLE_STRING_TYPE,10)		
		CreateWindow(My_lot_for_saleID)
		SetWindowPos(My_lot_for_saleID,1100,300,500,150)											-- ����� �������. ������ �����*������ ������*������*������ �������
		SetWindowCaption(My_lot_for_saleID, "������� �����")										-- �������� �������		
		if my_lot_for_sale == 0 then 
			my_lot_for_sale = math.ceil(my_lot/2)
		end 			
		InsertRow(My_lot_for_saleID, 1)
		SetCell(My_lot_for_saleID,1,4,ticker) 	
		InsertRow(My_lot_for_saleID, 2)
		SetCell(My_lot_for_saleID,2,4,ticker) 
		InsertRow(My_lot_for_saleID, 3)
		SetCell(My_lot_for_saleID,3,4,tostring(line)) 
		SetCell(My_lot_for_saleID,3,5,tostring(step)) 
		InsertRow(My_lot_for_saleID, 4)
		SetCell(My_lot_for_saleID,4,1,"�100") 
		SetCell(My_lot_for_saleID,4,2,"�10") 
		SetCell(My_lot_for_saleID,4,3,"�1") 
		SetCell(My_lot_for_saleID,4,4,tostring(my_lot_for_sale)) 
		SetCell(My_lot_for_saleID,4,5,"+1")
		SetCell(My_lot_for_saleID,4,6,"+10") 
		SetCell(My_lot_for_saleID,4,7,"+100") 
		InsertRow(My_lot_for_saleID, 5)	
		SetCell(My_lot_for_saleID,5,1, "-100%" )		
		SetCell(My_lot_for_saleID,5,2, "-10%" )
		SetCell(My_lot_for_saleID,5,3,"-1%")
		SetCell(My_lot_for_saleID,5,4,"���")
		SetCell(My_lot_for_saleID,5,5,"+1%")
		SetCell(My_lot_for_saleID,5,6,"+10%")
		SetCell(My_lot_for_saleID,5,7,"+100%")	
		SetColor(My_lot_for_saleID,4,1,RGB(0,140,240),QTABLE_DEFAULT_COLOR,RGB(0,140,240),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,4,2,RGB(87,185,255),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,4,3,RGB(87,185,255),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,4,4,RGB(251,206,177),QTABLE_DEFAULT_COLOR,RGB(251,206,177),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,4,5,RGB(245,154,227),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,4,6,RGB(245,154,227),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,4,7,RGB(240,108,213),QTABLE_DEFAULT_COLOR,RGB(240,108,213),QTABLE_DEFAULT_COLOR)	
		SetColor(My_lot_for_saleID,5,1,RGB(0,140,230),QTABLE_DEFAULT_COLOR,RGB(0,140,240),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,5,2,RGB(87,185,245),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,5,3,RGB(87,185,245),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,5,4,RGB(251,206,167),QTABLE_DEFAULT_COLOR,RGB(251,206,177),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,5,5,RGB(245,154,217),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,5,6,RGB(245,154,217),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(My_lot_for_saleID,5,7,RGB(240,108,203),QTABLE_DEFAULT_COLOR,RGB(240,108,213),QTABLE_DEFAULT_COLOR)

	elseif column == 10 then
		DestroyTable(Lotov_Podryad_ID)
		Lotov_Podryad_ID = AllocTable()														-- ������������� �������, � ����� �������� ���������	
		AddColumn (Lotov_Podryad_ID, 1, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (Lotov_Podryad_ID, 2, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (Lotov_Podryad_ID, 3, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (Lotov_Podryad_ID, 4, "����� � ���� �������", true, QTABLE_STRING_TYPE,20)
		AddColumn (Lotov_Podryad_ID, 5, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (Lotov_Podryad_ID, 6, "", true, QTABLE_STRING_TYPE,10)
		AddColumn (Lotov_Podryad_ID, 7, "", true, QTABLE_STRING_TYPE,10)		
		CreateWindow(Lotov_Podryad_ID)
		SetWindowPos(Lotov_Podryad_ID,1200,300,500,150)											-- ����� �������. ������ �����*������ ������*������*������ �������
		SetWindowCaption(Lotov_Podryad_ID, "����� � ���� �������")										-- �������� �������				
		InsertRow(Lotov_Podryad_ID, 1)
		SetCell(Lotov_Podryad_ID,1,4,ticker) 	
		InsertRow(Lotov_Podryad_ID, 2)
		SetCell(Lotov_Podryad_ID,2,4,ticker) 
		InsertRow(Lotov_Podryad_ID, 3)
		SetCell(Lotov_Podryad_ID,3,4,tostring(line)) 
		SetCell(Lotov_Podryad_ID,3,5,tostring(step)) 
		InsertRow(Lotov_Podryad_ID, 4)
		SetCell(Lotov_Podryad_ID,4,1,"�100") 
		SetCell(Lotov_Podryad_ID,4,2,"�10") 
		SetCell(Lotov_Podryad_ID,4,3,"�1") 
		SetCell(Lotov_Podryad_ID,4,4,tostring(vol_5_min)) 
		SetCell(Lotov_Podryad_ID,4,5,"+1")
		SetCell(Lotov_Podryad_ID,4,6,"+10") 
		SetCell(Lotov_Podryad_ID,4,7,"+100") 
		InsertRow(Lotov_Podryad_ID, 5)	
		SetCell(Lotov_Podryad_ID,5,1, "-100%" )		
		SetCell(Lotov_Podryad_ID,5,2, "-10%" )
		SetCell(Lotov_Podryad_ID,5,3,"-1%")
		SetCell(Lotov_Podryad_ID,5,4,"---")
		SetCell(Lotov_Podryad_ID,5,5,"+1%")
		SetCell(Lotov_Podryad_ID,5,6,"+10%")
		SetCell(Lotov_Podryad_ID,5,7,"+100%")	
		SetColor(Lotov_Podryad_ID,4,1,RGB(0,140,240),QTABLE_DEFAULT_COLOR,RGB(0,140,240),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,4,2,RGB(87,185,255),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,4,3,RGB(87,185,255),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,4,4,RGB(251,206,177),QTABLE_DEFAULT_COLOR,RGB(251,206,177),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,4,5,RGB(245,154,227),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,4,6,RGB(245,154,227),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,4,7,RGB(240,108,213),QTABLE_DEFAULT_COLOR,RGB(240,108,213),QTABLE_DEFAULT_COLOR)	
		SetColor(Lotov_Podryad_ID,5,1,RGB(0,140,230),QTABLE_DEFAULT_COLOR,RGB(0,140,240),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,5,2,RGB(87,185,245),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,5,3,RGB(87,185,245),QTABLE_DEFAULT_COLOR,RGB(87,185,255),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,5,4,RGB(251,206,167),QTABLE_DEFAULT_COLOR,RGB(251,206,177),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,5,5,RGB(245,154,217),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,5,6,RGB(245,154,217),QTABLE_DEFAULT_COLOR,RGB(245,154,227),QTABLE_DEFAULT_COLOR)
		SetColor(Lotov_Podryad_ID,5,7,RGB(240,108,203),QTABLE_DEFAULT_COLOR,RGB(240,108,213),QTABLE_DEFAULT_COLOR)			
		
	elseif column == 16 then
		local combat_mode = GetCell(MyAssetID, line, 16).image
		if combat_mode == nil or combat_mode == "" or combat_mode == "0" then 
			combat_mode = 1
			SetColor(MyAssetID,line,15,RGB(0, 128, 0),RGB(0,0,0),RGB(0, 128, 0),RGB(0,0,0))
			SetColor(MyAssetID,line,16,RGB(0, 178, 0),RGB(255,255,255),RGB(0, 178, 0),RGB(255,255,255))
			SetColor(MyAssetID,line,17,RGB(0, 128, 0),RGB(0,0,0),RGB(0, 128, 0),RGB(0,0,0))
		else
			combat_mode = 0
			SetColor(MyAssetID,line,15,RGB(204, 112, 0),RGB(0,0,0),RGB(204, 112, 0),RGB(0,0,0))
			SetColor(MyAssetID,line,16,RGB(255, 200, 0),RGB(0,0,0),RGB(255, 200, 0),RGB(0,0,0))						
			SetColor(MyAssetID,line,17,RGB(204, 112, 0),RGB(0,0,0),RGB(204, 112, 0),RGB(0,0,0))
		end 	
		SetCell(MyAssetID, line, 16, tostring(combat_mode)) -- ������ �����. "���������"
		
	elseif column == 19 then  -- "min"
		NewOrder("B", ticker,class,my_lot_for_sale,plankaMin,"310")					
	elseif column == 20 then  -- "-20%"
		local price = bid*0.8-(bid*0.8)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 21 then  -- "-15%"
		local price = bid*0.85-(bid*0.85)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 22 then  -- "-12%"
		local price = bid*0.88-(bid*0.88)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 23 then  -- "-10%"
		local price = bid*0.9-(bid*0.9)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")		
	elseif column == 24 then  -- "-7%"
		local price = bid*0.93-(bid*0.93)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 25 then  -- "-5%"
		local price = bid*0.95-(bid*0.95)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 26 then  -- "-3%"
		local price = bid*0.97-(bid*0.97)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 27 then  -- "-2%"
		local price = bid*0.98-(bid*0.98)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 28 then  -- "-1%"
		local price = bid*0.99-(bid*0.99)%step
		NewOrder("B", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 29 then  -- "+1%"
		local price = offer*1.01-(offer*1.01)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")			
	elseif column == 30 then  -- "+2%"
		local price = offer*1.02-(offer*1.02)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 31 then  -- "+3%"
		local price = offer*1.03-(offer*1.03)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 32 then  -- "+5%"
		local price = offer*1.05-(offer*1.05)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 33 then  -- "+7%"
		local price = offer*1.07-(offer*1.07)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")			
	elseif column == 34 then  -- "+10%"
		local price = offer*1.10-(offer*1.10)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")	
	elseif column == 35 then  -- "+12%"
		local price = offer*1.12-(offer*1.12)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")			
	elseif column == 36 then  -- "+15%"
		local price = offer*1.15-(offer*1.15)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")			
	elseif column == 37 then  -- "+20%"
		local price = offer*1.2-(offer*1.2)%step
		NewOrder("S", ticker, class, my_lot_for_sale, price, "310")			
	elseif column == 38 then  -- "+max"
		NewOrder("S", ticker, class, my_lot_for_sale, plankaMax, "310")			

	elseif column == 39 then  -- "0%" "������" �� �����
		NewOrder("B", ticker, class, my_lot_for_sale, plankaMax, "310")
	elseif column == 40 then -- "�������!!! �� �����"
		NewOrder("S", ticker, class, my_lot_for_sale, plankaMin, "310")	
	end

end


function ProcessingTableKC(par1, par2)	-- ��������� �����
	local command = GetCell(KomCentrID, par1, par2).image

	if command == "�������� �����" then
		ProcessingTableStock(par1, 2) 
	elseif command == "���������" then
		ExportSaleLevelExcel()
	elseif command =="������� ���� Excel" then 
		io.popen("start " ..SaleLevelExport) 		
	elseif 	command =="������� ������� ������" then 
		os.execute("start " ..getScriptPath())	
	elseif command =="�������� ����������" then
		Clear(MyAssetID)
		WriteTable=1	
	elseif command =="�������� ������������" then
		local check_sound = GetCell(KomCentrID, par1, 2).image
		if check_sound == "��������" then		
			SetCell(KomCentrID,par1, 2, "���������")
			SetColor(KomCentrID,par1,QTABLE_NO_INDEX,RGB(255, 102, 102),RGB(255,255,255),RGB(255, 102, 102),RGB(255,255,255))
		else
			SetCell(KomCentrID,par1, 2, "��������")
			SetColor(KomCentrID,par1,QTABLE_NO_INDEX,RGB(100, 150, 100),RGB(255,255,255),RGB(110, 160, 110),RGB(255,255,255))
		end		
	elseif command =="�������" then 
		local filepath = getScriptPath().."\\readmy.txt"
		local f=io.open(filepath,"r")
		if f~=nil then 
			io.close(f) 
			io.popen("start " ..filepath) 
		else 
			local file = assert(io.open(filepath, 'w'))
			file:write(emit.." ("..isin..").")
			file:close()
			io.popen("start  " ..filepath) 
		end	
	elseif command =="������ -15% (�������)" then	
		if Avtomat_buy ==0 then
			Avtomat_buy = 1
			SetCell(KomCentrID,12, 2, tostring(Avtomat_buy))
		else
			Avtomat_buy = 0
			SetCell(KomCentrID,12, 2, tostring(Avtomat_buy))
		end	
	end
	

end

function ProcessingTableAKC(par1, par2)	-- ������������ �������� � �������� ������ �����.
	 if par2 == 1 then
		 local secCode  =  GetCell(StockID, par1, 1).image
		 local class  =  GetCell(StockID, par1, 2).image		 
		 InsertRow(MyAssetID, 1)
		 SetCell(MyAssetID, 1, 1, secCode)
		 SetCell(MyAssetID, 1, 2, class)
	 end
end

 
-- ������� ��� ������ �����
function ProcessingTableStock(line, column)
	 DestroyTable(StockID)
	 StockID = AllocTable()														-- ������������� �������, � ����� �������� ���������	
	 AddColumn (StockID, 1, "SecCode", true, QTABLE_STRING_TYPE,10)
	 AddColumn (StockID, 2, "Class", true, QTABLE_STRING_TYPE,10)
	 AddColumn (StockID, 3, "isin_code", true, QTABLE_STRING_TYPE,20)
	 AddColumn (StockID, 4, "short_name", true, QTABLE_STRING_TYPE,20)
	 AddColumn (StockID, 5, "name", true, QTABLE_STRING_TYPE,50)
	 AddColumn (StockID, 6, "list_level", true, QTABLE_STRING_TYPE,5)
	 CreateWindow(StockID)
	 SetWindowPos(StockID,1000,300,650,500)										-- ����� �������. ������ �����*������ ������*������*������ �������
	 SetWindowCaption(StockID, "����� �����������")								-- �������� �������		

	 --local csvLines = {} -- ������ ����� ��� CSV �����

	 for cls in string.gmatch("TQBR,TQPI,TQTF,MTQR,TQTF_F", "[^,]+") do
		 SecList = getClassSecurities(cls)
		 for SecCode in string.gmatch(SecList, "([^,]+)") do	
			 local securityInfo = getSecurityInfo(cls, SecCode)
			 local isin_code, short_name, name, list_level = "���������� �� ���������� ������ � ������ �� �������"			
			 if securityInfo then				 
				  isin_code = securityInfo.isin_code
				  short_name = securityInfo.short_name
				  name = securityInfo.name
				  list_level = securityInfo.list_level
			 end
			 InsertRow(StockID,1)	
			 SetCell(StockID,1, 1, tostring(SecCode))
			 SetCell(StockID,1, 2, tostring(cls))
			 SetCell(StockID,1, 3, tostring(isin_code))
			 SetCell(StockID,1, 4, tostring(short_name))
			 SetCell(StockID,1, 5, tostring(name))
			 SetCell(StockID,1, 6, tostring(list_level))

			 -- ��������� ������ � ������ ����� ��� CSV
			 -- table.insert(csvLines, string.format('%s,%s,%s,%s,%s,%s', SecCode, cls, isin_code, short_name, name, list_level))
		 end
		 InsertRow(StockID,1)
		 SetCell(StockID,1, 1, tostring(line))
		 SetCell(StockID,1, 2, tostring(column))
	 end 

end


 function ProcessingTablePlankaMinus(par1, par2)				-- ������������� ������ �����
	local planka = tonumber(GetCell(PlankaMinusID,4,4).image)
	message(tostring(planka))
	local stroka = GetCell(PlankaMinusID,3,4).image
	local vol = GetCell(MyAssetID,tonumber(stroka),8).image
	if vol==nil or vol =="" then vol = 0 end
	vol = tonumber(vol)

	if GetCell(PlankaMinusID, par1, par2).image =="�100" then 
		planka = math.ceil(planka-100)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="�10" then 
		planka = math.ceil(planka-10)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="�1" then 
		planka = math.ceil(planka-1)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="+1" then 
		planka = math.ceil(planka+1)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="+10" then 
		planka = math.ceil(planka+10)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="+100" then 
		planka = math.ceil(planka+100)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="-100%" then 
		planka = 0
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="-10%" then 
		planka = math.ceil(planka*0.9)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="-1%" then 
		planka = math.ceil(planka*0.99)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="1/5 ������" then 
		planka = math.ceil(vol/5)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="+1%" then 
		planka = math.ceil(planka*1.01)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="+10%" then 
		planka = math.ceil(planka*1.1)
	elseif 	GetCell(PlankaMinusID, par1, par2).image =="+100%" then 
		planka = math.ceil(planka*2)
	end 

	if planka < 0 then
		planka = 0
	end 	
	
	SetCell(PlankaMinusID, 4, 4, tostring(planka))
	SetCell(MyAssetID, tonumber(stroka), 4, tostring(planka))
end


 function ProcessingTable_My_lot_for_saleID(par1, par2)				-- ������������� ����� �� �������
	local lot = tonumber(GetCell(My_lot_for_saleID,4,4).image)
	message(tostring(lot))
	local stroka = GetCell(My_lot_for_saleID,3,4).image
	local vol = GetCell(MyAssetID,tonumber(stroka),6).image
	if vol==nil or vol =="" then vol = 0 end
	vol = tonumber(vol)
	-- local step = tonumber(GetCell(MyAssetID, tonumber(stroka), 27).image)
	-- local ask = tonumber(GetCell(MyAssetID, tonumber(stroka), 9).image)
	
	if GetCell(My_lot_for_saleID, par1, par2).image =="�100" then 
		lot = math.ceil(lot-100)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="�10" then 
		lot = math.ceil(lot-10)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="�1" then 
		lot = math.ceil(lot-1)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="+1" then 
		lot = math.ceil(lot+1)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="+10" then 
		lot = math.ceil(lot+10)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="+100" then 
		lot = math.ceil(lot+100)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="-100%" then 
		lot = 0
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="-10%" then 
		lot = math.ceil(lot*0.9)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="-1%" then 
		lot = math.ceil(lot*0.99)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="���" then 
		lot = math.ceil(vol)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="+1%" then 
		lot = math.ceil(lot*1.01)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="+10%" then 
		lot = math.ceil(lot*1.1)
	elseif 	GetCell(My_lot_for_saleID, par1, par2).image =="+100%" then 
		lot = math.ceil(lot*2)
	end 

	if lot < 0 then
		lot = 0
	end 	
	
	SetCell(My_lot_for_saleID, 4, 4, tostring(lot))
	SetCell(MyAssetID, tonumber(stroka), 5, tostring(lot))
end

 function ProcessingTable_Lotov_Podryad_ID(par1, par2)				-- ������������� ����� �� �������
	local lot = tonumber(GetCell(Lotov_Podryad_ID,4,4).image)
	local stroka = GetCell(Lotov_Podryad_ID,3,4).image

	
	if GetCell(Lotov_Podryad_ID, par1, par2).image =="�100" then 
		lot = math.ceil(lot-100)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="�10" then 
		lot = math.ceil(lot-10)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="�1" then 
		lot = math.ceil(lot-1)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="+1" then 
		lot = math.ceil(lot+1)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="+10" then 
		lot = math.ceil(lot+10)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="+100" then 
		lot = math.ceil(lot+100)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="-100%" then 
		lot = 0
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="-10%" then 
		lot = math.ceil(lot*0.9)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="-1%" then 
		lot = math.ceil(lot*0.99)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="---" then 
		--lot = math.ceil(vol)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="+1%" then 
		lot = math.ceil(lot*1.01)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="+10%" then 
		lot = math.ceil(lot*1.1)
	elseif 	GetCell(Lotov_Podryad_ID, par1, par2).image =="+100%" then 
		lot = math.ceil(lot*2)
	end 

	if lot < 0 then
		lot = 0
	end 	
	
	SetCell(Lotov_Podryad_ID, 4, 4, tostring(lot))
	SetCell(MyAssetID, tonumber(stroka), 10, tostring(lot))
end