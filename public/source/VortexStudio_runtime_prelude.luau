
local __schedule = __schedule
local __report = __report
local __fireServer = __fireServer

local MAX_HANDLERS = 512

local function suspended(co, first)
	if coroutine.status(co) ~= "suspended" then
		return false
	end
	if type(first) == "table" and first.__block then
		return true
	end
	local seconds = 0
	if type(first) == "table" and first.__wait then
		seconds = first.__wait
	end
	__schedule(co, seconds)
	return true
end

local function adopt(co, ok, first)
	if not ok then
		error(first, 0)
	end
	suspended(co, first)
	return co
end

local function adoptSafe(co, ok, first)
	if not ok then
		__report(tostring(first))
		return co
	end
	suspended(co, first)
	return co
end

local function bind(fn, ...)
	local args = table.pack(...)
	if args.n == 0 then
		return fn
	end
	return function()
		return fn(table.unpack(args, 1, args.n))
	end
end

task = {}

function task.wait(seconds)
	return coroutine.yield({ __wait = seconds or 0 })
end

function task.spawn(fn, ...)
	local co = fn
	if type(fn) == "function" then
		co = coroutine.create(fn)
	end
	return adopt(co, coroutine.resume(co, ...))
end

function task.delay(seconds, fn, ...)
	local co = coroutine.create(bind(fn, ...))
	__schedule(co, seconds or 0)
	return co
end

function task.defer(fn, ...)
	return task.delay(0, fn, ...)
end

function wait(seconds)
	return task.wait(seconds)
end

function spawn(fn)
	return task.spawn(fn)
end

function delay(seconds, fn)
	return task.delay(seconds, fn)
end

Debris = {}

function Debris:AddItem(item, lifetime)
	if item == nil then
		return
	end
	task.delay(lifetime or 10, function()
		if type(item) == "table" and type(item.Destroy) == "function" then
			item:Destroy()
		end
	end)
end

function Debris:SetMaxItems() end

local Connection = {}
Connection.__index = Connection

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false
	local handlers = self._signal._handlers
	for i, c in ipairs(handlers) do
		if c == self then
			table.remove(handlers, i)
			break
		end
	end
end

Connection.disconnect = Connection.Disconnect

local Signal = {}
Signal.__index = Signal

function Signal.new(name)
	return setmetatable({ _name = name, _handlers = {}, _waiting = {} }, Signal)
end

function Signal:Connect(fn)
	if type(fn) ~= "function" then
		error("Connect expects a function", 2)
	end
	if #self._handlers >= MAX_HANDLERS then
		error(`signal "{self._name}" exceeded {MAX_HANDLERS} connections`, 2)
	end
	local conn = setmetatable({ Connected = true, _signal = self, _fn = fn }, Connection)
	table.insert(self._handlers, conn)
	return conn
end

Signal.connect = Signal.Connect

function Signal:Once(fn)
	local conn
	conn = self:Connect(function(...)
		conn:Disconnect()
		fn(...)
	end)
	return conn
end

function Signal:Wait()
	table.insert(self._waiting, coroutine.running())
	return coroutine.yield({ __block = true })
end

function Signal:Fire(...)
	local snapshot = {}
	for i, conn in ipairs(self._handlers) do
		snapshot[i] = conn
	end
	for _, conn in ipairs(snapshot) do
		if conn.Connected then
			local co = coroutine.create(conn._fn)
			adoptSafe(co, coroutine.resume(co, ...))
		end
	end

	local waiters = self._waiting
	if #waiters > 0 then
		self._waiting = {}
		for _, co in ipairs(waiters) do
			adoptSafe(co, coroutine.resume(co, ...))
		end
	end
end

Signal.fire = Signal.Fire

local registry = {}

function __signal(key)
	local existing = registry[key]
	if existing then
		return existing
	end
	local created = Signal.new(key)
	registry[key] = created
	return created
end

function __fire(key, ...)
	local existing = registry[key]
	if existing then
		existing:Fire(...)
	end
end

function __has(key)
	local existing = registry[key]
	return existing ~= nil and (#existing._handlers > 0 or #existing._waiting > 0)
end

function __promote(from, to, remoteTo)
	remoteTo = remoteTo or to
	local moves = {}
	for key in pairs(registry) do
		local rest = key:match("^Changed%.(.+)$")
		if rest == from then
			moves[#moves + 1] = { key, "Changed." .. to }
		end
		local scope, prop = key:match("^PropChanged%.([^.]+)%.(.+)$")
		if scope == from then
			moves[#moves + 1] = { key, "PropChanged." .. to .. "." .. prop }
		end
		local ascope, aname = key:match("^AttrChanged%.([^.]+)%.(.+)$")
		if ascope == from then
			moves[#moves + 1] = { key, "AttrChanged." .. to .. "." .. aname }
		end
		local remote = key:match("^RemoteEvent%.(.+)$")
		if remote == from then
			moves[#moves + 1] = { key, "RemoteEvent." .. remoteTo }
		end
		local bindable = key:match("^Bindable%.(.+)$")
		if bindable == from then
			moves[#moves + 1] = { key, "Bindable." .. remoteTo }
		end
	end
	for _, m in ipairs(moves) do
		local src = registry[m[1]]
		if src then
			local dst = __signal(m[2])
			for _, h in ipairs(src._handlers) do
				dst._handlers[#dst._handlers + 1] = h
				h._signal = dst
			end
			for _, w in ipairs(src._waiting) do
				dst._waiting[#dst._waiting + 1] = w
			end
			registry[m[1]] = nil
		end
	end
	if __serverInvokeHandlers then
		local fromKey = "ServerInvoke." .. from
		local fn = __serverInvokeHandlers[fromKey]
		if fn then
			__serverInvokeHandlers["ServerInvoke." .. remoteTo] = fn
			__serverInvokeHandlers[fromKey] = nil
		end
	end
end

RunService = {
	Heartbeat = __signal("RunService.Heartbeat"),
}

local function bounceOut(t)
	local n, d = 7.5625, 2.75
	if t < 1 / d then
		return n * t * t
	elseif t < 2 / d then
		t = t - 1.5 / d
		return n * t * t + 0.75
	elseif t < 2.5 / d then
		t = t - 2.25 / d
		return n * t * t + 0.9375
	else
		t = t - 2.625 / d
		return n * t * t + 0.984375
	end
end

local EASE_IN = {
	Linear = function(t) return t end,
	Sine = function(t) return 1 - math.cos(t * math.pi / 2) end,
	Quad = function(t) return t * t end,
	Cubic = function(t) return t * t * t end,
	Quart = function(t) return t * t * t * t end,
	Quint = function(t) return t * t * t * t * t end,
	Exponential = function(t) return t == 0 and 0 or 2 ^ (10 * (t - 1)) end,
	Circular = function(t) return 1 - math.sqrt(math.max(0, 1 - t * t)) end,
	Back = function(t)
		local c1 = 1.70158
		return (c1 + 1) * t * t * t - c1 * t * t
	end,
	Elastic = function(t)
		if t == 0 or t == 1 then return t end
		return -(2 ^ (10 * (t - 1))) * math.sin((t - 1.075) * (2 * math.pi) / 0.3)
	end,
	Bounce = function(t) return 1 - bounceOut(1 - t) end,
}

local function easeName(v)
	if type(v) == "table" and v.Name then return v.Name end
	if type(v) == "string" then return v end
	return nil
end

local function applyEasing(style, direction, t)
	local f = EASE_IN[easeName(style) or "Quad"] or EASE_IN.Quad
	local dir = easeName(direction) or "Out"
	if dir == "In" then
		return f(t)
	elseif dir == "InOut" then
		if t < 0.5 then return f(2 * t) / 2 end
		return 1 - f(2 - 2 * t) / 2
	else
		return 1 - f(1 - t)
	end
end

TweenInfo = {}

function TweenInfo.new(time, style, direction, repeatCount, reverses, delayTime)
	return {
		Time = time or 1,
		EasingStyle = style or Enum.EasingStyle.Quad,
		EasingDirection = direction or Enum.EasingDirection.Out,
		RepeatCount = repeatCount or 0,
		Reverses = reverses or false,
		DelayTime = delayTime or 0,
	}
end

local function lerpValue(a, b, t)
	if type(a) == "number" then
		return a + (b - a) * t
	end
	if type(a) == "table" and type(a.Lerp) == "function" then
		return a:Lerp(b, t)
	end
	return t < 1 and a or b
end

local tweenActive = {}
local MAX_TWEENS = 256

local Tween = {}
Tween.__index = Tween

function Tween:Play()
	if self.PlaybackState == Enum.PlaybackState.Playing then
		return
	end
	if self.PlaybackState ~= Enum.PlaybackState.Paused then
		self._elapsed = 0
		self._start = {}
		for prop in pairs(self._goals) do
			self._start[prop] = self.Instance[prop]
		end
	end
	self.PlaybackState = Enum.PlaybackState.Playing
	for _, e in ipairs(tweenActive) do
		if e == self then return end
	end
	if #tweenActive >= MAX_TWEENS then
		error(`more than {MAX_TWEENS} tweens playing at once`, 2)
	end
	tweenActive[#tweenActive + 1] = self
end

local function removeTween(self)
	for i, e in ipairs(tweenActive) do
		if e == self then
			table.remove(tweenActive, i)
			return
		end
	end
end

function Tween:Pause()
	if self.PlaybackState == Enum.PlaybackState.Playing then
		self.PlaybackState = Enum.PlaybackState.Paused
	end
end

function Tween:Cancel()
	removeTween(self)
	self._elapsed = 0
	self.PlaybackState = Enum.PlaybackState.Cancelled
	self.Completed:Fire(Enum.PlaybackState.Cancelled)
end

local function sampleTween(self)
	local d = self._info.Time
	if d <= 0 then return 1, true end
	local elapsed = self._elapsed - self._info.DelayTime
	local seg = self._info.Reverses and (2 * d) or d
	local total = self._info.RepeatCount < 0 and math.huge
		or seg * (self._info.RepeatCount + 1)
	if elapsed >= total then
		return (self._info.Reverses and 0 or 1), true
	end
	local within = elapsed % seg
	if self._info.Reverses and within > d then
		return 1 - (within - d) / d, false
	end
	return math.min(within / d, 1), false
end

local function stepTweens(dt)
	local snapshot = {}
	for i, e in ipairs(tweenActive) do snapshot[i] = e end
	for _, tw in ipairs(snapshot) do
		if tw.PlaybackState == Enum.PlaybackState.Playing then
			if tw.Instance.Parent == nil then
				removeTween(tw)
			else
				tw._elapsed = tw._elapsed + dt
				if tw._elapsed >= tw._info.DelayTime then
					local alpha, done = sampleTween(tw)
					local eased = applyEasing(tw._info.EasingStyle, tw._info.EasingDirection, alpha)
					for prop, goal in pairs(tw._goals) do
						pcall(function()
							tw.Instance[prop] = lerpValue(tw._start[prop], goal, eased)
						end)
					end
					if done then
						removeTween(tw)
						tw.PlaybackState = Enum.PlaybackState.Completed
						tw.Completed:Fire(Enum.PlaybackState.Completed)
					end
				end
			end
		end
	end
end

RunService.Heartbeat:Connect(function(dt)
	if #tweenActive > 0 then
		stepTweens(dt or 0)
	end
end)

TweenService = {}

function TweenService:Create(m_7123a699d7, info, goals)
	if type(m_7123a699d7) ~= "table" then
		error("TweenService:Create expects an Instance", 2)
	end
	if type(goals) ~= "table" then
		error("TweenService:Create expects a table of properties", 2)
	end
	info = info or TweenInfo.new()
	return setmetatable({
		Instance = m_7123a699d7,
		PlaybackState = Enum.PlaybackState.Begin,
		Completed = Signal.new("Tween.Completed"),
		_info = {
			Time = info.Time or 1,
			EasingStyle = info.EasingStyle,
			EasingDirection = info.EasingDirection,
			RepeatCount = info.RepeatCount or 0,
			Reverses = info.Reverses or false,
			DelayTime = info.DelayTime or 0,
		},
		_goals = goals,
		_start = {},
		_elapsed = 0,
	}, Tween)
end

function FireServer(channel, ...)
	__fireServer(channel, ...)
end

function OnRemoteEvent(channel, fn)
	return __signal("RemoteEvent." .. channel):Connect(fn)
end

__serverInvokeHandlers = {}

function __makeInvokeServer(queue)
	return function(_, ...)
		local id = queue(...)
		local ok, a, b, c, d, e, f, g = __signal("Invoke." .. id):Wait()
		registry["Invoke." .. id] = nil
		if not ok then
			error(a, 0)
		end
		return a, b, c, d, e, f, g
	end
end

function __runServerInvoke(key, ...)
	local fn = __serverInvokeHandlers[key]
	if not fn then
		return
	end
	return pcall(fn, ...)
end
