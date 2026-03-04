configure_updates
=========

![molecule workflow](https://github.com/straysheep-dev/ansible-role-configure_updates/actions/workflows/molecule.yml/badge.svg) ![ansible-lint workflow](https://github.com/straysheep-dev/ansible-role-configure_updates/actions/workflows/ansible-lint.yml/badge.svg)

Installs scheduled tasks and shell scripts that handle various system updates.

This was chosen over using an Anisble controller to ochestrate scheduled updates via [update_packages](), for speed and reliability.

- Running Ansible tasks as one-off state changes on deployed assets often can be handled as-needed
- The failure rate for something like automating system updates is high, and slower than scheduling this as a local task on the targets

> [!NOTE]
> 1. To initialize submodules in this template, do: `git submodule update --init --recursive`
> 2. Replace all instances of `role_name` with the actual `role_name`, **EXCEPT FOR `role_name_check: 1` in `molecule.yml`**
> 3. Replace all instances of `ansible-role-template` with `ansible-role-<role_name>`
> 4. To update submodules, do: `git submodule update --remote --recursive`, see [straysheep.dev/blog/resources/#git](https://straysheep.dev/blog/2019/07/15/-resources/#git)

> [!IMPORTANT]
> **Git Submodules & CI**: The dockerfiles for molecule tests are maintained in a [monorepo](https://github.com/straysheep-dev/docker-configs) as submodules for maintainability / repeatability across all roles. Because of this, the CI workflow requires `actions/checkout` to have `submodules: 'recursive'`.

Requirements
------------

None.

Role Variables
--------------

Each update script has its own parameters that can be adusted under `defaults/main.yml`. By default, [`update-packages.sh`](files/update-packages.sh) which handles standard system package updates, is enabled by default to run every night at 3am.

```yaml
update_cron_jobs:
  - name: update-packages
    script: update-packages.sh
    enabled: true
    user: root
    minute: "0"
    hour: "3"
    day: "*"
    month: "*"
    weekday: "*"

```

Dependencies
------------

None.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yml
- name: "Default Playbook"
  hosts: all
    #some_group
  roles:
    - role: straysheep_dev.configure_updates
```


License
-------

[MIT](./LICENSE)

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs)
