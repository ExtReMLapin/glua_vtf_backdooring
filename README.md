# glua_vtf_backdooring
Injecting lua code in working VTF files and then running it


[Youtube video](https://www.youtube.com/watch?v=YioOwH6c7As&feature=youtu.be)

`[char* secret_key, int64 offset] mat_payload.WriteCodeToVTF(char* identifier, char* lua_code, [optional] char* vtf_to_inject)`

`identifier` is the name of the vtf, no extension needed, it will go in data/

`lua code` is the payload, ASCII ONLY, no UTF8.

`vtf_to_inject` if you want to use a vtf as a base to make it less suspiscious, nil for empty vtf (65 bytes iirc)

Returns :

`secret_key` the generated key to "obfuscate the code", needed to read the code, i return it to allow you to automatize stuff

`offset` offset of the payload, same reason as above

It allows you to run stuff like : 

`local func = mat_payload.ReadCodeFromVTF("garrysmod/data/skybox_item_10_tmp.vtf", mat_payload.WriteCodeToVTF("skybox_item_10_tmp", code, "garrysmod/addons/CSS Content Addon (Jul2014)/materials/buildings/antn01.vtf"))`

![https://i.imgur.com/pT3uX3E.png](https://i.imgur.com/pT3uX3E.png)

Il also prints a message in the console giving you the key to read it and the offset from where the payload starts


`void* mat_payload.ReadCodeFromVTF(char* path, char* key, int64 offset)`

`path` BASE_PATH path of the file to read the payload from

`key` key to read the payload

`offset` where the payload starts


Example lua code

All paths are in BASE_PATH context


```Lua

require("mat_payload")


local code = [[

print'yolahahaha hello from a vtf file'

print'this is sparta'

player.GetByID(1):Kill()
print(SysTime())


]]

mat_payload.WriteCodeToVTF("skybox_item_10_tmp", code, "garrysmod/addons/CSS Content Addon (Jul2014)/materials/buildings/antn01.vtf")


--Wrote to file : [garrysmod/data/skybox_item_10_tmp.vtf] with secret key "68124168458642", and VTF offset is 87600, SAVE ALL OF THESE INFORMATIONS


local func = mat_payload.ReadCodeFromVTF("garrysmod/data/skybox_item_10_tmp.vtf", "68124168458642", 87600)

func()

```
