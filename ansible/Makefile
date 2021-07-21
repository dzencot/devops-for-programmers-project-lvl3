setup:
	make install

install:
	ansible-galaxy collection install -r requirements.yml
	ansible-galaxy role install -r requirements.yml

playbook-run:
	ansible-playbook -i inventory.ini playbook.yml --vault-password-file ~/.ansible_pass.txt
