--[[ *********************************************************
ENDUSER.lua
Se chegou aqui, é pra configurara  wifi e mandar de volta pro arq. que testa.
********************************************************* ]]--

print("ENDUSER: Inicando procedimentos para configuração via AP.")

wifi.setmode(wifi.SOFTAP)
_cfg1 = {
    ssid = "SetupESP_" .. node.chipid(),
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

enduser_setup.manual(true)

enduser_setup.start(setup_ok, setup_error, setup_debug)


function setup_ok()
	enduser_setup.stop()
	print("ENDUSER: Sucesso. Chamando programa principal em 10 segundos (por segurança).")
	tmr.create():alarm(10000, tmr.ALARM_SINGLE, function() dofile("main.lua") end)
end

function setup_error(err, str)
	enduser_setup.stop()
    print("ENDUSER: Erro #" .. err .. " - " .. str .. ". Chamando programa de teste de wifi novamente.")
	dofile("wifi_ok.lua")
end

function setup_debug(str)
	print("ENDUSER: Debug: " .. str .. ".")
end
