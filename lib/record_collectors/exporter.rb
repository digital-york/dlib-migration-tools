#!/usr/bin/env ruby
 require 'net/ssh'
 require 'shellwords'
# experiments to call batch file which is outside the vagrant box
# what is the best way to do this? install the fedora client on the virtual box?
class Exporter

  # run the export command on a fedora server for records identified in pid_file
  # then export to local machine ready for metadata extraction
  # rake metadata_extraction_tasks:export_records['yodlapp3.york.ac.uk',
  # <digilib_pwd>,<fedora_pwd>,<pidfile (without file extension)>,
  # <destination on local box>]
  def export_foxml(host, digilib_pwd, fed_password, pid_file, to_dir)
    ensure_empty_export_dir(host, digilib_pwd)
    bin_dir = '/opt/york/digilib/fedora/client/bin'
    export_dir = '/tmp/fedora_exports'
    log_dir = './logs'
    feduser = 'fedoraAdmin'
    fedhost = host.shellescape
    digilib_pwd = digilib_pwd.shellescape
    fed_password = fed_password.shellescape
    main_user = 'digilib'
    pidlist = pid_file.shellescape
    # pidlist = pidlist + '.txt'
    pidlist += '.txt'

    Net::SSH.start(fedhost, main_user, password: digilib_pwd) do|ssh|
      args = "#{feduser} #{fed_password} #{fedhost} #{export_dir} #{pidlist}"
      res = ssh.exec!("cd #{bin_dir} && './exportRecordBatch.sh' #{args}")
      puts 'res ' + res # worth leaving this as it gives any error output
    end
    base_url = main_user + '@' + fedhost
    #ftp_records = "sshpass -p #{digilib_pwd} sftp #{main_user}@#{fedhost}:#{export_dir}/*.xml #{to_dir}"
    #ftp_logfile = "sshpass -p #{digilib_pwd} sftp #{main_user}@#{fedhost}:#{bin_dir}/export.log #{log_dir}"
    ftp_records = "sshpass -p #{digilib_pwd} sftp #{base_url}:#{export_dir}/*.xml #{to_dir}"
    ftp_logfile = "sshpass -p #{digilib_pwd} sftp #{base_url}:#{bin_dir}/export.log #{log_dir}"

    system(ftp_records)
    system(ftp_logfile)
  end

  def ensure_empty_export_dir(host, digilib_pwd)
    host = host.shellescape
    digilib_pwd = digilib_pwd.shellescape
    Net::SSH.start(host, 'digilib', password: digilib_pwd) do |ssh|
      ssh.exec!('cd /tmp ; rm -r fedora_exports')
      ssh.exec!('cd /tmp ; mkdir fedora_exports')
    end
  end
end
