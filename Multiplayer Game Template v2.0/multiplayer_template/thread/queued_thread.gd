class_name QueuedThread
extends Node

@export var open_thread_on_ready : bool = true
@export var set_task_wait_time : float = 0.2

var thread : Thread
var should_exit_thread : bool = false
var semaphore : Semaphore 
var mutex : Mutex
var task_mutex : Mutex
var task_queue : Array[Callable] = []
var task : Callable
var set_task_timer : Timer


func _ready() -> void:
	set_task_timer = Timer.new()
	set_task_timer.wait_time = set_task_wait_time
	add_child(set_task_timer)
	set_task_timer.timeout.connect(_on_set_task_timer_timeout)
	
	if open_thread_on_ready:
		open_thread()
		
		
func open_thread() -> void:
	if thread != null:
		push_warning("Cannot open thread when it is already open")
		return
	semaphore = Semaphore.new()
	thread = Thread.new()
	mutex = Mutex.new()
	task_mutex = Mutex.new()
	thread.start(process_queued_thread)
	
	
func close_thread() -> void:
	mutex.lock()
	should_exit_thread = true
	mutex.unlock()
	semaphore.post()
	thread.wait_to_finish()
	thread = null
	

func process_queued_thread() -> void:
	while(true):
		semaphore.wait()
		mutex.lock()
		var should_exit : bool = should_exit_thread
		mutex.unlock()
		if should_exit:
			break
		task_mutex.lock()
		if task.is_valid():
			task.call()
		task_mutex.unlock()
		
		
func queue_task(next_task : Callable) -> void:
	task_queue.append(next_task)
	if set_task_timer.is_stopped():
		set_task_timer.start()
	
	
func attempt_set_task(next_task : Callable) -> void:
	var task_available : bool = task_mutex.try_lock()
	if task_available:
		task = next_task
		task_mutex.unlock()
		semaphore.post()
	
	
func _on_set_task_timer_timeout() -> void:
	if task_queue.is_empty():
		set_task_timer.stop()
		return
	attempt_set_task(task_queue.pop_front())
	
		
func _exit_tree() -> void:
	close_thread()
