# SPDX-FileCopyrightText: 2024 Chris Rizzitello <sithlord48@gmail.com>
# SPDX-License-Identifier: MIT

create_library(
    TARGET base
    TYPE STATIC
    SKIP_ALIAS_HEADERS
    HEADERS
        ELevel.h
        Event.h
        EventQueue.h
        EventQueueTimer.h
        EventTarget.h
        EventTypes.h
        finally.h
        Fwd.h
        IEventQueue.h
        IEventQueueBuffer.h
        ILogOutputter.h
        Log.h
        log_outputters.h
        PriorityQueue.h
        SimpleEventQueueBuffer.h
        Stopwatch.h
        String.h
        Time.h
        Unicode.h
        UniquePtrContainer.h
        XBase.h
    SOURCES
        EventQueue.cpp
        EventTarget.cpp
        Log.cpp
        log_outputters.cpp
        SimpleEventQueueBuffer.cpp
        Stopwatch.cpp
        String.cpp
        Time.cpp
        Unicode.cpp
        XBase.cpp
)
set(CMAKE_INCLUDE_CURRENT_DIR ON)

target_link_libraries(base cisp::common)
