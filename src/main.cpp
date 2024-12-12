// See LICENSE file at the root of LittleVulkanEngineContinuation project
#include <ThreadedLoggerForCPP/LoggerThread.h>

#include <ThreadedLoggerForCPP/LoggerFileSystem.hpp>
#include <ThreadedLoggerForCPP/LoggerGlobals.hpp>
#include <cstdlib>
#include <iostream>
#include <littlevulkanenginecontinuation/first_app.hpp>
#include <stdexcept>

// Global variable
std::string const g_exeGame = "LittleVulkanEngineContinuation";

// Function to initialize the threaded logger
void initThreadedLoggerForCPP(
    std::string const &projectDirectory, std::string const &logFileName, std::string const &gameSaveFolder) {
#pragma warning(push)
#pragma warning(disable : 4996)  // Disable warning for getenv
#ifdef _WIN32
  LoggerGlobals::UsernameDirectory = std::getenv("USERNAME");
#else
  LoggerGlobals::UsernameDirectory = std::getenv("USER");
#endif
#pragma warning(pop)
  // This is the folder that contains your src files like main.cpp
  LoggerGlobals::SrcProjectDirectory = projectDirectory;
  // Create Log File and folder
  LoggerGlobals::LogFolderPath =
      "C:\\Users\\" + LoggerGlobals::UsernameDirectory + "\\." + gameSaveFolder + "\\logging\\";
  LoggerGlobals::LogFilePath = "C:\\Users\\" + LoggerGlobals::UsernameDirectory + "\\." +
                               gameSaveFolder + "\\logging\\" + logFileName + ".log";
  LoggerGlobals::LogFolderBackupPath = "C:\\Users\\" + LoggerGlobals::UsernameDirectory + "\\." +
                                       gameSaveFolder + "\\logging\\LogBackup";
  LoggerGlobals::LogFileBackupPath = "C:\\Users\\" + LoggerGlobals::UsernameDirectory + "\\." +
                                     gameSaveFolder + "\\logging\\LogBackup\\" + logFileName + "-";

  LoggerThread::GetLoggerThread().StartLoggerThread(
      LoggerGlobals::LogFolderPath,
      LoggerGlobals::LogFilePath,
      LoggerGlobals::LogFolderBackupPath,
      LoggerGlobals::LogFileBackupPath);
}

int main() {
  try {
    initThreadedLoggerForCPP(g_exeGame, g_exeGame, g_exeGame);
    lve::FirstApp app{};
  } catch (const std::exception &e) {
    LOGGER_THREAD(LogLevel::ERRORING, e.what())
    LoggerThread::GetLoggerThread().ExitLoggerThread();
    return EXIT_FAILURE;
  }
  LoggerThread::GetLoggerThread().ExitLoggerThread();
  return EXIT_SUCCESS;
}
