#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
@author: Frank Brehm
@contact: frank.brehm@profitbricks.com
@copyright: © 2010 - 2013 by Frank Brehm, Berlin
@summary: Encapsulation module for access to the nameservers table
"""

# Standard modules
import sys
import os
import re
import logging

# Third party modules
import IPy
from IPy import IP

# Own modules
from pb_base.common import to_unicode_or_bust, to_utf8_or_bust
from pb_base.common import pp, to_bool

from pb_base.object import PbBaseObjectError
from pb_base.object import PbBaseObject

from pb_base.errors import PbReadTimeoutError, CallAbstractMethodError

from pb_dbhandler import BaseDbError

from pb_dbhandler.handler import BaseDbHandlerError

from dns_admin.errors import DnsAdminError
from dns_admin.errors import DnsDbObjectError
from dns_admin.errors import NullEntityValue

from dns_admin.handler import DnsAdminHandlerError

from dns_admin.translate import translator

_ = translator.lgettext
__ = translator.lngettext

__version__ = '0.2.0'

#==============================================================================
class Nameserver(PbBaseObject):
    """
    Encapsulation object for one particular nameserver.
    """

	#--------------------------------------------------------------------------
    def __init__(self,
            ns_id,
            ns_name,
            fqdn,
            admin_user,
            mgmt_address,
            config_dir,
            bind_dir,
            enabled = True,
            description = None,
            appname = None,
            verbose = 0,
            version = __version__,
            base_dir = None,
            use_stderr = False,
            initialized = False,
            ):
        """
        Initialisation of the nameserver object.

        @raise DnsDbObjectError: on a uncoverable error.

        @param ns_id: The unique numeric name server ID.
        @type ns_id: int
        @param ns_name: The unique name of the name server.
        @type ns_name: str
        @param fqdn: The Full Qualified Domain (a.k.a. Host) Name
                     of the name server.
        @type fqdn: str
        @param admin_user: The administration user used for
                           administration via SSH.
        @type admin_user: str
        @param mgmt_address: The IP address to use to connect to via SSH
                             for administration purposes.
        @type mgmt_address: IPy.IP or str
        @param config_dir: The directory on the name server containing
                           the name.conf and similar files.
        @type config_dir: str
        @param bind_dir: The directory on the name server containing
                         zone files, journals a.s.o.
        @type bind_dir: str
        @param enabled: Is this name server enabled for administration.
        @type enabled: bool
        @param description: Some kind of description of this name server.
        @type description: str or None

        @param appname: name of the current running application
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
        @param initialized: initialisation is complete after __init__()
                            of this object
        @type initialized: bool

        @return: None
        """

        super(Nameserver, self).__init__(
                appname = appname,
                verbose = verbose,
                version = version,
                base_dir = base_dir,
                use_stderr = use_stderr,
                initialized = False,
        )

        if ns_id is None:
            raise NullEntityValue('Nameserver', 'ns_id')
        self._ns_id = int(ns_id)

        if ns_name is None:
            raise NullEntityValue('Nameserver', 'ns_name')
        self._ns_name = str(ns_name)

        if fqdn is None:
            raise NullEntityValue('Nameserver', 'fqdn')
        self._fqdn = str(fqdn)

        if admin_user is None:
            raise NullEntityValue('Nameserver', 'admin_user')
        self._admin_user = str(admin_user)

        if mgmt_address is None:
            raise NullEntityValue('Nameserver', 'mgmt_address')
        if isinstance(mgmt_address, IP):
            self._mgmt_address = mgmt_address
        else:
            self._mgmt_address = IP(mgmt_address)

        if config_dir is None:
            raise NullEntityValue('Nameserver', 'config_dir')
        self._config_dir = str(config_dir)

        if bind_dir is None:
            raise NullEntityValue('Nameserver', 'bind_dir')
        self._bind_dir = str(bind_dir)

        self._enabled = to_bool(enabled)

        self._description = None
        if description:
            d = str(description).strip()
            if d:
                self._description = d

        self.initialized = True

    #-------------------------------------------------------
    @property
    def ns_id(self):
        """The unique numeric name server ID."""
        return self._ns_id

    @property
    def id(self):
        """The unique numeric name server ID."""
        return self._ns_id

    #-------------------------------------------------------
    @property
    def ns_name(self):
        """The unique name of the name server."""
        return self._ns_name

    @property
    def name(self):
        """The unique name of the name server."""
        return self._ns_name

    #-------------------------------------------------------
    @property
    def fqdn(self):
        """The Full Qualified Domain (a.k.a. Host) Name of the name server."""
        return self._fqdn

    #-------------------------------------------------------
    @property
    def admin_user(self):
        """The administration user used for administration via SSH."""
        return self._admin_user

    #-------------------------------------------------------
    @property
    def mgmt_address(self):
        """
        The IP address to use to connect to via SSH  for administration purposes.
        """
        return self._mgmt_address

    @property
    def address(self):
        """
        The IP address to use to connect to via SSH  for administration purposes.
        """
        return self._mgmt_address

    #-------------------------------------------------------
    @property
    def config_dir(self):
        """
        The directory on the name server containing
        the name.conf and similar files.
        """
        return self._config_dir

    #-------------------------------------------------------
    @property
    def bind_dir(self):
        """
        The directory on the name server containing
        zone files, journals a.s.o.
        """
        return self._bind_dir

    #-------------------------------------------------------
    @property
    def enabled(self):
        """Is this name server enabled for administration."""
        return self._enabled

    #-------------------------------------------------------
    @property
    def description(self):
        """Some kind of description of this name server."""
        return self._description

#==============================================================================

if __name__ == "__main__":
    pass

#==============================================================================
# vim: fileencoding=utf-8 filetype=python ts=4 et
