# HEAVYTECH TubeGo 1.1
# Desenvolvido por Danilo - HEAVYTECH
# Versao 1.1: cor do painel corrigida, inicializacao testavel.
# Interface local Windows Forms. Necessita yt-dlp e FFmpeg instalados.
# Use somente para videos proprios ou conteudo cujo download seja autorizado.

param([switch]$SmokeTest)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

function Color-Hex([string]$hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}
function Native-Argument([string]$value) {
    # Windows command-line quoting. No cmd.exe or Invoke-Expression.
    $result = '"'
    $slashes = 0
    foreach ($c in $value.ToCharArray()) {
        if ($c -eq '\') { $slashes++; continue }
        if ($c -eq '"') {
            $result += ('\' * ($slashes * 2 + 1)) + '"'
            $slashes = 0
            continue
        }
        $result += ('\' * $slashes) + $c
        $slashes = 0
    }
    $result += ('\' * ($slashes * 2)) + '"'
    return $result
}
function Find-Tool([string]$name) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $links = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links'
    $candidate = Join-Path $links ($name + '.exe')
    if (Test-Path -LiteralPath $candidate) { return $candidate }
    return $null
}
function New-UiLabel([string]$value, [int]$x, [int]$y, [int]$w, [int]$h, [int]$size = 10, [bool]$bold = $false) {
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $value
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.Size = New-Object System.Drawing.Size($w, $h)
    $label.ForeColor = $script:fg
    $label.BackColor = [System.Drawing.Color]::Transparent
    $weight = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $label.Font = New-Object System.Drawing.Font('Segoe UI', $size, $weight)
    return $label
}
function New-UiButton([string]$label, [int]$x, [int]$y, [int]$w, [int]$h, [bool]$primary = $false) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $label
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size($w, $h)
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 0
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btn.UseVisualStyleBackColor = $false
    $btn.BackColor = if ($primary) { $script:accent } else { $script:secondary }
    $btn.ForeColor = if ($primary) { $script:bg } else { $script:fg }
    $btn.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10, [System.Drawing.FontStyle]::Bold)
    return $btn
}

$script:bg = Color-Hex '#0B1323'
$script:panelColor = Color-Hex '#142237'
$script:secondary = Color-Hex '#243550'
$script:accent = Color-Hex '#38D0F2'
$script:fg = Color-Hex '#EFF8FE'
$script:muted = Color-Hex '#B4C6DA'
$script:good = Color-Hex '#78E2AE'
$script:danger = Color-Hex '#FFB4AE'
$script:appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$script:settingsPath = Join-Path $script:appDir 'config.json'
$script:job = $null
$script:outLog = $null
$script:errLog = $null
$script:logDetails = $null
$script:cancelled = $false
$script:finalFile = $null
$script:formatIndex = 0

$ytExecutable = Find-Tool 'yt-dlp'
$ffmpegExecutable = Find-Tool 'ffmpeg'

$form = New-Object System.Windows.Forms.Form
$form.Text = 'HEAVYTECH TubeGo | Baixador de videos'
$form.ClientSize = New-Object System.Drawing.Size(760, 544)
$form.MinimumSize = New-Object System.Drawing.Size(778, 580)
$form.MaximumSize = New-Object System.Drawing.Size(778, 810)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.MaximizeBox = $false
$form.BackColor = $script:bg
$form.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$iconPath = Join-Path $script:appDir 'TubeGo.ico'
if (Test-Path -LiteralPath $iconPath) {
    try { $form.Icon = New-Object System.Drawing.Icon($iconPath) } catch {}
}

$heading = New-UiLabel 'TUBEGO' 25 16 500 45 24 $true
$heading.ForeColor = $script:accent
$form.Controls.Add($heading)
$form.Controls.Add((New-UiLabel 'HEAVYTECH  |  Baixe videos do YouTube e outros sites' 28 65 680 24 10))

$panel = New-Object System.Windows.Forms.Panel
$panel.Location = New-Object System.Drawing.Point(22, 105)
$panel.Size = New-Object System.Drawing.Size(716, 354)
$panel.BackColor = $script:panelColor
$form.Controls.Add($panel)

$panel.Controls.Add((New-UiLabel 'LINK DO VIDEO' 20 16 660 26 10 $true))
$textUrl = New-Object System.Windows.Forms.TextBox
$textUrl.Location = New-Object System.Drawing.Point(20, 46)
$textUrl.Size = New-Object System.Drawing.Size(570, 29)
$textUrl.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$panel.Controls.Add($textUrl)
$paste = New-UiButton 'Colar link' 599 43 98 34
$paste.Add_Click({
    try { if ([System.Windows.Forms.Clipboard]::ContainsText()) { $textUrl.Text = [System.Windows.Forms.Clipboard]::GetText() } }
    catch { $status.ForeColor = $script:danger; $status.Text = 'Nao foi possivel acessar a area de transferencia.' }
})
$panel.Controls.Add($paste)

$panel.Controls.Add((New-UiLabel 'FORMATO / QUALIDADE' 20 101 310 24 10 $true))
$combo = New-Object System.Windows.Forms.ComboBox
$combo.Location = New-Object System.Drawing.Point(20, 131)
$combo.Size = New-Object System.Drawing.Size(327, 28)
$combo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
[void]$combo.Items.Add('Video MP4 - ate 720p')
[void]$combo.Items.Add('Video MP4 - ate 1080p')
[void]$combo.Items.Add('Somente audio MP3')
$combo.SelectedIndex = 1
$panel.Controls.Add($combo)

$panel.Controls.Add((New-UiLabel 'SALVAR NA PASTA' 20 177 660 24 10 $true))
$textFolder = New-Object System.Windows.Forms.TextBox
$textFolder.Location = New-Object System.Drawing.Point(20, 204)
$textFolder.Size = New-Object System.Drawing.Size(570, 27)
$textFolder.Font = New-Object System.Drawing.Font('Segoe UI', 10)
$videos = [Environment]::GetFolderPath([Environment+SpecialFolder]::MyVideos)
if ([string]::IsNullOrWhiteSpace($videos)) {
    $videos = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Downloads'
}
$textFolder.Text = Join-Path $videos 'TubeGo'
try {
    if (Test-Path -LiteralPath $script:settingsPath) {
        $prefs = Get-Content -LiteralPath $script:settingsPath -Raw | ConvertFrom-Json
        if ($prefs.folder) { $textFolder.Text = [string]$prefs.folder }
        if ($null -ne $prefs.format -and [int]$prefs.format -ge 0 -and [int]$prefs.format -le 2) {
            $combo.SelectedIndex = [int]$prefs.format
        }
    }
} catch {}
$panel.Controls.Add($textFolder)
$choose = New-UiButton 'Escolher' 599 200 98 35
$choose.Add_Click({
    $picker = New-Object System.Windows.Forms.FolderBrowserDialog
    $picker.Description = 'Selecione onde salvar os videos'
    if ($picker.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $textFolder.Text = $picker.SelectedPath }
    $picker.Dispose()
})
$panel.Controls.Add($choose)

$download = New-UiButton 'BAIXAR AGORA' 20 267 230 58 $true
$panel.Controls.Add($download)
$cancel = New-UiButton 'Cancelar' 264 271 114 50
$cancel.Enabled = $false
$panel.Controls.Add($cancel)
$openDir = New-UiButton 'Abrir pasta' 392 271 141 50
$openDir.Add_Click({
    if (-not (Test-Path -LiteralPath $textFolder.Text)) {
        try { [void](New-Item -ItemType Directory -Path $textFolder.Text -Force) }
        catch { return }
    }
    Start-Process -FilePath 'explorer.exe' -ArgumentList (Native-Argument $textFolder.Text)
})
$panel.Controls.Add($openDir)
$details = New-UiButton 'Detalhes' 547 271 150 50
$panel.Controls.Add($details)

$status = New-UiLabel 'Pronto. Cole um link e clique em Baixar agora.' 24 472 711 24 10
$status.ForeColor = $script:muted
$form.Controls.Add($status)
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = New-Object System.Drawing.Point(25, 502)
$progress.Size = New-Object System.Drawing.Size(710, 12)
$progress.Minimum = 0
$progress.Maximum = 100
$progress.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$form.Controls.Add($progress)
$credit = New-UiLabel 'Desenvolvido por Danilo  •  HEAVYTECH   |   Uso autorizado de conteudo' 25 522 705 20 8
$credit.ForeColor = $script:muted
$form.Controls.Add($credit)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point(25, 558)
$logBox.Size = New-Object System.Drawing.Size(710, 177)
$logBox.Multiline = $true
$logBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
$logBox.ReadOnly = $true
$logBox.BackColor = $script:panelColor
$logBox.ForeColor = $script:muted
$logBox.Font = New-Object System.Drawing.Font('Consolas', 9)
$logBox.Visible = $false
$form.Controls.Add($logBox)
$script:expanded = $false
$details.Add_Click({
    $script:expanded = -not $script:expanded
    $logBox.Visible = $script:expanded
    $form.ClientSize = New-Object System.Drawing.Size(760, $(if ($script:expanded) { 749 } else { 544 }))
})

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 550
$timer.Add_Tick({
    if (-not $script:job) { return }
    $lines = @()
    if ($script:outLog -and (Test-Path -LiteralPath $script:outLog)) {
        $lines += @(Get-Content -LiteralPath $script:outLog -Tail 25 -ErrorAction SilentlyContinue)
    }
    if ($script:errLog -and (Test-Path -LiteralPath $script:errLog)) {
        $lines += @(Get-Content -LiteralPath $script:errLog -Tail 8 -ErrorAction SilentlyContinue)
    }
    $visibleLines = @($lines | Where-Object { $null -ne $_ })
    if ($visibleLines.Count -gt 0) {
        $logBox.Lines = [string[]]$visibleLines
        $logBox.SelectionStart = $logBox.TextLength
        $logBox.ScrollToCaret()
    }
    $percentMatches = @($lines | Select-String -Pattern '\[download\]\s+(\d+(?:[\.,]\d+)?)%')
    if ($percentMatches.Count -gt 0) {
        $last = $percentMatches[-1].Matches[0].Groups[1].Value.Replace(',', '.')
        $fraction = 0.0
        if ([double]::TryParse($last, [System.Globalization.NumberStyles]::Float, [System.Globalization.CultureInfo]::InvariantCulture, [ref]$fraction)) {
            $fraction = [Math]::Min(100, [Math]::Max(0, [int][Math]::Round($fraction)))
            $progress.Value = [int]$fraction
            if ($fraction -lt 100) { $status.Text = "Baixando... $fraction%" }
            else { $status.Text = 'Download recebido. Finalizando video/audio...' }
        }
    }
    if (-not $script:job.HasExited) { return }
    $timer.Stop()
    $script:job.WaitForExit()
    $exit = [int]$script:job.ExitCode
    $allOut = @()
    $allErr = @()
    if (Test-Path -LiteralPath $script:outLog) { $allOut = @(Get-Content -LiteralPath $script:outLog -ErrorAction SilentlyContinue) }
    if (Test-Path -LiteralPath $script:errLog) { $allErr = @(Get-Content -LiteralPath $script:errLog -ErrorAction SilentlyContinue) }
    $script:finalFile = $null
    $paths = @($allOut | Where-Object { $_ -match '^__TUBEGO_FILE__' })
    if ($paths.Count -gt 0) { $script:finalFile = $paths[-1].Substring('__TUBEGO_FILE__'.Length).Trim() }
    if ($script:logDetails) {
        @("HEAVYTECH TubeGo | status nativo: $exit", "Data: $(Get-Date -Format s)", '=== SAIDA ===') + $allOut + '=== ERROS ===' + $allErr |
            Set-Content -LiteralPath $script:logDetails -Encoding UTF8
    }
    if ($script:cancelled) {
        $status.ForeColor = $script:muted
        $status.Text = 'Download cancelado.'
        $progress.Value = 0
    }
    elseif ($exit -eq 0 -and $script:finalFile -and (Test-Path -LiteralPath $script:finalFile)) {
        $status.ForeColor = $script:good
        $status.Text = 'Concluido! Arquivo salvo. Clique em Abrir pasta.'
        $progress.Value = 100
    }
    elseif ($exit -eq 0) {
        $status.ForeColor = $script:good
        $status.Text = 'Processo finalizado. Confira o arquivo na pasta escolhida.'
        $progress.Value = 100
    }
    else {
        $status.ForeColor = $script:danger
        $status.Text = "Nao foi possivel concluir (codigo $exit). Clique em Detalhes."
    }
    $download.Enabled = $true
    $cancel.Enabled = $false
    $script:job.Dispose()
    $script:job = $null
})

$download.Add_Click({
    if ($script:job -and -not $script:job.HasExited) { return }
    if (-not $ytExecutable -or -not $ffmpegExecutable) {
        $status.ForeColor = $script:danger
        $status.Text = 'yt-dlp ou FFmpeg nao encontrado. Execute novamente o instalador TubeGo.'
        return
    }
    $uri = $null
    $url = $textUrl.Text.Trim()
    if (-not [Uri]::TryCreate($url, [UriKind]::Absolute, [ref]$uri) -or $uri.Scheme -notin @('https','http')) {
        $status.ForeColor = $script:danger
        $status.Text = 'Cole um link valido iniciado com https:// ou http://.'
        return
    }
    $directory = $textFolder.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($directory)) {
        $status.ForeColor = $script:danger
        $status.Text = 'Escolha uma pasta de destino.'
        return
    }
    try {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
        @{folder=$directory;format=$combo.SelectedIndex} | ConvertTo-Json |
            Set-Content -LiteralPath $script:settingsPath -Encoding UTF8
    } catch {
        $status.ForeColor = $script:danger
        $status.Text = 'Erro ao preparar a pasta: ' + $_.Exception.Message
        return
    }
    $args = @('--ignore-config', '--no-playlist', '--newline', '--windows-filenames',
        '--print', 'after_move:__TUBEGO_FILE__%(filepath)s',
        '--ffmpeg-location', $ffmpegExecutable,
        '-P', $directory, '-o', '%(title).160B [%(id)s].%(ext)s')
    switch ($combo.SelectedIndex) {
        0 { $args += @('-f', 'bv*[ext=mp4][height<=720]+ba[ext=m4a]/b[ext=mp4][height<=720]/bv*[height<=720]+ba/b[height<=720]', '--merge-output-format', 'mp4') }
        1 { $args += @('-f', 'bv*[ext=mp4][height<=1080]+ba[ext=m4a]/b[ext=mp4][height<=1080]/bv*[height<=1080]+ba/b[height<=1080]', '--merge-output-format', 'mp4') }
        2 { $args += @('-x', '--audio-format', 'mp3', '--audio-quality', '0') }
    }
    $args += @('--', $url)
    $id = [Guid]::NewGuid().ToString('N')
    $script:outLog = Join-Path $env:TEMP "tubego-$id-stdout.txt"
    $script:errLog = Join-Path $env:TEMP "tubego-$id-stderr.txt"
    $script:logDetails = Join-Path $env:TEMP "tubego-$id-log.txt"
    $script:cancelled = $false
    $progress.Value = 0
    $status.ForeColor = $script:accent
    $status.Text = 'Iniciando download...'
    $logBox.Clear()
    $download.Enabled = $false
    $cancel.Enabled = $true
    try {
        $arguments = ($args | ForEach-Object { Native-Argument ([string]$_) }) -join ' '
        $script:job = Start-Process -FilePath $ytExecutable -ArgumentList $arguments `
            -WorkingDirectory $directory -RedirectStandardOutput $script:outLog `
            -RedirectStandardError $script:errLog -WindowStyle Hidden -PassThru -ErrorAction Stop
        $timer.Start()
    }
    catch {
        $status.ForeColor = $script:danger
        $status.Text = 'Erro ao iniciar: ' + $_.Exception.Message
        $download.Enabled = $true
        $cancel.Enabled = $false
    }
})
$cancel.Add_Click({
    if ($script:job -and -not $script:job.HasExited) {
        $script:cancelled = $true
        try { Start-Process -FilePath 'taskkill.exe' -ArgumentList @('/PID', [string]$script:job.Id, '/T', '/F') -WindowStyle Hidden -Wait | Out-Null } catch {
            try { $script:job.Kill() } catch {}
        }
        $status.ForeColor = $script:muted
        $status.Text = 'Cancelando...'
    }
})
$form.Add_FormClosing({
    $timer.Stop()
    if ($script:job -and -not $script:job.HasExited) {
        try { Start-Process -FilePath 'taskkill.exe' -ArgumentList @('/PID',[string]$script:job.Id,'/T','/F') -WindowStyle Hidden -Wait | Out-Null } catch {
            try { $script:job.Kill() } catch {}
        }
    }
})
if ($SmokeTest) {
    if (-not $form -or -not $textUrl -or -not $download) { throw 'Interface nao inicializada.' }
    Write-Output 'TUBEGO_SMOKE_TEST_OK'
    $timer.Dispose()
    $form.Dispose()
    return
}
[void][System.Windows.Forms.Application]::Run($form)