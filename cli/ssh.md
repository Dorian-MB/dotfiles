# SSH

Se connecter aux serveurs avec `ssh <alias>`, sans taper l'IP, l'utilisateur ni le mot de passe.
Marche pareil sur macOS et Linux/WSL ; les différences sont signalées.

## 1. Déclarer les serveurs dans `~/.ssh/config`

Un bloc par serveur ; le bloc va d'un `Host` au suivant.

```
Host <serveur1>          # l'alias tapé après `ssh`
    HostName <ip1>       # l'adresse réelle
    User <user>          # remplace `ssh <user>@<ip1>`

Host <serveur2>
    HostName <ip2>
    User <user>
```

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh   # sur un Mac neuf, ~/.ssh peut ne pas exister
chmod 600 ~/.ssh/config               # ssh peut refuser un config modifiable par d'autres
ssh -G <serveur1> | grep -E '^(hostname|user) '   # config appliquée, sans se connecter
```

Piège : un copier-coller (navigateur, Teams) peut insérer des espaces insécables. Symptôme :
`Bad configuration option: \302\240...` et **tout** le fichier est ignoré. Les voir et les corriger
(commandes valables sur macOS et Linux, contrairement à `cat -A` / `sed -i` qui diffèrent) :

```bash
cat -vet ~/.ssh/config                       # les insécables apparaissent en M-BM-
perl -pi -e 's/\xc2\xa0/ /g' ~/.ssh/config
```

Un mot de passe ne peut pas être mis dans ce fichier (et ne doit pas l'être, même en commentaire) : utiliser une clé (§4).

## 2. Diagnostiquer selon l'erreur

| Message | Cause | Quoi faire |
|---|---|---|
| `Could not resolve hostname <alias>` | alias absent du config (faute de frappe, bloc renommé) | `ssh -G <alias>` |
| `Connection timed out` | serveur injoignable sur le réseau | §3 (VPN) |
| `Host key verification failed` | premier contact, en mode non interactif | se connecter à la main une fois (§4) |
| `Permission denied` | mauvais utilisateur / mot de passe / clé | `ssh -v <alias>` |
| `connection is not using a post-quantum key exchange` | OpenSSH du serveur ancien | avertissement seulement, ignorable |

Tester sans rien taper (n'attend pas de mot de passe, coupe au bout de 5 s) :

```bash
ssh -o BatchMode=yes -o ConnectTimeout=5 <serveur1> true
```

## 3. Réseau : le VPN

Les serveurs ne sont joignables que via le bon VPN.

Windows (PowerShell) :

```powershell
Test-NetConnection <ip1> -Port 22                       # TcpTestSucceeded : True attendu
Find-NetRoute -RemoteIPAddress <ip1> | Select InterfaceAlias, NextHop
```

macOS (ou Linux) :

```bash
nc -vz -G 5 <ip1> 22          # "succeeded" attendu (Linux : nc -vz -w 5 ...)
route -n get <ip1> | grep interface   # Linux : ip route get <ip1>
```

- Interface Wi-Fi (`Wi-Fi`, `en0`) → le trafic ne passe pas par le VPN : mauvais VPN ou VPN déconnecté.
- Interface VPN (nom du VPN sous Windows, `utun…` sur Mac) → bon chemin.

WSL seulement : si Windows passe mais pas WSL, ajouter `networkingMode=mirrored` et `dnsTunneling=true` sous
`[wsl2]` dans `C:\Users\<user>\.wslconfig`, puis `wsl --shutdown`. (Pas nécessaire ici : WSL passait dès que le
VPN était bon.)

## 4. Première connexion et clé SSH

```bash
ssh <serveur1>
```

La première fois : `The authenticity of host ... can't be established` → `yes` (empreinte enregistrée dans
`~/.ssh/known_hosts`), puis mot de passe.

Pour ne plus taper le mot de passe :

```bash
ssh-keygen -t ed25519          # Entrée pour le chemin par défaut (~/.ssh/id_ed25519)
ssh-copy-id <serveur1>       # mot de passe une dernière fois
ssh-copy-id <serveur2>
```

- `id_ed25519` : clé privée, reste sur la machine, ne se partage jamais. Une par machine (Mac, WSL) : générer
  une clé sur chacune et refaire `ssh-copy-id`, plutôt que copier la clé privée.
- `id_ed25519.pub` : clé publique, copiée par `ssh-copy-id` dans `~/.ssh/authorized_keys` du serveur.
- Passphrase vide : connexion directe, mais quiconque copie la clé privée se connecte à ma place. Avec passphrase :
  clé chiffrée sur le disque, à taper à chaque connexion (ou une fois par session avec `ssh-agent`).

macOS : avec une passphrase, la ranger dans le trousseau pour ne la taper qu'une fois :

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

et en tête de `~/.ssh/config` :

```
IgnoreUnknown UseKeychain       # même fichier utilisable sous Linux, où l'option n'existe pas
Host *
    UseKeychain yes
    AddKeysToAgent yes
```

Vérifier : `ssh <serveur1>` ne demande plus de mot de passe. Sinon, `ssh -v <serveur1>` pour voir pourquoi
la clé est refusée (serveur qui n'accepte que les mots de passe, droits sur `~/.ssh` côté serveur…).
