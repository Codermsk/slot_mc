local REP = "https://raw.githubusercontent.com/Codermsk/slot_mc/master"

local shell = require("shell")
shell.execute("wget -fq " .. REP .. "/launcher.lua /home/1.lua")
shell.execute("wget -fq " .. REP .. "/libs/casino.lua /lib/casino.lua")
shell.execute("wget -fq " .. REP .. "/config/games.lua /lib/games.lua")
shell.execute("wget -fq " .. REP .. "/config/settings.lua /lib/settings.lua")

shell.execute("edit /lib/settings.lua")
