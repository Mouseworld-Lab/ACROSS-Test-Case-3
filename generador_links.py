import os
import re

def parse_interface_configs(file_content):
    interfaces = {}
    interface_pattern = re.compile(r'interface (\S+)')
    ip_pattern = re.compile(r' ip address (\S+) (\S+)')

    current_interface = None
    process_interface = False

    for line in file_content:
        if line.startswith('!'):
            process_interface = True  # Only process interfaces that follow a '!'

        interface_match = interface_pattern.match(line)
        if interface_match:
            if process_interface:
                current_interface = interface_match.group(1)
                interfaces[current_interface] = {}
                # print(f"Found interface: {current_interface}")
            else:
                current_interface = None  # Ignore this interface

        if current_interface:
            ip_match = ip_pattern.match(line)
            if ip_match:
                interfaces[current_interface]['ip'] = ip_match.group(1)
                interfaces[current_interface]['subnet'] = ip_match.group(2)
                # print(f"Found IP: {ip_match.group(1)} with subnet: {ip_match.group(2)} on interface: {current_interface}")

    return interfaces

def read_config_files(directory):
    nodes = {}
    ip_to_interface = {}

    for filename in os.listdir(directory):
        if filename.endswith("-config"):
            node_name = filename.split('-')[0]
            # print(f"Reading configuration for node: {node_name} from file: {filename}")
            with open(os.path.join(directory, filename), 'r') as file:
                file_content = file.readlines()
                interfaces = parse_interface_configs(file_content)
                nodes[node_name] = interfaces
                for interface, details in interfaces.items():
                    if 'ip' in details:
                        ip_to_interface[details['ip']] = (node_name, interface)
                        # print(f"Mapping IP {details['ip']} to node {node_name}, interface {interface}")
                    else:
                        # print(f"No IP found for node {node_name}, interface {interface} in file {filename}")
                        pass
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
        # print(f"Processing IP: {ip}, Node: {node}, Interface: {interface}, Network: {network}")

        for other_ip, (other_node, other_interface) in ip_to_interface.items():
            if ip != other_ip and ip_to_network(other_ip, subnet) == network:
                if (other_node, other_interface, node, interface) not in processed:
                    links.append({
                        "a_node": node,
                        "a_int": interface.replace('GigabitEthernet', 'eth'),
                        "z_node": other_node,
                        "z_int": other_interface.replace('GigabitEthernet', 'eth')
                    })
                    processed.add((node, interface, other_node, other_interface))
                    # print(f"Link found between {node} {interface} and {other_node} {other_interface}")
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
    directory = '/home/mario/ACROSS_test/router_config'  # Assuming the config files are in the current directory
    # print(f"Reading configurations from directory: {directory}")
    nodes, ip_to_interface = read_config_files(directory)
    links = generate_links(nodes, ip_to_interface)
    output = format_links(links)
    print(output)

if __name__ == "__main__":
    main()

