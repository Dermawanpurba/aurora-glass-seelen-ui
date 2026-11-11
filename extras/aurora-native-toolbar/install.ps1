$ErrorActionPreference = 'Stop'

$pluginSource = Join-Path $PSScriptRoot 'plugins'
$seelenRoot = Join-Path $env:APPDATA 'com.seelen.seelen-ui'
$installedPlugins = Join-Path $seelenRoot 'plugins'
$statePath = Join-Path $seelenRoot 'data\seelen-fancy-toolbar\state.yml'
$requiredPlugins = @(
  @{ Folder = 'calendar-popup'; Id = '@seelen/tb-calendar-popup' }
  @{ Folder = 'network-popup'; Id = '@seelen/tb-network-popup' }
  @{ Folder = 'media-popup'; Id = '@seelen/tb-media-popup' }
  @{ Folder = 'quick-settings'; Id = '@seelen/tb-quick-settings' }
  @{ Folder = 'notifications'; Id = '@seelen/tb-notifications' }
  @{ Folder = 'power-menu'; Id = '@seelen/tb-power-menu' }
)

if (-not (Test-Path -LiteralPath $statePath -PathType Leaf)) {
  throw "Seelen toolbar state was not found: $statePath"
}

foreach ($plugin in $requiredPlugins) {
  $manifest = Join-Path $pluginSource (Join-Path $plugin.Folder 'metadata.yml')
  if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) {
    throw "Packaged toolbar plugin was not found: $manifest"
  }
  $manifestText = [System.IO.File]::ReadAllText($manifest)
  if ($manifestText -notmatch ('(?m)^id:\s*["'']?' + [regex]::Escape($plugin.Id) + '["'']?\s*$')) {
    throw "Plugin ID does not match the packaged file: $manifest"
  }
}

$backupRoot = Join-Path $env:LOCALAPPDATA 'com.seelen.seelen-ui\backups'
$backupSuffix = [guid]::NewGuid().ToString('N').Substring(0, 8)
$backupPath = Join-Path $backupRoot ('native-navbar-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '-' + $backupSuffix)
New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
Copy-Item -LiteralPath $statePath -Destination (Join-Path $backupPath 'state.yml')
New-Item -ItemType Directory -Path $installedPlugins -Force | Out-Null

foreach ($plugin in $requiredPlugins) {
  $sourceManifest = Join-Path $pluginSource (Join-Path $plugin.Folder 'metadata.yml')
  $destinationFolder = Join-Path $installedPlugins ('native-tb-' + $plugin.Folder)
  New-Item -ItemType Directory -Path $destinationFolder -Force | Out-Null
  $destinationManifest = Join-Path $destinationFolder 'metadata.yml'

  if (Test-Path -LiteralPath $destinationManifest -PathType Leaf) {
    $installedText = [System.IO.File]::ReadAllText($destinationManifest)
    if ($installedText -notmatch ('(?m)^id:\s*["'']?' + [regex]::Escape($plugin.Id) + '["'']?\s*$')) {
      throw "An unrelated plugin already occupies the destination: $destinationManifest"
    }
    if ((Get-FileHash -LiteralPath $sourceManifest -Algorithm SHA256).Hash -ne
        (Get-FileHash -LiteralPath $destinationManifest -Algorithm SHA256).Hash) {
      Copy-Item -LiteralPath $destinationManifest -Destination (Join-Path $backupPath ($plugin.Folder + '-metadata.yml'))
    }
  }

  Copy-Item -LiteralPath $sourceManifest -Destination $destinationManifest -Force
}

$originalState = [System.IO.File]::ReadAllText($statePath)
$lineEnding = if ($originalState.Contains("`r`n")) { "`r`n" } else { "`n" }
$lines = [System.Collections.Generic.List[string]]::new()
$lines.AddRange([string[]][regex]::Split($originalState, "\r\n|\n|\r"))

for ($index = $lines.Count - 1; $index -ge 0; $index--) {
  if ($lines[$index] -match '^\s*-\s*(["'']?)(@default/power|@aurora/brightness)\1\s*$') {
    if ($Matches[2] -eq '@default/power') {
      $lines[$index] = $lines[$index].Replace('@default/power', '@seelen/tb-power-menu')
    } else {
      $lines.RemoveAt($index)
    }
  }
}

function Add-ToolbarItem([string]$Group, [string]$PluginId) {
  $groupStart = -1
  for ($index = 0; $index -lt $lines.Count; $index++) {
    if ($lines[$index] -match ('^' + [regex]::Escape($Group) + ':\s*(?:#.*)?$')) {
      $groupStart = $index
      break
    }
  }
  if ($groupStart -lt 0) {
    throw "Toolbar group was not found: $Group"
  }

  $insertAt = $groupStart + 1
  while ($insertAt -lt $lines.Count -and
         $lines[$insertAt] -notmatch '^[A-Za-z_][A-Za-z0-9_-]*:\s*(?:#.*)?$') {
    $line = $lines[$insertAt].Trim()
    if ($line -match '^-[ \t]*(.*)$') {
      $existingId = $Matches[1].Trim().Trim([char[]]@([char]39, [char]34))
      if ($existingId -eq $PluginId) {
        return
      }
    }
    $insertAt++
  }

  $lines.Insert($insertAt, "- '$PluginId'")
}

Add-ToolbarItem -Group 'center' -PluginId '@seelen/tb-calendar-popup'
Add-ToolbarItem -Group 'right' -PluginId '@seelen/tb-network-popup'
Add-ToolbarItem -Group 'right' -PluginId '@seelen/tb-media-popup'
Add-ToolbarItem -Group 'right' -PluginId '@seelen/tb-quick-settings'
Add-ToolbarItem -Group 'right' -PluginId '@seelen/tb-notifications'
Add-ToolbarItem -Group 'right' -PluginId '@seelen/tb-power-menu'

[System.IO.File]::WriteAllText($statePath, ($lines -join $lineEnding), [System.Text.UTF8Encoding]::new($false))
Write-Output 'Installed Seelen toolbar controls: date/calendar, Wi-Fi, volume, Quick Settings, notifications, and Power Menu.'
Write-Output "Backup: $backupPath"
Write-Output 'Restart Seelen UI to reload the updated toolbar.'
