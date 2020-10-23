# export-aseprite-file

> by David Capello

This is a script that can be used to export the data from a
`.aseprite` file into a JSON + a collection of PNG files.  This works
with Aseprite v1.2.25 and support the future v1.3 to export
tilemap/tileset data.

## Example

Usage:

    aseprite -b map.aseprite -script export.lua

In this example `export.lua` will create a folder named `map` with
some files inside:

```
map/
  sprite.json
  image1.png
  image2.png
  tileset1.png
```

An example of `map/sprite.json` content:

```json
{
  "filename": "map.aseprite",
  "width": 32,
  "height": 32,
  "frames": [
    { "duration": 0.1 },
    { "duration": 0.15 }
  ],
  "layers": [
    {
      "name": "Group Layer",
      "layers": [
        {
          "name": "Common Layer",
          "cels": [
            {
              "bounds": { "x": 10, "y": 13, "width": 12, "height": 13 },
              "frame": 0,
              "image": "map/image1.png"
            },
            {
              "bounds": { "x": 6, "y": 15, "width": 12, "height": 12 },
              "frame": 1,
              "image": "map/image2.png"
            }
          ]
        }
      ]
    },
    {
      "name": "Tilemap Layer",
      "tileset": 0,
      "cels": [
        {
          "bounds": { "x": 0, "y": 0, "width": 32, "height": 32 },
          "data": "text1",
          "frame": 0,
          "tilemap": {
            "width": 4,
            "height": 4,
            "tiles": [
              0, 1, 2, 3,
              4, 5, 5, 6,
              7, 5, 5, 8,
              9, 10, 11, 12
            ]
          }
        },
        {
          "bounds": { "x": 1, "y": 1, "width": 32, "height": 32 },
          "frame": 1,
          "color": "#f7a547",
          "data": "text2",
          "tilemap": {
            "width": 4,
            "height": 4,
            "tiles": [
              0, 1, 1, 3,
              4, 4, 4, 8,
              4, 4, 4, 8,
              9, 10, 10, 12
            ]
          }
        }
      ]
    }
  ],
  "tilesets": [
    {
      "grid": {
        "tileSize": { "width": 8, "height": 8 }
      },
      "image": "map/tileset1.png"
    }
  ],
  "tags": [
    {
      "name": "Tag A",
      "aniDir": "pingpong",
      "color": "#000000",
      "from": 0,
      "to": 2
    },
    {
      "name": "Tag B",
      "aniDir": "forward",
      "color": "#000000",
      "from": 0,
      "to": 1
    },
    {
      "name": "Tag C",
      "aniDir": "reverse",
      "color": "#000000",
      "from": 1,
      "to": 2
    }
  ],
  "slices": [
    {
      "name": "Slice 1",
      "color": "#0000ff",
      "bounds": { "x": 4, "y": 19, "width": 8, "height": 6 }
    },
    {
      "name": "Slice 2",
      "color": "#0000ff",
      "bounds": { "x": 14, "y": 9, "width": 9, "height": 11 },
      "center": { "x": 1, "y": 1, "width": 7, "height": 9 }
    },
    {
      "name": "Slice 3",
      "color": "#0000ff",
      "data": "text3",
      "bounds": { "x": 17, "y": 23, "width": 8, "height": 7 },
      "pivot": { "x": 4, "y": 2 }
    }
  ]
}
```

## Acknowledges

This project uses [json.lua](https://github.com/rxi/json.lua) by
[rxi](https://github.com/rxi) to export Lua tables to JSON files.

## License

This code is distributed under the terms of the MIT license. You can
use this code for your own purpose to export the specific data that
you need.
