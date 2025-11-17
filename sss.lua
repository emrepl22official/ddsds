-- follow.lua
-- Pocket bilgisayarında çalıştır. Broadcastları dinler ve ekranda gösterir.
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

print("Dinleme modunda. Takip etmek istediğin isim (label) yaz, boş bırak tümünü gösterir:")
local target = read()
if target == "" then target = nil end

local function compass(dx, dz)
  -- yaklaşık yön: N, NE, E, SE, S, SW, W, NW
  local angle = math.deg(math.atan2(dx, dz)) -- dx: x farkı, dz: z farkı
  if angle < 0 then angle = angle + 360 end
  local dirs = {"N","NE","E","SE","S","SW","W","NW"}
  local idx = math.floor(((angle + 22.5) % 360) / 45) + 1
  return dirs[idx]
end

local function parse(msg)
  -- "TRACKER|name|x|y|z"
  local parts = {}
  for p in string.gmatch(msg, "[^|]+") do table.insert(parts, p) end
  if #parts >= 5 and parts[1] == "TRACKER" then
    local name = parts[2]
    if parts[3] == "nil" then return name, nil end
    local x = tonumber(parts[3]); local y = tonumber(parts[4]); local z = tonumber(parts[5])
    return name, {x=x,y=y,z=z}
  end
  return nil
end

print("Bekleniyor... (ctrl+T ile durdur)")

while true do
  local id, msg = rednet.receive(5) -- 5 saniye bekle
  if id and msg then
    local name, pos = parse(msg)
    if name and (not target or name == target) then
      term.clear(); term.setCursorPos(1,1)
      print("Takipçi: "..name)
      if not pos then
        print("GPS yok veya pozisyon alınamıyor.")
      else
        -- kendi pozisyonun (eğer GPS varsa)
        local sx, sy, sz = gps.locate(2)
        if sx then
          local dx = pos.x - sx; local dz = pos.z - sz; local dy = pos.y - sy
          local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
          print(string.format("Pozisyon: x=%.2f y=%.2f z=%.2f", pos.x, pos.y, pos.z))
          print(string.format("Uzaklık: %.2f blok", dist))
          print("Yön: "..compass(dx, dz))
        else
          print(string.format("Pozisyon: x=%.2f y=%.2f z=%.2f", pos.x, pos.y, pos.z))
          print("Kendi pozisyonun bilinmiyor (GPS yok). Uzaklık hesaplanamaz.")
        end
      end
    end
  else
    -- zaman aşımı, arayüzü güncelle veya bekle
  end
end
