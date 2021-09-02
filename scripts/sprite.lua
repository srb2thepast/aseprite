-- Copyright (C) 2019-2021  Igara Studio S.A.
-- Copyright (C) 2018  David Capello
--
-- This file is released under the terms of the MIT license.
-- Read LICENSE.txt for more information.

do
  local a = Sprite(32, 64)
  assert(a.width == 32)
  assert(a.height == 64)
  assert(a.colorMode == ColorMode.RGB) -- RGB by default
  assert(a.bounds == Rectangle{x=0, y=0, width=32, height=64})

  -- Crop and resize
  a.selection:select(2, 3, 4, 5)
  a:crop()
  assert(a.width == 4)
  assert(a.height == 5)
  assert(a.cels[1].image.width == 32)
  assert(a.cels[1].image.height == 64)
  a:resize(6, 8)
  assert(a.width == 6)
  assert(a.height == 8)
  assert(a.cels[1].image.width == 32 * 6 / 4) -- Check that the image was resized (not only the canvas)
  assert(a.cels[1].image.height == 64 * 8 / 5)
  a:crop{x=-1, y=-1, width=20, height=30}
  assert(a.width == 20)
  assert(a.height == 30)

  -- Resize sprite setting width/height (just changing canvas size)
  a.width = 8
  a.height = 10
  assert(a.width == 8)
  assert(a.height == 10)

  -- Test other Sprite() constructors
  local b = Sprite(4, 8, ColorMode.INDEXED)
  assert(b.width == 4)
  assert(b.height == 8)
  assert(b.colorMode == ColorMode.INDEXED)

  local c = Sprite{ colorMode=ColorMode.INDEXED, width=10, height=20 }
  assert(c.width == 10)
  assert(c.height == 20)
  assert(c.colorMode == ColorMode.INDEXED)

  local d = Sprite{ fromFile="sprites/abcd.aseprite" }
  assert(#d.layers == 4)
  assert(d.width == 32)
  assert(d.height == 32)
  assert(d.colorMode == ColorMode.INDEXED)
end

-- Transparent color

do
  local a = Sprite(32, 32, ColorMode.INDEXED)
  assert(a.transparentColor == 0)
  a.transparentColor = 8
  assert(a.transparentColor == 8)
end

-- Palette

do
  local a = Sprite(32, 32, ColorMode.INDEXED)
  assert(#a.palettes == 1)
  assert(#a.palettes[1] == 256)

  local p = Palette(3)
  p:setColor(0, Color(255, 0, 0))
  p:setColor(1, Color(0, 255, 0))
  p:setColor(2, Color(0, 0, 255))
  a:setPalette(p)

  assert(#a.palettes == 1)
  assert(#a.palettes[1] == 3)
  assert(a.palettes[1]:getColor(0) == Color(255, 0, 0))
  assert(a.palettes[1]:getColor(1) == Color(0, 255, 0))
  assert(a.palettes[1]:getColor(2) == Color(0, 0, 255))
end

-- Duplicate & Flatten

do
  local a = Sprite(32, 32)
  a:newLayer()
  a:newLayer()
  assert(#a.layers == 3)

  local b = Sprite(a)           -- Clone a
  a:flatten()                   -- Flatten a
  assert(#a.layers == 1)
  assert(#b.layers == 3)
end

-- Resize non-active sprite
do
  local a = Sprite(32, 32)
  local b = Sprite(64, 64)
  app.activeSprite = a
  a:resize(10, 10)
  b:resize(20, 20)
  assert(a.width == 10)
  assert(a.height == 10)
  assert(b.width == 20)
  assert(b.height == 20)
  app.undo()
  assert(a.width == 32)
  assert(a.height == 32)
  app.activeSprite = b
  app.undo()
  assert(b.width == 64)
  assert(b.height == 64)
end

-- Grid bounds
do
  local s = Sprite(32, 32)
  assert(s.gridBounds == Rectangle{0, 0, 16, 16})
  s.gridBounds = Rectangle{2, 3, 8, 4}
  assert(s.gridBounds == Rectangle{2, 3, 8, 4})
  s:saveAs("_test_sprite_gridbounds.aseprite")

  local s2 = Sprite{ fromFile="_test_sprite_gridbounds.aseprite" }
  assert(s2.gridBounds == Rectangle{2, 3, 8, 4})
end

-- Pixel ratio
do
  local s = Sprite(32, 32)
  assert(s.pixelRatio == Size{1, 1})
  s.pixelRatio = Size{3, 2}
  assert(s.pixelRatio == Size{3, 2})
  s:saveAs("_test_sprite_pixelratio.aseprite")

  local s2 = Sprite{ fromFile="_test_sprite_pixelratio.aseprite" }
  assert(s2.pixelRatio == Size{3, 2})
end

-- Sprite{ fromFile, oneFrame }
do
  local s = Sprite(32, 32)
  s:newFrame()
  s:saveAs("_test1.png")
  assert(#s.frames == 2)

  s = Sprite{ fromFile="_test1.png" }
  assert(#s.frames == 2)

  s = Sprite{ fromFile="_test1.png", oneFrame=true }
  assert(#s.frames == 1)

  s = Sprite{ fromFile="_test1.png", oneFrame=false }
  assert(#s.frames == 2)
end
