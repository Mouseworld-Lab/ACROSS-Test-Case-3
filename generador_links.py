import os
import re
from collections import defaultdict

def parse_interface_configs(file_content):
    interfaces = {}
    interface_pattern = re.compile(r'interface (\S+)')
    ip_pattern = re.compile(r' ip address (\S+) (\S+)')

    current_interface = None

    for line in file_content:
        interface_match = interface_pattern.match(line)
        if interface_match:
            current_interface = interface_match.group(1)
            interfaces[current_interface] = {}
        
        ip_match = ip_pattern.match(line)
        if ip_match and current_interface:
            interfaces[current_interface]['ip'] = ip_match.group(1)
            interfaces[current_interface]['subnet'] = ip_match.group(2)

    return interfaces

def read_config_files(directory):
    nodes = {}
    ip_to_interface = {}

    for filename in os.listdir(directory):
        if filename.endswith("-config"):
            node_name = filename.split('-')[0]
            with open(os.path.join(directory, filename), 'r') as file:
                file_content = file.readlines()
                interfaces = parse_interface_configs(file_content)
                nodes[node_name] = interfaces
                for interface, details in interfaces.items():
                    ip_to_interface[details['ip']] = (node_name, interface)
    
    return nodes, ip_to_interface

def ip_to_network(ip, subnet):
    ip_parts = list(map(int, ip.split('.')))
    subnet_parts = list(map(int, subnet.split('.')))
    network_parts = [ip_parts[i] & subnet_parts[i] for i in range(4)]
    return '.'.join(map(str, network_parts))

def generate_links(nodes, ip_to_interface):
    links = []
    processed = set()  # To keep track of processed links

    for ip, (node, interface) in ip_to_interface.items():
        subnet = nodes[node][interface]['subnet']
        network = ip_to_network(ip, subnet)
        other_ip, other_node, other_interface = ip_to_interface.get(ip[::-1], (None, None, None))  # Reversed IP
        if other_ip and (other_node, other_interface, node, interface) not in processed:  # Check if reverse link is not processed
            links.append({
                "a_node": node,
                "a_int": interface.replace('GigabitEthernet', 'eth'),
                "z_node": other_node,
                "z_int": other_interface.replace('GigabitEthernet', 'eth')
            })
            processed.add((node, interface, other_node, other_interface))

    return links

def format_links(links):
    output = "links:\n"
    for link in links:
        output += f'  - a_node: "{link["a_node"]}"\n'
        output += f'    a_int: "{link["a_int"]}"\n'
        output += f'    z_node: "{link["z_node"]}"\n'
        output += f'    z_int: "{link["z_int"]}"\n'
        output += '\n'
    return output

def main():
    directory = '.'  # Assuming the config files are in the current directory
    nodes, ip_to_interface = read_config_files(directory)
    links = generate_links(nodes, ip_to_interface)
    output = format_links(links)
    print(output)

if __name__ == "__main__":
    main()
