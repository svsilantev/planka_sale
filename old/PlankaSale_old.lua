---@diagnostic disable: undefined-global, lowercase-global, trailing-space

-- Задача робота, максимально быстро выставить заявку на продажу по рынку
-- а) При уменьшении объема на планке
-- б) 
-- Настройку сделаем через текстовый файл. в него вносим тикер и количестов лотов на планке, при достижении которых выставляется заявка на продажу по цене на 10% ниже планки (по рынку). 
-- Идея в том, что когда начнутся распродажи, мы успеем выскочить в числе первых.

-- Реализация:
-- При запуске скрипта открывается текстовый файл, куда нужно внести тикер и объем на планке в лотах.
-- при закрытии 

-- Флаг для контроля выполнения основного цикла скрипта

is_run = true

IdUser = getInfoParam("USERID")
Client_code  = getItem("money_limits",1).client_code							-- Номер счета. Сбер "4L06E", Альфа "213288/000", ВТБ "10K2SQ"

if IdUser == "392295" then -- Сбер
	Firma = "MC0002500000"														-- Фирма по фондовому рынку
	MyAccount = "L01-00000F00"													-- Торговый счет
	TegBrocker = "Сбер"
	Teg = "UCAF" -- код позиции
elseif IdUser == "3325" then -- Альфа
	Firma = "MC0000500000"
	MyAccount = "L01-00000F00"
	TegBrocker = "Альфа"
	Teg = "EQTV" -- код позиции
elseif IdUser == "147526" then -- ВТБ
	Firma = "MC0003300000"
	MyAccount = "L01-00000F00"
	TegBrocker = "ВТБ"
	Teg = "EQTV" -- код позиции
else
	message("При старте программы не определен USERID")
end

--===============ЗАПОЛНИТЬ РУКАМИ ====================
Stock_For_Sale = "AMEZ" -- инструмент, который продаем
Class_For_Sale = "TQBR" -- класс
Vol_For_Sale = 10000 --лотов. если объем на планке меньше этого, продавать.
--====================================================
Kol_For_Sale = 0 -- Количество лотов для ордера. Если ноль, тогда продать все (по умолчанию). Если больше нуля, продать то, что установлено.
--====================================================

PlankaMax = tonumber(getParamEx(Class_For_Sale, Stock_For_Sale, "PRICEMAX").param_value) -- Максимально возможная цена
Lot = math.ceil(getParamEx(Class_For_Sale,Stock_For_Sale,"LOTSIZE").param_value)
BidDEPTH = tonumber(getParamEx(Class_For_Sale, Stock_For_Sale, "BIDDEPTH").param_value) -- Количество лотов на лучшем BID
Bid = tonumber(getParamEx(Class_For_Sale, Stock_For_Sale, "BID").param_value) -- лучший BID.

Price_For_Sale = PlankaMax -- Цена для ордера. По сути "по рынку"

local n = getNumberOf("depo_limits")	
local order={}
for i=0,n-1 do
    order = getItem("depo_limits", i)        
    local secCode = order["sec_code"]		
    local kol = tonumber(order["currentbal"])        
    local t1 = order["limit_kind"] -- срок расчетов
    if t1 == 1 and secCode == Stock_For_Sale then
        StockAmount  = kol/Lot
    end
end 

if Kol_For_Sale == 0 then 
    Kol_For_Sale = StockAmount  
end

message("===============================")
message("Акция : "..Stock_For_Sale.." ("..Class_For_Sale..")")
message("Максимальная цена (планка): "..tostring(PlankaMax))
message("Текущий объем на лучшем BID: "..tostring(BidDEPTH))
message("Продадим при уменьшении объема до: "..tostring(Vol_For_Sale).." лотов")
message("Продадим: "..tostring(Kol_For_Sale).." лотов")
message("Имеется: "..tostring(StockAmount).." лотов")
message("По цене: "..tostring(Price_For_Sale))
message("===============================")

--Stock_For_Sale.." : "..Class_For_Sale.." : "..Vol_For_Sale.." : "..Kol_For_Sale.." : ")

function Body() 
    sleep(1)
    if is_run then
        BidDEPTH = tonumber(getParamEx(Class_For_Sale, Stock_For_Sale, "BIDDEPTH").param_value) -- Количество лотов на лучшем BID
        if Bid == PlankaMax then
            if BidDEPTH <= Vol_For_Sale then
                message("Продавай!!!  Объем - "..tostring(BidDEPTH))            
                NewOrder("S", Stock_For_Sale, Class_For_Sale, tonumber(Kol_For_Sale), Price_For_Sale, "115")           
                is_run = false
            end
        else
            message("Работаем только на планке, однако текущая цена ниже. Цена на планке = "..tostring(PlankaMax).." А текущая цена  = ".. tostring(BidDEPTH))
            is_run = false
        end
    end 
end

-- Выставляем заявки.

function NewOrder(operation, emit,class,qty,price,tr_id) -- Выставляем заявки
    if tonumber(qty)>0 then
        --если в акциях шаг без дробной части, тогда вернет ошибку при виде цены 100.0. Поэтому:
        local price_num = tonumber(price)
        if price_num~=nil then
            local a, b = math.modf(price_num)   -- вернёт целую часть в переменную 'a' и дробную в переменную 'b'
            if b==0 then
                price = tostring(a)
            end
        else
            print("Ошибка: невозможно преобразовать price в число")
        end
        message("operation".." : "..operation.." , ".."emit".." : "..emit.." , ".."class".." : "..class.." , ".." qty".." : "..qty.." , ".." price".." : "..price.." , ".." tr_id".." : "..tr_id)
        local transaction={															--заполняем необходимые для лимтной заявки поля
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
        local res = sendTransaction(transaction)								--если ок, то пустая строка//если не ок что-то, то строка с диагностикой ошибки будет
    end
    return 1																--транзакцию отправили
end

-- Основная функция, выполняющаяся в отдельном потоке
function main()
    while is_run do -- Пока скрипт активен
        Body() -- Вызов основной логики скрипта
    end
end

-- Функция, вызываемая при остановке скрипта пользователем
function OnStop()
    is_run = false -- Сигнал остановки основного цикла
end
