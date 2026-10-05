# Fenstra: Qt-Widget-Stil und KWin-Fensterdekoration im Stil von Windows 11.
# Fork von KDE Breeze 6.7.5 (kstyle/, kdecoration/, libbreezecommon/ -> fenstra*),
# nur Qt 6, ohne Farbschemata, Cursor, Wallpaper und Übersetzungen.
cmake_minimum_required(VERSION 3.16)
project(fenstra-style)
set(PROJECT_VERSION "44.0")

set(KF6_MIN_VERSION "6.26.0")
set(QT_MIN_VERSION "6.10.0")
set(KDE_COMPILERSETTINGS_LEVEL "5.82")

find_package(ECM ${KF6_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${ECM_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
option(BUILD_TESTING "Build the testing tree." OFF)

include(GenerateExportHeader)
include(FeatureSummary)
include(ECMQtDeclareLoggingCategory)
include(ECMInstallIcons)
include(CMakePackageConfigHelpers)
include(KDECompilerSettings NO_POLICY_SCOPE)

set(QT_MAJOR_VERSION 6)
set(QT_NO_CREATE_VERSIONLESS_TARGETS ON)
set(QT_NO_CREATE_VERSIONLESS_FUNCTIONS ON)
include(KDEInstallDirs6)
include(KDECMakeSettings)

find_package(Qt6 ${QT_MIN_VERSION} REQUIRED CONFIG COMPONENTS Widgets Core Svg DBus Quick)
set(HAVE_QTDBUS ${Qt6DBus_FOUND})
find_package(KF6 ${KF6_MIN_VERSION} REQUIRED COMPONENTS
    CoreAddons ColorScheme Config GuiAddons I18n IconThemes WindowSystem KCMUtils)
find_package(KF6FrameworkIntegration ${KF6_MIN_VERSION} CONFIG REQUIRED)
find_package(KDecoration3 REQUIRED)

set(FENSTRA_HAVE_KSTYLE ${KF6FrameworkIntegration_FOUND})
set(FENSTRA_HAVE_QTQUICK ${Qt6Quick_FOUND})

add_subdirectory(kstyle kstyle6)
add_subdirectory(libfenstracommon libfenstracommon6)
add_subdirectory(kdecoration)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
