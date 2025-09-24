# -*- encoding: utf-8 -*-

from contextlib import contextmanager
from datetime import datetime
import sys
from traceback import format_exception
from .conf import settings
from . import const


class ANSI:
    RESET = '\033[0m'
    BOLD = '\033[1m'
    RED = '\033[31m'
    GREEN = '\033[32m'
    BLUE = '\033[34m'
    WHITE = '\033[37m'
    BG_RED = '\033[41m'


def color(color_code):
    """Utility for ability to disable colored output."""
    return '' if settings.no_colors else color_code


def warn(title):
    sys.stderr.write(u'{warn}[WARN] {title}{reset}\n'.format(
        warn=color(ANSI.BG_RED + ANSI.WHITE + ANSI.BOLD),
        reset=color(ANSI.RESET),
        title=title))


def exception(title, exc_info):
    sys.stderr.write(
        u'{warn}[WARN] {title}:{reset}\n{trace}'
        u'{warn}----------------------------{reset}\n\n'.format(
            warn=color(ANSI.BG_RED + ANSI.WHITE + ANSI.BOLD),
            reset=color(ANSI.RESET),
            title=title,
            trace=''.join(format_exception(*exc_info))))


def rule_failed(rule, exc_info):
    exception(u'Rule {}'.format(rule.name), exc_info)


def failed(msg):
    sys.stderr.write(u'{red}{msg}{reset}\n'.format(
        msg=msg,
        red=color(ANSI.RED),
        reset=color(ANSI.RESET)))


def show_corrected_command(corrected_command):
    sys.stderr.write(u'{prefix}{bold}{script}{reset}{side_effect}\n'.format(
        prefix=const.USER_COMMAND_MARK,
        script=corrected_command.script,
        side_effect=u' (+side effect)' if corrected_command.side_effect else u'',
        bold=color(ANSI.BOLD),
        reset=color(ANSI.RESET)))


def confirm_text(corrected_command):
    sys.stderr.write(
        (u'{prefix}{clear}{bold}{script}{reset}{side_effect} '
         u'[{green}enter{reset}/{blue}↑{reset}/{blue}↓{reset}'
         u'/{red}ctrl+c{reset}]').format(
            prefix=const.USER_COMMAND_MARK,
            script=corrected_command.script,
            side_effect=' (+side effect)' if corrected_command.side_effect else '',
            clear='\033[1K\r',
            bold=color(ANSI.BOLD),
            green=color(ANSI.GREEN),
            red=color(ANSI.RED),
            reset=color(ANSI.RESET),
            blue=color(ANSI.BLUE)))


def debug(msg):
    if settings.debug:
        sys.stderr.write(u'{blue}{bold}DEBUG:{reset} {msg}\n'.format(
            msg=msg,
            reset=color(ANSI.RESET),
            blue=color(ANSI.BLUE),
            bold=color(ANSI.BOLD)))


@contextmanager
def debug_time(msg):
    started = datetime.now()
    try:
        yield
    finally:
        debug(u'{} took: {}'.format(msg, datetime.now() - started))


def how_to_configure_alias(configuration_details):
    print(u"Seems like {bold}oops{reset} alias isn't configured!".format(
        bold=color(ANSI.BOLD),
        reset=color(ANSI.RESET)))

    if configuration_details:
        print(
            u"Please put {bold}{content}{reset} in your "
            u"{bold}{path}{reset} and apply "
            u"changes with {bold}{reload}{reset} or restart your shell.".format(
                bold=color(ANSI.BOLD),
                reset=color(ANSI.RESET),
                **configuration_details._asdict()))

        if configuration_details.can_configure_automatically:
            print(
                u"Or run {bold}oops{reset} a second time to configure"
                u" it automatically.".format(
                    bold=color(ANSI.BOLD),
                    reset=color(ANSI.RESET)))

    print(u'More details - https://github.com/nvbn/theoops#manual-installation')


def already_configured(configuration_details):
    print(
        u"Seems like {bold}oops{reset} alias already configured!\n"
        u"For applying changes run {bold}{reload}{reset}"
        u" or restart your shell.".format(
            bold=color(ANSI.BOLD),
            reset=color(ANSI.RESET),
            reload=configuration_details.reload))


def configured_successfully(configuration_details):
    print(
        u"{bold}oops{reset} alias configured successfully!\n"
        u"For applying changes run {bold}{reload}{reset}"
        u" or restart your shell.".format(
            bold=color(ANSI.BOLD),
            reset=color(ANSI.RESET),
            reload=configuration_details.reload))


def version(theoops_version, python_version, shell_info):
    sys.stderr.write(
        u'The Oops {} using Python {} and {}\n'.format(theoops_version,
                                                       python_version,
                                                       shell_info))
