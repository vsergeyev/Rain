-----------------------------------------------------------------------------------------
--
-- rain.lua
-- V. Sergeyev, pydevside@gmail.com
-- http://pythondvside.com
--
-- Snow by David Schooley <illustrationism@gmail.com>
-- 
-----------------------------------------------------------------------------------------
local screenW, screenH = display.contentWidth, display.contentHeight

local rain = {}
local rain_mt = { __index = rain }

-- EnterFrame handler
function rain.rainHandler( e )
	for i = 1, rain.group.numChildren, 1 do
		if rain.group[i].name == "rainDrop" then
			local drop = rain.group[i]
			if drop.y < rain.rainFloor then
				drop.x = drop.x + rain.rainRight * rain.dropLength*math.cos(rain.rainAngle) * drop.dropSpeed --rain.rainSpeed
				drop.y = drop.y + rain.dropLength * drop.dropSpeed --rain.rainSpeed
			else
				drop.x = drop.x0
				drop.y = drop.y0
			end
		end
	end
end

-- Constructor
function rain.new(group, config)
    rain.group = group

    -- Config
	rain.rainAngle = math.rad(config.angle or 70)
	rain.rainRight = -1
	if config.toRight then
		rain.rainRight = 1
	end
	local dropsCount = config.count or 500

	-- Rain or snow
	if (config.snow) then
		rain.rainSpeed = config.speed or 0.6
		rain.rainFloor = screenH - (config.floor or 0)
		rain.dropRadius = config.radius or 6
		rain.dropLength = rain.dropRadius
		rain.dropWidth = rain.dropRadius
		rain.dropAlpha = config.alpha or 0.1
		rain.dropColor = config.color or 255
	else
		rain.rainSpeed = config.speed or 1.2
		rain.rainFloor = screenH - (config.floor or 0)
		rain.dropLength = config.length or 45
		rain.dropWidth = config.width or 1
		rain.dropAlpha = config.alpha or 0.08
		rain.dropColor = config.color or 255
	end

    -- Drops
	for i = 1, dropsCount, 1 do
		local dy = math.random(screenH+100)
		local x, y = i*10 - rain.rainRight*(screenW*math.cos(rain.rainAngle)), -50-dy
		local drop

		-- Snow
		if (config.snow) then
			-- Make different sizes, weighed for smaller flakes
			local r_size = math.random(1,100)
			local size
			if     (r_size <= 50) then size = -2
			elseif (r_size <= 70) then size = -1
			elseif (r_size <= 85) then size = 0
			elseif (r_size <= 95) then size = 1
			else size = 2 end

			drop = display.newCircle(x, y, (rain.dropRadius + size))
			drop:setFillColor(rain.dropColor, rain.dropColor, rain.dropColor)
			drop.dropSpeed = rain.rainSpeed + (size / 10)
			drop.blendMode = "add"
			drop.alpha = rain.dropAlpha + ((size + 2) / 20)

		-- Rain
		else
			drop = display.newLine(x, y, x + rain.rainRight * rain.dropLength*math.cos(rain.rainAngle), y + rain.dropLength)
			drop.width = rain.dropWidth
			drop:setColor( rain.dropColor )
			drop.dropSpeed = rain.rainSpeed
			drop.alpha = rain.dropAlpha
		end

		drop.x0, drop.y0 = x, y
		drop.name = "rainDrop"
		group:insert(drop)
	end

	if not config.silent then
		local rainSound = config.sound or audio.loadStream("rain.wav")
		audio.play(rainSound, {loops=-1})
	end

	Runtime:addEventListener( "enterFrame", rain.rainHandler )
end

function rain.pause()
	Runtime:removeEventListener( "enterFrame", rain.rainHandler )
end

function rain.resume()
	Runtime:addEventListener( "enterFrame", rain.rainHandler )
end

return rain

----------------
-- End.
----------------