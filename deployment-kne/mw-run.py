import click
import subprocess
import time

@click.command()
def main():
    cg_clients = click.prompt('Enter number of cg_clients', type=int)
    ddos_clients = click.prompt('Enter number of ddos_clients', type=int)

    # Write the variables to a temporary YAML file
    with open('clients_number.yaml', 'w') as f:
        f.write(f"---\n# Declare the number of cglients and ddosclient for the deployment\ncg_count: {cg_clients}\nddos_count: {ddos_clients}\n")


    subprocess.run(['ansible-playbook', 'mw-deployment.yaml'])
    subprocess.run(['ansible-playbook', 'mw-config.yaml'])
    subprocess.run(['ansible-playbook', 'mw-mirror.yaml'])


    # Playbook options
    playbook_choices = [
    'mw-tasks', 
    'mw-testacross', 
    'playbooks-datasets/TC3.5_benign_traffic_only', 
    'playbooks-datasets/TC3.5_benign_HH_traffic_only', 
    'playbooks-datasets/TC3.5_ddos_traffic_only',
    'playbooks-datasets/TC3.5_all_at_once',
    'playbooks-datasets/TC3.5_ddos_with_intervals',
    'playbooks-datasets/TC3.5_unbalanced_traffic',	
    'mw-testacross-mitigation'
]

    chosen_playbook_num = click.prompt("Choose the next playbook to execute (1: mw-tasks, 2: mw-testacross, 3: TC3.5_benign_traffic_only, 4: TC3.5_benign_HH_traffic_only,"
    "5: TC3.5_ddos_traffic_only, 6: TC3.5_all_at_once, 7: TC3.5_ddos_with_intervals, 8: TC3.5_unbalanced_traffic, 9: mw-testacross-mitigation)", type=click.IntRange(1, 9))
    
    chosen_playbook = playbook_choices[chosen_playbook_num - 1]
    subprocess.run(['ansible-playbook', f'{chosen_playbook}.yaml'])

    # time.sleep(5)    
    # subprocess.run(['ansible-playbook', 'playbooks-datasets/TC3.5_ddos_with_intervals.yaml'])

    # After executing, automatically execute mw-undeploy.yaml
    subprocess.run(['ansible-playbook', 'mw-undeploy.yaml'])

if __name__ == '__main__':
    main()
