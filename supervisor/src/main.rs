use socket2::{ Domain, Protocol, SockAddr, Socket, Type };
use std::ffi::OsStr;
use std::mem::{ self, MaybeUninit };
use std::net::{ Ipv4Addr, SocketAddr, SocketAddrV4 };
use std::process::exit;
use std::sync::{ Arc, Mutex };
use std::thread;
use sysinfo::{ ProcessesToUpdate, System };

const BUF_SIZE: usize = 1024;

fn main() {
    let system = System::new_all();
    let system = Arc::new(Mutex::new(system));
    let sys_refresh_ref = Arc::clone(&system);

    thread::spawn(move || {
        loop {
            thread::sleep(std::time::Duration::from_secs(1));
            sys_refresh_ref.lock().unwrap().refresh_processes(ProcessesToUpdate::All, true);
        }
    });

    //let server_dead_clock = Arc::new(Mutex::new(std::time::Instant::now()));
    let vis_dead_clock = Arc::new(Mutex::new(std::time::Instant::now()));
    //let server_dead_clock_ref = Arc::clone(&server_dead_clock);
    let vis_dead_clock_ref = Arc::clone(&vis_dead_clock);

    // let server_dead_state = false;
    // let server_dead_state = Arc::new(Mutex::new(server_dead_state));
    // let server_dead_state_ref = Arc::clone(&server_dead_state);

    thread::spawn(move || {
        loop {
            // if server_dead_clock_ref.lock().unwrap().elapsed().as_secs_f32() > 1.0 {
            //     *server_dead_state.lock().unwrap() = true;
            // }

            let name = "lt_server";
            if vis_dead_clock_ref.lock().unwrap().elapsed().as_secs_f32() > 1.0 {
                let system = Arc::clone(&system);
                for process in system.lock().unwrap().processes_by_exact_name(OsStr::new(name)) {
                    let _ = process.kill();
                }

                exit(0);
            }
        }
    });

    let args: Vec<String> = std::env::args().collect();
    let port = if args.len() < 2 { 3000 } else { args[1].parse::<u16>().unwrap_or(3000) };
    let bindaddr: SockAddr = SocketAddrV4::new(Ipv4Addr::UNSPECIFIED, port).into();

    // let send_socket = Socket::new(Domain::IPV4, Type::DGRAM, Some(Protocol::UDP)).expect(
    //     "Failed to create socket"
    // );
    // send_socket.set_broadcast(true).expect("Failed to set broadcast");
    // send_socket.set_reuse_address(true).expect("Failed to set reuse address");
    
    let recv_socket = Socket::new(Domain::IPV4, Type::DGRAM, Some(Protocol::UDP)).expect(
        "Failed to create socket"
    );
    recv_socket.set_broadcast(true).expect("Failed to set broadcast");
    recv_socket.set_reuse_address(true).expect("Failed to set reuse address");
    recv_socket.bind(&bindaddr).expect("Failed to bind socket");
    let mut buf = [MaybeUninit::<u8>::uninit(); BUF_SIZE];

    // thread::spawn(move || {
    //     loop {
    //         let status_buffer = format!("{{\"host\":\"ltsv\",\"server_state\":{}}}", server_dead_state_ref.lock().unwrap());
    //         let status_buffer = status_buffer.as_bytes();
    //         let _ = send_socket.send_to(&status_buffer, &send_addr);
    //         thread::sleep(std::time::Duration::from_millis(60));
    //     }
    // });
    
    loop {
        let result = recv_socket.recv_from(&mut buf);
        // Todo: Safe?
        let data = unsafe {
            mem::transmute::<[std::mem::MaybeUninit<u8>; BUF_SIZE], [u8; BUF_SIZE]>(buf)
        };

        if let Ok((size, _)) = result {
            if data[0] == 123 {
                for i in 0..size {
                    if data[i] == 125 {
                        let json = String::from_utf8(data[0..i + 1].to_vec()).unwrap();
                        let json_data = serde_json::from_str::<serde_json::Value>(&json).unwrap();
                        let host = json_data["host"].as_str().unwrap_or("err");
                        match host {
                            // "lt" => {
                            //     *server_dead_clock.lock().unwrap() = std::time::Instant::now();
                            // }
                            "ltv" => {
                                *vis_dead_clock.lock().unwrap() = std::time::Instant::now();
                            }
                            "ltsv" => {
                                // Do nothing (self)
                            }
                            "err" => {
                                println!("Unexpected JSON data was received");
                            }
                            _ => {}
                        }

                        break;
                    }
                }
            }
        }
    }
}
