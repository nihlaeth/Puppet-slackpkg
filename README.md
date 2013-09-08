Puppet-slackpkg
===============

Slackpkg package provider module for puppet.

About
===================

This provides very basic support for slackpkg / slackware to puppet.
At this time the ensure=> absent option does not function yet.

Please excuse my Ruby, I'm a python programmer.

Written by: nihlaeth


Getting started
===================

Place this directory inside /etc/puppet/modules. That's all really.
If Puppet does not use slackpkg by default just add:
	
	provider => 'slackpkg',

to your packet declaration.


To do
===================

* Make the query function actually return a list of installed packages (this will fix ensure=>absent)
* Have the remove function check if the package is at 'latest'.



