# Fenstra-Fensterdekoration (KDecoration3-Plugin org.fenstra.decoration)
include_directories(${CMAKE_SOURCE_DIR}/libfenstracommon)
include_directories(${CMAKE_BINARY_DIR}/libfenstracommon)

add_library(fenstradecoration MODULE
    fenstrabutton.cpp
    fenstradecoration.cpp
)

set_target_properties(fenstradecoration PROPERTIES
    OUTPUT_NAME org.fenstra.decoration
)

target_link_libraries(fenstradecoration
    PRIVATE
        fenstracommon6
        KF6::CoreAddons
        KDecoration3::KDecoration
)

install(TARGETS fenstradecoration DESTINATION ${KDE_INSTALL_PLUGINDIR}/${KDECORATION_PLUGIN_DIR})
