role_name
=========

![molecule workflow](https://github.com/straysheep-dev/ansible-role-template/actions/workflows/molecule.yml/badge.svg) ![ansible-lint workflow](https://github.com/straysheep-dev/ansible-role-template/actions/workflows/ansible-lint.yml/badge.svg)

A brief description of the role goes here.

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

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

Role Variables
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```yml
- name: "Default Playbook"
  hosts: all
    #some_group
  roles:
    - role: straysheep_dev.role_name
```


License
-------

[MIT](./LICENSE)

Author Information
------------------

[straysheep-dev/ansible-configs](https://github.com/straysheep-dev/ansible-configs)
