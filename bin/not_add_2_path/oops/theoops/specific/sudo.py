import functools

def sudo_support(fn):
    @functools.wraps(fn)
    def wrapper(command, *args, **kwargs):
        """Removes sudo before calling fn and adds it after."""
        if not command.script.startswith('sudo '):
            return fn(command, *args, **kwargs)

        # Remove "sudo " and call the original function
        new_command = command.update(script=command.script[5:])
        result = fn(new_command, *args, **kwargs)

        # Re-add "sudo " to result
        if result and isinstance(result, str):
            return f'sudo {result}'
        elif isinstance(result, list):
            return [f'sudo {x}' for x in result]
        else:
            return result

    return wrapper
