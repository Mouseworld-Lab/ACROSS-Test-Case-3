import os
import re
import yaml

def parse_interface_configs(file_content):
    interfaces = {}
    interface_pattern = re.compile(r'interface (\S+)')
    ip_pattern = re.compile(r' ip address (\S+) (\S+)')

    current_interface = None
    process_interface = False
    flow_exporter_block = False

    for line in file_content:
        #print("Line:", line)  # Debug print
        if line.strip().startswith('flow exporter'):
            #print("Flow Exporter block detected")  # Debug print
            flow_exporter_block = True  # Start ignoring lines after this block begins
            continue  # Ignore this line and move to the next one
        elif line.startswith('!') and not line.strip().startswith('!'):
            #print("End of Flow Exporter block detected")  # Debug print
            flow_exporter_block = False  # Stop ignoring lines after the block ends
            continue  # Ignore this line and move to the next one

        if flow_exporter_block:
            continue  # Skip lines within the flow exporter block

        interface_match = interface_pattern.match(line)
        if interface_match:
            current_interface = interface_match.group(1)
            interfaces[current_interface] = {}
            continue

        if current_interface:
            ip_match = ip_pattern.match(line)
            if ip_match:
                interfaces[current_interface]['ip'] = ip_match.group(1)
                interfaces[current_interface]['subnet'] = ip_match.group(2)

    return interfaces

def read_config_files(directory):
    nodes = {}
    ip_to_interface = {}
    ip_interface_per_router = {}  # Dictionary to store IP-interface relationship per router

    for filename in os.listdir(directory):
        if filename.endswith("-config"):
            node_name = filename.split('-')[0]
            with open(os.path.join(directory, filename), 'r') as file:
                file_content = file.readlines()
                interfaces = parse_interface_configs(file_content)
                nodes[node_name] = interfaces
                ip_interface_per_router[node_name] = {}  # Initialize dictionary for the router
                for interface, details in interfaces.items():
                    if 'ip' in details:
                        ip_to_interface[details['ip']] = (node_name, interface)
                        ip_interface_per_router[node_name][details['ip']] = interface.replace('GigabitEthernet', 'eth')  # Store IP-interface relationship for the router
    return nodes, ip_to_interface, ip_interface_per_router

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

        for other_ip, (other_node, other_interface) in ip_to_interface.items():
            if ip != other_ip and ip_to_network(other_ip, subnet) == network:
                if (node, interface, other_node, other_interface) not in processed:
                    links.append({
                        "a_node": node,
                        "a_int": interface.replace('GigabitEthernet', 'eth'),
                        "z_node": other_node,
                        "z_int": other_interface.replace('GigabitEthernet', 'eth')
                    })
                    processed.add((node, interface, other_node, other_interface))
                    processed.add((other_node, other_interface, node, interface))  # Ensure reverse link is not processed again
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

def format_ip_interface(ip_interface_per_router):
    output = "IP-Interface per Router:\n"
    for router, ip_interface in ip_interface_per_router.items():
        output += f'  Router: {router}\n'
        for ip, interface in ip_interface.items():
            output += f'    {ip}: {interface}\n'
        output += '\n'
    return output

def generate_sub_links(config_file, ip_interface_per_router):
    sub_links = []

    with open(config_file, 'r') as file:
        data = yaml.safe_load(file)

        for entity, info in data.items():
            gateway = info['gateway']
            if gateway in ip_interface_per_router:
                for ip, interface in ip_interface_per_router[gateway].items():
                    # Check if the server/client IP is in the same subnet as the router interface
                    router_ip = ip.split('.')[0] + '.' + ip.split('.')[1] + '.' + ip.split('.')[2]
                    if info['network'].startswith(router_ip):
                        sub_links.append({
                            "a_node": gateway,
                            "a_int": interface,
                            "z_node": entity,
                            "z_int": info['interface']
                        })

    return sub_links

def format_sub_links(sub_links):
    output = "sub_links:\n"
    for link in sub_links:
        output += f'  - a_node: "{link["a_node"]}"\n'
        output += f'    a_int: "{link["a_int"]}"\n'
        output += f'    z_node: "{link["z_node"]}"\n'
        output += f'    z_int: "{link["z_int"]}"\n'
        output += '\n'
    return output

def main():
    directory = '/home/mario/ACROSS_test/router_config'  # Assuming the config files are in the current directory
    nodes, ip_to_interface, ip_interface_per_router = read_config_files(directory)
    links = generate_links(nodes, ip_to_interface)
    output_links = format_links(links)
    output_ip_interface = format_ip_interface(ip_interface_per_router)

    config_file = '/home/mario/ACROSS_test/configuration/servers_clients.yaml'
    sub_links = generate_sub_links(config_file, ip_interface_per_router)
    output_sub_links = format_sub_links(sub_links)

    # Combine links, sub_links, and ip_interface_per_router into a single output
    output = output_links + output_sub_links + output_ip_interface

    # Remove "sub_links:" from the output
    output = output.replace("sub_links:\n", "")

    print(output)

if __name__ == "__main__":
    main()
