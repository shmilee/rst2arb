#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright (c) 2016 shmilee

'''
Convert markdown, reStructuredText(rst) to article, report and beamer.
'''

import os
import json
import argparse
from configparser import ConfigParser

SYSTEM_CONF = '/etc/rst2arb.conf'
VERSION = 0.14


class Style(object):
    __slots__ = ('__name', '__doc_class', '__template', '__engine',
                 '__alias_name', '__options', '__in_format')

    def __init__(self, name, doc_class, template, engine):
        self.__name = name
        if doc_class in ('article', 'report', 'book', 'beamer'):
            self.__doc_class = doc_class
        else:
            raise ValueError(
                'Documentclass should be article, report, book or beamer.')
        self.__template = template
        if engine in ('pdflatex', 'xelatex', 'lualatex'):
            self.__engine = engine
        else:
            raise ValueError(
                'latex-engine should be pdflatex, xelatex or lualatex.')
        self.__alias_name = None
        self.__options = ()
        self.__in_format = 'rst'

    def set_alias_name(self, alias_name):
        self.__alias_name = alias_name

    def set_options(self, options):
        if isinstance(options, (tuple, list)):
            self.__options = options
        else:
            raise ValueError('Other options should be a list or tuple.')

    def set_in_format(self, in_format):
        if in_format in ('markdown', 'rst'):
            self.__in_format = in_format
        else:
            raise ValueError(
                'Input FORMAT should be markdown or reStructuredText.')

    def get_alias_name(self):
        return self.__alias_name

    def print_info(self, *no_in_format):
        if self.__alias_name == None:
            print('Style    name: %s' % self.__name)
        else:
            print('Style    name: %s (%s)' % (self.__name, self.__alias_name))
        if not no_in_format:
            print('Input  format: %s' % self.__in_format)
        print('Output format: latex(%s)' % self.__doc_class)
        print('Template file: %s' % self.__template)
        print('Latex  engine: %s' % self.__engine)
        print('Other options: %s\n' %
              '\n               '.join(self.__options))

    def strap_options(self):
        opt = []
        opt.append('-f %s' % self.__in_format)
        if self.__doc_class in ('article', 'report', 'book'):
            opt.append(' -V documentclass:%s' % self.__doc_class)
        elif self.__doc_class == 'beamer':
            opt.append(' -t beamer')
        opt.append(' --template="%s" --latex-engine=%s %s' %
                   (self.__template, self.__engine, ' '.join(self.__options)))
        return ''.join(opt)


def main(args):
    if not (os.path.exists(SYSTEM_CONF) and os.path.isfile(SYSTEM_CONF)
            and os.access(SYSTEM_CONF, os.R_OK)):
        print('%s is missing or is not readable.\n' % SYSTEM_CONF)
    user_conf = os.path.expanduser(args.conf)
    if not (os.path.exists(user_conf) and os.path.isfile(user_conf)
            and os.access(user_conf, os.R_OK)):
        print('%s is missing or is not readable.\n' % user_conf)

    try:
        config = ConfigParser()
        config.optionxform = str
        config.read([SYSTEM_CONF, user_conf])
        styles = {}
        alias_styles = {}
        for k, v in config._sections.items():
            styles[k] = Style(k, v['doc_class'],
                              v['template'], v['latex_engine'])
            if 'other_options' in v.keys():
                styles[k].set_options(json.loads(v['other_options']))
            if 'alias_name' in v.keys():
                styles[k].set_alias_name(v['alias_name'])
                alias_styles[v['alias_name']] = styles[k]
    except (Exception, KeyError) as e:
        print('Please check what you set in %s:' % user_conf)
        print(e)
        return 0

    if args.list_styles:
        for k in styles.keys():
            if styles[k].get_alias_name():
                print('%s (%s)' % (k, styles[k].get_alias_name()))
            else:
                print(k)
        return 1

    if args.show_info:
        for s in args.show_info:
            if s in styles.keys():
                print('--- Style info of "%s" ---' % s)
                styles[s].print_info('no_in_format')
                continue
            if s in alias_styles.keys():
                print('--- Style info of "%s" ---' % s)
                alias_styles[s].print_info('no_in_format')
                continue
            print('--- Style "%s" not found ---' % s)
        return 1

    if not args.input:
        parser.print_help()
        return 0

    s = args.style
    in_format = args.input.split('.')[-1]
    if in_format in ('md', 'mkd'):
        in_format = 'markdown'
    if args.out_file:
        out_file = args.out_file
    else:
        out_file = '.'.join(args.input.split('.')[:-1]) + '-' + s + '.pdf'

    if s in styles.keys():
        styles[s].set_in_format(in_format)
        if args.verbose != None:
            styles[s].print_info()
        cmd = ('pandoc %s "%s" -o "%s"' %
               (styles[s].strap_options(), args.input, out_file))
    elif s in alias_styles.keys():
        alias_styles[s].set_in_format(in_format)
        if args.verbose != None:
            alias_styles[s].print_info()
        cmd = ('pandoc %s "%s" -o "%s"' %
               (alias_styles[s].strap_options(), args.input, out_file))
    else:
        print('Unknow Style.')
        return 0
    if args.verbose != None:
        print('Command: %s\n' % cmd)
    print('==> Converting %s to %s ...' % (args.input, out_file))
    os.system(cmd)
    return 1

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='rst2arb v{} by shmilee'.format(VERSION),
                                     formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument('-v', '--verbose', action='count', help='be verbose')
    parser.add_argument('-l', '--list', dest='list_styles', action='store_true',
                        help='list available STYLEs in configuration file and exit')
    parser.add_argument('-i', dest='show_info', metavar='STYLE', nargs='+',
                        help='show the information of STYLE and exit')
    parser.add_argument('-s', dest='style', nargs='?', default='article',
                        help='Convert Input File to\n'
                        '  article (default)\n'
                        '  report\n'
                        '  beamer\n'
                        '  other STYLE (set by user configuration file)')
    parser.add_argument('-o', dest='out_file', nargs='?', type=str,
                        help='write output to OUT_FILE with a .pdf or .tex extension\n'
                        'Default OUT_FILE is: <Input_File>-<STYLE>.pdf')
    parser.add_argument('-f', dest='conf', nargs='?', type=str, default='~/.rst2arb.conf',
                        help='set user configuration file (default: %(default)s)\n'
                        'system configuration file is {}'.format(SYSTEM_CONF))
    parser.add_argument('input', metavar='Input_File', nargs='?', type=str,
                        help='The format of input can be Markdown or reStructuredText.')
    args = parser.parse_args()
    main(args)
