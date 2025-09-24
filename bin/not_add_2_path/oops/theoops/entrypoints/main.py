import os  # noqa: E402
import sys  # noqa: E402
from .. import logs  # noqa: E402
from ..argument_parser import Parser  # noqa: E402
from ..utils import get_installation_version  # noqa: E402
from ..shells import shell  # noqa: E402
from .alias import print_alias  # noqa: E402
from .fix_command import fix_command  # noqa: E402


def main():
    parser = Parser()
    known_args = parser.parse(sys.argv)

    if known_args.help:
        parser.print_help()
    # It's important to check if an alias is being requested before checking if
    # `TF_HISTORY` is in `os.environ`, otherwise it might mess with subshells.
    # Check https://github.com/nvbn/theoops/issues/921 for reference
    elif known_args.alias:
        print_alias(known_args)
    elif known_args.command or 'TF_HISTORY' in os.environ:
        fix_command(known_args)
    elif known_args.shell_logger:
        try:
            from .shell_logger import shell_logger  # noqa: E402
        except ImportError:
            logs.warn('Shell logger supports only Linux and macOS')
        else:
            shell_logger(known_args.shell_logger)
    else:
        parser.print_usage()
