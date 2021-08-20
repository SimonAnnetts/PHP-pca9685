# PHP-pcaA9685

PHP library for communicationg with the PCA9685 PWM driver.
The PCA9685 library used in this PHP binding is by Scott Edlin,
https://github.com/edlins/libPCA9685

## Requirements

~~~bash
sudo apt install php php-dev swig
~~~

## Building

~~~bash
git clone https://github.com/SimonAnnetts/PHP-pca9685.git
cd PHP-pca9685
./build.sh
~~~

## Installation

The module automatically installs itself in the php extensions directory and enables itself for php-cli and php running under apache2.

~~~bash
php -m |grep pca
~~~

should produce the output:
pca9685


