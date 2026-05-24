# Export current Markdown file to PDF using Pandoc and pdflatex.
# Usage: .\export_to_pdf.ps1 -MarkdownFile "huong_dan_ket_noi_mysql_vscode.md"
param(
    [string]$MarkdownFile = "huong_dan_ket_noi_mysql_vscode.md",
    [string]$OutputDir = "pdf"
)

$cwd = Split-Path -Parent $MyInvocation.MyCommand.Path
$mdPath = Join-Path $cwd $MarkdownFile
if (-not (Test-Path $mdPath)) {
    Write-Error "Input file not found: $mdPath"
    exit 1
}

$baseName = [IO.Path]::GetFileNameWithoutExtension($mdPath)
Write-Host "MarkdownFile: $MarkdownFile"
Write-Host "mdPath: $mdPath"
Write-Host "baseName: $baseName"

$outPath = Join-Path $cwd $OutputDir
New-Item -ItemType Directory -Force -Path $outPath | Out-Null
$pdfPath = Join-Path $outPath ($baseName + ".pdf")

$pandocExe = (Get-Command pandoc -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source) -as [string]
if (-not $pandocExe) {
    $candidate = Join-Path $env:LOCALAPPDATA 'Pandoc\pandoc.exe'
    if (Test-Path $candidate) {
        $pandocExe = $candidate
    }
}
if (-not $pandocExe) {
    Write-Error "pandoc executable not found in PATH or %LOCALAPPDATA%\Pandoc"
    exit 1
}

Write-Host "Using pandoc: $pandocExe"

$tempRoot = 'C:\temp\md_export'
$tempWork = Join-Path $tempRoot $baseName
if (Test-Path $tempWork) {
    Remove-Item -Recurse -Force $tempWork -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Force -Path $tempWork | Out-Null

$tempMdName = $baseName + '.md'
$tempTexName = $baseName + '.tex'
$tempPdfName = $baseName + '.pdf'
$tempMdPath = Join-Path $tempWork $tempMdName
$tempTexPath = Join-Path $tempWork $tempTexName
$tempPdfPath = Join-Path $tempWork $tempPdfName

Get-Content -LiteralPath $mdPath -Raw -Encoding UTF8 | Set-Content -LiteralPath $tempMdPath -Encoding UTF8
if (Test-Path (Join-Path $cwd 'images')) {
    Copy-Item -Path (Join-Path $cwd 'images') -Destination $tempWork -Recurse -Force
}

Write-Host "tempMdName: $tempMdName"
Write-Host "tempTexName: $tempTexName"
Write-Host "tempPdfName: $tempPdfName"

Write-Host "Preparing to run pandoc in temp workspace: $tempWork"
Push-Location $tempWork
& $pandocExe -s --listings -o $tempTexName $tempMdName
$pandocExit = $LASTEXITCODE
Pop-Location
if ($pandocExit -ne 0) {
    Write-Error "pandoc failed with exit code $pandocExit"
    exit $pandocExit
}

# Replace Pandoc-generated preamble with a clean pdflatex-friendly header
# so the .tex can be copied/compiled elsewhere without pandoc-specific bindings.
$texText = Get-Content -LiteralPath $tempTexPath -Raw -Encoding UTF8
$beginDoc = '\begin{document}'
$idx = $texText.IndexOf($beginDoc)
if ($idx -ge 0) {
    $body = $texText.Substring($idx)
}
else {
    $body = $texText
}
$body = [regex]::Replace($body, '\\pandocbounded\{(\\includegraphics(?:\[[^\]]*\])?\{[^}]+\})\}', '$1')
$body = [regex]::Replace($body, '\\includegraphics\[([^\]]*?)\s*,\s*alt=\{[^\}]*\}([^\]]*?)\]', '\includegraphics[$1$2]')
$body = [regex]::Replace($body, '\\begin\{figure\}', '\begin{figure}[H]')
$header = @"
\documentclass[11pt,a4paper]{article}

\usepackage[utf8]{vietnam}
\usepackage{amsmath,amssymb}
\usepackage{graphicx}
\usepackage{float}
\setkeys{Gin}{width=\linewidth,height=0.9\textheight,keepaspectratio}
\usepackage[margin=0.75in]{geometry}
\usepackage{xcolor}
\usepackage{array,longtable,booktabs,multirow}
\usepackage{enumitem}
\usepackage{listings}
\usepackage{hyperref}
\usepackage{fancyhdr}

\pagestyle{fancy}
\fancyhf{}
\fancyfoot[C]{Page \thepage}

\providecommand{\tightlist}{%
    \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
\providecommand{\passthrough}[1]{#1}

\lstdefinelanguage{SQL}{
    keywords={SELECT,FROM,WHERE,JOIN,LEFT,RIGHT,INNER,OUTER,ON,GROUP,BY,ORDER,ASC,DESC,COUNT,AVG,MAX,MIN,SUM,AS,AND,OR,NOT,NULL,IS,EXISTS,WITH,RANK,OVER,PARTITION,CASE,WHEN,THEN,ELSE,END,CREATE,TABLE,PRIMARY,KEY,FOREIGN,REFERENCES,INSERT,INTO,VALUES,UPDATE,DELETE,HAVING,DISTINCT},
    sensitive=false,
    comment=[l]{--},
    morecomment=[s]{/*}{*/},
    morestring=[b]',
    morestring=[b]"
}

\lstset{
    basicstyle=\ttfamily\small,
    keywordstyle=\color{blue}\bfseries,
    commentstyle=\color{gray},
    stringstyle=\color{red!70!black},
    showstringspaces=false,
    columns=fullflexible,
    frame=single,
    breaklines=true,
    tabsize=2,
    postbreak=\mbox{\textcolor{red}{$\hookrightarrow$}\space}
}

"@

$newTex = $header + "`r`n" + $body
Set-Content -LiteralPath $tempTexPath -Value $newTex -Encoding UTF8

$pdflatexExe = 'C:\Program Files\MiKTeX\miktex\bin\x64\pdflatex.exe'
if (-not (Test-Path $pdflatexExe)) {
    $pdflatexExe = (Get-Command pdflatex -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty Source) -as [string]
}
if (-not $pdflatexExe) {
    Write-Error "pdflatex executable not found"
    exit 1
}

Write-Host "Compiling LaTeX with: $pdflatexExe"
$latexArgs = @('-interaction=nonstopmode', '-halt-on-error', $tempTexName)
Push-Location $tempWork
& $pdflatexExe @latexArgs
$latexExit = $LASTEXITCODE
if ($latexExit -eq 0) {
    & $pdflatexExe @latexArgs
    $latexExit = $LASTEXITCODE
}
Pop-Location
if ($latexExit -ne 0) {
    Write-Error "pdflatex failed with exit code $latexExit"
    exit $latexExit
}

if (Test-Path $tempTexPath) {
    Copy-Item -Path $tempTexPath -Destination (Join-Path $outPath $tempTexName) -Force
}
if (Test-Path $tempPdfPath) {
    Copy-Item -Path $tempPdfPath -Destination $pdfPath -Force
}

if (Test-Path $pdfPath) {
    Write-Host "PDF created: $pdfPath"
}
else {
    Write-Error "PDF not created. Check Pandoc and PDF engine availability."
}
