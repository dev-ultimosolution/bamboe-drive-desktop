# SPDX-FileCopyrightText: 2017 Nextcloud GmbH and Nextcloud contributors
# SPDX-FileCopyrightText: 2012 ownCloud GmbH
# SPDX-License-Identifier: GPL-2.0-or-later
#
# keep the application name and short name the same or different for dev and prod build
# or some migration logic will behave differently for each build
if(NEXTCLOUD_DEV)
    set( APPLICATION_NAME       "NextcloudDev" )
    set( APPLICATION_SHORTNAME  "NextcloudDev" )
    set( APPLICATION_EXECUTABLE "nextclouddev" )
    set( APPLICATION_ICON_NAME  "Nextcloud" )
else()
    set( APPLICATION_NAME       "Bamboe Drive" )
    set( APPLICATION_SHORTNAME  "BamboeDrive" )
    set( APPLICATION_EXECUTABLE "bamboedrive" )
    set( APPLICATION_ICON_NAME  "${APPLICATION_SHORTNAME}" )
endif()

set( APPLICATION_CONFIG_NAME "${APPLICATION_EXECUTABLE}" )
set( APPLICATION_DOMAIN     "bamboemail.com" )
set( APPLICATION_VENDOR     "Ultimo Solution" )
set( APPLICATION_UPDATE_URL "https://bamboemail.com/drive/desktop/update/" CACHE STRING "URL for updater" )
set( APPLICATION_HELP_URL   "https://bamboemail.com/#support" CACHE STRING "URL for the help menu" )

# Default macOS builds (Nextcloud + NextcloudDev) use the Icon Composer (.icon)
# format for the app icon. That format can only be compiled by a recent enough
# toolchain (Xcode 26 ships the actool that understands .icon, and macOS 26
# provides the matching SDK), so we gate the modern pipeline on the build
# environment. Older environments — and branded customer builds, which use a
# different APPLICATION_NAME and ship their own colourful icon SVG — fall back
# to the historical Inkscape + ECM (ecm_add_app_icon) .icns pipeline instead.
#
# The Xcode/actool version is the real capability gate; the macOS check is a
# coarse secondary guard. Detection runs every configure and is intentionally
# NOT cached, so the decision self-heals once the build host is upgraded without
# requiring a clean reconfigure. Pass -DMACOS_USE_ICON_COMPOSER=ON/OFF to
# override auto-detection entirely.
if(APPLE)
    execute_process(COMMAND sw_vers -productVersion
        OUTPUT_VARIABLE _macos_product_version RESULT_VARIABLE _macos_ver_result
        OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)
    execute_process(COMMAND xcodebuild -version
        OUTPUT_VARIABLE _xcodebuild_version_raw RESULT_VARIABLE _xcode_ver_result
        OUTPUT_STRIP_TRAILING_WHITESPACE ERROR_QUIET)

    set(MACOS_ICON_COMPOSER_TOOLCHAIN_SUPPORTED OFF)
    if(_macos_ver_result EQUAL 0 AND _xcode_ver_result EQUAL 0)
        string(REGEX MATCH "Xcode ([0-9]+\\.[0-9]+)" _ "${_xcodebuild_version_raw}")
        set(_xcode_version "${CMAKE_MATCH_1}")
        message(STATUS "Detected build environment: macOS ${_macos_product_version}, Xcode ${_xcode_version}")
        if(_macos_product_version VERSION_GREATER_EQUAL "26.5"
           AND _xcode_version VERSION_GREATER_EQUAL "26.5")
            set(MACOS_ICON_COMPOSER_TOOLCHAIN_SUPPORTED ON)
        endif()
    endif()

    if(NOT DEFINED MACOS_USE_ICON_COMPOSER)
        if((APPLICATION_NAME STREQUAL "Nextcloud" OR NEXTCLOUD_DEV)
           AND EXISTS "${CMAKE_SOURCE_DIR}/theme/colored/AppIcon.icon/icon.json"
           AND MACOS_ICON_COMPOSER_TOOLCHAIN_SUPPORTED)
            set(MACOS_USE_ICON_COMPOSER ON)
            message(STATUS "Using Icon Composer (.icon) format for the macOS app icon.")
        else()
            set(MACOS_USE_ICON_COMPOSER OFF)
        endif()
    endif()

    if(NOT MACOS_USE_ICON_COMPOSER)
        message(STATUS "macOS app icon: using legacy ECM .icns pipeline.")
        # Restore the macOS-specific (squircle) icon for the default builds so the
        # legacy pipeline emits Nextcloud-macOS.icns rather than the generic logo.
        # Branded builds keep their own ${APPLICATION_ICON_NAME}-icon.svg.
        if((APPLICATION_NAME STREQUAL "Nextcloud" OR NEXTCLOUD_DEV)
           AND EXISTS "${CMAKE_SOURCE_DIR}/theme/colored/Nextcloud-macOS-icon.svg")
            set(APPLICATION_ICON_NAME "Nextcloud-macOS")
            message(STATUS "Using macOS-specific application icon: ${APPLICATION_ICON_NAME}")
        endif()
    endif()
endif()

set( APPLICATION_ICON_SET   "SVG" )
set( APPLICATION_SERVER_URL "https://drive.bamboemail.com" CACHE STRING "URL for the server to use. If entered, the UI field will be pre-filled with it" )
set( APPLICATION_SERVER_URL_ENFORCE ON ) # If set and APPLICATION_SERVER_URL is defined, the server can only connect to the pre-defined URL
set( APPLICATION_REV_DOMAIN "com.bamboemail.drive" )
set( APPLICATION_REV_DOMAIN_DBUS "drive.bamboemail.com" )
set( DEVELOPMENT_TEAM "NKUJUXUJ3B" CACHE STRING "Apple Development Team ID" )
set( APPLICATION_VIRTUALFILE_SUFFIX "bamboedrive" CACHE STRING "Virtual file suffix (not including the .)")
set( APPLICATION_OCSP_STAPLING_ENABLED OFF )
set( APPLICATION_FORBID_BAD_SSL OFF )

set( LINUX_PACKAGE_SHORTNAME "bamboedrive" )
set( LINUX_APPLICATION_ID "${APPLICATION_REV_DOMAIN}.${LINUX_PACKAGE_SHORTNAME}")

set( THEME_CLASS            "NextcloudTheme" )
set( WIN_SETUP_BITMAP_PATH  "${CMAKE_SOURCE_DIR}/admin/win/nsi" )

set( MAC_INSTALLER_BACKGROUND_FILE "${CMAKE_SOURCE_DIR}/admin/osx/installer-background.png" CACHE STRING "The MacOSX installer background image")

# set( THEME_INCLUDE          "${OEM_THEME_DIR}/mytheme.h" )
# set( APPLICATION_LICENSE    "${OEM_THEME_DIR}/license.txt )

## Updater options
option( BUILD_UPDATER "Build updater" ON )

option( WITH_PROVIDERS "Build with providers list" OFF )

option( ENFORCE_VIRTUAL_FILES_SYNC_FOLDER "Enforce use of virtual files sync folder when available" OFF )
option( DISABLE_VIRTUAL_FILES_SYNC_FOLDER "Disable use of virtual files sync folder even when available" OFF )

option(ENFORCE_SINGLE_ACCOUNT "Enforce use of a single account in desktop client" OFF)

option( DO_NOT_USE_PROXY "Do not use system wide proxy, instead always do a direct connection to server" OFF )

option( WIN_DISABLE_USERNAME_PREFILL "Do not prefill the Windows user name when creating a new account" OFF )

## Theming options
set(NEXTCLOUD_BACKGROUND_COLOR "#4a9e2b" CACHE STRING "Default Nextcloud background color")
set( APPLICATION_WIZARD_HEADER_BACKGROUND_COLOR ${NEXTCLOUD_BACKGROUND_COLOR} CACHE STRING "Hex color of the wizard header background")
set( APPLICATION_WIZARD_HEADER_TITLE_COLOR "#ffffff" CACHE STRING "Hex color of the text in the wizard header")
option( APPLICATION_WIZARD_USE_CUSTOM_LOGO "Use the logo from ':/client/theme/colored/wizard_logo.(png|svg)' else the default application icon is used" ON )

#
## Windows Shell Extensions & MSI - IMPORTANT: Generate new GUIDs for custom builds with "guidgen" or "uuidgen"
#
if(WIN32)
    # Context Menu
    set( WIN_SHELLEXT_CONTEXT_MENU_GUID      "{945B3022-50DE-466D-958D-EA354953CD65}" )

    # Overlays
    set( WIN_SHELLEXT_OVERLAY_GUID_ERROR     "{A5CBF54A-DE84-4BF6-AEE0-B2E6E54F6D97}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK        "{B556062B-FC55-4AB0-B0E5-24D9A22E7D75}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_OK_SHARED "{6B49D243-4458-4A94-BFF4-948330F47CB4}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_SYNC      "{6917BE94-9020-4C23-8549-A933B9B5DFEB}" )
    set( WIN_SHELLEXT_OVERLAY_GUID_WARNING   "{C270BB7B-76DD-48C3-8AAE-11AC6977362B}" )

    # MSI Upgrade Code (without brackets)
    # BAMBOE: NEVER CHANGE. Every Bamboe Drive release must keep this code so
    # newer installers upgrade in place (no uninstall, sync settings kept).
    set( WIN_MSI_UPGRADE_CODE                "AEB4B2AE-51BC-4CCC-ABC7-4175D6961A9B" )

    # Windows build options
    option( BUILD_WIN_MSI "Build MSI scripts and helper DLL" ON )
    option( BUILD_WIN_TOOLS "Build Win32 migration tools" OFF )
endif()

if (APPLE AND CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER_EQUAL 11.0)
    option( BUILD_FILE_PROVIDER_MODULE "Build the macOS virtual files File Provider module" OFF )
endif()
