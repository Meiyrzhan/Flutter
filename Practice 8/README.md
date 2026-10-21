# Reading List - Practice 8: A Little of Everything

Small Flutter app recapping weeks 1-7: plain Dart, state, layout, navigation with a result, and form validation.

## Structure
- `lib/main.dart` - app entry, startup `debugPrint`s
- `lib/models/book.dart` - `Book`, `fromMap`, `totalPages`, `unread`, `authors`, `seed`
- `lib/widgets/book_tile.dart` - `BookTile`
- `lib/library_screen.dart` - list, filter chips, header, add/detail navigation
- `lib/detail_screen.dart` - detail, answers with `BookAction`
- `lib/add_book_screen.dart` - validated form, answers with `Book`

## Run
If `android/`, `ios/` etc. are missing, generate them once (keeps existing `lib/`):

    flutter create .
    flutter pub get
    flutter run

Check: `flutter analyze` and `dart format .`

## Screenshots
Add `screenshot_list.png` (filter on Unread, long title wrapped) and `screenshot_form.png` (form with three errors) here.
