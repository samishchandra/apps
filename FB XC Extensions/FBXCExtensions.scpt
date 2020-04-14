# (c) Facebook, Inc. and its affiliates. Confidential and proprietary.

use scripting additions
use framework "Foundation"
property NSString : a reference to current application's NSString

# Helpers

on getHomeDir()
  return runShellCommand("echo $HOME")
end getHomeDir

on getChangeDirFBSourceCmd()
  return "cd $HOME/fbsource;"
end changeDirectoryCmd

on readFile(filePath)
  set fileHandle to open for access filePath
  set fileContents to text of (read fileHandle)
  close access fileHandle
  return fileContents
end readFile

on revealInFinder(filePath)
  tell application "Finder"
    reopen
    activate
    set selection to {}
    set target of window 1 to (POSIX file filePath)
  end tell
end revealInFinder

on runShellCommand(command)
  set fbPath to "/opt/facebook/bin:/usr/local/bin:/opt/homebrew/bin:/opt/facebook/hg/bin"
  set prefaceScript to "export PATH=$PATH" & ":" & fbPath & " ; "
  do shell script prefaceScript & command
end runShellCommand

on removeSubString(oldString, subString)
  set myString to NSString's stringWithString:oldString
  set newString to myString's stringByReplacingOccurrencesOfString:subString withString:""
  newString as text
end removeSubString

on removeLastComponent(filePath)
  set filePathString to NSString's stringWithString:filePath
  set removedLastComponentFilePathString to filePathString's stringByDeletingLastPathComponent
  removedLastComponentFilePathString as text
end removeLastComponent

# Xcode functionality

on getSanitizedPath(filePath)
  return "\"" & filePath & "\""
end getSanitizedPath

on getProjectPath()
  tell application "Xcode"
    tell active workspace document
      return path
    end tell
  end tell
  removeLastComponent(filePath)
end getProjectPath

on getFilePath()
  tell application "Xcode"
    set win to first window
    set title to name of win
    set docs to every document
    repeat with doc in docs
      set p to path of doc
      if p contains (word 1 of title) then
        return p
      end if
    end repeat
  end tell
end getFilePath

on getFileName()
  tell application "Xcode"
    set win to first window
    set title to name of win
    set docs to every document
    repeat with doc in docs
      set p to path of doc
      if p contains (word 1 of title) then
        return name of doc
      end if
    end repeat
  end tell
end getFileName

on performSaveFileInXcode()
  tell application "System Events"
    tell process "Xcode"
      # set frontmost to true
      click menu item "Save" of menu "File" of menu bar 1
    end tell
  end tell
end performSaveFileInXcode

# Uncrustify

on getUncrustifyBin()
  return getHomeDir() & "/fbsource/tools/third-party/uncrustify/uncrustify"
end getUncrustifyBin

on getUncrustifyConfig()
  return getHomeDir() & "/fbsource/tools/third-party/uncrustify/uncrustify.cfg"
end getUncrustifyConfig

on revealUncrustifyConfigFile()
  set uncrustifyConfig to getUncrustifyConfig()
  revealInFinder(uncrustifyConfig)
end revealUncrustifyConfigFile

on uncrustifyFormat(filePath)
  set uncrustifyBin to getUncrustifyBin()
  set uncrustifyConfig to getUncrustifyConfig()
  set uncrustifyCmd to uncrustifyBin & " -c " & uncrustifyConfig & " -f " & getSanitizedPath(filePath)
  runShellCommand(uncrustifyCmd)
end uncrustifyFormat

#on uncrustifyFormatCurrentFilePath()
#  set filePath to getFilePath()
#  uncrustifyFormat(filePath)
#end uncrustifyFormatCurrentFilePath
#
#on arcFormatCurrentFilePath()
#  set filePath to getFilePath()
#  set arcFormatCmd to "arc f " & getSanitizedPath(filePath)
#  runShellCommand(getChangeDirFBSourceCmd() & arcFormatCmd)
#end arcFormatCurrentFilePath
#
#on updateContents(newContents)
#  set filePath to getFilePath()
#  tell application "Xcode"
#    set docs to every source document
#    repeat with doc in docs
#      set p to path of doc
#      if p equals filePath then
#        set text of doc to newContents
#      end if
#    end repeat
#  end tell
#end run
