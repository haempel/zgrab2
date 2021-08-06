module github.com/haempel/zgrab2

go 1.12

require (
	github.com/golang/protobuf v1.5.2 // indirect
	github.com/haempel/zcrypto v0.0.0-20210806082605-e8d34626db73
	github.com/prometheus/client_golang v1.10.0
	github.com/prometheus/common v0.20.0 // indirect
	github.com/sirupsen/logrus v1.8.1
	github.com/zmap/rc2 v0.0.0-20190804163417-abaa70531248 // indirect
	github.com/zmap/zflags v1.4.0-beta.1
	golang.org/x/crypto v0.0.0-20210322153248-0c34fe9e7dc2
	golang.org/x/net v0.0.0-20210405180319-a5a99cb37ef4
	golang.org/x/sys v0.0.0-20210403161142-5e06dd20ab57
	golang.org/x/text v0.3.6
	gopkg.in/check.v1 v1.0.0-20190902080502-41f04d3bba15
	gopkg.in/mgo.v2 v2.0.0-20190816093944-a6b53ec6cb22
	gopkg.in/yaml.v2 v2.4.0
)

replace github.com/zmap/zgrab2 5e9507cacf0a7f5cd57aa17a48b29ce6cde76de9 => github.com/haempel/zgrab2 5fa636c1d2d76dc3afb2911194cdc1b906c4e9f4
