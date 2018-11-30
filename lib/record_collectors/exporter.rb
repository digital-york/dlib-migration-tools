#!/usr/bin/env ruby
 require 'net/ssh'
 require 'shellwords'
# experiments to call batch file which is outside the vagrant box
# what is the best way to do this? install the fedora client on the virtual box?
class Exporter

  # run the export command on a fedora server for records identified in pid_file
  def export_foxml(host, digilib_pwd, fed_password, pid_file, export_dir, to_dir)
    puts 'preparing to export records'
    bindir = '/opt/york/digilib/fedora/client/bin'
    feduser = 'fedoraAdmin'
    fedhost = host.shellescape
    digilib_pwd = digilib_pwd.shellescape
    fed_password = fed_password.shellescape
    export_dir = export_dir.shellescape
    user = 'digilib'
    pidlist = pid_file.shellescape
    Net::SSH.start(fedhost, user, :password => digilib_pwd) do|ssh|
      args = "#{feduser} #{fed_password} #{fedhost} #{export_dir} #{pidlist}"
      res = ssh.exec!("cd #{bindir} && './exportRecordBatch.sh' #{args}")
      puts 'res ' + res
    end
    exec("sshpass -p #{digilib_pwd} sftp #{user}@#{fedhost}:#{export_dir}/*.xml #{to_dir}")
  end
end
