local session_start_time = 0
local starting_exp = 0
local current_level = 0
local is_initialized = false

local menu_elements = {
    main_toggle = checkbox:new(true, get_hash("EXP_TRACKER")),
}

local function format_time(seconds)
    if seconds <= 0 or seconds > 864000 then return "Calculating..." end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function format_num(amount)
    local formatted = tostring(math.floor(amount or 0))
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then break end
    end
    return formatted
end

on_render(function()
    if not menu_elements.main_toggle:get() then 
        is_initialized = false
        return 
    end

    local lp = get_local_player()
    if not lp then return end

    local lp_level = lp:get_level()
    local lp_exp = lp:get_current_experience()
    local needed = lp:get_experience_remaining_next_level()
    
    if not lp_exp or lp_exp == 0 then return end

    if not is_initialized or lp_level > current_level then
        starting_exp = lp_exp
        current_level = lp_level
        
        if not is_initialized then
            session_start_time = get_time_since_inject()
            is_initialized = true
        end
    end

    local gained = lp_exp - starting_exp
    local elapsed = get_time_since_inject() - session_start_time

    local eta = "Calculating..."
    if gained > 0 and elapsed > 10 then
        local exp_per_sec = gained / elapsed
        if exp_per_sec > 0 then
            eta = format_time(needed / exp_per_sec)
        end
    end

    local base_pos = lp:get_position()
    local font_size = 20
    local height_start = 1.5  
    local v_spacing = 0.5     
    
    local draw_x = base_pos:x()
    local draw_y = base_pos:y()

    pcall(function()
        graphics.text_3d("Gained: +" .. format_num(gained), 
            vec3:new(draw_x, draw_y, base_pos:z() + height_start), 
            font_size, color_green(255))
        
        graphics.text_3d("Remaining: " .. format_num(needed), 
            vec3:new(draw_x, draw_y, base_pos:z() + height_start - v_spacing), 
            font_size, color_yellow(255))
        
        graphics.text_3d("ETA: " .. eta, 
            vec3:new(draw_x, draw_y, base_pos:z() + height_start - (v_spacing * 2)), 
            font_size, color_cyan(255))
    end)
end)

on_render_menu(function()
    if tree_node:new(0):push("EXP Tracker") then
        menu_elements.main_toggle:render("Enable Tracker", "Displays session stats")
        tree_node:new(0):pop()
    end
end)