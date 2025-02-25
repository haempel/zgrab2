ZGrab 2.0
=========

ZGrab is a fast, modular application-layer network scanner designed for completing large Internet-wide surveys. ZGrab is built to work with ZMap (ZMap identifies L4 responsive hosts, ZGrab performs in-depth, follow-up L7 handshakes). Unlike many other network scanners, ZGrab outputs detailed transcripts of network handshakes (e.g., all messages exchanged in a TLS handshake) for offline analysis.  

ZGrab 2.0 contains a new, modular ZGrab framework, which fully supersedes https://github.com/zmap/zgrab.

## Building

You will need to have a valid `$GOPATH` set up, for more information about `$GOPATH`, see https://golang.org/doc/code.html.

Once you have a working `$GOPATH`, run:

```shell
$ go get github.com/haempel/zgrab2
```

This will install zgrab under `$GOPATH/src/github.com/zmap/zgrab2`

```shell
$ cd $GOPATH/src/github.com/haempel/zgrab2
$ make
```

## Single Module Usage 

ZGrab2 supports modules. For example, to run the ssh module use

```shell
./zgrab2 ssh
```

Module specific options must be included after the module. Application specific options can be specified at any time.

## Input Format

Targets are specified with input files or from `stdin`, in CSV format.  Each input line has three fields:

```
IP, DOMAIN, TAG
```

Each line must specify `IP`, `DOMAIN`, or both.  If only `DOMAIN` is provided, scanners perform a DNS hostname lookup to determine the IP address.  If both `IP` and `DOMAIN` are provided, scanners connect to `IP` but use `DOMAIN` in protocol-specific contexts, such as the HTTP HOST header and TLS SNI extension.

If the `IP` field contains a CIDR block, the framework will expand it to one target for each IP address in the block.

The `TAG` field is optional and used with the `--trigger` scanner argument.

Unused fields can be blank, and trailing unused fields can be omitted entirely.  For backwards compatibility, the parser allows lines with only one field to contain `DOMAIN`.

These are examples of valid input lines:

```
10.0.0.1
domain.com
10.0.0.1, domain.com
10.0.0.1, domain.com, tag
10.0.0.1, , tag
, domain.com, tag
192.168.0.0/24, , tag

```

## Multiple Module Usage

To run a scan with multiple modules, a `.ini` file must be used with the `multiple` module. Below is an example `.ini` file with the corresponding zgrab2 command. 

***multiple.ini***
```ini
[Application Options]
output-file="output.txt"
input-file="input.txt"
[http]
name="http80"
port=80
endpoint="/"
[http]
name="http8080"
port=8080
endpoint="/"
[ssh]
port=22
```
```
./zgrab2 multiple -c multiple.ini
```
`Application Options` must be the initial section name. Other section names should correspond exactly to the relevant zgrab2 module name. The default name for each module is the command name. If the same module is to be used multiple times then `name` must be specified and unique.  
If the `name` field is defined explicitly in the ini file, it will replace module name in the json hirarchy.

Multiple module support is particularly powerful when combined with input tags and the `--trigger` scanner argument. For example, this input contains targets with two different tags:

```
141.212.113.199, , tagA
216.239.38.21, censys.io, tagB
```

Invoking zgrab2 with the following `multiple` configuration will perform an SSH grab on the first target above and an HTTP grab on the second target:

```ini
[ssh]
trigger="tagA"
name="ssh22"
port=22

[http]
trigger="tagB"
name="http80"
port=80
```

**ALERT**  
The input-file and output-file options seem to be broken. A workaround could reached with the command:
```shell
./zgrab2 multiple -c multiple.ini -o output.txt -f input.csv
```
The content of multiple. ini could look like:
```ini
[http]
name="protocol"
port=443
endpoint="/"
use-https="true"
```
Protocol modifies the "outer protocol name" in the json output hierarchy, so do not change it to keep database queries simple.


## Adding New Protocols 

Add module to modules/ that satisfies the following interfaces: `Scanner`, `ScanModule`, `ScanFlags`.

The flags struct must embed zgrab2.BaseFlags. In the modules `init()` function the following must be included. 

```go
func init() {
    var newModule NewModule
    _, err := zgrab2.AddCommand("module", "short description", "long description of module", portNumber, &newModule)
    if err != nil {
        log.Fatal(err)
    }
}
```
### Call hierarchy of the base routine

Zgrab2 is of modular architecture. So every module has to implement required interfaces. These interfaces are called by the base routine of this program.
The rough structure of program run is as follows:
1. detect and register used modules (useful for multiple module usage)
2. start all modules (func Process() in processing.go)
   - create output queue for modules json output
   - get grabbed information of module (func grabTarget in processing.go)
     - calls RunScanner()  
       - calls Scan() of the module ... 
3. get and print summary

### Change existing Module outputs

To change the json output of existing modules, one have to adapt the used code of the corresponding module go-files in the `module` folder.  
Every Module has its own parameters defined - usally as a struct.

If the outer module name of the json output should be changed, see `processing.go` line 169 in `grabTarget(...)`

### Change used go moudles versions 

Go modules have a pseudo version based on a git commit. If a new module version has to be imported in the project, change the modules verision in the `go.mod` file as described below.
1. replace the module version with the commit hash of the update. e.g
   - `github.com/sirupsen/logrus v1.8.1` 
   - `github.com/sirupsen/logrus 6288211277ec7fae37a514d2e58a0daa15c57fe`
2. run `go get <moudle name>`
   - this will replace the commit hash with the correct go pseudo version
  
More information: see: this [blog entry](https://jfrog.com/blog/go-big-with-pseudo-versions-and-gocenter/).

### Output schema

The python schema files are just for conversion to the needed database format. They don't affect the output of zgrab2 and are not up to date any more see [github issue](https://github.com/zmap/zgrab2/issues/312).

To add a schema for the new module, add a module under schemas, and update [`schemas/__init__.py`](schemas/__init__.py) to ensure that it is loaded.

See [schemas/README.md](schemas/README.md) for details.

### Integration tests
To add integration tests for the new module, run `integration_tests/new.sh [your_new_protocol_name]`.
This will add stub shell scripts in `integration_tests/your_new_protocol_name`; update these as needed.
See [integration_tests/mysql/*](integration_tests/mysql) for an example.
The only hard requirement is that the `test.sh` script drops its output in `$ZGRAB_OUTPUT/[your-module]/*.json`, so that it can be validated against the schema.

#### How to Run Integration Tests

To run integration tests, you must have [Docker](https://www.docker.com/) installed. Then, you can follow the following steps to run integration tests:

```
$ go get github.com/jmespath/jp && go build github.com/jmespath/jp
$ pip install --user zschema
$ make integration-test
```

Running the integration tests will generate quite a bit of debug output. To ensure that tests completed successfully, you can check for a successful exit code after the tests complete:

```
$ echo $?
0
```

## License
ZGrab2.0 is licensed under Apache 2.0 and ISC. For more information, see the LICENSE file.
