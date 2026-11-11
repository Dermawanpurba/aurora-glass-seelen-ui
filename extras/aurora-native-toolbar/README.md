# Native Seelen toolbar controls

These standalone copies of Seelen UI's bundled toolbar plugins keep the calendar, network, volume, Quick Settings, notifications, and Power Menu available when Seelen reloads its plugin registry.

The installer adds these controls to the existing fancy toolbar, opens brightness through Quick Settings, and replaces `@default/power` with Seelen's own Power Menu. It preserves other toolbar items and creates a backup before changing the saved layout or replacing a plugin manifest.

Run the installer from PowerShell:

```powershell
.\extras\aurora-native-toolbar\install.ps1
```

Restart Seelen UI after installation. Quick Settings exposes a brightness control when the monitor reports support for brightness adjustment.

The plugin manifests are copied from the official resources shipped with Seelen UI 2.8.10. Seelen UI and its bundled resources remain products of their upstream authors; Aurora Glass is an unofficial community theme.
