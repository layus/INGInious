# -*- coding: utf-8 -*-
#
# This file is part of INGInious. See the LICENSE and the COPYRIGHTS files for
# more information about the licensing of this file.

import os
import web
import json
import gettext

from inginious.common.tasks_problems import CodeProblem
from inginious.frontend.task_problems import DisplayableCodeProblem
from inginious.frontend.parsable_text import ParsableText


__version__ = "0.0"

class CodeFillProblem(CodeProblem):
    """
    Fill-in-the-blanks code problem
    """

    @classmethod
    def get_type(self):
        return "code-fill"

    @classmethod
    def parse_problem(cls, problem_content):
        return problem_content


class DisplayableCodeFillProblem(CodeFillProblem, DisplayableCodeProblem):

    """ A displayable fill-in-the-blanks code problem """
    def __init__(self, task, problemid, content, translations=None):
        super(DisplayableCodeFillProblem, self).__init__(task, problemid, content, translations)


    @classmethod
    def get_type_name(self, gettext):
        return gettext("code-fill")

    @classmethod
    def get_renderer(cls, template_helper):
        """ Get the renderer for this class problem """
        return template_helper.get_custom_renderer(os.path.join(PATH_TO_PLUGIN, "templates"), False)

    #@classmethod
    #def show_editbox(self, template_helper, key):
    #    return DisplayableCodeFillProblem.get_renderer(template_helper).code-fill(key)
    def show_input(self, template_helper, language, seed):
        """ Show BasicCodeProblem and derivatives """
        header = ParsableText(self.gettext(language,self._header), "rst",
                              translation=self._translations.get(language, gettext.NullTranslations()))
        return str(DisplayableCodeFillProblem.get_renderer(template_helper).code(self.get_id(), header, 8, 0, self._language, self._optional, self._default))
    

    @classmethod
    def show_editbox_templates(cls, template_helper, key):
        return ""

    def adapt_input_for_backend(self, input_data):
        """ Adapt the input from web.py for the inginious.backend """
        return "".join(input_data)



PATH_TO_PLUGIN = os.path.abspath(os.path.dirname(__file__))

class StaticMockPage(object):
    # TODO: Replace by shared static middleware and let webserver serve the files
    def GET(self, path):
        if not os.path.abspath(PATH_TO_PLUGIN) in os.path.abspath(os.path.join(PATH_TO_PLUGIN, path)):
            raise web.notfound()

        try:
            with open(os.path.join(PATH_TO_PLUGIN, "static", path), 'rb') as file:
                return file.read()
        except:
            raise web.notfound()

    def POST(self, path):
        return self.GET(path)

def init(plugin_manager, course_factory, client, plugin_config):
    # TODO: Replace by shared static middleware and let webserver serve the files
    plugin_manager.add_page('/plugins/code-fill/static/(.+)', StaticMockPage)
    plugin_manager.add_hook("css", lambda: "/plugins/code-fill/static/css/code-fill.css")
    plugin_manager.add_hook("javascript_header", lambda: "/plugins/code-fill/static/js/code-fill.js")
    course_factory.get_task_factory().add_problem_type(DisplayableCodeFillProblem)
