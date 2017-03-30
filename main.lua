--[[ *********************************************************
MAIN.lua
Programa principal. Coloque aqui o código.
********************************************************* --]]

print("MAIN: Programa principal iniciado.")

_MAX_TENTATIVAS_IP = 5

_pinna = {"pin1", "pin2", "pin3", "pin4", "pin5", "pin6", "pin7", "pin8", "pin9", "pin10", "pin11", "pin12", "pin13"}
_pinio = { 3    ,  10   ,  4    ,  9    ,  2    ,  1    ,  11   ,  12   ,  6    ,  7     ,  5     ,  8     ,  0 }
_pinst = { -1   ,  -1   ,  -1   ,  -1   ,  -1   ,  -1   ,  -1   ,  -1   ,  -1   ,  -1    ,  -1    ,  -1    ,  -1}

_server2 = nil

_funcao2 = 1
_tenta2 = 1
_timer2 = tmr.create()
_timer2:alarm(1000, tmr.ALARM_SEMI, function() start_webserver() end)

_hostname = "ESP" .. node.chipid()
print("MAIN: Definindo nome do dispositivo na rede como " .. _hostname .. ".")
wifi.sta.sethostname(_hostname)

function start_webserver()

	if (_funcao2 == 1) then
		print("MAIN: Detectando IP e intensidade do sinal. Aguarde.")
		local _ip = wifi.sta.getip()
		local _rssi = wifi.sta.getrssi()

		if (_ip ~= nil) then
			print("MAIN: Conectado no wifi com o ip " .. _ip .. " e intensidade do sinal " .. _rssi .. ".")
			_tenta2 = 1
			_funcao2 = _funcao2 + 1

		else
			print("MAIN: Falhou na " .. _tenta2 .. "a tentativa. Aguarde 1 segundo.")
			_tenta2 = _tenta2 + 1
			if (_tenta2 >= _MAX_TENTATIVAS_IP) then
				print("MAIN: Falhou demais, mas vamos continuar assim mesmo.")
				_tenta2 = 1
				_funcao2 = _funcao2 + 1

			end
		end
		_timer2:start()

    --[[
	elseif (_funcao2 == 2) then
		print("MAIN: Inicializando GPIO " .. _pin1 .. " e " .. _pin2 .. ".")
		gpio.mode(_pin1, gpio.OUTPUT)
		gpio.mode(_pin2, gpio.OUTPUT)
		_tenta2 = 1
		_funcao2 = _funcao2 + 1
		_timer2:start()
    --]]
	elseif (_funcao2 == 2) then
		print("MAIN: Webserver inicializado. É só usar agora.")

		if (_server2 == nil) then
			_server2 = net.createServer(net.TCP, 60)
		end

		_server2:listen(80, listen2)

		_timer2:unregister()
	end

end


function listen2(sck)
	sck:on("receive", receive2)
	sck:on("connection", connection2)
	--sck:on("disconnection", disconnection2)
end

function connection2(sck, req)
	local _port, _ip = sck:getpeer()
	if (_ip ~= nil) then
		print("MAIN: Cliente " .. _ip .. " conectado (+) no webserver pela porta " .. _port .. ".")
	end
end

function disconnection2(sck, req)
	local _port, _ip = sck:getpeer()
	if (_ip ~= nil) then
		print("MAIN: Cliente " .. _ip .. " desconectado (-) do webserver.")
	end
end

function receive2(sck, req)
	local _port, _ip = sck:getpeer()
	local _GET = {}
	if (_ip ~= nil) then
		print("MAIN: Cliente " .. _ip .. " enviando dados para o webserver.")
	end
	vars1, vars2 = get_http_req(req)
	for k, v in string.gmatch(vars1['REQUEST'], "(%w+)=(%w+)&*") do
		_GET[string.lower(k)] = string.lower(v)
	end
	for k1, v1 in pairs(_GET) do
		print("\t" .. k1 .. " = \'" .. v1 .. "\'")
	end

    for x1 = 1, 13 do
        k1 = _pinna[x1]
        if (_GET[k1] == "on") then
            if (_pinst[x1] == -1) then
                gpio.mode(_pinio[x1], gpio.OUTPUT)
            end
            gpio.write(_pinio[x1], gpio.HIGH)
            _pinst[x1] = 1
            print("\tLigou " .. k1 .. " - " .. _pinna[x1] .. " - " .. _pinio[x1] .. " - " .. _pinst[x1])
        elseif (_GET[k1] == "off") then
            if (_pinst[x1] == -1) then
                gpio.mode(_pinio[x1], gpio.OUTPUT)
            end
            gpio.write(_pinio[x1], gpio.LOW)
            _pinst[x1] = 0
            print("\tDesligou " .. k1 .. " - " .. _pinna[x1] .. " - " .. _pinio[x1] .. " - " .. _pinst[x1])
        end
    end
    

	local ht = {}
	table.insert(ht, "<html>")
	table.insert(ht, "<head>")
	table.insert(ht, "<title>" .. _hostname .. "</title>")
	table.insert(ht, "<meta charset=\"UTF-8\" />")
	table.insert(ht, "</head>")
	table.insert(ht, "<body>")

    for x1 = 1, 13 do
        k1 = _pinna[x1]
        table.insert(ht, "<p>" .. string.upper(k1) .. ": <a href=\"?" .. k1 .. "=on\"><button>ON</button></a> <a href=\"?" .. k1 .. "=off\"><button>OFF</button></a></p>")
    end
--	if (_pin1st == 1) then
--		table.insert(ht, "<p>PIN1: <a href=\"?pin1=off\"><button>OFF</button></a></p>")
--	elseif (_pin1st == 0) then
--		table.insert(ht, "<p>PIN1: <a href=\"?pin1=on\"><button>ON</button></a></p>")
--	end
--	if (_pin2st == 1) then
--		table.insert(ht, "<p>PIN2: <a href=\"?pin2=off\"><button>OFF</button></a></p>")
--	elseif (_pin2st == 0) then
--		table.insert(ht, "<p>PIN2: <a href=\"?pin2=on\"><button>ON</button></a></p>")
--	end
	table.insert(ht, "</body>")
	table.insert(ht, "</html>")

	local sht = 0
	for key, value in pairs(ht) do
		sht = sht + string.len(value) + 1
	end

	table.insert(ht, 1, "HTTP/1.1 200 OK")
	table.insert(ht, 2, "Server: " .. _hostname)
	table.insert(ht, 3, "Connection: keep-alive")
	table.insert(ht, 4, "Content-Type: text/html; charset=UTF-8")
	table.insert(ht, 5, "Cache-Control: no-cache")
	table.insert(ht, 6, "Content-Language: pt-BR, en-US")
	table.insert(ht, 7, "Content-Length: " .. sht .. "\n")

	local function sender(sck)
		if (#ht > 0) then
			sck:send(table.remove(ht, 1) .. "\n")
		else
			sck:close()
		end
	end

	if (_ip ~= nil) then
		print("MAIN: Webserver respondendo para o cliente " .. _ip .. ".")
	end
	sck:on("sent", sender)
	sender(sck)
end

function get_http_req(instr)
	local t1 = {}
	local t2 = {}
	local first = nil
	local key, v, strt_ndx, end_ndx
	local body = 0

	for str in string.gmatch(instr, "([^\n]+)") do
		-- First line in the method and path
		if (first == nil) then
			first = 1
			strt_ndx, end_ndx = string.find(str, "([^ ]+)")
			v = trim(string.sub(str, end_ndx + 2))
			key = trim(string.sub(str, strt_ndx, end_ndx))
			t1["METHOD"] = key
			t1["REQUEST"] = v
		elseif (body == 0) then 
			strt_ndx, end_ndx = string.find(str, "([^:]+)")
			if (end_ndx ~= nil) then
				v = trim(string.sub(str, end_ndx + 2))
				key = trim(string.sub(str, strt_ndx, end_ndx))
				if ((key ~= "") or (v ~= "")) then
					t1[key] = v
				else
					body = 1
				end
			end
		elseif (body == 1) then
			for str2 in string.gmatch(str, "([^&]+)") do
				strt_ndx, end_ndx = string.find(str2, "([^=]+)")
				if (end_ndx ~= nil) then
					v = trim(string.sub(str2, end_ndx + 2))
					key = trim(string.sub(str2, strt_ndx, end_ndx))
					if ((key ~= "") or (v ~= "")) then
						t2[key] = v
					end
				end
			end
		end
	end
	return t1, t2
end

-- String trim left and right
function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end
