local Field = {}
local Element = require("Element")

local Pair = {}
function Pair:new(x,y)
  local newObj = {}
  newObj.x = x
  newObj.y = y
  self.__index = self
  return setmetatable(newObj, self)
end

--меняем местами 2 элемента на нашем поле
local function swap(self,move_from, move_to)
  local buff = self.table[move_from.x][move_from.y]
  self.table[move_from.x][move_from.y] = self.table[move_to.x][move_to.y]
  self.table[move_to.x][move_to.y] = buff
end
--ищем вертикальную линиию в (x,y)
local function vert_check(self,coordinates)
  local match = {}
  if (coordinates.x > self.height or coordinates.y > self.width) then
    print ("Smth go wrong")
    return match
  end
  local vert = {coordinates}
  local x = coordinates.x 
  local y = coordinates.y
  local i=1
  while (x-i >= 1 and self.table[x][y].color == self.table[x-i][y].color) do
    vert[#vert+1] = Pair:new(x-i, y)
    i = i+1
  end
  i=1
  while (x+i <= self.height and self.table[x][y].color == self.table[x+i][y].color) do
    vert[#vert+1] = Pair:new(x+i, y)
    i = i+1
  end
  if #vert >=3 then match = vert end
  return match
end
--ищем горизонтальную линиию в (x,y)
local function horizon_check(self,coordinates)
  local match = {}
  if (coordinates.x > self.height or coordinates.y > self.width) then
    print ("Smth go wrong")
    return match
  end
  local horizon = {coordinates}
  local x = coordinates.x 
  local y = coordinates.y
  local i=1
  while (y-i >= 1 and self.table[x][y].color == self.table[x][y-i].color) do
    horizon[#horizon+1] = Pair:new(x, y-i)
    i = i+1
  end
  i=1
  while (y+i <= self.width and self.table[x][y].color == self.table[x][y+i].color) do
    horizon[#horizon+1] = Pair:new(x, y+i)
    i = i+1
  end
  if #horizon >=3 then match = horizon end
  return match
end
-- чекаем все фигуры в (x, y), возвращаем координаты заматчивших элементов
local function check(self, coordinates)
  local match = {}
  if (coordinates.x > self.height or coordinates.y > self.width) then
    print ("Smth go wrong")
    return match
  end
  match = horizon_check(self,coordinates)
  local vert=vert_check(self,coordinates)
  for i=1, #vert, 1 do
    match[#match+1]=vert[i]
  end
  return match
end
--чекаем всё поле. заматчившие элементы помечаем на удаление. возвращаем true|false
local function check_field(self)
  local isMatch = false
  for i = 1, self.height, 1 do
    for j = 1, self.width, 1 do
      if self.table[i][j].moved then --проверять можно только те элементы которые двигались
        local pair = Pair:new(i,j)
        local match = check(self, pair)
        for k=1, #match, 1 do
          local x= match[k].x
          local y= match[k].y
          self.table[x][y].toDelete=true
          isMatch=true
        end
      end
    end
  end
  return isMatch
end
--падение
local function fall(self)
  for j = 1, self.width, 1 do
    local elements = {}
    local isMovingStart = false
    for i = self.height, 1, -1 do
      if not self.table[i][j].toDelete then
        self.table[i][j].moved = isMovingStart -- запоминаем если падает
        elements[#elements+1] = self.table[i][j]
      else
        isMovingStart = true -- как только есть удалённый - начинаем падение
      end
    end
    if isMovingStart then --если элементы падали - пересобираем колонку и генерим новые
      for k=1, #elements, 1 do
        self.table[self.height-k+1][j] = elements[k]
      end
      for k=#elements+1, self.height, 1 do
        self.table[self.height-k+1][j] = Element:new(#self.COLORS -1)
      end
    end
  end
end
--проверяем есть ли ход
local function help (self)
  local isMove
  for i = 1, self.height-1, 1 do
    for j = 1, self.width-1, 1 do
      isMove = self:move(i, j, "r")
      if isMove then
        swap(self, Pair:new(i,j), Pair:new(i,j+1))
        self.table[i][j].moved = false
        self.table[i][j+1].moved = false
        return i, j, "r"
      end
      isMove = self:move(i, j, "d")
      if isMove then
        swap(self, Pair:new(i,j), Pair:new(i+1,j))
        self.table[i][j].moved = false
        self.table[i+1][j].moved = false
        return i, j, "d"
      end
    end
    isMove = self:move(i, self.width, "d")
    if isMove then
      swap(self, Pair:new(i,self.width), Pair:new(i+1,self.width))
      self.table[i][self.width].moved = false
      self.table[i+1][self.width].moved = false
      return i, self.width, "d"
    end
  end
  for j = 1, self.width-1, 1 do
    isMove = self:move(self.height, j, "r")
    if isMove then
      swap(self, Pair:new(self.height,j), Pair:new(self.height,j+1))
      self.table[self.height][j].moved = false
      self.table[self.height][j+1].moved = false
      return self.height, j, "r"
    end
  end
  return false
end
--тик без вывода на экран для инициализации
local function silent_tick(self)
  local isMatch = check_field(self)
  while isMatch do
    fall(self)
    isMatch = check_field(self)
  end
  local isMove = help(self)
  if (isMove == false) then
    while not isMove or isMatch do
      self:mix()
      isMatch = check_field(self)
      isMove = help(self)
    end
  end
end
----------------------------------------------------------------
----------------------------------------------------------------
function Field:init(COLORS, WIDTH, HEIGHT)
  local newObj = {}
  newObj.table = {}
  newObj.width = WIDTH
  newObj.height = HEIGHT
  newObj.COLORS = COLORS
  self.__index = self
  for i = 1, newObj.height, 1 do
    newObj.table[i] = {}
    for j = 1, newObj.width, 1 do
      newObj.table[i][j] = Element:new(#newObj.COLORS -1) --последний цвет для пустой ячейки
    end
  end
  setmetatable(newObj, self)
  silent_tick(newObj)  -- протикали чтоб не было готовых м3 но был ход
  return newObj
end

local function hide_deleted(self) --перекрашиваем "удалённые" в пустой цвет
  for i = 1, self.height, 1 do
    for j = 1, self.width, 1 do
      if self.table[i][j].toDelete then
        self.table[i][j].color = #self.COLORS
      end
    end
  end
  return
end

function Field:tick()
  local isMatch = check_field(self)
  while isMatch do
    hide_deleted(self)
    print("BOOOOOM!\n")
    self:dump() --выводим на экран поле после взрыва
    io.read() --просто ждём enter чтоб двигаться дальше
    fall(self)
    print("taptaptap!\n")
    self:dump()  --выводим на экран поле после падения элементов
    io.read() --просто ждём enter чтоб двигаться дальше
    isMatch = check_field(self)
  end
  local isMove = help(self) -- проверяем ходы, при необходимости перемешиваем
  if (isMove == false) then
    print ("no movements\nlet's mix it\n")
    while not isMove or isMatch do
      self:mix()
      isMatch = check_field(self)
      isMove = help(self)
    end
    self:dump()
  end
end

--меняем элементы если ход приводит к матчу. возвращаем true|false
function Field:move(x, y, dir)
  local match1,match2
  local move_from=Pair:new(x,y),move_to
  if dir=="l" then
    move_to=Pair:new(x,y-1)
  elseif dir=="r" then
    move_to=Pair:new(x,y+1)
  elseif dir=="u" then
    move_to=Pair:new(x-1,y)
  elseif dir=="d" then
    move_to=Pair:new(x+1,y)
  else
    print ("Smth really goes wrong")
    return false
  end
  swap(self, move_from, move_to)
  match1 = check(self,move_from)
  match2 = check(self,move_to)
  if (#match1 == 0 and #match2 == 0) then
    swap(self, move_from, move_to)
    return false
  else
    self.table[move_to.x][move_to.y].moved=true
    self.table[move_from.x][move_from.y].moved=true
    return true
  end
  return false
end

function Field:dump()
  io.write("    ")
  for j = 1, self.width, 1 do io.write(j-1 .. " ") end
  io.write("\n    ")
  for j = 1, self.width, 1 do io.write("--") end
  io.write("\n")
  for i = 1, self.height, 1 do
    io.write(i-1 .. " | ")
    for j = 1, self.width, 1 do
      local color_index = self.table[i][j].color
      io.write(self.COLORS[color_index] .. " ")
    end
    print ("\n")
  end
end

function Field:mix()
  --меняем рандомные элементы местами
  for k = 1, self.width*self.height, 1 do
    local p1 =Pair:new(math.floor(math.random(1,self.height)), math.floor(math.random(1,self.width)))
    local p2= Pair:new(math.floor(math.random(1,self.height)), math.floor(math.random(1,self.width)))
    swap(self, p1, p2)
  end
  for i = 1, self.height, 1 do
    for j = 1, self.width, 1 do --всё поле делаем новым: элементы двигались, на удаление никто не помечен
      self.table[i][j].moved = true
      self.table[i][j].toDelete = false
    end
  end
end

return Field