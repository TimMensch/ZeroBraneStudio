-- saveonappswitch.lua
return {
  name = "Save all files on app switch",
  description = "A plugin to save all modified files when app focus is lost.",
  author = "Paul Kulchenko",
  onAppFocusLost = function() SaveAll(true) end,
}
