function math.sign(v)
    if v < 0 then
        return -1
    elseif v > 0 then
        return 1
    else
        return 0
    end
end

_fire = { 
    enabled = false,
    sleep = false,
    width = 640,
    height = 240,
    delta = 1 / 1024,
    t = 0,
    velX = 1,
    velY = 2.5,
}

function fire_init()
    local firePixelShaderCode = [[
        uniform Image paletteImage;

        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 baseColor = texture2D(texture, texture_coords);
            return texture2D(paletteImage, vec2(baseColor.r, 0));
        }
    ]]

    local fireShowAlivePixelsCode = [[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 baseColor = texture2D(texture, texture_coords);
            if (baseColor.r > 0.00390625) {
                return vec4(1, 1, 1, 1);
            }
            else {
                return vec4(0, 0, 0, 0);
            }
        }
    ]]

    _fire.shaders = {
        normal = love.graphics.newShader(firePixelShaderCode),
        showAlive = love.graphics.newShader(fireShowAlivePixelsCode),
    }

    _fire.shader = _fire.shaders["normal"]

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

    
    local steps = 1
    local paletteData = love.image.newImageData(37 * steps, 1);

    local x = 0
    for i = 1, #rgbs, 3 do
        local r, g, b = rgbs[i] / 255, rgbs[i + 1] / 255, rgbs[i + 2] / 255
        for j = 0, steps - 1 do
            paletteData:setPixel(x + j, 0, r, g, b, 1)
        end
        x = x + steps
    end

    local paletteImage = love.graphics.newImage(paletteData)
    _fire.shaders["normal"]:send("paletteImage", paletteImage)

    _fire.canvas = love.graphics.newCanvas(_fire.width, _fire.height)
end

function fire_set_enabled(value)
    if value == nil then value = not _fire.enabled end
    _fire.enabled = value
end

function fire_update(dt)
    local fire = _fire

    fire.t = fire.t + dt

    if fire.enabled or not fire.sleep then
        local w, h = fire.width, fire.height
        
        local data = fire.canvas:newImageData()

        if fire.enabled then
            for x = 0, w - 1 do 
                data:setPixel(x, h - 1, 1, 1, 1, 1)
            end
        end

        fire.sleep = true

        local delta = fire.delta
        for y = 0, h-1 do
            for x = 0, w - 1 do
                local xx = x + math.random(-fire.velX, fire.velX)
                local yy = y + math.random() * fire.velY
                local cv = 0

                if xx >= 0 and xx < w and yy >= 0 and yy < h then
                    cv = data:getPixel(xx, yy)
                end
                if cv > 0 then
                    local v = math.max(cv - delta, 0)
                    data:setPixel(x, y, v, v, v, 1)
                    if data:getPixel(x, y) > 0 then
                        fire.sleep = false
                    end
                end
            end
        end

        local image = love.graphics.newImage(data)

        fire.canvas:renderTo(function()
            love.graphics.draw(image)
        end)
    end
end

function fire_draw()
    local sx, sy = love.graphics.getDimensions()

    love.graphics.setShader(_fire.shader)
    love.graphics.draw(_fire.canvas, 0, 0, 0, sx / _fire.width, sy / _fire.height)
    love.graphics.setShader()

end   