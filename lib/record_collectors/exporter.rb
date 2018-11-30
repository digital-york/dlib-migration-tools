#!/usr/bin/env ruby
 require 'net/ssh'
 require 'shellwords'
# experiments to call batch file which is outside the vagrant box
# what is the best way to do this? install the fedora client on the virtual box?
class Exporter

  def export_foxml(host, digilib_password, fed_password, pid_file, export_dir)
    puts 'preparing to export records'
    bindir = '/opt/york/digilib/fedora/client/bin'
    feduser = 'fedoraAdmin'
    fedhost = host.shellescape
    digilib_password = digilib_password.shellescape
    fed_password = fed_password.shellescape
    export_dir = export_dir.shellescape
    digilib_user = 'digilib'
    pidlist = pid_file.shellescape
    Net::SSH.start(fedhost, digilib_user, :password => digilib_password) do|ssh|
      args = "#{feduser} #{fed_password} #{fedhost} #{export_dir} #{pidlist}"
      res = ssh.exec!("cd #{bindir} && './exportRecordBatch.sh' #{args}")
      puts 'res ' + res
    end
  end
end
