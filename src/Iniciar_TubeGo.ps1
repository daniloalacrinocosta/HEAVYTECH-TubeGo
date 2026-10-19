# HEAVYTECH TubeGo Launcher 1.1 - Desenvolvido por Danilo
$ErrorActionPreference = 'Stop'
$appPath = Join-Path $PSScriptRoot 'TubeGo.ps1'
$logPath = Join-Path $PSScriptRoot 'erro-inicializacao.txt'
try {
    if (-not (Test-Path -LiteralPath $appPath)) { throw "Arquivo do aplicativo ausente: $appPath" }
    & $appPath
}
catch {
    $details = @("HEAVYTECH TubeGo - erro ao abrir", "Data: $(Get-Date -Format s)", "Arquivo: $appPath", '---', $_.ToString(), $_.ScriptStackTrace) -join [Environment]::NewLine
    try { $details | Set-Content -LiteralPath $logPath -Encoding UTF8 } catch {}
    try {
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("Nao foi possivel abrir o TubeGo.\n\nDetalhes salvos em:\n$logPath\n\n$($_.Exception.Message)".Replace('\n', [Environment]::NewLine), 'HEAVYTECH TubeGo', 'OK', 'Error') | Out-Null
    } catch { Write-Error $details }
}
