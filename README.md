Source: https://github.com/quarkusio/quarkus-quickstarts/tree/master/rest-json-quickstart

## CI Tool Configuration

TODO

## Tests

### Unit Tests
Run the unit tests:
```
mvn test
```

### UAT Tests
Run the user acceptance tests:
```
mvn -Pintegration-test test -Dselenium.hub.url=SELENIUM_HUB_URL -Dtarget.base.url=TARGET_BASE_URL
```

SELENIUM_HUB_URL is the URL where the Selenium Hub is available and listening.

TARGET_BASE_URL is the URL of this running application.
