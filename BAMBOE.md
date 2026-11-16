# Bamboe Drive Desktop

Bamboe Drive Desktop is a rebranded build of the
[Nextcloud desktop client](https://github.com/nextcloud/desktop) (GPL-2.0-or-later)
for Bamboe Drive (`https://drive.bamboemail.com`). This repository is the
public source of the modified client, as required by the GPL.

Bamboe Drive is not affiliated with or endorsed by Nextcloud GmbH.

## What is changed from upstream

| Item | Value |
|---|---|
| Upstream base | `v34.0.7` |
| App name / executable | `Bamboe Drive` / `bamboedrive.exe` |
| Server | `https://drive.bamboemail.com`, enforced (users cannot change it) |
| Login | Browser login flow → Bamboe SSO (same password as the mailbox) |
| Updater | `https://bamboemail.com/drive/desktop/update/` (not updates.nextcloud.org) |
| Colours | `#4a9e2b` |
| Provider list | off |
| Windows shell extension and CfAPI GUIDs | new, unique to Bamboe Drive |

Files touched: `NEXTCLOUD.cmake`, `CMakeLists.txt` (CfAPI GUIDs),
`theme/colored/BamboeDrive-*`, `theme/colored/wizard_logo*`,
`admin/win/msi/gui/*.bmp`, `.github/workflows/bamboe-windows.yml`.

## MSI UpgradeCode — never change

```
AEB4B2AE-51BC-4CCC-ABC7-4175D6961A9B
```

Set in `NEXTCLOUD.cmake` (`WIN_MSI_UPGRADE_CODE`). Every release must keep it so
a newer installer upgrades the installed one in place (no uninstall, sync
settings kept). The same applies to the shell extension and CfAPI GUIDs.

## Building the Windows installer

GitHub Actions workflow **Bamboe Drive Windows** (`windows-2022` runner, KDE Craft
+ MSVC + WiX 3):

- Manual: *Actions → Bamboe Drive Windows → Run workflow*; the MSI is in the run's artifacts.
- Release: push a tag `bamboe-vX.Y.Z` (e.g. `bamboe-v34.0.7`); the MSI is attached to the GitHub release.

The first run builds the Craft dependency cache and takes a few hours; later
runs reuse it.

Releases are unsigned until a code-signing certificate is bought: Windows
SmartScreen shows a warning ("More info → Run anyway"). Distribute installers
only from the official Bamboemail download link.

## Updating to a new upstream release

1. `git fetch upstream --tags` and rebase/merge the `bamboe` branch onto the new tag.
2. Re-check `NEXTCLOUD.cmake` and the CfAPI GUIDs in `CMakeLists.txt` after conflicts;
   keep all GUIDs and the UpgradeCode unchanged.
3. Tag `bamboe-v<upstream version>` to build.
