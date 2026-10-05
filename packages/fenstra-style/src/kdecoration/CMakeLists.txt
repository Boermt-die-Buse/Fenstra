add_definitions(-DTRANSLATION_DOMAIN="fenstra_kwin_deco")

################# includes #################
include_directories(${CMAKE_SOURCE_DIR}/libfenstracommon)
include_directories(${CMAKE_BINARY_DIR}/libfenstracommon)

################# newt target #################
### plugin classes
set(fenstradecoration_SRCS
    fenstrabutton.cpp
    fenstradecoration.cpp
    fenstrasettingsprovider.cpp
    fenstraexceptionlist.cpp
)

### build library
kconfig_add_kcfg_files(fenstradecoration_SRCS fenstrasettings.kcfgc)
add_library(fenstradecoration MODULE
    ${fenstradecoration_SRCS}
    ${fenstradecoration_config_PART_FORMS_HEADERS})

set_target_properties(fenstradecoration PROPERTIES
    OUTPUT_NAME org.kde.fenstra
)

target_link_libraries(fenstradecoration
    PRIVATE
        fenstracommon6
        Qt6::DBus
        KF6::CoreAddons
        KF6::ConfigGui
        KF6::GuiAddons
        KF6::I18n
        KF6::IconThemes
        KDecoration3::KDecoration
        KF6::ColorScheme
)

install(TARGETS fenstradecoration DESTINATION ${KDE_INSTALL_PLUGINDIR}/${KDECORATION_PLUGIN_DIR})

add_subdirectory(config)

