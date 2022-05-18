#!/bin/bash

#'Set the main variables'
YELLOW="\033[133m"
GREEN="\033[032m"
RESET="\033[0m"

	: 'Basic requirements'
	basicRequirements() {
		echo -e "[$GREEN+$RESET] This script will install the required dependencies to run recon.sh, please stand by.."
		echo -e "[$GREEN+$RESET] It will take a while, go grab a cup of coffee :)"
		cd "$HOME" || return
		sleep 1
		echo -e "[$GREEN+$RESET] Getting the basics.."
		export LANGUAGE=en_US.UTF-8
		export LANG=en_US.UTF-8
		export LC_ALL=en_US.UTF-8
		sudo apt-get update -y
		sudo apt install npm
		sudo apt-get install git -y
		git clone https://github.com/x1mdev/ReconPi.git
		sudo apt-get install -y --reinstall build-essential
		sudo apt install -y python3-pip
		sudo apt install -y file
		sudo apt-get install -y dnsutils
		sudo apt install -y lua5.1 alsa-utils libpq5
		sudo apt-get autoremove -y
		sudo apt clean
		#echo -e "[$GREEN+$RESET] Stopping Docker service.."
		#sudo systemctl disable docker.service
		#sudo systemctl disable docker.socket
		echo -e "[$GREEN+$RESET] Creating directories.."
		mkdir -p "$HOME"/tools
		mkdir -p "$HOME"/go
		mkdir -p "$HOME"/go/src
		mkdir -p "$HOME"/go/bin
		mkdir -p "$HOME"/go/pkg
		sudo chmod u+w .
		echo -e "[$GREEN+$RESET] Done."
	}

: 'Golang initials'
golangInstall() {
	echo -e "[$GREEN+$RESET] Installing and setting up Go.."

	if [[ $(go version | grep -o '1.14') == 1.14 ]]; then
		echo -e "[$GREEN+$RESET] Go is already installed, skipping installation"
	else
		cd "$HOME"/tools || return
		git clone https://github.com/udhos/update-golang
		cd "$HOME"/tools/update-golang || return
		sudo bash update-golang.sh
		sudo cp /usr/local/go/bin/go /usr/bin/ 
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Adding recon alias & Golang to "$HOME"/.bashrc.."
	sleep 1
	configfile="$HOME"/.bashrc

	if [ "$(cat "$configfile" | grep '^export GOPATH=')" == "" ]; then
		echo export GOPATH='$HOME'/go >>"$HOME"/.bashrc
	fi

	if [ "$(echo $PATH | grep $GOPATH)" == "" ]; then
		echo export PATH='$PATH:$GOPATH'/bin >>"$HOME"/.bashrc
	fi

	if [ "$(cat "$configfile" | grep '^alias recon=')" == "" ]; then
		echo "alias recon=$HOME/ReconPi/recon.sh" >>"$HOME"/.bashrc
	fi

	bash /etc/profile.d/golang_path.sh

	source "$HOME"/.bashrc

	cd "$HOME" || return
	echo -e "[$GREEN+$RESET] Golang has been configured."
}

: 'Golang tools'
golangTools() {
	echo -e "[$GREEN+$RESET] Installing subfinder.."
	go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing subjack.."
	go install github.com/haccer/subjack@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing aquatone.."
	go install github.com/michenriksen/aquatone@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing httprobe.."
	go install github.com/tomnomnom/httprobe@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing assetfinder.."
	go install github.com/tomnomnom/assetfinder@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing gf.."
	go install github.com/tomnomnom/gf@latest
	echo 'source $GOPATH/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
	cp -r $GOPATH/src/github.com/tomnomnom/gf/examples ~/.gf
	cd "$HOME"/tools/ || return
	git clone https://github.com/1ndianl33t/Gf-Patterns
	cp ~/Gf-Patterns/*.json ~/.gf
	git clone https://github.com/dwisiswant0/gf-secrets
	cp "$HOME"/tools/gf-secrets/.gf/*.json ~/.gf
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing qsreplace.."
	go install github.com/tomnomnom/qsreplace@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing ffuf (Fast web fuzzer).."
	go install github.com/ffuf/ffuf@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing gobuster.."
	go install github.com/OJ/gobuster/v3@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing Amass.."
	apt install snapd
	snap install amass
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing getJS.."
	go install github.com/003random/getJS@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing shuffledns.."
	go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing dnsprobe.."
	go install github.com/projectdiscovery/dnsprobe@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing nuclei.."
	go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing dalfox"
	go install github.com/hahwul/dalfox/v2@latest
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing hakrawler"
	go install github.com/hakluke/hakrawler@latest
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing naabu"
	go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest
	echo -e "[$GREEN+$RESET] Done."

    echo -e "[$GREEN+$RESET] Installing httpx"
	go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing ASNIP"
	go install github.com/harleo/asnip@latest
	echo -e "[$GREEN+$RESET] Done."
	
}

: 'Additional tools'
additionalTools() {
	echo -e "[$GREEN+$RESET] Installing massdns.."
	if [ -e /usr/local/bin/massdns ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/blechschmidt/massdns.git
		cd "$HOME"/tools/massdns || return
		echo -e "[$GREEN+$RESET] Running make command for massdns.."
		make -j
		sudo cp "$HOME"/tools/massdns/bin/massdns /usr/local/bin/
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing nuclei-templates.."
	nuclei -update-templates
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing jq.."
	sudo apt install -y jq
	echo -e "[$GREEN+$RESET] Done."
	
	echo -e "[$GREEN+$RESET] Installing Chromium browser.."
	sudo apt install -y chromium-browser
	echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing dirsearch.."
	if [ -e "$HOME"/tools/dirsearch/dirsearch.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/maurosoria/dirsearch.git
		cd "$HOME"/tools/ || return
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing Arjun (HTTP parameter discovery suite).."
	if [ -e "$HOME"/tools/Arjun/arjun.py ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/s0md3v/Arjun.git
		python3 setup.py install
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing findomain.."
	arch=`uname -m`
	if [ -e "$HOME"/tools/findomain ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	elif [[ "$arch" == "x86_64" ]]; then
		wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-linux -O "$HOME"/tools/findomain
		chmod +x "$HOME"/tools/findomain
		sudo cp "$HOME"/tools/findomain /usr/local/bin
		echo -e "[$GREEN+$RESET] Done."
	else
		wget https://github.com/Edu4rdSHL/findomain/releases/latest/download/findomain-aarch64 -O "$HOME"/tools/findomain
		chmod +x "$HOME"/tools/findomain
		sudo cp "$HOME"/tools/findomain /usr/local/bin
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing nmap.."
		sudo apt-get install -y nmap
		wget https://raw.githubusercontent.com/vulnersCom/nmap-vulners/master/vulners.nse -O /usr/share/nmap/scripts/vulners.nse && nmap --script-updatedb
		echo -e "[$GREEN+$RESET] Done."

	echo -e "[$GREEN+$RESET] Installing SecLists.."
	if [ -e "$HOME"/tools/Seclists/Discovery ]; then
		echo -e "[$GREEN+$RESET] Already installed."
	else
		cd "$HOME"/tools/ || return
		git clone https://github.com/danielmiessler/SecLists.git
		echo -e "[$GREEN+$RESET] Done."
	fi

	echo -e "[$GREEN+$RESET] Installing Asnlookup"
	cd "$HOME"/tools/ || return
	git clone https://github.com/yassineaboukir/Asnlookup
	cd Asnlookup
	pip3 install -r requirements.txt
	echo -e "[$GREEN+$RESET] Done."
	
	echo -e "[$GREEN+$RESET] Installing Sublist3r"
	cd "$HOME"/tools/ || return
	git clone https://github.com/aboul3la/Sublist3r.git
	cd Sublist3r
	pip install -r requirements.txt
	echo -e "[$GREEN+$RESET] Done."
		
	echo -e "[$GREEN+$RESET] Installing ParamSpider"
	cd "$HOME"/tools/ || return
	git clone https://github.com/devanshbatham/ParamSpider
	cd ParamSpider
	pip3 install -r requirements.txt
	echo -e "[$GREEN+$RESET] Done."
	
}
: 'Dashboard setup'
setupDashboard() {
	echo -e "[$GREEN+$RESET] Installing Nginx.."
	sudo apt-get install -y nginx
	sudo nginx -t
	echo -e "[$GREEN+$RESET] Done."
}

: 'Finalize'
finalizeSetup() {
	echo -e "[$GREEN+$RESET] Finishing up.."
	displayLogo
	source "$HOME"/.bashrc || return
	echo -e "[$GREEN+$RESET] Installation script finished! "
}

: 'Execute the main functions'
displayLogo
basicRequirements
golangInstall
golangTools
additionalTools
setupDashboard
finalizeSetup
