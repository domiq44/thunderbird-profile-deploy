# ---------------------------------------------------------
# Makefile pour le déploiement Thunderbird
# ---------------------------------------------------------

.PHONY: help deploy clean

help:
	@echo ""
	@echo "Commandes disponibles :"
	@echo ""
	@echo "  make deploy                        → Lance le playbook"
	@echo "  make deploy thunderbird_force_reset=true"
	@echo "                                    → Lance un reset complet"
	@echo "  make clean                         → Nettoie les fichiers temporaires"
	@echo ""

deploy:
	ansible-playbook -i inventory deploy_thunderbird.yml \
		-e "thunderbird_force_reset=$(thunderbird_force_reset)"

clean:
	rm -f *.retry
