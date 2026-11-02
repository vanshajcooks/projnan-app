Add-Type -AssemblyName System.Drawing

function Generate-ProbonIcon {
    param([int]$size, [string]$outPath)

    $bmp = New-Object System.Drawing.Bitmap $size, $size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # Outer squircle
    $rect = [System.Drawing.Rectangle]::new(0, 0, $size, $size)
    $bgBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect,
        [System.Drawing.ColorTranslator]::FromHtml("#161822"),
        [System.Drawing.ColorTranslator]::FromHtml("#08090D"),
        [System.Drawing.Drawing2D.LinearGradientMode]::ForwardDiagonal
    )

    $radius = [int]($size * 0.22)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $radius * 2
    $path.AddArc(0, 0, $diameter, $diameter, 180, 90)
    $path.AddArc($size - $diameter, 0, $diameter, $diameter, 270, 90)
    $path.AddArc($size - $diameter, $size - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc(0, $size - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()

    $g.FillPath($bgBrush, $path)

    # Accent border
    $pen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml("#7C3AED"), [float]($size * 0.035))
    $g.DrawPath($pen, $path)

    # Stylized "P" monogram
    $fontSize = [float]($size * 0.52)
    $font = [System.Drawing.Font]::new("Arial", $fontSize, [System.Drawing.FontStyle]::Bold)
    $sf = [System.Drawing.StringFormat]::new()
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center

    $shadowBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(120, 124, 58, 237))
    $shadowRect = [System.Drawing.RectangleF]::new(0.0, [float]($size * 0.03), [float]$size, [float]$size)
    $g.DrawString("P", $font, $shadowBrush, $shadowRect, $sf)

    $textBrush = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
        $rect,
        [System.Drawing.ColorTranslator]::FromHtml("#C4B5FD"),
        [System.Drawing.ColorTranslator]::FromHtml("#7C3AED"),
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
    )
    $textRect = [System.Drawing.RectangleF]::new(0.0, 0.0, [float]$size, [float]$size)
    $g.DrawString("P", $font, $textBrush, $textRect, $sf)

    $g.Dispose()

    $dir = [System.IO.Path]::GetDirectoryName($outPath)
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Generated: $outPath ($size x $size)"
}

$base = "C:\Projects\Probon App\android\app\src\main\res"
Generate-ProbonIcon -size 48  -outPath "$base\mipmap-mdpi\ic_launcher.png"
Generate-ProbonIcon -size 72  -outPath "$base\mipmap-hdpi\ic_launcher.png"
Generate-ProbonIcon -size 96  -outPath "$base\mipmap-xhdpi\ic_launcher.png"
Generate-ProbonIcon -size 144 -outPath "$base\mipmap-xxhdpi\ic_launcher.png"
Generate-ProbonIcon -size 192 -outPath "$base\mipmap-xxxhdpi\ic_launcher.png"
Generate-ProbonIcon -size 512 -outPath "C:\Projects\Probon App\assets\icon\app_icon.png"
