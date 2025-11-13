//
//  Item.swift
//  88trip
//
//  Created by かめいりょう on 2025/09/27.
//

import Foundation
import SwiftUI
import SwiftData
import MapKit


//アプリで扱うデータのクラスを定義するファイルです

//@modelとはswiftdataにこのクラスは永続化対象のデータですと教えるためのアトリビュート

//@なんとかみたいなやつはアトリビュートと言います


final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}


final class PostData {
    var image: Image
    var text: String
    
    init(image: Image, text: String) {
        self.image = image
        self.text = text
    }
}

//Identifiable
//それぞれのデータに一意の識別子を持たせるためのプロトコル

//codable
//jsonなど外部データと交換できるようにするプロトコル
struct PpostData: Identifiable, Codable{
    
    var id: UUID = UUID()
    var imageUrl: String
    var text: String
}


struct NoticeData: Identifiable , Codable {
    var id: UUID = UUID()
    var userName: String
    var noticeContent: String = {
        let messages = [
            "さんがあなたの投稿にいいねしました。",
            "さんから新しいコメントが届きました。",
            "さんにメンションされました。",
            "さんがフォローしました。",
            "新しい通知があります。"
        ]
        return messages.randomElement() ?? "通知があります。"
        
    }()
}



//練習
struct ProfileData: Identifiable, Codable {
    var id: UUID = UUID()
    var userName: String
}

//MapView　専用
struct Pin: Identifiable {
    let id : Int
    let name: String
    let coordinate: CLLocationCoordinate2D
    let place: String
}

//徳島1　２３ヶ所
//高知2 16ヶ所
//愛媛3　２６
//香川4 ２３

let sikokuPins: [Pin] = [
    Pin(id: 1, name: "霊山寺", coordinate: CLLocationCoordinate2D(latitude: 34.159665, longitude: 134.502531), place: "1"),
    Pin(id: 2, name: "極楽寺", coordinate: CLLocationCoordinate2D(latitude: 34.156163, longitude: 134.490206), place: "1"),
    Pin(id: 3,name: "金泉寺", coordinate: CLLocationCoordinate2D(latitude: 34.147190, longitude: 134.468769), place: "1"),
    Pin(id: 4,name: "大日寺", coordinate: CLLocationCoordinate2D(latitude: 34.151320, longitude: 134.430843), place: "1"),
    Pin(id: 5,name: "地蔵寺", coordinate: CLLocationCoordinate2D(latitude: 34.137157, longitude: 134.431967), place: "1"),
    Pin(id: 6,name: "安楽寺", coordinate: CLLocationCoordinate2D(latitude: 34.118033, longitude: 134.388341), place: "1"),
    Pin(id: 7,name: "十楽寺", coordinate: CLLocationCoordinate2D(latitude: 34.120456, longitude: 134.378329), place: "1"),
    Pin(id: 8,name: "熊谷寺", coordinate: CLLocationCoordinate2D(latitude: 34.122718, longitude: 134.340016), place: "1"),
    Pin(id: 9,name: "法輪寺", coordinate: CLLocationCoordinate2D(latitude: 34.104314, longitude: 134.333788), place: "1"),
    Pin(id: 10,name: "切幡寺", coordinate: CLLocationCoordinate2D(latitude: 34.107740, longitude: 134.304310), place: "1"),
    Pin(id: 11,name: "藤井寺", coordinate: CLLocationCoordinate2D(latitude: 34.051624, longitude: 134.348545), place: "1"),
    Pin(id: 12,name: "焼山寺", coordinate: CLLocationCoordinate2D(latitude: 33.984866, longitude: 134.310313), place: "1"),
    Pin(id: 13,name: "大日寺", coordinate: CLLocationCoordinate2D(latitude: 34.038109, longitude: 134.462636), place: "1"),
    Pin(id: 14,name: "常楽寺", coordinate: CLLocationCoordinate2D(latitude: 34.050323, longitude: 134.476013), place: "1"),
    Pin(id: 15,name: "国分寺", coordinate: CLLocationCoordinate2D(latitude: 34.055644, longitude: 134.473631), place: "1"),
    Pin(id: 16,name: "観音寺", coordinate: CLLocationCoordinate2D(latitude: 34.068467, longitude: 134.474153), place: "1"),
    Pin(id: 17,name: "井戸寺", coordinate: CLLocationCoordinate2D(latitude: 34.085156, longitude: 134.485483), place: "1"),
    Pin(id: 18,name: "恩山寺", coordinate: CLLocationCoordinate2D(latitude: 33.985967, longitude: 134.578231), place: "1"),
    Pin(id: 19,name: "立江寺", coordinate: CLLocationCoordinate2D(latitude: 33.967815, longitude: 134.605678), place: "1"),
    Pin(id: 20,name: "鶴林寺", coordinate: CLLocationCoordinate2D(latitude: 33.913921, longitude: 134.505546), place: "1"),
    Pin(id: 21,name: "太龍寺", coordinate: CLLocationCoordinate2D(latitude: 33.882508, longitude: 134.521623), place: "1"),
    Pin(id: 22,name: "平等寺", coordinate: CLLocationCoordinate2D(latitude: 33.851938, longitude: 134.582643), place: "1"),
    Pin(id: 23,name: "薬王寺", coordinate: CLLocationCoordinate2D(latitude: 33.732329, longitude: 134.527557), place: "1"),
    
    
    
    Pin(id: 24,name: "最御崎寺", coordinate: CLLocationCoordinate2D(latitude: 33.249024, longitude: 134.175843), place: "2"),
    Pin(id: 25,name: "津照寺", coordinate: CLLocationCoordinate2D(latitude: 33.288190, longitude: 134.148391), place: "2"),
    Pin(id: 26,name: "金剛頂寺", coordinate: CLLocationCoordinate2D(latitude: 33.307226, longitude: 134.122828), place: "2"),
    Pin(id: 27,name: "神峯寺", coordinate: CLLocationCoordinate2D(latitude: 33.467582, longitude: 133.974844), place: "2"),
    Pin(id: 28,name: "大日寺", coordinate: CLLocationCoordinate2D(latitude: 33.577781, longitude: 133.705071), place: "2"),
    Pin(id: 29,name: "国分寺", coordinate: CLLocationCoordinate2D(latitude: 33.598705, longitude: 133.640485), place: "2"),
    Pin(id: 30,name: "善楽寺", coordinate: CLLocationCoordinate2D(latitude: 33.591920, longitude: 133.577654), place: "2"),
    Pin(id: 31,name: "竹林寺", coordinate: CLLocationCoordinate2D(latitude: 33.546634, longitude: 133.577443), place: "2"),
    Pin(id: 32,name: "禅師峰寺", coordinate: CLLocationCoordinate2D(latitude: 33.526854, longitude: 133.611603), place: "2"),
    Pin(id: 33,name: "雪蹊寺", coordinate: CLLocationCoordinate2D(latitude: 33.500850, longitude: 133.543137), place: "2"),
    Pin(id: 34,name: "種間寺", coordinate: CLLocationCoordinate2D(latitude: 33.491723, longitude: 133.487559), place: "2"),
    Pin(id: 35,name: "清滝寺", coordinate: CLLocationCoordinate2D(latitude: 33.512514, longitude: 133.409513), place: "2"),
    Pin(id: 36,name: "青龍寺", coordinate: CLLocationCoordinate2D(latitude: 33.425982, longitude: 133.452224), place: "2"),
    Pin(id: 37,name: "岩本寺", coordinate: CLLocationCoordinate2D(latitude: 33.208000, longitude: 133.134615), place: "2"),
    Pin(id: 38,name: "金剛福寺", coordinate: CLLocationCoordinate2D(latitude: 32.725572, longitude: 133.018675), place: "2"),
    Pin(id: 39,name: "延光寺", coordinate: CLLocationCoordinate2D(latitude: 32.961317, longitude: 132.774070), place: "2"),
    
    
    
    Pin(id: 40,name: "観自在寺", coordinate: CLLocationCoordinate2D(latitude: 32.964677, longitude: 132.564118), place: "3"),
    Pin(id: 41,name: "龍光寺", coordinate: CLLocationCoordinate2D(latitude: 33.295234, longitude: 132.598172), place: "3"),
    Pin(id: 42, name: "佛木寺", coordinate: CLLocationCoordinate2D(latitude: 33.310265, longitude: 132.582125), place: "3"),
    Pin(id: 43,name: "明石寺", coordinate: CLLocationCoordinate2D(latitude: 33.369224, longitude: 132.518986), place: "3"),
    Pin(id: 44,name: "大寶寺", coordinate: CLLocationCoordinate2D(latitude: 33.661179, longitude: 132.911511), place: "3"),
    Pin(id: 45,name: "岩屋寺", coordinate: CLLocationCoordinate2D(latitude: 33.658735, longitude: 132.980769), place: "3"),
    Pin(id: 46,name: "浄瑠璃寺", coordinate: CLLocationCoordinate2D(latitude: 33.753545, longitude: 132.819097), place: "3"),
    Pin(id: 47,name: "八坂寺", coordinate: CLLocationCoordinate2D(latitude: 33.757959, longitude: 132.812811), place: "3"),
    Pin(id: 48,name: "西林寺", coordinate: CLLocationCoordinate2D(latitude: 33.793573, longitude: 132.813875), place: "3"),
    Pin(id: 49,name: "浄土寺", coordinate: CLLocationCoordinate2D(latitude: 33.816823, longitude: 132.807911), place: "3"),
    Pin(id: 50,name: "繁多寺", coordinate: CLLocationCoordinate2D(latitude: 33.828120, longitude: 132.804792), place: "3"),
    Pin(id: 51,name: "石手寺", coordinate: CLLocationCoordinate2D(latitude: 33.847898, longitude: 132.796470), place: "3"),
    Pin(id: 52,name: "太山寺", coordinate: CLLocationCoordinate2D(latitude: 33.884535, longitude: 132.717990), place: "3"),
    Pin(id: 53,name: "円明寺", coordinate: CLLocationCoordinate2D(latitude: 33.891746, longitude: 132.739659), place: "3"),
    Pin(id: 54,name: "延命寺", coordinate: CLLocationCoordinate2D(latitude: 34.066826, longitude: 132.963989), place: "3"),
    Pin(id: 55,name: "南光坊", coordinate: CLLocationCoordinate2D(latitude: 34.068227, longitude: 132.995328), place: "3"),
    Pin(id: 56,name: "泰山寺", coordinate: CLLocationCoordinate2D(latitude: 34.050437, longitude: 132.974822), place: "3"),
    Pin(id: 57,name: "栄福寺", coordinate: CLLocationCoordinate2D(latitude: 34.029463, longitude: 132.978413), place: "3"),
    Pin(id: 58,name: "仙遊寺", coordinate: CLLocationCoordinate2D(latitude: 34.013232, longitude: 132.977395), place: "3"),
    Pin(id: 59,name: "国分寺", coordinate: CLLocationCoordinate2D(latitude: 34.026184, longitude: 133.025513), place: "3"),
    Pin(id: 60,name: "横峰寺", coordinate: CLLocationCoordinate2D(latitude: 33.837617, longitude: 133.111005), place: "3"),
    Pin(id: 61,name: "香園寺", coordinate: CLLocationCoordinate2D(latitude: 33.893538, longitude: 133.103254), place: "3"),
    Pin(id: 62,name: "宝寿寺", coordinate: CLLocationCoordinate2D(latitude: 33.897316, longitude: 133.114957), place: "3"),
    Pin(id: 63,name: "吉祥寺", coordinate: CLLocationCoordinate2D(latitude: 33.896109, longitude: 133.129214), place: "3"),
    Pin(id: 64,name: "前神寺", coordinate: CLLocationCoordinate2D(latitude: 33.891259, longitude: 133.160451), place: "3"),
    Pin(id: 65,name: "三角寺", coordinate: CLLocationCoordinate2D(latitude: 33.966792, longitude: 133.586647), place: "3"),
    
    
    
    
    Pin(id: 66,name: "雲辺寺", coordinate: CLLocationCoordinate2D(latitude: 34.035374, longitude: 133.723545), place: "4"),
    Pin(id: 67,name: "大興寺", coordinate: CLLocationCoordinate2D(latitude: 34.102172, longitude: 133.719171), place: "4"),
    Pin(id: 68,name: "神恵院", coordinate: CLLocationCoordinate2D(latitude: 34.134477, longitude: 133.647577), place: "4"),
    Pin(id: 69,name: "観音寺", coordinate: CLLocationCoordinate2D(latitude: 34.134477, longitude: 133.647577), place: "4"),
    Pin(id: 70,name: "本山寺", coordinate: CLLocationCoordinate2D(latitude: 34.139708, longitude: 133.694121), place: "4"),
    Pin(id: 71,name: "弥谷寺", coordinate: CLLocationCoordinate2D(latitude: 34.229754, longitude: 133.724331), place: "4"),
    Pin(id: 72,name: "曼荼羅寺", coordinate: CLLocationCoordinate2D(latitude: 34.223309, longitude: 133.750203), place: "4"),
    Pin(id: 73, name: "出釈迦寺", coordinate: CLLocationCoordinate2D(latitude: 34.219192, longitude: 133.750223), place: "4"),
    Pin(id: 74, name: "甲山寺", coordinate: CLLocationCoordinate2D(latitude: 34.233200, longitude: 133.765798), place: "4"),
    Pin(id: 75, name: "善通寺", coordinate: CLLocationCoordinate2D(latitude: 34.225056, longitude: 133.774201), place: "4"),
    Pin(id: 76, name: "金倉寺", coordinate: CLLocationCoordinate2D(latitude: 34.250068, longitude: 133.780954), place: "4"),
    Pin(id: 77, name: "道隆寺", coordinate: CLLocationCoordinate2D(latitude: 34.276665, longitude: 133.763019), place: "4"),
    Pin(id: 78, name: "郷照寺", coordinate: CLLocationCoordinate2D(latitude: 34.306689, longitude: 133.824548), place: "4"),
    Pin(id: 79, name: "天皇寺", coordinate: CLLocationCoordinate2D(latitude: 34.311384, longitude: 133.882711), place: "4"),
    Pin(id: 80, name: "国分寺", coordinate: CLLocationCoordinate2D(latitude: 34.303162, longitude: 133.944150), place: "4"),
    Pin(id: 81, name: "白峯寺", coordinate: CLLocationCoordinate2D(latitude: 34.333950, longitude: 133.926567), place: "4"),
    Pin(id: 82, name: "根香寺", coordinate: CLLocationCoordinate2D(latitude: 34.344499, longitude: 133.960561), place: "4"),
    Pin(id: 83, name: "一宮寺", coordinate: CLLocationCoordinate2D(latitude: 34.286636, longitude: 134.026533), place: "4"),
    Pin(id: 84, name: "屋島寺", coordinate: CLLocationCoordinate2D(latitude: 34.357766, longitude: 134.100965), place: "4"),
    Pin(id: 85, name: "八栗寺", coordinate: CLLocationCoordinate2D(latitude: 34.359907, longitude: 134.139827), place: "4"),
    Pin(id: 86, name: "志度寺", coordinate: CLLocationCoordinate2D(latitude: 34.323855, longitude: 134.179224), place: "4"),
    Pin(id: 87, name: "長尾寺", coordinate: CLLocationCoordinate2D(latitude: 34.266782, longitude: 134.171516), place: "4"),
    Pin(id: 88, name: "大窪寺", coordinate: CLLocationCoordinate2D(latitude: 34.191431, longitude: 134.206868), place: "4"),
    Pin(id:89, name: "橋本寺", coordinate: CLLocationCoordinate2D(latitude: 34.3040886, longitude: 134.0519187), place: "4"),
    Pin(
        id: 90,
        name: "目的地",
        coordinate: CLLocationCoordinate2D(
            latitude: 34.314623,
            longitude: 134.085374
        ),
        place: "4"
    ),
    Pin(id: 91,name: "目的地2",coordinate: CLLocationCoordinate2D(latitude: 34.29251876795014,longitude: 134.06137288189024),place: "4")
]

let syoudosimapins: [Pin] = [
    Pin(id: 1, name: "第1番 洞雲山", coordinate: CLLocationCoordinate2D(latitude: 34.461647, longitude: 134.336736), place: "1"),
    Pin(id: 2, name: "第2番 碁石山", coordinate: CLLocationCoordinate2D(latitude: 34.461292, longitude: 134.333448), place: "2"),
    Pin(id: 3, name: "第3番 観音寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "3"),
    Pin(id: 33, name: "第3番 観音寺奥之院 隼山", coordinate: CLLocationCoordinate2D(latitude: 34.458348, longitude: 134.323433), place: "3-奥"),
    Pin(id: 4, name: "第4番 古江庵", coordinate: CLLocationCoordinate2D(latitude: 34.460124, longitude: 134.314256), place: "4"),
    Pin(id: 5, name: "第5番 堀越庵", coordinate: CLLocationCoordinate2D(latitude: 34.457456, longitude: 134.300084), place: "5"),
    Pin(id: 6, name: "第6番 田の浦庵", coordinate: CLLocationCoordinate2D(latitude: 34.452249, longitude: 134.287668), place: "6"),
    Pin(id: 7, name: "第7番 向庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "7"),
    Pin(id: 8, name: "第8番 常光寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "8"),
    Pin(id: 9, name: "第9番 庚申堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "9"),
    Pin(id: 10, name: "第10番 西照庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "10"),
    Pin(id: 11, name: "第11番 観音堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "11"),
    Pin(id: 12, name: "第12番 岡之坊", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "12"),
    Pin(id: 13, name: "第13番 栄光寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "13"),
    Pin(id: 14, name: "第14番 清滝山", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "14"),
    Pin(id: 15, name: "第15番 大師堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "15"),
    Pin(id: 16, name: "第16番 極楽寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "16"),
    Pin(id: 17, name: "第17番 一ノ谷庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "17"),
    Pin(id: 18, name: "第18番 石門洞", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "18"),
    Pin(id: 19, name: "第19番 木ノ下庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "19"),
    Pin(id: 20, name: "第20番 佛ヶ滝", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "20"),
    Pin(id: 21, name: "第21番 清見寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "21"),
    Pin(id: 22, name: "第22番 峯之山庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "22"),
    Pin(id: 23, name: "第23番 本堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "23"),
    Pin(id: 24, name: "第24番 安養寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "24"),
    Pin(id: 25, name: "第25番 誓願寺庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "25"),
    Pin(id: 26, name: "第26番 阿彌陀寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "26"),
    Pin(id: 27, name: "第27番 桜ノ庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "27"),
    Pin(id: 28, name: "第28番 薬師堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "28"),
    Pin(id: 29, name: "第29番 風穴庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "29"),
    Pin(id: 30, name: "第30番 正法寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "30"),
    Pin(id: 31, name: "第31番 誓願寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "31"),
    Pin(id: 32, name: "第32番 愛染寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "32"),
    Pin(id: 33, name: "第33番 長勝寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "33"),
    Pin(id: 34, name: "第34番 保寿寺庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "34"),
    Pin(id: 35, name: "第35番 林庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "35"),
    Pin(id: 36, name: "第36番 釈迦堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "36"),
    Pin(id: 37, name: "第37番 明王寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "37"),
    Pin(id: 38, name: "第38番 光明寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "38"),
    Pin(id: 39, name: "第39番 松風庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "39"),
    Pin(id: 40, name: "第40番 保安寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "40"),
    Pin(id: 41, name: "第41番 佛谷山", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "41"),
    Pin(id: 42, name: "第42番 西の瀧", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "42"),
    Pin(id: 43, name: "第43番 浄土寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "43"),
    Pin(id: 44, name: "第44番 湯舟山", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "44"),
    Pin(id: 45, name: "第45番 地蔵寺堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "45"),
    Pin(id: 46, name: "第46番 多聞寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "46"),
    Pin(id: 47, name: "第47番 栂尾山", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "47"),
    Pin(id: 48, name: "第48番 毘沙門堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "48"),
    Pin(id: 49, name: "第49番 東林庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "49"),
    Pin(id: 50, name: "第50番 遊苦庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "50"),
    Pin(id: 51, name: "第51番 宝幢坊", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "51"),
    Pin(id: 52, name: "第52番 旧八幡宮", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "52"),
    Pin(id: 53, name: "第53番 本覚寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "53"),
    Pin(id: 54, name: "第54番 宝生院", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "54"),
    Pin(id: 55, name: "第55番 観音堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "55"),
    Pin(id: 56, name: "第56番 行者堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "56"),
    Pin(id: 57, name: "第57番 浄源坊", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "57"),
    Pin(id: 58, name: "第58番 西光寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "58"),
    Pin(id: 581, name: "第58番 西光寺奥之院 誓願之塔", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "58-奥"),
    Pin(id: 59, name: "第59番 甘露庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "59"),
    Pin(id: 60, name: "第60番 江洞窟", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "60"),
    Pin(id: 61, name: "第61番 浄土庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "61"),
    Pin(id: 62, name: "第62番 大乗殿", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "62"),
    Pin(id: 63, name: "第63番 蓮華庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "63"),
    Pin(id: 64, name: "第64番 松風庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "64"),
    Pin(id: 65, name: "第65番 光明庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "65"),
    Pin(id: 66, name: "第66番 等空庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "66"),
    Pin(id: 67, name: "第67番 瑞雲堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "67"),
    Pin(id: 68, name: "第68番 松林寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "68"),
    Pin(id: 69, name: "第69番 瑠璃堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "69"),
    Pin(id: 70, name: "第70番 長勝寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "70"),
    Pin(id: 71, name: "第71番 滝ノ宮堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "71"),
    Pin(id: 72, name: "第72番 滝湖寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "72"),
    Pin(id: 721, name: "第72番 滝湖寺奥之院 笠ヶ滝", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "72-奥"),
    Pin(id: 73, name: "第73番 救世堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "73"),
    Pin(id: 74, name: "第74番 圓満寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "74"),
    Pin(id: 75, name: "第75番 大聖寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "75"),
    Pin(id: 76, name: "第76番 金剛寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "76"),
    Pin(id: 761, name: "第76番 金剛寺奥之院 三暁庵（笠松大師）", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "76-奥"),
    Pin(id: 77, name: "第77番 歓喜寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "77"),
    Pin(id: 78, name: "第78番 雲胡庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "78"),
    Pin(id: 79, name: "第79番 薬師庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "79"),
    Pin(id: 80, name: "第80番 観音寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "80"),
    Pin(id: 81, name: "第81番 恵門ノ瀧", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "81"),
    Pin(id: 82, name: "第82番 吉田庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "82"),
    Pin(id: 83, name: "第83番 福田庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "83"),
    Pin(id: 84, name: "第84番 雲海寺", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "84"),
    Pin(id: 85, name: "第85番 本地堂", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "85"),
    Pin(id: 86, name: "第86番 当浜庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "86"),
    Pin(id: 87, name: "第87番 海庭庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "87"),
    Pin(id: 88, name: "第88番 楠霊庵", coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), place: "88")
]

let kyoutopins : [Pin] = [
    Pin(id: 201, name: "清水寺", coordinate: CLLocationCoordinate2D(latitude: 34.994856, longitude: 135.785046), place: "1"),
    Pin(id: 202, name: "金閣寺", coordinate: CLLocationCoordinate2D(latitude: 35.039371, longitude: 135.729243), place: "2"),
    Pin(id: 203, name: "銀閣寺", coordinate: CLLocationCoordinate2D(latitude: 35.027074, longitude: 135.798245), place: "3"),
    Pin(id: 204, name: "伏見稲荷大社", coordinate: CLLocationCoordinate2D(latitude: 34.967140, longitude: 135.772670), place: "4"),
    Pin(id: 205, name: "二条城", coordinate: CLLocationCoordinate2D(latitude: 35.014239, longitude: 135.748055), place: "5"),
    Pin(id: 206, name: "龍安寺", coordinate: CLLocationCoordinate2D(latitude: 35.034625, longitude: 135.718305), place: "6"),
    Pin(id: 207, name: "東寺", coordinate: CLLocationCoordinate2D(latitude: 34.980441, longitude: 135.747733), place: "7"),
    Pin(id: 208, name: "三十三間堂", coordinate: CLLocationCoordinate2D(latitude: 34.988900, longitude: 135.773400), place: "8"),
    Pin(id: 209, name: "嵐山 竹林の小径", coordinate: CLLocationCoordinate2D(latitude: 35.009400, longitude: 135.667500), place: "9"),
    Pin(id: 210, name: "貴船神社", coordinate: CLLocationCoordinate2D(latitude: 35.121900, longitude: 135.772700), place: "10"),
    Pin(id: 211, name: "上賀茂神社", coordinate: CLLocationCoordinate2D(latitude: 35.060600, longitude: 135.772600), place: "11"),
    Pin(id: 212, name: "下鴨神社", coordinate: CLLocationCoordinate2D(latitude: 35.039400, longitude: 135.772700), place: "12"),
    Pin(id: 213, name: "高台寺", coordinate: CLLocationCoordinate2D(latitude: 35.000600, longitude: 135.779300), place: "13"),
    Pin(id: 214, name: "南禅寺", coordinate: CLLocationCoordinate2D(latitude: 35.011500, longitude: 135.798400), place: "14"),
    Pin(id: 215, name: "平安神宮", coordinate: CLLocationCoordinate2D(latitude: 35.015000, longitude: 135.778600), place: "15")
]


struct Destination: Identifiable {
    let id = UUID()
    let title: String
    let center: CLLocationCoordinate2D
    let distance: CLLocationDistance
    let pins: [Pin]
}

let destinations: [Destination] = [
    .init(title: "四国88箇所", center: CLLocationCoordinate2D(latitude: 33.8417, longitude: 133.5500), distance: 1_250_000, pins: sikokuPins),
    .init(title: "京都",     center: CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681), distance: 1_250_000, pins: kyoutopins),
    .init(title: "小豆島",   center: CLLocationCoordinate2D(latitude: 34.4830, longitude: 134.2830), distance: 300_000, pins: syoudosimapins)
]
