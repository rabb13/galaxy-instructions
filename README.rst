Galaxy (galaxyproject_) Instructions
------------------------------------

This documents aims for who has no or little experience Ansible or Saltstack (pick one). May not be complete at this time of writing.**

These documents includes - 
 - Instruction/Notes to deploy Galaxy_ using SaltStack_ from https://github.com/rabb13/saltstack-galaxy.
 - Notes to deploy Galaxy_ using Ansible_ from https://github.com/rabb13/ansible-galaxy.
 - Script to fix tools which are currently broken when you try install from tool shed.
 - Script to Download and Update datamanager (.loc) files
 - Install annovar (Not including the tool itself)


Version compatiblity:
---------
 Galaxy:
   Tested - v17.09 & 18.01**
   Compatiblity - 17. +
 OS:
   Tested: Ubuntu 16.04
   Compatbilty : Ubuntu 16.04 + , Redhat/CentOS 7 + (Maybe Most major release with systemd)
 Saltstask: 
  Tested: 2016.11
  Compatiblity: 2016.11 _
 Ansible: 
  Tested: 2.4.0
  Compatiblity: 2.4 +

Deploying Galaxy using `saltstack-galaxy` _
----------------------------------------

 - Install salt minion : `Follow instruction based on your distribution <https://repo.saltstack.com/>`_ .
 - Standalone Salt Minion setup : `Follow instruction here <https://docs.saltstack.com/en/latest/topics/tutorials/standalone_minion.html>`_ .
 - example configuration of "/etc/salt/minion" 
 .. code::

   #----------------------
   master_type: "disable"
   file_client: local
   file_roots:
     base:
       - /srv/salt
   pillar_roots:
     base:
       - /srv/pillar
   #----------------------
..

 - Copy the dirctory `saltstack/galaxy <https://github.com/rabb13/saltstack-galaxy/tree/master/galaxy>`_ to /srv/salt
 - Create a file "/srv/pillar/top.sls" and Enter the configuration based on `pilalr.example <https://github.com/rabb13/saltstack-galaxy/blob/master/pillar.example>`
----------------------------------------

Deploying Galaxy using `ansible-galaxy` _
----------------------------------------
 - Install Ansible : `Instructions here- <http://docs.ansible.com/ansible/latest/intro_installation.html#installing-the-control-machine>`_ .
 - In this example we will use local host with default ansible config.
 - Copy the contents of `ansible-galaxy <https://github.com/rabb13/ansible-galaxy>`_ to "/etc/asible/roles/galaxy" (create directory i you need to)
 - Give your localhost a name: add a line "galaxy-local ansible_connection=local"
 - Create a playbook for galaxy-local, e.g. "/etc/ansible/galaxy-local.yml'
 - example config: 
 .. code:: 

 \- hosts:

   \- galaxy-local
  roles:

   \- postgresql # Only if you want to use postgres

   \- nginx  # only if you want to use nginx

   \- galaxy
..

 - Create vars file for this host here- "/etc/ansible/hosst_vars/galaxy-local.yml" and Enter the Vars exlained `here <https://github.com/rabb13/ansible-galaxy>`_


Tools fixer - "bx-python"
------------------------

Reason: currently the galaxy tool depndeny "package_bx_python_0_7" is broken.
Fix: 
  - Download the script `galaxy_fix_bx-python.sh <https://raw.githubusercontent.com/rabb13/galaxy-instructions/master/scripts/galaxy_fix_bx-python.sh>`_ .
  - open it with an editor, make sure all the variables are set correctly
  - make it executable: ``chmod +x galaxy_fix_bx-python.sh``
  - run it: ``./galaxy_fix_bx-python.sh``


DataManager Update
-----------------

Note: This will update Galaxy_ datamanager list automatically
Instrcution:
 - Download the script : `galaxy_datamanager_update.sh <https://raw.githubusercontent.com/rabb13/galaxy-instructions/master/scripts/galaxy_datamanager_update.sh>`_
 - open it with an editor, make sure all the variables and loc file list are updated
 - make it executable: ``chmod +x galaxy_datamanager_update.sh``
 - run it: ``./galaxy_datamanager_update.sh``

**TO BE CONTINUED**


--------------------------------------------

.. _Galaxy: https://galaxyproject.org/
.. _galaxyproject: https://galaxyproject.org/
.. _SaltStack: https://saltstack.com/
.. _Ansible: https://www.ansible.com/
.. _saltstack-galaxy https://github.com/rabb13/saltstack-galaxy
.. _ansible-galaxy https://github.com/rabb13/ansible-galaxy

