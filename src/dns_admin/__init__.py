#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
@author: Frank Brehm
@contact: frank.brehm@profitbricks.com
@copyright: © 2010 - 2013 by Frank Brehm, Berlin
@summary: All modules for the DNS administration tool
"""

# Standard modules
import sys
import os
import logging

__author__ = 'Frank Brehm <frank.brehm@profitbricks.com>'
__copyright__ = '(C) 2010-2013 by profitbricks.com'
__contact__ = 'frank.brehm@profitbricks.com'
__version__ = '0.1.2'
__license__ = 'LGPLv3+'

# module variables:

default_config_dir = os.sep + os.path.join('etc', 'bind')
default_bind_dir = os.sep + os.path.join('var', 'bind')
default_log_dir = os.sep + os.path.join('var', 'log', 'bind')

# Database defaults
default_db_host = 'localhost'
default_db_port = 5432
default_db_schema = 'dns'
default_db_user = 'dnsadmin'


#==============================================================================

if __name__ == "__main__":
    pass

#==============================================================================
# vim: fileencoding=utf-8 filetype=python ts=4
