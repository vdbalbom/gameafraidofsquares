-- constants
local resolution = {width = 360, height = 640}
local speed = 0.9 -- [0,1]
local atackspeed = 0.1 -- [0,1]
local maxtimeprotected = 200 -- [0,255]
local maxlives = 3
local initialposition = {dx = resolution.width/2, dy = resolution.height/2}
local circleinitialrad = 5
local squarewidth = 5
local maxatack = 100

-- variables
local position
local squares
local atack
local gameover
local win
local lives
local timeprotected
local captured
local level
local score
local levelscore

function radcircle()
  return circleinitialrad + atack/4
end

function radatack()
  return circleinitialrad + atack
end

function atackspeed()
   return 0.1 + level*2/100
end

function squarespeed()
  return 0.5 + level*3/100
end

function amount()
  return 25 + level*3
end

function extralives()
  return math.modf(levelscore/100)
end

function startgame()
  level = 1
  lives = maxlives
  captured = 0
  score = 0
  levelscore = 0
  position = initialposition
  timeprotected = 0
  gameover = false
  win = false
  atack = 0
  squares = {}
  createSquares()
end

function nextlevel()
  level = level + 1
  lives = lives + extralives()
  captured = 0
  levelscore = 0
  position = initialposition
  timeprotected = 0
  gameover = false
  win = false
  atack = 0
  squares = {}
  createSquares()
end

function createSquares()
  local d = resolution.height/(amount()-1)
  local k = 0
  while k<amount() do
    squares[k+1] = {position = {dx = 0, dy = d*k}, helprandom = {0,0}, random = {0,0}, alive = true}
    squares[k+2] = {position = {dx = 355, dy = d*(k+1)}, helprandom = {0,0}, random = {0,0}, alive = true}
    k = k + 2
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
  if i == 1 then
    if squares[j].position.dx <= 0 then squares[j].random[i] = 1 end
    if squares[j].position.dx >= 355 then squares[j].random[i] = -1 end
    squares[j].position.dx = squares[j].position.dx + squares[j].random[i]*squarespeed()
    return squares[j].position.dx
  else
    if squares[j].position.dy <= 0 then squares[j].random[i] = 1 end
     if squares[j].position.dy >= 635 then squares[j].random[i] = -1 end
    squares[j].position.dy = squares[j].position.dy + squares[j].random[i]*squarespeed()
    return squares[j].position.dy
  end
end

function updatesquarespositions()
  local i = 1
  while i <= amount() do
    calcmove(1,i)
    calcmove(2,i)
    i = i + 1
  end
end

function gameoverdraw()
  love.graphics.setColor(255,255,255)
  love.graphics.print("Game Over", 150,280)
  love.graphics.print("score "..score, 150, 300)
  love.graphics.print("Press 'p' to restart...", 120, 350)
end

function windraw()
  love.graphics.setColor(255,255,255)
  love.graphics.print("You Win!", 150,280)
  love.graphics.print("score "..score, 150, 300)
  love.graphics.print("Press 'p' to contunue...", 110, 350)
end

function scoreboarddraw()
  love.graphics.setColor(255,255,255)
  love.graphics.print("lives "..lives, 10, 10)
  love.graphics.print("captured "..captured, 100, 10)
  love.graphics.print("score "..score, 210, 10)
  love.graphics.print("level "..level,300,10)
end

function circledraw()
  love.graphics.setColor(255,255,255,255-timeprotected)
  love.graphics.circle("fill",position.dx,position.dy,radcircle(),100)
  love.graphics.circle("line",position.dx,position.dy,radcircle(),100)
  love.graphics.setColor(255,255,255)
  love.graphics.circle("line",position.dx,position.dy,radatack(),100)
end

function squaresdraw()
  local i = 1
  while(i<=amount()) do
    if squares[i].alive then
      love.graphics.rectangle("fill",squares[i].position.dx,squares[i].position.dy,squarewidth,squarewidth)
    end
    i = i + 1
  end
end

function updatewin()
   if captured == amount() then
     win = true
   end
end

function updategameover()
  if lives == 0 then gameover = true end
end

function updatenextlevel()
  if love.keyboard.isDown("p") then
    nextlevel()
  end
end

function updaterestart()
  if love.keyboard.isDown("p") then
    startgame()
  end
end

function updatetimeprotected()
   if timeprotected > 0 then timeprotected = timeprotected - 1 end
end

function moveright()
  position.dx = position.dx + speed;
end

function moveleft()
  position.dx = position.dx - speed;
end

function moveup()
  position.dy = position.dy - speed;
end

function movedown()
  position.dy = position.dy + speed;
end

function updatemove()
  if love.keyboard.isDown("left") then
    moveleft()
  end
  if love.keyboard.isDown("right") then
    moveright()
  end
  if love.keyboard.isDown("up") then
    moveup()
  end
  if love.keyboard.isDown("down") then
    movedown()
  end
  if position.dx - radatack() < 0 then
    position.dx = radatack()
  end
  if position.dx + radatack() > resolution.width then
    position.dx = resolution.width - radatack()
  end
  if position.dy - radatack() < 0 then
    position.dy = radatack()
    end
  if position.dy + radatack() > resolution.height then
    position.dy = resolution.height - radatack()
  end
end

function updateatack()
  if love.keyboard.isDown("space") or love.keyboard.isDown(" ") then
      if atack < maxatack then
        atack = atack + atackspeed();
      end
    else
      if not (atack==0) then
        i = 1
        local count = 0
        while i <= amount() do
          if (squares[i].position.dx + squarewidth/2 - position.dx)^2 + (squares[i].position.dy + squarewidth/2 - position.dy)^2 <= (radatack())^2 then
            if squares[i].alive then
              captured = captured + 1
              count = count + 1
            end
            squares[i].alive = false
          end
          i = i + 1;
        end
        score = score + count^2
        atack = 0;
      end
    end
end

function updatecollide()
  local i = 1
  while i <= amount() do
    if (squares[i].position.dx + squarewidth/2 - position.dx)^2 + (squares[i].position.dy + squarewidth/2 - position.dy)^2 <= (radcircle())^2 then
      if squares[i].alive and timeprotected == 0 then
        lives = lives - 1
        timeprotected = maxtimeprotected
        i = amount()
      end
    end
    i = i + 1;
  end

end

function love.load()
  love.window.setMode(resolution.width,resolution.height)
  startgame()
end

function love.draw()
  if gameover then
    gameoverdraw()
  elseif win then
    windraw()
  else
    scoreboarddraw()
    circledraw()
    squaresdraw()
  end
end

function love.update()
  updatewin()
  updategameover()
  if win then
	updatenextlevel()
  elseif gameover then
	updaterestart()
  else
    updatetimeprotected()
    updatemove()
    updatesquarespositions()
    updateatack()
    updatecollide()
  end
end
