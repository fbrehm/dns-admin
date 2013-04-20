#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
@author: Frank Brehm
@contact: frank.brehm@profitbricks.com
@copyright: © 2010 - 2013 by Frank Brehm, ProfitBricks GmbH, Berlin
@summary: module for some common used error classes
"""

# Standard modules
import errno

# Own modules
from dns_admin.translate import translator

from pb_base.errors import PbError
from pb_base.cfg_app import PbCfgAppError

from pb_dbhandler.handler import BaseDbHandlerError

__version__ = '0.3.0'

_ = translator.lgettext
__ = translator.lngettext

#==============================================================================
class DnsAdminError(PbError):
    """
    Base error class for all other self defined exceptions.
    """

    pass

#==============================================================================
class DnsAdminAppError(DnsAdminError, PbCfgAppError):
    """
    Base class of all exceptions in DnsAdminApp and DnsDbAdminApp class.
    """

    pass

#==============================================================================
class DnsAdminHandlerError(BaseDbHandlerError, DnsAdminError):
    """
    Base error class
    """

    pass

#==============================================================================
class DnsDbObjectError(DnsAdminError):
    """
    Special exception class for exceptions happend in methods of
    database encapsulation classes.
    """
    pass

#==============================================================================
class NullEntityValue(DnsDbObjectError):
    """
    Special Exception for entity propertie, which don't may be None.
    """

	#--------------------------------------------------------------------------
    def __init__(self, entity_name, cls):
        self.entity_name = entity_name
        self.cls = cls

	#--------------------------------------------------------------------------
    def __str__(self):
        return _("Property %(ent)r of class %(cls)s may not be None.") % {
                'ent': self.entity_name, 'cls': self.cls}

#==============================================================================

if __name__ == "__main__":
    pass

#==============================================================================

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
