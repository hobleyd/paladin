// Shaped to match Book.fromJson's contract (see lib/models/book.g.dart):
// Author/Series/Tags are nested objects, not plain strings.
const String booksResponseData = '''
[
 {
  "UUID": "fb46a7d7-e4f5-4daa-94ce-0891e4463b82",
  "Title": "Brief Cases",
  "Series": {"series": "Dresden Files, The"},
  "Series_index": 15.5,
  "Author": [{"name": "Butcher, Jim"}],
  "Rating": 0,
  "Is_read": false,
  "Last_read": 0,
  "Last_modified": 1676939763,
  "Blurb": "Magic. It can get a guy killed. Return to the world of the Dresden Files with Harry Dresden (the only wizard in the Chicago phone book) and friends as they solve supernatural mysteries, protect the helpless, and fight evil.",
  "Tags": [
   {"tag": "Mystery & Detective"},
   {"tag": "Supernatural"},
   {"tag": "Magic"}
  ]
 },
 {
  "UUID": "ed2f3da9-7ee3-4eef-a4c9-76b84d865294",
  "Title": "Ghost Fleet: A Novel of the Next World War",
  "Series": null,
  "Series_index": 1,
  "Author": [{"name": "Singer, P. W."}, {"name": "Cole, August"}],
  "Rating": 0,
  "Is_read": false,
  "Last_read": 0,
  "Last_modified": 1678597153,
  "Blurb": "Ghost Fleet is a page-turning imagining of a war set in the not-too-distant future. Navy captains battle through a modern-day Pearl Harbor; fighter pilots duel with stealthy drones.",
  "Tags": [
   {"tag": "Military"},
   {"tag": "Science Fiction"}
  ]
 }
 ]
 ''';
