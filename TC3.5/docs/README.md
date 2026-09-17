**The programs and scripts that have been implemented are the following:**
#### **Cgserver:**
- ACROSSserver.py:
    ```
    kubectl exec -n ddos cgserver -- python3 ACROSSserver.py 
    ```
    We use the sockets library in Python, which offers low-level access to network interfaces. Using this library, we have developed a straightforward server that listens for bursts of traffic from clients.

#### **Ddosserver:**
- caddy:
    ```
    kubectl exec -n ddos ddosserver -- caddy run --config /etc/caddy/Caddyfile' 
    ```
    We have set up a standard HTTP/3 server using caddy, with the aim of delivering a basic 'Hello World' web page. Currently the site URL is https://micaddy.com (only works with local dns).

- bind9:
    ```
    kubectl exec -n ddos ddosserver -- service named start
    ```
    We have setup a dns server using bind9. The server is waiting to receive new queries through port 53.
    - Features: EDNS, DNSSEC, DOH support

 - dnsdist:
    ```
    kubectl exec -n ddos ddosserver -- service dnsdist start
    ```
    Dnsdist is a load balancing and redirection server for DNS services. In this configuration, provides a DNS over HTTPS (DoH) service on all interfaces and port 4443 using TLS certificates located in "/etc/ssl/certs/doh-cert.pem" and "/etc/ssl/certs/doh-key.pem". It acts as a DoH proxy, redirecting queries to the local DNS server listening on the local address and port 53.


#### **Cgclient:**
- ACROSSfile_transfer.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- python3 ACROSSfile_transfer.py <large_file_url> [<limit_rate>]
    ```
    To simulate elephant flows, we have used WGET to generate file transfers. With this, we begin to download a large video file from a website.
    - Parameters:
        
        -<large_file_url>: set the url to dowload the large file
        -<limit_rate>: optional argument to limit download speed

- ACROSSfile_transfer_scp.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- env cgserver={{ cgserver_ip }} python3 ACROSSfile_transfer_scp.py [<limit_rate>]
    ```
    To simulate elephant flows, we have used scp. With this, we begin the transference of a large archive.
    - Parameters:

        -<limit_rate>: optional argument to limit download speed
        
- ACROSSconsuming_video.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- python3 ACROSSconsuming_video.py <Twitch_stream_URL> <viewing_time>
    ```
    This Python script automates the process of opening and consuming a video stream. It is designed to simulate elephant flows having a large number of users consuming a viral streaming. We can also consume a normal video (not streaming) and this will generate cheetah streams (Twitch VOD). To automate web browsing we use the Selenium library.
    - Parameters:

        -<Twitch_stream_URL>: set the url to a Twitch stream

        -<viewing_time>: set the viewing time video

- ACROSSconsuming_video_YT.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- python3 ACROSSconsuming_video.py <YT_video_URL> <viewing_time>
    ```
    This Python script automates the process of opening and consuming a video stream. It is designed to simulate elephant flows having a large number of users consuming a viral streaming. We can also consume a normal video (not streaming) and this will generate cheetah streams. To automate web browsing we use the Selenium library.
    - Parameters:

        -<YT_video_URL>: set the url to a Youtube Video

        -<viewing_time>: set the viewing time video
        
- ACROSSshorts.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- python3 ACROSSshorts.py <viewing_time>
    ```
    This Python script automates the process of opening YouTube Shorts and simulating the user scrolling through the Shorts feed at a random pace. It is designed to simulate cheetah flow, where a user scrolls through YouTube Shorts and videos load lazily as they show up in the browser viewport. We also use  the Selenium libraryto automate the procces.
    - Parameters:

        -<viewing_time>: set the viewing time of Youtube shorts

- ACROSSrandom_walk.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- python3 ACROSSrandom_walk.py <set_time>
    ```
    This Python script simulates browsing publicly accessible web pages over the Internet using Selenium. It is designed to simulate normal benign traffic.
    - Parameters:

        -<set_time>: set the time for the simulation

- ACROSSclient.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- env cgserver={{ cgserver_ip }} python3 ACROSSclient.py <set_multiplier>
    ```
    This Python script generates short-lived bursts of high traffic, creating 'cheetah flows'. To simulate this behavior, random spikes of data are sent to the server during communication. This can be achieved by sending a sudden surge of packets over a short duration.
    - Parameters:

        -<set_multiplier>: adjust the multiplier as needed.

- aria2c:
    ```
    kubectl exec -n ddos cgclient14 -- aria2c --disable-ipv6=true --max-upload-limit=100 <set_URL>
    ```
    Simulate benign p2p traffic 

    - Parameters:

        -<set_URL>: set the URL to dowload

- ACROSSrand_dig.sh:
    ```
    kubectl exec -n ddos cgclient15 -- ./ACROSSrand_dig.sh 1800 <set_time>
    ```
    This Python script simulate benign dns queries with dig. DNS server: 8.8.8.8

    - Parameters:

        -<set_time>: set the time for the simulation





#### **Ddosclient:**
- hping3.sh:
    ```
    kubectl exec -n ddos {{ item.pod }} -- env ddosserver={{ ddosserver_ip }} sudo hping3 <select_mode> -c <number_of_packets> -d <packet_data_size> -S <target_ip> -w <window size> -p <select_port> --flood
    ```
    This script initiates a DDoS attack on the server using hping3 with specified parameters, simulating a IP/TCP/UDP flood of traffic.
    - Parameters:
        
        -<select_mode>: TCP -> leave blank, IP -> -0, ICMP -> -1, UDP -> -2 

        -<number_of_packets>: set the packet number to send
        
        -<packet_data_size>: set the packet data size
        
        -<target_ip>: target ip to flood
        
        -<window_size>: MTU size
        
        -<select_port>: set the port to flood

- vegeta.sh:
    ```
    kubectl exec -n ddos {{ item.pod }} -- env ddosserver={{ ddosserver_ip }} ./vegeta.sh <set_time>
    ```
    This script initiates a DDoS attack on the server using vegeta (https://github.com/tsenart/vegeta), simulating a HTTP flood of traffic.
    - Parameters:
        
        -<set_time>: set the time of the flood.

- dns_scapy.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- env ddosserver={{ ddosserver_ip }} python3 dns_scapy.py <dns_query_packets>
    ```
    This script initiates a DNS Amplification attack on the local Dns server using the scapy library.
    - Parameters:
        
        -<dns_query_packets>: set the number of querys.

- dns-amp:
    ```
    kubectl exec -n ddos {{ item.pod }} --  ./dns_amp/dns-amp <destination_ip> -t <set_type> -f <set_file> -s <source_ip> -p <dst_port> -P <src_port> -i <set_interval> -n <query_number> -d <set_duration> -r -D -S -h  
    ```
    This script initiates a DNS Amplification attack using C
    - Parameters:
        
        -<destination_ip>: IP of the DNS server.
        
        -<set_qtype>: query type to ask for.
        
        -<set_file>: set the file with the qnames

        -<source_ip>: set the spoofed source ip.

        -<dst_port>: destination port.

        -<src_port>: source port.

        -<set_interval>: interval (in microsecond) between two packets.

        -<query_number>: set the number of querys.

        -<set_duration>: run for at most this many seconds.

        -r: fake random source IP

        -D: run as daemon

        -S: enable dnssec

        -h: help

- floodoh.py:
    ```
    kubectl exec -n ddos {{ item.pod }} -- python3 cne-DoH-master/floodoh.py <n_connect> <set_qname> <set_qtype> <doh_url>
    ```
    In order to do a quick test on lots of connections to a DoH server we have been using a small python script that generates connections and occasionally asks a question in them. You can se more documentation inside cne-DoH-master folder.
    - Parameters:
        
        -<n_connect>: set the number of connections.
        
        -<set_qname>: DNS name to ask over and over again.

        -<set_qtype>: query type to ask for.

        -<doh_url>: URL of the DoH server.

- quic-flooding.sh:
    ```
    kubectl exec -n ddos {{ item.pod }} -- ./quic-flooding.sh
    ```
    This attack initiates a flood of requests to the caddy server with the aim of causing a denial of service. It consists of sending a large number of QUIC requests simultaneously to a specific server using the aioquic library taking advantage of the 0-RTT protocol to reduce the connection startup time.

- synflood:
    ```
    kubectl exec -n ddos {{ item.pod }} -- ./synflood/synflood <destination_ip> <dst_port> -i <set_interface> -s <spoofed_source_ip> -n <set_number>
    ```
    This attack initiates a SYN flood attack to an ip address
    - Parameters:

    -<destination_ip>: IP of the DNS server.

    -<dst_port>: destination port.
    
    -<set_interface>: Specify network interface.

    -<source_ip>: set the spoofed source ip (optional parameter).

    -<set_number>: Specify number of connections.

- watertorture:
    ```
    kubectl exec -n ddos {{ item.pod }} -- ./dns-flood/dnsflood <query_name> <destination_ip> -s <source_ip> -p <dst_port> -P <src_port> -i <set_interval> -n <query_number> -d <set_duration> -r -R -D -S -h  
    ```
    This attack initiates a DNS water torture attack with the flag -R
    - Parameters:

    -<query_name>: set domain name.

    -<destination_ip>: IP of the DNS server.

    -<source_ip>: set the spoofed source ip.

    -<dst_port>: destination port.
    
    -<src_port>: source port.

    -<set_interval>: interval (in microsecond) between two packets.

    -<query_number>: set the number of querys.

    -<set_duration>: run for at most this many seconds.

    -r: fake random source IP.

    -R: prefix with random subdomain names.

    -D: run as daemon.

    -S: enable dnssec.

    -h: help.

    
