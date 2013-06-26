local qc
local win = ide.osname == "Windows"
local debug = 'D'

return {
  name = "QuickCharge Game",
  description = "QuickCharge cross-platform library Game",
  api = {"game", "qc"},
  frun = function(self,wfilename,rundebug)
    qc = qc or ide.config.path.qc -- check if the path is configured
    if not qc then
      local sep = win and ';' or ':' ;

      local default =
           win and ([[C:\Program Files\qc]]..sep..[[D:\Program Files\qc]]..sep..
                    [[C:\Program Files (x86)\qc]]..sep..[[D:\Program Files (x86)\qc]]..sep)
        or ''
      local path = ide.config.path.projectdir .. sep .. default
                 ..(os.getenv('PATH') or '')..sep
                 ..(os.getenv('HOME') and os.getenv('HOME') .. '/bin' or '')
      local paths = {}
      for p in path:gmatch("[^"..sep.."]+") do
        qc = qc or GetFullPathIfExists(p, win and 'qcGame'..debug..'.exe' or 'qcGame'..debug)
        table.insert(paths, p)
      end
      if not qc then
        DisplayOutput("Can't find qcGame"..debug.." executable in any of the folders in PATH or project folder: "
          ..table.concat(paths, ", ").."\n")
        return
      end
    end

    if rundebug then
      -- start running the application right away
      DebuggerAttachDefault({startwith = 'lua/init.lua',
        runstart = ide.config.debugger.runonstart ~= false})
    end

    file = file or wfilename:GetFullPath()

    local mdb = MergeFullPath(GetPathWithSep(ide.editorFilename), "lualibs/mobdebug/?.lua")
    local cmd = ('"%s" %s'):format(qc, (rundebug and ("-d "..mdb)) or "")

    -- CommandLineRun(cmd,wdir,tooutput,nohide,stringcallback,uid,endcallback)
    return CommandLineRun(cmd,self:fworkdir(wfilename),true,false,nil,nil,
      function() ide.debugger.pid = nil end)
  end,
  fprojdir = function(self,wfilename)
    return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
  end,
  fworkdir = function(self,wfilename)
    return ide.config.path.projectdir or wfilename:GetPath(wx.wxPATH_GET_VOLUME)
  end,
  hasdebugger = true,
  fattachdebug = function(self) DebuggerAttachDefault() end,
  scratchextloop = true,
}
