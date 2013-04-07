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

__version__ = '0.1.0'

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

if __name__ == "__main__":
    pass

#==============================================================================

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
