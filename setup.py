import os
from setuptools import setup, find_packages

# Utility function to read the README file.
# Used for the long_description.  It's nice, because now 1) we have a top level
# README file and 2) it's easier to type in the README file than to put a raw
# string in below ...
def read(fname):
    return open(os.path.join(os.path.dirname(__file__), fname)).read()

setup(
    name = "INGInious",
    version = "0.0",
    #packages = [''],
    scripts = ['checktask', 'testtask', 'app_frontend.py'],
    #packages = ['inginious.frontend', 'inginious.backend', 'inginious.common'],
    packages = find_packages(),
    #scripts = ['say_hello.py'],

    # Project uses reStructuredText, so ensure that the docutils get
    # installed or upgraded on the target machine
    install_requires = ['pymongo', 'pytidylib', 'docker-py', 'sh', 'web.py', 'docutils', 'simpleldap', 'webtest'],

    #package_data = {
    #    # If any package contains *.txt or *.rst files, include them:
    #    '': ['*.txt', '*.rst'],
    #    # And include any *.msg files found in the 'hello' package, too:
    #    'hello': ['*.msg'],
    #}

    # metadata for upload to PyPI
    author = "INGI Deprtment @ UCL",
    #author_email = "me@example.com",
    description = "INGInious is an intelligent grader that allows secured and automated testing of code made by students.",
    license = "AGPL",
    #keywords = "hello world example examples",
    url = "https://github.com/UCL-INGI/INGInious",
    long_description = read('README.md')

    # could also include long_description, download_url, classifiers, etc.
)

