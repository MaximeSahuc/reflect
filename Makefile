INSTALL_DIR = /opt/reflect
REPO_DIR = $(pwd)

# Install Reflect
install: banner check_sudo install_scrcpy install_wiringop build_reflectd configure_i3 system_configuration install_scripts ask_for_reboot
	@echo "Installation completed successfully."

banner:
	@echo -n "\n\n\e[38;5;63m    ██████╗ ███████╗███████╗██╗     ███████╗ ██████╗████████╗    \033[0m\n"
	@echo -n "\e[38;5;63m    ██╔══██╗██╔════╝██╔════╝██║     ██╔════╝██╔════╝╚══██╔══╝    \033[0m\n"
	@echo -n "\e[38;5;63m    ██████╔╝█████╗  █████╗  ██║     █████╗  ██║        ██║       \033[0m\n"
	@echo -n "\e[38;5;63m    ██╔══██╗██╔══╝  ██╔══╝  ██║     ██╔══╝  ██║        ██║       \033[0m\n"
	@echo -n "\e[38;5;63m    ██║  ██║███████╗██║     ███████╗███████╗╚██████╗   ██║       \033[0m\n"
	@echo -n "\e[38;5;63m    ╚═╝  ╚═╝╚══════╝╚═╝     ╚══════╝╚══════╝ ╚═════╝   ╚═╝       \033[0m\n\n\n"
	@echo -n "\e[38;5;46m>\033[0m Installing Reflect...\n"

# Check if sudo privileges are required
check_sudo:
	@echo -n "\e[38;5;214m  Sudo access required.\033[0m\n"
	@sudo -v || exit 1

install_scrcpy:
	@echo -n "\e[38;5;46m>>\033[0m Installing Scrcpy...\n"
	@sudo apt update
	@sudo apt -yy install ffmpeg libsdl2-2.0-0 adb wget \
					gcc git pkg-config meson ninja-build libsdl2-dev \
					libavcodec-dev libavdevice-dev libavformat-dev libavutil-dev \
					libswresample-dev libusb-1.0-0 libusb-1.0-0-dev
	@rm -fr $(HOME)/scrcpy
	@git clone https://github.com/Genymobile/scrcpy $(HOME)/scrcpy
	@cd $(HOME)/scrcpy ; ./install_release.sh
	@sudo usermod -aG plugdev $(USER)
	@echo -n "\e[38;5;46m>>\033[0m Done installing Scrcpy\n"

install_wiringop:
	@echo -n "\e[38;5;46m>>\033[0m Installing WiringOP...\n"
	@rm -fr $(HOME)/wiringOP
	@git clone https://github.com/orangepi-xunlong/wiringOP.git -b next --depth=1 $(HOME)/wiringOP
	@cd $(HOME)/wiringOP ; sudo ./build clean
	@cd $(HOME)/wiringOP ; sudo ./build

build_reflectd:
	@echo -n "\e[38;5;46m>>\033[0m Building Reflectd...\n"
	@cd $(REPO_DIR)/reflectd ; ./build
	@echo "Reflectd built successfully, creating Reflectd service..."
	@cp reflectd/reflectd.service /etc/systemd/system/
	@sudo systemctl daemon-reload
	@sudo systemctl enable reflectd.service
	@sudo systemctl start mydaemon.service
	@echo -n "\e[38;5;46m>>\033[0m Done installing Reflectd\n"

configure_i3:
	@echo -n "\e[38;5;46m>>\033[0m Configuring i3...\n"
	@sudo apt install unclutter
	@cp $(REPO_DIR)/configs/i3/config $(HOME)/.config/i3/config
	@echo -n "\e[38;5;46m>>\033[0m Done configuring i3\n"

system_configuration:
	@echo -n "\e[38;5;46m>>\033[0m Setup Auto Login...\n"
	@cp $(REPO_DIR)/configs/lightdm/autologin.conf /etc/lightdm/lightdm.conf.d/10-autologin.conf
	@echo -n "\e[38;5;46m>>\033[0m Done setup auto login\n"

install_scripts:
	@echo -n "\e[38;5;46m>>\033[0m Installing scripts...\n"
	@mkdir -p $(INSTALL_DIR)
	@cp $(REPO_DIR)/scripts/* $(INSTALL_DIR)

ask_for_reboot:
	@echo -n "\e[38;5;128mAll done!\033[0m...\n"
	@read -p "Do you want to reboot the system? (y/n): " answer
	@if [[ "$(answer)" == "y" || "$(answer)" == "Y" ]]; then
		echo "Rebooting now..."
		sudo reboot
	else
		echo "Reboot canceled."
	fi

update:
	@echo -n "\e[38;5;46m>>\033[0m Updating Reflect...\n"
	@git reset --hard
	@git clean -fd
	@git pull
	@echo -n "\n\n\n"
	make install

help:
	@echo "Available targets:"
	@echo "  install    - Install Reflect"
	@echo "  help       - Show this help message"