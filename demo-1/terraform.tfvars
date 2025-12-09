# Copyright IBM Corp. 2023
# SPDX-License-Identifier: MPL-2.0

commands = [
    "sudo apt update -y",
    "sudo apt install -y nginx",
    "sudo sh -c 'echo \"Hello from the other side</strong>\" > /var/www/html/index.html'",
    "sudo systemctl reload nginx",
]
