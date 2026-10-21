# Book Club

A reading-club app for Mobile Development, Lab 1. Each item is a book the club
meets about: a title, a genre (six values, each with a label, icon and colour),
a meeting date, a place (or a link when the meeting is online), a number of
copies, and the list of readers who borrowed one. You can browse and search
the books, favourite them, borrow or return a copy, add, edit and delete books,
and set your name, group and theme in the profile. All data lives in memory.

## Run

This repository contains `lib/`, `assets/` and `pubspec.yaml`. If the
`android/`, `ios/` etc. folders are missing, generate them once:

```
flutter create .
flutter pub get
flutter run
```

## Screenshots

| Phone, light | Phone, dark | Tablet grid |
| --- | --- | --- |
| _add `screenshots/phone_light.png`_ | _add `screenshots/phone_dark.png`_ | _add `screenshots/tablet_grid.png`_ |

## Decisions

The book list and the profile live in the shell's State, because three tabs
and two pushed screens all read the same data and one owner means one place
that calls setState; the tabs receive the data as constructor parameters and
send every change up through callbacks. The detail screen takes callbacks in
its route arguments because `onGenerateRoute` builds it without knowing the
shell, yet it has to change the shell's list (borrow, return, delete) and
switch to the profile tab. The form instead returns a `Book` through `pop`,
because it produces exactly one value and the caller alone decides what to do
with it, so backing out returns null and changes nothing. The list becomes a
grid through a `LayoutBuilder` rather than `MediaQuery`, because what matters
is the width this tab is given, not the width of the screen. The `PopScope`
compares the current value of every field with the values the form opened
with, so typing something and typing it back is not dirty, and Save pops
directly so it never asks. With week 9's tools I would move the list and the
profile out of the shell's State into a proper state-management solution and
persist them, so the callbacks passed through route arguments would go away.
