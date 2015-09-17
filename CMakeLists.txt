cmake_minimum_required (VERSION 3.0.0)
project (APMProject)

include(APM.cmake)

APM_add_module_repository(moduleRepo FOLDER "${CMAKE_CURRENT_SOURCE_DIR}/../APM_CMakeDoxygen")

require_package(CMakeDoxygen VERSION 1.0)

if(NOT CMakeDoxygen_FOUND)
  APM_message(FATAL "NOT FOUND")
else()
  configure_file(Doxyfile.in Doxyfile @ONLY)
  set(DOXYGEN_EXECUTABLE "C:/Logiciels/Doxygen/doxygen.exe")
  find_package(Doxygen)

  if(DOXYGEN_FOUND)
    execute_process(COMMAND ${DOXYGEN_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR})
  endif()
endif()
