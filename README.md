Puppet-slackpkg
===============

Slackpkg package provider module for puppet.

About
===================

This provides very basic support for slackpkg / slackware to puppet.

Please excuse my Ruby, I'm a python programmer.

Written by: nihlaeth


Getting started
===================

Place this directory inside /etc/puppet/modules. That's all really.
If Puppet does not use slackpkg by default just add:
	
	provider => 'slackpkg',

to your packet declaration.

In order to have slackpkg work without a menu you need to set the batch and
default answer options in /etc/slackpkg/slackpkg.conf. Puppet can do this
for you.

To do
===================

* Have the remove function get package name from pkglist.
* Add -batch and -default-answer=y arguments so the slackpkg configuration does not need modification.


