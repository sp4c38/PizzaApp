import threading

from dataclasses import dataclass
from queue import Empty as QueueEmptyError, Full as QueueFullError, Queue

from typing import Callable, Optional
from sqlalchemy.orm import Session

from src.pizzaapp import engine


@dataclass
class StoreOperation:
    """Information about a operation to store something to the database."""

    func: Callable
    args: Optional[tuple] = None
    kwargs: Optional[dict] = None


def add_to_store_queue(queue: Queue, store_operation: StoreOperation) -> bool:
    """Try to add a new store operation to the store queue.

    :returns: True if store operation was added successfully, false if
        an error occurred (queue blocked).
    """
    timeout_sec = 2
    try:
        queue.put_nowait(store_operation)
    except QueueFullError:
        print(
            "Tried to put new store operation in store queue, "
            f"but timed out after {timeout_sec} sec."
        )
        return False
    return True


def run_store_to_database(queue: Queue, kill_event: threading.Event, refresh_interval=0.5):
    """Runs tasks to store new orders.

    :param queue: Queue which will be observed for new orders and from which the
        orders will be retrieved.
    :param kill_event: A event which will be set when this function/thread should
        be exited.
    :param refresh_interval: Optional interval in which to check if there are items
        in the queue after it was found to be empty.
    """
    session = Session(engine)
    while True:
        while not queue.empty():
            try:
                task = queue.get(block=False)
            except QueueEmptyError:
                break

            task_args = task.args if task.args is not None else ()
            task_kwargs = task.kwargs if task.kwargs is not None else {}
            task.func(session, *task_args, **task_kwargs)

            session.expunge_all()

        kill_thread = kill_event.wait(refresh_interval)
        if kill_thread is True:
            break

    thread = threading.current_thread()
    print(f'Shutting down "{thread.name}" child thread (TID: {thread.native_id}).')
    session.close()
