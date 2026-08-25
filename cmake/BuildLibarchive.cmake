include(ExternalProject)

if(WIN32)
  # get bzip2 precompiled from https://github.com/philr/bzip2-windows use fetchcontent to download and extract the files
  include(FetchContent)
  FetchContent_Declare(
    bzip2 URL "https://github.com/philr/bzip2-windows/releases/download/v1.0.8.0/bzip2-dev-1.0.8.0-win-x64.zip")
  FetchContent_MakeAvailable(bzip2)
  # add the shared library to the IMPORTED library
  add_library(libbzip2 STATIC IMPORTED)
  target_include_directories(libbzip2 INTERFACE ${bzip2_SOURCE_DIR})
  set_property(TARGET libbzip2 PROPERTY IMPORTED_LOCATION ${bzip2_SOURCE_DIR}/libbz2-static.lib)

  # get openssl precompiled from https://wiki.overbyte.eu/arch/openssl-1.1.1w-win64.zip
  FetchContent_Declare(openssl URL "https://wiki.overbyte.eu/arch/openssl-1.1.1w-win64.zip")
  FetchContent_MakeAvailable(openssl)

  # Official Windows amd64 zips were withdrawn (404). Build from the source tarball.
  set(ENABLE_TEST
      OFF
      CACHE BOOL "" FORCE)
  set(ENABLE_TAR
      OFF
      CACHE BOOL "" FORCE)
  set(ENABLE_CPIO
      OFF
      CACHE BOOL "" FORCE)
  set(ENABLE_CAT
      OFF
      CACHE BOOL "" FORCE)
  set(ENABLE_WERROR
      OFF
      CACHE BOOL "" FORCE)
  set(ENABLE_INSTALL
      OFF
      CACHE BOOL "" FORCE)
  set(BUILD_SHARED_LIBS
      ON
      CACHE BOOL "" FORCE)

  include(FetchContent)
  FetchContent_Declare(
    libarchive
    URL "https://github.com/libarchive/libarchive/releases/download/v3.7.4/libarchive-3.7.4.tar.gz")
  FetchContent_MakeAvailable(libarchive)

  add_library(libarchive INTERFACE)
  if(TARGET archive)
    target_link_libraries(libarchive INTERFACE archive libbzip2)
    install(FILES $<TARGET_FILE:archive> DESTINATION ${CMAKE_SOURCE_DIR}/release/$<CONFIG>/obs-plugins/64bit)
  elseif(TARGET archive_static)
    target_link_libraries(libarchive INTERFACE archive_static libbzip2)
  else()
    message(FATAL_ERROR "libarchive CMake project did not create archive or archive_static")
  endif()
  if(EXISTS "${openssl_SOURCE_DIR}/libcrypto-1_1-x64${CMAKE_SHARED_LIBRARY_SUFFIX}")
    install(FILES ${openssl_SOURCE_DIR}/libcrypto-1_1-x64${CMAKE_SHARED_LIBRARY_SUFFIX}
            DESTINATION ${CMAKE_SOURCE_DIR}/release/$<CONFIG>/obs-plugins/64bit)
  endif()
else()
  if(APPLE)
    # Homebrew ships libarchive keg only, include dirs have to be set manually
    execute_process(
      COMMAND brew --prefix libarchive
      OUTPUT_VARIABLE LIBARCHIVE_PREFIX
      OUTPUT_STRIP_TRAILING_WHITESPACE COMMAND_ERROR_IS_FATAL ANY)
    set(LibArchive_INCLUDE_DIR "${LIBARCHIVE_PREFIX}/include")
    set(LibArchive_LIBRARIES "${LIBARCHIVE_PREFIX}/lib/libarchive.dylib")
  endif()

  find_package(LibArchive REQUIRED)
  find_package(BZip2 REQUIRED)

  add_library(libarchive INTERFACE)
  target_link_libraries(libarchive INTERFACE LibArchive::LibArchive BZip2::BZip2)
endif()
