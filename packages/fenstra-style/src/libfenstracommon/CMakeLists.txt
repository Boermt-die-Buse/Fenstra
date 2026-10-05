add_library(fenstracommon${QT_MAJOR_VERSION} OBJECT fenstraboxshadowrenderer.cpp)

set_target_properties(fenstracommon${QT_MAJOR_VERSION} PROPERTIES POSITION_INDEPENDENT_CODE TRUE)

target_link_libraries(fenstracommon${QT_MAJOR_VERSION}
    PUBLIC
        Qt${QT_MAJOR_VERSION}::Core
        Qt${QT_MAJOR_VERSION}::Gui)
