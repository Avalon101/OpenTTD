# openttd-mapBuilder
MapBuilder is a gamescript for OpenTTD.

Instrukser
======

Install

1. Læg denne tar fil i din game mappe under din openttd mappe i din settings. ([user setteings/bla/bla]/openttd/game)
2. Genstart spillet hvis det var åbent da du lagde mappen over.


Brug

1. Lav dit map i scenario editor, bestående af landskab og 1 by.
2. Under options (tandhjulet) vælges 'AI/Game Script settings. Her vælges MapBuilder.
3. Gem dit scenario.
4. Spil dit scenario. Det kan være en fordel at pause spillet mens scriptet kører. Foretag dig intet mens scriptet kører (følg med i AI/Game Script Debug Log).
5. Nyd dit spil :)


Known Bugs
======
- Script can run a never ending loop if number of towns and max industries per town are too low (temporary solution: max industries per town * number of towns > 60)
- On rare occations, a town can be missing its player number.




CHANGE LOG
======
v3.0.0
------
- All industries are placed, both country side and in towns.
- There is no longer a need for user to go back to scenario editor. Play on, when the map builder has finished. (follow along in the AI/Game Script Debug Log.)

v00002
------
- Feature: Towns distributed to all players with player number assigned.
- Feature: Added random distribution of industries for each town.
- Feature: Options to settings:
	- Number of players
	- Number of towns per player
	- Maximum number of industries per town

v00001
------
- Feature: Random sign plants for every industry, except those in towns.
