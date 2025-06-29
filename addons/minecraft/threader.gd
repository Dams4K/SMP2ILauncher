extends Progressor
class_name Threader

var thread: Thread

func start(thread_callable: Callable):
	thread = Thread.new()
	thread.start(thread_callable)

func get_progress():
	return get_child_count()
