TOOL["Name"] = "#tool.fading_doors.name"
TOOL["Category"] = "Construction"

local en = {
    ["name"] 	= "Fading Door",
    ["desc"] 	= "Makes anything into a fadable door",
    ["0"] 	= "Left click to make it a fading door. Right click to copy data. Reload to remove fading door.",

    ["button"]  = "Button",
    ["close"]   = "Close Sound:",
    ["open"]    = "Open Sound:",
    ["none"] 	= "None"
}

local ru = {
    ["name"] 	= "Fading Door",
	["desc"] 	= "Превращает что угодно в исчезающую дверь",
	["0"] 	= "Щелкните левой кнопкой мыши, чтобы сделать это исчезающей дверью. Щелкните правой кнопкой мыши, чтобы скопировать данные. Перезарядка, чтобы удалить исчезающую дверь.",

    ["button"]  = "Кнопка",
    ["close"]   = "Звук Закрытия:",
    ["open"]    = "Звук Открытия:",
    ["none"] 	= "Отсутствует"
}

local tag_prefix = "tool.fading_doors."
for placeholder, fulltext in pairs( ru ) do
    language.Add( tag_prefix .. placeholder, fulltext, "ru" )
end

for placeholder, fulltext in pairs( en ) do
    language.Add( tag_prefix .. placeholder, fulltext, "en" )
end

-- Convars
local clientConVars = {
    -- Material
    ["material"] = "sprites/heatwave",

    -- Sounds
    ["sound_close"] = "",
    ["sound_open"] = "",

    -- Controls
    ["toggle"] = "0",
	["button"] = 41
}

-- Door Materials
local doorMaterials = {
	"models/props_combine/portalball001_sheet",
	"models/props_combine/stasisshield_sheet",
	"models/props_combine/com_shield001a",
	"models/props_combine/tprings_globe",
    "models/props_c17/frostedglass_01a",
    "models/props_lab/Tank_Glass001",
    "Models/effects/splodearc_sheet",
    "Models/effects/comball_sphere",
    "Models/effects/comball_tape",
    "Models/effects/vol_light001",
    "models/shadertest/shader3",
    "models/shadertest/shader4",
	"models/shadertest/shader5",
	-- "debug/env_cubemap_model",
    "models/debug/debugwhite",
    -- "models/screenspace",
    "sprites/heatwave",
    "models/wireframe"
}

local doorSounds = {
    -- Door Close Sounds
    ["Close"] = {
        "npc/roller/mine/combine_mine_deactivate1.wav",
        "npc/roller/mine/combine_mine_deploy1.wav",
        "npc/combine_gunship/attack_start2.wav",
        "npc/combine_gunship/attack_stop2.wav",
        "npc/scanner/scanner_nearmiss2.wav",
        "npc/roller/mine/rmine_taunt1.wav",
        "npc/barnacle/barnacle_gulp1.wav",
        "npc/barnacle/barnacle_gulp2.wav",
        "npc/scanner/scanner_siren1.wav",
        "npc/turret_floor/retract.wav",
        "npc/dog/dog_pneumatic1.wav",
        "npc/dog/dog_pneumatic2.wav",
        "doors/doorstop1.wav"
    },

    -- Door Open Sounds
    ["Open"] = {
		"npc/roller/mine/combine_mine_deactivate1.wav",
		"npc/roller/mine/combine_mine_deploy1.wav",
		"npc/combine_gunship/attack_start2.wav",
		"npc/combine_gunship/attack_stop2.wav",
		"npc/scanner/scanner_nearmiss2.wav",
		"npc/roller/mine/rmine_taunt1.wav",
		"npc/barnacle/barnacle_gulp1.wav",
		"npc/barnacle/barnacle_gulp2.wav",
        "npc/scanner/scanner_siren1.wav",
		"npc/turret_floor/retract.wav",
		"npc/dog/dog_pneumatic1.wav",
		"npc/dog/dog_pneumatic2.wav",
        "doors/doorstop1.wav"
    }
}

for name, tbl in pairs( doorSounds ) do
    local newTbl = {}
    for num, path in ipairs( tbl ) do
        if file.Exists("sound/" .. path, "GAME") then
            newTbl[ string.match( path, ".*/([%w%p]+).wav" ) ] = Sound( path )
        end
    end

    doorSounds[ name ] = newTbl
end

if CLIENT then
	function TOOL:BuildCPanel()
        for tag, default in pairs( clientConVars ) do
            CreateClientConVar("fd_" .. tag, tostring( default ), true, true)
        end

		self:AddControl("Header", {
            ["Text"] = "#tool.fading_doors.name",
            ["Description"] = "#tool.fading_doors.desc"
        })

		self:AddControl("CheckBox", {
            ["Label"] = "#tool.button.toggle",
            ["Command"] = "fd_toggle"
        })

        --  Open Sounds List
            local openSounds = vgui.Create("CtrlListBox", self)
            openSounds:AddOption("#tool.fading_doors.none", {"none"})

            for name, path in pairs( doorSounds.Open ) do
                openSounds:AddOption( name, {path} )
            end

            local left = vgui.Create("DLabel", self)
            left:SetText("#tool.fading_doors.open")
            left:SetDark(true)

            openSounds:SetHeight(25)
            openSounds:Dock(TOP)

            -- Get Player Settings
            local openCvarValue = GetConVar( "fd_sound_open" ):GetString()
            openSounds:SetValue( (openCvarValue == "") and "#tool.fading_doors.none" or openCvarValue )

            timer.Create("fd_sound_open", 0.25, 0, function()
                if IsValid( openSounds ) then
                    local openCvarValue = GetConVar( "fd_sound_open" ):GetString()
                    openSounds:SetValue( (openCvarValue == "") and "#tool.fading_doors.none" or openCvarValue )
                end
            end)

            function openSounds:OnSelect( index, value )
                RunConsoleCommand( "fd_sound_open", ((value == "#tool.fading_doors.none") and "" or value ) )
            end

            self:AddItem(left, openSounds)
        --

        --  Close Sounds List
            local closeSounds = vgui.Create("CtrlListBox", self)
            closeSounds:AddOption("#tool.fading_doors.none", {"none"})
            for name, path in pairs( doorSounds.Close ) do
                closeSounds:AddOption( name, {path} )
            end

            local left = vgui.Create("DLabel", self)
            left:SetText("#tool.fading_doors.close")
            left:SetDark(true)
            closeSounds:SetHeight(25)
            closeSounds:Dock(TOP)

            -- Get Player Settings
			local closeCvarValue = GetConVar( "fd_sound_close" ):GetString()
			closeSounds:SetValue( (closeCvarValue == "") and "#tool.fading_doors.none" or closeCvarValue )

            timer.Create("fd_sound_close", 0.25, 0, function()
                if IsValid( closeSounds ) then
                    local closeCvarValue = GetConVar( "fd_sound_close" ):GetString()
                    closeSounds:SetValue( (closeCvarValue == "") and "#tool.fading_doors.none" or closeCvarValue )
                end
            end)

            function closeSounds:OnSelect( index, value )
                RunConsoleCommand( "fd_sound_close", ((value == "#tool.fading_doors.none") and "" or value ) )
            end

		    self:AddItem(left, closeSounds)
        --

		self:AddControl("Numpad", {
            ["Label"] = "#tool.fading_doors.button",
            ["ButtonSize"] = "24",
            ["Command"] = "fd_button"
        })

		self:MatSelect("fd_material", doorMaterials, true, 0.25, 0.25)
	end

	function TOOL:LeftClick(tr)
        if tr.HitWorld then return false end
        return IsValid( tr.Entity ) and tr.Entity:IsProp()
	end

	function TOOL:RightClick(tr)
        if tr.HitWorld then return false end
        return IsValid( tr.Entity ) and tr.Entity:IsFadingDoor()
	end

	function TOOL:Reload(tr)
        if tr.HitWorld then return false end
        return IsValid( tr.Entity ) and tr.Entity:IsFadingDoor()
	end

    net.Receive( "js.fd_sync_settings", function()
        local fd_material = net.ReadString()
        if (fd_material != "") then
            RunConsoleCommand("fd_material", fd_material)
        end

        local fd_button = net.ReadString()
        if (fd_button != "") then
            RunConsoleCommand("fd_button", fd_button)
        end

        local fd_toggle = net.ReadString()
        if (fd_toggle != "") then
            RunConsoleCommand("fd_toggle", fd_toggle)
        end

        RunConsoleCommand("fd_sound_open", net.ReadString())
        RunConsoleCommand("fd_sound_close", net.ReadString())
    end)

else

    function TOOL:CreateDoor( ent )
        local ply = self:GetOwner()
        if IsValid( ply ) and ply:Alive() then
            if (ent.fading_door == nil) then
                ent:SetNWBool("fading_door", true)
                ent.fading_door = {
                    -- Base Data
                    ["Toggled"]     = false,

                    -- Material
                    ["Material"] 	= ply:GetInfo("fd_material", clientConVars.material),

                    -- Key
                    ["Key"] 	 	= ply:GetInfoNum("fd_button", clientConVars.button),
                    ["IsToggle"] 	= tobool( ply:GetInfoNum("fd_toggle", clientConVars.toggle) ),

                    -- Sounds
                    ["Sounds"]		= {
                        ["Open"] 	= ply:GetInfo("fd_sound_open", clientConVars.sound_open),
                        ["Close"]	= ply:GetInfo("fd_sound_close", clientConVars.sound_close)
                    }
                }
            else
                ent.fading_door = table.Merge(ent.fading_door, {
                    -- Material
                    ["Material"] 	= ply:GetInfo("fd_material", clientConVars.material),

                    -- Key
                    ["Key"] 	 	= ply:GetInfoNum("fd_button", clientConVars.button),
                    ["IsToggle"] 	= tobool( ply:GetInfoNum("fd_toggle", clientConVars.toggle) ),

                    -- Sounds
                    ["Sounds"]		= {
                        ["Open"] 	= ply:GetInfo("fd_sound_open", clientConVars.sound_open),
                        ["Close"]	= ply:GetInfo("fd_sound_close", clientConVars.sound_close)
                    }
                })
            end

            ent.fading_door.Up = numpad.OnUp( ply, ent.fading_door.Key, "Fading_DoorUp", ent )
            ent.fading_door.Down = numpad.OnDown( ply, ent.fading_door.Key, "Fading_DoorDown", ent )

            local phys = ent:GetPhysicsObject()
            if IsValid( phys ) then
                phys:EnableMotion( false )
                phys:EnableDrag( false )
            end

            return true
        end

        return false
    end

    util.AddNetworkString( "js.fd_sync_settings" )
    function TOOL:CopyData( ent )
        local data = ent.fading_door
        if (data == nil) then return false end

        local ply = self:GetOwner()
        if IsValid( ply ) then

            net.Start("js.fd_sync_settings")
                net.WriteString( data.Material )
                net.WriteString( tostring( data.Key ) )
                net.WriteString( (data.IsToggle == true) and "1" or "0" )
                net.WriteString( data.Sounds.Open )
                net.WriteString( data.Sounds.Close )
            net.Send( ply )

            return true
        end

        return false
    end

    function TOOL:RightClick( tr )
        if tr.HitWorld then return false end

        local ent = tr.Entity
        if IsValid( ent ) and ent:IsFadingDoor() then
            return self:CopyData( ent )
        end

        return false
    end

    function TOOL:LeftClick( tr )
        if tr.HitWorld then return false end

        local ent = tr.Entity
        if IsValid( ent ) and ent:IsProp() then
            return self:CreateDoor( ent )
        end

        return false
    end

    function TOOL:RemoveDoor( ent )
        local data = ent.fading_door
        if (data) then

            -- Collision Group Return
            local oldCollisionGroup = data.OldCollisionGroup
            if (oldCollisionGroup != nil) then
                ent:SetCollisionGroup( oldCollisionGroup )
                data.OldCollisionGroup = nil
            end

            -- Material Return
            local oldMaterial = data.OldMaterial
            if (oldMaterial != nil) then
                ent:SetMaterial( oldMaterial )
                data.OldMaterial = nil
            end

            if (data.Up) then
                numpad.Remove( data.Up )
            end

            if (data.Down) then
                numpad.Remove( data.Down )
            end

            ent.fading_door = nil
        end

        ent:SetNWBool( "fading_door", false )

        local phys = ent:GetPhysicsObject()
        if IsValid( phys ) then
            phys:EnableMotion( true )
            phys:Wake()
        end

        return true
    end

    function TOOL:Reload( tr )
        if tr.HitWorld then return false end

        local ent = tr.Entity
        if IsValid( ent ) and ent:IsFadingDoor() then
            return self:RemoveDoor( ent )
        end

        return false
    end

    local deadUse = CreateConVar("fd_deaduse", "0", {FCVAR_LUA_SERVER, FCVAR_ARCHIVE}, 0, 1):GetBool()
    cvars.AddChangeCallback("fd_deaduse", function( name, old, new )
        deadUse = tobool( new )
    end)

    local function toggleFadingDoor( ent, data, state )
        if (state) then
            -- Collision Group Save and Change
            data.OldCollisionGroup = ent:GetCollisionGroup()
            ent:SetCollisionGroup( 12 )

            -- Material Save and Change
            data.OldMaterial = ent:GetMaterial()
            ent:SetMaterial( data.Material )

            ent:DrawShadow( false )

            local openSound = data.Sounds.Open
            if (openSound != "") then
                ent:EmitSound( doorSounds.Open[ openSound ] )
            end
        else
            -- Collision Group Return
            local oldCollisionGroup = data.OldCollisionGroup
            if (oldCollisionGroup != nil) then
                ent:SetCollisionGroup( oldCollisionGroup )
                data.OldCollisionGroup = nil
            end

            -- Material Return
            local oldMaterial = data.OldMaterial
            if (oldMaterial != nil) then
                ent:SetMaterial( (oldMaterial == "") and nil or oldMaterial )
                data.OldMaterial = nil
            end

            ent:DrawShadow( true )

            local closeSound = data.Sounds.Close
            if (closeSound != "") then
                ent:EmitSound( doorSounds.Close[ closeSound ] )
            end
        end

        data.Toggled = state
    end

    local function toggle( pressed, ply, ent )
        if (deadUse == true) or ply:Alive() then
            if IsValid( ent ) then
                local data = ent.fading_door
                if (data == nil) then
                    ent:Remove()
                    return
                end

                if (data.IsToggle) then
                    if (pressed) then return end
                    toggleFadingDoor( ent, data, not data.Toggled )
                else
                    toggleFadingDoor( ent, data, pressed )
                end
            end
        end
    end

    numpad.Register("Fading_DoorDown", function( ... )
        toggle( true, ... )
    end)

    numpad.Register("Fading_DoorUp", function( ... )
        toggle( false, ... )
    end)

end

do
    local ENTITY = FindMetaTable("Entity")
    function ENTITY:IsFadingDoor()
        return self:GetNWBool( "fading_door", false )
    end
end