#!/usr/bin/env ruby
 require 'net/ssh'
# experiments to call batch file which is outside the vagrant box
# what is the best way to do this? install the fedora client on the virtual box?
class Exporter

  def bat_test
    puts "testing"
     ssh = Net::SSH.start('yodlapp3.york.ac.uk','digilib', :password => 'put password here') do|ssh|
    res = ssh.exec!('/opt/york/digilib/fedora/client/bin/echotest.sh')
    # should output 'this is only a test'
    puts 'res'+ res
    end
  end
end
