# Discorso da fare

## 1 Motivazioni

TODO

## 2 Obiettivi

L'obiettivo è stato quello di consentire l'effettuazione di
ispezioni per _Security Assurance_ anche all'interno di reti e cloud private.

## 3 Security Assurance e MoonCloud

Nell'ambito della tesi si è collaborato con MoonCloud, spin-off dell'Università di Milano.

MoonCloud è un framework per l'analisi ed il monitoraggio continuo di sistemi cloud, le cui analisi sono volte alla certificazione in caso di rispetto di una data proprietà.

Per effettuare le proprie valutazioni MoonCloud utilizza una raccolta continua di evidenze, in modo da attestare l'effettivo stato della sicurezza di un sistema (_Security Assurance_).

MoonCloud viene offerto _as-a-service_, al cliente finale non è richiesto di installare niente, semplicemente, dopo essersi registrato, specifica i parametri del target. MoonCloud si occupa di fare l'analisi e di mostrare i risultati.

## 4 Soluzione

Per poter analizzare anche reti private mantenendo un paradigma _as-a-service_ è stato necessario realizzare un *ponte* tra MoonCloud e tali target. In particolare, si utilizza un collegamento *VPN*.

Queste le tecnologie usate:

- *OpenVPN* per la VPN
- un client VPN *Linux*  portato nella rete target e responsabile di instaurare il collegamento
- *nftables*, successore di _iptables_ per risolvere numerosi problemi di configurazione derivanti da un utilizzo _non standard_.

Molto importante è stato essere _configuration-free_, e ciò ha imposto di adottare soluzioni particolarmente innovative.

## 5 Soluzione (2)

In questa immagine possiamo vedere l'architettura...

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

## Sicurezza

Il VPN client viene portato in una rete untrusted, e quindi è fondamentale proteggere la rete MoonCloud da qualsiasi attacco portato avanti tramite tale collegamento.

Per farlo si sono predisposte delle regole di firewalling sui VPN server per cui l'unico traffico consentito sulla VPN sono le richieste da MoonCloud e le relative risposte, tutto il resto non viene consentito.

## Conclusioni

TOODO.