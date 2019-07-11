require "inspec/resources/command"
require "inspec/resources/powershell"

module Inspec::Resources
  # this resource returns additional system informatio
  class System < Inspec.resource(1)
    name "sys_info"
    supports platform: "unix"
    supports platform: "windows"

    desc "Use the user InSpec system resource to test for operating system properties."
    example <<~EXAMPLE
      describe sys_info do
        its('hostname') { should eq 'example.com' }
      end

      describe sys_info do
        its('hostname') { should eq 'example.com' }
      end

    EXAMPLE

    %w{ alias boot domain fqdn ip-address short NIS/YP }.each do |opt|
      define_method(opt.to_sym) do
        hostname(opt)
      end
    end

    # returns the hostname of the local system
    def hostname(opt = nil)
      os = inspec.os
      if os.linux? || os.darwin?
        opt = case opt
        when 'f', 'long', 'fqdn', 'full'
          '-f'
        when 'a', 'alias'
          '-a'
        when 'b', 'boot'
          '-b'
        when 'd', 'domain'
          '-d'
        when 'F', 'file'
          '-F'
        when 'i', 'ip-address'
          '-i'
        when 's', 'short'
          '-s'
        when 'y', 'yp', 'nis', 'NIS/YP'
          '-y'
        else
          nil
        end
        inspec.command("hostname #{opt}").stdout.chomp
      elsif os.windows?
        inspec.powershell("$env:computername").stdout.chomp
      else
        skip_resource "The `sys_info.hostname` resource is not supported on your OS yet."
      end
    end
  end
end
