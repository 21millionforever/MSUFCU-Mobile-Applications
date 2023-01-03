// ignore_for_file: non_constant_identifier_names

import '../models/my_offers_icon.dart';

class MockMyOffers {
  static List<MyOffersIcon> FetchCommunityEventsIcons() {
    return [
      MyOffersIcon(
          shopName: "Unconditional love",
          category: "Community events",
          imageLink: "https://pbs.twimg.com/media/FVSxsxSWYAAnJ69.png",
          discountContent: "Unconditional love"),
      MyOffersIcon(
          shopName: "Student Art Exhibit",
          category: "Community events",
          imageLink:
              "https://www.cuinsight.com/wp-content/uploads/2021/01/unnamed-8.jpg",
          discountContent: "Student Art Exhibit"),
      MyOffersIcon(
          shopName: "Bangladesh Night 2022",
          category: "Community events",
          imageLink:
              "https://cogs.msu.edu/wp-content/uploads/2022/03/Flyer_Bangladesh-Night-2022-e1647278421352.jpg",
          discountContent: "Bangladesh Night 2022"),
    ];
  }

  static List<MyOffersIcon> FetchExclusiveOffersIcons() {
    return [
      MyOffersIcon(
          shopName: "World Gratitude Day",
          category: "Exclusive offers",
          imageLink: "https://pbs.twimg.com/media/FdNC7EdWAAQZzIU.png",
          discountContent: "Thank you"),
      MyOffersIcon(
          shopName: "Virtual Intern",
          category: "Exclusive offers",
          imageLink:
              "https://media-exp1.licdn.com/dms/image/C5622AQHUr_y9oevmug/feedshare-shrink_800/0/1658923418575?e=2147483647&v=beta&t=dTVTbpkOfcefOeOyz__JvSVCLEA_4xm32Qu8oTxDdi4",
          discountContent: "Virtual Intern"),
      MyOffersIcon(
          shopName: "Grand Opening Special",
          category: "Exclusive offers",
          imageLink: "https://i.ytimg.com/vi/FhX-pgALewA/mqdefault.jpg",
          discountContent: "Special"),
    ];
  }
}
