local state = ya.sync(function(st)
	return {
		cwd = tostring(cx.active.current.cwd),
		empty = st.empty,
	}
end)

local set_state = ya.sync(function(st, empty)
	st.empty = empty
end)

local function fail(s, ...)
	ya.notify({
		title = "Fasd",
		content = s:format(...),
		timeout = 5,
		level = "error",
	})
end

-- Check if fasd database has any entries
local function empty()
	local child = Command("fasd"):arg({ "-l" }):stdout(Command.PIPED):spawn()

	if not child then
		return true
	end

	local first = child:read_line()
	child:start_kill()
	return not first
end

-- fasd -A "$PWD" on directory change
local function setup(_, opts)
	opts = opts or {}

	ps.sub("cd", function()
		local cwd = tostring(cx.active.current.cwd)
		ya.emit("shell", {
			cwd = fs.cwd(),
			orphan = true,
			"fasd -A " .. ya.quote(cwd),
		})
	end)
	-- ps.sub("open", function()
	-- 	local hovered = cx.active.current.hovered
	-- 	if not hovered then
	-- 		return
	-- 	end
	--
	-- 	local path = tostring(hovered.url)
	-- 	ya.emit("shell", {
	-- 		cwd = fs.cwd(),
	-- 		orphan = true,
	-- 		"fasd -A " .. ya.quote(path),
	-- 	})
	-- end)
end

-- fzf-based jump
local function entry()
	local st = state()
	if st.empty == nil then
		st.empty = empty()
		set_state(st.empty)
	end

	if st.empty then
		return fail("No Fasd entries found. Visit some folders first to build your history.")
	end

	local _permit = ui.hide()
	local cmd = [[fasd -t | sort -k1 -g | fzf --no-sort -e --tac | grep '/.*' -o]]

	local child, err1 = Command("sh"):arg({ "-c", cmd }):stdout(Command.PIPED):stderr(Command.PIPED):spawn()

	if not child then
		return fail("Failed to start fasd command: %s", err1)
	end

	local output, err2 = child:wait_with_output()
	if not output then
		return fail("Cannot read fasd output: %s", err2)
	elseif not output.status.success and output.status.code ~= 130 then
		return fail("Fasd exited with code %s: %s", output.status.code, output.stderr)
	end

	local target = output.stdout:gsub("\n$", "")
	if target == "" then
		return
	end

	local target_stat = fs.cha(target)
	if not target_stat then
		return fail("Path not found: %s", target)
	end

	if target_stat.is_dir then
		ya.emit("cd", { target, raw = true })
	elseif target_stat.is_file then
		ya.emit("select", { target })
	else
		fail("Invalid Fasd target: %s", target)
	end
end

return {
	setup = setup,
	entry = entry,
}
