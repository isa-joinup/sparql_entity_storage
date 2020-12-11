#!/bin/bash

install_codebase () {
    mkdir -p ${SITE_DIR}/web/modules
    cp ${TRAVIS_BUILD_DIR}/tests/travis-ci/fixtures/composer.json.dist ${SITE_DIR}/composer.json
    cd ${SITE_DIR}
    # Replace all variables from the $ENV array.
    perl -i -pe's/\$\{([^}]+)\}/$ENV{$1}/' composer.json
    COMPOSER_MEMORY_LIMIT=-1 composer install --no-interaction --prefer-dist
    # Link the TRAVIS_BUILD_DIR in the contrib modules to test the current branch.
    ln -s ${TRAVIS_BUILD_DIR} ${SITE_DIR}/web/modules/sparql_entity_storage
}

case "${TEST}" in
    PHPCodeSniffer)
        cd ${TRAVIS_BUILD_DIR}
        composer install
        ./vendor/bin/phpcs
        exit $?
        ;;
    PHPUnit)
        # Deploy the codebase.
        install_codebase

        # Setup PHPUnit.
        cp ${TRAVIS_BUILD_DIR}/tests/travis-ci/fixtures/phpunit.xml.dist ${SITE_DIR}/phpunit.xml

        # Virtuoso setup.
        mkdir ${SITE_DIR}/virtuoso
        docker run --name virtuoso -p 8890:8890 -p 1111:1111 -e SPARQL_UPDATE=true -v ${SITE_DIR}/virtuoso:/data -d tenforce/virtuoso

        # Create the MySQL database.
        mysql -e 'CREATE DATABASE sparql_entity_storage_test'
        mysql -e 'CREATE DATABASE sparql_entity_storage_test_phpunit'

        # Install Drupal.
        ./vendor/bin/drush site:install testing --yes --root=${SITE_DIR}/web --db-url=mysql://root:@127.0.0.1/sparql_entity_storage_test

        # Add the SPARQL connection to settings.php.
        chmod 0775 ${SITE_DIR}/web/sites/default/settings.php
        cat ${TRAVIS_BUILD_DIR}/tests/travis-ci/fixtures/connection.txt >> ${SITE_DIR}/web/sites/default/settings.php

        # Enable the 'sparql_entity_storage' module.
        ./vendor/bin/drush pm:enable sparql_entity_storage --yes --root=${SITE_DIR}/web

        # Start the webserver for browser tests.
        cd ${SITE_DIR}/web
        nohup php -S localhost:8888 > /dev/null 2>&1 &

        # Wait until the web server is responding.
        until curl -s localhost:8888; do true; done > /dev/null

        # Run PHPUnit.
        cd ..
        ./vendor/bin/phpunit --verbose
        exit $?
        ;;
    *)
        echo "Unknown test '$1'"
        exit 1
esac
