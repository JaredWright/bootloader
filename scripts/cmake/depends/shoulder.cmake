if(ENABLE_BUILD_BOOTLOADER AND NOT WIN32)
    message(STATUS "Including dependency: shoulder")

    set(SHOULDER_SOURCE_DIR ${CACHE_DIR}/shoulder)
    set(SHOULDER_BUILD_DIR ${DEPENDS_DIR}/shoulder/${VMM_PREFIX}/build)

    download_dependency(
        shoulder
        URL          ${SHOULDER_URL}
        URL_MD5      ${SHOULDER_URL_MD5}
    )

    add_dependency(
        shoulder vmm
        CONFIGURE_COMMAND
            ${CMAKE_COMMAND} -E copy_directory ${SHOULDER_SOURCE_DIR} ${SHOULDER_BUILD_DIR}
        BUILD_COMMAND
            ${CMAKE_COMMAND} -E echo "TODO: Shoulder build step"
        INSTALL_COMMAND
            ${CMAKE_COMMAND} -E echo "TODO: Shoulder install step"
    )
endif()
