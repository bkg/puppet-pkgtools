require 'puppet/provider/package'

Puppet::Type.type(:package).provide :pkgtools, :parent => Puppet::Provider::Package do
  desc "A pkgtools/pkgng provider for FreeBSD."

  commands :pkg => "/usr/local/sbin/pkg",
           :portinstall => "/usr/local/sbin/portinstall",
           :portupgrade => "/usr/local/sbin/portupgrade"
  confine :operatingsystem => :freebsd

  def self.instances
    packages = []
    groups = [:pkgname, :ensure, :name]
    pat = /^(\S+)-([^-\s]+)\s+(\S+)$/
    pkg('info', '-ao').lines.each do |line| 
      match = pat.match(line)
      pkginfo = Hash[groups.zip(match.captures)]
      packages << new(pkginfo.merge! :name => self.name)
    end
    packages
  end

  def install
    should = @resource.should(:ensure)
    # TODO: Handle install_options to allow make params to be passed through.
    portinstall('--batch', '--sudo', @resource[:name])
  end

  def latest
    status = pkg('version', '-vg', @resource[:name])
    match = /\S+-(\S+)[^\d]+([\d_.,]+)?.+/.match(status)
    current, newver = match.captures if match
    newver or current
  end

  def query
    cmd = ['query', '%n %v', @resource[:name]]
    begin
      pkgname, pkgver = pkg(*cmd).split ' '
    rescue Puppet::ExecutionFailure
      #raise Puppet::Error.new(pkgname)
    end
    #return {:ensure => (pkgver or :purged)}
    {:ensure => pkgver || :purged}
  end

  def uninstall
    pkg('delete', '-qy', @resource[:name])
  end

  def update
    # If the current status is purged, we must call install, not upgrade.
    return install if query[:ensure] == :purged
    portupgrade('--batch', '--sudo', @resource[:name])
  end
end
