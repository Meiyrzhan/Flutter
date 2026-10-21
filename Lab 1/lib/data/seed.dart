import '../models/book.dart';
import '../models/genre.dart';

/// Twelve seed books with dates relative to today.
///
/// The five the defence looks at:
///  * b5 has a 60-character title
///  * b2 is at its limit (4 of 4)
///  * b3 and b10 are in the past
///  * b4 and b11 are online (the place is a link)
///  * b5, b7 and b12 have no notes
List<Book> seedBooks() {
  final now = DateTime.now();
  DateTime at(int days, int hour, [int minute = 0]) =>
      DateTime(now.year, now.month, now.day + days, hour, minute);

  return [
    Book(
      id: 'b1',
      title: 'Dune',
      genre: Genre.scifi,
      meeting: at(2, 18),
      place: 'Library, room 204',
      copies: 6,
      readers: const ['Aida', 'Marat', 'Dana'],
      online: false,
      notes: 'Part one only. Bring your annotated copy.',
      favourite: true,
    ),
    Book(
      id: 'b2',
      title: 'The Hobbit',
      genre: Genre.fantasy,
      meeting: at(1, 17, 30),
      place: 'Reading nook',
      copies: 4,
      readers: const ['Timur', 'Aruzhan', 'Nursultan', 'Zhanna'],
      online: false,
      notes: 'We read chapters 1 to 6.',
    ),
    Book(
      id: 'b3',
      title: 'Gone Girl',
      genre: Genre.mystery,
      meeting: at(-3, 19),
      place: 'Cafe Aroma',
      copies: 8,
      readers: const ['Dias', 'Madina', 'Alibek', 'Aigerim', 'Yerlan'],
      online: false,
      notes: 'Spoilers were allowed.',
    ),
    Book(
      id: 'b4',
      title: 'Project Hail Mary',
      genre: Genre.scifi,
      meeting: at(4, 20),
      place: 'https://meet.example.com/hail-mary',
      copies: 12,
      readers: const ['Aida', 'Dias'],
      online: true,
      notes: 'We meet on a video call.',
    ),
    Book(
      id: 'b5',
      title: 'The Extraordinarily Long Chronicle of the Lighthouse Keepers',
      genre: Genre.history,
      meeting: at(6, 16),
      place: 'Library, room 101',
      copies: 15,
      readers: const ['Marat', 'Zhanna'],
      online: false,
    ),
    Book(
      id: 'b6',
      title: 'Cosmos',
      genre: Genre.science,
      meeting: at(7, 16),
      place: 'Lecture hall B',
      copies: 10,
      readers: const ['Dana', 'Timur', 'Madina'],
      online: false,
      notes: 'Chapters 1 to 3.',
    ),
    Book(
      id: 'b7',
      title: 'Milk and Honey',
      genre: Genre.poetry,
      meeting: at(3, 15),
      place: 'Cafe Aroma',
      copies: 7,
      readers: const [
        'Aigerim',
        'Yerlan',
        'Dias',
        'Alibek',
        'Aruzhan',
        'Nursultan',
      ],
      online: false,
    ),
    Book(
      id: 'b8',
      title: 'Sapiens',
      genre: Genre.history,
      meeting: at(9, 18, 30),
      place: 'Library, room 101',
      copies: 20,
      readers: const ['Aida', 'Marat', 'Dana', 'Timur'],
      online: false,
      notes: 'Bring one question for the discussion.',
    ),
    Book(
      id: 'b9',
      title: 'The Name of the Wind',
      genre: Genre.fantasy,
      meeting: at(10, 19),
      place: 'Reading nook',
      copies: 5,
      readers: const ['Zhanna', 'Madina'],
      online: false,
      notes: 'Long book, start early.',
    ),
    Book(
      id: 'b10',
      title: 'Murder on the Orient Express',
      genre: Genre.mystery,
      meeting: at(-10, 17),
      place: 'Library, room 204',
      copies: 6,
      readers: const ['Alibek', 'Aida', 'Yerlan'],
      online: false,
      notes: 'Who guessed it first?',
      favourite: true,
    ),
    Book(
      id: 'b11',
      title: 'A Brief History of Time',
      genre: Genre.science,
      meeting: at(12, 14),
      place: 'https://zoom.example.com/hawking',
      copies: 30,
      readers: const [
        'Dana',
        'Marat',
        'Dias',
        'Timur',
        'Aruzhan',
        'Madina',
        'Aigerim',
        'Yerlan',
      ],
      online: true,
      notes: 'Recording will be shared.',
    ),
    Book(
      id: 'b12',
      title: 'Leaves of Grass',
      genre: Genre.poetry,
      meeting: at(14, 18),
      place: 'Garden terrace',
      copies: 9,
      readers: const ['Nursultan'],
      online: false,
      favourite: true,
    ),
  ];
}
