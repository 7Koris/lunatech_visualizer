# Simple placeholder godot osc client using dfcompose 'godOSC' plugin as starter

extends Node
@export var _osc_port = 3000

# OSC FEATURES
var rms = 0
var bass = 0
var mid = 0
var treble = 0
var flux = 0
var zcr = 0
var centroid = 0
var rolloff = 0
var tv = 0

# NETWORK STUFF
const _HB_DELAY = 100 # msec
const _BROADCAST_ADDR = "255.255.255.255"
var _incoming_messages := {}
var _server = UDPServer.new()
var _peers: Array[PacketPeerUDP] = []
var _hb_sender = PacketPeerUDP.new()

var _osc_thread: Thread
var _hb_thread: Thread
var _terminated: bool = false

var _is_server_alive = false

func update_port(port):
	_server.stop()
	_server.listen(port)
	_hb_sender.close()
	_hb_sender.bind(port)
	_hb_sender.set_broadcast_enabled(true)
	_hb_sender.set_dest_address(_BROADCAST_ADDR, port)

func _ready():
	_server.listen(_osc_port)
	_hb_sender.bind(_osc_port)
	_hb_sender.set_broadcast_enabled(true)
	_hb_sender.set_dest_address(_BROADCAST_ADDR, _osc_port)
	_osc_thread = Thread.new()
	_hb_thread = Thread.new()
	_osc_thread.start(_osc_thread_loop.bind())
	_hb_thread.start(_hb_thread_loop.bind())

func _hb_thread_loop():
	while(!_terminated):
		var data: Dictionary = {
			"time": Time.get_ticks_msec(),
			"host": "ltv"
		}
		var buf = JSON.stringify(data).to_utf8_buffer()
		_hb_sender.put_packet(buf)
		OS.delay_msec(_HB_DELAY)

func _osc_thread_loop():
	while(!_terminated):
		_server.poll()
		if _server.is_connection_available():
			var peer: PacketPeerUDP = _server.take_connection()
			_peers.append(peer)
		parse()

func _exit_tree():
	_osc_thread.wait_to_finish()
	_hb_thread.wait_to_finish()

func listen(new_port):
	_osc_port = new_port
	_server.listen(_osc_port)

func parse():
	for peer in _peers:
		for l in range(peer.get_available_packet_count()):
			var packet = peer.get_packet()
			if packet.get_string_from_ascii() == "#bundle":
				parse_bundle(packet)
			else:
				parse_message(packet)

func parse_message(packet: PackedByteArray):
	if packet.find(123) == 0:
		var json = JSON.parse_string(packet.get_string_from_ascii())
		if json["host"] == "ltsv":
			_is_server_alive = json["server_state"]
		return
	if not packet.find(47) == 0:
		return
	
	var comma_index = packet.find(44)
	var address = packet.slice(0, comma_index).get_string_from_ascii()
	var args = packet.slice(comma_index, packet.size())
	var tags = args.get_string_from_ascii()
	var vals = []

	args = args.slice(ceili((tags.length() + 1) / 4.0) * 4, args.size())
	for tag in tags.to_ascii_buffer():
		match tag:
			44: #,: comma
				pass
			70: #false
				vals.append(false)
			84: #true
				vals.append(true)
			105: #i: int32
				var val = args.slice(0, 4)
				val.reverse()
				vals.append(val.decode_s32(0))
				args = args.slice(4, args.size())
			102: #f: float32
				var val = args.slice(0, 4)
				val.reverse()
				vals.append(val.decode_float(0))
				args = args.slice(4, args.size())
			115: #s: string
				var val = args.get_string_from_ascii()
				vals.append(val)
				args = args.slice(ceili((val.length() + 1) / 4.0) * 4, args.size())
			98:  #b: blob
				vals.append(args)
			_:
				pass
			
	_incoming_messages[address] = vals
	
	if vals is Array and len(vals) == 1:
		vals = vals[0]


func parse_bundle(packet: PackedByteArray):
	packet = packet.slice(7)
	var mess_num = []
	#var bund_ind = 0
	var messages = []
	
	for i in range(packet.size()/4.0):
		#var bund_arr = PackedByteArray([32,0,0,0])
		if packet.slice(i*4, i*4+4) == PackedByteArray([1, 0, 0, 0]):
			mess_num.append(i*4)
			#bund_ind + 1
		elif packet[i*4+1] == 47 and packet[i*4 - 2] <= 0 and packet.slice(i*4 - 4, i*4) != PackedByteArray([1, 0, 0, 0]):
			mess_num.append(i*4-4)
		pass
	

	for i in range(len(mess_num)):
		if i  < len(mess_num) - 1:
			messages.append(packet.slice(mess_num[i]+4, mess_num[i+1]+1))
		else:
			var pack = packet.slice(mess_num[i]+4)
			messages.append(pack)
	
	for bund_packet in messages:
		bund_packet.remove_at(0)
		bund_packet.insert(0,0)
		var comma_index = bund_packet.find(44)
		var address = bund_packet.slice(1, comma_index).get_string_from_ascii()
		var args = bund_packet.slice(comma_index, packet.size())
		var tags = args.get_string_from_ascii()
		var vals = []
		
		args = args.slice(ceili((tags.length() + 1) / 4.0) * 4, args.size())
		
		for tag in tags.to_ascii_buffer():
			match tag:
				44: #,: comma
					pass
				70: #false
					vals.append(false)
					args = args.slice(4, args.size())
				84: #true
					vals.append(true)
					args = args.slice(4, args.size())
				105: #i: int32
					var val = args.slice(0, 4)
					val.reverse()
					vals.append(val.decode_s32(0))
					args = args.slice(4, args.size())
				102: #f: float32
					var val = args.slice(0, 4)
					val.reverse()
					vals.append(val.decode_float(0))
					args = args.slice(4, args.size())
				115: #s: string
					var val = args.get_string_from_ascii()
					vals.append(val)
					args = args.slice(ceili((val.length() + 1) / 4.0) * 4, args.size())
				98:  #b: blob
					vals.append(args)
				
		match address:
			"/lt/RMS":
				rms = vals[0]
			"/lt/Bass":
				bass = vals[0]
			"/lt/Mid":
				mid = vals[0]
			"/lt/Treble":
				treble = vals[0]
			"/lt/Flux":
				flux = vals[0]
			"/lt/ZCR":
				zcr = vals[0]
			"/lt/Centroid":
				centroid = vals[0]
			"/lt/RollOff":
				rolloff = vals[0]
			"/lt/TV":
				tv = vals[0]
		_incoming_messages[address] = vals
