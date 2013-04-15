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
from pb_base.common import pp, to_unicode_or_bust, to_utf8_or_bust

from pb_base.errors import PbError
from pb_base.errors import FunctionNotImplementedError

from pb_base.object import PbBaseObjectError

from pb_base.app import PbApplicationError

from pb_base.cfg_app import PbCfgAppError
from pb_base.cfg_app import PbCfgApp

from pb_dbhandler.helper import init_db_argparser

import dns_admin

from dns_admin import default_config_dir
from dns_admin import default_bind_dir
from dns_admin import default_log_dir
from dns_admin import default_db_host
from dns_admin import default_db_port
from dns_admin import default_db_schema
from dns_admin import default_db_user

from dns_admin.errors import DnsAdminError
from dns_admin.errors import DnsAdminAppError

from dns_admin.handler import DnsAdminHandlerError
from dns_admin.handler import DnsAdminHandler

from dns_admin.translate import translator

__version__ = '0.2.1'

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

        self.handler = None
        """
        @ivar: The underlaying handler object.
        @type: DnsAdminHandler
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
                hide_default_config = True,
                need_config_file = False,
        )

        self.post_init()
        self._init_handler_object()
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
    def as_dict(self, short = False):
        """
        Transforms the elements of the object into a dict

        @param short: don't include local properties in resulting dict.
        @type short: bool

        @return: structure as dict
        @rtype:  dict
        """

        res = super(DnsAdminApp, self).as_dict(short = short)
        res['command'] = self.command
        res['simulate'] = self.simulate
        res['timeout'] = self.timeout

        return res

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

        self.arg_parser.add_argument(
                '--config-dir',
                action = "store",
                dest = "config_dir",
                help = (_("BIND configuration directory (Default: %r)") % (
                        default_config_dir)),
        )

        self.arg_parser.add_argument(
                '--bind-dir',
                action = "store",
                dest = "bind_dir",
                help = (_("BIND data directory (Default: %r)") % (
                        default_bind_dir)),
        )

        init_db_argparser(self.arg_parser)

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
    def init_cfg_spec(self):
        """
        Method to complete the initialisation of the config
        specification file. It adds some specific configuration options
        for the DNS admin application.

        """

        default_db_host = 'localhost'
        default_db_port = 5432
        default_db_schema = 'dns'
        default_db_user = 'dnsadmin'

        if not u'db' in self.cfg_spec:
            self.cfg_spec[u'db'] = {}
            self.cfg_spec.comments[u'db'].append('')
            self.cfg_spec.comments[u'db'].append('')
            self.cfg_spec.comments[u'db'].append(
                    u'Configuration parameters for the database connection')
            self.cfg_spec.comments[u'db'].append(
                    u'NOTE: the database password is not included in ' +
                    u'the configuration.')
            self.cfg_spec.comments[u'db'].append(
                    u'If a password is needed, then it should be ' +
                    u'included in a .pgpass file.')

        db_host_spec = u"string(default = '%s')" % (
                to_unicode_or_bust(default_db_host))
        if not u'host' in self.cfg_spec[u'db']:
            self.cfg_spec[u'db'][u'host'] = db_host_spec
            self.cfg_spec[u'db'].comments[u'host'].append('')
            self.cfg_spec[u'db'].comments[u'host'].append(
                    u'The hostname or IP address of the PostgreSQL ' +
                    u'database server')

        if not u'port' in self.cfg_spec[u'db']:
            self.cfg_spec[u'db'][u'port'] = (u'integer(min = 1, ' +
                    u'max = %d, default = %d)') % ((2**15 - 1), default_db_port)
            self.cfg_spec[u'db'].comments[u'port'].append('')
            self.cfg_spec[u'db'].comments[u'port'].append(
                    u'The TCP port number of the PostgreSQL database server')

        spec = u"string(default = '%s')" % (
                to_unicode_or_bust(default_db_schema))
        if not u'schema' in self.cfg_spec[u'db']:
            self.cfg_spec[u'db'][u'schema'] = spec
            self.cfg_spec[u'db'].comments[u'schema'].append('')
            self.cfg_spec[u'db'].comments[u'schema'].append(
                    u'The DNS database schema of the PostgreSQL ' +
                    u'database server')

        spec = u"string(default = '%s')" % (
                to_unicode_or_bust(default_db_user))
        if not u'user' in self.cfg_spec[u'db']:
            self.cfg_spec[u'db'][u'user'] = spec
            self.cfg_spec[u'db'].comments[u'user'].append('')
            self.cfg_spec[u'db'].comments[u'user'].append(
                    u'The DNS database user of the PostgreSQL ' +
                    u'database server')

    #--------------------------------------------------------------------------
    def _init_commands(self):

        self.cmds = []
        self.cmd = {}

        # version
        self.cmds.append('info')
        self.cmd['info'] = {}
        self.cmd['info']['argparse'] = self._init_args_info
        self.cmd['info']['handler'] = self._handle_info

    #--------------------------------------------------------------------------
    def _init_handler_object(self):

        config_dir = default_config_dir
        bind_dir = default_bind_dir
        log_dir = default_log_dir

        db_host = default_db_host
        db_port = default_db_host
        db_schema = default_db_schema
        db_user = default_db_user
        db_passwd = None

        if self.args.config_dir:
            config_dir = self.args.config_dir
        if self.args.bind_dir:
            bind_dir = self.args.bind_dir

        if u'db' in self.cfg:

            db_cfg = self.cfg[u'db']

            if u'host' in db_cfg:
                db_host = to_utf8_or_bust(db_cfg[u'host'])

            if u'port' in db_cfg:
                db_port = db_cfg[u'port']

            if u'schema' in db_cfg:
                db_schema = to_utf8_or_bust(db_cfg[u'schema'])

            if u'user' in db_cfg:
                db_user = to_utf8_or_bust(db_cfg[u'user'])

        if self.args.db_host:
            db_host = self.args.db_host

        if self.args.db_port:
            db_port = self.args.db_port

        if self.args.db_schema:
            db_schema = self.args.db_schema

        if self.args.db_user:
            db_user = self.args.db_user

        if self.args.db_password is not None:
            db_passwd = self.args.db_password

        sudo = False
        if os.geteuid():
            sudo = True

        if self.verbose > 2:
            args = {
                'config_dir': config_dir,
                'bind_dir': bind_dir,
                'log_dir': log_dir,
                'db_host': db_host,
                'db_port': db_port,
                'db_schema': db_schema,
                'db_user':  db_user,
                'db_passwd': db_passwd,
            }
            log.debug("Init args for handler:\n%s", pp(args))

        self.handler = DnsAdminHandler(
                db_host = db_host,
                db_port = db_port,
                db_schema = db_schema,
                db_user = db_user,
                db_passwd = db_passwd,
                config_dir = config_dir,
                bind_dir = bind_dir,
                log_dir = log_dir,
                auto_connect = False,
                simulate = self.simulate,
                appname = self.appname,
                verbose = self.verbose,
                base_dir = self.base_dir,
                sudo = sudo,
        )

    #--------------------------------------------------------------------------
    def _run(self):
        """The underlaying startpoint of the application."""

        log.debug("Starting ...")

        cmd = self.command
        method = self.cmd[cmd]['handler']
        method()

        log.debug("Ending ...")

    #--------------------------------------------------------------------------
    def _init_args_info(self):

        indent = ' ' * self.usage_term_len
        opts_str = _("general options")
        info_cmd_str = _('info command')

        usage = "%s [%s] info <%s>\n" % (self.appname, opts_str, info_cmd_str)
        usage += indent + "%s info -h|--help" % (self.appname)
        msg = _('Shows some informations about the %s application.') % (
                self.appname)

        parser_info = self._cmd_subparsers.add_parser(
                'info',
                help = msg,
                description = msg,
                usage = usage,
        )

        info_help = _("The information, you want to see.")
        info_help += " " + _("Possible values:")
        info_help += " version: " + _("shows version informations about the " +
                "application and the database model;")
        info_help += " default_config: " + _("display a generated default " +
                "configuration file;")
        info_help += " cfg_files: " + _("displays all possible standard " +
                "configuration files;")

        parser_info.add_argument(
                'info_cmd',
                nargs = '?',
                default = 'version',
                choices = ['version', 'default_config', 'cfg_files'],
                help = info_help,
        )

    #--------------------------------------------------------------------------
    def _handle_info(self):

        if self.args.info_cmd == 'default_config':
            self.show_default_config()
            sys.exit(0)

        if self.args.info_cmd == 'cfg_files':
            sys.stdout.write(_("Used default configuration files:") + "\n")
            for cfg_file in self.cfg_files:
                sys.stdout.write("    %r\n" % (cfg_file))
            sys.stdout.write("\n")
            sys.exit(0)

        sys.stdout.write(_("Version of %s: %s\n") % (self.appname, self.version))
        db_version = self.handler.get_dbmodel_version()
        sys.stdout.write(_("Version of database model: %s\n\n") % (db_version))

#==============================================================================

if __name__ == "__main__":

    pass

#==============================================================================

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
