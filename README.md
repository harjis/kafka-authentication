# Kafka-authentication

This is a prototype on how to use SSL encryption with Kafka

## Steps:

1. Run:
```shell
./start.sh
```

2. Produce messages with:
```shell
./scripts/kcat-produce.sh 
```

3. Consume messages with:
```shell
./scripts/kcat-consume.sh 
```

4. Teardown with:
```shell
./stop.sh
```