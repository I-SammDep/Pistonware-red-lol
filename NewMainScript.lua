--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.
local errorPopupShown = false
local setidentity = syn and syn.set_thread_identity or set_thread_identity or setidentity or setthreadidentity or function() end
local getidentity = syn and syn.get_thread_identity or get_thread_identity or getidentity or getthreadidentity or function() return 8 end
local isfile = isfile or function(file)
	local suc, res = pcall(function() return readfile(file) end)
	return suc and res ~= nil
end
local delfile = delfile or function(file) writefile(file, "") end

local function displayErrorPopup(text, func)
	local oldidentity = getidentity()
	setidentity(8)
	local ErrorPrompt = getrenv().require(game:GetService("CoreGui").RobloxGui.Modules.ErrorPrompt)
	local prompt = ErrorPrompt.new("Default")
	prompt._hideErrorCode = true
	local gui = Instance.new("ScreenGui", game:GetService("CoreGui"))
	prompt:setErrorTitle("Vape")
	prompt:updateButtons({{
		Text = "OK",
		Callback = function() 
			prompt:_close() 
			if func then func() end
		end,
		Primary = true
	}}, 'Default')
	prompt:setParent(gui)
	prompt:_open(text)
	setidentity(oldidentity)
end

local function vapeGithubRequest(scripturl)
	if not isfile("vape/"..scripturl) then
		local suc, res
		task.delay(15, function()
			if not res and not errorPopupShown then 
				errorPopupShown = true
				displayErrorPopup("The connection to github is taking a while, Please be patient.")
			end
		end)
		suc, res = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/I-SammDep/Pistonware-red-lol/"..readfile("vape/commithash.txt").."/"..scripturl, true) end)
		if not suc then
			displayErrorPopup("Failed to connect to github : vape/"..scripturl.." : "..res)
			error(res)
		end
		writefile("vape/"..scripturl, res)
	end
	return readfile("vape/"..scripturl)
end

if not shared.VapeDeveloper then 
	local commit = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://api.github.com/repos/I-SammDep/Pistonware-red-lol/commits", true))[1].commit.url:split("/commits/")[2]
	if isfolder("vape") then 
		if ((not isfile("commithash.txt")) or readfile("commithash.txt") ~= commit) then
			for i,v in pairs({"Universal.lua", "MainScript.lua", "GuiLibrary.lua"}) do 
				if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
					delfile(v)
				end 
			end
			if isfolder("CustomModules") then 
				for i,v in pairs(listfiles("CustomModules")) do 
					if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
						delfile(v)
					end 
				end
			end
			if isfolder("Libraries") then 
				for i,v in pairs(listfiles("Libraries")) do 
					if isfile(v) and readfile(v):find("--This watermark is used to delete the file if its cached, remove it to make the file persist after commits.") then
						delfile(v)
					end 
				end
			end
			writefile("commithash.txt", commit)
		end
	else
		makefolder("vape")
		writefile("commithash.txt", commit)
	end
end

loadstring(vapeGithubRequest("MainScript.lua"))()