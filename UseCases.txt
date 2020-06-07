Use Cases
=========

The basic idea is to allow one to import multiple Features/Packages without conflict.

As a user, I don't really need to know most details (but they should be discoverable).

E.g. Playing Klondike or FreeCell from Morphic-Games-Solitaire requires only that Classes FreeCell and Klondike be in the system dictionary.  All interior classes (CardMorph, Table) can be local to the PackageEnv.

One can then import multiple card games without conflict, where each defines its own Card/CardMorph Classes.

On the other hand, I may be writing a card game and wish to use Morphic-Games-Solitaire's Deck and CardMorphs, so I wish to be able to create my own Package which requires/uses these Classes from  Morphic-Games-Solitaire.

To simplify cases, it would be great if Feature=Package=PackageEnv.

Note that (#require = #use) is a composable, directed acyclic relation.

How is this presented/expressed in the toolset/UI precisely but without clutter?



