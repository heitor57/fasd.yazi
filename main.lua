local state = ya.sync(function()
	return {
		activename = tostring(cx.tabs.idx),
	}
end)
local function fail(s, ...)
	ya.notify({
		title = "Fasd",
		content = s:format(...),
		timeout = 5,
		level = "error",
	})
end

local function entry()
	local _permit = ya.hide()
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
	_permit:drop()

	local cha = fs.cha(Url(target), true)

	if cha.is_dir then
		ya.emit("cd", { target, raw = true })
	else
		ya.emit("reveal", { target })
	end
end

return {
	entry = entry,
}
