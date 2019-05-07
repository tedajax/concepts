pixelcode = [[
uniform Image paletteImage;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
    vec4 baseColor = texture2D(texture, texture_coords);
    return texture2D(paletteImage, vec2(baseColor.r, 0));
}
]]

function love.load()
    pxshader = love.graphics.newShader(pixelcode)

    rgbs = {
                0x07,0x07,0x07,
                0x1F,0x07,0x07,
                0x2F,0x0F,0x07,
                0x47,0x0F,0x07,
                0x57,0x17,0x07,
                0x67,0x1F,0x07,
                0x77,0x1F,0x07,
                0x8F,0x27,0x07,
                0x9F,0x2F,0x07,
                0xAF,0x3F,0x07,
                0xBF,0x47,0x07,
                0xC7,0x47,0x07,
                0xDF,0x4F,0x07,
                0xDF,0x57,0x07,
                0xDF,0x57,0x07,
                0xD7,0x5F,0x07,
                0xD7,0x5F,0x07,
                0xD7,0x67,0x0F,
                0xCF,0x6F,0x0F,
                0xCF,0x77,0x0F,
                0xCF,0x7F,0x0F,
                0xCF,0x87,0x17,
                0xC7,0x87,0x17,
                0xC7,0x8F,0x17,
                0xC7,0x97,0x1F,
                0xBF,0x9F,0x1F,
                0xBF,0x9F,0x1F,
                0xBF,0xA7,0x27,
                0xBF,0xA7,0x27,
                0xBF,0xAF,0x2F,
                0xB7,0xAF,0x2F,
                0xB7,0xB7,0x2F,
                0xB7,0xB7,0x37,
                0xCF,0xCF,0x6F,
                0xDF,0xDF,0x9F,
                0xEF,0xEF,0xC7,
                0xFF,0xFF,0xFF
            }

    
    paletteData = love.image.newImageData(37, 1);

    local x = 0
    for i = 1, #rgbs, 3 do
        local r, g, b = rgbs[i] / 255, rgbs[i + 1] / 255, rgbs[i + 2] / 255
        paletteData:setPixel(x, 0, r, g, b, 1)
        x = x + 1
    end

    paletteImage = love.graphics.newImage(paletteData)

    pxshader:send("paletteImage", paletteImage)

    
    cx, cy = 640, 360 / 2
    local sx, sy = love.graphics.getDimensions()
    canvas = love.graphics.newCanvas(cx, cy)

    enableFire = true
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "f" then
        enableFire = not enableFire
    end
end

function love.update(dt)
    local sx, sy = canvas:getDimensions()
    local delta = 1 / 256
    
    local data = canvas:newImageData()

    if enableFire then
        for x = 0, sx - 1 do 
            data:setPixel(x, sy - 1, 1, 1, 1, 1)
        end
    end

    for y = 0, sy - 1 do
        for x = 0, sx - 1 do
            local r = bit.band(math.floor(math.random() * 3), 3)
            local cv = data:getPixel(math.min(math.max(x + (r - 1), 0), sx - 1), math.min(math.max(y + bit.band(r, 1), 0), sy - 1))
            if cv > 0 then
                local v = cv - delta
                data:setPixel(x, y, v, v, v, 1)
            end
        end
    end

    local image = love.graphics.newImage(data)

    canvas:renderTo(function()
        love.graphics.draw(image)
    end)
end

function love.draw()
    local sx, sy = love.graphics.getDimensions()
    love.graphics.clear()
    love.graphics.setShader(pxshader)
    love.graphics.draw(canvas, 0, 0, 0, sx / cx, sy / cy)
    love.graphics.setShader()
end