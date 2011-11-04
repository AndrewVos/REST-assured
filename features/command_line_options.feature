Feature: command line options
  In order to run rest-assured in different configurations (db params, port, etc)
  As test developer
  I need a way to specify those configurations.

  Scenario Outline: specifing server port
    When I start rest-assured with <option>
    Then it should run on port <port>

    Examples:
      | option      | port |
      | -p 1234     | 1234 |
      | --port 1235 | 1235 |
      |             | 4578 |

  Scenario Outline: specifing log file
    When I start rest-assured with <option>
    Then the log file should be <logfile>

    Examples:
      | option                   | logfile               |
      | -l /tmp/rest-assured.log | /tmp/rest-assured.log |
      | --logfile ./test.log     | ./test.log            |
      |                          | ./rest-assured.log    |