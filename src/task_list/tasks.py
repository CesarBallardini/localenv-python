"""An in-memory task list: add, complete, and remove tasks.

No persistence -- this is a small domain meant to exercise the testing
setup (unit tests + BDD), not a production task tracker.
"""

from __future__ import annotations

from dataclasses import dataclass, field


class TaskNotFoundError(Exception):
    """Raised when an operation references a task that doesn't exist."""


class DuplicateTaskError(Exception):
    """Raised when adding a task whose title is already in the list."""


@dataclass(frozen=True, slots=True)
class Task:
    """A single to-do item, identified by its title."""

    title: str
    done: bool = False


@dataclass(slots=True)
class TaskList:
    """An in-memory collection of tasks, keyed by title."""

    _tasks: dict[str, Task] = field(default_factory=dict)

    def add(self, title: str) -> None:
        """Add a new pending task. Raises if the title already exists."""
        if title in self._tasks:
            raise DuplicateTaskError(title)
        self._tasks[title] = Task(title=title)

    def complete(self, title: str) -> None:
        """Mark a task as done. Raises if the task doesn't exist."""
        if title not in self._tasks:
            raise TaskNotFoundError(title)
        self._tasks[title] = Task(title=title, done=True)

    def remove(self, title: str) -> None:
        """Remove a task entirely. Raises if the task doesn't exist."""
        if title not in self._tasks:
            raise TaskNotFoundError(title)
        del self._tasks[title]

    def pending(self) -> list[Task]:
        """Tasks not yet marked done."""
        return [task for task in self._tasks.values() if not task.done]

    def all_tasks(self) -> list[Task]:
        """Every task, done or not."""
        return list(self._tasks.values())
