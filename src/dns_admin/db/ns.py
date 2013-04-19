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

# Own modules
from pb_base.common import pp, to_unicode_or_bust, to_utf8_or_bust

from pb_base.object import PbBaseObjectError
from pb_base.object import PbBaseObject

from pb_base.errors import PbReadTimeoutError, CallAbstractMethodError

from pb_dbhandler import BaseDbError

from pb_dbhandler.handler import BaseDbHandlerError

from dns_admin.errors import DnsAdminError
from dns_admin.errors import DnsAdminAppError

from dns_admin.handler import DnsAdminHandlerError

from dns_admin.translate import translator

_ = translator.lgettext
__ = translator.lngettext

__version__ = '0.1.0'

#==============================================================================

if __name__ == "__main__":
    pass

#==============================================================================
# vim: fileencoding=utf-8 filetype=python ts=4
