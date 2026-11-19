# Utiliser les CLI

Aide-mémoire des outils les moins évidents. Pour le reste : `<outil> --help` ou `man <outil>`.

## fd — trouver des fichiers

Le motif est une regex sur le **nom** (pas le chemin). Ignore par défaut les fichiers cachés et ce qui est dans `.gitignore`.

```bash
fd conf                      # noms contenant "conf", depuis le dossier courant
fd conf ~/dotfiles           # ... dans un autre dossier
fd -e lua                    # par extension
fd -e md -e txt              # plusieurs extensions
fd -t d nvim                 # seulement les dossiers (-t f : fichiers)
fd -H .env                   # inclure les fichiers cachés
fd -I node_modules           # inclure ce que .gitignore exclut
fd -E .git -H                # tout, sauf .git
fd -g '*.test.ts'            # glob au lieu de regex
fd -p 'src/.*util'           # regex sur le chemin complet
fd -d 2 readme               # profondeur max
fd --changed-within 1d       # modifiés depuis 24 h
fd -e log -x rm              # lancer une commande par fichier
fd -e png -X viu             # une seule commande avec tous les fichiers
```

## rg — chercher dans le contenu

Regex par défaut, récursif, respecte `.gitignore`.

```bash
rg TODO                      # partout sous le dossier courant
rg -i todo                   # insensible à la casse (-S : casse "intelligente")
rg -w log                    # mot entier
rg -F 'a.b(c)'               # texte littéral, pas de regex
rg -t py import              # par type de fichier (rg --type-list)
rg -g '*.lua' -g '!lazy-lock*' require   # filtrer par glob, ! = exclure
rg -l TODO                   # seulement les noms de fichiers
rg -c TODO                   # nombre de correspondances par fichier
rg -C 3 error                # 3 lignes de contexte (-A après, -B avant)
rg -uu secret                # inclure fichiers cachés et ignorés
rg -o 'v[0-9]+\.[0-9]+'      # n'afficher que la partie trouvée
rg 'fn (\w+)' -r '$1' -o     # remplacer dans l'affichage (ne modifie rien)
rg -U 'start.*\n.*end'       # regex sur plusieurs lignes
```

Remplacer dans les fichiers : `rg -l ancien | xargs sed -i 's/ancien/nouveau/g'` (macOS : `sed -i ''`).

## fzf — choisir dans une liste

Tout ce qui sort d'une commande peut passer dans fzf ; la ligne choisie est renvoyée.

```bash
fd -t f | fzf                                     # choisir un fichier
vi "$(fzf)"                                       # l'ouvrir
fzf --preview 'bat --color=always {}'             # avec aperçu
git branch | fzf | xargs git switch               # changer de branche
fzf -m                                            # sélection multiple (Tab)
```

Dans fzf : taper pour filtrer, `'mot` = correspondance exacte, `^debut`, `fin$`, `!exclure`, espace = ET, `|` = OU.

Fonctions du `.zshrc` : `fcd` (aller dans un dossier) et `fvi [motif]` (ouvrir un fichier dans nvim avec aperçu).

## bat — cat avec coloration

```bash
bat fichier.py               # coloré, numéros, pagination
bat -p fichier               # sans décoration
bat -r 10:20 fichier         # lignes 10 à 20
bat -l json                  # forcer le langage (utile en pipe : curl ... | bat -l json)
bat -A fichier               # montrer espaces, tabs, fins de ligne (CRLF !)
```

## eza — ls

Déjà en alias : `ls`, `ll` (liste + git), `la` (avec cachés), `lt` (arbre sur 2 niveaux), `lls`/`las`/`lts` (avec taille des dossiers).

```bash
eza -l --sort=modified       # trier par date (size, name, extension…)
eza --tree --level=3 -I node_modules   # arbre en ignorant un motif
```

## jq — JSON

```bash
jq . fichier.json                      # joli affichage
jq '.name' package.json                # un champ
jq -r '.name'                          # sans guillemets (pour les scripts)
jq '.items[0]'                         # premier élément
jq '.items[] | .id'                    # un champ de chaque élément
jq '[.items[] | select(.age > 30)]'    # filtrer
jq '.items | length'                   # compter
jq '.items | map({id, nom: .name})'    # reformer les objets
jq 'keys'                              # clés d'un objet
jq -s '.' a.json b.json                # fusionner en un tableau
jq '.version = "2.0"' f.json > tmp && mv tmp f.json   # modifier
curl -s https://api.github.com/repos/jqlang/jq | jq '.stargazers_count'
```

## qsv — traiter des CSV

Chaque commande lit un CSV et en écrit un sur la sortie : on les enchaîne avec `|`. Finir par `| qsv table` pour lire à l'écran, ou `> sortie.csv`.

```bash
qsv headers f.csv                        # noms des colonnes
qsv count f.csv                          # nombre de lignes
qsv table f.csv                          # aligné à l'écran
qsv slice -l 10 f.csv                    # 10 premières lignes
qsv stats f.csv | qsv table              # type, min, max, moyenne… par colonne
qsv frequency -s ville f.csv             # valeurs les plus fréquentes d'une colonne
qsv select nom,age f.csv                 # garder des colonnes (aussi 1-3, !age)
qsv search -s ville paris f.csv          # lignes où la colonne correspond (regex, -i)
qsv sort -s age -N -R f.csv              # trier : -N numérique, -R décroissant
qsv dedup f.csv                          # supprimer les doublons (trie au passage)
qsv join ville a.csv ville b.csv         # jointure (--left, --full…)
qsv fmt -t ';' f.csv                     # changer de séparateur
qsv input -d ';' f.csv > propre.csv      # lire un CSV à ;
```

Le plus pratique : du SQL directement sur le fichier (la table porte le nom du fichier sans `.csv`) :

```bash
qsv sqlp ventes.csv 'select ville, avg(age) as moy from ventes group by ville order by moy desc'
qsv sqlp a.csv b.csv 'select * from a join b using (id)'
```

Enchaîner : `qsv search -s ville paris f.csv | qsv sort -s age -N | qsv table`.

## csvlens — regarder un CSV

```bash
csvlens f.csv
csvlens -d ';' f.csv         # séparateur ; (-t : tabulation)
qsv stats f.csv | csvlens    # explorer la sortie d'une autre commande
```

Touches : `hjkl` ou flèches pour bouger, `/` chercher, `&` filtrer les lignes, `*` filtrer les colonnes, `H` aide, `q` quitter.
