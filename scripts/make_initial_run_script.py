import os
from pathlib import Path

from utils import read_schedules_from_stdin, get_commands_from_schedules

PROJECT_HOME = Path(__file__).parents[1].absolute()
MELTANO_EXECUTABLE = os.environ.get("CRONTAB_MELTANO_EXECUTABLE", "meltano")


def make_script(commands: dict):
    command_list = [c for c_list in commands.values() for c in c_list]
    commands_str = "\n".join(command_list)
    return f"""#!/bin/bash
set -x
{commands_str}
"""


def main():
    job_schedules, elt_schedules = read_schedules_from_stdin()
    commands = get_commands_from_schedules(
        job_schedules, elt_schedules, meltano_executable=MELTANO_EXECUTABLE
    )
    print(make_script(commands))


if __name__ == "__main__":
    main()
