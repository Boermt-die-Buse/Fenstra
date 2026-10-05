################# includes #################
include_directories(
  animations
  debug
)

include_directories(${CMAKE_SOURCE_DIR}/libfenstracommon)
include_directories(${CMAKE_BINARY_DIR}/libfenstracommon)

################# configuration #################
configure_file(config-fenstra.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-fenstra.h )

########### next target ###############
set(fenstra_PART_SRCS
    animations/fenstraanimation.cpp
    animations/fenstraanimations.cpp
    animations/fenstraanimationdata.cpp
    animations/fenstrabaseengine.cpp
    animations/fenstrabusyindicatordata.cpp
    animations/fenstrabusyindicatorengine.cpp
    animations/fenstradialdata.cpp
    animations/fenstradialengine.cpp
    animations/fenstraenabledata.cpp
    animations/fenstragenericdata.cpp
    animations/fenstraheaderviewdata.cpp
    animations/fenstraheaderviewengine.cpp
    animations/fenstrascrollbardata.cpp
    animations/fenstrascrollbarengine.cpp
    animations/fenstraspinboxengine.cpp
    animations/fenstraspinboxdata.cpp
    animations/fenstrastackedwidgetdata.cpp
    animations/fenstrastackedwidgetengine.cpp
    animations/fenstratabbarengine.cpp
    animations/fenstratabbardata.cpp
    animations/fenstratoolboxengine.cpp
    animations/fenstratransitiondata.cpp
    animations/fenstratransitionwidget.cpp
    animations/fenstrawidgetstateengine.cpp
    animations/fenstrawidgetstatedata.cpp
    debug/fenstrawidgetexplorer.cpp
    fenstraaddeventfilter.cpp
    fenstrablurhelper.cpp
    fenstraframeshadow.cpp
    fenstrahelper.cpp
    fenstramdiwindowshadow.cpp
    fenstramnemonics.cpp
    fenstrapropertynames.cpp
    fenstrashadowhelper.cpp
    fenstrasplitterproxy.cpp
    fenstrastyle.cpp
    fenstrastyleplugin.cpp
    fenstratileset.cpp
    fenstrawindowmanager.cpp
    fenstratoolsareamanager.cpp
)

kconfig_add_kcfg_files(fenstra_PART_SRCS ../kdecoration/fenstrasettings.kcfgc)
kconfig_add_kcfg_files(fenstra_PART_SRCS fenstrastyleconfigdata.kcfgc)


add_library(fenstra${QT_MAJOR_VERSION} MODULE ${fenstra_PART_SRCS})

ecm_qt_declare_logging_category(fenstra${QT_MAJOR_VERSION}
    HEADER
        fenstra_logging.h
    IDENTIFIER
        FENSTRA
    CATEGORY_NAME
        fenstra${QT_MAJOR_VERSION}
    DEFAULT_SEVERITY
        Warning
)

target_link_libraries(fenstra${QT_MAJOR_VERSION}
    Qt${QT_MAJOR_VERSION}::Core
    Qt${QT_MAJOR_VERSION}::Gui
    Qt${QT_MAJOR_VERSION}::Widgets
)

if(HAVE_QTDBUS)
    target_link_libraries(fenstra${QT_MAJOR_VERSION}
        Qt${QT_MAJOR_VERSION}::DBus
    )
endif()

if( FENSTRA_HAVE_QTQUICK )
    target_link_libraries(fenstra${QT_MAJOR_VERSION} 
        Qt${QT_MAJOR_VERSION}::Quick
        KF${QT_MAJOR_VERSION}::CoreAddons
    )
endif()

target_link_libraries(fenstra${QT_MAJOR_VERSION}
    KF${QT_MAJOR_VERSION}::CoreAddons
    KF${QT_MAJOR_VERSION}::ConfigCore
    KF${QT_MAJOR_VERSION}::ConfigGui
    KF${QT_MAJOR_VERSION}::GuiAddons
    KF${QT_MAJOR_VERSION}::IconThemes
    KF${QT_MAJOR_VERSION}::WindowSystem
)

if(QT_MAJOR_VERSION STREQUAL "5")
    target_link_libraries(fenstra5 KF5::ConfigWidgets)
else()
    target_link_libraries(fenstra6 KF6::ColorScheme)
endif()

target_link_libraries(fenstra${QT_MAJOR_VERSION} fenstracommon${QT_MAJOR_VERSION})

if(KF${QT_MAJOR_VERSION}FrameworkIntegration_FOUND)
    target_link_libraries(fenstra${QT_MAJOR_VERSION}  KF${QT_MAJOR_VERSION}::Style)
endif()


if (WIN32)
    # As stated in https://docs.microsoft.com/en-us/cpp/c-runtime-library/math-constants M_PI only gets defined
    # when if _USE_MATH_DEFINES is defined
    target_compile_definitions(fenstra${QT_MAJOR_VERSION}  PRIVATE _USE_MATH_DEFINES _BSD_SOURCE)
endif()


########### install files ###############
install(TARGETS fenstra${QT_MAJOR_VERSION}  DESTINATION ${KDE_INSTALL_QTPLUGINDIR}/styles/)
install(FILES fenstra.themerc  DESTINATION  ${KDE_INSTALL_DATADIR}/kstyle/themes)

########### subdirectories ###############

if (QT_MAJOR_VERSION EQUAL "6" AND TARGET "KF6::KCMUtils")
    add_subdirectory(config)
endif()
