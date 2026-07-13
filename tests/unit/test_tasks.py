"""Unit tests for the in-memory task list."""

import pytest

from task_list.tasks import DuplicateTaskError, TaskList, TaskNotFoundError


@pytest.mark.unit
def test_new_list_has_no_tasks(task_list: TaskList) -> None:
    assert task_list.all_tasks() == []


@pytest.mark.unit
def test_add_task_appears_as_pending(task_list: TaskList) -> None:
    task_list.add('buy milk')

    assert [task.title for task in task_list.pending()] == ['buy milk']


@pytest.mark.unit
def test_adding_duplicate_title_raises(task_list: TaskList) -> None:
    task_list.add('buy milk')

    with pytest.raises(DuplicateTaskError):
        task_list.add('buy milk')


@pytest.mark.unit
def test_complete_moves_task_out_of_pending(task_list: TaskList) -> None:
    task_list.add('buy milk')

    task_list.complete('buy milk')

    assert task_list.pending() == []
    assert task_list.all_tasks()[0].done is True


@pytest.mark.unit
def test_completing_unknown_task_raises(task_list: TaskList) -> None:
    with pytest.raises(TaskNotFoundError):
        task_list.complete('does not exist')


@pytest.mark.unit
def test_remove_deletes_task(task_list: TaskList) -> None:
    task_list.add('buy milk')

    task_list.remove('buy milk')

    assert task_list.all_tasks() == []


@pytest.mark.unit
def test_removing_unknown_task_raises(task_list: TaskList) -> None:
    with pytest.raises(TaskNotFoundError):
        task_list.remove('does not exist')
