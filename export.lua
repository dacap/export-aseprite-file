-- export.lua
-- Copyright (C) 2020  David Capello
--
-- This file is released under the terms of the MIT license.

local spr = app.sprite
if not spr then return print "No active sprite" end

if ColorMode.TILEMAP == nil then ColorMode.TILEMAP = 4 end
assert(ColorMode.TILEMAP == 4)

local fs = app.fs
local pc = app.pixelColor
local output_folder = fs.joinPath(app.fs.filePath(spr.filename), fs.fileTitle(spr.filename))
local image_n = 0
local tileset_n = 0

local function write_json_data(filename, data)
  local json = dofile('./json.lua')
  local file = io.open(filename, "w")
  file:write(json.encode(data))
  file:close()
end

local function fill_user_data(t, obj)
  if obj.color.alpha > 0 then
    if obj.color.alpha == 255 then
      t.color = string.format("#%02x%02x%02x",
                              obj.color.red,
                              obj.color.green,
                              obj.color.blue)
    else
      t.color = string.format("#%02x%02x%02x%02x",
                              obj.color.red,
                              obj.color.green,
                              obj.color.blue,
                              obj.color.alpha)
    end
  end
  if pcall(function() return obj.data end) then -- a tag doesn't have the data field pre-v1.3
    if obj.data and obj.data ~= "" then
      t.data = obj.data
    end
  end
end

local function export_tileset(tileset)
  local t = {}
  local grid = tileset.grid
  local size = grid.tileSize
  t.grid = { tileSize={ width=grid.tileSize.width, height=grid.tileSize.height } }
  if #tileset > 0 then
    local spec = spr.spec
    spec.width = size.width
    spec.height = size.height * #tileset
    local image = Image(spec)
    image:clear()
    for i = 0,#tileset-1 do
      local tile = tileset:getTile(i)
      image:drawImage(tile, 0, i*size.height)
    end

    tileset_n = tileset_n + 1
    local imageFn = fs.joinPath(output_folder, "tileset" .. tileset_n .. ".png")
    image:saveAs(imageFn)
    t.image = imageFn
  end
  return t
end

local function export_tilesets(tilesets)
  local t = {}
  for _,tileset in ipairs(tilesets) do
    table.insert(t, export_tileset(tileset))
  end
  return t
end

local function export_frames(frames)
  local t = {}
  for _,frame in ipairs(frames) do
    table.insert(t, { duration=frame.duration })
  end
  return t
end

local function export_cel(cel)
  local t = {
    frame=cel.frameNumber-1,
    bounds={ x=cel.bounds.x,
             y=cel.bounds.y,
             width=cel.bounds.width,
             height=cel.bounds.height }
  }

  if cel.image.colorMode == ColorMode.TILEMAP then
    local tilemap = cel.image
    -- save tilemap
    t.tilemap = { width=tilemap.width,
                  height=tilemap.height,
                  tiles={} }
    for it in tilemap:pixels() do
      table.insert(t.tilemap.tiles, pc.tileI(it()))
    end
  else
    -- save regular cel
    image_n = image_n + 1
    local imageFn = fs.joinPath(output_folder, "image" .. image_n .. ".png")
    cel.image:saveAs(imageFn)
    t.image = imageFn
  end

  fill_user_data(t, cel)
  return t
end

local function export_cels(cels)
  local t = {}
  for _,cel in ipairs(cels) do
    table.insert(t, export_cel(cel))
  end
  return t
end

local function get_tileset_index(layer)
  for i,tileset in ipairs(layer.sprite.tilesets) do
    if layer.tileset == tileset then
      return i-1
    end
  end
  return -1
end

local function export_layer(layer, export_layers)
  local t = { name=layer.name }
  if layer.isImage then
    if layer.opacity < 255 then
      t.opacity = layer.opacity
    end
    if layer.blendMode ~= BlendMode.NORMAL then
      t.blendMode = layer.blendMode
    end
    if #layer.cels >= 1 then
      t.cels = export_cels(layer.cels)
    end
    if pcall(function() return layer.isTilemap end) then
      if layer.isTilemap then
        t.tileset = get_tileset_index(layer)
      end
    end
  elseif layer.isGroup then
    t.layers = export_layers(layer.layers)
  end
  fill_user_data(t, layer)
  return t
end

local function export_layers(layers)
  local t = {}
  for _,layer in ipairs(layers) do
    table.insert(t, export_layer(layer, export_layers))
  end
  return t
end

local function ani_dir(d)
  local values = { "forward", "reverse", "pingpong" }
  return values[d+1]
end

local function export_tag(tag)
  local t = {
    name=tag.name,
    from=tag.fromFrame.frameNumber-1,
    to=tag.toFrame.frameNumber-1,
    aniDir=ani_dir(tag.aniDir)
  }
  fill_user_data(t, tag)
  return t
end

local function export_tags(tags)
  local t = {}
  for _,tag in ipairs(tags) do
    table.insert(t, export_tag(tag, export_tags))
  end
  return t
end

local function export_slice(slice)
  local t = {
    name=slice.name,
    bounds={ x=slice.bounds.x,
             y=slice.bounds.y,
             width=slice.bounds.width,
             height=slice.bounds.height }
  }
  if slice.center then
    t.center={ x=slice.center.x,
               y=slice.center.y,
               width=slice.center.width,
               height=slice.center.height }
  end
  if slice.pivot then
    t.pivot={ x=slice.pivot.x,
               y=slice.pivot.y }
  end
  fill_user_data(t, slice)
  return t
end

local function export_slices(slices)
  local t = {}
  for _,slice in ipairs(slices) do
    table.insert(t, export_slice(slice, export_slices))
  end
  return t
end

----------------------------------------------------------------------
-- Creates output folder

fs.makeDirectory(output_folder)

----------------------------------------------------------------------
-- Write /sprite.json file in the output folder

local jsonFn = fs.joinPath(output_folder, "sprite.json")
local data = {
  filename=spr.filename,
  width=spr.width,
  height=spr.height,
  frames=export_frames(spr.frames),
  layers=export_layers(spr.layers)
}
if #spr.tags > 0 then
  data.tags = export_tags(spr.tags)
end
if #spr.slices > 0 then
  data.slices = export_slices(spr.slices)
end
if pcall(function() return spr.tilesets end) then
  data.tilesets = export_tilesets(spr.tilesets)
end
write_json_data(jsonFn, data)
