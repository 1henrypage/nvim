local M = {}

-- Helper: run a shell command and return trimmed output
local function term_cmd(cmd)
	local wrapped = { "sh", "-c", cmd }
	return vim.fn.system(wrapped):gsub("%s+$", "")
end

-- Helper: detect OS
local _system_type
local function system_type()
	if _system_type then
		return _system_type
	end
	local sysname = (vim.uv or vim.loop).os_uname().sysname:lower()
	if sysname:find("darwin") then
		_system_type = "darwin"
	elseif sysname:find("linux") then
		_system_type = "linux"
	else
		_system_type = "unknown"
	end
	return _system_type
end

-- Progress bar generator (each character is 1 display column wide)
-- Braille block U+28xx: East Asian Width = N (Neutral) → always 1 display col
local BAR_FILLED = "⣿"
local BAR_EMPTY  = "⠀"

local function gen_graph(percent, width)
	percent = tonumber(percent)
	if not percent or percent ~= percent then
		percent = 0
	end
	width = width or 20
	percent = math.max(0, math.min(percent, 100))
	local filled = math.floor((percent / 100) * width + 0.5)
	filled = math.max(0, math.min(filled, width))
	return string.rep(BAR_FILLED, filled) .. string.rep(BAR_EMPTY, width - filled)
end

-- Fastfetch integration with cache
local _ff_cache
local _has_fastfetch

local function fetch_stats()
	if _ff_cache then
		return _ff_cache
	end
	if _has_fastfetch == false then
		return nil
	end
	if _has_fastfetch == nil then
		_has_fastfetch = term_cmd("command -v fastfetch") ~= ""
	end
	if not _has_fastfetch then
		return nil
	end

	local json_output =
		term_cmd([[fastfetch -s CPUUsage:Memory:Swap:Disk:Uptime:Battery:Processes:LocalIP --format json]])
	if json_output == "" then
		return nil
	end

	local ok, data = pcall(vim.json.decode, json_output)
	if not ok or not data then
		return nil
	end

	local stats = {}
	for _, item in ipairs(data) do
		if item.type == "CPUUsage" and item.result then
			local sum = 0
			for _, val in ipairs(item.result) do
				sum = sum + val
			end
			stats.cpu_load = math.floor((sum / #item.result) + 0.5)
		elseif item.type == "Memory" and item.result then
			stats.ram_total = item.result.total
			stats.ram_used = item.result.used
		elseif item.type == "Swap" and item.result and item.result[1] then
			stats.swap_total = item.result[1].total
			stats.swap_used = item.result[1].used
		elseif item.type == "Disk" and item.result and item.result[1] then
			stats.disk_total = item.result[1].bytes.total
			stats.disk_used = item.result[1].bytes.used
		elseif item.type == "Battery" and item.result and item.result[1] then
			stats.battery_capacity = item.result[1].capacity
			stats.battery_status = item.result[1].status
		elseif item.type == "Processes" and item.result then
			stats.processes = tostring(item.result)
		elseif item.type == "LocalIp" and item.result and item.result[1] then
			stats.local_ip = item.result[1].ipv4
		elseif item.type == "Uptime" and item.result then
			stats.uptime = item.result.bootTime
		end
	end

	_ff_cache = stats
	return stats
end

-- Stat helpers
local function get_cpu(ff)
	if ff and ff.cpu_load then
		return ff.cpu_load
	end
	return tonumber((term_cmd("uptime"):match("load averages?:%s*([%d%.]+)"))) or 0
end

local function get_ram(ff)
	if ff and ff.ram_total and ff.ram_used then
		local used = math.floor((tonumber(ff.ram_used) / 1024 ^ 3) * 10) / 10
		local total = math.floor((tonumber(ff.ram_total) / 1024 ^ 3) * 10) / 10
		return used, total
	end
	local vm_stat = term_cmd("vm_stat")
	local page_size = 4096
	local active = tonumber(vm_stat:match("Pages active:%s*(%d+)")) or 0
	local inactive = tonumber(vm_stat:match("Pages inactive:%s*(%d+)")) or 0
	local wired = tonumber(vm_stat:match("Pages wired down:%s*(%d+)")) or 0
	local memsize = tonumber((term_cmd("sysctl -n hw.memsize"):gsub("[^%d]", ""))) or (8 * 1024 ^ 3)
	local used_gb = math.floor((active + inactive + wired) * page_size / 1024 ^ 3)
	local total_gb = math.floor(memsize / 1024 ^ 3)
	return used_gb, total_gb
end

local function get_swap(ff)
	if ff and ff.swap_total and ff.swap_used then
		local used = math.floor((tonumber(ff.swap_used) / 1000 ^ 3) * 10) / 10
		local total = math.floor((tonumber(ff.swap_total) / 1000 ^ 3) * 10) / 10
		return used, total
	end
	local out = term_cmd("sysctl vm.swapusage")
	local total = tonumber(out:match("total = ([%d%.]+)M")) or 0
	local used = tonumber(out:match("used = ([%d%.]+)M")) or 0
	return math.floor(used), math.floor(total)
end

local function get_disk(ff)
	if ff and ff.disk_used and ff.disk_total then
		local used = math.floor(tonumber(ff.disk_used) / 1000 ^ 3 + 0.5)
		local total = math.floor(tonumber(ff.disk_total) / 1000 ^ 3 + 0.5)
		return used, total
	end
	local out = term_cmd("df -H /System/Volumes/Data | awk 'NR==2 {print $3, $2}'")
	local used, total = out:match("([%d%.]+)[GMKTB]?%s+([%d%.]+)[GMKTB]?")
	return math.floor(tonumber(used or 0) + 0.5), math.floor(tonumber(total or 1) + 0.5)
end

local function get_uptime(ff)
	if ff and ff.uptime then
		return ff.uptime:sub(1, 19):gsub("T", " "), 50
	end
	local boot_sec = term_cmd("sysctl -n kern.boottime"):match("sec%s*=%s*(%d+)")
	local boot_time = tonumber(boot_sec) or os.time()
	local boot_date = os.date("%Y-%m-%d %H:%M:%S", boot_time)
	local days = math.floor(os.difftime(os.time(), boot_time) / 86400)
	local pct = math.min(days / 14, 1) * 100
	return boot_date, pct
end

local function get_battery_capacity(ff)
	if ff and ff.battery_capacity then
		return math.floor(ff.battery_capacity + 0.5)
	end
	local out = term_cmd("pmset -g batt | grep -Eo '[0-9]+%' | head -1 | tr -d '%'")
	return tonumber(out) or 0
end

local function get_battery_status(ff)
	if ff and ff.battery_status then
		return ff.battery_status:match("Charging") or ff.battery_status:match("AC Power") or false
	end
	local out = term_cmd("pmset -g batt")
	return (out and (out:match(" charging") or out:match("AC Power"))) and true or false
end

local function battery_icon(capacity, charging)
	if charging then
		return "󰂄"
	end
	local icons = { "󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹" }
	local idx = math.min(math.floor(capacity / 10) + 1, #icons)
	return icons[idx]
end

local function get_processes(ff)
	if ff and ff.processes then
		return ff.processes
	end
	return term_cmd("ps ax | wc -l | awk '{print $1}'")
end

local function get_local_ip(ff)
	if ff and ff.local_ip then
		return ff.local_ip:match("([^/]+)")
	end
	local ip = term_cmd("ipconfig getifaddr en0")
	if ip == "" then
		ip = term_cmd("ipconfig getifaddr en1")
	end
	return ip ~= "" and ip or "N/A"
end

local function os_version()
	local name = term_cmd("sw_vers -productName")
	local ver = term_cmd("sw_vers -productVersion")
	return " " .. name .. " " .. ver
end

local function vim_version()
	local v = vim.version()
	return " " .. v.major .. "." .. v.minor .. "." .. v.patch
end

-- Build the header string (called once at startup)
local function build_header()
	local ff = fetch_stats()

	local cpu_load = get_cpu(ff)
	local ram_used, ram_total = get_ram(ff)
	local ram_pct = ram_total > 0 and (ram_used / ram_total * 100) or 0
	local swap_used, swap_total = get_swap(ff)
	local swap_pct = swap_total > 0 and (swap_used / swap_total * 100) or 0
	local disk_used, disk_total = get_disk(ff)
	local disk_pct = disk_total > 0 and (disk_used / disk_total * 100) or 0
	local uptime_date, _uptime_pct = get_uptime(ff)
	local bat_cap = get_battery_capacity(ff)
	local bat_stat = get_battery_status(ff)
	local procs = get_processes(ff)
	local ip = get_local_ip(ff)

	-- Box is 52 display cols wide. All content is ASCII or guaranteed-1-wide braille.
	-- Standard rows: │ LABEL  │ %-16s %s │ → 2+7+2+16+1+22+2 = 52  (bar=22)
	-- UPTIME row:    │ UPTIME │ %-21s  %s │ → 2+7+2+21+2+16+2 = 52  (bat_display=16)
	--   bat_display: %3d(3) + %%(1) + ascii-indicator(1) + space(1) + bar(10) = 16
	-- PROCS row:     │ PROCS  │ %-39s │    → 2+7+2+39+2 = 52
	local bat_indicator = bat_stat and "+" or " " -- ASCII, always 1 col
	local bat_display = string.format(
		"%3d%%%s %s",
		bat_cap,
		bat_indicator,
		gen_graph(bat_cap, 10)
	) -- display: 3+1+1+1+10 = 16, all ASCII/braille
	local system_info = {
		"╭────────┬─────────────────────────────────────────╮",
		string.format("│ CPU    │ %-16s %s │", cpu_load .. "%",                       gen_graph(cpu_load, 22)),
		string.format("│ RAM    │ %-16s %s │", ram_used  .. "/" .. ram_total  .. "GB", gen_graph(ram_pct,  22)),
		string.format("│ SWAP   │ %-16s %s │", swap_used .. "/" .. swap_total .. "GB", gen_graph(swap_pct, 22)),
		string.format("│ DISK   │ %-16s %s │", disk_used .. "/" .. disk_total .. "GB", gen_graph(disk_pct, 22)),
		string.format("│ UPTIME │ %-21s  %s │", uptime_date, bat_display),
		string.format("│ PROCS  │ %-39s │", procs .. "   IP: " .. ip),
		"╰────────┴─────────────────────────────────────────╯",
	}

	local ascii = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]]

	return ascii
		.. "\n\n"
		.. os_version()
		.. " | "
		.. vim_version()
		.. "\n"
		.. table.concat(system_info, "\n")
		.. "\n"
		.. os.date()
end

M.header = build_header()

return M
