# -*- coding: utf-8 -*-
#
# Copyright (c) 2014-2015 Université Catholique de Louvain.
#
# This file is part of INGInious.
#
# INGInious is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# INGInious is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with INGInious.  If not, see <http://www.gnu.org/licenses/>.
""" Contains AccessibleTime, class that represents the period of time when a course/task is accessible """

from datetime import datetime


class AccessibleTime(object):
    """ represents the period of time when a course/task is accessible """

    def __init__(self, val=None):
        """
            Parse a string/a boolean to get the correct time period.
            Correct values for val:
            True (task always open)
            False (task always closed)
            2014-07-16 11:24:00 (task is open from 2014-07-16 at 11:24:00)
            2014-07-16 (task is open from 2014-07-16)
            / 2014-07-16 11:24:00 (task is only open before the 2014-07-16 at 11:24:00)
            / 2014-07-16 (task is only open before the 2014-07-16)
            2014-07-16 11:24:00 / 2014-07-20 11:24:00 (task is open from 2014-07-16 11:24:00 and will be closed the 2014-07-20 at 11:24:00)
            2014-07-16 / 2014-07-20 11:24:00 (...)
            2014-07-16 11:24:00 / 2014-07-20 (...)
            2014-07-16 / 2014-07-20 (...)
        """
        if val is None or val == "" or val is True:
            self._val = [datetime.min, datetime.max]
        elif val == False:
            self._val = [datetime.max, datetime.max]
        else:  # str
            values = val.split("/")
            if len(values) == 1:
                self._val = [self._parse_date(values[0].strip(), datetime.min), datetime.max]
            else:
                self._val = [self._parse_date(values[0].strip(), datetime.min), self._parse_date(values[1].strip(), datetime.max)]

    @classmethod
    def _parse_date(cls, date, default):
        """ Parse a valid date """
        if date == "":
            return default

        for format_type in ["%Y-%m-%d %H:%M:%S", "%Y-%m-%d %H:%M", "%Y-%m-%d %H", "%Y-%m-%d", "%d/%m/%Y %H:%M:%S", "%d/%m/%Y %H:%M", "%d/%m/%Y %H",
                            "%d/%m/%Y"]:
            try:
                return datetime.strptime(date, format_type)
            except ValueError:
                pass
        raise Exception("Unknown format for " + date)

    def before_start(self, when=None):
        """ Returns True if the task/course is not yet accessible """
        if when is None:
            when = datetime.now()

        return self._val[0] > when

    def after_start(self, when=None):
        """ Returns True if the task/course is or have been accessible in the past """
        return not self.before_start(when)

    def is_open(self, when=None):
        """ Returns True if the course/task is still open """
        if when is None:
            when = datetime.now()

        return self._val[0] <= when and when <= self._val[1]

    def is_always_accessible(self):
        """ Returns true if the course/task is always accessible """
        return self._val[0] == datetime.min and self._val[1] == datetime.max

    def is_never_accessible(self):
        """ Returns true if the course/task is never accessible """
        return self._val[0] == datetime.max and self._val[1] == datetime.max

    def get_std_start_date(self):
        """ If the date is custom, return the start datetime with the format %Y-%m-%d %H:%M:%S. Else, returns "". """
        first, _ = self._val
        if first != datetime.min and first != datetime.max:
            return first.strftime("%Y-%m-%d %H:%M:%S")
        else:
            return ""

    def get_std_end_date(self):
        """ If the date is custom, return the end datetime with the format %Y-%m-%d %H:%M:%S. Else, returns "". """
        _, second = self._val
        if second != datetime.max:
            return second.strftime("%Y-%m-%d %H:%M:%S")
        else:
            return ""

    def get_start_date(self):
        """ Return a datetime object, representing the date when the task/course become accessible """
        return self._val[0]

    def get_end_date(self):
        """ Return a datetime object, representing the deadline for accessibility """
        return self._val[1]
