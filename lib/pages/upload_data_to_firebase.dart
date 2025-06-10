import 'package:chillwave/controllers/artist_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UploadDataToFirebase extends StatelessWidget {
  UploadDataToFirebase({super.key});

  final List<Map<String, String>> artistList = [
    {
    "artist_name": "Taylor Swift",
    "artist_images": "",
    "bio": "Taylor Swift là nữ ca sĩ kiêm nhạc sĩ người Mỹ, nổi bật với các bản hit như 'Love Story', 'Shake It Off', và 'Blank Space'."
  },
  {
    "artist_name": "Ed Sheeran",
    "artist_images": "",
    "bio": "Ed Sheeran là ca sĩ kiêm nhạc sĩ người Anh, được biết đến qua các ca khúc như 'Perfect', 'Shape of You', và 'Thinking Out Loud'."
  },
  {
    "artist_name": "Adele",
    "artist_images": "",
    "bio": "Adele là nữ ca sĩ người Anh với chất giọng mạnh mẽ, nổi bật qua các ca khúc 'Hello', 'Someone Like You' và 'Easy On Me'."
  },
  {
    "artist_name": "Justin Bieber",
    "artist_images": "",
    "bio": "Justin Bieber là ca sĩ người Canada, nổi tiếng toàn cầu với các bản hit như 'Baby', 'Peaches', và 'Sorry'."
  },
  {
    "artist_name": "BTS",
    "artist_images": "",
    "bio": "BTS là nhóm nhạc nam Hàn Quốc hàng đầu thế giới, nổi bật qua các bản hit như 'Dynamite', 'Butter', và 'Boy With Luv'."
  },
  {
    "artist_name": "The Weeknd",
    "artist_images": "",
    "bio": "The Weeknd là ca sĩ người Canada, nổi bật với phong cách R&B và các ca khúc như 'Blinding Lights', 'Starboy'."
  },
  {
    "artist_name": "Billie Eilish",
    "artist_images": "",
    "bio": "Billie Eilish là ca sĩ trẻ người Mỹ với phong cách độc đáo, nổi tiếng qua 'Bad Guy', 'Lovely' và 'Happier Than Ever'."
  },
  {
    "artist_name": "Bruno Mars",
    "artist_images": "",
    "bio": "Bruno Mars là nghệ sĩ đa tài người Mỹ với các hit như 'Just The Way You Are', '24K Magic', 'Uptown Funk'."
  },
  {
    "artist_name": "Ariana Grande",
    "artist_images": "",
    "bio": "Ariana Grande là ca sĩ người Mỹ có giọng hát cao vút, nổi tiếng với các ca khúc '7 Rings', 'Positions', và 'Into You'."
  },
  {
    "artist_name": "Coldplay",
    "artist_images": "",
    "bio": "Coldplay là ban nhạc rock người Anh, nổi tiếng toàn cầu với các ca khúc như 'Yellow', 'Viva La Vida', và 'Fix You'."
  }
    // {
    //   "artist_name": "Đen Vâu",
    //   "artist_images": "",
    //   "bio": "Đen Vâu là rapper nổi tiếng với phong cách gần gũi, sâu sắc qua các bản hit như 'Mang tiền về cho mẹ', 'Đi về nhà'."
    // },
    // {
    //   "artist_name": "Soobin Hoàng Sơn",
    //   "artist_images": "",
    //   "bio": "Soobin Hoàng Sơn là ca sĩ đa tài với giọng hát ngọt ngào, nổi bật qua các bài như 'Phía sau một cô gái', 'Giá như'."
    // }

  // {
  //   "artist_name": "HIEUTHUHAI",
  //   "artist_images": "",
  //   "bio": "HIEUTHUHAI là rapper trẻ đầy triển vọng, được biết đến với phong cách rap phóng khoáng và hiện đại. Quán quân chương trình 'Anh Trai Vượt Ngàn Chông Gai'."
  // },
  // {
  //   "artist_name": "Rhyder",
  //   "artist_images": "",
  //   "bio": "Rhyder là ca sĩ kiêm rapper Gen Z, nổi bật nhờ ngoại hình điển trai và chất giọng ngọt ngào. Á quân cuộc thi âm nhạc hot hiện nay."
  // },
  // {
  //   "artist_name": "Quang Hùng MasterD",
  //   "artist_images": "",
  //   "bio": "Quang Hùng MasterD là ca sĩ kiêm nhạc sĩ được yêu thích với các ca khúc viral như 'Dễ đến dễ đi'."
  // },
  // {
  //   "artist_name": "Đức Phúc",
  //   "artist_images": "",
  //   "bio": "Đức Phúc là quán quân The Voice Việt 2015, nổi bật với chất giọng cao và cảm xúc. Anh sở hữu nhiều bản hit ballad đình đám."
  // },
  // {
  //   "artist_name": "Isaac",
  //   "artist_images": "",
  //   "bio": "Isaac là cựu trưởng nhóm 365daband, hiện là ca sĩ solo nổi bật và hoạt động đa lĩnh vực như diễn xuất và dẫn chương trình."
  // },
  // {
  //   "artist_name": "Anh Tú Atus",
  //   "artist_images": "",
  //   "bio": "Anh Tú là nam ca sĩ - diễn viên có ngoại hình điển trai, giọng ca mạnh mẽ và từng đạt Top 10 nhiều cuộc thi âm nhạc."
  // },
  // {
  //   "artist_name": "Dương Domic",
  //   "artist_images": "",
  //   "bio": "Dương Domic là ca sĩ trẻ đang lên, được chú ý nhờ khả năng sáng tác và phong cách âm nhạc hiện đại."
  // },
  // {
  //   "artist_name": "Negav",
  //   "artist_images": "",
  //   "bio": "Negav là rapper Gen Z với phong cách cá tính, nổi bật qua các vòng thi đấu rap cạnh tranh."
  // },
  // {
  //   "artist_name": "Erik",
  //   "artist_images": "",
  //   "bio": "Erik là ca sĩ trẻ nổi tiếng với các bản ballad đầy cảm xúc như 'Sau tất cả', 'Em không sai, chúng ta sai'."
  // },
  // {
  //   "artist_name": "Quân A.P",
  //   "artist_images": "",
  //   "bio": "Quân A.P sở hữu chất giọng trầm ấm, từng gây sốt với ca khúc 'Ai là người thương em'."
  // },
  // {
  //   "artist_name": "JSOL",
  //   "artist_images": "",
  //   "bio": "JSOL là ca sĩ trẻ triển vọng, nổi bật với các bản tình ca nhẹ nhàng và hình ảnh thư sinh."
  // },
  // {
  //   "artist_name": "Pháp Kiều",
  //   "artist_images": "",
  //   "bio": "Pháp Kiều là rapper trẻ cá tính, được biết đến qua các bản rap bắt tai và kỹ thuật chắc chắn."
  // },
  // {
  //   "artist_name": "Captain",
  //   "artist_images": "",
  //   "bio": "Captain là nghệ sĩ Gen Z nổi bật với khả năng rap và trình diễn cuốn hút."
  // },
  // {
  //   "artist_name": "Song Luân",
  //   "artist_images": "",
  //   "bio": "Song Luân là diễn viên, ca sĩ nổi tiếng với ngoại hình sáng và giọng hát nội lực."
  // },
  // {
  //   "artist_name": "Hùng Huỳnh",
  //   "artist_images": "",
  //   "bio": "Hùng Huỳnh là nghệ sĩ đa năng: ca sĩ, người mẫu và vũ công với phong cách biểu diễn cuốn hút."
  // },
  // {
  //   "artist_name": "Ali Hoàng Dương",
  //   "artist_images": "",
  //   "bio": "Ali là quán quân The Voice Việt, nổi bật với phong cách thời trang và âm nhạc hiện đại."
  // },
  // {
  //   "artist_name": "Quang Trung",
  //   "artist_images": "",
  //   "bio": "Quang Trung là diễn viên kiêm ca sĩ, gây ấn tượng với giọng hát cảm xúc và lối diễn xuất duyên dáng."
  // },
  // {
  //   "artist_name": "Lou Hoàng",
  //   "artist_images": "",
  //   "bio": "Lou Hoàng là học trò của OnlyC, sở hữu phong cách âm nhạc trẻ trung và cá tính."
  // },
  // {
  //   "artist_name": "Gin Tuấn Kiệt",
  //   "artist_images": "",
  //   "bio": "Gin Tuấn Kiệt là diễn viên và ca sĩ nổi bật, ghi dấu ấn qua nhiều vai diễn và sản phẩm âm nhạc sôi động."
  // },
  // {
  //   "artist_name": "Bích Phương",
  //   "artist_images": "",
  //   "bio": "Bích Phương được biết đến với hình ảnh nữ tính, sáng tạo trong âm nhạc qua các hit như 'Bùa yêu'."
  // },
  // {
  //   "artist_name": "Phương Ly",
  //   "artist_images": "",
  //   "bio": "Phương Ly là nữ ca sĩ trẻ với chất giọng ngọt ngào và gu thời trang nổi bật."
  // },
  // {
  //   "artist_name": "Tiên Tiên",
  //   "artist_images": "",
  //   "bio": "Tiên Tiên là nhạc sĩ, ca sĩ với phong cách độc đáo, nổi bật từ 'Say you do'."
  // },
  // {
  //   "artist_name": "Miu Lê",
  //   "artist_images": "",
  //   "bio": "Miu Lê là ca sĩ kiêm diễn viên nổi bật với nhiều bản hit như 'Yêu anh'."
  // },
  // {
  //   "artist_name": "Bảo Anh",
  //   "artist_images": "",
  //   "bio": "Bảo Anh sở hữu chất giọng trầm ấm, từng gây sốt với 'Trái tim em cũng biết đau'."
  // },
  // {
  //   "artist_name": "Châu Bùi",
  //   "artist_images": "",
  //   "bio": "Châu Bùi là fashionista và người mẫu, hiện đang lấn sân sang âm nhạc và diễn xuất."
  // },
  // {
  //   "artist_name": "Quỳnh Anh Shyn",
  //   "artist_images": "",
  //   "bio": "Quỳnh Anh Shyn là hot girl kiêm nghệ sĩ trẻ thử sức trong lĩnh vực âm nhạc với màu sắc riêng."
  // },
  // {
  //   "artist_name": "Orange",
  //   "artist_images": "",
  //   "bio": "Orange nổi bật với giọng ca nội lực, từng thành công cùng Karik với 'Người lạ ơi'."
  // },
  // {
  //   "artist_name": "Phương Mỹ Chi",
  //   "artist_images": "",
  //   "bio": "Phương Mỹ Chi là giọng ca dân ca nổi bật từ The Voice Kids, được mệnh danh là 'cô bé dân ca'."
  // },
  // {
  //   "artist_name": "Lâm Bảo Ngọc",
  //   "artist_images": "",
  //   "bio": "Lâm Bảo Ngọc là ca sĩ trẻ nổi bật với chất giọng kỹ thuật cao và cảm xúc."
  // },
  // {
  //   "artist_name": "Han Sara",
  //   "artist_images": "",
  //   "bio": "Han Sara là ca sĩ Hàn Quốc hoạt động tại Việt Nam, nổi bật với hình ảnh trẻ trung, năng động."
  // },
  // {
  //   "artist_name": "Ngô Lan Hương",
  //   "artist_images": "",
  //   "bio": "Ngô Lan Hương là ca sĩ Gen Z nổi bật với phong cách âm nhạc nhẹ nhàng, trong sáng."
  // },
  // {
  //   "artist_name": "Pháo Northside",
  //   "artist_images": "",
  //   "bio": "Pháo là rapper nữ cá tính với phong cách mạnh mẽ, từng thi Rap Việt và để lại dấu ấn."
  // },
  // {
  //   "artist_name": "Danmy",
  //   "artist_images": "",
  //   "bio": "Danmy là nghệ sĩ trẻ tiềm năng với phong cách trình diễn cuốn hút và âm nhạc hiện đại."
  // },
  // {
  //   "artist_name": "Muộii",
  //   "artist_images": "",
  //   "bio": "Muộii là nghệ sĩ Gen Z nổi bật trên nền tảng mạng xã hội, đang lấn sân âm nhạc."
  // },
  // {
  //   "artist_name": "Sơn Tùng MTP",
  //   "artist_images": "",
  //   "bio": "Sơn Tùng M-TP là biểu tượng của V-pop hiện đại với nhiều bản hit đình đám như 'Lạc trôi', 'Chúng ta của hiện tại'."
  // },
  // {
  //   "artist_name": "Hà Anh Tuấn",
  //   "artist_images": "",
  //   "bio": "Hà Anh Tuấn được yêu thích với giọng hát truyền cảm và chuỗi chương trình 'See Sing Share'."
  // },
  // {
  //   "artist_name": "Mỹ Tâm",
  //   "artist_images": "",
  //   "bio": "Mỹ Tâm là một trong những diva hàng đầu Việt Nam, với hàng loạt bản hit sống mãi cùng năm tháng."
  // },
  // {
  //   "artist_name": "Noo Phước Thịnh",
  //   "artist_images": "",
  //   "bio": "Noo Phước Thịnh là nam ca sĩ nổi bật với nhiều bản hit được giới trẻ yêu thích."
  // },
  // {
  //   "artist_name": "Đông Nhi",
  //   "artist_images": "",
  //   "bio": "Đông Nhi là nữ ca sĩ sở hữu lượng fan lớn và sự nghiệp âm nhạc ổn định nhiều năm qua."
  // },
  // {
  //   "artist_name": "Hồ Ngọc Hà",
  //   "artist_images": "",
  //   "bio": "Hồ Ngọc Hà là nữ ca sĩ - người mẫu với phong cách quyến rũ và khả năng trình diễn cuốn hút."
  // },
  // {
  //   "artist_name": "Hoàng Dũng",
  //   "artist_images": "",
  //   "bio": "Hoàng Dũng là ca sĩ kiêm nhạc sĩ ballad, nổi bật với bản hit 'Nàng thơ'."
  // },
  // {
  //   "artist_name": "Hòa Minzy",
  //   "artist_images": "",
  //   "bio": "Hòa Minzy là ca sĩ nội lực, thường gây xúc động qua các ca khúc ballad và MV ý nghĩa."
  // },
  // {
  //   "artist_name": "Thùy Chi",
  //   "artist_images": "",
  //   "bio": "Thùy Chi là giọng ca trong trẻo, từng gắn liền với tuổi thơ qua các bài hát học trò."
  // },
  // {
  //   "artist_name": "Phan Mạnh Quỳnh",
  //   "artist_images": "",
  //   "bio": "Phan Mạnh Quỳnh là nhạc sĩ - ca sĩ nổi tiếng với khả năng sáng tác sâu sắc và lời ca gần gũi."
  // },
  // {
  //   "artist_name": "Hoàng Thùy Linh",
  //   "artist_images": "",
  //   "bio": "Hoàng Thùy Linh là nghệ sĩ tiên phong dòng nhạc dân gian đương đại, nổi bật với 'See Tình'."
  // },
  // {
  //   "artist_name": "Hà Nhi",
  //   "artist_images": "",
  //   "bio": "Hà Nhi nổi bật với chất giọng dày và đầy cảm xúc, ghi dấu qua nhiều bản cover chất lượng."
  // },
  // {
  //   "artist_name": "Văn Mai Hương",
  //   "artist_images": "",
  //   "bio": "Văn Mai Hương là ca sĩ nội lực, từng đạt á quân Vietnam Idol và sở hữu nhiều bản hit trữ tình."
  // }
];


  Future<void> uploadArtistsToFirestore() async {
    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('artists');

    for (final artist in artistList) {
      await collection.add(artist);
    }
  }
  Future<void> addSelectedSongs() async {
  final firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> songs = [
    // Coldplay
{
  'song_name': 'Fix You',
  'artist_id': ['lKJoNShUxxUKxCd1Kp83'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2005,
  'country': 'international',
},
// Ariana Grande
{
  'song_name': '7 Rings',
  'artist_id': ['h1otBb4PJMWpC6OXyLqH'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2019,
  'country': 'international',
},
// The Weeknd
{
  'song_name': 'Blinding Lights',
  'artist_id': ['Zq498eDzQys8yxiREqtI'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2020,
  'country': 'international',
},
// BTS
{
  'song_name': 'Dynamite',
  'artist_id': ['UoyzE7vbCFahEZZfFLXV'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2020,
  'country': 'international',
},
// Billie Eilish
{
  'song_name': 'Happier Than Ever',
  'artist_id': ['KYY3GBNvrTsoq3Xiv3cc'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2021,
  'country': 'international',
},
// Ed Sheeran
{
  'song_name': 'Perfect',
  'artist_id': ['72gOwzzJ1klyS63BUp1j'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2017,
  'country': 'international',
},
// Taylor Swift
{
  'song_name': 'Blank Space',
  'artist_id': ['uVhCAxnIQW5M41PU4QbW'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2014,
  'country': 'international',
},
// Justin Bieber
{
  'song_name': 'Peaches',
  'artist_id': ['una7m5wEfVtjrbdHZ6Um'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2021,
  'country': 'international',
},
// Bruno Mars
{
  'song_name': 'Uptown Funk',
  'artist_id': ['NmND5KZgMg2DWu0TvcUo'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2014,
  'country': 'international',
},
// Adele
{
  'song_name': 'Hello',
  'artist_id': ['atZWGkyhUmQsMPquc0SP'],
  'audio_url': '',
  'duration': null,
  'love_count': 0,
  'play_count': 0,
  'song_imageUrl': '',
  'year': 2015,
  'country': 'international',
},

      // Đen Vâu – "Vị Nhà" (2025)
      // {
      //   'song_name': 'Vị Nhà',
      //   'artist_id': ['bSpS0xfDCmIeVlUyGZ91'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2025,
      // },
      // // Đen Vâu – "Mang tiền về cho mẹ" (2021)
      // {
      //   'song_name': 'Mang tiền về cho mẹ',
      //   'artist_id': ['bSpS0xfDCmIeVlUyGZ91'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2021,
      // },
      // // Soobin Hoàng Sơn – "Giá như" (2024)
      // {
      //   'song_name': 'Giá như',
      //   'artist_id': ['NXM2u9s9Dm0dN7YwiYnv'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2024,
      // },
      // // Soobin Hoàng Sơn – "Dancing In The Dark" (2025)
      // {
      //   'song_name': 'Dancing In The Dark',
      //   'artist_id': ['NXM2u9s9Dm0dN7YwiYnv'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2025,
      // },
      // // Ali Hoàng Dương
      // {
      //   'song_name': 'Đừng Phiền Anh',
      //   'artist_id': ['0iD3qQaODjukMdk9rvmz'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // HIEUTHUHAI
      // {
      //   'song_name': 'Nước Mắt Cá Sấu',
      //   'artist_id': ['3sOvqtORQzMlzBk7Y5aX'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2022, // track trong playlist :contentReference[oaicite:1]{index=1}
      // },
      // // Pháo Northside
      // {
      //   'song_name': 'Một Ngày Chẳng Nắng',
      //   'artist_id': ['oKZEIquHPPYGMOrZjCTj'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2022,
      // },
      // // Danmy
      // {
      //   'song_name': 'Come with me',
      //   'artist_id': ['4bWIKa8vLB91FHvKb1NL'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Muộii
      // {
      //   'song_name': 'Chuyện Đôi Ta',
      //   'artist_id': ['i75eOC9PllNh7KbazlBj'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Hòa Minzy
      // {
      //   'song_name': 'Ngủ Một Mình',
      //   'artist_id': ['xWtzYwyQ7ZSHANXakuod'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,  // được đánh giá trending :contentReference[oaicite:2]{index=2}
      // },
      // // Thùy Chi
      // {
      //   'song_name': 'Giấc Mơ Trưa',
      //   'artist_id': ['DdVE3cRAuQd3U5anoJKV'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2021,
      // },
      // // Hoàng Thùy Linh
      // {
      //   'song_name': 'Để Mị nói cho mà nghe',
      //   'artist_id': ['FjybI3N9HRWyLyeF0tpz'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2019, // hit lớn và đoạt nhiều giải thưởng :contentReference[oaicite:3]{index=3}
      // },
      // // Sơn Tùng MTP
      // {
      //   'song_name': 'Chạy Ngay Đi',
      //   'artist_id': ['GkK22lJhtjIyfdhFmtTY'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2019,
      // },
      // // Đức Phúc
      // {
      //   'song_name': 'Em Đồng Ý (I Do)',
      //   'artist_id': ['H5X5e8OJv4tWemSLYI9H'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,  // nằm trong bảng Billboard Vietnam Hot100 :contentReference[oaicite:4]{index=4}
      // },
      // // Erik
      // {
      //   'song_name': 'Em không sai, chúng ta sai',
      //   'artist_id': ['YqmVOl67YVnhqDIkrs9x'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2020,
      // },
      // // Ali Hoàng Dương collab
      // {
      //   'song_name': 'REGRET',
      //   'artist_id': ['0iD3qQaODjukMdk9rvmz', 'pBNYdZtt1wmfCYVIcw15'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2024, // ca khúc nhóm show :contentReference[oaicite:5]{index=5}
      // },
      // // Phương Ly – "Anh Là Ngoại Lệ Của Em" (2023)
      // {
      //   'song_name': 'Anh Là Ngoại Lệ Của Em',
      //   'artist_id': ['4jtBgbth0CRAPimwHMOL'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Bảo Anh – "Cứ Để Anh Ta Rời Đi" (feat. Dương Domic...) (2024)
      // {
      //   'song_name': 'Cứ Để Anh Ta Rời Đi',
      //   'artist_id': ['PwKcZCKiNI9mSE0k959F'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2024,
      // },
      // // Pháo Northside – "Sự Nghiệp Chướng" (2025)
      // {
      //   'song_name': 'Sự Nghiệp Chướng',
      //   'artist_id': ['oKZEIquHPPYGMOrZjCTj'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2025,
      // },
      // // Suni Hạ Linh – "Ngỏ Lời" (2023)
      // {
      //   'song_name': 'Ngỏ Lời',
      //   'artist_id': ['aDQaUxY7CBNp4i7urRUx'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Erik – "Ăn Sáng Nha" (2020, ft. Suni Hạ Linh)
      // {
      //   'song_name': 'Ăn Sáng Nha',
      //   'artist_id': ['YqmVOl67YVnhqDIkrs9x'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2020,
      // },
      // // Dương Domic – "Phiêu Nhịp Thở" (2023)
      // {
      //   'song_name': 'Phiêu Nhịp Thở',
      //   'artist_id': ['gVdImK9IuRTOr3VVQ5rT'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Han Sara – single nổi bật gần đây (2024)
      // {
      //   'song_name': 'Single Mới 2024',
      //   'artist_id': ['aDQaUxY7CBNp4i7urRUx'], // Han Sara
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2024,
      // },
      // // Gin Tuấn Kiệt – sản phẩm viral (2023)
      // {
      //   'song_name': 'Single Viral 2023',
      //   'artist_id': ['eOyCLDFLFyToaBbOGE1Q'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Quỳnh Anh Shyn – debut show Em Xinh (2025)
      // {
      //   'song_name': 'Debut Show 2025',
      //   'artist_id': ['aC5Eu2k9ZfONrumo6PyC'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2025,
      // },
      // // Miu Lê – single mới (2023)
      // {
      //   'song_name': 'Single Míu Lê 2023',
      //   'artist_id': ['ce8195mEs1GCry1YjmFR'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Muộii – "Chuyện Đôi Ta" (2023)
      // {
      //   'song_name': 'Chuyện Đôi Ta',
      //   'artist_id': ['i75eOC9PllNh7KbazlBj'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Lou Hoàng – single mới (2023)
      // {
      //   'song_name': 'Single Lou Hoàng 2023',
      //   'artist_id': ['mmoJyDIcluwiSPvOoX3S'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Quân A.P – "Dắt em đi khỏi đây" (2023)
      // {
      //   'song_name': 'Dắt em đi khỏi đây',
      //   'artist_id': ['Ttzt7AzW00PkZ6RudB2i'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,  // Mở đầu iTunes Top 1 :contentReference[oaicite:1]{index=1}
      // },
      // // Isaac – "Loving You 2022" (DJ Isaac) (2022)
      // {
      //   'song_name': 'Loving You 2022',
      //   'artist_id': ['61RwPHsc4xPd15gYg0Z7'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2022,  // Track nổi bật của DJ Isaac :contentReference[oaicite:2]{index=2}
      // },
      // // Hùng Huỳnh – "Chẳng Thể Nhắm Mắt" ft. Kewtiie (2023)
      // {
      //   'song_name': 'Chẳng Thể Nhắm Mắt',
      //   'artist_id': ['S2gKvbRueI78gjdHnVic'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,  // Track viral trên TikTok :contentReference[oaicite:3]{index=3}
      // },
      // // Suni Hạ Linh – "Ngỏ lời" (2023)
      // {
      //   'song_name': 'Ngỏ lời',
      //   'artist_id': ['aDQaUxY7CBNp4i7urRUx'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,  // #1 YouTube Trending :contentReference[oaicite:4]{index=4}
      // },
      // // Phương Ly – "Anh Là Ngoại Lệ Của Em" (2023)
      // {
      //   'song_name': 'Anh Là Ngoại Lệ Của Em',
      //   'artist_id': ['4jtBgbth0CRAPimwHMOL'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Bảo Anh – "Cứ Để Anh Ta Rời Đi" (2024)
      // {
      //   'song_name': 'Cứ Để Anh Ta Rời Đi',
      //   'artist_id': ['PwKcZCKiNI9mSE0k959F'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2024,
      // },
      // // Gin Tuấn Kiệt – Viral single (2023)
      // {
      //   'song_name': 'Single Viral 2023',
      //   'artist_id': ['eOyCLDFLFyToaBbOGE1Q'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Rhyder – "Chịu Cách Mình Nói Thua" (2023)
      // {
      //   'song_name': 'Chịu Cách Mình Nói Thua',
      //   'artist_id': ['62iv1zaJ57js7lpbdqir'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Quang Hùng MasterD – "Thủy Triều" (2024)
      // {
      //   'song_name': 'Thủy Triều',
      //   'artist_id': ['VILRXha5xc1Rd7srH6RH'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2024,
      // },
      // // Pháp Kiều – "DOC" (2023)
      // {
      //   'song_name': 'DOC',
      //   'artist_id': ['61RwPHsc4xPd15gYg0Z7'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // JSOL – "Cổ Tích" (2022)
      // {
      //   'song_name': 'Cổ Tích',
      //   'artist_id': ['wE3jbyZhypxpoJprKzuA'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2022,
      // },
      // // Danmy – "Come with me" (2023) [đã thêm trước]
      // // Muộii – "Chuyện Đôi Ta" (2023) [đã thêm trước]
      // // Captain – "Walk" (feat. RHYDER...) (2023)
      // {
      //   'song_name': 'Walk',
      //   'artist_id': ['pbAeaE7m8t0LJ7Pi2aph'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
      // // Negav – "Hào Quang" (feat. Rhyder, Dương Domic, Pháp Kiều) (2023)
      // {
      //   'song_name': 'Hào Quang',
      //   'artist_id': ['Yac6qfXX6hvTvp4sT8bj'],
      //   'audio_url': '',
      //   'duration': null,
      //   'love_count': 0,
      //   'play_count': 0,
      //   'song_imageUrl': '',
      //   'year': 2023,
      // },
  ];

  for (final song in songs) {
    await firestore.collection('songs').add(song);
  }
}
  Future<void> addCountryToAllSongs() async {
    final songsCollection = FirebaseFirestore.instance.collection('songs');

    try {
      final snapshot = await songsCollection.get();
      for (var doc in snapshot.docs) {
        await songsCollection.doc(doc.id).update({
          'country': 'Viet Nam',
        });
      }
      print("Thêm 'country: Viet Nam' thành công cho tất cả bài hát.");
    } catch (e) {
      print("Lỗi khi thêm country: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          //uploadArtistsToFirestore();
          //ArtistController.printAllArtists();
          //addSelectedSongs();
          //addCountryToAllSongs();
        },
        child: Text('Thêm dữ liệu'),
      ),
    );
  }
}