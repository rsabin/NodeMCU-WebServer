--[[ *********************************************************
INIT.lua
Apenas inicia um timer de 3 segundos antes de desviar para o programa real.
Isso evita problemas de loop se der erro fata logo na entrada.
********************************************************* ]]--

print("INIT: Iniciando programa em 3 segundos.")

tmr.create():alarm(3000, tmr.ALARM_SINGLE, function() dofile("wifi_tst.lua") end)
