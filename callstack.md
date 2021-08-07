# Callstack for tls information
zgrab2Main(bin.go)
    Process(processing.go)
        - outputresults(json encoded output)
        - start threads
        grabTarget (processing.go)
            runscanner (scanner.go)
                scan (every module)
                    clienthandshake( tls-handshake )
                        doFullHandshake



# Importieren von Go-Modulen / Verändern von importierten Go-Modulen
beim Aktualisieren eines go-moduls beachten:
man kann den git-commit hash des entsprechenden Moduls in der go.mod Datei des importierenden Moduls eintragen.
Mittels anschließendem `go mod download <path to mod>` wird der commit hash im go.mod automatisch durch eine sogenannte pseudo Version ersetzt.


result (http-lib scanner.go)
    response (http-lib response.go)
        request (http-lib request.go)
            tls_log