# Game Nights

Mobile Development, Lab 1. A small Flutter app for finding and joining
**board game nights**: every night has a title, a category, a date, a limit
of seats and a list of players. You can search and filter the list, mark
favourites, open a night, join or leave it, and create, edit or delete nights.
All data lives in memory.

Requires Flutter 3.35 or newer (Dart 3.5+). No packages beyond the Flutter SDK
and `flutter_lints`.

## Screenshots

| Phone, light | Phone, dark | Tablet grid |
| --- | --- | --- |
| ![phone light](screenshots/phone_light.png) | ![phone dark](screenshots/phone_dark.png) | ![tablet grid](screenshots/tablet_grid.png) |

## Decisions

The list of nights and the profile live in the shell's State, because the
list, the favourites tab and the profile tab all read them and the shell is the
lowest widget above all three. The detail screen takes callbacks through its
route arguments because it is a separate route that cannot reach the shell's
State, so it reports every change upward and keeps its own copy of the item
only to redraw itself. The form returns a value through `pop` instead of
changing the list itself, so backing out changes nothing and the caller decides
what to do with the result after checking `mounted`. The list is a
`LayoutBuilder` because the grid should react to the width this widget is
given, not to the width of the whole screen. `PopScope` compares the values the
form opened with against the current values of all fields, so an edit that is
typed and then undone does not ask "Discard changes?", and Save never asks. With
week 9's tools I would move the list and the profile out of the shell into a
state-management solution, so the tabs would not need constructor parameters
and callbacks for every change.
