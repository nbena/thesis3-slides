# Guida

## 1 Motivazioni

Con l'aumentare della complessità dei sistemi IT aumenta anche la necessità di effettuare attività di _Security Assurance_ e _Security Assessment_. In particolare tali attività dovrebbero essere svolte in maniera continuativa, ed essere erogate _as-a-service_ in modo da ridurre i costi.

Nell'ambito di queste attività per sistemi cloud, gli approcci che si sono rivelati più efficaci sono quelli basati sulla raccolta di evidenze presso il sistema stesso, per determinare quale sia il reale livello di sicurezza.

Per raccogliere tali evidenze è possibile sfruttare gli hook messi a dispozione dai cloud provider stessi.

Si vuole estendere questo paradigma anche per l'analisi di reti e cloud private, dove tuttavia questi hook non sono disponibili. Oltretutto, sono reti protette da firewall e probabilmente anche da NAT.

## 2 Obiettivi

L'obiettivo è stato quello di consentire l'effettuazione di
ispezioni per _Security Assurance_ ed _Assessment_ anche all'interno di reti e cloud private.

La nuova soluzione deve garantire un alto livello di sicurezza, e deve essere il più possibile lightweight per i clienti, nel senso che si deve integrare nella loro infrastruttura senza richiedere configurazioni particolari, come ad esempio aprire porte del firewall o specificare delle rotte nel default gateway. Per questo deve anche mantenere, nei limiti del possibile, il paradigma _as-a-service_ della security assurance ed assessment fatte in sistemi cloud pubblici.

## 3 Security Assurance e MoonCloud

Nell'ambito della tesi si è collaborato con MoonCloud, spin-off dell'Università di Milano.

MoonCloud è un framework per l'analisi ed il monitoraggio continuo di sistemi cloud, le cui analisi sono volte alla certificazione in caso di rispetto di una data proprietà.

Per effettuare le proprie valutazioni MoonCloud utilizza una raccolta continua di evidenze, in modo da attestare l'effettivo stato della sicurezza di un sistema (_Security Assurance_) e di valutare che certe proprietà siano rispettate.

MoonCloud viene offerto _as-a-service_, al cliente finale non è richiesto di installare niente, semplicemente, dopo essersi registrato, specifica i parametri del target. MoonCloud si occupa di fare l'analisi e di mostrare i risultati.

## 4 Soluzione

Per poter analizzare anche reti private mantenendo un paradigma _as-a-service_ è stato necessario realizzare un *ponte* tra MoonCloud e tali target. In particolare, si utilizza un collegamento *VPN*.

Queste le tecnologie usate:

- *OpenVPN* per la VPN
- un client VPN *Linux*  portato nella rete target e responsabile di instaurare il collegamento
- *nftables*, successore di _iptables_ per risolvere numerosi problemi di configurazione derivanti da un utilizzo _non standard_, per il quale ad esempio non è possibile chiedere al cliente di effettuare alcuna configurazione nella propria rete.

A tale scopo sono proposte varie soluzioni innovative.

## 5 Soluzione (2)

In questa immagine possiamo vedere l'architettura discussa. Lato MoonCloud vi è un VPN server che è in grado di gestire più clienti diversi, in cui si hanno i client VPN.

## NAT al contrario

La prima soluzione innovativa adottata è stata chiamata *NAT al contrario*. I pacchetti provenienti da MoonCloud lungo la VPN ed inseriti nella rete target dal VPN client hanno come indirizzo IP sorgente quello di MoonCloud stessa. Le richieste arrivano all'host, tuttavia esso non sa che deve inoltrare le risposte al VPN client anziché al proprio default gateway, poiché la destinazione è una rete di cui non ha nessuna rotta.

Il default gateway o comunque un router in Internet dropperà tali pacchetti perché destinati ad una rete privata.

Per far sì che le risposte vengano inoltrate al VPN client, si realizza su esso del NAT per modificare l'indirizzo IP sorgente dai pacchetti provenienti dalla VPN, in modo che siano immessi nella rete target con un IP che appartiene alla rete stessa, per questo le risposte torneranno senza problemi al VPN client.

## IP mapping

Un VPN server è in grado di gestire diversi client, e questo è proprio ciò che si vuole, cioè far sì che un singolo server possa gestire il maggior numero possibile di clienti, limitando quindi il numero di VM necessarie in MoonCloud.

Tuttavia, quando si realizza una VPN di questo tipo è fondamentale che _tutte_ le reti che vi partecipano abbiano dei NET ID diversi.

E' chiaro che prima o poi vi sarà un conflitto; una prima soluzione è quella di destinare un VPN srver per ogni cliente, tuttavia si è cercata un'alternativa migliore.

La soluzione proposta si chiama *IP mapping* e consiste nel _mappare_ le reti dei clienti su nuove reti garantite univoche, in modo che non vi siano conflitti.

Vediamolo nel dettaglio.

## IP mapping (2)

1. Nel momento in cui avviene l'enrollment di un nuovo cliente, le sue reti vengono appunto modificate in reti diverse da MoonCloud.
2. Quando si vuole fare un'ispezione, il cliente specifica l'indirizzo IP originale, e MoonCloud in modo trasparente ottiene la sua versione mappata: quello sarà l'indirizzo IP destinazione dei pacchetti da MoonCloud.
3. Il VPN client riceve tali pacchetti e ne modifica l'IP dst, da quello mappato a quello originale.
4. Si applica il NAT al contrario ed i pacchetti raggiungono quindi l'host target.

A questo punto l'host target produce una risposta che viene inviata al VPN client.

1. Il VPN client applica l'inverso del NAT al contrario
2. Modifica l'indirizzo IP src da quello originale a quello mappato, in modo che corrisponda a ciò che MoonCloud si aspetta.
3. Il pacchetti viene quindi inviato sulla VPN.

Per effettuare tutto ciò si utilizza ancora *nftables*.

## MoonCloud_VPN

Come contorno all'architettura proposta si è realizzato un microservizio dedicato alla sua gestione. Esso è scritto in Python ed espone delle API rest per assolvere ai seguenti compiti:

- creazione dei file di configurazione per OpenVPN client e server, e trasferimento via SSH ai server
- gestione del ciclo di vita dei certificati utilizzati per l'autenticazione nella VPN
- gestione dell'IP mapping, per cui una volta che un cliente si enrolla si mappano le sue reti in reti univoche, e, dato un indirizzo IP originale ritornare l'IP mappato.

## Sicurezza

Il VPN client viene portato in una rete untrusted, e quindi è fondamentale proteggere la rete MoonCloud da qualsiasi attacco portato avanti tramite tale collegamento.

Per farlo si sono predisposte delle regole di firewalling sui VPN server per cui l'unico traffico consentito sulla VPN sono le richieste da MoonCloud e le relative risposte, tutto il resto non viene consentito.

## Conclusioni

In conclusione, l'architettura proposta consente di applicare gli approcci di _Security Assurance_ ed _Assessment_ che si sono dimostrati tanto efficaci per sistemi cloud anche per reti e cloud private.

Posto di portare nella rete target il VPN client, si mantiene ancora un paradigma as-a-service che garantisce elevata sicurezza.