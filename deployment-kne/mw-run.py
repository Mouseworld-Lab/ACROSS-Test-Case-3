import click
import subprocess

@click.command()
def main():
    cg_clients = click.prompt('Enter number of cg_clients', type=int)
    ddos_clients = click.prompt('Enter number of ddos_clients', type=int)

    # Write the variables to a temporary YAML file
    with open('clients_number.yaml', 'w') as f:
        f.write(f"---\n# Declare the number of cglients and ddosclient for the deployment\ncg_count: {cg_clients}\nddos_count: {ddos_clients}\n")


    subprocess.run(['ansible-playbook', 'mw-deployment.yaml'])
    subprocess.run(['ansible-playbook', 'mw-config.yaml'])


    # Playbook options
    playbook_choices = ['mw-test1', 'mw-test2', 'mw-test10ceosrev', 'mw-test4' , 'mw-tasks', 'mw-testacross']

    chosen_playbook_num = click.prompt("Choose the next playbook to execute (1: mw-test1, 2: mw-test2, 3: mw-test10ceosrev, 4: mw-test4 , 5: mw-tasks, 6: mw-testacross)", type=click.IntRange(1, 6))
    chosen_playbook = playbook_choices[chosen_playbook_num - 1]
    subprocess.run(['ansible-playbook', f'{chosen_playbook}.yaml'])


    # After executing, automatically execute mw-undeploy.yaml
    subprocess.run(['ansible-playbook', 'mw-undeploy.yaml'])

if __name__ == '__main__':
    main()
