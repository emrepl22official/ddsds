-- tracker.lua
-- Hedef oyuncunun bilgisayarında çalıştırılır.
-- Gereksinim: wireless modem (pocket veya computer) ve sunucuda GPS (gps.locate) çalışıyor olmalı.
local sides = {"left","right","top","bottom","front","back"}
local modemSide
for _,s in ipairs(sides) do
  if peripheral.getType and peripheral.getType(s) == "modem" then modemSide = s; break end
end
if not modemSide then
  print("Modem bulunamadı. Cihazında wireless modem olmalı.")
  return
end
rednet.open(modemSide)

local name = os.getComputerLabel() or "tracker"
print("Tracker çalışıyor. ID: "..name)
local interval = 1 -- kaç saniyede bir yayınlansın

while true do
  -- gps.locate(timeout) -> x,y,z  (sunucuda GPS kuleleri kurulmuş olmalı)
  local x,y,z = gps.locate(2)
  if x then
    -- mesaj formatı: "TRACKER|isim|x|y|z"
    local msg = table.concat({"TRACKER", name, tostring(x), tostring(y), tostring(z)}, "|")
    rednet.broadcast(msg)
  else
    -- gps bulunamadı
    rednet.broadcast("TRACKER|"..name.."|nil|nil|nil")
  end
  sleep(interval)
end
