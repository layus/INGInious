# -*- coding: utf-8 -*-
#
# Copyright (c) 2014 Université Catholique de Louvain.
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
""" Contains the function deleter, which is used by PoolManager to delete a docker container """
import docker


def deleter(docker_config, containerid):
    """ Deletes a container """
    try:
        docker_connection = docker.Client(base_url=docker_config.get('server_url'))
        docker_connection.remove_container(containerid, True, False, True)
    except Exception as e:
        print "Cannot delete container {}: {}".format(containerid, repr(e))
