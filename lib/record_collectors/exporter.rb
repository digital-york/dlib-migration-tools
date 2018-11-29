#!/usr/bin/env ruby
 require 'net/ssh'
 require 'shellwords'
# experiments to call batch file which is outside the vagrant box
# what is the best way to do this? install the fedora client on the virtual box?
class Exporter

  def export_foxml(digilib_user, digilib_password, fed_password, export_dir)
    puts 'testing'
    bindir = '/opt/york/digilib/fedora/client/bin'
    feduser = 'fedoraAdmin'
    fedhost = 'yodlapp3.york.ac.uk'
    # exportdir = '/opt/york/digilib/foxml_exports'
    pidlist = './app3pids.txt'
    Net::SSH.start('yodlapp3.york.ac.uk', digilib_user, :password => digilib_password) do|ssh|
      # args = "fedoraAdmin $admin_password yodlapp3.york.ac.uk /opt/york/digilib/foxml_exports app3pids.txt".shellescape
      res = ssh.exec!("cd #{bindir} && './exportRecordBatch.sh' #{feduser} #{fed_password} #{fedhost} #{export_dir} #{pidlist}" )
      puts 'res ' + res
    end
  end
end
