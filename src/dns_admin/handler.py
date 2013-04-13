#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
@author: Frank Brehm
@contact: frank.brehm@profitbricks.com
@organization: Profitbricks GmbH
@copyright: © 2010 - 2013 by Profitbricks GmbH
@license: GPL3
@summary: handler module for all underlaying actions
          in DNS administration applications.
"""

# Standard modules
import sys
import os
import os.path
import re
import logging

# Third party modules
import argparse

# Own modules
from pb_base.common import pp, to_unicode_or_bust, to_utf8_or_bust

from pb_base.object import PbBaseObjectError

from pb_base.errors import PbReadTimeoutError

from pb_base.handler import PbBaseHandlerError
from pb_base.handler import CommandNotFoundError

from pb_dbhandler.pgpass import PgPassFileError
from pb_dbhandler.pgpass import PgPassFileNotExistsError

from pb_dbhandler.handler import BaseDbHandlerError
from pb_dbhandler.handler import BaseDbHandler

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

from dns_admin.translate import translator

_ = translator.lgettext
__ = translator.lngettext

__version__ = '0.3.1'

log = logging.getLogger(__name__)

#==============================================================================
class DnsAdminHandlerError(BaseDbHandlerError, DnsAdminError):
    """
    Base error class
    """

    pass

#==============================================================================
class DnsAdminHandler(BaseDbHandler):
    """
    Handler class for all underlaying actions in DNS administration applications.
    """

    #--------------------------------------------------------------------------
    def __init__(self,
            db_host = 'localhost',
            db_port = 5432,
            db_schema = 'dns',
            db_user = 'dnsadmin',
            db_passwd = None,
            config_dir = default_config_dir,
            bind_dir = default_bind_dir,
            log_dir = default_log_dir,
            connect_params = None,
            auto_connect = False,
            simulate = False,
            pgpass_file = None,
            appname = None,
            verbose = 0,
            version = __version__,
            base_dir = None,
            use_stderr = False,
            sudo = False,
            quiet = False,
            ):
        """
        Initialisation of the  DNS administration handler object.

        @raise BaseDbError: on an exception on a uncoverable error.

        @param db_host: the host of the PostgreSQL database
        @type db_host: str
        @param db_port: the TCP port of PostgreSQL on the database machine.
        @type db_port: int
        @param db_schema: the database schema using on the DB.
        @type db_schema: str
        @param db_user: the database user using for connecting to DB.
        @type db_user: str
        @param db_passwd: the password of the database user connecting to DB.
        @type db_passwd: str
        @param config_dir: the BIND configuration directory
        @type config_dir: str
        @param bind_dir: the BIND data directory
        @type bind_dir: str
        @param log_dir: the logging directory of BIND
        @type log_dir: str
        @param connect_params: additional connect parameters for connecting
                               to database
        @type connect_params: dict
        @param auto_connect: establish connection at the end of initialization
                             of this object
        @type auto_connect: bool
        @param simulate: don't execute DDL or DMS operations, only display them,
        @type simulate: bool
        @param pgpass_file: a .pgpass file, where the password could be searched,
                            if no password was given.
                            If not given, $HOME/.pgpass will used.
        @type pgpass_file: str
        @type appname: str
        @param verbose: verbose level
        @type verbose: int
        @param version: the version string of the current object or application
        @type version: str
        @param base_dir: the base directory of all operations
        @type base_dir: str
        @param use_stderr: a flag indicating, that on handle_error() the output
                           should go to STDERR, even if logging has
                           initialized logging handlers.
        @type use_stderr: bool
        @param sudo: should the command executed by sudo by default
        @type sudo: bool
        @param quiet: don't display ouput of action after calling
        @type quiet: bool

        @return: None

        """

        super(DnsAdminHandler, self).__init__(
                db_host = db_host,
                db_port = db_port,
                db_schema = db_schema,
                db_user = db_user,
                db_passwd = db_passwd,
                connect_params = connect_params,
                auto_connect = auto_connect,
                simulate = simulate,
                pgpass_file = pgpass_file,
                appname = appname,
                verbose = verbose,
                base_dir = base_dir,
                use_stderr = use_stderr,
                sudo = sudo,
                quiet = quiet,
        )
        self.initialized = False

        self._config_dir = config_dir
        self._bind_dir = bind_dir
        self._log_dir = log_dir
        self.initialized = True

    #--------------------------------------------------------------------------
    @property
    def config_dir(self):
        """The BIND configuration directory."""
        return self._config_dir

    #--------------------------------------------------------------------------
    @property
    def bind_dir(self):
        """The BIND data directory."""
        return self._bind_dir

    #--------------------------------------------------------------------------
    @property
    def log_dir(self):
        """The logging directory of BIND."""
        return self._bind_dir

    #--------------------------------------------------------------------------
    def as_dict(self, short = False):
        """
        Transforms the elements of the object into a dict

        @param short: don't include local properties in resulting dict.
        @type short: bool

        @return: structure as dict
        @rtype:  dict
        """

        res = super(DnsAdminHandler, self).as_dict(short = short)
        res['config_dir'] = self.config_dir
        res['bind_dir'] = self.bind_dir
        res['log_dir'] = self.log_dir

        return res

    #--------------------------------------------------------------------------
    def get_dbmodel_version(self):
        """
        Retrieves the current database model version from table 'da_version'

        @return: the current database model version
        @rtype: str

        """

        if not self.connected:
            self.connect()
        if not self.cursor_opened:
            self.open_cursor()

        sql = 'SELECT * FROM da_dbmodel_version()'
        log.debug("excecuting SQL: %r", self.cursor.mogrify(sql))
        self.cursor.execute(sql)
        row = self.cursor.fetchone()

        return row[0]

#==============================================================================
class PortArgparseAction(argparse.Action):

    def __call__(self, parser, namespace, values, option_string = None):

        port = int(values)

        if port < 1:
            raise argparse.ArgumentError(self,
                    _("The port number of a PostgreSQL database must be greater than zero."))
        max_port = 2**15 - 1
        if port > max_port:
            raise argparse.ArgumentError(self,
                    (_("The port number of a PostgreSQL database must be less or equal %d.") % (max_port)))

        setattr(namespace, self.dest, port)

#==============================================================================
def init_db_argparser(parser):
    """
    Init of the typical database options with the given argument parser.

    @param parser: the argument parser object, where to add the database
                   arguments
    @type parser: argparse.ArgumentParser

    """

    db_group = parser.add_argument_group(_('Database options'))

    db_group.add_argument(
            '--db-host', '-H',
            action = "store",
            dest = 'db_host',
            metavar = 'HOST',
            help = (_("The host of the PostgreSQL database (Default: %r).") % (
                    default_db_host)),
    )

    db_group.add_argument(
            '--db-port', '-P',
            action = PortArgparseAction,
            dest = 'db_port',
            type = int,
            metavar = 'PORT',
            help = (_("The TCP port of PostgreSQL database on the database machine (Default: %d).") % (
                    default_db_port)),
    )

    db_group.add_argument(
            '--db-schema', '-S',
            action = "store",
            dest = 'db_schema',
            metavar = 'SCHEMA',
            help = (_("The database schema (database) used on DB host (Default: %r).") % (
                default_db_schema)),
    )

    db_group.add_argument(
            '--db-user', '-U',
            action = "store",
            dest = 'db_user',
            metavar = 'USER',
            help = (_("The database user using for connecting to DB (Default: %r).") % (
                    default_db_user)),
    )

    db_group.add_argument(
            '--db-password',
            action = "store",
            dest = 'db_password',
            metavar = 'PASSWORD',
            help = _("The password of the database user connecting to DB (Not recommended, better to use an entry in the $HOME/.pgpass file)."),
    )

#==============================================================================

if __name__ == "__main__":
    pass

#==============================================================================

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
