#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$SkillsPath
)

$ErrorActionPreference = 'Stop'

if (-not $SkillsPath) {
    $scriptDir = $PSScriptRoot
    if (-not $scriptDir) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    $SkillsPath = Join-Path (Split-Path -Parent $scriptDir) '.opencode/skills'
}

if (-not (Test-Path -LiteralPath $SkillsPath)) {
    Write-Host "ERROR: no existe la ruta de skills: $SkillsPath" -ForegroundColor Red
    exit 1
}

$files = @(Get-ChildItem -LiteralPath $SkillsPath -Recurse -File -Filter 'SKILL.md' | Sort-Object FullName)
if ($files.Count -eq 0) {
    Write-Host "ERROR: no se encontro ningun SKILL.md en $SkillsPath" -ForegroundColor Red
    exit 1
}

$results = New-Object System.Collections.Generic.List[object]
$failures = New-Object System.Collections.Generic.List[string]

foreach ($file in $files) {
    $skillId = $file.Directory.Name
    $errors = New-Object System.Collections.Generic.List[string]

    $text = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)
    if ($text.Length -gt 0 -and $text[0] -eq [char]0xFEFF) {
        $text = $text.Substring(1)
    }
    $lines = $text -split "\r?\n"

    if ($lines.Count -lt 3 -or $lines[0].Trim() -ne '---') {
        $errors.Add('no empieza con --- en la linea 1')
    }
    else {
        $closing = -1
        for ($i = 1; $i -lt $lines.Count; $i++) {
            if ($lines[$i].Trim() -eq '---') {
                $closing = $i
                break
            }
        }

        if ($closing -lt 0) {
            $errors.Add('no tiene --- de cierre')
        }
        else {
            $front = @{}
            $currentKey = $null

            for ($i = 1; $i -lt $closing; $i++) {
                $line = $lines[$i]

                if ($line.Trim() -eq '' -or $line -match '^\s*#') {
                    continue
                }
                if ($line -match "`t") {
                    $errors.Add("tabulador en frontmatter, linea $($i + 1)")
                }

                if ($line -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
                    $currentKey = $Matches[1]
                    $value = $Matches[2].Trim()
                    if ($value -in @('>', '|', '>-', '|-')) {
                        $value = ''
                    }
                    $front[$currentKey] = $value
                }
                elseif ($line -match '^\s+(.+)$' -and $null -ne $currentKey) {
                    $front[$currentKey] = ($front[$currentKey] + ' ' + $Matches[1].Trim()).Trim()
                }
                else {
                    $errors.Add("frontmatter invalido, linea $($i + 1): $line")
                }
            }

            foreach ($required in @('name', 'description')) {
                if (-not $front.ContainsKey($required) -or [string]::IsNullOrWhiteSpace($front[$required])) {
                    $errors.Add("falta el campo '$required'")
                }
            }

            if ($front.ContainsKey('name')) {
                $name = $front['name'].Trim().Trim('"').Trim("'")
                if ($name -ne $skillId) {
                    $errors.Add("name '$name' no coincide con la carpeta '$skillId'")
                }
            }

            $body = ''
            if ($closing + 1 -lt $lines.Count) {
                $body = ($lines[($closing + 1)..($lines.Count - 1)] -join "`n").Trim()
            }
            if ([string]::IsNullOrWhiteSpace($body)) {
                $errors.Add('no tiene contenido despues del frontmatter')
            }
        }
    }

    $status = if ($errors.Count -eq 0) { 'OK' } else { 'ERROR' }
    $nameValue = if ($front -and $front.ContainsKey('name')) { $front['name'].Trim('"').Trim("'") } else { '' }

    $results.Add([pscustomobject]@{
        Skill  = $skillId
        Name   = $nameValue
        Estado = $status
        Errores = ($errors -join '; ')
    })

    if ($errors.Count -gt 0) {
        $failures.Add("$skillId -> $($errors -join '; ')")
    }
}

$results | Format-Table -AutoSize

if ($failures.Count -gt 0) {
    Write-Host "`n$($failures.Count) skill(s) con errores:" -ForegroundColor Red
    foreach ($failure in $failures) {
        Write-Host " - $failure" -ForegroundColor Red
    }
    exit 1
}

Write-Host "`n$($results.Count) skill(s) validados correctamente." -ForegroundColor Green
exit 0
