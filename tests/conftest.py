"""Shared fixtures for the whole test suite."""

import pytest

from task_list.tasks import TaskList


@pytest.fixture
def task_list() -> TaskList:
    """A fresh, empty task list for each test."""
    return TaskList()
