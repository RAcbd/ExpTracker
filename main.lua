local plugin_version = "1.4"
local session_start_time = 0
local starting_exp = 0
local current_level = 0
local is_initialized = false

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

    pos_x = slider_int:new(0, 3840, 50, get_hash("EXP_TRACKER_X")),
    pos_y = slider_int:new(0, 2160, 200, get_hash("EXP_TRACKER_Y")),
    font_size = slider_int:new(10, 50, 20, get_hash("EXP_TRACKER_FONT_SIZE")),
    line_gap = slider_int:new(10, 60, 25, get_hash("EXP_TRACKER_LINE_GAP")),
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

local function draw_text_2d_with_shadow(text, x, y, size, col)
    local shadow_offset = 2
    
    graphics.text_2d(text, vec2:new(x + shadow_offset, y + shadow_offset), size, colors.black)
    graphics.text_2d(text, vec2:new(x, y), size, col)
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

    local start_x = menu_elements.pos_x:get()
    local start_y = menu_elements.pos_y:get()
    local f_size = menu_elements.font_size:get()
    local v_gap = menu_elements.line_gap:get()     

    pcall(function()
        draw_text_2d_with_shadow("Session: " .. format_time(elapsed), start_x, start_y, f_size, colors.white)
        draw_text_2d_with_shadow("Gained: +" .. format_num(gained), start_x, start_y + v_gap, f_size, colors.green)
        draw_text_2d_with_shadow("Avg/Hr: " .. format_num(exp_per_hour), start_x, start_y + (v_gap * 2), f_size, colors.magenta)
        draw_text_2d_with_shadow("Remaining: " .. format_num(needed), start_x, start_y + (v_gap * 3), f_size, colors.yellow)
        draw_text_2d_with_shadow("ETA: " .. eta, start_x, start_y + (v_gap * 4), f_size, colors.cyan)
    end)
end)

on_render_menu(function()
    if tree_node:new(0):push("U | Exp Tracker | Raff | v" .. plugin_version) then
        menu_elements.main_toggle:render("Enable Tracker", "Displays session stats")
        menu_elements.reset_toggle:render("Manual Reset", "Resets counter and timer to 0")
        
        -- Layout Sliders Group
        menu_elements.pos_x:render("X Position", "Move UI horizontally across the screen")
        menu_elements.pos_y:render("Y Position", "Move UI vertically up and down the screen")
        menu_elements.font_size:render("Font Size", "Adjust the scale of the overlay text")
        menu_elements.line_gap:render("Line Gap", "Adjust the vertical spacing between tracking metrics")
        
        tree_node:pop()
    end
end)