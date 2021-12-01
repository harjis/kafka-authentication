# Kafka-authentication

This is a prototype on how to implement authentication & encryption on Kafka with SSL & SASL

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