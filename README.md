puppet-pkgtools
===============

A package provider for FreeBSD using pkgtools and pkgng.

Be sure you have followed the set up instructions for switching to
[pkgng](https://wiki.freebsd.org/pkgng). Simply specify 'pkgtools' as your
package provider and you are ready to go. This provider supports present,
latest, and absent package states.

### Example ###

    package { 'tmux':
      ensure => latest,
      provider => 'pkgtools' 
    }
