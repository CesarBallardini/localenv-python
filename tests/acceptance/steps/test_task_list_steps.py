"""Step definitions for task_list.feature."""

import pytest
from pytest_bdd import given, parsers, scenarios, then, when

from task_list.tasks import TaskList, TaskNotFoundError

scenarios('../features/task_list.feature')


@pytest.fixture
def caught_error() -> dict[str, Exception | None]:
    return {'raised': None}


@given('an empty task list')
def empty_task_list(task_list: TaskList) -> None:
    assert task_list.all_tasks() == []


@given(parsers.parse('I add the task "{title}"'))
@when(parsers.parse('I add the task "{title}"'))
def add_task(task_list: TaskList, title: str) -> None:
    task_list.add(title)


@when(parsers.parse('I complete the task "{title}"'))
def complete_task(task_list: TaskList, title: str) -> None:
    task_list.complete(title)


@when(parsers.parse('I try to complete the task "{title}"'))
def try_complete_task(task_list: TaskList, title: str, caught_error: dict) -> None:
    try:
        task_list.complete(title)
    except TaskNotFoundError as exc:
        caught_error['raised'] = exc


@then(parsers.parse('the pending tasks are "{title}"'))
def pending_tasks_are(task_list: TaskList, title: str) -> None:
    assert [task.title for task in task_list.pending()] == [title]


@then('there are no pending tasks')
def no_pending_tasks(task_list: TaskList) -> None:
    assert task_list.pending() == []


@then('it fails because the task was not found')
def it_fails_not_found(caught_error: dict) -> None:
    assert isinstance(caught_error['raised'], TaskNotFoundError)
