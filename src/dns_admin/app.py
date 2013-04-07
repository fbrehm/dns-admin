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

from dns_admin.errors import DnsAdminError
from dns_admin.errors import DnsAdminAppError

from dns_admin.translate import translator

__version__ = '0.1.0'

_ = translator.lgettext
__ = translator.lngettext

log = logging.getLogger(__name__)

#==============================================================================

if __name__ == "__main__":

    pass

#==============================================================================

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
