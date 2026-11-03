"""Fuzz the task list against a plain dict, which is the behaviour it should match."""

import sys

import atheris

with atheris.instrument_imports():
    from task_list.tasks import DuplicateTaskError, TaskList, TaskNotFoundError

ADD, COMPLETE, REMOVE = range(3)
# Short titles, so that operations keep landing on the same tasks.
MAX_TITLE_LENGTH = 3


def apply_operation(tasks: TaskList, expected: dict[str, bool], operation: int, title: str) -> None:
    """Run one operation on the task list and the same one on the dict."""
    try:
        if operation == ADD:
            tasks.add(title)
            assert title not in expected
            expected[title] = False
        elif operation == COMPLETE:
            tasks.complete(title)
            assert title in expected
            expected[title] = True
        else:
            tasks.remove(title)
            assert title in expected
            del expected[title]
    except DuplicateTaskError:
        assert title in expected
    except TaskNotFoundError:
        assert title not in expected


def fuzz_one_input(data: bytes) -> None:
    """Turn the fuzzer's bytes into operations, checking the state after each one."""
    provider = atheris.FuzzedDataProvider(data)
    tasks = TaskList()
    expected: dict[str, bool] = {}
    while provider.remaining_bytes():
        operation = provider.ConsumeIntInRange(ADD, REMOVE)
        title = provider.ConsumeUnicodeNoSurrogates(MAX_TITLE_LENGTH)
        apply_operation(tasks, expected, operation, title)
        assert {task.title: task.done for task in tasks.all_tasks()} == expected
        assert {task.title for task in tasks.pending()} == {name for name, done in expected.items() if not done}


if __name__ == '__main__':
    atheris.Setup(sys.argv, fuzz_one_input)
    atheris.Fuzz()
