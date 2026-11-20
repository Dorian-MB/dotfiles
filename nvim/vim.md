# Vim : commandes de base

Grammaire : `[count] commande [count] motion`, ex : `3dw`, `d2w`, `ci(`.
Les ajouts par rapport a `vim.txt` sont marques **+**.

## Modes
| Touche | Action |
|--------|--------|
| `i` / `a` | insert avant / apres le curseur |
| `I` / `A` | insert en debut / fin de ligne |
| `o` / `O` | nouvelle ligne en dessous / au dessus, en insert |
| `v` / `V` / `<C-v>` | visual caractere / ligne / bloc |
| `R` | mode remplacement (jusqu'a `<Esc>`) |
| `<Esc>` / `<C-[>` **+** | retour en normal |
| `<C-o>` **+** | (en insert) executer une seule commande normale |

## Deplacement

### Horizontal
| Touche | Action |
|--------|--------|
| `h` `j` `k` `l` | gauche, bas, haut, droite |
| `w` / `b` | debut du mot suivant / precedent |
| `W` / `B` | idem pour un MOT (tout ce qui est colle : `my_array.argmax(axis=1)`) |
| `e` / `E` | fin du mot / MOT |
| `ge` **+** | fin du mot precedent |
| `0` / `^` / `$` **+** | debut de ligne / premier caractere non blanc / fin de ligne |
| `f<x>` / `F<x>` | sauter sur `x` en avant / en arriere |
| `t<x>` / `T<x>` | sauter juste avant `x` en avant / en arriere |
| `;` / `,` | repeter le dernier `f t F T` / en sens inverse |

### Vertical
| Touche | Action |
|--------|--------|
| `gg` / `G` | debut / fin du fichier |
| `:20` ou `20G` **+** | aller a la ligne 20 |
| `{` / `}` | paragraphe precedent / suivant |
| `(` / `)` | phrase precedente / suivante |
| `<C-u>` / `<C-d>` | demi-page haut / bas |
| `<C-b>` / `<C-f>` **+** | page entiere haut / bas |
| `<C-y>` / `<C-e>` **+** | defiler d'une ligne sans bouger le curseur |
| `H` / `M` / `L` **+** | haut / milieu / bas de l'ecran |
| `%` | parenthese / accolade / crochet correspondant |

### Vue
| Touche | Action |
|--------|--------|
| `zz` | centrer la ligne a l'ecran |
| `zt` ou `z<CR>` | ligne en haut de l'ecran |
| `zb` **+** | ligne en bas de l'ecran |

## Recherche
| Touche | Action |
|--------|--------|
| `/<x>` / `?<x>` | chercher vers le bas / vers le haut |
| `n` / `N` | occurrence suivante / precedente |
| `*` / `#` | mot sous le curseur, suivant / precedent |
| `gn` / `gN` | selectionner l'occurrence suivante / precedente (`cgn` puis `.` pour remplacer une a une) |
| `/\<mot\>` **+** | mot entier uniquement |
| `/<x>\c` **+** | recherche insensible a la casse |

## Edition

### Inserer / modifier
| Touche | Action |
|--------|--------|
| `x` / `X` **+** | supprimer le caractere sous / avant le curseur |
| `r<x>` | remplacer un caractere par `x` |
| `s` / `S` | supprimer le caractere / la ligne et passer en insert |
| `c<motion>` | changer (supprimer + insert) : `ciw`, `ce`, `ct)` |
| `cc` **+** | changer la ligne entiere |
| `C` | changer jusqu'a la fin de la ligne |
| `J` | joindre la ligne du dessous (avec un espace) |
| `gJ` **+** | joindre sans espace |
| `~` **+** | inverser la casse du caractere |
| `gu<motion>` / `gU<motion>` | minuscule / majuscule (`guiw`, `gUU` ligne) |
| `>>` / `<<` | indenter / desindenter la ligne (`>` / `<` en visual) |
| `==` | re-indenter la ligne (`=` sur une selection, `gg=G` tout le fichier) |
| `<C-a>` / `<C-x>` | incrementer / decrementer un nombre |
| `.` | repeter la derniere modification (ex : `ciw test<Esc>` puis `.` sur un autre mot) |

### Copier / couper / coller
| Touche | Action |
|--------|--------|
| `y<motion>` | copier (`yw`, `y$`) |
| `yy` / `Y` **+** | copier la ligne / jusqu'a la fin de ligne (nvim) |
| `yiw` / `yiW` | copier le mot / le MOT |
| `yi(` `yi{` `yi[` `yi"` | copier le contenu entre `()` `{}` `[]` `""` |
| `d<motion>` | couper (`dw`, `d}`) : supprimer = couper |
| `dd` / `D` | couper la ligne / jusqu'a la fin de ligne |
| `diw` / `daw` **+** | couper le mot / le mot et l'espace autour |
| `df<x>` / `dt<x>` **+** | couper jusqu'a `x` inclus / exclu |
| `da(` | couper les parentheses et leur contenu |
| `p` / `P` | coller apres / avant (ligne dessous / dessus pour une ligne) |
| `xp` **+** | echanger deux caracteres |
| `ddp` **+** | echanger deux lignes |

Coller sur une selection remplace le registre par le texte supprime : le
prochain `p` collera ce texte (pareil apres un `dd`).

### Registres **+**
| Touche | Action |
|--------|--------|
| `"<r>y` / `"<r>p` | copier dans / coller depuis le registre `r` (ex : `"ayiw`, `"ap`) |
| `"0p` | coller la derniere copie (`y`), meme apres un `d` |
| `"+y` / `"+p` | presse-papier systeme |
| `"_d` | supprimer sans toucher aux registres |
| `<C-r><r>` | (en insert / ligne de commande) coller le registre `r` |
| `:reg` | lister les registres |

### Annuler
| Touche | Action |
|--------|--------|
| `u` | annuler |
| `<C-r>` | refaire |
| `U` **+** | annuler tous les changements de la ligne |

## Text objects **+**
Avec un operateur (`d` `c` `y` `v`...) : `i` = interieur, `a` = avec les bords.

| Objet | Cible |
|-------|-------|
| `iw` / `aw` | mot |
| `iW` / `aW` | MOT |
| `is` / `as` | phrase |
| `ip` / `ap` | paragraphe |
| `i(` `ib` / `a(` | parentheses |
| `i{` `iB` / `a{` | accolades |
| `i[` / `a[` | crochets |
| `i"` `i'` `` i` `` | entre guillemets |
| `it` / `at` | balise HTML / XML |

## Mode visual
| Touche | Action |
|--------|--------|
| `V` | selectionner la ligne |
| `viw` / `vip` / `vi(` / `vi"` | selectionner mot / paragraphe / `()` / `""` |
| `o` | aller a l'autre bout de la selection |
| `gv` | reselectionner la derniere selection |
| `<C-v>` puis `I` / `A` | inserer au debut / a la fin de chaque ligne du bloc (`<Esc>` pour appliquer) |
| `<C-v>` puis `$A` **+** | ajouter a la fin de lignes de longueurs differentes |
| `y` `d` `c` `>` `<` `=` `u` `U` | operateurs appliques a la selection |
| `:` **+** | commande sur la selection (`:'<,'>s/a/b/g`, `:'<,'>norm A;`) |

## Marques et sauts
| Touche | Action |
|--------|--------|
| `m<x>` | poser la marque `x` (minuscule = fichier, majuscule = globale) |
| `` `<x> `` / `'<x>` **+** | aller a la marque `x` / a sa ligne |
| ``` `` ``` | revenir a la position avant le dernier saut (ex : apres un `gg` par erreur) |
| `` `. `` | derniere modification |
| `gi` | reprendre l'insert a la derniere position d'insert |
| `<C-o>` / `<C-i>` **+** | position precedente / suivante dans la jump list |
| `g;` / `g,` **+** | modification precedente / suivante (change list) |
| `:marks` **+** | lister les marques |

## Code (LSP)
| Touche | Action |
|--------|--------|
| `gd` | aller a la definition |
| `K` | documentation de l'element sous le curseur |
| `gf` **+** | ouvrir le fichier dont le chemin est sous le curseur |

## Replis (folds)
| Touche | Action |
|--------|--------|
| `zf<motion>` / `zf` (visual) | creer un repli (`zf3j`, `zfip`) |
| `zo` / `zc` / `za` | ouvrir / fermer / basculer le repli (`zO` `zC` `zA` recursif) |
| `zR` / `zM` | ouvrir / fermer tous les replis |
| `zr` / `zm` | diminuer / augmenter le niveau de repli global |
| `zj` / `zk` | repli suivant / precedent |
| `zd` / `zD` / `zE` | supprimer le repli / les replis sous le curseur / tous |

## Macros
| Touche | Action |
|--------|--------|
| `q<x>` | enregistrer dans le registre `x` |
| `q` | arreter l'enregistrement |
| `@<x>` | jouer la macro `x` (`3@x` trois fois) |
| `@@` **+** | rejouer la derniere macro |
| `:'<,'>norm @x` **+** | jouer la macro sur chaque ligne selectionnee |

Exemple, echanger `foo` <-> `bar` : `qa` `_R` `bar` `<Esc>` `j` `q` puis `3@a`.

## Ligne de commande

### Fichiers et fenetres
| Commande | Action |
|----------|--------|
| `:w` / `:wq` / `:x` **+** / `:q!` | ecrire / ecrire et quitter / idem si modifie / quitter sans sauver |
| `:wa` / `:qa` **+** | ecrire / quitter tout |
| `:e <path>` **+** | ouvrir un fichier (`:e #` le fichier precedent, `:e!` recharger) |
| `:sp <path>` / `:vsp <path>` | split horizontal / vertical |
| `<C-w>w` / `<C-w>hjkl` | changer de fenetre |
| `<C-w>q` / `<C-w>o` **+** | fermer la fenetre / garder seulement celle-ci |
| `<C-w>=` **+** | egaliser la taille des fenetres |
| `:tabnew` | nouvel onglet |
| `gt` / `gT` | onglet suivant / precedent |
| `:ls` / `:b <n>` **+** | lister les buffers / aller au buffer `n` |
| `:bn` / `:bp` / `:bd` **+** | buffer suivant / precedent / fermer |
| `:ter` | ouvrir un terminal |

### Options
| Commande | Action |
|----------|--------|
| `:set nu` / `:set nonu` | numeros de ligne |
| `:set rnu` | numeros relatifs (`:set rnu nu` les deux) |
| `:set wrap!` **+** | basculer le retour a la ligne (`!` = toggle) |
| `:set ic` / `:set noic` **+** | recherche insensible / sensible a la casse |
| `:noh` **+** | effacer le surlignage de recherche |

### Rechercher / remplacer
| Commande | Portee |
|----------|--------|
| `:s/old/new/flags` | ligne courante |
| `:%s/old/new/flags` | tout le fichier |
| `:.,$s/old/new/flags` | de la ligne courante (`.`) a la fin (`$`) |
| `:'<,'>s/old/new/flags` **+** | la selection visual |
| `:10,20s/old/new/g` **+** | lignes 10 a 20 |

Flags : `g` toutes les occurrences de la ligne, `c` confirmer, `i` insensible a
la casse, `I` sensible a la casse.
**+** Dans `new`, `&` = le texte trouve, `\1` = premier groupe `\(...\)`.

### Autres **+**
| Commande | Action |
|----------|--------|
| `:g/<x>/d` | supprimer toutes les lignes qui contiennent `x` (`:v/<x>/d` celles qui ne le contiennent pas) |
| `:g/<x>/norm A;` | executer des touches normales sur chaque ligne qui matche |
| `:sort` / `:sort u` | trier les lignes / sans doublons |
| `:!<cmd>` | lancer une commande shell |
| `:r <path>` / `:r !<cmd>` | inserer un fichier / la sortie d'une commande |
| `:%!<cmd>` | filtrer le fichier par une commande (ex : `:%!jq .`) |
| `:h <sujet>` | aide (ex : `:h text-objects`) |
| `@:` | rejouer la derniere commande `:` |
| `q:` | historique des commandes editable |

## Surround (plugin nvim-surround)
| Touche | Action |
|--------|--------|
| `ys<motion><c>` | entourer : `ysiw)` mot, `ys$"` jusqu'a la fin |
| `yss<c>` | entourer la ligne |
| `cs<old><new>` | changer : `cs('` `(x)` -> `'x'` |
| `ds<c>` | supprimer : `ds"` |
| `S<c>` (visual) | entourer la selection |

`(` `{` `[` ajoutent un espace a l'interieur, `)` `}` `]` non. `t` = balise HTML.
