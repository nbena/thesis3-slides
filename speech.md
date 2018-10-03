# Discorso da fare

## 1 Motivazioni




## 2 Obiettivi

L'obiettivo è stato quello di consentire l'effettuazione di
ispezioni per _Security Assurance_ anche all'interno di reti e cloud private.


## 3 Security Assurance e MoonCloud

Nell'ambito della tesi si è collaborato con MoonCloud, spin-off dell'Università di Milano.


MoonCloud è un framework per l'analisi ed il monitoraggio continuo di
sistemi cloud, le cui analisi sono volte alla certificazione in caso di rispetto
di una data proprietà.

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

## MoonCloud_VPN


## NAT al contrario

La prima soluzione innovativa adottata è stata chiamata *NAT al contrario*. I pacchetti provenienti da MoonCloud lungo la VPN ed inseriti nella rete target dal VPN client hanno come indirizzo IP sorgente quello di MoonCloud stessa. Le richieste arrivano all'host, tuttavia egli non sa che.

## IP mapping


## IP mapping 2


## Sicurezza

