# openttd-mapBuilder
MapBuilder is a gamescript for OpenTTD.

Instrukser
======

Install
1. Læg denne tar fil i din game mappe under din openttd mappe i din settings. ([user setteings/bla/bla]/openttd/game)
2. Genstart spillet hvis det var åbent da du lagde mappen over.


Brug
1. Lav dit map i scenario editor, bestående af landskab og 1 by (Noter byens navn så du kan fjerne den senere)
2. Under options (tandhjulet) vælges 'AI/Game Script settings. Her vælges Builder v0001.
3. Gem dit scenario.
4. Spil dit scenario. ( du skal intet gøre her, bare vent på at game scriptet sætter skilte for dig.
   Det anbefales at følge processen i AI/Game Script debug, som findes under hjælp).
5. Når scriptet er færdigt, gem spillet.
6. Rename din save game fil fra *.sav til *.scn.
7. Load din fil i scenario editor og sæt undistrier under skiltene.
8. Fjern din by fra punkt 1.
9. Fjern GameScript samme sted det blev tilføjet til mappet.
10. Gem scenario. Færdig.


Known Bugs
======
Script can run a never ending loop if number of towns and max industries per town are too low
	(temporary solution: max industries per town * number of towns > 60)
On rare occations, a town can be missing its player number.




CHANGE LOG
======
v00002
------
Feature: Towns distributed to all players with player number assigned.
Feature: Added random distribution of industries for each town.
Feature: Options to settings
		 + Number of players
		 + Number of towns per player
		 + Maximum number of industries per town

v00001
------
Feature: Random sign plants for every industry, except those in towns.
