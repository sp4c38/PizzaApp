"""Store information to the database in a seperate thread.

Other threads can put items in a queue observed by this module. They then get executed in this background
thread. An item consists of a function to call and arguments to parse to this function.

In this module there is a "simple store" function which directly takes a orm object and stores it in the db.
Sometimes more then that has to be done. Functions handling those tasks are normally not in this file,
but in seperate files. For example a function to store new orders is in order.py.
"""

import threading

from dataclasses import dataclass
from queue import Empty as QueueEmptyError, Queue
from typing import Callable, Optional

from loguru import logger
from sqlalchemy.orm import Session

from pizzaapp import engine


@dataclass
class StoreOperation:
    """Information about a operation to store something to the database."""

    func: Callable
    args: Optional[tuple] = None
    kwargs: Optional[dict] = None


def simple_store(session: Session, orm_object):
    """Store a orm object to the database.

    This function can be called if no extra tasks should be execute in the store thread
    other than storing a orm object.
    """
    session.add(orm_object)
    session.commit()


def run_store_thread(queue: Queue, kill_event: threading.Event, refresh_interval=0.5):
    """Runs tasks to store new store operations.

    :param queue: Queue to which will be observed for new store operations,.
    :param kill_event: A event signalizing this thread to terminate.
    :param refresh_interval: Optional interval in which to check if there are items
        in the queue after it was found to be empty. Defaults to 0.5 seconds.
    """
    session = Session(engine)
    store_operation_count = 1
    while True:
        while not queue.empty():
            try:
                task = queue.get(block=False)
            except QueueEmptyError:
                break

            task_args = task.args if task.args is not None else ()
            task_kwargs = task.kwargs if task.kwargs is not None else {}
            logger.debug(
                f"Starting store operation {store_operation_count} for function {task.func.__name__}()."
            )
            task.func(session, *task_args, **task_kwargs)
            logger.info(
                f"Store operation {store_operation_count} for function {task.func.__name__}() finished."
            )
            store_operation_count += 1

            session.expunge_all()

        kill_thread = kill_event.wait(refresh_interval)
        if kill_thread is True:
            break

    thread = threading.current_thread()
    logger.info(f"Shutting down {thread.name} thread (TID: {thread.native_id}).")
    session.close()
