# Simple placeholder godot osc client using dfcompose 'godOSC' plugin as starter

extends Node

@export var osc_port = 3000
const BROADCAST_ADDR = "255.255.255.255"

# NETWORK STUFF
const HB_DELAY = 2000 # msec
var incoming_messages := {}
var server = UDPServer.new()
var peers: Array[PacketPeerUDP] = []
var hb_sender = PacketPeerUDP.new()

# OSC FEATURES
var broad_range_rms = 0
var low_range_rms = 0
var mid_range_rms = 0
var high_range_rms = 0
var flux = 0
var zcr = 0
var spectral_centroid = 0

# THREAD STUFF
signal message_received(address, value, time)
var osc_thread: Thread
var hb_thread: Thread
var server_status_thread: Thread
var terminated: bool = false

var is_server_alive = false

func update_port(port):
	server.stop()
	server.listen(port)
	hb_sender.close()
	hb_sender.bind(port)
	hb_sender.set_broadcast_enabled(true)
	hb_sender.set_dest_address(BROADCAST_ADDR, port)

func _ready():
	server.listen(osc_port)
	hb_sender.bind(osc_port)
	hb_sender.set_broadcast_enabled(true)
	hb_sender.set_dest_address(BROADCAST_ADDR, osc_port)
	osc_thread = Thread.new()
	hb_thread = Thread.new()
	osc_thread.start(_osc_thread.bind())
	hb_thread.start(_hb_thread.bind())

func _hb_thread():
	while(!terminated):
		var data: Dictionary = {
			"time": Time.get_ticks_msec(),
			"host": "ltv"
		}
		var buf = JSON.stringify(data).to_utf8_buffer()
		hb_sender.put_packet(buf)
		OS.delay_msec(100)

func _osc_thread():
	while(!terminated):
		server.poll()
		if server.is_connection_available():
			var peer: PacketPeerUDP = server.take_connection()
			peers.append(peer)
		parse()

func _exit_tree():
	osc_thread.wait_to_finish()
	hb_thread.wait_to_finish()

func listen(new_port):
	osc_port = new_port
	server.listen(osc_port)

func parse():
	for peer in peers:
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
			is_server_alive = json["server_state"]
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
			
	incoming_messages[address] = vals
	
	if vals is Array and len(vals) == 1:
		vals = vals[0]
	message_received.emit(address, vals, Time.get_time_string_from_system())


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
				broad_range_rms = vals[0]
			"/lt/LowRangeRMS":
				low_range_rms = vals[0]
			"/lt/MidRangeRMS":
				mid_range_rms = vals[0]
			"/lt/HighRangeRMS":
				high_range_rms = vals[0]
			"/lt/Flux":
				flux = vals[0]
			"/lt/ZCR":
				zcr = vals[0]
			"/lt/SpectralCentroid":
				spectral_centroid = vals[0]
		incoming_messages[address] = vals
