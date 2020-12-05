#!/bin/bash

sudo sed 's/\#includedir\ \/etc\/sudoers.d/includedir\ \/etc\/sudoers.d/g' /etc/sudoers | EDITOR='tee' visudo
