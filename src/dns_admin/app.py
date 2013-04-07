#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
@author: Frank Brehm
@contact: frank.brehm@profitbricks.com
@copyright: © 2010 - 2013 by Frank Brehm, ProfitBricks GmbH, Berlin
@summary: The module for the application object of 'dns-admin'.
"""

# Standard modules
import sys 
import os
import logging

# Third party modules

# Own modules
from pb_base.common import pp, to_unicode_or_bust

from pb_base.errors import PbError
from pb_base.errors import FunctionNotImplementedError

from pb_base.object import PbBaseObjectError

from pb_base.app import PbApplicationError

from pb_base.cfg_app import PbCfgAppError
from pb_base.cfg_app import PbCfgApp

import dns_admin

from dns_admin.errors import DnsAdminError
from dns_admin.errors import DnsAdminAppError

from dns_admin.translate import translator

__version__ = '0.1.0'

_ = translator.lgettext
__ = translator.lngettext

log = logging.getLogger(__name__)

#==============================================================================
class DnsAdminApp(PbCfgApp):
    """
    Object class for the dns-admin script.
    """

    #--------------------------------------------------------------------------
    def __init__(self, appname = 'dns-admin', verbose = 0,
            version = dns_admin.__version__):
        """
        Initialisation of the dns-admin application object.
        """

        opts_str = _('options')
        indent = ' ' * self.usage_term_len
        usage = "%%(prog)s [%s] <%s> [%s]" % (
                _('general options'), _('subcommand'), _('subcmd options'))
        usage += '\n'
        usage += indent + "%(prog)s -h|--help\n"
        usage += indent + "%(prog)s -V|--version"

        desc = _("Script for database based administration of a BIND name server")

        self.db = None
        """
        @ivar: object for database handling operations and executing OS commands
        @type: DnsAdminDbHandler
        """
        self._command = None
        """
        @ivar: the SCST client command to execute
        @type: str
        """

        self._timeout = 10
        """
        @ivar: timout in seconds for all opening and IO operations
        @type: int
        """

        self._simulate = False
        """
        @ivar: simulation mode, nothing is really done
        @type: bool
        """

        self._cmd_subparsers = None
        """
        @ivar: a subparser list for argparse for the different commands
        @type: ArgumentParser
        """

        self._init_commands()

        super(DnsAdminApp, self).__init__(
                appname = appname,
                verbose = verbose,
                version = version,
                usage = usage,
                use_stderr = False,
                description = desc,
                cfg_dir = 'dns-admin',
                cfg_stem = 'dns-admin',
                hide_default_config = False,
                need_config_file = False,
        )

        self.post_init()
        self.initialized = True

    #--------------------------------------------------------------------------
    @property
    def command(self):
        """The dns-admin command to execute."""
        return self._command

    #------------------------------------------------------------
    @property
    def simulate(self):
        """Simulation mode, nothing is really done."""
        return self._simulate

    #------------------------------------------------------------
    @property
    def timeout(self):
        """timeout in seconds for all opening and IO operations"""
        return self._timeout

    @timeout.setter
    def timeout(self, value):
        self._timeout = int(value)

    #--------------------------------------------------------------------------
    def __del__(self):
        """Destructor, no parameters, no return value."""

        initialized = getattr(self, 'initialized', False)
        verbose = getattr(self, 'verbose', 0)
        if verbose > 1:
            log.info(_("Destroying %s application object."), self.appname)


    #--------------------------------------------------------------------------
    def init_arg_parser(self):
        """
        Method to initiate the argument parser.
        """

        super(self.__class__, self).init_arg_parser()

        self.arg_parser.add_argument(
                '-T', '--test', '--simulate', '--dry-run',
                action = "store_true",
                dest = "simulate",
                help = _("Simulation mode, nothing is really done."),
        )

        self._cmd_subparsers = self.arg_parser.add_subparsers(
                dest = 'command',
                title = _('Available subcommands'),
                help = (_('All available subcommands of %s.') % (self.appname)),
        )

        for cmd in self.cmds:
            method = self.cmd[cmd]['argparse']
            method()

    #--------------------------------------------------------------------------
    def perform_arg_parser(self):
        """
        Execute some actions after parsing the command line parameters.
        """

        super(self.__class__, self).perform_arg_parser()

        #if self.args.command == 'help':
        #    sys.stderr.write("No command given to execute.\n\n")
        #    self.arg_parser.print_usage(sys.stderr)
        #    self.exit(1)

        self._command = self.args.command.lower()
        self._simulate = getattr(self.args, 'simulate', False)

    #--------------------------------------------------------------------------
    def _init_commands(self):

        self.cmds = []
        self.cmd = {}

        # version
        self.cmds.append('version')
        self.cmd['version'] = {}
        self.cmd['version']['argparse'] = self._init_args_version
        self.cmd['version']['handler'] = self._handle_version

    #--------------------------------------------------------------------------
    def _run(self):
        """The underlaying startpoint of the application."""

        log.debug("Starting ...")

        cmd = self.command
        method = self.cmd[cmd]['handler']
        method()

        log.debug("Ending ...")

    #--------------------------------------------------------------------------
    def _init_args_version(self):

        opts_str = _("general options")

        usage = "%s [%s] version [-d]\n" % (self.appname, opts_str)
        usage += "       %s version -h|--help" % (self.appname)
        msg = _('Shows the version of the %s application and the database model.') % (
                self.appname)

        parser_version = self._cmd_subparsers.add_parser(
                'version',
                help = msg,
                description = msg,
                usage = usage,
        )

    #--------------------------------------------------------------------------
    def _handle_version(self):

        sys.stdout.write(_("Version of %s: %s\n\n") % (self.appname, self.version))

#==============================================================================

if __name__ == "__main__":

    pass

#==============================================================================

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
