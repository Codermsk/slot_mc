local component, kb = require("component"), require("keyboard")
--me = component.proxy(component.me_controller.address)
me = component.proxy(component.me_interface.address)
local inet = component.internet
local comp = require("computer")

local chat_id = "-1001911045227"
local token = "6632287578:AAEGDtWm_HdzuTiubdfVASbYZABoLEP28yo"
local send = "sendMessage"
local upd = "getUpdates"
local url = "https://api.telegram.org/bot" .. token .. "/"

function request(url,body, headers, timeout) --функция http запросов
  handle, err = inet.request(url, body, headers, 'POST') --  отправляем запрос. Сразу обрабатываем ошибку.
  if not handle then
    return nil, ("request failed: %s"):format(err or "unknown error")
  end
  start = comp.uptime() -- запрос доходит до сервера не мгновенно. Нужно подождать. Чтобы не зависнуть слишком долго, мы засекаем время начала.
  while true do
    status, err = handle.finishConnect() -- вызываем finishConnect, чтобы узнать статус подключения.
    if status then -- finishConnect вернул true. Значит, соединение установлено. Уходим из цикла.
      break
    end    
    if status == nil then -- finishConnect вернул nil. Мы специально проверяем через status == nil, потому что не нужно путать его с false. nil — это ошибка. Поэтому оформляем его как ошибку.
      return nil, ("request failed: %s"):format(err or "unknown error")
    end
    if comp.uptime() >= start + timeout then -- проверяем, висим ли в цикле мы слишком долго. Если да, то тоже возвращаем ошибку. Не забываем закрыть за собой соединение.
      handle.close()
      return nil, "request failed: connection timed out"
    end
    os.sleep(1) -- нам не нужен бизи-луп. Спим.
  end
  return handle -- мы не читаем сразу всё в память, чтобы экономить память. Вместо этого отдаём наружу handle.
end
function val(reso,par,st,sp) -- достает из строки ответа значение указанного параметра
	if string.find(reso,par) ~= nil then
		i,j = string.find(reso,par)
		r = ''
		f=j+st
		while string.char(string.byte(reso,f))~=sp do
			r=r.. string.char(string.byte(reso,f))
			f=f+1
		end
		return r 
	else
		return ''
	end
end
--------------------------------------------------------------------------
function ae2items() -- фунция опроса мэ на хранящиеся предметы
	local items = false
	while items == false do
		os.sleep(2)
		items = me.getItemsInNetwork()
	end
	return items -- возращает огромную таблицу доступных предметов
end
function ae2crafts() -- функция опроса мэ на доступные крафты. 
	local crafts = false	-- нет смысла хранить такой кусок данных в памяти
	while crafts == false do--который еще и долго обрабатывает функция поиска
		os.sleep(2)
		crafts = me.getCraftables()
	end
	return crafts -- возращает нереально огромную таблицу доступных крафтов
end
function itemInME(label,itemTable) -- поиск предмета в таблице предметов
	for i=1, itemTable.n do
		if itemTable[i].label == label then --работает быстро
			return itemTable[i]
		end
	end
end
function craftInME(itLabel) -- поиск крафта указанного предмета в 
  crafts = false	
	while crafts == false do
		os.sleep(2)
		crafts = me.getCraftables({label = itlabel}) -- так даже быстрее, чем если шарить 
	end			
	return crafts
end
function gCpus()
	local cpus = me.getCpus()
	local ret = ''
	for i=1, cpus.n do
		ret = ret..'CPU:'..i.. '\tname = '.. cpus[i].name
		if cpus[i].busy then
			ret = ret..'  Состояние: Занят\n'
		else
			ret = ret..'  Состояние: Холост\n'
		end
	end
	return ret
end
function requestCraft(itemlabel, count)
	craftIt = false	
	while craftIt == false do
		os.sleep(2)
		craftIt = me.getCraftables({label = itemlabel}) -- так даже быстрее, чем если шарить 
	end
	if craftIt.n >= 1 then								
		craft=craftIt[1]-- избавляемся от лишних {}		
		if tonumber(count)~= nil then
			local valu = tonumber(count)
			currentItem = craft.request(tonumber(valu)) -- постановка на крафт и присвоение крафттаблици предмету
			return 'крафт '..count..'шт '..itemlabel..' был успешно запущен'
		else
			return 'введено не правильное количество, ввэды цэлоэ чысло'
		end
	else
		return 'крафт невозможен, вероятно указан неверный label или отсутсвует шаблон крафта \nВвод осуществляется через запятую без пробелов возле запятых\nПример: /craft,Lithium Dust,1000'
	end
end
-------------------------------------------
function getEnergyStatus()
	local rf = component.flux_controller.getEnergyInfo()
	return math.ceil(rf.energyInput/4) .. " eu/t\n"
end
function getStatus()
	Table = ae2items()
	fluids = false
	while fluids==false do
		fluids = me.getFluidsInNetwork()
		os.sleep(2)
	end
	i = 1
	data = "Статус:\n"
	data = data .. getEnergyStatus()

	while(i < #Table) do
		if (Table[i].name == "ic2:nuclear" and Table[i].damage == 3) then
			count = math.modf(Table[i].size)
			data = data .. "\nПлутоний " .. count
		end
		if (Table[i].name == "ic2:misc_resource" and Table[i].damage == 3) then
			count = math.modf(Table[i].size)
			data = data .. "\nМатерия " .. count
		end
		if (Table[i].name == "ic2stuff:pf_matter") then
			count = math.modf(Table[i].size)
			data = data .. "\nСовершенная материя " .. count
		end
		if (Table[i].name == "ic2:crafting" and Table[i].damage == 24) then
			count = math.modf(Table[i].size)
			data = data .. "\nКоробка утильсырья " .. count
		end
		if (Table[i].name == "contenttweaker:money" and Table[i].damage == 0) then
			count = math.modf(Table[i].size)
			data = data .. "\nЭмов " .. count
		end
		if (Table[i].name == "minecraft:lapis_block" and Table[i].damage == 0) then
			count = math.modf(Table[i].size)
			data = data .. "\nЛазурит блоков " .. count
		end
		i = i + 1
	end
	i = 1
	while i<= #fluids do
		if fluids[i].name == 'xenon_129' then
			count = math.ceil(fluids[i].amount/1000, 3)
			data = data .. "\nКсенона " .. count.. ' вёдер'
		end
		if fluids[i].label == 'Crushed Ice' then
			count = math.ceil(fluids[i].amount/1000, 3)
			data = data .. "\nМолотого льда " .. count.. ' вёдер'
		end
		i = i+1
	end
	return data
end
-------------------------------------------
function checkUpdates(bod) -- Проверка обновлений запросов от ботв
	local req = request(url..upd, bod, r_headers, 10) --print(req)
	if req ~= nil then
		res = req.read() --print(res)
		if res ~= nil then
			cres = string.gsub(res,'\"','')-- print(cres)
		else
			cres = '' --print(cres)
		end
	end
	if cres ~= '' then
		cres = string.gsub(res,'\"','')
		if cres == '{ok:true,result:[]}' then
			print('Нет запросов')
			return ''
		else
			local u_id = val(cres,'_id',2,',') --print(u_id)
			
			text = val(res,'text\":',2,'\"') print(text)
			from = val(cres,'{id',2,',') --print(from)
			from_user = val(cres,'username',2,',')
			if text =='/cpus' then
				print('Получен запрос о состоянии процессоров крафта от '..from_user)
				--insert function
				local raw_json_text = "chat_id=" .. from .. "&text=" .. 'Состояние процессоров крафта\n'..gCpus()-- выдача инфы о процах
				request(url..send, raw_json_text, r_headers, 10)				
			end
			if string.match(text,'/craft') == '/craft'  then
				local craft = val(cres,'craft',2,',')
				if craft == 'entities:[{offset:0' then
					local raw_json_text = "chat_id=" .. from .. "&text=" ..'Не указанно что и сколько крафтить\nВвод осуществляется через запятую без пробелов возле запятых\nПример: /craft,Lithium Dust,1000 '
					count='0'
					request(url..send, raw_json_text, r_headers, 10)
				else
					local count = val(cres,craft,2,',')
					if count == 'entities:[{offset:0' then
						count = '1'
						local raw_json_text = "chat_id=" .. from .. "&text=" .. 'Окей окей, раз не говоришь сколько нужно, попробуем тогда скрафтить 1 штуку'
						request(url..send, raw_json_text, r_headers, 10)
						print('Получен запрос на крафт '..count..' штук '.. craft..' от '..from_user)		
						local raw_json_text = "chat_id=" .. from .. "&text=" .. requestCraft(craft, count)
						request(url..send, raw_json_text, r_headers, 10)
					else
						print('Получен запрос на крафт '..count..' штук '.. craft..' от '..from_user)		
						local raw_json_text = "chat_id=" .. from .. "&text=" .. requestCraft(craft, count)
						request(url..send, raw_json_text, r_headers, 10)
					end
				end
			end
			if text == '/list' then
				print('Получен запрос на списко имен предметов от '..from_user)
				--insert function			
				local raw_json_text = "chat_id=" .. from .. "&text=" .. 'Список имён предметов\n https://pastebin.com/raw/f2bVGW2r'
				request(url..send, raw_json_text, r_headers, 10)
			end
			if text == '/status' then
				print('Получен запрос о статусе от '..from_user)
				local raw_json_text = "chat_id=" .. from .. '&text=Подожди пару минут, отчет готовится'
				request(url..send, raw_json_text, r_headers, 10)
				local raw_json_text = "chat_id=" .. from .. "&text=" .. getStatus()
				request(url..send, raw_json_text, r_headers, 10)
			end
			if text == '/energy' then
				print('Получен запрос о энергии от '..from_user)
				local raw_json_text = "chat_id=" .. from .. "&text=" .. getEnergyStatus()
				request(url..send, raw_json_text, r_headers, 10)
			end
			if text == '/start' then
				local info = 'ку, вот доступные команды:\n/status - формирует общий отчет в течении 2х минут\n/energy - выдаст текущий eu/t \n/cpus - выдает инфо о процессорах крафта\n/craft - команда вызова крафта.Ввод через запятую без пробелов возле запятых. Пример: /craft,Lithium Dust,1000.\n/list - выдает список корректных имен предметов для крафта\n/count временно не работает'
				local raw_json_text = "chat_id=" .. from .. "&text=" .. info
				request(url..send, raw_json_text, r_headers, 10)
			end
			os.sleep(1)
			return 'offset='..math.ceil(u_id+1)																	
		end
	else
		print('request Error')
	end
end
raw_request =''
while true do
	if kb.isKeyDown(kb.keys.w) and kb.isControlDown() then
		print("харэ")
		os.exit()
	end
	raw_request=checkUpdates(raw_request) 
    os.sleep(1)
    --term.clear()
end
