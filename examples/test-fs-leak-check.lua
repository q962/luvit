local uv = require('uv');
function p() end

p("uv", uv)
p("process", process)

function loop()
  local count = 0
  uv.fs_open("license.txt", 'r', "0644", function (fd)
    p("on_open", {fd=fd})
    uv.fs_read(fd, 0, 4096, function (chunk, length)
      p("on_read", {chunk=chunk, length=length})
      uv.fs_close(fd, function ()
        p("on_close")
        check()
      end)
    end)
  end)

  uv.fs_mkdir("temp", "0755", function ()
    p("on_mkdir")
    uv.fs_rmdir("temp", function ()
      p("on_rmdir")
      check()
    end)
  end)

  uv.fs_open("tempfile", "w", "0644", function (fd)
    p("on_open2", {fd=fd})
    uv.fs_write(fd, 0, "Hello World\n", function (bytes_written)
      p("on_write", {bytes_written=bytes_written})
      uv.fs_close(fd, function ()
        p("on_close2")
        uv.fs_unlink("tempfile", function ()
          p("on_unlink")
          check()
        end)
      end)
    end)
  end)
  
  function check()
    count = count + 1
    if (count == 3) then
      return loop()
    end
  end
  
end

loop()
