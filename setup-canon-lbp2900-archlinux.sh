#!/bin/bash

set -e

echo "Starting Canon LBP2900 printer setup on Arch Linux..."

# 1. Update the system
echo "Updating system..."
sudo pacman -Syu --noconfirm

# 2. Install required dependencies
echo "Installing required dependencies..."
sudo pacman -S --noconfirm cups ghostscript gsfonts gutenprint cups-pdf libcups system-config-printer

# 3. Enable and start CUPS service
echo "Enabling and starting CUPS service..."
sudo systemctl enable --now cups

# 4. Install the Canon CAPT driver (AUR package)
echo "Installing Canon CAPT driver from AUR..."
if ! command -v yay &> /dev/null; then
    echo "Yay AUR helper not found. Installing yay..."
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
fi

yay -S --noconfirm cndrvcups-capt

# 5. Configure the printer
echo "Configuring the Canon LBP2900 printer..."
sudo /etc/init.d/cups restart

# Add the printer
sudo lpadmin -p Canon-LBP2900 -m CNCUPSLBP2900CAPTK.ppd -v ccp://localhost:59787 -E

# Register the printer with the CAPT driver
sudo ccpdadmin -p Canon-LBP2900 -o /dev/usb/lp0

# 6. Enable and start the ccpd service
echo "Enabling and starting the ccpd service..."
sudo systemctl enable --now ccpd

# 7. Test the printer
echo "Testing the printer..."
sudo captstatusui -P Canon-LBP2900

echo "Canon LBP2900 setup completed successfully!"
