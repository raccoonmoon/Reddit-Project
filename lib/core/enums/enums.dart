enum ThemeMode { dark, light }

enum UserKarma {
  comment(1),
  textPost(2),
  imagePost(3),
  linkPost(3),
  awardPost(5),
  deletePost(-1);

  final int karma;
  const UserKarma(this.karma);
}

//enum Userawards { awesomeAns, gold, thankyou, til }
