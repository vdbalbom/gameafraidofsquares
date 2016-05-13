love.window.setMode(360,640)

local dx,dy = 0, 0
local speed = 80 -- 0 - 100
local squares = {}
local atackspeed = 10 -- 0 - 100
local movespeed = 50 -- 0 - 100
local atack = 0 
local gameover = false
local lives = 3
local time = 0
local points = 0

function love.load()
  local k = 1
while k<=100 do
  squares[k] = {move = {-20, 10*k}, helprandom = {0,0}, random = {0,0}, alive = true}
  k = k + 1
  squares[k] = {move = {380, 10*k}, helprandom = {0,0}, random = {0,0}, alive = true}
  k = k + 1
end
end

function calcmove(i,j)
  if squares[j].helprandom[i] == 0 then
    squares[j].random[i] = love.math.random(2)
    squares[j].helprandom[i] = 50
  else 
    squares[j].helprandom[i] = squares[j].helprandom[i] - 1
  end
  if squares[j].random[i] == 2 then squares[j].random[i] = -1 end
  if squares[j].move[i] <= 0 then squares[j].random[i] = 1 end
  if i == 2 then
    if squares[j].move[i] >= 635 then squares[j].random[i] = -1 end
  else
    if squares[j].move[i] >= 355 then squares[j].random[i] = -1 end
  end
  squares[j].move[i] = squares[j].move[i] + squares[j].random[i]*movespeed/100
  return squares[j].move[i]
end

function love.draw()
  if gameover then
    love.graphics.print("Game Over", 150,280)
    love.graphics.print("points "..points, 100, 10)
    
  else
    love.graphics.print("lives "..lives, 10, 10)
    love.graphics.print("points "..points, 100, 10)
    love.graphics.setColor(255,255,255,255-time)
    love.graphics.circle("fill",180+dx,320+dy,5+atack/4,100)
    love.graphics.circle("line",180+dx,320+dy,5+atack/4,100)
    love.graphics.setColor(255,255,255)
    love.graphics.circle("line",180+dx,320+dy,5+atack,100)
    local j = 1
    while(j<=100) do
      if squares[j].alive then
        love.graphics.rectangle("fill",calcmove(1,j),calcmove(2,j),5,5)
      end
      j = j + 1
    end
  end
end

function love.update()
  if time > 0 then time = time - 1 end
  if love.keyboard.isDown("left") then
    dx = dx - speed/100;
  end
  if love.keyboard.isDown("right") then
    dx = dx + speed/100;
  end
  if love.keyboard.isDown("up") then
    dy = dy - speed/100;
  end
  if love.keyboard.isDown("down") then
    dy = dy + speed/100;
  end
  local i = 1
  while i <= 100 do
    if (squares[i].move[1] + 2.5 - dx - 180)^2 + (squares[i].move[2] + 2.5 - dy - 320)^2 <= (atack/4 + 3)^2 then
      if squares[i].alive and time == 0 then
        lives = lives - 1
        time = 200
        if lives == 0 then gameover = true end
        i = 100 
      end
    end
    i = i + 1;
  end
  if love.keyboard.isDown("space") then
    if atack < 100 then
      atack = atack + atackspeed/100;
    end
  else
    if not (atack==0) then
      i = 1
      while i <= 100 do
        if (squares[i].move[1] + 2.5 - dx - 180)^2 + (squares[i].move[2] + 2.5 - dy - 320)^2 <= (atack + 5)^2 then
          if squares[i].alive then points = points + 1 end
          squares[i].alive = false
        end
        i = i + 1;
      end
      atack = 0;
    end
  end
end
