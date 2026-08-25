# Resolve a local OBS Studio / obs-deps tree via CMAKE_PREFIX_PATH, OBS_STUDIO_DIR,
# and OBS_DEPS_DIR. Never FORCE machine-specific drive paths.

include_guard(GLOBAL)

if(NOT OBS_STUDIO_DIR AND DEFINED ENV{OBS_STUDIO_DIR} AND NOT "$ENV{OBS_STUDIO_DIR}" STREQUAL "")
  set(OBS_STUDIO_DIR
      "$ENV{OBS_STUDIO_DIR}"
      CACHE PATH "OBS Studio source tree or CMake build tree")
endif()

if(NOT OBS_DEPS_DIR AND DEFINED ENV{OBS_DEPS_DIR} AND NOT "$ENV{OBS_DEPS_DIR}" STREQUAL "")
  set(OBS_DEPS_DIR
      "$ENV{OBS_DEPS_DIR}"
      CACHE PATH "obs-deps prefix (SIMDe headers, extra libs)")
endif()

function(_squawk_append_prefix _dir)
  if(NOT _dir OR NOT EXISTS "${_dir}")
    return()
  endif()
  cmake_path(ABSOLUTE_PATH _dir NORMALIZE OUTPUT_VARIABLE _abs)
  list(FIND CMAKE_PREFIX_PATH "${_abs}" _idx)
  if(_idx EQUAL -1)
    list(PREPEND CMAKE_PREFIX_PATH "${_abs}")
    set(CMAKE_PREFIX_PATH
        "${CMAKE_PREFIX_PATH}"
        PARENT_SCOPE)
  endif()
endfunction()

function(_squawk_append_module _dir)
  if(NOT _dir OR NOT EXISTS "${_dir}")
    return()
  endif()
  cmake_path(ABSOLUTE_PATH _dir NORMALIZE OUTPUT_VARIABLE _abs)
  list(FIND CMAKE_MODULE_PATH "${_abs}" _idx)
  if(_idx EQUAL -1)
    list(APPEND CMAKE_MODULE_PATH "${_abs}")
    set(CMAKE_MODULE_PATH
        "${CMAKE_MODULE_PATH}"
        PARENT_SCOPE)
  endif()
endfunction()

# OBS_STUDIO_DIR may be the source root or the CMake build directory.
if(OBS_STUDIO_DIR)
  cmake_path(ABSOLUTE_PATH OBS_STUDIO_DIR NORMALIZE OUTPUT_VARIABLE _obs_studio)
  if(EXISTS "${_obs_studio}/libobs/libobsConfig.cmake")
    set(_obs_build "${_obs_studio}")
    cmake_path(GET _obs_studio PARENT_PATH _obs_src)
  elseif(EXISTS "${_obs_studio}/build/libobs/libobsConfig.cmake")
    set(_obs_src "${_obs_studio}")
    set(_obs_build "${_obs_studio}/build")
  else()
    set(_obs_src "${_obs_studio}")
    set(_obs_build "${_obs_studio}")
  endif()

  _squawk_append_prefix("${_obs_build}")
  _squawk_append_prefix("${_obs_build}/libobs")
  _squawk_append_prefix("${_obs_build}/frontend/api")
  _squawk_append_module("${_obs_src}/cmake")
  _squawk_append_module("${_obs_src}/cmake/finders")
  _squawk_append_module("${_obs_src}/cmake/Modules")

  file(GLOB _qt6_prefixes "${_obs_src}/.deps/obs-deps-qt6-*-x64")
  list(SORT _qt6_prefixes)
  list(REVERSE _qt6_prefixes)
  foreach(_qt6 IN LISTS _qt6_prefixes)
    _squawk_append_prefix("${_qt6}")
  endforeach()

  if(NOT w32-pthreads_DIR AND EXISTS "${_obs_build}/deps/w32-pthreads/w32-pthreadsConfig.cmake")
    set(w32-pthreads_DIR
        "${_obs_build}/deps/w32-pthreads"
        CACHE PATH "w32-pthreads CMake package")
  endif()
endif()

if(OBS_DEPS_DIR)
  _squawk_append_prefix("${OBS_DEPS_DIR}")
endif()

# Infer finders / w32-pthreads / Qt from an OBS build already on CMAKE_PREFIX_PATH.
foreach(_prefix IN LISTS CMAKE_PREFIX_PATH)
  if(NOT EXISTS "${_prefix}/libobs/libobsConfig.cmake")
    continue()
  endif()
  _squawk_append_prefix("${_prefix}/frontend/api")
  cmake_path(GET _prefix PARENT_PATH _obs_src_from_prefix)
  _squawk_append_module("${_obs_src_from_prefix}/cmake")
  _squawk_append_module("${_obs_src_from_prefix}/cmake/finders")
  _squawk_append_module("${_obs_src_from_prefix}/cmake/Modules")
  file(GLOB _qt6_from_prefix "${_obs_src_from_prefix}/.deps/obs-deps-qt6-*-x64")
  list(SORT _qt6_from_prefix)
  list(REVERSE _qt6_from_prefix)
  foreach(_qt6 IN LISTS _qt6_from_prefix)
    _squawk_append_prefix("${_qt6}")
  endforeach()
  if(NOT w32-pthreads_DIR AND EXISTS "${_prefix}/deps/w32-pthreads/w32-pthreadsConfig.cmake")
    set(w32-pthreads_DIR
        "${_prefix}/deps/w32-pthreads"
        CACHE PATH "w32-pthreads CMake package")
  endif()
  break()
endforeach()

set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")
