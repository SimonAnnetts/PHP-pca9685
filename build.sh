#!/bin/bash

php_version=7.3
swig_php_version=7
lib_install_dir=/usr/local/lib

# output file for SWIG to consume
outfile="pca9685.i"

# get and build the PCA9685 lib
rm -Rf libPCA9685/ 2>/dev/null
git clone https://github.com/edlins/libPCA9685.git
[ $? -ne 0 ] && echo "An error occurred trying to download the PCA9685 library!" && exit 1
cd libPCA9685 && mkdir build && cd build
cmake ..
[ $? -ne 0 ] && echo "An error occurred preparing the build of the PCA9685 library!" && exit 1
make PCA9685
[ $? -ne 0 ] && echo "An error occurred building the PCA9685 library!" && exit 1
sudo make install PCA9685
[ $? -ne 0 ] && echo "An error occurred installing the PCA9685 library!" && exit 1
sudo ldconfig ${lib_install_dir}
cd ../..

echo "Writing an interface file for SWIG...."
echo "%module pca9685" >${outfile}
echo "%include \"carrays.i\"" >>${outfile}
echo "%array_functions(unsigned int, uintArray);" >>${outfile}
echo "" >>${outfile}
echo "%{" >>${outfile}
echo "#include \"./libPCA9685/src/PCA9685.h\"" >>${outfile}
echo "%}" >>${outfile}
echo >>${outfile}

echo "%include \"./libPCA9685/src/PCA9685.h\"" >>${outfile}

echo "Using SWIG to create PHP module source...."
swig -v -php${swig_php_version} ${outfile}
[ $? -ne 0 ] && echo "An error occurred creating the PHP pca9685 module source!" && exit 1

php_includes=$(php-config --includes)
php_extensions=$(php-config --extension-dir)

echo "Compiling PHP module source...."
gcc ${php_includes} -fpic -c pca9685_wrap.c
[ $? -ne 0 ] && echo "An error occurred building the PHP pca9685 module source!" && exit 1
gcc -shared pca9685_wrap.o -lPCA9685 -o pca9685.so
[ $? -ne 0 ] && echo "An error occurred building the PHP pca9685 module source!" && exit 1

echo "Copying pca9685.so to PHP extensions dir..."
echo "extension=${php_extensions}/pca9685.so" >pca9685.ini

sudo cp -f pca9685.so ${php_extensions}/
sudo chown root:root ${php_extensions}/pca9685.so
sudo chmod 644 ${php_extensions}/pca9685.so

sudo cp -f pca9685.ini /etc/php/${php_version}/mods-available/pca9685.ini
sudo chown root:root /etc/php/${php_version}/mods-available/pca9685.ini

for i in cli apache2; do
	if [ -d /etc/php/${php_version}/${i} ]; then
		sudo ln -s /etc/php/${php_version}/mods-available/pca9685.ini /etc/php/${php_version}/${i}/conf.d/20-pca9685.ini 2>/dev/null
	fi
done

echo "There is a pca9685.php include file that loads the module and provides a pca9685 class."
echo "DONE!"