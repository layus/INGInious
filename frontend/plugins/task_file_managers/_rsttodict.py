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
"""" Helper package for tasks_rst_file_manager. DEPRECATED """

import collections
import re

from docutils import core, nodes
from docutils.parsers.rst import Parser, Directive, directives
from docutils.writers import UnfilteredWriter


class Question(nodes.General, nodes.Element):
    id = None
    name = None
    header = None
    type = None
    language = None
    answer = None
    multiple = None
    limit = None


class Box(nodes.General, nodes.Element):
    type = None
    content = None
    maxchars = None
    lines = None
    language = None


class Choice(nodes.General, nodes.Element):
    text = None
    valid = None


class BaseDirective(Directive):
    has_content = True

    # This has to be replaced in subclasses
    node_class = None

    def run(self):
        node = self.node_class()
        self.state.nested_parse(self.content, self.content_offset, node)
        return [node]


class QuestionDirective(BaseDirective):
    required_arguments = 1
    option_spec = {
        'type': unicode,
        'language': unicode,
        'answer': unicode,
        'multiple': bool,
        'limit': int
    }

    node_class = Question

    def run(self):
        node = super(type(self), self).run()[0]
        node.id = self.arguments[0]
        node.header = '\n'.join(self.content)
        match = re.search('\.\.[ \t]+(positive|negative|box)::', node.header)
        if match:
            node.header = node.header[:match.start()].strip()
        else:
            node.header = node.header.strip()
        for option, value in self.options.items():
            setattr(node, option, value)
        return [node]


class BoxDirective(Directive):
    has_content = True
    option_spec = {
        'type': unicode,
        'maxchars': int,
        'lines': int,
        'language': unicode
    }

    def run(self):
        node = Box()
        for option, value in self.options.items():
            setattr(node, option, value)
        node.content = '\n'.join(self.content)
        return [node]


class PosNegDirective(Directive):
    has_content = True

    # This has to be replaced in subclasses
    valid = None

    def run(self):
        node = Choice()
        node.text = '\n'.join(self.content)
        node.valid = self.valid
        return [node]


class PositiveDirective(PosNegDirective):
    valid = True


class NegativeDirective(PosNegDirective):
    valid = False


class TitleParser(Parser):
    symbols = '[!"#$%&\'()*+,-./:;<=>?@[\]^_`{|}~]'
    context = None

    def parse(self, inputstring, document):
        pattern = ('(?:' + TitleParser.symbols + '+\s)?.+\s' + TitleParser.symbols
                   + '+\s+(?:(?::.+:.*\s)*)((?:.*\s)*?)(?:'
                   + TitleParser.symbols + '+\s)?.+\s' + TitleParser.symbols + '+')
        self.context = re.search(pattern, inputstring).group(1).strip('\n\r')
        Parser(self).parse(inputstring, document)


class Writer(UnfilteredWriter):
    docinfo_types = {
        'context': unicode,
        'order': int,
        'name': unicode,
        'accessible': unicode,
        'limit-time': int,
        'limit-memory': int,
        'limit-output': int,
        'environment': unicode
    }

    parser = None
    output = {}

    def translate(self):
        self.validate()
        self.docinfo()
        title = self.document.next_node(nodes.title)
        if title:
            self.output['name'] = title.astext()
        if self.parser.context and len(self.parser.context) > 0:
            self.output['context'] = self.parser.context
        self.process_questions()

    def validate(self):
        docinfo = self.document.next_node(nodes.docinfo)
        if docinfo:
            for field in docinfo.traverse(nodes.field):
                field_name = field.next_node(nodes.field_name).astext()
                field_body = field.next_node(nodes.field_body).astext()
                try:
                    Writer.docinfo_types[field_name](field_body)
                except KeyError:
                    raise StructureError('Invalid document option: ' + field_name + '.')
                except ValueError:
                    raise StructureError('Invalid value for ' + field_name + ' option: ' + field_body + '.')
        questions = self.document.traverse(Question)
        if len(questions) == 0:
            raise StructureError('There must be at least one question in your document.')
        for question in questions:
            type = get_type(question.type)
            type.validate(question)

    def docinfo(self):
        docinfo = self.document.next_node(nodes.docinfo)
        if not docinfo:
            return
        author = docinfo.next_node(nodes.author)
        if author:
            self.output['author'] = map(lambda s: s.strip(), author.astext().split(','))
            if len(self.output['author']) == 1:
                self.output['author'] = self.output['author'][0]
        self.output['limits'] = {}
        for field in docinfo.traverse(nodes.field):
            field_name = field.next_node(nodes.field_name).astext()
            field_body = field.next_node(nodes.field_body).astext()
            if field_name == 'accessible':
                if field_body == 'true':
                    self.output['accessible'] = True
                    continue
                if field_body == 'false':
                    self.output['accessible'] = False
                    continue
            match = re.match('^limit-(.*)$', field_name)
            if match:
                self.output['limits'][match.group(1)] = Writer.docinfo_types[field_name](field_body)
            else:
                self.output[field_name] = Writer.docinfo_types[field_name](field_body)

    def process_questions(self):
        self.output['problems'] = collections.OrderedDict()
        for question in self.document.traverse(Question):
            name = question.parent.next_node(nodes.title)
            if name:
                question.name = name.astext()
            infos = {}
            for option in QuestionDirective.option_spec:
                value = getattr(question, option)
                if value:
                    infos[option] = value
            if question.name:
                infos['name'] = question.name
            if question.header and len(question.header) > 0:
                infos['header'] = question.header
            self.process_boxes(question, infos)
            self.process_choices(question, infos)
            self.output['problems'][question.id] = infos

    def process_boxes(self, question, infos):
        boxes = collections.OrderedDict()
        id = 1
        for box in question.traverse(Box):
            boxId = 'boxId' + unicode(id)
            boxes[boxId] = {}
            for option in BoxDirective.option_spec:
                value = getattr(box, option)
                if option == 'maxchars':
                    option = 'maxChars'
                if value:
                    boxes[boxId][option] = value
                if box.content:
                    boxes[boxId]['content'] = box.content
            id += 1
        if len(boxes) > 0:
            infos['boxes'] = boxes

    def process_choices(self, question, infos):
        choices = []
        for choice in question.traverse(Choice):
            choices.append({
                'text': choice.text,
                'valid': choice.valid
            })
        if len(choices) > 0:
            infos['choices'] = choices


def get_type(type):
    if type == 'code':
        return Code()
    if type == 'code-single-line':
        return CodeSingleLine()
    if type == 'match':
        return Match()
    if type == "multiple-choice":
        return MultipleChoice()
    return UnknownType()


class StructureError(Exception):
    pass


class Type(object):
    def validate(self, question):
        pass


class Code(Type):
    def validate(self, question):
        for box in question.traverse(Box):
            if not box.type:
                raise StructureError('Every box directive must have a type option.')
            if box.type == 'text' and not box.content:
                raise StructureError('A box directive with a text type must have a content option.')


class CodeSingleLine(Type):
    pass


class Match(Type):
    def validate(self, question):
        if not question.answer:
            raise StructureError('A match type question must have an answer option.')


class MultipleChoice(Type):
    def validate(self, question):
        for choice in question.traverse(Choice):
            if not choice.text or len(choice.text) == 0:
                raise StructureError('Every positive and negative directive must have a content.')


class UnknownType(Type):
    def validate(self, question):
        raise StructureError('Unknown type for the question directive.')


def rst2dict(rst_string):
    directives.register_directive('question', QuestionDirective)
    directives.register_directive('box', BoxDirective)
    directives.register_directive('positive', PositiveDirective)
    directives.register_directive('negative', NegativeDirective)
    parser = TitleParser()
    writer = Writer()
    writer.parser = parser
    return core.publish_string(source=rst_string, parser=parser, writer=writer)
