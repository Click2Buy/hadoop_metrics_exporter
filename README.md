# hadoop_metrics_exporter
Hadoop metrics exporter for prometheus


<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Name Screen Shot][product-screenshot]](https://click2buy.com/wp-content/uploads/2021/07/Logo-Click2buy.png)

Actually without Ambari we don't have possibility to get hadoop metrics.
This project set sevral metrics for hadoop application like hbase, yarn , hive

We use ruby on rails and prometheus gem.

### Built With



* [![Ruby][ruby]]Ruby-url]
* [![Docker][Docker]][Docker-url]


## Getting Started

We can use docker or not (dockzer is recommanded for better compatibilty)

In any case , you must upload 2 conf files

#### metrics.yml ####

list of all metrics available, see metrics.yml.example

you can add metrics 

choose application

  ```yaml
  hbase:
  SystemCpuLoad:
    desc: 'cpu hive server'
    metricType: 'gauge
  ```

#### exporter.yml ####


Conf for access to api metrics 

  ```yaml
    exporter:
    bind: 0.0.0.0
    port: 7629
    interval: 60
    verbose: true
    components:
    hbase:
        url:        http://hbase/jmx
        basic_auth:
        username:   hbase
        password:   hbase
    yarn:
        url:      http://yarn/ws/v1/cluster/metrics
        basic_auth:
        username:   yarn
        password:   yarn
    namenode:
        url:      http://namenode.com/jmx
        basic_auth:
        username:   namenode
        password:   namenode
  ```

  bind: address where process listen
  port: port listen
  interval: interval in second between each api call
  basic_auth: in case of a minimum of security

### with docker


* create conf and metrics directories
  ```sh
  mkdir conf
  mkdir metrics
  ```

* paste metrics/metrics.conf inside metrics directory

  ```sh
touch metrics/metrics.yml
  ```

* same for exporter.yml conf

  ```sh
touch conf/exporter.yml
  ```

  download docker-compose exemple and run 

    ```sh
docker-compose -f docker-compose.yml up -d
  ```