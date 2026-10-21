/// The person using the app (R1, R3).
class Profile {
  const Profile({required this.name, required this.group});

  const Profile.empty() : this(name: '', group: '');

  final String name;
  final String group;

  Profile copyWith({String? name, String? group}) {
    return Profile(name: name ?? this.name, group: group ?? this.group);
  }
}
