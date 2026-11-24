# Generates the Kedai Ummi launcher icon from simple vector shapes.
# Uses only .NET System.Drawing, so no extra Flutter packages are needed.
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$brandDir = Join-Path $root 'assets/images/brand'
$androidRes = Join-Path $root 'android/app/src/main/res'
$iosIcons = Join-Path $root 'ios/Runner/Assets.xcassets/AppIcon.appiconset'

New-Item -ItemType Directory -Force -Path $brandDir | Out-Null

$size = 1024
$bitmap = New-Object System.Drawing.Bitmap $size, $size
$g = [System.Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

$espresso = [System.Drawing.Color]::FromArgb(255, 43, 30, 22)
$terracotta = [System.Drawing.Color]::FromArgb(255, 190, 91, 55)
$gold = [System.Drawing.Color]::FromArgb(255, 198, 160, 91)
$goldSoft = [System.Drawing.Color]::FromArgb(255, 255, 230, 168)
$cream = [System.Drawing.Color]::FromArgb(255, 255, 247, 232)

# Warm gradient background.
$bgRect = New-Object System.Drawing.Rectangle 0, 0, $size, $size
$bgBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  $bgRect,
  $espresso,
  $terracotta,
  45
)
$g.FillRectangle($bgBrush, $bgRect)

# Soft golden halo behind the emblem.
for ($i = 8; $i -ge 1; $i--) {
  $radius = 120 + $i * 42
  $alpha = 10
  $haloBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($alpha, 255, 214, 140))
  $g.FillEllipse(
    $haloBrush,
    (512 - $radius),
    (486 - $radius),
    ($radius * 2),
    ($radius * 2)
  )
  $haloBrush.Dispose()
}

# Cream plate.
$plateBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle 232, 232, 560, 560),
  $cream,
  [System.Drawing.Color]::FromArgb(255, 236, 214, 178),
  90
)
$g.FillEllipse($plateBrush, 232, 232, 560, 560)

# Thin gold ring on the plate.
$ringPen = New-Object System.Drawing.Pen($gold, 8)
$g.DrawEllipse($ringPen, 266, 266, 492, 492)

# Bowl / subtle U monogram.
$bowlBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
  (New-Object System.Drawing.Rectangle 342, 390, 340, 340),
  $goldSoft,
  $cream,
  90
)
$bowlPen = New-Object System.Drawing.Pen($bowlBrush, 76)
$bowlPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$bowlPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawArc($bowlPen, 342, 390, 340, 340, 8, 164)

# Steam wisps.
$steamPen = New-Object System.Drawing.Pen($gold, 17)
$steamPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$steamPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$g.DrawBezier($steamPen, 446, 452, 418, 404, 474, 382, 448, 330)
$g.DrawBezier($steamPen, 512, 436, 486, 382, 540, 360, 514, 300)
$g.DrawBezier($steamPen, 578, 452, 550, 404, 606, 382, 580, 330)

# Gold sparkle.
$sparkle = New-Object System.Drawing.Drawing2D.GraphicsPath
$sparkle.AddPolygon([System.Drawing.Point[]]@(
  (New-Object System.Drawing.Point 768, 272),
  (New-Object System.Drawing.Point 786, 318),
  (New-Object System.Drawing.Point 832, 336),
  (New-Object System.Drawing.Point 786, 354),
  (New-Object System.Drawing.Point 768, 400),
  (New-Object System.Drawing.Point 750, 354),
  (New-Object System.Drawing.Point 704, 336),
  (New-Object System.Drawing.Point 750, 318)
))
$g.FillPath((New-Object System.Drawing.SolidBrush($goldSoft)), $sparkle)

$source = Join-Path $brandDir 'logo.png'
$bitmap.Save($source, [System.Drawing.Imaging.ImageFormat]::Png)

function Save-Resized([string]$path, [int]$target) {
  $out = New-Object System.Drawing.Bitmap $target, $target
  $og = [System.Drawing.Graphics]::FromImage($out)
  $og.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $og.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $og.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $og.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $og.DrawImage(
    $bitmap,
    (New-Object System.Drawing.Rectangle 0, 0, $target, $target),
    0, 0, $size, $size,
    [System.Drawing.GraphicsUnit]::Pixel
  )
  $og.Dispose()
  $out.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $out.Dispose()
}

# Android legacy launcher icons.
$androidSizes = @{
  'mipmap-mdpi' = 48
  'mipmap-hdpi' = 72
  'mipmap-xhdpi' = 96
  'mipmap-xxhdpi' = 144
  'mipmap-xxxhdpi' = 192
}
foreach ($folder in $androidSizes.Keys) {
  $dir = Join-Path $androidRes $folder
  New-Item -ItemType Directory -Force -Path $dir | Out-Null
  Save-Resized (Join-Path $dir 'ic_launcher.png') $androidSizes[$folder]
}

# iOS app icons.
$iosSizes = @{
  'Icon-App-20x20@1x.png' = 20
  'Icon-App-20x20@2x.png' = 40
  'Icon-App-20x20@3x.png' = 60
  'Icon-App-29x29@1x.png' = 29
  'Icon-App-29x29@2x.png' = 58
  'Icon-App-29x29@3x.png' = 87
  'Icon-App-40x40@1x.png' = 40
  'Icon-App-40x40@2x.png' = 80
  'Icon-App-40x40@3x.png' = 120
  'Icon-App-60x60@2x.png' = 120
  'Icon-App-60x60@3x.png' = 180
  'Icon-App-76x76@1x.png' = 76
  'Icon-App-76x76@2x.png' = 152
  'Icon-App-83.5x83.5@2x.png' = 167
  'Icon-App-1024x1024@1x.png' = 1024
}
foreach ($name in $iosSizes.Keys) {
  Save-Resized (Join-Path $iosIcons $name) $iosSizes[$name]
}

$g.Dispose()
$bgBrush.Dispose()
$plateBrush.Dispose()
$ringPen.Dispose()
$bowlPen.Dispose()
$steamPen.Dispose()
$bitmap.Dispose()

Write-Host "Logo generated: $source"
Write-Host "Android + iOS launcher icons updated."
