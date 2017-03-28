--[[ *********************************************************
WIFI_TST.lua
A principal função deste arq. é tentar conectar no wifi com os dados já salvos.
Caso consiga, segue pro programa principal. Senão chama o enduser para configurar.
********************************************************* --]]
print("WIFI_TST: Testando wifi em 1 segundo.")

_MAX_TENTATIVAS = 5

wifi.setmode(wifi.STATION)
wifi.sta.connect()

_tenta1 = 1
_timer1 = tmr.create()
_timer1:alarm(_tenta1 * 1000, tmr.ALARM_SEMI, function() test_wifi() end)

function test_wifi()
	print("WIFI_TST: Tentativa nro." .. _tenta1)

	-- Aguarda conexão algumas vezes e depois desiste.
	_tenta1 = _tenta1 + 1
	if (_tenta1 >= _MAX_TENTATIVAS) then
		print("WIFI_TST: Máximo de tentativas atingido. Desviando para ENDUSER.")
		dofile("enduser.lua")

	else

		-- Se conectou, manda pro programa principal. Senão chama esta função de novo
		local _stat = wifi.sta.status()
		if (_stat == 5) then
			print("WIFI_TST: Sucesso (" .. str_sta_status(_stat) .. "). Desviando para MAIN.")
			dofile("main.lua")

		else
			print("WIFI_TST: Ainda não conectou (" .. str_sta_status(_stat) .. "). Novo teste em " .. _tenta1 .. " segundos.")
			_timer1:interval(_tenta1 * 1000)
			_timer1:start()

		end
	end

end


function str_sta_status(num)
	local ret = ""
	if (num == 5) then
		ret = "GOTIP"
	elseif (num == 4) then
		ret = "FAIL"
	elseif (num == 3) then
		ret = "APNOTFOUND"
	elseif (num == 2) then
		ret = "WRONGPWD"
	elseif (num == 1) then
		ret = "CONNECTING"
	elseif (num == 0) then
		ret = "IDLE"
	end
	return ret
end

