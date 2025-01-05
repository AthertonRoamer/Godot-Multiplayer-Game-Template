class_name UPNPManager
extends QueuedThread

signal upnp_error(err : int)
signal upnp_bound_successfully
signal retrieved_external_ip(ip : String)

var upnp : UPNP
var upnp_mutex : Mutex = Mutex.new()
var network : NetworkManager
var data_mutex : Mutex = Mutex.new()
var external_port : int:
	get():
		data_mutex.lock()
		var port := external_port
		data_mutex.unlock()
		return port
var external_ip : String:
	get():
		data_mutex.lock()
		var ip := external_ip
		data_mutex.unlock()
		return ip
		

func trigger_setup_upnp(port : int, internal_port : int) -> void:
	queue_task(setup_upnp.bind(port, internal_port))


func setup_upnp(port : int, internal_port : int) -> void:
	upnp_mutex.lock()
	upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		Main.output.bind("UPNP discover error: " + str(err)).call_deferred()
	else:
		Main.output.bind("UPNP discover successful").call_deferred()
		var _error = attempt_forwarding(port, internal_port)
	upnp_error.emit.bind(err).call_deferred()
	upnp_mutex.unlock()
	
	
func attempt_forwarding(port : int, internal_port : int) -> int:
	upnp_mutex.lock()
	var err : int
	err = upnp.add_port_mapping(port, internal_port, ProjectSettings.get_setting("application/config/name"), "UDP")
	if err != OK:
		push_error(str(err))
		Main.output.bind("UPNP add port mapping error for UDP: " + str(err)).call_deferred()
		upnp_error.emit.bind(err).call_deferred()
	else:
		Main.output.bind("UPNP add port mapping successful on external port: " + str(port)).call_deferred()
		data_mutex.lock()
		external_port = port
		data_mutex.unlock()
		query_external_ip_address()
		upnp_bound_successfully.emit.call_deferred()
	upnp_error.emit.bind(err).call_deferred()
	upnp_mutex.unlock()
	return err
	
	
func query_external_ip_address() -> void:
	upnp_mutex.lock()
	var ip : String = upnp.query_external_address()
	upnp_mutex.unlock()
	Main.output.bind("External ip " + str(ip)).call_deferred()
	retrieved_external_ip.emit.bind(ip).call_deferred()
	data_mutex.lock()
	external_ip = ip
	data_mutex.unlock()
	
func  _exit_tree() -> void:
	super()
	if upnp:
		upnp.delete_port_mapping(external_port)
