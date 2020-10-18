Hitbox = Class{}

function Hitbox:init(map, x, y, width, height)
	self.map = map
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function Hitbox:deInit()
	self.x = nil
	self.y = nil
	self.width = nil
	self.height = nil
	self = nil
end

function Hitbox:update(x, y)
	self.x = x
	self.y = y
end

function Hitbox:changeProperties(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
end

function Hitbox:hitboxCollides(hitbox2)
	if self.x ~= nil and hitbox2.x ~= nil then
		if ((self.x <= hitbox2.x and self.x + self.width >= hitbox2.x) or (self.x <= hitbox2.x + hitbox2.width and self.x + self.width >= hitbox2.x + hitbox2.width) or (self.x <= hitbox2.x and self.x + self.width >= hitbox2.x + hitbox2.width) or (self.x >= hitbox2.x and self.x + self.width <= hitbox2.x + hitbox2.width)) and ((self.y <= hitbox2.y and self.y + self.height >= hitbox2.y) or (self.y >= hitbox2.y and self.y <= hitbox2.y + hitbox2.height)) then
			return true
		end
	end
	
	return false
end

function Hitbox:tileCollides(direction)
	if direction == 'right' then
		-- check if there's a tile directly to the right of us
		if self.map:collides(self.map:tileAt(self.x + self.width, self.y + 4)) and
			not self.map:collides(self.map:tileAt(self.x + self.width, self.y + 4 - self.height)) and
			not self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height / 2 - self.height)) then

			return true

		elseif self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height / 2)) and
			not self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height / 2 - self.height)) and
			not self.map:collides(self.map:tileAt(self.x + self.width, self.y + 4 - self.height)) then

			return true

		elseif self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 1)) then

			return true
			
		end
	elseif direction == 'left' then
		-- check if there's a tile directly to the left of us
        if self.map:collides(self.map:tileAt(self.x - 1, self.y + 4)) and
			not self.map:collides(self.map:tileAt(self.x - 1, self.y + 4 - self.height)) and
			not self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height / 2 - self.height)) then
			
			return true
			
		elseif self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height / 2)) and
			not self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height / 2 - self.height)) and
			not self.map:collides(self.map:tileAt(self.x - 1, self.y + 4 - self.height)) then
			
			return true
			
		elseif self.map:collides(self.map:tileAt(self.x - 1, self.y + self.height - 1)) then
            
            return true
			
		end
	end
	
	return false
end

function Hitbox:render()
	if self.x ~= nil then
		love.graphics.setColor(1, 1, 1, .75)
		love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
		love.graphics.setColor(1, 1, 1, 1)
	end
end