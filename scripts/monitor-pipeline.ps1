# scripts/monitor-pipeline.ps1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Clear-Host

$intervalSeconds = 5
$repoRoot = $PSScriptRoot | Split-Path -Parent
Set-Location $repoRoot

while ($true) {
    Clear-Host
    $now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "================================================================================" -ForegroundColor Cyan
    Write-Host " 🚀 MONITOR DE PIPELINE DESATENDIDO — ALTARDIARIO ($now)" -ForegroundColor Cyan
    Write-Host "================================================================================" -ForegroundColor Cyan

    # 1. ESTADO DE GIT Y TRUNK (MAIN)
    Write-Host "`n📌 1. ESTADO DE GIT (MAIN LOCAL vs REMOTO):" -ForegroundColor Yellow
    try {
        $head = git rev-parse --short HEAD
        $mainLocal = git rev-parse --short main 2>$null
        $originMain = git rev-parse --short origin/main 2>$null
        Write-Host "   • HEAD actual:   $head"
        Write-Host "   • main (local):  $mainLocal"
        Write-Host "   • origin/main:   $originMain"
        
        $lastCommit = git log -1 --pretty=format:"%h - %an: %s (%cr)" main 2>$null
        Write-Host "   • Último merge:  $lastCommit" -ForegroundColor DarkGray
    } catch {
        Write-Host "   ⚠️ Error consultando Git" -ForegroundColor Red
    }

    # 2. PROGRESO GLOBAL DEL ROADMAP (roadmap/tasks.yaml)
    Write-Host "`n📊 2. MÉTRICAS ROADMAP (roadmap/tasks.yaml):" -ForegroundColor Yellow
    $tasksPath = Join-Path $repoRoot "roadmap\tasks.yaml"
    if (Test-Path $tasksPath) {
        $tasksContent = Get-Content $tasksPath -Raw
        $total = ([regex]::Matches($tasksContent, "- id:")).Count
        $done = ([regex]::Matches($tasksContent, "status:\s*done")).Count
        $inProgress = ([regex]::Matches($tasksContent, "status:\s*in_progress")).Count
        $blocked = ([regex]::Matches($tasksContent, "status:\s*blocked")).Count
        $backlog = $total - ($done + $inProgress + $blocked)

        $percent = if ($total -gt 0) { [math]::Round(($done / $total) * 100, 1) } else { 0 }
        Write-Host "   • Progreso: $done / $total tareas completadas ($percent%)" -ForegroundColor Green
        Write-Host "   • En curso: $inProgress | Backlog: $backlog | Bloqueadas: $blocked" -ForegroundColor Gray
    } else {
        Write-Host "   ⚠️ No se encontró roadmap/tasks.yaml" -ForegroundColor Red
    }

    # 3. ESTADO DE LA BANDEJA (CARRIL B)
    Write-Host "`n📬 3. ESTADO BANDEJA DEL WORKER (BANDEJA.md):" -ForegroundColor Yellow
    $bandejaPath = Join-Path $repoRoot "BANDEJA.md"
    if (Test-Path $bandejaPath) {
        $bandejaLines = Get-Content $bandejaPath
        $activa = $bandejaLines | Select-String -Pattern "^\s*-\s*\*\*ID:\*\*" | Select-Object -First 2
        foreach ($item in $activa) {
            Write-Host "   • $($item.Line.Trim())" -ForegroundColor White
        }
        $estado = $bandejaLines | Select-String -Pattern "ESTADO:|LISTO_PARA_MERGE|in_progress|queued" | Select-Object -First 3
        foreach ($st in $estado) {
            Write-Host "     ↳ $($st.Line.Trim())" -ForegroundColor Cyan
        }
    } else {
        Write-Host "   ⚠️ No se encontró BANDEJA.md en la raíz" -ForegroundColor DarkYellow
    }

    # 4. WORKTREES ACTIVOS
    Write-Host "`n🌲 4. WORKTREES ACTIVOS REGISTRADOS:" -ForegroundColor Yellow
    $worktrees = git worktree list 2>$null
    if ($worktrees) {
        foreach ($wt in $worktrees) {
            Write-Host "   • $wt" -ForegroundColor DarkCyan
        }
    }

    Write-Host "`n--------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host " Actualizando cada $intervalSeconds segundos... Presiona [Ctrl + C] para salir." -ForegroundColor DarkGray
    Start-Sleep -Seconds $intervalSeconds
}