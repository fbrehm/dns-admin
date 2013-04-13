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

from dns_admin.errors import DnsAdminError
from dns_admin.errors import DnsAdminAppError

from dns_admin.translate import translator

_ = translator.lgettext
__ = translator.lngettext

__version__ = '0.1.0'

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



#==============================================================================

if __name__ == "__main__":
    pass

#==============================================================================

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
