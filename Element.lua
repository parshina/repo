local Element = {}
function Element:new(colors_count)
  local newObj = {}
  newObj.color = math.floor(math.random(1,colors_count))
  newObj.toDelete = false     --отмечает элемент на удаление
  newObj.moved = true         --отмечает если новый/двигался
  return newObj
end
return Element