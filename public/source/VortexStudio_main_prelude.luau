
Vector3 = {}
Vector3.__index = Vector3

function Vector3.new(x, y, z)
    return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, Vector3)
end

function Vector3.__add(a, b)
    return Vector3.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

function Vector3.__sub(a, b)
    return Vector3.new(a.x - b.x, a.y - b.y, a.z - b.z)
end

function Vector3.__mul(a, b)
    if type(a) == "number" then
        return Vector3.new(a * b.x, a * b.y, a * b.z)
    end
    if type(b) == "number" then
        return Vector3.new(a.x * b, a.y * b, a.z * b)
    end
    return Vector3.new(a.x * b.x, a.y * b.y, a.z * b.z)
end

function Vector3.__div(a, b)
    if type(b) == "number" then
        return Vector3.new(a.x / b, a.y / b, a.z / b)
    end
    return Vector3.new(a.x / b.x, a.y / b.y, a.z / b.z)
end

function Vector3.__unm(v)
    return Vector3.new(-v.x, -v.y, -v.z)
end

function Vector3.__eq(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z
end

function Vector3.__tostring(v)
    return string.format("%.3f, %.3f, %.3f", v.x, v.y, v.z)
end

function Vector3:Dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

function Vector3:Cross(other)
    return Vector3.new(
        self.y * other.z - self.z * other.y,
        self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x
    )
end

function Vector3:Lerp(other, alpha)
    return self + (other - self) * alpha
end

Vector3.zero = Vector3.new(0, 0, 0)
Vector3.one = Vector3.new(1, 1, 1)
Vector3.xAxis = Vector3.new(1, 0, 0)
Vector3.yAxis = Vector3.new(0, 1, 0)
Vector3.zAxis = Vector3.new(0, 0, 1)

local vector3_fields = {
    Magnitude = function(v)
        return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
    end,
    Unit = function(v)
        local m = v.Magnitude
        if m == 0 then return Vector3.zero end
        return Vector3.new(v.x / m, v.y / m, v.z / m)
    end,
    X = function(v) return v.x end,
    Y = function(v) return v.y end,
    Z = function(v) return v.z end,
}

local vector3_methods = {}
for key, value in pairs(Vector3) do
    if type(value) == "function" then vector3_methods[key] = value end
end

function Vector3.__index(v, key)
    local field = vector3_fields[key]
    if field then return field(v) end
    return vector3_methods[key]
end

Color3 = {}
Color3.__index = Color3

function Color3.new(r, g, b)
    return setmetatable({ R = r or 0, G = g or 0, B = b or 0 }, Color3)
end

function Color3.fromRGB(r, g, b)
    return Color3.new((r or 0) / 255, (g or 0) / 255, (b or 0) / 255)
end

function Color3.__eq(a, b)
    return a.R == b.R and a.G == b.G and a.B == b.B
end

function Color3.__tostring(c)
    return string.format("%.3f, %.3f, %.3f", c.R, c.G, c.B)
end

function Color3:Lerp(other, alpha)
    return Color3.new(
        self.R + (other.R - self.R) * alpha,
        self.G + (other.G - self.G) * alpha,
        self.B + (other.B - self.B) * alpha
    )
end

CFrame = {}

local function qnorm(x, y, z, w)
    local m = math.sqrt(x * x + y * y + z * z + w * w)
    if m == 0 then return 0, 0, 0, 1 end
    return x / m, y / m, z / m, w / m
end

local function qmul(ax, ay, az, aw, bx, by, bz, bw)
    return
        aw * bx + ax * bw + ay * bz - az * by,
        aw * by - ax * bz + ay * bw + az * bx,
        aw * bz + ax * by - ay * bx + az * bw,
        aw * bw - ax * bx - ay * by - az * bz
end

local function qrot(qx, qy, qz, qw, vx, vy, vz)
    local tx = 2 * (qy * vz - qz * vy)
    local ty = 2 * (qz * vx - qx * vz)
    local tz = 2 * (qx * vy - qy * vx)
    return
        vx + qw * tx + (qy * tz - qz * ty),
        vy + qw * ty + (qz * tx - qx * tz),
        vz + qw * tz + (qx * ty - qy * tx)
end

local function axisq(ax, ay, az, angle)
    local h = angle * 0.5
    local s = math.sin(h)
    return ax * s, ay * s, az * s, math.cos(h)
end

local function qmat(x, y, z, w)
    local xx, yy, zz = x * x, y * y, z * z
    local xy, xz, yz = x * y, x * z, y * z
    local wx, wy, wz = w * x, w * y, w * z
    return
        1 - 2 * (yy + zz), 2 * (xy - wz),     2 * (xz + wy),
        2 * (xy + wz),     1 - 2 * (xx + zz), 2 * (yz - wx),
        2 * (xz - wy),     2 * (yz + wx),     1 - 2 * (xx + yy)
end

local function matq(r00, r01, r02, r10, r11, r12, r20, r21, r22)
    local tr = r00 + r11 + r22
    if tr > 0 then
        local s = math.sqrt(tr + 1.0) * 2
        return (r21 - r12) / s, (r02 - r20) / s, (r10 - r01) / s, 0.25 * s
    elseif r00 > r11 and r00 > r22 then
        local s = math.sqrt(1.0 + r00 - r11 - r22) * 2
        return 0.25 * s, (r01 + r10) / s, (r02 + r20) / s, (r21 - r12) / s
    elseif r11 > r22 then
        local s = math.sqrt(1.0 + r11 - r00 - r22) * 2
        return (r01 + r10) / s, 0.25 * s, (r12 + r21) / s, (r02 - r20) / s
    else
        local s = math.sqrt(1.0 + r22 - r00 - r11) * 2
        return (r02 + r20) / s, (r12 + r21) / s, 0.25 * s, (r10 - r01) / s
    end
end

local function newRaw(x, y, z, qx, qy, qz, qw)
    qx, qy, qz, qw = qnorm(qx, qy, qz, qw)
    return setmetatable({ x = x, y = y, z = z, qx = qx, qy = qy, qz = qz, qw = qw }, CFrame)
end

function CFrame.fromMatrix(pos, vx, vy, vz)
    local qx, qy, qz, qw = matq(
        vx.x, vy.x, vz.x,
        vx.y, vy.y, vz.y,
        vx.z, vy.z, vz.z
    )
    return newRaw(pos.x, pos.y, pos.z, qx, qy, qz, qw)
end

function CFrame.lookAt(at, target, up)
    up = up or Vector3.yAxis
    local back = (at - target).Unit
    if back.Magnitude == 0 then back = Vector3.zAxis end
    local right = up:Cross(back).Unit
    if right.Magnitude == 0 then right = Vector3.xAxis end
    local trueUp = back:Cross(right)
    return CFrame.fromMatrix(at, right, trueUp, back)
end

function CFrame.fromEulerAnglesXYZ(rx, ry, rz)
    local qx = { axisq(1, 0, 0, rx) }
    local qy = { axisq(0, 1, 0, ry) }
    local qz = { axisq(0, 0, 1, rz) }
    local ax, ay, az, aw = qmul(qx[1], qx[2], qx[3], qx[4], qy[1], qy[2], qy[3], qy[4])
    ax, ay, az, aw = qmul(ax, ay, az, aw, qz[1], qz[2], qz[3], qz[4])
    return newRaw(0, 0, 0, ax, ay, az, aw)
end

CFrame.Angles = CFrame.fromEulerAnglesXYZ

function CFrame.fromEulerAnglesYXZ(rx, ry, rz)
    local qy = { axisq(0, 1, 0, ry) }
    local qx = { axisq(1, 0, 0, rx) }
    local qz = { axisq(0, 0, 1, rz) }
    local ax, ay, az, aw = qmul(qy[1], qy[2], qy[3], qy[4], qx[1], qx[2], qx[3], qx[4])
    ax, ay, az, aw = qmul(ax, ay, az, aw, qz[1], qz[2], qz[3], qz[4])
    return newRaw(0, 0, 0, ax, ay, az, aw)
end

CFrame.fromOrientation = CFrame.fromEulerAnglesYXZ

function CFrame.fromAxisAngle(axis, angle)
    local u = axis.Unit
    return newRaw(0, 0, 0, axisq(u.x, u.y, u.z, angle))
end

function CFrame.new(a, b, c, ...)
    if a == nil then
        return newRaw(0, 0, 0, 0, 0, 0, 1)
    end
    if type(a) == "table" and type(b) == "table" then
        return CFrame.lookAt(a, b, c)
    end
    if type(a) == "table" then
        return newRaw(a.x, a.y, a.z, 0, 0, 0, 1)
    end
    local rest = { ... }
    if #rest >= 9 then
        local qx, qy, qz, qw = matq(rest[1], rest[2], rest[3], rest[4], rest[5], rest[6], rest[7], rest[8], rest[9])
        return newRaw(a, b, c, qx, qy, qz, qw)
    end
    if #rest >= 4 then
        return newRaw(a, b, c, rest[1], rest[2], rest[3], rest[4])
    end
    return newRaw(a or 0, b or 0, c or 0, 0, 0, 0, 1)
end

function CFrame.__mul(a, b)
    if type(b) == "table" and b.qw ~= nil then
        local px, py, pz = qrot(a.qx, a.qy, a.qz, a.qw, b.x, b.y, b.z)
        local qx, qy, qz, qw = qmul(a.qx, a.qy, a.qz, a.qw, b.qx, b.qy, b.qz, b.qw)
        return newRaw(a.x + px, a.y + py, a.z + pz, qx, qy, qz, qw)
    end
    local px, py, pz = qrot(a.qx, a.qy, a.qz, a.qw, b.x, b.y, b.z)
    return Vector3.new(a.x + px, a.y + py, a.z + pz)
end

function CFrame.__add(a, v)
    return newRaw(a.x + v.x, a.y + v.y, a.z + v.z, a.qx, a.qy, a.qz, a.qw)
end

function CFrame.__sub(a, v)
    return newRaw(a.x - v.x, a.y - v.y, a.z - v.z, a.qx, a.qy, a.qz, a.qw)
end

function CFrame.__eq(a, b)
    return a.x == b.x and a.y == b.y and a.z == b.z
        and a.qx == b.qx and a.qy == b.qy and a.qz == b.qz and a.qw == b.qw
end

function CFrame.__tostring(c)
    local r00, r01, r02, r10, r11, r12, r20, r21, r22 = qmat(c.qx, c.qy, c.qz, c.qw)
    return string.format("%.3f, %.3f, %.3f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f, %.5f",
        c.x, c.y, c.z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
end

function CFrame:Inverse()
    local ix, iy, iz, iw = -self.qx, -self.qy, -self.qz, self.qw
    local px, py, pz = qrot(ix, iy, iz, iw, -self.x, -self.y, -self.z)
    return newRaw(px, py, pz, ix, iy, iz, iw)
end

function CFrame:ToWorldSpace(cf)
    return self * cf
end

function CFrame:ToObjectSpace(cf)
    return self:Inverse() * cf
end

function CFrame:PointToWorldSpace(v)
    return self * v
end

function CFrame:PointToObjectSpace(v)
    return self:Inverse() * v
end

function CFrame:VectorToWorldSpace(v)
    return Vector3.new(qrot(self.qx, self.qy, self.qz, self.qw, v.x, v.y, v.z))
end

function CFrame:VectorToObjectSpace(v)
    return Vector3.new(qrot(-self.qx, -self.qy, -self.qz, self.qw, v.x, v.y, v.z))
end

function CFrame:GetComponents()
    local r00, r01, r02, r10, r11, r12, r20, r21, r22 = qmat(self.qx, self.qy, self.qz, self.qw)
    return self.x, self.y, self.z, r00, r01, r02, r10, r11, r12, r20, r21, r22
end

CFrame.components = CFrame.GetComponents

function CFrame:ToEulerAnglesXYZ()
    local r00, r01, r02, _, r11, r12, _, r21, r22 = qmat(self.qx, self.qy, self.qz, self.qw)
    local sy = math.max(-1, math.min(1, r02))
    local y = math.asin(sy)
    if math.abs(r02) < 0.99999 then
        return math.atan2(-r12, r22), y, math.atan2(-r01, r00)
    end
    return math.atan2(r21, r11), y, 0
end

CFrame.toEulerAnglesXYZ = CFrame.ToEulerAnglesXYZ

function CFrame:ToEulerAnglesYXZ()
    local _, _, r02, r10, r11, r12, _, _, r22 = qmat(self.qx, self.qy, self.qz, self.qw)
    local sx = math.max(-1, math.min(1, -r12))
    local x = math.asin(sx)
    if math.abs(r12) < 0.99999 then
        return x, math.atan2(r02, r22), math.atan2(r10, r11)
    end
    return x, math.atan2(r02, r22), 0
end

CFrame.toEulerAnglesYXZ = CFrame.ToEulerAnglesYXZ
CFrame.ToOrientation = CFrame.ToEulerAnglesYXZ

function CFrame:Lerp(goal, alpha)
    local ax, ay, az, aw = self.qx, self.qy, self.qz, self.qw
    local bx, by, bz, bw = goal.qx, goal.qy, goal.qz, goal.qw
    if ax * bx + ay * by + az * bz + aw * bw < 0 then
        bx, by, bz, bw = -bx, -by, -bz, -bw
    end
    return newRaw(
        self.x + (goal.x - self.x) * alpha,
        self.y + (goal.y - self.y) * alpha,
        self.z + (goal.z - self.z) * alpha,
        ax + (bx - ax) * alpha,
        ay + (by - ay) * alpha,
        az + (bz - az) * alpha,
        aw + (bw - aw) * alpha
    )
end

local cframe_fields = {
    Position = function(c) return Vector3.new(c.x, c.y, c.z) end,
    p = function(c) return Vector3.new(c.x, c.y, c.z) end,
    X = function(c) return c.x end,
    Y = function(c) return c.y end,
    Z = function(c) return c.z end,
    LookVector = function(c) return Vector3.new(qrot(c.qx, c.qy, c.qz, c.qw, 0, 0, -1)) end,
    RightVector = function(c) return Vector3.new(qrot(c.qx, c.qy, c.qz, c.qw, 1, 0, 0)) end,
    UpVector = function(c) return Vector3.new(qrot(c.qx, c.qy, c.qz, c.qw, 0, 1, 0)) end,
    XVector = function(c) return Vector3.new(qrot(c.qx, c.qy, c.qz, c.qw, 1, 0, 0)) end,
    YVector = function(c) return Vector3.new(qrot(c.qx, c.qy, c.qz, c.qw, 0, 1, 0)) end,
    ZVector = function(c) return Vector3.new(qrot(c.qx, c.qy, c.qz, c.qw, 0, 0, 1)) end,
    Rotation = function(c) return newRaw(0, 0, 0, c.qx, c.qy, c.qz, c.qw) end,
}

local cframe_methods = {}
for key, value in pairs(CFrame) do
    if type(value) == "function" then cframe_methods[key] = value end
end

function CFrame.__index(c, key)
    local field = cframe_fields[key]
    if field then return field(c) end
    return cframe_methods[key]
end

CFrame.identity = newRaw(0, 0, 0, 0, 0, 0, 1)

Enum = {}

local EnumItem = {}
EnumItem.__index = EnumItem
function EnumItem.__tostring(i) return "Enum." .. i.EnumType.Name .. "." .. i.Name end
function EnumItem.__eq(a, b) return a.Name == b.Name and a.EnumType == b.EnumType end

local function defineEnum(name, items)
    local et = { Name = name }
    local byName, list = {}, {}
    for _, pair in ipairs(items) do
        local item = setmetatable({ Name = pair[1], Value = pair[2], EnumType = et }, EnumItem)
        byName[pair[1]] = item
        list[#list + 1] = item
    end
    function et:GetEnumItems()
        local out = {}
        for i, v in ipairs(list) do out[i] = v end
        return out
    end
    function et:FromName(n) return byName[n] end
    function et:FromValue(v)
        for _, it in ipairs(list) do if it.Value == v then return it end end
    end
    setmetatable(et, {
        __index = function(_, k)
            local it = byName[k]
            if it then return it end
            error("'" .. tostring(k) .. "' is not a valid member of \"Enum." .. name .. "\"", 2)
        end,
        __tostring = function() return "Enum." .. name end,
    })
    Enum[name] = et
end

defineEnum("Material", {
    {"Smooth", 1}, {"Plastic", 2}, {"Wood", 3}, {"Metal", 4}, {"Grass", 5}, {"Ice", 6}, {"Paint", 7},
})
defineEnum("NormalId", {
    {"Right", 0}, {"Top", 1}, {"Back", 2}, {"Left", 3}, {"Bottom", 4}, {"Front", 5},
})

defineEnum("KeyCode", {
    {"Unknown", 0},
    {"Backspace", 8}, {"Tab", 9}, {"Return", 13}, {"Escape", 27}, {"Space", 32},
    {"Quote", 39}, {"Comma", 44}, {"Minus", 45}, {"Period", 46}, {"Slash", 47},
    {"Zero", 48}, {"One", 49}, {"Two", 50}, {"Three", 51}, {"Four", 52},
    {"Five", 53}, {"Six", 54}, {"Seven", 55}, {"Eight", 56}, {"Nine", 57},
    {"Semicolon", 59}, {"Equals", 61},
    {"LeftBracket", 91}, {"BackSlash", 92}, {"RightBracket", 93}, {"Backquote", 96},
    {"A", 97}, {"B", 98}, {"C", 99}, {"D", 100}, {"E", 101}, {"F", 102}, {"G", 103},
    {"H", 104}, {"I", 105}, {"J", 106}, {"K", 107}, {"L", 108}, {"M", 109}, {"N", 110},
    {"O", 111}, {"P", 112}, {"Q", 113}, {"R", 114}, {"S", 115}, {"T", 116}, {"U", 117},
    {"V", 118}, {"W", 119}, {"X", 120}, {"Y", 121}, {"Z", 122}, {"Delete", 127},
    {"Up", 17}, {"Down", 18}, {"Right", 19}, {"Left", 20},
    {"LeftShift", 304}, {"RightShift", 303}, {"LeftControl", 306}, {"RightControl", 305},
    {"LeftAlt", 308}, {"RightAlt", 307}, {"LeftSuper", 311}, {"RightSuper", 312},
    {"F1", 265}, {"F2", 266}, {"F3", 267}, {"F4", 268}, {"F5", 269}, {"F6", 270},
    {"F7", 271}, {"F8", 272}, {"F9", 273}, {"F10", 274}, {"F11", 275}, {"F12", 276},
})

defineEnum("UserInputType", {
    {"MouseButton1", 0}, {"MouseButton2", 1}, {"MouseButton3", 2}, {"MouseWheel", 3},
    {"MouseMovement", 4}, {"Touch", 7}, {"Keyboard", 8}, {"Focus", 9},
    {"Gamepad1", 12}, {"None", 19},
})

defineEnum("EasingStyle", {
    {"Linear", 0}, {"Sine", 1}, {"Back", 2}, {"Quad", 3}, {"Quart", 4}, {"Quint", 5},
    {"Bounce", 6}, {"Elastic", 7}, {"Exponential", 8}, {"Circular", 9}, {"Cubic", 10},
})

defineEnum("EasingDirection", {
    {"In", 0}, {"Out", 1}, {"InOut", 2},
})

defineEnum("PlaybackState", {
    {"Begin", 0}, {"Delayed", 1}, {"Playing", 2}, {"Paused", 3},
    {"Completed", 4}, {"Cancelled", 5},
})

setmetatable(Enum, {
    __index = function(_, k)
        error("'" .. tostring(k) .. "' is not a valid Enum", 2)
    end,
})

