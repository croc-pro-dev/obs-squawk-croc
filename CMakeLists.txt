cmake_minimum_required(VERSION 3.16...3.26)

# CMake 4.x dropped support for cmake_minimum_required < 3.5. FetchContent
# deps (libarchive 3.7.4, etc.) still declare 2.8.x.
set(CMAKE_POLICY_VERSION_MINIMUM
    3.5
    CACHE STRING "Minimum policy version for old FetchContent projects")

include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/common/bootstrap.cmake" NO_POLICY_SCOPE)

project(${_name} VERSION ${_version})

option(ENABLE_FRONTEND_API "Use obs-frontend-api for UI functionality" ON)
option(ENABLE_QT "Use Qt functionality" ON)

if(WIN32)
  include("${CMAKE_CURRENT_SOURCE_DIR}/cmake/windows/local-obs.cmake")
endif()

include(compilerconfig)
include(defaults)
include(helpers)

add_library(${CMAKE_PROJECT_NAME} MODULE)

find_package(libobs REQUIRED)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE OBS::libobs)

if(ENABLE_FRONTEND_API)
  find_package(obs-frontend-api REQUIRED)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE OBS::obs-frontend-api)
endif()

if(ENABLE_QT)
  find_package(Qt6 REQUIRED COMPONENTS Widgets Core)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt6::Core Qt6::Widgets)
  target_compile_options(
    ${CMAKE_PROJECT_NAME} PRIVATE $<$<C_COMPILER_ID:Clang,AppleClang>:-Wno-quoted-include-in-framework-header
                                  -Wno-comma>)
  set_target_properties(
    ${CMAKE_PROJECT_NAME}
    PROPERTIES AUTOMOC ON
               AUTOUIC ON
               AUTORCC ON)
endif()

# build cURL
set(USE_SYSTEM_CURL
    OFF
    CACHE STRING "Use system cURL")
if(USE_SYSTEM_CURL)
  find_package(CURL REQUIRED)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE "${CURL_LIBRARIES}")
  target_include_directories(${CMAKE_PROJECT_NAME} SYSTEM PUBLIC "${CURL_INCLUDE_DIRS}")
else()
  include(cmake/BuildMyCurl.cmake)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE libcurl)
endif()

# build sherpa-onnx
include(cmake/BuildSherpaOnnx.cmake)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE sherpa-onnx)

find_package(LibArchive QUIET)
if(LibArchive_FOUND)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE LibArchive::LibArchive)
  if(WIN32)
    find_package(BZip2 REQUIRED)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE BZip2::BZip2)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE BZ_STATIC)
  endif()
else()
  include(cmake/BuildLibarchive.cmake)
  target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE libarchive)
endif()

if(MSVC)
  target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE /WX-)
endif()

target_sources(
  ${CMAKE_PROJECT_NAME}
  PRIVATE src/input-thread.cpp
          src/model-utils/model-downloader-ui.cpp
          src/model-utils/model-downloader.cpp
          src/model-utils/model-find-utils.cpp
          src/model-utils/model-infos.cpp
          src/plugin-main.c
          src/sherpa-tts/sherpa-tts.cpp
          src/audio-thread.cpp
          src/squawk-source.c
          src/squawk-source.cpp
          src/tts-utils.cpp)

set_target_properties_plugin(${CMAKE_PROJECT_NAME} PROPERTIES OUTPUT_NAME ${_name})
