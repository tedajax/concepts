require 'fire'

function love.load()
    fire_init()
    fire_set_enabled(true)

    ship = love.graphics.newImage("ship.png")

    player = {
        posX = 64, posY = 300
    }
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f" then
        fire_set_enabled()
    end
end

function love.update(dt)
    fire_update(dt)

    local ix, iy = 0, 0

    if love.keyboard.isScancodeDown("left") then ix = ix - 1 end
    if love.keyboard.isScancodeDown("right") then ix = ix + 1 end
    if love.keyboard.isScancodeDown("up") then iy = iy - 1 end
    if love.keyboard.isScancodeDown("down") then iy = iy + 1 end

    local speed = 520
    player.posX = player.posX + ix * speed * dt
    player.posY = player.posY + iy * speed * dt
end

function love.draw()
    love.graphics.clear()
    fire_draw()

    love.graphics.draw(ship, player.posX, player.posY, 0, 1, 1, 0.5, 0.5)
end