#!/bin/bash

#myproject='AdraShuttleService'
#mywww='public_html'

read -p "Name of your project " myproject
read -p "Name of your public folder " mywww
 
# initialize project
composer create-project laravel/laravel $myproject --prefer-dist
cd $myproject
 
# fix paths to public
for f in server.php storage/framework/compiled.php; do
    perl -pi -e "s|/public|/../${mywww}|" $f
done
 
# this regex needs to be executed every time the vendor code is updated
oldstr="\$this->basePath.DIRECTORY_SEPARATOR.'public'"
newstr="dirname(\$this->basePath).DIRECTORY_SEPARATOR.'${mywww}'"
sed -i '' "s|${oldstr}|${newstr}|" vendor/laravel/framework/src/Illuminate/Foundation/Application.php
 
# fix path to bootstrap
perl -pi -e "s|/bootstrap|/${myproject}/bootstrap|" public/index.php
 
# rename the public folder to match hosting providers web root
mv public $mywww
 
# create a directory for everything except the public directory
mkdir $myproject
 
# move stuff to app dir
mv {app,bootstrap,config,database,resources,storage,tests,vendor,artisan,.env*,*.js*,*.lock,*.php,*.xml,*.yml} $myproject
 
# use artisan to remove the compiled app
cd $myproject
php artisan clear-compiled
