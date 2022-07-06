import json
import logging
import sys
from typing import List


def read_schedules_from_stdin():
    """
    Read stdin, assuming the meltano schedules are in a json format.
    :return:
    """
    sys_input = sys.stdin.read()
    meltano_schedules = json.loads(sys_input).get("schedules", {})
    job_schedules = meltano_schedules.get("job", [])
    elt_schedules = meltano_schedules.get("elt", [])
    return job_schedules, elt_schedules


def get_commands_from_schedules(
    job_schedules: List[dict],
    elt_schedules: List[dict],
    meltano_executable: str = "meltano",
):
    commands = {
        "@hourly": [],
        "@daily": [],
        "@weekly": [],
        "@monthly": [],
        "@yearly": [],
        "@once": [],
    }
    # Convert elt and job schedules into proper commands
    for schedule in job_schedules:
        interval = schedule["interval"]
        job_name = schedule["job"]["name"]
        if interval in commands:
            commands[interval].append(f"{meltano_executable} run {job_name}")
        else:
            logging.info(
                f"Schedule for job {job_name} with interval {interval} "
                f"was not added to the crontab entries."
            )
    for schedule in elt_schedules:
        interval = schedule["interval"]
        if interval in commands:
            elt_args = " ".join(schedule["elt_args"])
            commands[interval].append(f"{meltano_executable} elt {elt_args}")
        else:
            logging.info(
                f"ELT schedule {schedule['name']} with interval {interval} "
                f"was not added to the crontab entries."
            )
    return commands
