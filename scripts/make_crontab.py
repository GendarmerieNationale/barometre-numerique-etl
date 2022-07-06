import os
from pathlib import Path

from utils import read_schedules_from_stdin, get_commands_from_schedules

"""
Transform meltano schedules from a json format into a crontab file.

Example:
$ meltano schedule list --format=json | python make_crontab.py

If you want to specify environment variables (such as CRONTAB_MELTANO_EXECUTABLE),
first load your `.env` file :
$ export $(grep -v '^#' .env | xargs)

"""

PROJECT_HOME = Path(__file__).parents[1].absolute()
# The meltano executable that you want to use in the crontab.
# Note: crontab does not use the $PATH that you have in your regular shell.
#
# Examples:
# - 'meltano' is fine if it is on the '/usr/local/bin:/usr/bin:/bin' path (it is probably not)
# - '/home/my_user/.local/bin/meltano' if you installed meltano with pipx
# - '/usr/local/bin/docker compose exec meltano-ui meltano' if you are using docker
MELTANO_EXECUTABLE = os.environ.get("CRONTAB_MELTANO_EXECUTABLE", "meltano")


def get_crontab_entries(commands: dict):
    # These crontab intervals slightly differ from the meltano ones, so that cron jobs
    # are not executed at the same time
    entry_intervals = {
        "@hourly": "30 * * * *",  # every hour at minute 30
        "@daily": "0 0 * * *",  # every day at 00:00
        "@weekly": "0 1 * * 0",  # every week on sunday at 01:00
        "@monthly": "0 2 1 * *",  # every first day of the month at 02:00
        "@yearly": "0 3 1 1 *",  # every january 1st at 03:00
    }
    # Gather commands together by interval, and run them one after the other
    crontab_entries = {}
    for interval, commands in commands.items():
        if len(commands) > 0 and interval in entry_intervals:
            cron_interval = entry_intervals[interval]
            chained_commands = " && ".join(commands)
            crontab_entries[interval] = (
                f"{cron_interval} (cd {PROJECT_HOME} && {chained_commands}) "
                f"2>&1 | /usr/bin/logger -t meltano"
            )
    return crontab_entries


def make_crontab_file(crontab_entries: dict):
    crontab_template = """
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * [username] command to be executed

SHELL=/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin

PROJECT_HOME={project_home}

# Schedules are grouped by interval, and the output (both stdout and stderr) of 
# the processes are redirected to the logger unix utility
{entries}
"""
    formatted_entries = "\n".join(
        f"""
# {interval}
{entry}
"""
        for interval, entry in crontab_entries.items()
    )
    return crontab_template.format(project_home=PROJECT_HOME, entries=formatted_entries)


def main():
    job_schedules, elt_schedules = read_schedules_from_stdin()
    commands = get_commands_from_schedules(
        job_schedules, elt_schedules, meltano_executable=MELTANO_EXECUTABLE
    )
    crontab_entries = get_crontab_entries(commands)
    crontab_full_content = make_crontab_file(crontab_entries)
    print(crontab_full_content)


if __name__ == "__main__":
    main()
