# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.17

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Disable VCS-based implicit rules.
% : %,v


# Disable VCS-based implicit rules.
% : RCS/%


# Disable VCS-based implicit rules.
% : RCS/%,v


# Disable VCS-based implicit rules.
% : SCCS/s.%


# Disable VCS-based implicit rules.
% : s.%


.SUFFIXES: .hpux_make_needs_suffix_list


# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /home/maximilian/.local/share/JetBrains/Toolbox/apps/CLion/ch-0/202.7319.72/bin/cmake/linux/bin/cmake

# The command to remove a file.
RM = /home/maximilian/.local/share/JetBrains/Toolbox/apps/CLion/ch-0/202.7319.72/bin/cmake/linux/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/maximilian/Documents/work/notifi/linux

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/maximilian/Documents/work/notifi/linux/cmake-build-debug

# Utility rule file for flutter_assemble.

# Include the progress variables for this target.
include flutter/CMakeFiles/flutter_assemble.dir/progress.make

flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/libflutter_linux_gtk.so
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_basic_message_channel.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_binary_codec.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_binary_messenger.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_dart_project.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_engine.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_json_message_codec.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_json_method_codec.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_message_codec.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_method_call.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_method_channel.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_method_codec.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_method_response.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_plugin_registrar.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_plugin_registry.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_standard_message_codec.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_standard_method_codec.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_string_codec.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_value.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_view.h
flutter/CMakeFiles/flutter_assemble: ../flutter/ephemeral/flutter_linux/flutter_linux.h


../flutter/ephemeral/libflutter_linux_gtk.so:
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --blue --bold --progress-dir=/home/maximilian/Documents/work/notifi/linux/cmake-build-debug/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Generating ../../flutter/ephemeral/libflutter_linux_gtk.so, ../../flutter/ephemeral/flutter_linux/fl_basic_message_channel.h, ../../flutter/ephemeral/flutter_linux/fl_binary_codec.h, ../../flutter/ephemeral/flutter_linux/fl_binary_messenger.h, ../../flutter/ephemeral/flutter_linux/fl_dart_project.h, ../../flutter/ephemeral/flutter_linux/fl_engine.h, ../../flutter/ephemeral/flutter_linux/fl_json_message_codec.h, ../../flutter/ephemeral/flutter_linux/fl_json_method_codec.h, ../../flutter/ephemeral/flutter_linux/fl_message_codec.h, ../../flutter/ephemeral/flutter_linux/fl_method_call.h, ../../flutter/ephemeral/flutter_linux/fl_method_channel.h, ../../flutter/ephemeral/flutter_linux/fl_method_codec.h, ../../flutter/ephemeral/flutter_linux/fl_method_response.h, ../../flutter/ephemeral/flutter_linux/fl_plugin_registrar.h, ../../flutter/ephemeral/flutter_linux/fl_plugin_registry.h, ../../flutter/ephemeral/flutter_linux/fl_standard_message_codec.h, ../../flutter/ephemeral/flutter_linux/fl_standard_method_codec.h, ../../flutter/ephemeral/flutter_linux/fl_string_codec.h, ../../flutter/ephemeral/flutter_linux/fl_value.h, ../../flutter/ephemeral/flutter_linux/fl_view.h, ../../flutter/ephemeral/flutter_linux/flutter_linux.h, _phony_"
	cd /home/maximilian/Documents/work/notifi/linux/cmake-build-debug/flutter && /home/maximilian/.local/share/JetBrains/Toolbox/apps/CLion/ch-0/202.7319.72/bin/cmake/linux/bin/cmake -E env FLUTTER_ROOT="/home/maximilian/flutter" PROJECT_DIR="/home/maximilian/Documents/work/notifi" DART_DEFINES="flutter.inspector.structuredErrors%3Dtrue" DART_OBFUSCATION="false" TRACK_WIDGET_CREATION="true" TREE_SHAKE_ICONS="false" PACKAGE_CONFIG=".packages" FLUTTER_TARGET="/home/maximilian/Documents/work/notifi/lib/main.dart" /home/maximilian/flutter/packages/flutter_tools/bin/tool_backend.sh linux-x64 Debug

../flutter/ephemeral/flutter_linux/fl_basic_message_channel.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_basic_message_channel.h

../flutter/ephemeral/flutter_linux/fl_binary_codec.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_binary_codec.h

../flutter/ephemeral/flutter_linux/fl_binary_messenger.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_binary_messenger.h

../flutter/ephemeral/flutter_linux/fl_dart_project.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_dart_project.h

../flutter/ephemeral/flutter_linux/fl_engine.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_engine.h

../flutter/ephemeral/flutter_linux/fl_json_message_codec.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_json_message_codec.h

../flutter/ephemeral/flutter_linux/fl_json_method_codec.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_json_method_codec.h

../flutter/ephemeral/flutter_linux/fl_message_codec.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_message_codec.h

../flutter/ephemeral/flutter_linux/fl_method_call.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_method_call.h

../flutter/ephemeral/flutter_linux/fl_method_channel.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_method_channel.h

../flutter/ephemeral/flutter_linux/fl_method_codec.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_method_codec.h

../flutter/ephemeral/flutter_linux/fl_method_response.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_method_response.h

../flutter/ephemeral/flutter_linux/fl_plugin_registrar.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_plugin_registrar.h

../flutter/ephemeral/flutter_linux/fl_plugin_registry.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_plugin_registry.h

../flutter/ephemeral/flutter_linux/fl_standard_message_codec.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_standard_message_codec.h

../flutter/ephemeral/flutter_linux/fl_standard_method_codec.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_standard_method_codec.h

../flutter/ephemeral/flutter_linux/fl_string_codec.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_string_codec.h

../flutter/ephemeral/flutter_linux/fl_value.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_value.h

../flutter/ephemeral/flutter_linux/fl_view.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/fl_view.h

../flutter/ephemeral/flutter_linux/flutter_linux.h: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate ../flutter/ephemeral/flutter_linux/flutter_linux.h

flutter/_phony_: ../flutter/ephemeral/libflutter_linux_gtk.so
	@$(CMAKE_COMMAND) -E touch_nocreate flutter/_phony_

flutter_assemble: flutter/CMakeFiles/flutter_assemble
flutter_assemble: ../flutter/ephemeral/libflutter_linux_gtk.so
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_basic_message_channel.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_binary_codec.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_binary_messenger.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_dart_project.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_engine.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_json_message_codec.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_json_method_codec.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_message_codec.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_method_call.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_method_channel.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_method_codec.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_method_response.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_plugin_registrar.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_plugin_registry.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_standard_message_codec.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_standard_method_codec.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_string_codec.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_value.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/fl_view.h
flutter_assemble: ../flutter/ephemeral/flutter_linux/flutter_linux.h
flutter_assemble: flutter/_phony_
flutter_assemble: flutter/CMakeFiles/flutter_assemble.dir/build.make

.PHONY : flutter_assemble

# Rule to build all files generated by this target.
flutter/CMakeFiles/flutter_assemble.dir/build: flutter_assemble

.PHONY : flutter/CMakeFiles/flutter_assemble.dir/build

flutter/CMakeFiles/flutter_assemble.dir/clean:
	cd /home/maximilian/Documents/work/notifi/linux/cmake-build-debug/flutter && $(CMAKE_COMMAND) -P CMakeFiles/flutter_assemble.dir/cmake_clean.cmake
.PHONY : flutter/CMakeFiles/flutter_assemble.dir/clean

flutter/CMakeFiles/flutter_assemble.dir/depend:
	cd /home/maximilian/Documents/work/notifi/linux/cmake-build-debug && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/maximilian/Documents/work/notifi/linux /home/maximilian/Documents/work/notifi/linux/flutter /home/maximilian/Documents/work/notifi/linux/cmake-build-debug /home/maximilian/Documents/work/notifi/linux/cmake-build-debug/flutter /home/maximilian/Documents/work/notifi/linux/cmake-build-debug/flutter/CMakeFiles/flutter_assemble.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : flutter/CMakeFiles/flutter_assemble.dir/depend

