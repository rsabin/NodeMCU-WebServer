--[[ *********************************************************
ENDUSER.lua
Se chegou aqui, é pra configurar wifi e mandar de volta pro arq. que testa.
********************************************************* --]]

print("ENDUSER: Inicando procedimentos para configuração via AP.")

wifi.setmode(wifi.STATIONAP)
_cfg1 = {
	ssid = "SetupESP" .. node.chipid(),
	auth = wifi.OPEN,
	hidden = false,
	save = false}

_cfg2 = {
	ip = "192.168.4.1",
	netmask = "255.255.255.0",
	gateway = "192.168.4.1"
}

print("ENDUSER: Procure uma rede com o nome " .. _cfg1.ssid .. " e acesse o IP " .. _cfg2.ip .. ".")

wifi.ap.setip(_cfg2)
wifi.ap.config(_cfg1)

enduser_setup.manual(false)

tmr.create():alarm(5000, tmr.ALARM_SINGLE, function() start_enduser() end)

function setup_ok()
	print("ENDUSER: Sucesso. Chamando programa principal em 10 segundos (por segurança).")
	--enduser_setup.stop()
	tmr.create():alarm(10000, tmr.ALARM_SINGLE, function() dofile("main.lua") end)
end

function setup_error(err, str)
	print("ENDUSER: Erro #" .. err .. " - " .. str .. ". Chamando programa de teste de wifi novamente.")
	--enduser_setup.stop()
	dofile("wifi_ok.lua")
end

function setup_debug(str)
	print("ENDUSER: Debug: " .. str .. ".")
end

function start_enduser()
	print("ENDUSER: Aguardando configuração do usuário.")
	enduser_setup.start(
		function()
			setup_ok()
		end,
		function(err, str)
			setup_error(err, str)
		end,
		print
	)
end
