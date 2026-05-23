configure_updates
=========

![molecule workflow](https://github.com/straysheep-dev/ansible-role-configure_updates/actions/workflows/molecule.yml/badge.svg) ![ansible-lint workflow](https://github.com/straysheep-dev/ansible-role-configure_updates/actions/workflows/ansible-lint.yml/badge.svg)

Installs scheduled tasks and shell scripts that handle various system updates.

This role defaults to systemd-timers, if the target supports it. Otherwise it will fall back to cron.

Scheduling local tasks was chosen over using an Anisble controller to ochestrate scheduled updates remotely via [update_packages](https://github.com/straysheep-dev/ansible-role-update_packages), for the following reasons:

- Speed and reliability
- The failure rate for system upgrades via Ansible tasks is high
- Ansible is for setting a state, not performing system upgrades

> [!NOTE]
> 1. To initialize submodules in this template, do: `git submodule update --init --recursive`
> 2. Replace all instances of `role_name` with the actual `role_name`, **EXCEPT FOR `role_name_check: 1` in `molecule.yml`**
> 3. Replace all instances of `ansible-role-template` with `ansible-role-<role_name>`
> 4. To update submodules, do: `git submodule update --remote --recursive`, see [straysheep.dev/blog/resources/#git](https://straysheep.dev/blog/2019/07/15/-resources/#git)

> [!IMPORTANT]
> **Git Submodules & CI**: The dockerfiles for molecule tests are maintained in a [monorepo](https://github.com/straysheep-dev/docker-configs) as submodules for maintainability / repeatability across all roles. Because of this, the CI workflow requires `actions/checkout` to have `submodules: 'recursive'`.

> [!TIP]
> For local development, don't forget to symlink your `<namespace>.<role_name>` to one of the paths Ansible expects roles to exist under. This is the alternative to using a relative file path in `molecule/converge.yml`.
>
> ```bash
> ln -s ~/src/ansible-role-role_name ~/.ansible/roles/<namespace>.role_name
> ```

Requirements
------------

On Debian-family hosts (Debian, Ubuntu, Proxmox VE) this role installs the [`needrestart`](https://github.com/liske/needrestart/blob/master/README.batch.md) package and uses it to reliably determine if we're pending a reboot in `reboot-logic.sh`. `/run/reboot-required` is not always reliable outside of Ubuntu.

Role Variables
--------------

You do not *need* to modify role variables, but can.

By default, [`update-packages.sh`](files/update-packages.sh) which handles standard system package updates, is enabled to run every night at 3am. This is followed by the [`reboot-logic.sh`](files/reboot-logic.sh) task which defaults to running at 4am.

If a display (X11 or Wayland) is detected, the default logic is to *not* automate reboots, assuming it's a workstation. Override this in an inventory file as needed.

```yaml
update_schedules:
  - name: update-packages
    script: update-packages.sh
    timeout: "30m"                   # Works for both, systemd-timers, and cron + /bin/timeout
    enabled: true                    # enabled: false will remove the scheduled task from the target
    user: root
    # systemd backend
    on_calendar: "*-*-* 03:00:00"
    # On Wazuh, update-packages depends on update-wazuh.service completing cleanly
    requires: "{{ ['update-wazuh.service'] if (is_wazuh | default(false)) else [] }}"
    after: "{{ ['update-wazuh.service'] if (is_wazuh | default(false)) else [] }}"
    # cron backend
    cron_expression: "0 3 * * *"

  - name: reboot-logic
    script: reboot-logic.sh
    timeout: "5m"
    # Don't default to automatic reboots on workstations, override as needed.
    enabled: "{{ is_headless | default(false) | bool }}"
    user: root
    # systemd backend
    on_calendar: "*-*-* 04:00:00"
    # On Proxmox, reboot-logic depends on pve-maintenance.service completing cleanly
    requires: "{{ ['pve-maintenance.service'] if (is_proxmox | default(false)) else [] }}"
    after: "{{ ['pve-maintenance.service'] if (is_proxmox | default(false)) else [] }}"
    # cron backend
    cron_expression: "0 4 * * *"

```

### Wazuh

Automate Wazuh upgrades if Wazuh server components are detected. Right now, this makes two assumptions:

- You are running a stand-alone Wazuh instance, all components on one machine
- You are using SOPS + age, and optionally a key vault to store and access secrets on Wazuh

If one of (`wazuh-manager`, `wazuh-dashboard`, `wazuh-indexer`) are found, [update-wazuh.sh](./files/update-wazuh.sh) is installed and scheduled to safely execute ahead of any other update tasks. Wazuh services need [prepared and cannot be upgraded like normal system services](https://documentation.wazuh.com/current/upgrade-guide/upgrading-central-components.html). To make this task work with `update-packages`, we only use the systemd backend by default.

```yaml
update_schedules:
  - name: update-wazuh
    # By defualt, this installs a .service file with no timer.
    # update-wazuh gets wired together with update-packages, so that we never run
    # package updates on a Wazuh server until the central components are updated
    # successfully.
    timeout: "2h"
    script: update-wazuh.sh
    enabled: "{{ is_wazuh | default(false) | bool }}"
    user: root
    # systemd backend
    #on_calendar: "*-*-* 00:00:00"
    #requires: []
    #after: []
    # cron backend
    #cron_expression: "0 0 * * *"

```

### Proxmox

Automate VM snapshots, and hypervisor (host) upgrades, if Proxmox (`/usr/bin/pveversion`) is detected.

- pve-maintenance will gracefully shutdown and snapshot all running VMs
- If a VM does not have the `qemu-guest-agent` installed, it will fail to shutdown and the task stops here
- If `needrestart -k -b` detects a pending kernel upgrade, the VMs stay off for `reboot-logic` to run
- You must ensure necessary VMs are capable of booting automatically when Proxmox restarts
- To make this task work with `reboot-logic`, we only use the systemd backend by default.

```yaml
update_schedules:
  - name: pve-maintenance
    # By defualt, this installs a .service file with no timer.
    # pve-maintenance gets wired together with reboot-logic, so that we never reboot
    # if VM's are not cleanly shutdown and snapshots taken. That's why the timer backends
    # below are commented out. You can uncomment them to have updates and VM snapshots run
    # additionally on their own schedule, but reboot-logic always invokes this task on
    # Proxmox, meaning it will run twice. Account for this when scheduling a timer.
    script: pve-maintenance.sh
    timeout: "1h"
    enabled: "{{ is_proxmox | default(false) | bool }}"
    user: root
    # systemd backend
    #on_calendar: "Sun *-*-* 02:00:00"
    #requires: []
    #after: []
    # cron backend
    #cron_expression: "0 2 * * 0"

```

Dependencies
------------

None.

Example Playbook
----------------

Simply install the correct tasks on the targets to automate upgrades:

```yaml
- name: "Default Playbook"
  hosts: all
    #some_group
  roles:
    - role: straysheep_dev.configure_updates
```

For more advanced inventory-based usage (with SOPS + age) you'll want to use inventory groups (below), or [`host_group_vars`](https://docs.ansible.com/projects/ansible/latest/inventory_guide/intro_inventory.html#organizing-host-and-group-variables).


```yaml
---
workstations:
  hosts:
    localhost:
      ansible_connection: local
      ansible_become_password: "{{ admin1_sudo_pass }}"
    192.168.122.61:
        ansible_user: admin
        ansible_become_password: "{{ admin2_sudo_pass }}"
    192.168.122.75:
        ansible_user: admin
        ansible_become_password: "{{ admin3_sudo_pass }}"
    192.168.122.120:
        ansible_user: admin
        ansible_become_password: "{{ admin4_sudo_pass }}"

wazuh_servers:
  hosts:
    10.20.30.40:
      ansible_port: 2222
      ansible_user: wazuh
      ansible_become_password: "{{ wazuh_sudo_pass }}"
      ansible_become_method: sudo

proxmox_servers:
  hosts:
    10.100.100.100:
      ansible_port: 22
      ansible_user: pveadmin
      ansible_become_password: "{{ pveadmin_sudo_pass }}"
      ansible_become_method: sudo

```

License
-------

[MIT](./LICENSE)

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs)

> [!NOTE]
> **AI-assisted Authorship**
>
> The following models and tools were used for drafts, examples, or research:
> - [Claude (`claude-sonnet-4.6`, `claude-opus-4.7`) via web and Claude Code](https://claude.com/product/overview)
