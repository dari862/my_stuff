import re
import functools
from ..utils import is_app
from ..shells import shell

def git_support(fn):
    @functools.wraps(fn)
    def wrapper(command, *args, **kwargs):
        """Resolves git aliases and supports testing for both git and hub."""
        if not is_app(command, 'git', 'hub'):
            return False

        # perform git aliases expansion
        if command.output and 'trace: alias expansion:' in command.output:
            search = re.search(r"trace: alias expansion: ([^ ]*) => ([^\n]*)",
                               command.output)
            if search:
                alias = search.group(1)
                expansion = ' '.join(shell.quote(part)
                                     for part in shell.split_command(search.group(2)))
                new_script = re.sub(r"\b{}\b".format(re.escape(alias)), expansion, command.script)
                command = command.update(script=new_script)

        return fn(command, *args, **kwargs)

    return wrapper
