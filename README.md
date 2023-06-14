# Voting-Machine

Projet universitaire de machine à voter pour élections officielles.

## Procédure

1. A trouver
   - Un votant se présente au bureau
   - Pour rentrer sa carte d'identité et sa carte éléctorale au 2 personels présent à l'entrée
   - Les personels vérifie sur la liste éléctorale si le votant est bien présent
   - Les personels désigne une machine sur laquel le votant va voter
   - Le votant se rend dans l'isoloire ou se trouve la machine
   - Il scane le QR code prèsent sur ça carte éléctoral afin de s'identifier
   - Il vote pour un candidat ou blanc
   - Il sort de l'isoloire et signe sur la liste éléctoral
   - Lors de la fermeture du bureau les résultats sont envoyer a la préfecture
   - Les résultats sont publier
   - Les votants peuvent ensuite verifier que lors vote a bien était pris en compte en utilisant les signature de cercle.
2. Aspect cryptographique
   - Chaque élécteur possède une paire de clé RSA 4096 générer a l'avance par l'état
   - L'état ne conserve que la clé publique
   - La clé privé est transmise au votant en utilisant une carte a puce NFC
   - Au moment du vote sur la machine le votant présente la carte a puce
   - La machine vérifie que la clé privée issue de la carte a puce corespond bien a la clé public du votant
   - Une fois que le votant a fait son choix son vote est signé en utilisant la signature de cercle
   - La signature est effectuée en utilisant la clè publique de tous les votants du bureau ainsi que la clé privé du votant
   - Le vote est ensuite chiffrée sous le format suivant : EncKP(EncKBV(vote+aléa)) avec KP = la clé public de la préfecture et KBV = la clé publique du bureau de vote
   - Pour envoyer les résultat au serveur du bureau de vote on utilisent TLS.
   - Le message envoyer est le suivant : id_vote+signature+EncKP(EncKBV(vote+aléa))
   - L'id du vote est utilisé pour afficher sur un écran relier au serveur du bureau de vote les votes pris en compte
   - Lors du dépouillement la préfecture envoie ça clé privée en utilisant TLS
   - Les votes sont ensuite déchifrée puis analyser
   - Les résultat sont ensuite envoyer a la préfecture en utilisant TLS
   - Si un votant souhaite verifier que sont vote a bien été pris en compte il peut reconstruire la signature de cercle de sont bureau. Il compare ensuite cette signature a la liste publier par la préfecture.
