extends Resource

enum Cook {
  None = 0,
  Cooked = 1,
  Burned = 2
}

enum Chop {
  None = 0,
  Chopped = 1,
  Diced = 2,
  Minced = 3,
  Ground = 4
}

export(String) var name = "base"
export(Cook) var cook = Cook.None
export(Chop) var chop = Cook.None