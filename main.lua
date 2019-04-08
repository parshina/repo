local Element = require("Element")
local Field = require("Field")

local COLORS = {"A","B","C","D","E","F"," "} -- сет цветов, последний используется для пустого поля
local WIDTH = 10
local HEIGHT = 10

local function validate_command(command)  -- пытаемся парсить команду
  if (command == "q") then
    return true
  end
  local x,y,dir
  x,y,dir = string.match(command,"m (%d+) (%d+) ([lrud])")  -- парсим
  if (x == nil) then -- не получилось распарсить
    print ("correct format is m x y dir")
    return false
  end
  x = tonumber(x)
  y = tonumber(y)
  --проверяем что x y и свич в пределах границы поля
  if (x >= HEIGHT) or (y >= WIDTH) then
    print ("dont cross borders of field")
    return false
  end
  if (dir == "l" and y == 0) or (dir == "r" and y == WIDTH-1) or (dir == "u" and x == 0) or (dir == "d" and x == HEIGHT-1) then
    print ("dont cross borders of field")
    return false
  end
  return true, x+1, y+1, dir
end

-- основной цикл

local field = Field:init(COLORS, WIDTH, HEIGHT)
field:dump()
print("type command")
local command
command = io.read()
while (command ~= "q") do
  local is_correct,x,y,dir = validate_command(command)
  if (is_correct == false) then 
    print ("please type correct command")
    command = io.read()
  else
    local match = field:move(x, y, dir) --меняем
    if match == false then print("no match after this movement\n") end 
    field:dump() -- показали результат менки (если он был)
    io.read() --просто ждём enter чтоб двигаться дальше
    field:tick() -- взрывы, падения
    print("type command")  -- начинаем след ход
    command = io.read()
  end
end 