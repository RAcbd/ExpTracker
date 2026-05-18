local session_start_time = 0
local starting_exp = 0
local current_level = 0
local is_initialized = false

-- Manual Color Definitions to prevent framework crashes
local colors = {
    white = color.new(255, 255, 255, 255),
    green = color.new(0, 255, 0, 255),
    yellow = color.new(255, 255, 0, 255),
    magenta = color.new(255, 0, 255, 255),
    cyan = color.new(0, 255, 255, 255),
    black = color.new(0, 0, 0, 200)
}

local menu_elements = {
    main_toggle = checkbox:new(true, get_hash("EXP_TRACKER")),
    reset_toggle = checkbox:new(false, get_hash("EXP_RESET_TOGGLE")),
}

local function format_time(seconds)
    if not seconds or seconds <= 0 or seconds > 864000 then return "00:00:00" end
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function format_num(amount)
    local val = tonumber(amount) or 0
    local formatted = tostring(math.floor(val))
    while true do  
        local k
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then break end
    end
    return formatted
end

local function draw_text_with_shadow(text, pos, size, col)
    local shadow_offset = 0.005
    local shadow_pos = vec3:new(pos:x() + shadow_offset, pos:y() - shadow_offset, pos:z())
    
    graphics.text_3d(text, shadow_pos, size, colors.black)
    graphics.text_3d(text, pos, size, col)
end

on_render(function()
    if not menu_elements.main_toggle:get() then 
        is_initialized = false
        return 
    end

    local lp = get_local_player()
    if not lp then return end

    local lp_level = lp:get_level() or 0
    local lp_exp = lp:get_current_experience() or 0
    local needed = lp:get_experience_remaining_next_level() or 0
    
    if lp_exp == 0 then return end

    if menu_elements.reset_toggle:get() or not is_initialized or lp_level > current_level then
        starting_exp = lp_exp
        current_level = lp_level
        session_start_time = get_time_since_inject()
        is_initialized = true
        menu_elements.reset_toggle:set(false)
    end

    local gained = lp_exp - starting_exp
    local elapsed = get_time_since_inject() - session_start_time

    local exp_per_hour = 0
    local eta = "00:00:00"

    if elapsed > 0.1 then
        exp_per_hour = (gained / elapsed) * 3600
        if gained > 0 then
            local exp_per_sec = gained / elapsed
            if exp_per_sec > 0 then
                eta = format_time(needed / exp_per_sec)
            end
        end
    end

    local base_pos = lp:get_position()
    local dx, dy, dz = base_pos:x(), base_pos:y(), base_pos:z()
    local h_start = 1.85  
    local v_gap = 0.3     
    local f_size = 20

    pcall(function()
        draw_text_with_shadow("Session: " .. format_time(elapsed), vec3:new(dx, dy, dz + h_start), f_size, colors.white)
        draw_text_with_shadow("Gained: +" .. format_num(gained), vec3:new(dx, dy, dz + h_start - v_gap), f_size, colors.green)
        draw_text_with_shadow("Avg/Hr: " .. format_num(exp_per_hour), vec3:new(dx, dy, dz + h_start - (v_gap * 2)), f_size, colors.magenta)
        draw_text_with_shadow("Remaining: " .. format_num(needed), vec3:new(dx, dy, dz + h_start - (v_gap * 3)), f_size, colors.yellow)
        draw_text_with_shadow("ETA: " .. eta, vec3:new(dx, dy, dz + h_start - (v_gap * 4)), f_size, colors.cyan)
    end)
end)

on_render_menu(function()
    if tree_node:new(0):push("EXP Tracker") then
        menu_elements.main_toggle:render("Enable Tracker", "Displays session stats")
        menu_elements.reset_toggle:render("Manual Reset", "Resets counter and timer to 0")
        tree_node:pop()
    end
end)